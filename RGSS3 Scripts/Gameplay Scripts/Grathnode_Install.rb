#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Grathnode Install
#  Author: Kread-EX
#  Version 1.13
#  Release date: 31/12/2011
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
 
#------------------------------------------------------------------------------
#  ▼ UPDATES
#------------------------------------------------------------------------------
# # 16/01/2013. Fixed a bug with removed grathnodes not being given back.
# # 28/12/2012. Fixed another bug with savefiles.
# # 30/01/2012. Added option to disable grathnode menu for certain characters.
# # 30/01/2012. Added option to remove grathnodes when a skill is forgetted.
# # 20/01/2012. Compatibility fix.
# # 19/01/2012. Loads of compatibility fixes.
# # 14/01/2012. Fixed two crashing bugs with the DBS implementation.
# # 10/01/2012. <max_grathnodes: 0> now works.
# # 07/01/2012. Fixed a critical bug preventing the installs to be saved.
# # 05/01/2012. Fixed a crashing bug in the Install menu if no skill is
# # available.
# # 01/01/2012. Fixed compatibility with Yanfly's TP Manager (thanks Adalwulf)
# # NOW DEPRECATED. Use Yanfly's Ace Skill Menu to ensure compat. However, in
# # case you don't want to, just uncomment the code at the end of the script.
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
# # This script is inspired from the Ar Tonelico series. In a nutshell,
# # it allows the player to assign special items called Grathnode crystals to
# # skills in order to add special effects.
# # The upgrades are actor-dependant: if two actors have the same skill, they
# # can use a different set of crystals.
#------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#------------------------------------------------------------------------------
# # First, you need to create the desired grathnode crystals. They are regular
# # items, but tagged as <grathnode> in their notebox.
# # Certain grathnodes are suited only for a certain type of skill. To ensure
# # that a defensive skill doesn't use an offensive effect, you can choose
# # the kind of scope:
# # <scope: string> in the item notebox.
# # String can be different values:
# # for_opponent? 
# # for_friend? 
# # for_dead_friend? 
# # for_user? 
# # for_all? 
# #
# # Every skill can contain up to 6 crystals by default, but you can lower the
# # number either individually (by putting <max_grathnodes: x> if the skill
# # notebox, or globally by altering the ABSOLUTE_MAX_GRATHNODES value within
# # the script.
# #
# # The scene can be called with SceneManager.call(Scene_Grathnode), however
# # I strongly recommend you to use Yanfly's Ace Menu Engine, as I prepared
# # special compatibility for it.
#------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#------------------------------------------------------------------------------
# # Works with Yanfly's Battle Engine Ace. Actually, it may work better than with
# # the DBS, thanks to the nice pop-ups, very GUST-ish at the conception.
# #
# # List of aliases and overwrites:
# #
# # DataManager
# # load_database (alias)
# # load_grathnode_notetags (new method)
# #
# # RPG::Item
# # load_grathnode_notetags (new method)
# # is_grathnode? (new method)
# # grathnode_scope (new attr method)
# # mp_inflation (new attr method)
# # tp_inflation (new attr method)
# #
# # RPG::Skill
# # load_grathnode_notetags (new method)
# # grathnode_slots (new method)
# #
# # Game_Actor
# # installs (new attr method)
# # barring_grathnode (new attr method)
# # setup (alias)
# # forget_skill (alias)
# # add_grathnode (new method)
# # skill_mp_cost (new child method)
# # skill_tp_cost (new child method)
# # process_grathnode_mp_cost (new method)
# # process_grathnode_tp_cost (new method)
# #
# # Game_Party
# # last_selected_skill (new attr method)
# # menu_actor (alias)
# # menu_actor_next (alias)
# # menu_actor_prev (alias)
# #
# # Scene_Grathnode (new class)
# #
# # Window_UpSkillList (new class)
# #
# # Window_GrathnodeList (new class)
# #
# # Window_GrathnodeInstall (new class)
# #
# # Scene_Battle
# # apply_item_effects (alias)
# # apply_grathnode_effects (new method - YEA Battle Engine only)
#------------------------------------------------------------------------------

($imported ||= {})['KRX-GrathnodeInstall'] = true

puts 'Load: Grathnode Install v1.13 by Kread-EX'

