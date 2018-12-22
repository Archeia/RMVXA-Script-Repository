#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Banish Skills
#  Author: Kread-EX
#  Version 1.0
#  Release date: 23/11/2012
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
 
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
# # Allows the creation of anti-magic skills, meant to interrupt and counter
# # regardless of who is targeted. Inspired by Eien no Aselia, a game I
# # recommend you to play for a good Visual Novel/Strategy hybrid.
#------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#------------------------------------------------------------------------------
# # There are 4 configuration stages.
# #
# # 1. Create the "Banishment state". It is a state you will mark with the
# # following notetags.
# # <banisher> # Indicate the state as a banish state
# # <banish_type: n> # Will only interrupt skills of type n (n being the
# # number of the type you can assign in the database)
# # <banish_level: n> # Will only interrupt skill of level equal or less to
# # n (see next section)
# # <banish_skill: n> # The ID of the counter skill.
# #
# # 2. Create two skills: one for the interception and one for counter.
# # The interception skill will be learnt and used by the player. It must
# # add the banish state previously created to the user and that's it.
# # The counter skill can be really whatever you want.
# #
# # 3. If you want your banish skill to be unable to block spells of a certain
# # power, you'll have to tag them:
# # <banish_level: n>
# # You'll be only able to interrupt them if the level of the banish skill
# # is superior or equal to this skill's level.
# #
# # 4. Personalize the banish message in the config module below.
#------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#------------------------------------------------------------------------------
# # Works with the DBS and Ace Battle Engine. 
# # List of aliases and overwrites:
# #
# # DataManager
# # load_database (alias)
# # load_banish_notetags (new method)
# #
# # RPG::Skill
# # banish_lv (new attr method)
# # load_banish_notatags (new method)
# #
# # RPG::State
# # banisher (new attr method)
# # banish_skill (new attr method)
# # banish_lv (new attr method)
# # banish_type (new attr method)
# # load_banish_notetags (new method)
# #
# # Game_Battler
# # can_banish? (new method)
# # remove_banish_state (new method)
# #
# # Window_Battlelog
# # display_banish (new method)
# #
# # Scene_Battle
# # use_item (alias)
# # banish_ok? (new method)
# # use_banish_skill (new method)
#------------------------------------------------------------------------------

$imported['KRX-BanishSkills'] = true if $imported != nil

puts 'Load: Banish Skills v1.0 by Kread-EX'

module KRX
#===========================================================================
# ■ CONFIGURATION
#===========================================================================
  module VOCAB
    # First %s will be replaced by the original skill's name.
    # Second %s will be replaced by the actor who is banishing.
    BANISH_MESSAGE = "%s has been interrupted by %s!"
  end
#===========================================================================
# ■ CONFIGURATION ENDS HERE
#===========================================================================
  module REGEXP
    BANISH_STATE = /<banisher>/i
    BANISH_TYPE = /<banish_type:[ ]*(\d+)>/i
    BANISH_LV = /<banish_level:[ ]*(\d+)>/i
    BANISH_SKILL = /<banish_skill:[ ]*(\d+)>/i
  end
  
end

#===========================================================================
# ■ DataManager
#===========================================================================

module DataManager  
	#--------------------------------------------------------------------------
	# ● Loads the database
	#--------------------------------------------------------------------------
	class << self; alias_method(:krx_banish_dm_ld, :load_database); end
	def self.load_database
		krx_banish_dm_ld
		load_banish_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_banish_notetags
		groups = [$data_skills, $data_states]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_banish_notetags
			end
		end
		puts "Read: Banish Skills Notetags"
	end
end

#===========================================================================
# ■ RPG::Skill
#===========================================================================

class RPG::Skill < RPG::UsableItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader     :banish_lv
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_banish_notetags
		@note.split(/[\r\n]+/).each do |line|
			case line
      when KRX::REGEXP::BANISH_LV
        @banish_lv = $1.to_i
			end
		end
	end
end

#===========================================================================
# ■ RPG::State
#===========================================================================

class RPG::State < RPG::BaseItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader     :banisher
  attr_reader     :banish_type
  attr_reader     :banish_lv
  attr_reader     :banish_skill
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_banish_notetags
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::BANISH_STATE
        @banisher = true
      when KRX::REGEXP::BANISH_TYPE
        @banish_type = $1.to_i
      when KRX::REGEXP::BANISH_LV
        @banish_lv = $1.to_i
      when KRX::REGEXP::BANISH_SKILL
        @banish_skill = $1.to_i
			end
		end
	end
end

#===========================================================================
# ■ Game_Battler
#===========================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● Determine if the battler has a banish skill active
  #--------------------------------------------------------------------------
  def can_banish?
    states.each do |st|
      if st.banisher
        return [st.banish_type, st.banish_lv, st.banish_skill]
      end
    end
    false
  end
  #--------------------------------------------------------------------------
  # ● Erases the banish state
  #--------------------------------------------------------------------------
  def remove_banish_state
    states.each {|st| remove_state(st.id) if st.banisher}
  end
end

#==============================================================================
# ■ Window_BattleLog
#==============================================================================

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # ● Displays the banishment message
  #--------------------------------------------------------------------------
  def display_banish(item, banisher)
    add_text(sprintf(KRX::VOCAB::BANISH_MESSAGE, item.name, banisher.name))
    wait
  end
end

#===========================================================================
# ■ Scene_Battle
#===========================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● Use the skill/item
  #--------------------------------------------------------------------------
  alias_method(:krx_banish_sb_ui, :use_item)
  def use_item
    return if banish_ok?
    krx_banish_sb_ui
  end
  #--------------------------------------------------------------------------
  # ● Determine if a banishment will happen
  #--------------------------------------------------------------------------
  def banish_ok?
    banish_data = type = lv = sk = nil
    item = @subject.current_action.item
    all_battle_members.each do |tar|
      next if tar.is_a?(Game_Actor) && @subject.is_a?(Game_Actor)
      next if tar.is_a?(Game_Enemy) && @subject.is_a?(Game_Enemy)
      if tar.can_banish? != false && item.is_a?(RPG::Skill)
        banish_data = tar.can_banish?
        type, lv, sk = banish_data[0], banish_data[1], banish_data[2]
        if type.nil? || type == item.stype_id
          if lv.nil? || lv > (item.banish_lv || 0)
            use_banish_skill(tar, item, sk)
            return true
          end
        end
      end
    end
    false
  end
  #--------------------------------------------------------------------------
  # ● Use a Banish skill
  #--------------------------------------------------------------------------
  def use_banish_skill(target, orig_item, skill_id)
    @log_window.display_use_item(@subject, orig_item)
    @subject.use_item(orig_item)
    @log_window.display_banish(orig_item, target)
    item = $data_skills[skill_id]
    @log_window.display_use_item(target, item)
    target.use_item(item)
    target.remove_banish_state
    refresh_status
    show_animation([@subject], item.animation_id)
    item.repeats.times do
      @subject.item_apply(target, item)
      refresh_status
      @log_window.display_action_results(@subject, item)
    end
  end
end