#Formation Bonus v1.4
#----------#
#Features: Rearrange actors by rows and make formations, granting bonuses
#           based on what row and formation the actors are in.
#
#Usage:    Plug and play, customize as needed.
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    posted on the thread for the script
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
#Location for actor sprites in battle (3x3 grid only right now):
FORMATION_ROWS = 3
FORMATION_COLS = 3
#Set a number of locations equal to rows * cols
FORMATION_LOCATIONS = [
  [375,200],[425,200],[475,200],
  [395,230],[445,230],[495,230],
  [415,260],[465,260],[515,260]]
  
FORMATION_SX = 20

#If true only skills with the <RANGE> tag can be used in the back row
FORMATION_USE_RANGE = false
 
#Icon to be displayed as formation slot in the Formation Changing Scene.
FORMATION_ICON = 430
#Change in damage given/recieved based on row position:
#Front row, middle row, back row
FORMATION_ROW_ATK = [1.0, 0.8, 0.5]
FORMATION_ROW_DEF = [1.0, 0.8, 0.5]
FORMATION_ROW_MAT = [1.0, 1.0, 1.0]
FORMATION_ROW_MDF = [1.0, 1.0, 1.0]
FORMATION_ROW_TGR = [2.0, 1.0, 0.5]
 
#The special Formations actors can be placed in:
# id => { :name => "name of formation", :slots = [slots to be filled], ... }
#   Slot ids are:
#    0,1,2
#     3,4,5
#      6,7,8
#  Stat options are: :hp, :mp, :atk, :def, :mat, :mdf, :agi, :luk
#  Formation bonuses apply to all actors.
# Example:
#  1 => { :name => "Back Row", :slots => [2,5,8], :hp => 20, :mp => 5,}
FORMATION_BONUS = { 0 => {},
  1 => { :name => "One Liner", :slots => [3,4,5], :hp => 20,}
}
class Game_Actor < Game_Battler
  attr_accessor :formation_slot
  alias formation_init initialize
  alias formation_param param
  alias formation_scm skill_conditions_met?
  def initialize(actor_id)
    formation_init(actor_id)
    @formation_slot = -1
  end
  def screen_x
    FORMATION_LOCATIONS[@formation_slot][0]
  end
  def screen_y
    FORMATION_LOCATIONS[@formation_slot][1]
  end
  def front_row?
    array = []
    FORMATION_ROWS.times do |i|
      array.push(FORMATION_COLS * i)
    end
    array.include?(@formation_slot)
  end
  def middle_row?
    !front_row? && !back_row?
  end
  def back_row?
    array = []
    FORMATION_ROWS.times do |i|
      array.push(FORMATION_COLS * i + FORMATION_COLS - 1)
    end
    array.include?(@formation_slot)
  end
  def param(param_id)
    sym = [:hp,:mp,:atk,:def,:mat,:mdf,:agi,:luk]
    value = formation_param(param_id)
    if $game_party.short_form[sym[param_id]]
      value *= ($game_party.short_form[sym[param_id]] * 0.01 + 1)
    end
    [[value, param_max(param_id)].min, param_min(param_id)].max.to_i
  end
  def skill_conditions_met?(skill)
    formation_scm(skill) && check_range(skill)
  end
  def check_range(skill)
    return true unless FORMATION_USE_RANGE
    if back_row? && !skill.note.include?("<RANGE>")
      return false
    else
      return true
    end
  end
  def attack_usable?
    if FORMATION_USE_RANGE && back_row? 
      if equips[0] 
        return false if !equips[0].note.include?("<RANGE>")
      else
        return false
      end
    end
    usable?($data_skills[attack_skill_id])
  end
end
 
class Game_Enemy < Game_Battler
  def front_row?
    true
  end
  def middle_row?
    false
  end
  def back_row?
    false
  end
end
 
class Game_Battler
  def tgr
    return sparam(0) * FORMATION_ROW_TGR[2] if back_row?
    return sparam(0) * FORMATION_ROW_TGR[1] if middle_row?
    return sparam(0) * FORMATION_ROW_TGR[0]
  end
  def make_damage_value(user, item)
    value = item.damage.eval(user, self, $game_variables)
    value *= item_element_rate(user, item)
    value *= pdr if item.physical?
    value *= mdr if item.magical?
    value *= rec if item.damage.recover?
    value *= row_defense if item.physical? && !item.damage.recover?
    value *= row_attack(user) if item.physical? && !item.damage.recover?
    value *= row_magic_attack(user) if item.magical? && !item.damage.recover?
    value *= row_magic_defense if item.magical? && !item.damage.recover?
    value = apply_critical(value) if @result.critical
    value = apply_variance(value, item.damage.variance)
    value = apply_guard(value)
    @result.make_damage(value.to_i, item)
  end
  def row_defense
    return FORMATION_ROW_DEF[1] if middle_row?
    return FORMATION_ROW_DEF[2] if back_row?
    return FORMATION_ROW_DEF[0]
  end
  def row_attack(user)
    return FORMATION_ROW_ATK[2] if user.back_row?
    return FORMATION_ROW_ATK[1] if user.middle_row?
    return FORMATION_ROW_ATK[0]
  end
  def row_magic_defense
    return FORMATION_ROW_MDF[1] if middle_row?
    return FORMATION_ROW_MDF[2] if back_row?
    return FORMATION_ROW_MDF[0]
  end
  def row_magic_attack(user)
    return FORMATION_ROW_MAT[2] if user.back_row?
    return FORMATION_ROW_MAT[1] if user.middle_row?
    return FORMATION_ROW_MAT[0]
  end
