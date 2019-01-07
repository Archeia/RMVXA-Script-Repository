=begin
#===============================================================================
 Title: Restricted Move Input
 Author: Hime
 Date: Aug 31, 2013
--------------------------------------------------------------------------------
 ** Change log
 Aug 31, 2013
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to enable or disable movement for specific
 directions using script calls. When a direction is disabled, the player
 is unable to move in that direction on the map using the direction input keys.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 

 The following script calls will enable or disable specific directions:
 
   disable_move_direction(dir_symbol)
   enable_move_direction(dir_symbol)
   
 Where the `dir_symbol`is one of the following
 
   :UP
   :LEFT
   :RIGHT
   :DOWN
   
--------------------------------------------------------------------------------
 ** Example
 
 To prevent players from moving up or down, use the script calls
 
   disable_move_direction(:UP)
   disable_move_direction(:DOWN)
   
 To enable them again, use the script calls
 
   enable_move_direction(:UP)
   enable_move_direction(:DOWN)
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_RestrictedMoveInput"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Restricted_Move_Input
    
    Input_Map = {
      :DOWN => 2,
      :LEFT => 4,
      :RIGHT => 6,
      :UP => 8
    }
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
class Game_System
  
  def disabled_move_inputs
    @move_input_disabled ||= {}
  end
end

class Game_Interpreter
  
  def disable_move_direction(dir_symbol)
    dir = TH::Restricted_Move_Input::Input_Map[dir_symbol]
    $game_system.disabled_move_inputs[dir] = true
  end
  
  def enable_move_direction(dir_symbol)
    dir = TH::Restricted_Move_Input::Input_Map[dir_symbol]
    $game_system.disabled_move_inputs[dir] = false
  end
end

class Game_Player < Game_Character
  
  alias :th_linear_movement_move_by_input :move_by_input
  def move_by_input
    return if $game_system.disabled_move_inputs[Input.dir4]
    th_linear_movement_move_by_input
  end
end