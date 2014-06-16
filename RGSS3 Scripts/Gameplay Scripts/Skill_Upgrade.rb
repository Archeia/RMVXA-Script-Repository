#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Skill Upgrade
#  Author: Kread-EX
#  Version 1.07
#  Release date: 24/12/2012
#
#  For Rukaroa.
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
 
#------------------------------------------------------------------------------
#  ▼ UPDATES
#------------------------------------------------------------------------------
# # 06/02/2013. Fixed compatibility issue with Yanfly's Autobattle.
# # 29/12/2012. Added the option to have negative values for MP/TP inflation.
# # 28/12/2012. Fixed a bug with the JP display when Ace Menu Engine isn't
# # installed.  Fixed a bug in the skill list when no skill is present.
# #             Fixed a bug with non numerical damage values.
# # 26/12/2012. Added the option to disable downgrades.
# # 26/12/2012. Fixed another bug with JP.
# # 26/12/2012. Fixed a bug with the level window.
#------------------------------------------------------------------------------
#  ▼ TERMS OF USAGE
#------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work for commercial purposes if you like it.
# #  Credit is appreciated.
# #
# # For support:
# # grimoirecastle.wordpress.com
# # rpgmakerweb.com
#------------------------------------------------------------------------------
#  ▼ INTRODUCTION
#------------------------------------------------------------------------------
# # Allows to upgrade/downgrade skills with either JP, gold, or a game
# # variable.
#------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#------------------------------------------------------------------------------
# # Before everything, you should put this script below the JP Manager if you
# # intend to use JP for upgrade.
# #
# # Start by visiting the configuration section of the script to set up the
# # default parameters. They're all commented and apply to every skill.
# #
# # In order to customize the system for each skill, you will use notetags in
# # the skills' notebox.
# #
# # <upgrade_cost: x>
# # This is the base cost for a skill upgrade.
# # 
# # <upgrade_formula: string>
# # How the cost rises after each upgrade. You need some basic Ruby syntax
# # knowledge in order to use this option but there are two specific words:
# # cost refers to the base cost.
# # level refers to the next skill level.
# #
# # <max_level: x>
# # The maximum level a skill can attain.
# #
# # <upgrade_damage: x>
# # The percentage of damage bonus per level.
# #
# # <upgrade_mp: x>
# # The percentage of additional MP cost per level.
# #
# # <upgrade_tp: x>
# # The percentage of additional TP cost per level.
# #
# # <level_morph: x, y>
# # At level X, skill will transform into skill Y. This is a one-way process,
# # so downgrade won't be allowed after a morph.
#------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#------------------------------------------------------------------------------
# # Compatible with Yanfly's JP Manager and Ace Menu Engine
# #
# # List of new classes:
# # 
# # Scene_Upgrade
# # Window_UpgradeStats
# # Window_UpgradeList
# # Window_UpgradeSkillCommand
# # Window_UpgradeStatus
# # Window_UpgradeCommand
# #
# # List of aliases and overwrites:
# # 
# # DataManager
# # load_database (alias)
# # load_supgrade_notetags (new method)
# # 
# # RPG::Skill
# # load_supgrade_notetags (new method)
# # upgrade_data (new method)
# # make_cost (new method)
# # 
# # Game_Battler
# # make_damage_value (alias)
# # 
# # Game_Actor
# # skill_level (new method)
# # skill_mp_cost (alias)
# # skill_tp_cost (alias)
# # upgrade_skill (new method)
# # downgrade_skill (new method)
# # mod_skill_level (new method)
#------------------------------------------------------------------------------

$imported = {} if $imported.nil?
$imported['KRX-SkillUpgrade'] = true

puts 'Load: Skill Upgrade v1.07 by Kread-EX'

