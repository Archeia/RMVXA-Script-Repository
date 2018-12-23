#==============================================================================
# 
# • modern algebra Monster Catalogue v1.4 Add-on:
#   • Kill Counts, Elements and States Resistance, 
#     Drop Items (including Extra Drops from Yanfly),
#     and Stealable Items from Yanfly Script
# by : DrDhoom
# -- Last Updated: 2018.01.09
# -- Level: Easy, Normal
# -- Requires: modern algebra Monster Catalogue v1.1
#
#
# Aditional Credit :
#   - joeyjoejoe (Commission requester)
# 
#==============================================================================

module Dhoom
  module MonsterCatalogueAddon    
  #    :always    - The value to be shown will always be shown
  #    :encounter - The value to be shown will be shown once the monster has 
  #                been encountered. You can either manually encounter an enemy
  #                through a call script, or it will automatically happen the
  #                first time the party fights that kind of enemy.
  #    :analyze   - The value to be shown will be shown once the monster has 
  #                been analyzed. You can set either manually analyze an enemy
  #                through a call script, or you can do it by setting items and
  #                skills to be \analyze items that, when used, will analyze
  #                a monster and show data on it. By default, I do not use this
  #                option for anything.
    ENABLE_DATA_WHEN = :always
    
  # %d is where the digit would be
    KILL_TEXT = "Total Killed: %d"   
    
    ELEMENT_LABEL = "Elements"
    ELEMENT_LABEL_Y = 38
    ELEMENT_FONT_SIZE = 14
    ELEMENT_EACH_ROW = 7
    ELEMENT_SPACING = 2
    ELEMENT_WIDTH = 54    
    ELEMENT_ID = [3,4,5,6,7,8,9,10,11,12,13,14,15,16]
    DEFAULT_ELEMENT_ICON = 16
    
    ELEMENT_ICONS = []
    ELEMENT_ICONS[3] = 17
    ELEMENT_ICONS[4] = 18
    
    STATE_LABEL = "States"
    STATE_LABEL_Y = 184
    STATE_FONT_SIZE = 14
    STATE_EACH_ROW = 5
    STATE_SPACING = 2
    STATE_WIDTH = 54
    STATE_ID = [2,3,4,5,6,7,8,9,10,11]
    
    SKILL_LABEL = "Skills"
    SKILL_MANIPULATE_LABEL = "Control Skill"
    SKILL_LABEL_Y = 38
    SKILL_FONT_SIZE = 24
    SKILL_EACH_ROW = 1
    SKILL_SPACING = 6
    SKILL_WIDTH = 280
    DISABLE_SKILLS = false
    DISABLE_MANIPULATE_SKILLS = false
    
    DROP_LABEL = "Drops"
    DROP_FONT_SIZE = 21
    DROP_EACH_ROW = 1
    DROP_SPACING = 6
    DROP_WIDTH = 280
    
    STEALABLE_LABEL = "Stealables"
    STEALABLE_FONT_SIZE = 21
    STEALABLE_EACH_ROW = 1
    STEALABLE_SPACING = 6
    STEALABLE_WIDTH = 280
    STEALABLE_GOLD_ICON = 361
  end
end

class Game_System
  attr_accessor :enemy_killed
  
  alias dhoom_mcadon_gmsystem_initialize initialize
  def initialize
    dhoom_mcadon_gmsystem_initialize
    @enemy_killed = []
  end
end

module BattleManager
  class <<self; alias dhoom_mcadon_batman_battle_end battle_end; end
  def self.battle_end(result)
    $game_troop.dead_members.each do |enemy|
      $game_system.enemy_killed[enemy.enemy_id] ||= 0
      $game_system.enemy_killed[enemy.enemy_id] += 1
    end
    dhoom_mcadon_batman_battle_end(result)    
  end
end