end
 
class Game_Party
  attr_accessor  :formation_id
  def first_available_slot
  end
  def formation_slot(id)
    members.each do |actor|
      return actor if actor.formation_slot == id
    end
    return nil
  end
  def formation_name
    return current_formation[:name] if current_formation
    return "-----"
  end
  def setup_starting_members
    @actors = $data_system.party_members.clone
    iter = 0
    members.each do |actor|
      actor.formation_slot = iter
      iter += 1
    end
    current_formation
  end
  def current_formation
    FORMATION_BONUS.each do |sym, form|
      next if sym == 0
      valid = true
      form[:slots].each do |val|
        valid = false unless formation_slot(val)
      end
      next unless valid
      @formation_id = sym
      return FORMATION_BONUS[sym]
    end
    @formation_id = 0
    return nil
  end
  def short_form
    @formation_id = 0 unless @formation_id
    FORMATION_BONUS[@formation_id]
  end
  def add_actor(actor_id)
    return if @actors.include?(actor_id)
    @actors.push(actor_id)
    (FORMATION_ROWS * FORMATION_COLS).times do |i|
      if formation_slot(i).nil?
        $game_actors[actor_id].formation_slot = i
        break
      end
    end
    $game_player.refresh
    $game_map.need_refresh = true
  end
  def remove_actor(actor_id)
    return unless @actors.include?(actor_id)
    @actors.delete(actor_id)
    $game_actors[actor_id].formation_slot = -1
    $game_player.refresh
    $game_map.need_refresh = true
  end
end
 
class Scene_Formation < Scene_Base
  def start
    super
    @help_window = Window_Help.new(1)
    @list_window = Window_FormList.new
    @list_window.set_handler(:ok, method(:list_ok))
    @list_window.set_handler(:cancel, method(:list_cancel))
    @bonus_window = Window_FormBonus.new
    @form_window = Window_Formation.new
    @form_window.set_handler(:ok, method(:form_ok))
    @form_window.set_handler(:cancel, method(:form_cancel))
    @stat_window = Window_FormStat.new
    @list_window.select(0)
    @list_window.activate
  end
  def update
    super
    if @list_window.active
      @stat_window.set_actor(@list_window.current_item)
    elsif @form_window.active
      if @form_window.current_item
        @stat_window.set_actor(@form_window.current_item)
      else
        @stat_window.set_actor(@list_window.current_item)
      end
    end
  end
  def list_ok
    @form_window.select(@list_window.current_item.formation_slot)
    @form_window.activate
  end
  def list_cancel
    SceneManager.return
  end
  def form_ok
    index = @form_window.current_index
    actor = @list_window.current_item
    if $game_party.formation_slot(index)
      $game_party.formation_slot(index).formation_slot = actor.formation_slot
    end
    actor.formation_slot = index
    @form_window.refresh
    @bonus_window.refresh
    @stat_window.refresh
    form_cancel
  end
  def form_cancel
    @form_window.select(-1)
    @list_window.activate
  end
end
 
class Window_FormList < Window_Selectable
  def initialize
    super(0,48,Graphics.width/5*2,(Graphics.height-48)/2)
    refresh
  end
  def item_max
    $game_party.battle_members.size
  end
  def draw_item(index)
    actor = $game_party.battle_members[index]
    rect = item_rect(index)
    draw_text(rect, actor.name)
    draw_text(rect, "Lvl   ",2)
    draw_text(rect, actor.level,2)
  end
  def current_item
    return $game_party.battle_members[@index] if @index >= 0
    return nil
  end
end
 
class Window_FormBonus < Window_Base
  def initialize
    super(Graphics.width/5*2,48+(Graphics.height-48)/3*2,Graphics.width/5*3+3,(Graphics.height-48)/3+2)
    refresh
  end
  def refresh
    contents.clear
    change_color(system_color)
    draw_text(0,0,contents.width,line_height,"Bonuses:")
    return unless $game_party.current_formation
    change_color(normal_color)
    form = $game_party.current_formation
    xx = 6;yy = line_height;iter = 1
    form.each do |key, val|
      next unless [:hp,:mp,:atk,:def,:mat,:mdf,:agi,:luk].include?(key)
      case key
      when :hp
        text = sprintf("%s %+d%", Vocab::hp, val.to_s)
      when :mp
        text = sprintf("%s %+d%", Vocab::mp, val.to_s)
      when :atk
        text = sprintf("%s %+d%", Vocab::param(2), val.to_s)
      when :def
        text = sprintf("%s %+d%", Vocab::param(3), val.to_s)
      when :mat
        text = sprintf("%s %+d%", Vocab::param(4), val.to_s)
      when :mdf
        text = sprintf("%s %+d%", Vocab::param(5), val.to_s)
      when :agi
        text = sprintf("%s %+d%", Vocab::param(6), val.to_s)
      when :luk
        text = sprintf("%s %+d%", Vocab::param(7), val.to_s)
      end
      draw_text(xx,yy,contents.width/3,line_height,text)
      xx += contents.width/3
      if iter % 3 == 0
        xx = 5; yy += line_height
      end
      iter += 1
    end
  end