module KRX
#===========================================================================
# ■ CONFIGURATION
#===========================================================================
  # The 'currency' used to upgrade skills.
  # :jp requires Yanfly's JP Manager.
  # :gold just uses the party's gold.
  # :variable uses a game variable.
  UPGRADE_CURRENCY = :jp
  
  # The ID of the variable used as currency (if :variable is used).
  UPGRADE_VARIABLE_ID = 5
  
  # Set to true to disable the downgrade option.
  DISABLE_DOWNGRADE = false
  
  # Default max level.
  SKILL_MAX_LEVEL = 10
  
  # Default upgrade cost.
  UPGRADE_COST = 100
  
  # Default upgrade formula.
  UPGRADE_FORMULA = "cost * level"
  
  # Default damage inflation.
  UPGRADE_DAMAGE = 20
  
  # Default MP inflation.
  UPGRADE_MP = 20
  
  # Default TP inflation
  UPGRADE_TP = 10
  
  # Percentage of the currency NOT retrieved when downgrading skills.
  DOWNGRADE_MALUS = 30
  
  # X offset in the upgrade menu.
  UPGRADE_X_OFFSET = 96
  
  module VOCAB
    
    SKILL_MAX_LV = 'Maxed'
    SKILL_MIN_LV = 'Min'
    SKILL_COST = 'Cost:'
    SKILL_DAMAGE = 'Damage%:'
    UPGRADE_SKILL = 'Upgrade'
    DOWNGRADE_SKILL = 'Downgrade'
    
  end
#===========================================================================
# ■ CONFIGURATION ENDS HERE
#===========================================================================
  module REGEXP
    SU_COST = /<upgrade_cost:[ ]*(\d+)>/i
    SU_FORMULA = /<upgrade_formula:[ ]*(.+)>/i
    SU_LEVEL_MAX = /<max_level:[ ]*(\d+)>/i
    SU_MORPH = /<level_morph:[ ]*(\d+)[,]?[ ]*(\d+)/i
    SU_DAMAGE = /<upgrade_damage:[ ]*(\d+)>/i
    SU_MP = /<upgrade_mp:[ ]*(-?\d+)>/i
    SU_TP = /<upgrade_tp:[ ]*(-?\d+)>/i
  end
end

# JP Manager check
if KRX::UPGRADE_CURRENCY == :jp && !$imported["YEA-JPManager"]
  msgbox("You need the JP Manager to use JP for skill upgrade.\n" +
  "The option has been reverted to Gold instead.")
  KRX::UPGRADE_CURRENCY = :gold
end # End JP Manager check

#===========================================================================
# ■ DataManager
#===========================================================================

module DataManager  
	#--------------------------------------------------------------------------
	# ● Loads the database
	#--------------------------------------------------------------------------
	class << self; alias_method(:krx_supgrade_dm_ld, :load_database); end
	def self.load_database
		krx_supgrade_dm_ld
		load_supgrade_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_supgrade_notetags
    for obj in $data_skills
      next if obj.nil?
      obj.load_supgrade_notetags
    end
		puts "Read: Skill Upgrade Notetags"
	end
end

#==========================================================================
# ■ RPG::Skill
#==========================================================================

class RPG::Skill < RPG::UsableItem
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_supgrade_notetags
		@note.split(/[\r\n]+/).each do |line|
			case line
      when KRX::REGEXP::SU_COST
        @upgrade_cost = $1.to_i
      when KRX::REGEXP::SU_FORMULA
        @upgrade_formula = $1
      when KRX::REGEXP::SU_LEVEL_MAX
        @upgrade_maxlv = $1.to_i
      when KRX::REGEXP::SU_MORPH
        @upgrade_morph = [$1.to_i, $2.to_i]
      when KRX::REGEXP::SU_DAMAGE
        @upgrade_damage = $1.to_i
      when KRX::REGEXP::SU_MP
        @upgrade_mp = $1.to_i
      when KRX::REGEXP::SU_TP
        @upgrade_tp = $1.to_i
			end
		end
  end
	#--------------------------------------------------------------------------
	# ● Returns upgrade data
	#--------------------------------------------------------------------------
	def upgrade_data
    return @upgrade_data if @upgrade_data
    cost = @upgrade_cost || KRX::UPGRADE_COST
    formula = @upgrade_formula || KRX::UPGRADE_FORMULA
    lv = @upgrade_maxlv || KRX::SKILL_MAX_LEVEL
    damage = @upgrade_damage || KRX::UPGRADE_DAMAGE
    mp = @upgrade_mp || KRX::UPGRADE_MP
    tp = @upgrade_tp || KRX::UPGRADE_TP
    morph = @upgrade_morph || 0
    @upgrade_data = {
      :cost => cost,
      :formula => formula,
      :lv => lv,
      :morph => morph,
      :damage => damage,
      :mp => mp,
      :tp => tp
    }
    @upgrade_data
  end
	#--------------------------------------------------------------------------
	# ● Returns the actual cost, based on the formula
	#--------------------------------------------------------------------------
  def make_cost(level)
    formula = upgrade_data[:formula]
    cost = upgrade_data[:cost]
    return eval(formula)
  end
