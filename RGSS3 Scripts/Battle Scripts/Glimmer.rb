#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Glimmer
#  Author: Kread-EX
#  Version 1.0
#  Release date: 13/12/2011
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
 
#-------------------------------------------------------------------------------------------------
#  ▼ TERMS OF USAGE
#-------------------------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work for commercial purposes if you like it.
# #  Do not distribute this script without my permission.
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
# # Glimmer is a skill learning system used by the SaGa games. Basically, certain attacks
# # allow the user to have an epiphany and 'spark' a new skill if the target is high level
# # enough.
#-------------------------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#-------------------------------------------------------------------------------------------------
# # The glimmer use one giant notetag with several sub-notetags within. Those tags are
# # inserted into the enemy's notebox.
# # <glimmer: x>           - the actor who can glimmer
# # <ID: x, x>           - the skills that can be sparked.
# # <%: x, x>         - the % chance to spark.
# # <sparkers: x, x>      - the base skill allowing the glimmer
# # </glimmer>            - mandatory end tag
#-------------------------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
# # Works with Yanfly Engine Ace (Ace Battle Engine).
# # Works with Skill Fusion and take precedence over it.
# #
# # List of aliases and overwrites:
# #
# # Game_Enemy
# # initialize (alias)
# # load_glimmer_notetags (new method)
# # glimmer_ok? (new method)
# # glimmer_useless? (new method)
# # glimmers (new method)
# # glimmer_chance (new method)
# # glimmer_sparkers (new method)
# #
# # Scene_Battle
# # execute_action (alias)
# # glimmer_effect (new method)
#-------------------------------------------------------------------------------------------------

$imported = {} if $imported.nil?
$imported['KRX-Glimmer'] = true

puts 'Load: Glimmer v1.0 by Kread-EX'

module KRX

	module REGEXP
		GLIMMER_START = /<glimmer:[ ]*(\d+)>/i
		GLIMMER_END = /<\/glimmer>/i
		GLIMMER_IDS = /<ID:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
		GLIMMER_PER = /<%:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
		GLIMMER_SPARKERS = /<sparkers:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
	end
	
	module VOCAB
		GLIMMER_TEXT = 'Glimmer!'
	end
	
end

#===========================================================================
# ■ Game_Enemy
#===========================================================================

class Game_Enemy < Game_Battler
	#--------------------------------------------------------------------------
	# ● Object Initialize
	#--------------------------------------------------------------------------
	alias_method(:krx_glimmer_ge_init, :initialize)
	def initialize(index, enemy_id)
		krx_glimmer_ge_init(index, enemy_id)
		@glimmer_data = {}
		load_glimmer_notetags
		puts "Read: Glimmer Notetags for #{enemy.name}"
	end 
	#--------------------------------------------------------------------------
	# ● Determine if the enemy sparks any new skill
	#--------------------------------------------------------------------------
	def glimmer_ok?
		!@glimmer_data.empty?
	end
	#--------------------------------------------------------------------------
	# ● Determine if the actor knows all the glimmers already
	#--------------------------------------------------------------------------
	def glimmer_useless?(key)
		glimmers(key).each do |id|
			skill = $data_skills[id]
			if !$game_actors[key].skill_learn?(skill)
				return false
			end
		end
		return true
	end
	#--------------------------------------------------------------------------
	# ● Returns the actors eligible to a glimmer
	#--------------------------------------------------------------------------
	def glimmer_actors
		@glimmer_data.keys
	end
	#--------------------------------------------------------------------------
	# ● Returns the glimmers of an actor
	#--------------------------------------------------------------------------
	def glimmers(key)
		@glimmer_data[key][0]
	end
	#--------------------------------------------------------------------------
	# ● Returns the chances of glimmer for a skill
	#--------------------------------------------------------------------------
	def glimmer_chance(key, skill_id)
		ind = 0
		glimmers(key).each do |id|
			ind = @glimmer_data[key][0].index(id)
			break if id == skill_id
		end
		@glimmer_data[key][1][ind]
	end
	#--------------------------------------------------------------------------
	# ● Returns the skills that can spark a glimmer
	#--------------------------------------------------------------------------
	def glimmer_sparkers(key)
		@glimmer_data[key][2]
	end
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_glimmer_notetags
		actor = nil
		write_glimmer = false
		enemy.note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::GLIMMER_START
				@glimmer_data[$1.to_i] = [[], [], []]
				actor = $1.to_i
				write_glimmer = true
			when KRX::REGEXP::GLIMMER_END
				write_glimmer = false
			when KRX::REGEXP::GLIMMER_IDS
				if write_glimmer
					$1.scan(/\d+/).each do |i|
						@glimmer_data[actor][0].push(i.to_i)
					end
				end
			when KRX::REGEXP::GLIMMER_PER
				if write_glimmer
					$1.scan(/\d+/).each do |i|
						@glimmer_data[actor][1].push(i.to_i)
					end
				end
			when KRX::REGEXP::GLIMMER_SPARKERS
				if write_glimmer
					$1.scan(/\d+/).each do |i|
						@glimmer_data[actor][2].push(i.to_i)
					end
				end
			end
		end
	end
end

#===========================================================================
# ■ Scene_Battle
#===========================================================================

class Scene_Battle < Scene_Base
	#--------------------------------------------------------------------------
	# ● Execute the current action
	#--------------------------------------------------------------------------
	alias_method(:krx_glimmer_sb_action, :execute_action)
	def execute_action
		glimmer_effect if @subject.is_a?(Game_Actor)
		krx_glimmer_sb_action
	end
	#--------------------------------------------------------------------------
	# ● Checks for a glimmer and performs it if any
	#--------------------------------------------------------------------------
	def glimmer_effect
		item = @subject.current_action.item
		return unless item
		targets = @subject.current_action.make_targets.compact
		targets.delete_if do |target|
			!target.is_a?(Game_Enemy) ||
			!target.glimmer_ok? ||
			!target.glimmer_actors.include?(@subject.id) ||
			!target.glimmer_sparkers(@subject.id).include?(item.id) ||
			target.glimmer_useless?(@subject.id)
		end
		return if targets.nil? || targets.empty?
		target = targets[rand(targets.size)]
		target.glimmers(@subject.id).each do |id|
			next if @subject.skill_learn?($data_skills[id])
			if (rand(100) + 1) < target.glimmer_chance(@subject.id, id)
				@log_window.add_text(KRX::VOCAB::GLIMMER_TEXT)
				@subject.current_action.set_skill(id)
				@subject.learn_skill(id)
				return
			end
		end
	end
end