module KRX
#===========================================================================
# ■ CONFIGURATION
#===========================================================================
  ABSOLUTE_MAX_GRATHNODES = 5
  CLEAR_FORGET_SKILL = true
  SINGLE_ACTOR_INSTALL = false
  SINGLE_ACTOR_INSTALL_ID = 9
  
  module VOCAB
    GRATHNODE = 'Grathnode'
  end
#===========================================================================
# ■ CONFIGURATION ENDS HERE
#===========================================================================
  module REGEXP
    MAX_GRATHNODES = /<max_grathnodes:[ ]*(\d+)>/i
    GRATHNODE_ITEM = /<grathnode>/i
    GRATHNODE_SCOPE = /<scope:[ ]*(\w+.)>/
    MP_INFLATION = /<mp_inflation:[ ]*(\d+)>/i
    TP_INFLATION = /<tp_inflation:[ ]*(\d+)>/i
  end
end
  
#===========================================================================
# ■ DataManager
#===========================================================================

module DataManager  
	#--------------------------------------------------------------------------
	# ● Loads the database
	#--------------------------------------------------------------------------
	class << self
		alias_method(:krx_grathnode_dm_load_database, :load_database)
	end
	def self.load_database
		krx_grathnode_dm_load_database
		load_grathnode_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_grathnode_notetags
		groups = [$data_items, $data_skills]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_grathnode_notetags
			end
		end
		puts "Read: Grathnode Install Notetags"
	end
end

#==========================================================================
# ■ RPG::Item
#==========================================================================

class RPG::Item < RPG::UsableItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader     :grathnode_scope
  attr_reader     :mp_inflation
  attr_reader     :tp_inflation
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_grathnode_notetags
    @mp_inflation = @tp_inflation = 0
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::GRATHNODE_ITEM
				@is_grathnode = true
			when KRX::REGEXP::GRATHNODE_SCOPE
				@grathnode_scope = $1
      when KRX::REGEXP::MP_INFLATION
        @mp_inflation = $1.to_i
      when KRX::REGEXP::TP_INFLATION
        @tp_inflation = $1.to_i
			end
		end
	end
	#--------------------------------------------------------------------------
	# ● Determine if the item is a grathnode crystal
	#--------------------------------------------------------------------------
	def grathnode?
    @is_grathnode
  end
end

#==========================================================================
# ■ RPG::Skill
#==========================================================================

class RPG::Skill < RPG::UsableItem
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_grathnode_notetags
		@max_grathnodes = nil
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::MAX_GRATHNODES
        @max_grathnodes = [$1.to_i, KRX::ABSOLUTE_MAX_GRATHNODES].min
			end
		end
  end
	#--------------------------------------------------------------------------
	# ● Returns the maximum number of grathnode slots
	#--------------------------------------------------------------------------
	def grathnode_slots
    (@max_grathnodes == nil ? KRX::ABSOLUTE_MAX_GRATHNODES : @max_grathnodes)
  end
end

#==========================================================================
# ■ Game_Actor
#==========================================================================

class Game_Actor < Game_Battler
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
	attr_accessor	:installs
  attr_accessor :barring_grathnode
	#--------------------------------------------------------------------------
	# ● Setup
	#--------------------------------------------------------------------------
	alias_method(:krx_grathnode_gp_setup, :setup)
	def setup(actor_id)
		krx_grathnode_gp_setup(actor_id)
		@installs = {}
    @barring_grathnode = false
	end
	#--------------------------------------------------------------------------
	# ● Adds a grathnode crystal to a specific skill slot
	#--------------------------------------------------------------------------
  def add_grathnode(skill, crystal, slot)
    if @installs[skill.id].nil?
      @installs[skill.id] = Array.new(skill.grathnode_slots, nil)
    elsif @installs[skill.id][slot] != nil
      item = $data_items[@installs[skill.id][slot]]
      $game_party.gain_item(item, 1)
    end
    $game_party.lose_item(crystal, 1) unless crystal.nil?
    @installs[skill.id][slot] = crystal.nil? ? nil : crystal.id
  end
  #--------------------------------------------------------------------------
  # ● Returns the MP cost for a skill
  #--------------------------------------------------------------------------
  def skill_mp_cost(skill)
    cost = super
    (cost + cost * process_grathnode_mp_cost(skill) / 100).round
  end
  #--------------------------------------------------------------------------
  # ● Returns the TP cost for a skill
  #--------------------------------------------------------------------------
  def skill_tp_cost(skill)
    cost = super
    (cost + cost * process_grathnode_tp_cost(skill) / 100).round
  end
	#--------------------------------------------------------------------------
	# ● Calculates the MP cost inflation
	#--------------------------------------------------------------------------
  def process_grathnode_mp_cost(skill)
    result = 0.0
    return result if @installs[skill.id].nil?
    @installs[skill.id].compact.each do |grathnode|
      result += $data_items[grathnode].mp_inflation
    end
    return result
  end
	#--------------------------------------------------------------------------
	# ● Calculates the TP cost inflation
	#--------------------------------------------------------------------------
  def process_grathnode_tp_cost(skill)
    result = 0.0
    return result if @installs[skill.id].nil?
    @installs[skill.id].compact.each do |grathnode|
      result += $data_items[grathnode].tp_inflation
    end
    return result
  end
  #--------------------------------------------------------------------------
  # ● Forgets a skill
  #--------------------------------------------------------------------------
  alias_method(:krx_grathnode_ga_fs, :forget_skill)
  def forget_skill(skill_id)
    krx_grathnode_ga_fs(skill_id)
    if KRX::CLEAR_FORGET_SKILL
      skill = $data_skills[skill_id]
      (0...skill.grathnode_slots).each do |i|
        add_grathnode(skill, nil, i)
      end
    end
  end