end
 
class Window_Formation < Window_Selectable
  def initialize
    super(Graphics.width/5*2,48,Graphics.width/5*3+3,(Graphics.height-48)/3*2)
    refresh
  end
  def refresh
    contents.clear
    xx = FORMATION_SX;yy = contents.height/3;iter = 0
    FORMATION_ROWS.times do
      FORMATION_COLS.times do
        draw_icon(FORMATION_ICON,xx,yy,$game_party.formation_slot(iter))
        if $game_party.formation_slot(iter)
          draw_actor_graphic($game_party.formation_slot(iter),xx-4,yy-16)
        end
        xx += 50
        iter += 1
      end
      xx -= FORMATION_COLS * 50
      yy += 30;xx += 10
    end
    change_color(system_color)
    draw_text(0,0,contents.width,line_height,"Formation: ")
    change_color(normal_color)
    draw_text(106,0,contents.width,line_height,$game_party.formation_name)
  end
  def item_rect(index)
    xx = FORMATION_SX;yy = contents.height/3
    xx += index % col_max * 50
    xx += 10 * (index / col_max).to_i
    yy += 30 * (index / col_max).to_i
    Rect.new(xx,yy,24,24)
  end
  def col_max; FORMATION_COLS; end
  def row_max; FORMATION_ROWS; end
  def item_max; FORMATION_COLS * FORMATION_ROWS; end
  def current_item
    $game_party.formation_slot(@index) ? $game_party.formation_slot(@index) : nil
  end
  def current_index
    @index
  end
  def draw_actor_graphic(actor,x,y)
    new_bitmap = Cache.character(actor.character_name)
    next_bitmap = new_bitmap.clone
    xx = actor.character_index % 4 * new_bitmap.width/4
    yy = actor.character_index / 4 * new_bitmap.height/2
    next_bitmap.blt(0,0,next_bitmap,Rect.new(xx,yy,next_bitmap.width/4,next_bitmap.height/2))
    contents.blt(x,y,next_bitmap,Rect.new(0,next_bitmap.height/8,next_bitmap.width/12,next_bitmap.height/8))
  end
end
 
class Window_FormStat < Window_Base
  def initialize
    super(0,48+(Graphics.height-48)/2,Graphics.width/5*2,(Graphics.height-48)/2)
    refresh
  end
  def refresh
    contents.clear
    change_color(system_color)
    draw_text(0,line_height,contents.width,line_height,"Class:")
    draw_text(0,line_height*2,contents.width/2,line_height,Vocab::hp)
    draw_text(contents.width/2,line_height*2,contents.width/2,line_height,Vocab::mp)
    draw_text(0,line_height*3,contents.width/2,line_height,Vocab::param(2))
    draw_text(contents.width/2,line_height*3,contents.width/2,line_height,Vocab::param(3))
    draw_text(0,line_height*4,contents.width/2,line_height,Vocab::param(4))
    draw_text(contents.width/2,line_height*4,contents.width/2,line_height,Vocab::param(5))
    draw_text(0,line_height*5,contents.width/2,line_height,Vocab::param(6))
    draw_text(contents.width/2,line_height*5,contents.width/2,line_height,Vocab::param(7))
    contents.fill_rect(contents.width/2-2,line_height*2.5,1,line_height*3,Color.new(155,155,155))
    return unless @actor
    change_color(normal_color)
    draw_actor_graphic(@actor,contents.width/2,32)
    draw_text(0,line_height,contents.width,line_height,@actor.class.name,2)
    draw_text(0,line_height*2,contents.width/2,line_height,@actor.mhp,2)
    draw_text(contents.width/2,line_height*2,contents.width/2,line_height,@actor.mmp,2)
    draw_text(0,line_height*3,contents.width/2,line_height,@actor.atk,2)
    draw_text(contents.width/2,line_height*3,contents.width/2,line_height,@actor.def,2)
    draw_text(0,line_height*4,contents.width/2,line_height,@actor.mat,2)
    draw_text(contents.width/2,line_height*4,contents.width/2,line_height,@actor.mdf,2)
    draw_text(0,line_height*5,contents.width/2,line_height,@actor.agi,2)
    draw_text(contents.width/2,line_height*5,contents.width/2,line_height,@actor.luk,2)
  end
  def set_actor(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
end
 
class Scene_Menu
  def command_formation
    SceneManager.call(Scene_Formation)
  end
end
 
class Window_MenuCommand
  def formation_enabled
    true
  end
end