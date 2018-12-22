#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Variable Cover Rates
#  Author: Kread-EX
#  Version 1.01
#  Release date: 25/12/2012
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

#------------------------------------------------------------------------------
#  ▼ UPDATES
#------------------------------------------------------------------------------
# # 17/02/2013. Fixed a stupid math error.
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
# # Enables the use of variable HP rate requirements when the Cover trait is
# # applied to states.
#------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#------------------------------------------------------------------------------
# # Just enter <target hp: n%> in the notebox of the state. If the state has a
# # Cover trait, it'll use it instead of the default 25%.
#------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#------------------------------------------------------------------------------
# # List of aliases and overwrites:
# #
# # DataManager
# # load_database (alias)
# # load_vcover_notetags (new method)
# #
# # RPG::State
# # cover_hp (new attr method)
# # load_vcover_notetags (new method)
# #
# # Game_BattlerBase
# # substitute_hp_condition (new method)
# #
# # Scene_Battle
# # check_substitute (overwrite)
#------------------------------------------------------------------------------

$imported ||= {}
$imported['KRX-VariableCover'] = true if $imported != nil

puts 'Load: Variable Cover Rates v1.01 by Kread-EX'

module KRX
  module REGEXP
    COVER_HP = /<target hp:[ ]*(\d+)%>/i
  end
end

#===========================================================================
# ■ DataManager
#===========================================================================

module DataManager  
	#--------------------------------------------------------------------------
	# ● Loads the database
	#--------------------------------------------------------------------------
	class << self; alias_method(:krx_vcover_dm_ld, :load_database); end
	def self.load_database
		krx_vcover_dm_ld
		load_vcover_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_vcover_notetags
		groups = [$data_states]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_vcover_notetags
			end
		end
		puts "Read: Variable Cover Rates Notetags"
	end
end

#===========================================================================
# ■ RPG::State
#===========================================================================

class RPG::State < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ● Public instance variables
  #--------------------------------------------------------------------------
  attr_reader   :cover_hp
  #--------------------------------------------------------------------------
  # ● Loads the note tags
  #--------------------------------------------------------------------------
  def load_vcover_notetags
    @note.split(/[\r\n]+/).each do |line|
      case line
      when KRX::REGEXP::COVER_HP
        @cover_hp = $1.to_i
      end
    end
  end
end

#==============================================================================
# ■ Game_BattlerBase
#==============================================================================

class Game_BattlerBase
	#--------------------------------------------------------------------------
	# ● Returns the substitute target HP condition
	#--------------------------------------------------------------------------
  def substitute_hp_condition
    result = 4
    states.each do |state|
      state.features.each do |feature|
        if feature.code == FEATURE_SPECIAL_FLAG &&
        feature.data_id == FLAG_ID_SUBSTITUTE
          result = (state.cover_hp / 100.00) || 4
          break
        end
      end
    end
    result
  end
end

#===========================================================================
# ■ Scene_Battle
#===========================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● Check for valid subsitute
  #--------------------------------------------------------------------------
  def check_substitute(target, item)
    return false if @subject.actor? == target.actor?
    sub = target.friends_unit.substitute_battler
    return false if sub.nil? || sub == target
    hp_target = sub.substitute_hp_condition
    target.hp < target.mhp * hp_target && (!item || !item.certain?)
  end
end