end

#==========================================================================
# ■ Game_Party
#==========================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ● Public instance variables
  #--------------------------------------------------------------------------
  attr_accessor   :last_selected_skill
  #--------------------------------------------------------------------------
  # ● Next actor
  #--------------------------------------------------------------------------
  alias_method(:krx_grathnode_gp_man, :menu_actor_next)
  def menu_actor_next
    if SceneManager.scene.is_a?(Scene_Grathnode)
      return menu_actor if KRX::SINGLE_ACTOR_INSTALL
      val = members.select {|act| !act.barring_grathnode}
      index = val.index(menu_actor) || -1
      index = (index + 1) % val.size
      self.menu_actor = val[index]
    else
      krx_grathnode_gp_man
    end
  end
  #--------------------------------------------------------------------------
  # ● Previous actor
  #--------------------------------------------------------------------------
  alias_method(:krx_grathnode_gp_map, :menu_actor_prev)
  def menu_actor_prev
    if SceneManager.scene.is_a?(Scene_Grathnode)
      return menu_actor if KRX::SINGLE_ACTOR_INSTALL
      val = members.select {|act| !act.barring_grathnode}
      index = val.index(menu_actor) || 1
      index = (index + val.size - 1) % val.size
      self.menu_actor = val[index]
    else
      krx_grathnode_gp_map
    end
  end
  #--------------------------------------------------------------------------
  # ● Get the current actor for menus
  #--------------------------------------------------------------------------
  alias_method(:krx_grathnode_gp_ma, :menu_actor)
  def menu_actor
    if SceneManager.scene.is_a?(Scene_Grathnode)
      val = members.select {|act| !act.barring_grathnode}
      return $game_actors[@menu_actor_id] || val[0]
    end
    return krx_grathnode_gp_ma
  end
end

#==========================================================================
# ■ Scene_Grathnode
#==========================================================================

