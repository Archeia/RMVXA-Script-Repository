#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Morphing
#  Author: Kread-EX
#  Version 1.0
#  Release date: 21/01/2012
#
#  Big thanks to Seiryuki.
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
 
#-------------------------------------------------------------------------------------------------
#  ▼ TERMS OF USAGE
#-------------------------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work for commercial purposes if you like it.
# #  Credit is appreciated.
# #
# # For support:
# # grimoirecastle.wordpress.com
# # OR
# # rpgmakervxace.net
# # OR
# # rpgrevolution.com
#-------------------------------------------------------------------------------------------------
#  ▼ INTRODUCTION
#-------------------------------------------------------------------------------------------------
# # Allows you to use a skill to "scan" an enemy, effectively analyzing its form,
# # and then morphing into the same enemy. Though the actor parameters don't
# # change, all of the enemy's skills are available.
#-------------------------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#-------------------------------------------------------------------------------------------------
# # There is three steps: skill tagging, state tagging and enemy tagging.
# # 
# #
# # Skill 1: "Enemy Scan". This skill should target an enemy and needs to be
# # tagged with <morph_learn>. If the skill successfully hits the target, its
# # form will be added to the list.
# # In the config module of the script, turning UPDATE_MORPH_ON_DEATH to true
# # will only add the form if the skill KILLS the target.
# #
# # Skill 2: "Morph". This skill will apply a special state on the user (or
# # another target) which is used for detection purposes. It also opens a window
# # where you can select a list of transformations. This skill is tagged
# # <morph_use>
# # In the script config section, set MORPH_ICON_INDEX to whatever icon you want
# # to be displayed for the forms list.
# #
# # Skill 3: "Revert". This skill will remove the special state, hence cancelling
# # the transformation. You don't need to make any actor learn it, it's
# # automatically added to the action lists. It needs to target the user.
# # Don't forget to set the Revert skill ID in the config part of the script, at
# # REVERT_SKILL_ID
# #
# # The Morph state. A special state you need to tag as <morph>
# # It can have a duration or restrictions or whatever you want. Since enemies
# # use the same skill type differentiation as actors, it is recommended to add
# # the skill types that the monsters will most likely use.
# #
# # Enemy tagging: by default, all monsters can be transformed into. If you don't
# # want a certain one to be available, put this in its notebox:
# # <no_morphing>
# # Additional and optional enemy options:
# # <morph_facename: string> The new faceset filename
# # <morph_faceindex: x> The new faceset index
#-------------------------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#-------------------------------------------------------------------------------------------------
# # Works with the base Ace Battle Engine, but not tested with every add-on.
# # Feel free to report incompatiblities as they will fixed if possible.
# #
# # List of aliases and overwrites:
# #
# # DataManager
# # load_database (alias)
# # load_morph_notetags (new method)
# #
# # RPG::Skill
# # load_morph_notetags (new method)
# # morphing_style (new attr method)
# # load_morph_notetags (new method)
# #
# # RPG::Enemy
# # load_morph_notetags (new method)
# # morph_facename (new attr method)
# # morph_faceindex (new attr method)
# # morph_list_ok? (new method)
# #
# # RPG::State
# # load_morph_notetags (new method)
# # morph (new attr method)
# #
# # Game_BattlerBase (YEA only)
# # make_miss_popups (alias)
# #
# # Game_Battler
# # item_apply (alias)
# #
# # Game_Actor
# # setup (alias)
# # face_name (overwrite)
# # face_index (overwrite)
# # morph_list (new attr method)
# # morph_id (new attr method)
# # morph_facename (new attr method)
# # morph_faceindex (new attr method)
# #
# # Window_BattleSkill
# # make_item_list (alias)
# # make_morph_list (new method)
# #
# # Window_MorphList (new class)
# #
# # Scene_Battle
# # apply_item_effects (alias)
# # on_actor_cancel (alias)
# # on_skill_ok (alias)
# # on_morph_ok (new method)
# # on_morph_cancel (new method)
# # create_morph_window (new method)
# # apply_morphing (new method)

$imported = {} if $imported.nil?
$imported['KRX-Morphing'] = true

puts 'Load: Morphing v1.0 by Kread-EX'

module KRX
  
  REVERT_SKILL_ID = 130
  
  UPDATE_MORPH_ON_DEATH = false
  MORPH_ICON_INDEX = 9
  
	module REGEXP
		ENEMY_MORPH = /<no_morphing>/i
    SKILL_MORPH_SCAN = /<morph_learn>/i
    SKILL_MORPH_USE = /<morph_use>/i
    STATE_MORPH = /<morph>/i
    MORPH_FACENAME = /<morph_facename:[ ]*(\w+.)>/
    MORPH_FACEINDEX = /<morph_faceindex:[ ]*(\d+)>/i
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
		alias_method(:krx_morph_dm_load_database, :load_database)
	end
	def self.load_database
		krx_morph_dm_load_database
		load_morph_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_morph_notetags
		groups = [$data_skills, $data_enemies, $data_states]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_morph_notetags
			end
		end
		puts "Read: Morphing Notetags"
	end
