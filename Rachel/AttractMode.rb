#==============================================================================
# Attract Mode
# by: Racheal
# Version 1.3
# Created: 09/12/2013
# Updated: 10/12/2013
#==============================================================================
# Allows you to set up an attract mode map if the player idles on the title
# screen. Attract mode can be canceled at any time with the confirm or cancel
# keys.
#==============================================================================
# Instructions:
# * Insert in the Materials section
# * Configure to your liking below
#==============================================================================

#==============================================================================
# Customization
#==============================================================================
module Racheal_Attract_Mode
	# Map that attract mode sends you to
	ATTRACT_MAP = 2

	# Set whether to view attract mode before the first time you se
	# title screen
	SHOW_FIRST = true

	# Amount of time (in frames) until attract mode kicks in
	# The time is set exceptionally low in this demo just so you don't have to
	# sit around and wait a long time to see it.
	WAIT = 320
	end
	#==============================================================================
	# End Customization
	#==============================================================================

	module Input

	BUTTONS = [
	:LEFT, :UP, :RIGHT, :DOWN,
	:A, :B, :C,
	:X, :Y, :Z,
	:L, :R,
	:SHIFT, :CTRL, :ALT,
	:F5, :F6, :F7, :F8, :F9
	]

	def self.any_press?
		BUTTONS.any? {|i| press? i}
	end

end

#==============================================================================

module DataManager
	#--------------------------------------------------------------------------
	# * Set Up Attract Mode
	#--------------------------------------------------------------------------
	def self.setup_attract
		create_game_objects
		$game_party.setup_starting_members
		$game_map.setup(Racheal_Attract_Mode::ATTRACT_MAP)
		$game_player.moveto(5, 5)
		$game_player.refresh
		Graphics.frame_count = 0
		end
	end

	#==============================================================================

class Scene_Attract < Scene_Map
#--------------------------------------------------------------------------
# * Frame Update
#--------------------------------------------------------------------------
def update
	super
		SceneManager.goto(Scene_Title) if Input.any_press?
	end
end

#==============================================================================

class Scene_Title < Scene_Base
	@@attract_seen = !Racheal_Attract_Mode::SHOW_FIRST
	#--------------------------------------------------------------------------
	# * Start Processing
	#--------------------------------------------------------------------------
	alias scene_title_start_attract_mode start
	def start
		unless @@attract_seen
		start_attract
		@@attract_seen = true
		return
		end
		scene_title_start_attract_mode
		@count = 0
	end
	#--------------------------------------------------------------------------
	# * Frame Update
	#--------------------------------------------------------------------------
	alias scene_title_update_attract_mode update
	def update
		scene_title_update_attract_mode
		@count += 1
		start_attract if @count == Racheal_Attract_Mode::WAIT
	end
	#--------------------------------------------------------------------------
	# * Termination Processing
	#--------------------------------------------------------------------------
	alias scene_title_terminate_attract_mode terminate
	def terminate
		Graphics.freeze
		scene_title_terminate_attract_mode if @viewport
	end
	#--------------------------------------------------------------------------
	# * Start Attract
	#--------------------------------------------------------------------------
	def start_attract
		DataManager.setup_attract
		close_command_window if @command_window
		fadeout_all
		$game_player.transparent = true
		$game_player.followers.visible = false
		$game_player.refresh
		$game_map.autoplay
		SceneManager.goto(Scene_Attract)
	end
end