class Scene_Grathnode < Scene_Skill
	#--------------------------------------------------------------------------
	# ● Object Initializate
	#--------------------------------------------------------------------------
  def initialize
    if KRX::SINGLE_ACTOR_INSTALL
      $game_party.menu_actor = $game_actors[KRX::SINGLE_ACTOR_INSTALL_ID]
    end
  end
	#--------------------------------------------------------------------------
	# ● Scene start
	#--------------------------------------------------------------------------
	def start
    super
    create_install_window
	end
	#--------------------------------------------------------------------------
	# ● Creates the window displaying the grathnodes currently installed
	#--------------------------------------------------------------------------
  def create_install_window
    wy = @status_window.y + @status_window.height
    ww = Graphics.width / 2
    wh = Graphics.height - wy
		@install_window = Window_GrathnodeInstall.new(ww, wy, ww, wh)
		@install_window.viewport = @viewport
    @install_window.set_handler(:ok,     method(:on_slot_ok))
    @install_window.set_handler(:cancel,     method(:on_slot_cancel))
    @item_window.install_window = @install_window
  end
	#--------------------------------------------------------------------------
	# ● Creates the window displaying the grathnodes currently owned
	#--------------------------------------------------------------------------
	def create_grathnodes_window
    wx = 0
    wy = @status_window.y + @status_window.height
    ww = Graphics.width / 2
    wh = Graphics.height - wy
    @grathnode_window = Window_GrathnodeList.new(wx, wy, ww, wh)
    @grathnode_window.viewport = @viewport
    @grathnode_window.help_window = @help_window
    @grathnode_window.refresh
    @grathnode_window.select(0)
    @grathnode_window.activate
    @grathnode_window.set_handler(:ok,     method(:on_grath_ok))
    @grathnode_window.set_handler(:cancel, method(:on_grath_cancel))
	end
	#--------------------------------------------------------------------------
	# ● Creates the window displaying the skills
	#--------------------------------------------------------------------------
	def create_item_window
    wx = 0
    wy = @status_window.y + @status_window.height
    ww = Graphics.width / 2
    wh = Graphics.height - wy
    @item_window = Window_UpSkillList.new(wx, wy, ww, wh)
    @item_window.actor = @actor
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @command_window.skill_window = @item_window
	end
  #--------------------------------------------------------------------------
  # ● Validates the skill selection
  #--------------------------------------------------------------------------
  def on_item_ok
    @item_window.hide
    @last_index = @item_window.index
    $game_party.last_selected_skill = @item_window.item
    create_grathnodes_window
  end
  #--------------------------------------------------------------------------
  # ● Cancels the skill selection
  #--------------------------------------------------------------------------
  def on_item_cancel
    @item_window.unselect
    @item_window.update_help
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # ● Validates the slot selection
  #--------------------------------------------------------------------------
  def on_slot_ok
    sk = @item_window.item
    gr = @grathnode_window.item
    slot = @install_window.index
    @actor.add_grathnode(sk, gr, slot)
    @item_window.refresh
    @install_window.unselect
    @install_window.set_item(@item_window.item)
    @grathnode_window.refresh
    @grathnode_window.activate
  end
  #--------------------------------------------------------------------------
  # ● Cancels the slot selection
  #--------------------------------------------------------------------------
  def on_slot_cancel
    @install_window.unselect
    @grathnode_window.activate
  end
  #--------------------------------------------------------------------------
  # ● Validates the grathnode selection
  #--------------------------------------------------------------------------
  def on_grath_ok
    @install_window.activate
    @install_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ● Cancels the grathnode selection
  #--------------------------------------------------------------------------
  def on_grath_cancel
    @item_window.select(@last_index)
    @item_window.show
    @item_window.activate
    @grathnode_window.dispose ; @grathnode_window = nil
  end
  #--------------------------------------------------------------------------
  # ● Confirms the actor switch
  #--------------------------------------------------------------------------
  def on_actor_change
    super
    @install_window.actor = @actor
  end
end

#==========================================================================
# ■ Window_UpSkillList
#==========================================================================
	
class Window_UpSkillList < Window_SkillList
	#--------------------------------------------------------------------------
	# ● Assigns the install window
	#--------------------------------------------------------------------------
	def install_window=(value)
		@install_window = value
	end
	#--------------------------------------------------------------------------
	# ● Determine if the skill can be selected
	#--------------------------------------------------------------------------
	def enable?(item)
		return item != nil && item.grathnode_slots > 0
	end
	#--------------------------------------------------------------------------
	# ● Refreshes the help and install windows
	#--------------------------------------------------------------------------
	def update_help
		super
		@install_window.set_item(item)
	end
	#--------------------------------------------------------------------------
	# ● Returns the number of columns
	#--------------------------------------------------------------------------
	def col_max
		return 1
	end
end

#==========================================================================
# ■ Window_GrathnodeInstall
#==========================================================================
	
