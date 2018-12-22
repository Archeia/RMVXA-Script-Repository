#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Skill Fusion
#  Author: Kread-EX
#  Version 1.04
#  Release date: 10/12/2011
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
 
#-------------------------------------------------------------------------------------------------
#  ▼ UPDATES
#-------------------------------------------------------------------------------------------------
# # 29/01/2012. Fixec ompatibility with the latest YEA Battle Engine.
# # 02/01/2012. Fixed compatibility with Lunatic Objects and Cast Animations.
# # 13/12/2011. Added permanent detection to ensure compat. with Glimmer.
# # 12/12/2011. Fixed a bug preventing to use a skill for multiple fusions
# # (thanks to infamous bon bon)
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
# # This script allows a character to use the remnants of a skill to transform her
# # skill into another one.
#-------------------------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#-------------------------------------------------------------------------------------------------
# # Use the skill notebox with this tag:
# # <skill_fusion: x, y>
# # x = ID of the skill which remnants are used.
# # y = ID of the skill to transform into.
#-------------------------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
# # Works with the DBS and Ace Battle Engine. Make sure to put this script ABE!
# # List of aliases and overwrites:
# #
# # DataManager
# # load_database (alias)
# # load_skillfusion_notetags (new method)
# #
# # RPG::Skill
# # loadskillfusion_notetags (new method)
# #
# # Scene_Battle
# # use_item (alias)
# # fusion_check (new method)
#-------------------------------------------------------------------------------------------------

$imported = {} if $imported.nil?
$imported['KRX-SkillFusion'] = true

puts 'Load: Skill Fusion v1.04 by Kread-EX'

module KRX

	FUSION_PARTY_CHECK = true

	module REGEXP
		SKILL_FUSION =  /<skill_fusion:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
	end

	module VOCAB
		FUSION_TEXT = "Skill Fusion active!"
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
		alias_method(:krx_skillfusion_dm_load_database, :load_database) unless $@
	end
	def self.load_database
		krx_skillfusion_dm_load_database
		load_skillfusion_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_skillfusion_notetags
		groups = [$data_skills]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_skillfusion_notetags
			end
		end
		puts "Read: Skill Fusion Notetags"
	end
end

#===========================================================================
# ■ RPG::Skill
#===========================================================================

class RPG::Skill < RPG::UsableItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
	attr_reader		:fusions
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_skillfusion_notetags
		@fusions = []
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::SKILL_FUSION
				$1.scan(/\d+/).each {|i| @fusions.push(i.to_i)}
			end
		end
	end
end

#===========================================================================
# ■ Scene_Battle
#===========================================================================

class Scene_Battle < Scene_Base
	#--------------------------------------------------------------------------
	# ● Uses a skill or item
	#--------------------------------------------------------------------------
  alias_method(:krx_skillfusion_sb_ui, :use_item)
	def use_item
		fusion_check(@subject.current_action.item)
		krx_skillfusion_sb_ui
	end
	#--------------------------------------------------------------------------
	# ● Determine if the fusion prerequisites are met
	#--------------------------------------------------------------------------
	def fusion_check(item)
		@fs_class = NilClass if @fs_class.nil?
		if (item.is_a?(RPG::Skill) && !item.fusions.empty?) &&
		((KRX::FUSION_PARTY_CHECK && @subject.is_a?(@fs_class)) ||
		!KRX::FUSION_PARTY_CHECK)
			item.fusions.each_index do |i|
				next if i % 2 !=0
				if @fs_last != nil && @fs_last.id == item.fusions[i]
					if @subject.usable?($data_skills[item.fusions[i+1]])
						comb = " (#{@fs_last.name} + #{item.name})"
						item = $data_skills[item.fusions[i+1]]
						@subject.current_action.set_skill(item.id)
						@log_window.add_text(KRX::VOCAB::FUSION_TEXT + comb)
					end
				end
			end
		end
		@fs_last = item
		@fs_class = @subject.is_a?(Game_Actor) ? Game_Actor : Game_Enemy
	end
end