#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Game Over Common Event
#  Author: Kread-EX
#  Version 1.02
#  Release date: 17/12/2011
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
 
 #-------------------------------------------------------------------------------------------------
#  ▼ UPDATES
#-------------------------------------------------------------------------------------------------
# # 19/12/2011. Added the option to replay Map BGM.
# # 18/12/2011. Fixed an infinite loop.
#-------------------------------------------------------------------------------------------------
#  ▼ TERMS OF USAGE
#-------------------------------------------------------------------------------------------------
# #  None. Made that in a few minutes.
#-------------------------------------------------------------------------------------------------
#  ▼ INTRODUCTION
#-------------------------------------------------------------------------------------------------
# # Overrides the standard Game Over with a common event on the map.
#-------------------------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#-------------------------------------------------------------------------------------------------
# # By default, use the 1st common event as game over. You can change this with a
# # script call:
# # $game_system.game_over_event_id = x
# # To disable the replay of the map bgm:
# # $game_system.game_over_map_bgm = false
# #
# # Note: The Game Over event command will not trigger the common event.
#-------------------------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
# # I don't foresee any problems.
#-------------------------------------------------------------------------------------------------

puts 'Load: Game Over Common Event v1.02 by Kread-EX'

#===========================================================================
# ■ SceneManager
#===========================================================================

module SceneManager
	#--------------------------------------------------------------------------
	# ● Jump to a scene
	#--------------------------------------------------------------------------
	class << self; alias_method(:krx_goce_sm_goto, :goto); end
	def self.goto(scene_class)
		if scene_class == Scene_Gameover
			unless $game_temp.no_game_over_ce || $game_system.game_over_event_id == -1
				id = $game_system.game_over_event_id
				$game_temp.reserve_common_event(id != nil ? id : 1)
				$game_party.members.each do |mem|
					mem.remove_state(1)
				end
				if @scene.is_a?(Scene_Battle) && $game_system.game_over_map_bgm
					BattleManager.replay_bgm_and_bgs
				end
				scene_class = Scene_Map
			end
		end
		$game_temp.no_game_over_ce = false
		krx_goce_sm_goto(scene_class)
	end  
end

#===========================================================================
# ■ Game_Temp
#===========================================================================

class Game_Temp
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
	attr_accessor	:no_game_over_ce
end

#===========================================================================
# ■ Game_System
#===========================================================================

class Game_System
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
	attr_accessor		:game_over_event_id
	attr_accessor		:game_over_map_bgm
	#--------------------------------------------------------------------------
	# ● Object Initialize
	#--------------------------------------------------------------------------
	alias_method(:krx_goce_gs_init, :initialize)
	def initialize
		krx_goce_gs_init
		@game_over_event_id = 1
		@game_over_map_bgm = true
	end
end

#===========================================================================
# ■ Game_Interpreter
#===========================================================================

class Game_Interpreter
	#--------------------------------------------------------------------------
	# ● Game Over
	#--------------------------------------------------------------------------
	alias_method(:krx_goce_gi_353, :command_353)
	def command_353
		$game_temp.no_game_over_ce = true
		krx_goce_gi_353
	end
end