class Window_MonsterCard < Window_Selectable
  include Dhoom::MonsterCatalogueAddon
  
  alias dhoom_mcadon_wndmcard_refresh refresh  
  def refresh(monster_id = @monster_id, index = 0)
    @tindex = index
    if @tindex == 0
      monster_id = 0 if monster_id == nil      
      if monster_id.is_a?(Game_Enemy)        
        @monster = monster_id        
        @monster_id = @monster.enemy_id  
      elsif @monster.nil? || @monster.enemy_id != monster_id
        @monster_id = monster_id
        @monster = monster_id > 0 ? Game_Enemy.new(0, @monster_id) : nil
      end
      if @monster.is_a?(Game_Enemy)
        dhoom_mcadon_wndmcard_refresh(@monster)
      else
        dhoom_mcadon_wndmcard_refresh(monster_id)
      end      
      w = MAMC_CONFIG[:frame_width]
      draw_total_killed(6 + w*2, 2 + w*2) if @monster
    elsif @tindex == 1
      contents.clear
      reset_font_settings
      w = MAMC_CONFIG[:frame_width]
      draw_frame
      draw_name(6 + w*2, 2 + w*2) if @monster
      draw_total_killed(6 + w*2, 2 + w*2) if @monster
      draw_label(ELEMENT_LABEL_Y, ELEMENT_LABEL)
      draw_label(STATE_LABEL_Y, STATE_LABEL)
      enabled = $game_system.mamc_data_conditions_met?(ENABLE_DATA_WHEN, @monster_id)
      draw_elements(enabled)
      draw_states(enabled)
    elsif @tindex == 2
      contents.clear
      reset_font_settings
      w = MAMC_CONFIG[:frame_width]
      draw_frame
      draw_name(6 + w*2, 2 + w*2) if @monster
      draw_total_killed(6 + w*2, 2 + w*2) if @monster
      enabled = $game_system.mamc_data_conditions_met?(ENABLE_DATA_WHEN, @monster_id)
      unless DISABLE_SKILLS
        draw_label(SKILL_LABEL_Y, SKILL_LABEL)
        draw_skills(enabled)
      else
        @mskill_label = SKILL_LABEL_Y
      end
      reset_font_settings
      if $imported && $imported["DHManipulate"] && !monster.enemy.control_skill.empty? && !DISABLE_MANIPULATE_SKILLS
        draw_label(@mskill_label, SKILL_MANIPULATE_LABEL)
        draw_manipulate_skills(enabled)
      else
        @drop_label = @mskill_label
      end
      items = monster.enemy.drop_items
      items += monster.enemy.extra_drops if $imported && $imported["YEA-ExtraDrops"]
      unless items.empty?
        reset_font_settings
        draw_label(@drop_label, DROP_LABEL)
        draw_drops(enabled)      
      end
    elsif @tindex == 3
      contents.clear
      reset_font_settings
      w = MAMC_CONFIG[:frame_width]
      draw_frame
      draw_name(6 + w*2, 2 + w*2) if @monster
      draw_total_killed(6 + w*2, 2 + w*2) if @monster
      enabled = $game_system.mamc_data_conditions_met?(ENABLE_DATA_WHEN, @monster_id)
      if $imported && $imported["YEA-StealItems"]
        reset_font_settings
        draw_label(SKILL_LABEL_Y, STEALABLE_LABEL)
        draw_stealables(enabled)
      end
    end
    update_help
  end
  alias monster_id= refresh
  alias monster= refresh
      
  def draw_total_killed(x, y)
    change_color(system_color)
    $game_system.enemy_killed ||= []
    $game_system.enemy_killed[@monster_id] ||= 0
    text = sprintf(KILL_TEXT, $game_system.enemy_killed[@monster_id])
    draw_text(x, y, contents_width - 2*x, line_height, text, 2)
  end  
  
  def draw_label(ay, text)
    w = MAMC_CONFIG[:frame_width]
    contents.font.bold = true
    stw = text_size(text).width + 8
    lx = 34
    y = ay + (line_height / 2)
    draw_stat_divider(1 + w, y + w, contents_width - 2 - 3*w, lx, stw, text_color(MAMC_CONFIG[:frame_shadow_colour]))
    draw_stat_divider(1, y, contents_width - 2 - w, lx, stw, text_color(MAMC_CONFIG[:frame_colour]))
    change_color(text_color(MAMC_CONFIG[:frame_colour]))
    draw_text(lx, ay, stw, line_height, text, 1)
    reset_font_settings
  end
      
  def draw_elements(enabled)
    contents.font.size = ELEMENT_FONT_SIZE
    x = (contents.width-(ELEMENT_WIDTH+ELEMENT_SPACING)*ELEMENT_EACH_ROW)/2    
    y = ELEMENT_LABEL_Y+28
    ELEMENT_ID.each_with_index do |id, i|   
      change_color(system_color)
      draw_text(x, y, ELEMENT_WIDTH, ELEMENT_FONT_SIZE, $data_system.elements[id], 1)
      if ELEMENT_ICONS[id]
        draw_icon(ELEMENT_ICONS[id], x+(ELEMENT_WIDTH-24)/2, y+ELEMENT_FONT_SIZE)
      else
        draw_icon(DEFAULT_ELEMENT_ICON, x+(ELEMENT_WIDTH-24)/2, y+ELEMENT_FONT_SIZE)
      end
      change_color(normal_color)
      if enabled
        text = "#{(monster.element_rate(id)*100).to_i}%"
      else
        text = "????"
      end
      draw_text(x, y+ELEMENT_FONT_SIZE+28, ELEMENT_WIDTH, ELEMENT_FONT_SIZE, text, 1)
      x += ELEMENT_WIDTH+ELEMENT_SPACING
      if (i+1) % ELEMENT_EACH_ROW == 0
        y += ELEMENT_FONT_SIZE*2+28+ELEMENT_SPACING
        w = ELEMENT_ID.size-(i+1) > ELEMENT_EACH_ROW ? ELEMENT_EACH_ROW : ELEMENT_ID.size-(i+1)
        x = (contents.width-(ELEMENT_WIDTH+ELEMENT_SPACING)*w)/2
      end
    end
  end
  
  def draw_states(enabled)
    contents.font.size = STATE_FONT_SIZE
    x = (contents.width-(STATE_WIDTH+STATE_SPACING)*STATE_EACH_ROW)/2    
    y = STATE_LABEL_Y+28
    states = []
    $data_states.compact.each do |state|
      states.push(state) if STATE_ID.include?(state.id)
    end
    states.each_with_index do |state, i| 
      change_color(system_color)
      draw_text(x, y, STATE_WIDTH, STATE_FONT_SIZE, state.name, 1)
      draw_icon(state.icon_index, x+(STATE_WIDTH-24)/2, y+STATE_FONT_SIZE)
      change_color(normal_color)
      if enabled
        text = "#{(monster.state_rate(state.id)*100).to_i}%"
      else
        text = "????"
      end
      draw_text(x, y+STATE_FONT_SIZE+28, STATE_WIDTH, STATE_FONT_SIZE, text, 1)
      x += STATE_WIDTH+STATE_SPACING
      if (i+1) % STATE_EACH_ROW == 0
        y += STATE_FONT_SIZE*2+28+STATE_SPACING
        w = states.size-(i+1) > STATE_EACH_ROW ? STATE_EACH_ROW : states.size-(i+1)
        x = (contents.width-(STATE_WIDTH+STATE_SPACING)*w)/2
      end
    end    
  end
  
  def draw_skills(enabled)
    contents.font.size = SKILL_FONT_SIZE
    x = (contents.width-(SKILL_WIDTH+SKILL_SPACING)*SKILL_EACH_ROW)/2    
    y = SKILL_LABEL_Y+28
    skills = []
    monster.enemy.actions.each do |action|
      skills.push(action.skill_id) unless skills.include?(action.skill_id)
    end
    skills.each_with_index do |id, i|
      change_color(normal_color)
      draw_icon($data_skills[id].icon_index, x, y+(SKILL_FONT_SIZE-24)/2) if enabled
      text = enabled ? $data_skills[id].name : $data_skills[id].name.gsub(/./,"?")
      draw_text(x+28, y, SKILL_WIDTH-28, SKILL_FONT_SIZE, text)
      x += SKILL_WIDTH+SKILL_SPACING
      if (i+1) % SKILL_EACH_ROW == 0
        y += SKILL_FONT_SIZE+SKILL_SPACING
        x = (contents.width-(SKILL_WIDTH+SKILL_SPACING)*SKILL_EACH_ROW)/2
        @mskill_label = y
      else
        @mskill_label = y+SKILL_FONT_SIZE+SKILL_SPACING
      end
    end
  end
  
  def draw_manipulate_skills(enabled)
    contents.font.size = SKILL_FONT_SIZE
    x = (contents.width-(SKILL_WIDTH+SKILL_SPACING)*SKILL_EACH_ROW)/2    
    y = @mskill_label+28
    if monster.enemy.control_skill.empty?
      change_color(normal_color)
      draw_text(x, y, SKILL_WIDTH, SKILL_FONT_SIZE, "None")
      @drop_label = y+SKILL_FONT_SIZE+SKILL_SPACING
    else
      monster.enemy.control_skill.each_with_index do |skill, i|
        change_color(normal_color)
        draw_icon(skill.icon_index, x, y+(SKILL_FONT_SIZE-24)/2) if enabled
        text = enabled ? skill.name : skill.name.gsub(/./,"?")
        draw_text(x+28, y, SKILL_WIDTH-28, SKILL_FONT_SIZE, text)
        x += SKILL_WIDTH+SKILL_SPACING
        if (i+1) % SKILL_EACH_ROW == 0
          y += SKILL_FONT_SIZE+SKILL_SPACING
          x = (contents.width-(SKILL_WIDTH+SKILL_SPACING)*SKILL_EACH_ROW)/2
          @drop_label = y
        else
          @drop_label = y+SKILL_FONT_SIZE+SKILL_SPACING
        end
      end
    end
  end
  
  def draw_drops(enabled)
    contents.font.size = DROP_FONT_SIZE
    x = (contents.width-(DROP_WIDTH+DROP_SPACING)*DROP_EACH_ROW)/2    
    y = @drop_label+28
    items = monster.enemy.drop_items
    items += monster.enemy.extra_drops if $imported && $imported["YEA-ExtraDrops"]
    items.select{|v| v.kind != 0}.each_with_index do |drop, i|
      change_color(normal_color)
      case drop.kind
      when 1
        item = $data_items[drop.data_id]
      when 2
        item = $data_weapons[drop.data_id]
      when 3
        item = $data_armors[drop.data_id]
      end
      draw_icon(item.icon_index, x, y+(DROP_FONT_SIZE-24)/2) if enabled
      text = enabled ? item.name : item.name.gsub(/./,"?")
      if $imported && $imported["YEA-ExtraDrops"] && drop.drop_rate > 0
        percent = "#{(drop.drop_rate * 100).to_i}%"
      else
        percent = "#{(1.0/drop.denominator*100).to_i}%"
      end
      amount = enabled ? percent : percent.gsub(/./,"?")
      draw_text(x+28, y, DROP_WIDTH-28-DROP_FONT_SIZE*2, DROP_FONT_SIZE, text)
      draw_text(x, y, DROP_WIDTH, DROP_FONT_SIZE, amount, 2)
      x += DROP_WIDTH+DROP_SPACING
      if (i+1) % DROP_EACH_ROW == 0
        y += DROP_FONT_SIZE+DROP_SPACING
        x = (contents.width-(DROP_WIDTH+DROP_SPACING)*DROP_EACH_ROW)/2
        @stealable_label = y
      else
        @stealable_label = y+DROP_FONT_SIZE+DROP_SPACING
      end
    end
  end
  
  def draw_stealables(enabled)
    contents.font.size = STEALABLE_FONT_SIZE
    x = (contents.width-(STEALABLE_WIDTH+STEALABLE_SPACING)*STEALABLE_EACH_ROW)/2    
    y = SKILL_LABEL_Y+28
    monster.enemy.stealable_items.each_with_index do |drop, i|
      change_color(normal_color)      
      case drop.kind
      when 1
        item = $data_items[drop.data_id]
      when 2
        item = $data_weapons[drop.data_id]
      when 3
        item = $data_armors[drop.data_id]
      when 4
        item = 'gold'
      end
      icon = item === 'gold' ? STEALABLE_GOLD_ICON : item.icon_index
      draw_icon(icon, x, y+(STEALABLE_FONT_SIZE-24)/2) if enabled
      name = item === 'gold' ? Vocab.currency_unit : item.name
      text = enabled ? name : name.gsub(/./,"?")
      percent = "#{(drop.rate*100).to_i}%"
      amount = enabled ? percent : percent.to_s.gsub(/./,"?")
      draw_text(x+28, y, STEALABLE_WIDTH-28-STEALABLE_FONT_SIZE*2, STEALABLE_FONT_SIZE, text)
      draw_text(x, y, STEALABLE_WIDTH, STEALABLE_FONT_SIZE, amount, 2)
      x += STEALABLE_WIDTH+STEALABLE_SPACING
      if (i+1) % STEALABLE_EACH_ROW == 0
        y += STEALABLE_FONT_SIZE+STEALABLE_SPACING
        x = (contents.width-(STEALABLE_WIDTH+STEALABLE_SPACING)*STEALABLE_EACH_ROW)/2
      end
    end
  end
    
  def update
    super
    return unless self.active && self.visible
    if Input.trigger?(:LEFT)
      Sound.play_cursor
      @tindex -= 1
      @tindex = $imported && $imported["YEA-StealItems"] ? 3 : 2 if @tindex == -1
    elsif Input.trigger?(:RIGHT)
      Sound.play_cursor
      @tindex += 1
      max = $imported && $imported["YEA-StealItems"] ? 4 : 3
      @tindex = 0 if @tindex == max
    end
    if @temp_index != @tindex
      @temp_index = @tindex
      refresh(@monster_id, @tindex)
    end
  end