end

#==========================================================================
# ■ Game_Battler
#==========================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● Calculate the damage dealt
  #--------------------------------------------------------------------------
  alias_method(:krx_supgrade_gb_mdv, :make_damage_value)
  def make_damage_value(user, item)
    krx_supgrade_gb_mdv(user, item)
    if user.actor? && item.is_a?(RPG::Skill)
      value = @result.hp_damage if item.damage.to_hp?
      value = @result.mp_damage if item.damage.to_mp?
      return if value.nil? || value == 0
      base = item.upgrade_data[:damage]
      lv = user.skill_level(item)
      value += (value * base * lv / 100.00).round
      @result.make_damage(value.to_i, item)
    end
  end
end

#==========================================================================
# ■ Game_Actor
#==========================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● Returns the current skill level
  #--------------------------------------------------------------------------
  def skill_level(skill)
    @skill_level ||= {}
    @skill_level[skill.id] || 0
  end
  #--------------------------------------------------------------------------
  # ● Returns the MP cost for a skill
  #--------------------------------------------------------------------------
  alias_method(:krx_supgrade_ga_smc, :skill_mp_cost)
  def skill_mp_cost(skill)
    cost = krx_supgrade_ga_smc(skill)
    cost += (skill.upgrade_data[:mp] * skill_level(skill) * cost / 100.00).round
    cost = [cost, 0].max
  end
  #--------------------------------------------------------------------------
  # ● Returns the TP cost for a skill
  #--------------------------------------------------------------------------
  alias_method(:krx_supgrade_ga_stc, :skill_tp_cost)
  def skill_tp_cost(skill)
    cost = krx_supgrade_ga_stc(skill)
    cost += (skill.upgrade_data[:tp] * skill_level(skill) * cost / 100.00).round
    cost = [[cost, 0].max, max_tp].min
  end
  #--------------------------------------------------------------------------
  # ● Upgrades a skill
  #--------------------------------------------------------------------------
  def upgrade_skill(skill)
    @skill_level[skill.id] ||= 0
    @skill_level[skill.id] += 1
    mid = skill.upgrade_data[:morph][0]
    if mid > 0 && skill_level(skill) == mid
      morph = $data_skills[skill.upgrade_data[:morph][1]]
      ind = @skills.index(skill.id)
      @skills[ind] = morph.id
      @skill_level[morph.id] ||= 0
    end
    cur = KRX::UPGRADE_CURRENCY
    lose_jp(skill.make_cost(skill_level(skill))) if cur == :jp
    $game_party.lose_gold(skill.make_cost(skill_level(skill))) if cur == :gold
  end
  #--------------------------------------------------------------------------
  # ● Downgrades a skill
  #--------------------------------------------------------------------------
  def downgrade_skill(skill)
    cost = skill.make_cost(skill_level(skill))
    cost -= cost.to_f * KRX::DOWNGRADE_MALUS / 100
    cur = KRX::UPGRADE_CURRENCY
    earn_jp(cost.round) if cur == :jp
    $game_party.gain_gold(cost.round) if cur == :gold
    if cur == :variable
      var = $game_variables[KRX::UPGRADE_VARIABLE_ID]
      var += cost.round
    end
    @skill_level[skill.id] -= 1
  end
  #--------------------------------------------------------------------------
  # ● Alter skill level without any currency effect
  #--------------------------------------------------------------------------
  def mod_skill_level(skill, lv)
    @skill_level[skill.id] ||= 0
    @skill_level[skill.id] += lv
  end
