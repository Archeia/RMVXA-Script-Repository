=begin
#===============================================================================
 Title: Camera Target
 Author: Tsukihime
 Date: Nov 24, 2014
--------------------------------------------------------------------------------
 ** Change log
 Nov 24, 2014
   - fixed bug where followers weren't being targeted at all
 Jun 23, 2014
   - fixed bug where using events to set event positions incorrectly moved
     the camera to another event
 Feb 22, 2014
   - added support for setting party followers as the camera target
 Apr 16, 2013
   - initial release
--------------------------------------------------------------------------------  
 ** Terms of Use
 * Free to use in commercial/non-commercial projects
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Tsukihime in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to set the camera to follow a particular character
 on the map using script calls. By default, the camera follows the leader
 of the party.

--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 To set the camera's target, make a script call in the event or move route
 
   set_camera_target(char_id)
   
 If char_id is negative, then it is the corresponding member of the party.
 For example, -1 is the leader of the party, -2 is the second member, -3
 is the third member.
 
 If char_id is 0, then it is the current event that is executing the call.
 
 if char_id is 1 or higher, then it is the specified event. For example, char_id
 5 refers to event 5 on the current map.
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_CameraTarget] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Camera_Target
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module DataManager
  class << self
    alias :th_camera_target_create_game_objects :create_game_objects
  end
  def self.create_game_objects
    th_camera_target_create_game_objects
    $game_system.camera_target = $game_player
  end
end

#-------------------------------------------------------------------------------
# For convenient script call
#-------------------------------------------------------------------------------
class Game_Interpreter
  
  #-----------------------------------------------------------------------------
  # Set the camera target. Update mode is how the camera will update its target
  # Not implemented yet
  #-----------------------------------------------------------------------------
  def set_camera_target(event_id, update_mode=0)
    $game_system.camera_target = get_character(event_id)
    $game_map.refresh_camera_target(update_mode)
  end
  
  alias :th_camera_target_get_character :get_character
  def get_character(param)
    return nil if $game_party.in_battle
    return $game_player.followers[-(param+2)] if param < -1
    th_camera_target_get_character(param)
  end
end

#-------------------------------------------------------------------------------
# Camera target stored with the system
#-------------------------------------------------------------------------------
class Game_System
  attr_reader :camera_target
  
  alias :th_camera_target_initialize :initialize
  def initialize
    th_camera_target_initialize
    @camera_target = nil
  end
  
  def camera_target=(target)
    @camera_target = target
  end
end

#-------------------------------------------------------------------------------
# When the camera target changes, decide whether to update the camera position
# to the current target, and how it should be done
#-------------------------------------------------------------------------------
class Game_Map
  def refresh_camera_target(update_mode)
    char = $game_system.camera_target
    $game_system.camera_target.center(char.x, char.y)
  end
end

#-------------------------------------------------------------------------------
# Add scrolling logic to all characters
#-------------------------------------------------------------------------------
class Game_Character < Game_CharacterBase
  
  #-----------------------------------------------------------------------------
  # X Coordinate of Screen Center
  #-----------------------------------------------------------------------------
  def center_x
    (Graphics.width / 32 - 1) / 2.0
  end
  #-----------------------------------------------------------------------------
  # Y Coordinate of Screen Center
  #-----------------------------------------------------------------------------
  def center_y
    (Graphics.height / 32 - 1) / 2.0
  end
  #-----------------------------------------------------------------------------
  # Set Map Display Position to Center of Screen
  #-----------------------------------------------------------------------------
  def center(x, y)
    $game_map.set_display_pos(x - center_x, y - center_y)
  end
  
  #-----------------------------------------------------------------------------
  # Scroll map depending on character location
  #-----------------------------------------------------------------------------
  def update_scroll(last_real_x, last_real_y)
    return unless $game_system.camera_target == self
    ax1 = $game_map.adjust_x(last_real_x)
    ay1 = $game_map.adjust_y(last_real_y)
    ax2 = $game_map.adjust_x(@real_x)
    ay2 = $game_map.adjust_y(@real_y)
    $game_map.scroll_down (ay2 - ay1) if ay2 > ay1 && ay2 > center_y
    $game_map.scroll_left (ax1 - ax2) if ax2 < ax1 && ax2 < center_x
    $game_map.scroll_right(ax2 - ax1) if ax2 > ax1 && ax2 > center_x
    $game_map.scroll_up   (ay1 - ay2) if ay2 < ay1 && ay2 < center_y
  end
  
  #-----------------------------------------------------------------------------
  # Return the specified character by ID
  #-----------------------------------------------------------------------------
  def get_character(param)
    if $game_party.in_battle
      nil
    elsif param == -1
      $game_player
    elsif param < -1
      $game_player.followers[param.abs-2]
    else
      $game_map.events[param]
    end
  end
  
  #-----------------------------------------------------------------------------
  # Set the camera target. Used in move route interpreter
  #-----------------------------------------------------------------------------
  def set_camera_target(event_id, update_mode=0)
    $game_system.camera_target = get_character(event_id)
    $game_map.refresh_camera_target(update_mode)
  end

  alias :th_camera_target_update :update
  def update
    last_real_x = @real_x
    last_real_y = @real_y
    th_camera_target_update
    update_scroll(last_real_x, last_real_y)
  end
  
  alias :th_camera_target_moveto :moveto
  def moveto(x, y)
    th_camera_target_moveto(x, y)
    center(x, y) if $game_system.camera_target == self
  end
end

#-------------------------------------------------------------------------------
# Only update scroll if player is the camera target
#-------------------------------------------------------------------------------
class Game_Player < Game_Character
  
  alias :th_camera_target_update_scroll :update_scroll
  def update_scroll(last_real_x, last_real_y)
    return unless $game_system.camera_target == self
    th_camera_target_update_scroll(last_real_x, last_real_y)
  end
end

class Game_Event < Game_Character
  
  alias :th_camera_target_get_character :get_character
  def get_character(param)
    if param == 0
      return $game_map.events[@id]
    end
    th_camera_target_get_character(param)
  end
end