end

class Scene_MonsterCatalogue < Scene_MenuBase
  alias dhoom_mcadon_scmcat_create_category_window create_category_window
  def create_category_window
    dhoom_mcadon_scmcat_create_category_window
    if @category_window
      @category_window.set_handler(:ok,       method(:activate_monstercard_window))
    end
  end
  
  alias dhoom_mcadon_scmcat_create_monsterlist_window create_monsterlist_window
  def create_monsterlist_window
    dhoom_mcadon_scmcat_create_monsterlist_window
    @monsterlist_window.set_handler(:ok,       method(:activate_monstercard_window))
    @monsterlist_window.set_handler(:cancel,   method(:return_scene))
  end
  
  alias dhoom_mcadon_scmcat_create_monstercard_window create_monstercard_window
  def create_monstercard_window
    dhoom_mcadon_scmcat_create_monstercard_window
    @monstercard_window.set_handler(:cancel,   method(:deactivate_monstercard_window))
    @monstercard_window.deactivate
  end
  
  def activate_monstercard_window
    @monstercard_window.activate
    @monsterlist_window.deactivate
    @category_window.deactivate if @category_window
  end
  
  def deactivate_monstercard_window
    @monstercard_window.deactivate
    @monsterlist_window.activate
    @category_window.activate if @category_window
  end
end

class Scene_Battle
  def create_monstercard_window
    x = (Graphics.width - @status_window.width) / 2
    @monstercard_window = Window_MonsterCard.new(x, 0, @status_window.width, Graphics.height)
    @monstercard_window.z = [@log_window.z + 1, 200].max
    @monstercard_window.openness = 0
    # Include the BattleMonsterCard module in the singleton class
    @monstercard_window.send(:extend, MAMC_BattleMonsterCard)
    @monstercard_window.set_handler(:cancel, lambda { close_monster_card_window })
    @monstercard_window.set_handler(:ok, lambda { close_monster_card_window })
  end

  alias dhoom_mcadon_scbat_mamc_analyze_monster mamc_analyze_monster
  def mamc_analyze_monster(target)
    dhoom_mcadon_scbat_mamc_analyze_monster(target)
    @status_window.hide
    @actor_command_openned = @actor_command_window.open?
    @actor_command_window.openness = 0
  end
  
  alias dhoom_mcadon_scbat_close_monster_card_window close_monster_card_window
  def close_monster_card_window
    dhoom_mcadon_scbat_close_monster_card_window
    @status_window.show
    @actor_command_window.openness = 255 if @actor_command_openned
  end  
end