class Window_GrathnodeInstall < Window_Selectable
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_accessor   :actor
	#--------------------------------------------------------------------------
	# ● Object Initialize
	#--------------------------------------------------------------------------
	def initialize(x, y, width, height)
		super
		set_item
    @actor = $game_party.menu_actor
	end
	#--------------------------------------------------------------------------
	# ● Refresh the contents
	#--------------------------------------------------------------------------
	def set_item(item = nil)
		contents.clear
		return if item.nil?
    @data = Array.new(item.grathnode_slots, nil)
    @installs = @actor.installs[item.id]
		draw_item_installs(item)
	end
	#--------------------------------------------------------------------------
	# ● Displays the skill's current installs
	#--------------------------------------------------------------------------
	def draw_item_installs(item)
    draw_horz_line(line_height * 6)
		change_color(system_color)
		contents.draw_text(4, 0, width, line_height, KRX::VOCAB::GRATHNODE)
		change_color(normal_color)
    m = item.grathnode_slots
		(1..m).each {|i| contents.draw_text(4, line_height * i, width, line_height, "#{i}.")}
    return if @installs.nil? || @installs.empty?
		@installs.each_index do |i|
			grath = @installs[i].nil? ? nil : $data_items[@installs[i]]
			draw_item_name(grath, 28, line_height * (i + 1), true, width - 24)
    end
    draw_mp(item) if @actor.process_grathnode_mp_cost(item).round > 0
    draw_tp(item) if @actor.process_grathnode_tp_cost(item).round > 0
  end
	#--------------------------------------------------------------------------
	# ● Displays the skill's MP inflation rate
	#--------------------------------------------------------------------------
  def draw_mp(item)
    change_color(system_color)
    contents.draw_text(4, line_height * 7, width, line_height, Vocab.basic(5))
    change_color(normal_color)
    contents.draw_text(28, line_height * 7, width, line_height,
    "+#{@actor.process_grathnode_mp_cost(item).round.to_s}%")
  end
	#--------------------------------------------------------------------------
	# ● Displays the skill's TP inflation rate
	#--------------------------------------------------------------------------
  def draw_tp(item)
    change_color(system_color)
    w = width / 4
    contents.draw_text(w, line_height * 7, width, line_height, Vocab.basic(7))
    change_color(normal_color)
    contents.draw_text(w + 28, line_height * 7, width, line_height,
    "+#{@actor.process_grathnode_tp_cost(item).round.to_s}%")
	end
	#--------------------------------------------------------------------------
	# ● Returns the number of columns
	#--------------------------------------------------------------------------
	def col_max
		return 1
	end
  #--------------------------------------------------------------------------
  # ● Returns the max number of rows
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #--------------------------------------------------------------------------
  # ● Sets the rectangle for selections
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = index % col_max * (item_width + spacing)
    rect.y = (index / col_max * item_height) + line_height
    rect
  end
	#--------------------------------------------------------------------------
	# ● Displays an horizontal line
	#--------------------------------------------------------------------------
	def draw_horz_line(y)
		line_y = y + line_height / 2 - 1
		contents.fill_rect(0, line_y, contents_width, 2, line_color)
	end
	#--------------------------------------------------------------------------
	# ● Returns the color used for horizontal lines
	#--------------------------------------------------------------------------
	def line_color
		color = normal_color
		color.alpha = 48
		return color
	end
end

#==========================================================================
# ■ Window_GrathnodeList
#==========================================================================
	
class Window_GrathnodeList < Window_ItemList
	#--------------------------------------------------------------------------
	# ● Determine if an item goes in the list
	#--------------------------------------------------------------------------
	def include?(item)
    item.is_a?(RPG::Item) && item.grathnode?
	end
	#--------------------------------------------------------------------------
	# ● Determine if the grathnode can be used
	#--------------------------------------------------------------------------
	def enable?(item)
    return true if item.nil?
    actor = $game_party.menu_actor
    skill = $game_party.last_selected_skill
    if !actor.installs[skill.id].nil? && actor.installs[skill.id].include?(item.id)
      return false
    end
    if !item.grathnode_scope.nil? && !skill.send(item.grathnode_scope)
      return false
    end
    return true
	end
	#--------------------------------------------------------------------------
	# ● Creates the list based on the recipes
	#--------------------------------------------------------------------------
	def make_item_list
		@data = $game_party.items.select {|item| include?(item)}
    @data.push(nil)
	end
	#--------------------------------------------------------------------------
	# ● Returns the number of columns
	#--------------------------------------------------------------------------
	def col_max
		return 1
	end
end

#==========================================================================
# ■ Scene_Battle
#==========================================================================