end

#==============================================================================
# ■ Window_UpgradeCommand
#==============================================================================

class Window_UpgradeCommand < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ● Get window width
  #--------------------------------------------------------------------------
  def window_width
    return Graphics.width / 2
  end
  #--------------------------------------------------------------------------
  # ● Get number of columns
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # ● Make the command list
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(KRX::VOCAB::UPGRADE_SKILL, :upgrade)
    add_command(KRX::VOCAB::DOWNGRADE_SKILL, :downgrade)
  end
end

#==============================================================================
# ■ Window_UpgradeStatus
#==============================================================================

class Window_UpgradeStatus < Window_SkillStatus
  #--------------------------------------------------------------------------
  # ● Refresh
  #--------------------------------------------------------------------------
  def refresh
    super
    return unless @actor
    cur = KRX::UPGRADE_CURRENCY
    cy = $imported["YEA-AceMenuEngine"] ? line_height * 3 : 0
    draw_actor_jp(@actor, 0, cy, contents_width) if cur == :jp
    if cur == :gold
      voc = Vocab.currency_unit
      value = $game_party.gold
      draw_currency_value(value, voc, 4, cy, contents.width - 8)
    end
    if cur == :variable
      var = $game_variables[KRX::UPGRADE_VARIABLE_ID]
      name = $data_system.variables[KRX::UPGRADE_VARIABLE_ID]
      cx = text_size(name).width
      change_color(normal_color)
      draw_text(0, cy, contents_width - cx - 2, line_height, var, 2)
      change_color(system_color)
      draw_text(0, cy, contents_width, line_height, name, 2)
    end
  end
end

#==============================================================================
# ■ Window_UpgradeSkillCommand
#==============================================================================

class Window_UpgradeSkillCommand < Window_SkillCommand
  #--------------------------------------------------------------------------
  # ● Makes the command list
  #--------------------------------------------------------------------------
  def make_command_list
    return unless @actor
    @actor.added_skill_types.sort.each do |stype_id|
      name = $data_system.skill_types[stype_id]
      add_command(name, :skill, true, stype_id)
    end
  end
end

#==============================================================================
# ■ Window_UpgradeList
#==============================================================================

class Window_UpgradeList < Window_SkillList
  #--------------------------------------------------------------------------
  # ● Get mode
  #--------------------------------------------------------------------------
  def mode
    @mode || :upgrade
  end
  #--------------------------------------------------------------------------
  # ● Set mode
  #--------------------------------------------------------------------------
  def mode=(x)
    @mode = x
    refresh
  end
  #--------------------------------------------------------------------------
  # ● Get number of columns
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  #--------------------------------------------------------------------------
  # ● Determine if a skill is greyed out
  #--------------------------------------------------------------------------
  def enable?(item)
    return false if item.nil?
    return false if max_level?(item)
    return false if cannot_pay?(item)
    true
  end
  #--------------------------------------------------------------------------
  # ● Determine if the skill level is maxed
  #--------------------------------------------------------------------------
  def max_level?(item)
    if mode == :upgrade
      level = @actor.skill_level(item)
      max = item.upgrade_data[:lv]
      return (level + 1) == max
    end
    @actor.skill_level(item) == 0
  end
  #--------------------------------------------------------------------------
  # ● Determine if the cost can't be payed
  #--------------------------------------------------------------------------
  def cannot_pay?(skill)
    return false if mode == :downgrade
    cost = skill.make_cost(@actor.skill_level(skill) + 1)
    cur = KRX::UPGRADE_CURRENCY
    now_cur = @actor.jp if cur == :jp
    now_cur = $game_party.gold if cur == :gold
    now_cur = $game_variables[KRX::UPGRADE_VARIABLE_ID] if cur == :variable
    now_cur < cost
  end
  #--------------------------------------------------------------------------
  # ● Draw the JP, gold or variable cost
  #--------------------------------------------------------------------------
  def draw_skill_cost(rect, skill)
    if mode == :upgrade
      text = skill.make_cost(@actor.skill_level(skill) + 1)
      text = KRX::VOCAB::SKILL_MAX_LV if max_level?(skill)
      draw_text(rect, text, 2)
      return
    end
    cost = skill.make_cost(@actor.skill_level(skill))
    cost -= cost.to_f * KRX::DOWNGRADE_MALUS / 100
    text = cost.round.to_s
    text = KRX::VOCAB::SKILL_MIN_LV if @actor.skill_level(skill) == 0
    draw_text(rect, text, 2)
  end
