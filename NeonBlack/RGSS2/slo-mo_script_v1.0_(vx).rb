###--------------------------------------------------------------------------###
#  Slo-mo script                                                               #
#  Version 1.0                                                                 #
#                                                                              #
#      Credits:                                                                #
#  Original code by: Neonblack                                                 #
#  Modified by:                                                                #
#                                                                              #
#  This work is licensed under the Creative Commons Attribution-NonCommercial  #
#  3.0 Unported License. To view a copy of this license, visit                 #
#  http://creativecommons.org/licenses/by-nc/3.0/.                             #
#  Permissions beyond the scope of this license are available at               #
#  http://cphouseset.wordpress.com/liscense-and-terms-of-use/.                 #
#                                                                              #
#      Contact:                                                                #
#  NeonBlack - neonblack23@live.com (e-mail) or "neonblack23" on skype         #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Revision information:                                                   #
#  V1.0 - 10.29.2011                                                           #
#   Wrote and debugged main script                                             #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Compatibility:                                                          #
#  Alias       - Game_System: initialize, update                               #
#                Sprite_Character: update                                      #
#                Scene_Map: perform_battle_transition                          #
#                Scene_Menu: initialize                                        #
#  New Classes - Game_FrameRate                                                #
#  New Objects - Game_FrameRate: initialize, update, glitch_test               #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Instructions:                                                           #
#  Place this script in the "Materials" section of the scripts above main.     #
#  This script is pretty much plug and play with a few options available to    #
#  change below.  Using the script is as simple as changing a single           #
#  variable.  To enter slo-mo, simply change the pre-defined variable.         #
#  Since changing the framerate affects pretty much everything on screen and   #
#  everything in an event, caution is advised when using this script.          #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Config:                                                                 #
#  These are the default values used by several of the functions in the        #
#  script.  You may change these values as you find your game requires in      #
#  order to give the player a better playing experience based on your game.    #
#                                                                              #
# The default variable used for the frame rate.  Changing this variable at     #
# any time in game will result in a modified frame rate.                       #
SET_FPS_VARIABLE = 27 # Default = 27                                           #
#                                                                              #
# The default "slow" value.  While the framerate is this value or below, all   #
# events on screen change to "add" blending mode to make slo-mo mode a little  #
# more fancy.  Set this value to 9 or below to disable it.                     #
SLOMO_BLEND_EFFECT = 30 # Default = 30                                         #
#                                                                              #
# The default min and max values for FPS.  These limit what your min and max   #
# values can be in game to prevent large scale bugs.  Even if you set them     #
# higher or lower, the RGSS2 core engine cannot use frame rates lower than 10  #
# or higher than 120.                                                          #
LIMIT_FPS_MAX = 60 # Default = 60                                              #
LIMIT_FPS_MIN = 30 # Default = 30                                              #
#                                                                              #
###--------------------------------------------------------------------------###


###--------------------------------------------------------------------------###
#  The following lines are the actual core code of the script.  While you are  #
#  certainly invited to look, modifying it may result in undesirable results.  #
#  Modify at your own risk!                                                    #
###--------------------------------------------------------------------------###


# New class  -  Controls the framerate in game if it is changed by a controller.
class Game_FrameRate
  def initialize
    # Nothing here!  Is that even allowed?  In any case, this is a placeholder.
  end
  
  def update
    new_fps = $game_variables[SET_FPS_VARIABLE]
    new_fps = 60 if new_fps < 10
    new_fps = glitch_test(new_fps)
    if not $scene.is_a?(Scene_Battle) && $scene != Scene_Menu
      Graphics.frame_rate = new_fps if Graphics.frame_rate != new_fps
    end
    $game_variables[SET_FPS_VARIABLE] = new_fps
  end

# New object  -  Called by the "update" object.  Used to check the new FPS
#                value and limit it if needed.
  def glitch_test(fps)
    fps = LIMIT_FPS_MAX if fps > LIMIT_FPS_MAX
    fps = LIMIT_FPS_MIN if fps < LIMIT_FPS_MIN
    return fps
  end
end

class Game_System
# Alias method  -  Used to initialize frame rate.
  alias initialize_with_framerate initialize
  def initialize
    $cp_framerate = Game_FrameRate.new
    initialize_with_framerate
  end

# Alias method  -  Used to update the frame rate.
  alias update_with_framerate update
  def update
    update_with_framerate
    $cp_framerate.update
  end
end

class Sprite_Character < Sprite_Base
# Alias method  -  Used to change sprite blending.
  alias update_with_framerate update
  def update
    update_with_framerate
    self.blend_type = Graphics.frame_rate <= SLOMO_BLEND_EFFECT ? 1 : 0
  end
end

class Scene_Map < Scene_Base
# Alias method  -  Used to return the framerate to 60 in battle.
  alias perform_battle_transition_with_framerate perform_battle_transition
  def perform_battle_transition
    Graphics.frame_rate = 60
    perform_battle_transition_with_framerate
  end
end

class Scene_Menu < Scene_Base
# Alias method  -  Used to return the framerate to 60 in the menu.
  alias initialize_with_framerate initialize
  def initialize(menu_index = 0)
    Graphics.frame_rate = 60
    initialize_with_framerate(menu_index)
  end
end