class Scene_Battle < Scene_Base
  
  ## Yanfly's Ace Battle Engine implementation
  if $imported["YEA-BattleEngine"]
  #--------------------------------------------------------------------------
  # ● Applies the effects of the skill or item
  #--------------------------------------------------------------------------
  alias_method(:krx_grathnode_sb_aie, :apply_item_effects)
  def apply_item_effects(target, item)
    apply_grathnode_effects(target, item)
    krx_grathnode_sb_aie(target, item)
  end
  #--------------------------------------------------------------------------
  # ● Applies the effects of grathnodes associated to the skill
  #--------------------------------------------------------------------------
  def apply_grathnode_effects(target, item)
    unless @subject.is_a?(Game_Actor)&& @subject.installs.keys.include?(item.id) &&
    @subject.installs[item.id] != nil
      return
    end
    @subject.installs[item.id].compact.each do |grath| 
      target.item_apply(@subject, $data_items[grath])
    end
  end
  ## End of Yanfly's Ace Battle Engine implementation
  ## DBS implementation
  else
  #--------------------------------------------------------------------------
  # ● Applies the effects of the skill or item
  #--------------------------------------------------------------------------
  alias_method(:krx_grathnode_sb_aie, :apply_item_effects)
  def apply_item_effects(target, item)
    krx_grathnode_sb_aie(target, item)
    apply_grathnode_effects(target, item)
  end
  #--------------------------------------------------------------------------
  # ● Applies the effects of grathnodes associated to the skill
  #--------------------------------------------------------------------------
  def apply_grathnode_effects(target, item)
    unless @subject.is_a?(Game_Actor)&& @subject.installs.keys.include?(item.id) &&
    @subject.installs[item.id] != nil || target.dead?
      return
    end
    return unless @subject.is_a?(Game_Actor)
    return if @subject.installs.nil? || @subject.installs[item.id].nil?
    @subject.installs[item.id].compact.each do |grath| 
      target.item_apply(@subject, $data_items[grath])
      @log_window.display_action_results(target, $data_items[grath])
    end
  end # Method End
  end ## End of DBS implementation
end

## Menu inclusion, with Yanfly's Ace Menu Engine
if $imported["YEA-AceMenuEngine"]

#==========================================================================
# ■ Scene_Menu
#==========================================================================
	
class Scene_Menu < Scene_MenuBase
	#--------------------------------------------------------------------------
	# ● Switch to the actor selection
	#--------------------------------------------------------------------------
	def command_install
    if KRX::SINGLE_ACTOR_INSTALL
      SceneManager.call(Scene_Grathnode)
      return
    end
    @status_window.select_last
    @status_window.activate
    @status_window.set_handler(:ok,     method(:on_install_ok))
    @status_window.set_handler(:cancel, method(:on_personal_cancel))
  end
	#--------------------------------------------------------------------------
	# ● Validates the actor selection
	#--------------------------------------------------------------------------
	def on_install_ok
    SceneManager.call(Scene_Grathnode)
  end
end

#==========================================================================
# ■ Window_MenuStatus
#==========================================================================
	
class Window_MenuStatus < Window_Selectable
	#--------------------------------------------------------------------------
	# ● Determine if a party member can be selected
	#--------------------------------------------------------------------------
  alias_method(:krx_grathnode_wms_cie?, :current_item_enabled?)
  def current_item_enabled?
    if @handler[:ok].name == :on_install_ok
      return !$game_party.members[index].barring_grathnode
    end
    return krx_grathnode_wms_cie?
  end
end

end ## End of Yanfly's Menu inclusion

## Compatibility with Yanfly's TP Manager. Deprecated with the use of Ace Skill
## Menu
=begin
if $imported["YEA-TPManager"]

#==============================================================================
# ■ Window_SkillCommand
#==============================================================================

class Window_SkillCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● Aliases YF's new method
  #--------------------------------------------------------------------------
  alias_method(:krx_grathnode_wsc_tp, :add_tp_modes)
  def add_tp_modes
    return if SceneManager.scene.is_a?(Scene_Grathnode)
    krx_grathnode_wsc_tp
  end
end

#==========================================================================
#  ■  Scene_Grathnode
#==========================================================================

class Scene_Grathnode < Scene_Skill
	#--------------------------------------------------------------------------
	# ● Creates the command window
	#--------------------------------------------------------------------------
  def create_command_window
    wy = @help_window.height
    @command_window = Window_SkillCommand.new(0, wy)
    @command_window.viewport = @viewport
    @command_window.help_window = @help_window
    @command_window.actor = @actor
    @command_window.set_handler(:skill,    method(:command_skill))
    @command_window.set_handler(:cancel,   method(:return_scene))
    @command_window.set_handler(:pagedown, method(:next_actor))
    @command_window.set_handler(:pageup,   method(:prev_actor))
  end  
end


end ## End of TP Manager compatibility
=end