end

#===========================================================================
# ■ RPG::Skill
#===========================================================================

class RPG::Skill < RPG::UsableItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
	attr_reader		  :morphing_style
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_morph_notetags
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::SKILL_MORPH_SCAN
        @morphing_style = :scan
      when KRX::REGEXP::SKILL_MORPH_USE
        @morphing_style = :trans
      end
		end
	end
end

#===========================================================================
# ■ RPG::Enemy
#===========================================================================

class RPG::Enemy < RPG::BaseItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader   :morph_facename
  attr_reader   :morph_faceindex
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_morph_notetags
    @morph_list_ok = true
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::ENEMY_MORPH
        @morph_list_ok = false
      when KRX::REGEXP::MORPH_FACENAME
        @morph_facename = $1
      when KRX::REGEXP::MORPH_FACEINDEX
        @morph_faceindex = $1.to_i
      end
		end
	end
	#--------------------------------------------------------------------------
	# ● Determine if the enemy can be added to the morph list
	#--------------------------------------------------------------------------
	def morph_list_ok?
    @morph_list_ok
  end
end

#===========================================================================
# ■ RPG::State
#===========================================================================

class RPG::State < RPG::BaseItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader   :morph
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_morph_notetags
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::STATE_MORPH
        @morph = true
      end
		end
	end
end

## YEA Battle Engine Only
if $imported['YEA-BattleEngine']
#===========================================================================
# ■ Game_BattlerBase
#===========================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # new method: make_miss_popups
  #--------------------------------------------------------------------------
  alias_method(:krx_morph_gbb_mmp, :make_miss_popups)
  def make_miss_popups(user, item)
    return if dead?
    if self.is_a?(Game_Enemy) && item.is_a?(RPG::Skill) &&
    item.morphing_style != nil
      @result.success = true unless @result.missed
    end    
    krx_morph_gbb_mmp(user, item)
  end
end
## YEA Battle Engine Only
end ## END of YEA implementation

#===========================================================================
# ■ Game_Battler
#===========================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● Applies an item's effects
  #--------------------------------------------------------------------------
  alias_method(:krx_morph_gb_ia, :item_apply)
  def item_apply(user, item)
    krx_morph_gb_ia(user, item)
    if self.is_a?(Game_Enemy) && item.is_a?(RPG::Skill) &&
    item.morphing_style != nil
      @result.success = true unless @result.missed
    end
  end
end

#===========================================================================
# ■ Game_Actor
#===========================================================================

class Game_Actor < Game_Battler
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader   :morph_list
  attr_accessor :morph_id
  attr_accessor :morph_facename
  attr_accessor :morph_faceindex
	#--------------------------------------------------------------------------
	# ● Object Initialize
	#--------------------------------------------------------------------------
  alias_method(:krx_morph_ga_setup, :setup)
  def setup(actor_id)
    @morph_list = []
    @morph_id = 0
    krx_morph_ga_setup(actor_id)
  end
	#--------------------------------------------------------------------------
	# ● Returns the face graphic filename
	#--------------------------------------------------------------------------
  def face_name
    if SceneManager.scene.is_a?(Scene_Battle) && @morph_facename != nil
      states.each do |st|
        if st.morph
          return @morph_facename
        end
      end
    end
    @face_name
  end
	#--------------------------------------------------------------------------
	# ● Returns the face graphic index
	#--------------------------------------------------------------------------
  def face_index
    if SceneManager.scene.is_a?(Scene_Battle) && @morph_faceindex != nil
      states.each do |st|
        if st.morph
          return @morph_faceindex
        end
      end
    end
    @face_index
  end
end

#==============================================================================
# ■ Window_BattleSkill
#==============================================================================

class Window_BattleSkill < Window_SkillList
  #--------------------------------------------------------------------------
  # ● Creates the list
  #--------------------------------------------------------------------------
  alias_method(:krx_morph_wbs_mil, :make_item_list)
  def make_item_list
    if @actor != nil
      @actor.states.each do |st|
        if st.morph
          make_morph_list
          return
        end
      end
    end
    krx_morph_wbs_mil
  end
  #--------------------------------------------------------------------------
  # ● Creates the list for a morphed actor
  #--------------------------------------------------------------------------
  def make_morph_list
    @data = []
    enn = $data_enemies[@actor.morph_id]
    enn.actions.each do |action|
      if include?($data_skills[action.skill_id])
        @data.push($data_skills[action.skill_id])
      end
    end
    revert = $data_skills[KRX::REVERT_SKILL_ID]
    @data.push(revert) if include?(revert)
  end
