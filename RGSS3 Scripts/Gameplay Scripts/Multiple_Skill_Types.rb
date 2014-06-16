#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Multiple Skill Types
#  Author: Kread-EX
#  Version 1.0
#  Release date: 16/01/2012
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
# # Allows skills to have more than one different type. They can appear under
# # different battle commands and if one command is sealed, the skill is unusable
# # even if the other command is available.
#-------------------------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#-------------------------------------------------------------------------------------------------
# # Just add <new_skilltypes: x> in the skill's notebox, whilst x is the type ID.
# # You can add more than one type ID, separated by commas.
#-------------------------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#-------------------------------------------------------------------------------------------------
# # List of aliases and overwrites:
# #
# # DataManager
# # load_database (alias)
# # load_nst_notetags (new method)
# #
# # RPG::Skill
# # load_nst_notetags (new method)
# # new_stypes (new attr method)
# #
# # Game_BattlerBase
# # skill_conditions_met? (alias)
# #
# # Window_SkillList
# # include? (overwrite)
#-------------------------------------------------------------------------------------------------


$imported = {} if $imported.nil?
$imported['KRX-MultipleSkillTypes'] = true

puts 'Load: Multiple Skill Types v1.00 by Kread-EX'

module KRX
  
  module REGEXP
    SKILL_TYPES = /<new_skilltypes:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
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
		alias_method(:krx_nst_dm_load_database, :load_database)
	end
	def self.load_database
		krx_nst_dm_load_database
		load_nst_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_nst_notetags
		groups = [$data_skills]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_nst_notetags
			end
		end
		puts "Read: Multiple Skill Types Notetags"
	end
end

#==========================================================================
# ■ RPG::Skill
#==========================================================================

class RPG::Skill < RPG::UsableItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader   :new_stypes
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_nst_notetags
    @new_stypes = []
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::SKILL_TYPES
        $1.scan(/\d+/).each {|i| @new_stypes.push(i.to_i)}
			end
		end
  end
end

#==========================================================================
# ■ Game_BattlerBase
#==========================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● Determine if a skill can be used
  #--------------------------------------------------------------------------
  alias_method(:krx_nst_bgg_scm?, :skill_conditions_met?)
  def skill_conditions_met?(skill)
    skill.new_stypes.each do |sid|
      return true if skill_type_sealed?(sid)
    end
    krx_nst_bgg_scm?(skill)
  end
end

#==========================================================================
# ■ Window_SkillList
#==========================================================================

class Window_SkillList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● Determine if a skill goes in the list
  #--------------------------------------------------------------------------
  def include?(item)
    return false unless item
    return true if item.stype_id == @stype_id
    item.new_stypes.each do |sid|
      return true if sid == @stype_id
    end
    return false
  end
end