end

#==============================================================================
# ■ Window_UpgradeStats
#==============================================================================

class Window_UpgradeStats < Window_Base
  #--------------------------------------------------------------------------
  # ● Public instance variables
  #--------------------------------------------------------------------------
  attr_accessor  :actor
  attr_accessor  :skill_window
  #--------------------------------------------------------------------------
  # ● Object initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, w, h)
    super(x, y, w, h)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    @actor = $game_party.menu_actor
    refresh if @skill_window && @skill_window.item != @last_item
  end
  #--------------------------------------------------------------------------
  # ● Return the current skill
  #--------------------------------------------------------------------------
  def item
    @morph_item || @last_item
  end
  #--------------------------------------------------------------------------
  # ● Refresh
  #--------------------------------------------------------------------------
  def refresh
    @last_item = @skill_window.item if @skill_window
    @morph_item = @last_item
    contents.clear
    draw_background
    return if @last_item.nil?
    draw_legends(1)
    draw_current_level
    draw_legends(5)
    draw_next_level if @skill_window.mode == :upgrade
    draw_previous_level if @skill_window.mode == :downgrade
  end
  #--------------------------------------------------------------------------
  # ● Draw the background bars (easy integration with YF menus)
  #--------------------------------------------------------------------------
  def draw_background
    color = Color.new(0, 0, 0, translucent_alpha / 2)
    rect = Rect.new(1, line_height + 1, contents_width - 2, line_height - 2)
    (0..6).each do |i|
      unless i == 3 || ((@skill_window && @skill_window.mode == :downgrade) &&
      [2, 6].include?(i))
        contents.fill_rect(rect, color)
      end
      rect.y += line_height
    end
  end
  #--------------------------------------------------------------------------
  # ● Draw the legends
  #--------------------------------------------------------------------------
  def draw_legends(line)
    cap = "#{Vocab.tp_a} #{KRX::VOCAB::SKILL_COST}" if item.tp_cost >= 0
    cap = "#{Vocab.mp_a} #{KRX::VOCAB::SKILL_COST}" if item.mp_cost > 0
    change_color(system_color)
    y = line_height * line
    draw_text(4, y, contents_width, line_height, cap)
    cap = KRX::VOCAB::SKILL_DAMAGE
    y += line_height
    draw_text(4, y, contents_width, line_height, cap)
    return if @skill_window.mode == :downgrade
    cap = case KRX::UPGRADE_CURRENCY
      when :jp; YEA::JP::VOCAB
      when :gold; Vocab.currency_unit
      when :variable; $data_system.variables[KRX::UPGRADE_VARIABLE_ID]
    end
    y += line_height
    draw_text(4, y, contents_width, line_height, cap + ' ' + KRX::VOCAB::SKILL_COST)
  end
  #--------------------------------------------------------------------------
  # ● Draw the current skill level
  #--------------------------------------------------------------------------
  def draw_current_level
    change_color(normal_color)
    name = item.name.dup
    if @actor.skill_level(item) > 0
      name << ' (+' + @actor.skill_level(item).to_s + ')'
    end
    tw = text_size(name).width
    draw_icon(item.icon_index, (contents_width - tw) / 2 - 12, 0)
    draw_text(28, 0, contents_width - 28, line_height, name, 1)
    y = line_height
    draw_tp_mp(0, y)
    y += line_height
    draw_damage(@actor.skill_level(item), y)
    y += line_height
    draw_cost(@actor.skill_level(item), y)
  end
  #--------------------------------------------------------------------------
  # ● Draw the next skill level
  #--------------------------------------------------------------------------
  def draw_next_level
    mid = item.upgrade_data[:morph][0]
    if mid > 0 && @actor.skill_level(item) + 1 == mid
      @morph_item = $data_skills[item.upgrade_data[:morph][1]]
    end
    change_color(normal_color)
    name = item.name.dup
    unless @morph_item != @last_item
      name << ' (+' + (@actor.skill_level(item) + 1).to_s + ')'
    end
    tw = text_size(name).width
    y = line_height * 4
    draw_icon(item.icon_index, (contents_width - tw) / 2 - 12, y)
    draw_text(28, y, contents_width - 28, line_height, name, 1)
    y += line_height
    draw_tp_mp(1, y)
    y += line_height
    draw_damage(@actor.skill_level(item) + 1, y)
    y += line_height
    draw_cost(@actor.skill_level(@last_item) + 1, y)
  end
  #--------------------------------------------------------------------------
  # ● Draw the previous skill level
  #--------------------------------------------------------------------------
  def draw_previous_level
    change_color(normal_color)
    return if @actor.skill_level(item) == 0
    name = @last_item.name.dup
    unless @actor.skill_level(item) == 1
      name << ' (+' + (@actor.skill_level(item) - 1).to_s + ')'
    end
    tw = text_size(name).width
    y = line_height * 4
    draw_icon(item.icon_index, (contents_width - tw) / 2 - 12, y)
    draw_text(28, y, contents_width - 28, line_height, name, 1)
    y += line_height
    draw_tp_mp(-1, y)
    y += line_height
    draw_damage(@actor.skill_level(item) - 1, y)
    y += line_height
    draw_cost(@actor.skill_level(item) - 1, y)
  end
  #--------------------------------------------------------------------------
  # ● Draw MP/TP rate
  #--------------------------------------------------------------------------
  def draw_tp_mp(level, y)
    @actor.mod_skill_level(item, level) unless @morph_item != @last_item
    cost = '---'
    cost = @actor.skill_tp_cost(item) if item.tp_cost > 0
    cost = @actor.skill_mp_cost(item) if item.mp_cost > 0
    @actor.mod_skill_level(item, -level) unless @morph_item != @last_item
    x = KRX::UPGRADE_X_OFFSET
    draw_text(x, y, 128, line_height, cost)
  end
  #--------------------------------------------------------------------------
  # ● Draw damage rate
  #--------------------------------------------------------------------------
  def draw_damage(level, y)
    rate = 100
    level -= 1 if @morph_item != @last_item
    if item.damage.to_hp?
      rate += level * item.upgrade_data[:damage]
    else
      rate = '---'
    end
    rate = rate.to_s + '%' if rate.is_a?(Numeric)
    x = KRX::UPGRADE_X_OFFSET
    draw_text(x, y, 128, line_height, rate)
  end
  #--------------------------------------------------------------------------
  # ● Draw cost
  #--------------------------------------------------------------------------
  def draw_cost(level, y)
    return if @skill_window.mode == :downgrade
    cost = @last_item.make_cost(level)
    cost = KRX::VOCAB::SKILL_MAX_LV if @skill_window.max_level?(item)
    cost = KRX::VOCAB::SKILL_MIN_LV if level == 0
    x = KRX::UPGRADE_X_OFFSET
    draw_text(x, y, 128, line_height, cost)
  end