end
  
#==============================================================================
# ■ Window_MorphList
#==============================================================================

class Window_MorphList < Window_BattleSkill
  #--------------------------------------------------------------------------
  # ● Determine if an item is included in the list
  #--------------------------------------------------------------------------
  def include?(item)
    item
  end
  #--------------------------------------------------------------------------
  # ● Selects the last item
  #--------------------------------------------------------------------------
  def select_last
    @data.last
  end
  #--------------------------------------------------------------------------
  # ● Determine if the morphing is available
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(item)
  end
  #--------------------------------------------------------------------------
  # ● Determine if a specific morph is available
  #--------------------------------------------------------------------------
  def enable?(item)
    @actor
  end
  #--------------------------------------------------------------------------
  # ● Creates the list
  #--------------------------------------------------------------------------
  def make_item_list
    @data = @actor ? @actor.morph_list : []
  end
  #--------------------------------------------------------------------------
  # ● Displays the indexed item
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      sk = RPG::Skill.new
      sk.icon_index = KRX::MORPH_ICON_INDEX
      sk.name = $data_enemies[item].name
      draw_item_name(sk, rect.x, rect.y, enable?(sk))
    end
  end
  #--------------------------------------------------------------------------
  # ● Dummy method
  #--------------------------------------------------------------------------
  def update_help ; end
end

#==========================================================================
#  ■  Scene_Battle
#==========================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● Cancels the actor selection
  #--------------------------------------------------------------------------
  alias_method(:krx_morph_sb_oac, :on_actor_cancel)
  def on_actor_cancel
    @morphing_id = nil
    krx_morph_sb_oac
  end
  #--------------------------------------------------------------------------
  # ● Validates the skill selection
  #--------------------------------------------------------------------------
  alias_method(:krx_morph_sb_osok, :on_skill_ok)
  def on_skill_ok
    if @skill_window.item.morphing_style == :trans && @morphing_id.nil?
      BattleManager.actor.last_skill.object = @skill_window.item
      @skill_window.hide
      create_morph_window
      return
    end
    krx_morph_sb_osok
  end
  #--------------------------------------------------------------------------
  # ● Creates the window displaying the morphing possibilities
  #--------------------------------------------------------------------------
  def create_morph_window
    @morphlist_window = Window_MorphList.new(@help_window, @info_viewport)
    @morphlist_window.set_handler(:ok,     method(:on_morph_ok))
    @morphlist_window.set_handler(:cancel, method(:on_morph_cancel))
    @morphlist_window.actor = BattleManager.actor
    # Ace Battle Engine implementation.
    if $imported['YEA-BattleEngine']
      @morphlist_window.height = @skill_window.height
      @morphlist_window.width = @skill_window.width
      @morphlist_window.y = Graphics.height - @morphlist_window.height
      @morphlist_window.refresh
    end
    # End of Ace Battle Engine implementation.
    @morphlist_window.show
    @morphlist_window.select(0)
    @morphlist_window.activate
  end
	#--------------------------------------------------------------------------
	# ● Validates morphing selection
	#--------------------------------------------------------------------------
  def on_morph_ok
    @morphing_id = @morphlist_window.item
    @morphlist_window.dispose
    @morphlist_window = nil
    on_skill_ok
  end
	#--------------------------------------------------------------------------
	# ● Cancels morphing selection
	#--------------------------------------------------------------------------
  def on_morph_cancel
    @morphlist_window.dispose
    @morphlist_window = nil
    @skill_window.show
    @skill_window.activate
  end
	#--------------------------------------------------------------------------
	# ● Applies the action effects
	#--------------------------------------------------------------------------
	alias_method(:krx_morph_sb_aie, :apply_item_effects)
	def apply_item_effects(target, item)
		krx_morph_sb_aie(target, item)
    apply_morphing(target, item)
  end
	#--------------------------------------------------------------------------
	# ● Applies the morphing skill effects
	#--------------------------------------------------------------------------
  def apply_morphing(target, item)
    return unless @subject.is_a?(Game_Actor) && !target.result.missed
    # Scanning
		if item.is_a?(RPG::Skill) && item.morphing_style == :scan
      if target.enemy.morph_list_ok?
        if !KRX::UPDATE_MORPH_ON_DEATH || target.dead?
          @subject.morph_list.push(target.enemy.id)
        end
      end
      @subject.morph_list.uniq!
    # Morphing
    elsif item.is_a?(RPG::Skill) && item.morphing_style == :trans
      enn = $data_enemies[@morphing_id]
      @subject.morph_id = @morphing_id
      @subject.morph_facename = enn.morph_facename
      @subject.morph_faceindex = enn.morph_faceindex
      @morphing_id = nil
    end
	end
end