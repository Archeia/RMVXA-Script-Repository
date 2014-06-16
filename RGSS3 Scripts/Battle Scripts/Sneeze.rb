#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Sneeze
#  Author: Kread-EX
#  Version 1.0
#  Release date: 22/12/2011
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
# # Those who played Final Fantasy VI probably remember Typhon/Chupon, and his
# # infamous Sneeze. This skill kicks out a character from the party until the end
# # of the battle. 
#-------------------------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#-------------------------------------------------------------------------------------------------
# # Sneeze is actually a state. You just need to put this inside the notebox:
# #  <sneeze>
# # Don't forget to put the text which needs to be displayed once an ally is hit
# # with it.
#-------------------------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
# # Pointless with any script allowing to manage party during battle.
# #
# # List of aliases and overwrites:
# #
# # DataManager
# # load_database (alias)
# # load_sneeze_notetags (new method)
# #
# # BattleManager
# # init_members (alias)
# # process_defeat (alias)
# # process_abort (alias)
# # battle_end (alias)
# # resotres_party (new method)
# #
# # Game_Temp
# # used_sneeze (new attr method)
# #
# # RPG::State
# # load_sneeze_notetags (new method)
# # remove_at_battle_end (alias)
# #
# # Scene_Battle
# # apply_item_effects (alias)
#-------------------------------------------------------------------------------------------------

$imported = {} if $imported.nil?
$imported['KRX-Sneeze'] = true

puts 'Load: Sneeze v1.0 by Kread-EX'

module KRX
	
	module REGEXP
		SNEEZE_EFFECT = /<sneeze>/i
	end
	
end

#===========================================================================
# ■ BattleManager
#===========================================================================

module BattleManager  
	#--------------------------------------------------------------------------
	# ● Alias listings
	#--------------------------------------------------------------------------
	class << self
		alias_method(:krx_sneeze_bm_init_members, :init_members)
		alias_method(:krx_sneeze_bm_battle_end, :battle_end)
		alias_method(:krx_sneeze_bm_process_defeat, :process_defeat)
		alias_method(:krx_sneeze_bm_process_abort, :process_abort)
	end
	#--------------------------------------------------------------------------
	# ● Initializes variables
	#--------------------------------------------------------------------------
	def self.init_members
		krx_sneeze_bm_init_members
		@save_party = $game_party.all_members.dup
	end 
	#--------------------------------------------------------------------------
	# ● Loses the battle
	#--------------------------------------------------------------------------
	def self.process_defeat
		if $game_temp.used_sneeze
			if @can_lose ||@can_escape
				process_abort
				return
			end
		end
		krx_sneeze_bm_process_defeat
	end
	#--------------------------------------------------------------------------
	# ● Aborts the battle
	#--------------------------------------------------------------------------
	def self.process_abort
		if $game_temp.used_sneeze
			unless @can_lose ||@can_escape
				restores_party
				SceneManager.goto(Scene_Gameover)
				return
			end
		end
		krx_sneeze_bm_process_abort
	end
	#--------------------------------------------------------------------------
	# ● Ends the battle
	#--------------------------------------------------------------------------
	def self.battle_end(result)
		restores_party if $game_temp.used_sneeze
		$game_temp.used_sneeze = false
		krx_sneeze_bm_battle_end(result)
	end
	#--------------------------------------------------------------------------
	# ● Recreates the party
	#--------------------------------------------------------------------------
	def self.restores_party
		$game_party.all_members.each do |act|
			$game_party.remove_actor(act.id)
		end
		@save_party.each_index do |i|
			$game_party.add_actor(@save_party[i].id)
		end
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
		alias_method(:krx_sneeze_dm_load_database, :load_database)
	end
	def self.load_database
		krx_sneeze_dm_load_database
		load_sneeze_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_sneeze_notetags
		groups = [$data_states]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_sneeze_notetags
			end
		end
		puts "Read: Sneeze Notetags"
	end
end

#==========================================================================
#  ■  RPG::State
#==========================================================================

class RPG::State < RPG::BaseItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
	attr_reader		:sneeze
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_sneeze_notetags
		@note.split(/[\r\n]+/).each do |line|
			case line
			when  KRX::REGEXP::SNEEZE_EFFECT
				@sneeze = true
			end
		end
	end
	#--------------------------------------------------------------------------
	# ● Checks if removal at the end of battle
	#--------------------------------------------------------------------------
	alias_method(:krx_sneeze_state_reb, :remove_at_battle_end)
	def remove_at_battle_end
		return true if @sneeze
		return krx_sneeze_state_reb
	end
end

#==========================================================================
#  ■  Game_Temp
#==========================================================================

class Game_Temp
		attr_accessor	:used_sneeze
end

#==========================================================================
#  ■  Scene_Battle
#==========================================================================

class Scene_Battle < Scene_Base
	#--------------------------------------------------------------------------
	# ● Applies the action effects
	#--------------------------------------------------------------------------
	alias_method(:krx_sneeze_sb_aie, :apply_item_effects)
	def apply_item_effects(target, item)
		krx_sneeze_sb_aie(target, item)
		if target.is_a?(Game_Actor)
			target.states.each do |st|
				if st.sneeze
					$game_party.remove_actor(target.id)
					$game_temp.used_sneeze = true
					break
				end
			end
		end
	end
end