end

#==============================================================================
# ■ Scene_Upgrade
#==============================================================================

class Scene_Upgrade < Scene_Skill
  #--------------------------------------------------------------------------
  # ● Start scene
  #--------------------------------------------------------------------------
  def start
    super
    create_param_window
    create_upgrade_window
  end
  #--------------------------------------------------------------------------
  # ● Create the command window
  #--------------------------------------------------------------------------
  def create_command_window
    wy = @help_window.height
    @command_window = Window_UpgradeSkillCommand.new(0, wy)
    @command_window.viewport = @viewport
    @command_window.help_window = @help_window
    @command_window.actor = @actor
    @command_window.set_handler(:skill,    method(:command_skill))
    @command_window.set_handler(:cancel,   method(:return_scene))
    @command_window.set_handler(:pagedown, method(:next_actor))
    @command_window.set_handler(:pageup,   method(:prev_actor))
  end
  #--------------------------------------------------------------------------
  # ● Create the upgrade command window
  #--------------------------------------------------------------------------
  def create_upgrade_window
    y = @status_window.y + @status_window.height
    @upgrade_window = Window_UpgradeCommand.new(0, y)
    @upgrade_window.viewport = @viewport
    @upgrade_window.deactivate
    if KRX::DISABLE_DOWNGRADE
      @upgrade_window.hide
      return
    end
    @upgrade_window.set_handler(:upgrade,   method(:command_upgrade))
    @upgrade_window.set_handler(:downgrade, method(:command_downgrade))
    @upgrade_window.set_handler(:cancel,    method(:cancel_upgrade))
    @item_window.y += @upgrade_window.height
    @item_window.height -= @upgrade_window.height
    @item_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● Create the status window
  #--------------------------------------------------------------------------
  def create_status_window
    y = @help_window.height
    @status_window = Window_UpgradeStatus.new(@command_window.width, y)
    @status_window.viewport = @viewport
    @status_window.actor = @actor
  end
  #--------------------------------------------------------------------------
  # ● Create the upgrade list window
  #--------------------------------------------------------------------------
  def create_item_window
    y = @status_window.y + @status_window.height
    w = Graphics.width / 2
    h = Graphics.height - y
    @item_window = Window_UpgradeList.new(0, y, w, h)
    @item_window.viewport = @viewport
    @item_window.actor = @actor
    @item_window.help_window = @help_window
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @command_window.skill_window = @item_window
  end
  #--------------------------------------------------------------------------
  # ● Create the parameter view window
  #--------------------------------------------------------------------------
  def create_param_window
    x = Graphics.width / 2
    y = @item_window.y
    h = @item_window.height
    @param_window = Window_UpgradeStats.new(x, y, x, h)
    @param_window.viewport = @viewport
    @param_window.skill_window = @item_window
    @param_window.actor = @actor
  end
  #--------------------------------------------------------------------------
  # ● Command skill
  #--------------------------------------------------------------------------
  def command_skill
    if KRX::DISABLE_DOWNGRADE
      command_upgrade
      return
    end
    @upgrade_window.activate
  end
  #--------------------------------------------------------------------------
  # ● Command upgrade
  #--------------------------------------------------------------------------
  def command_upgrade
    @item_window.activate.select_last
    @item_window.mode = :upgrade
  end
  #--------------------------------------------------------------------------
  # ● Command downgrade
  #--------------------------------------------------------------------------
  def command_downgrade
    @item_window.activate.select_last
    @item_window.mode = :downgrade
  end
  #--------------------------------------------------------------------------
  # ● Cancel upgrade/downgrade selection
  #--------------------------------------------------------------------------
  def cancel_upgrade
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # ● Validate skill selection
  #--------------------------------------------------------------------------
  def on_item_ok
    @actor.upgrade_skill(@item_window.item) if @item_window.mode == :upgrade
    @actor.downgrade_skill(@item_window.item) if @item_window.mode == :downgrade
    @item_window.refresh
    @item_window.activate
    @param_window.refresh
    @status_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● Cancel skill selection
  #--------------------------------------------------------------------------
  def on_item_cancel
    @item_window.unselect
    if KRX::DISABLE_DOWNGRADE
      cancel_upgrade
      return
    end
    @upgrade_window.activate
  end
end

## Menu inclusion, with Yanfly's Ace Menu Engine
if $imported["YEA-AceMenuEngine"]

#==========================================================================
# ■ Scene_Menu
#==========================================================================
	
class Scene_Menu < Scene_MenuBase
	#--------------------------------------------------------------------------
	# ● Switch to the upgrade scene
	#--------------------------------------------------------------------------
	def command_skill_upgrade
    SceneManager.call(Scene_Upgrade)
  end
end

end ## End of Yanfly's Menu inclusion