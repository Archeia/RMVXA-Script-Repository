=begin
#===============================================================================
 Title: Move Route Triggering
 Author: Hime
 Date: Nov 17, 2013
--------------------------------------------------------------------------------
 ** Change log
 Nov 17, 2013
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
 
 This script allows you to execute touch trigger events while a move route is
 being processed. By default, events are not executed even if the move route
 forces the character to come into contact with another character.

--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 Plug and play.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_MoveRouteTriggering"] = true
#===============================================================================
# ** Rest of Script
#===============================================================================
class Game_Character < Game_CharacterBase
  alias :th_move_route_triggering_update_routine_move :update_routine_move
  def update_routine_move
    th_move_route_triggering_update_routine_move
    check_event_trigger_touch_front
  end
end

class Game_Player < Game_Character
  
  alias :th_move_route_triggering_start_map_event :start_map_event
  def start_map_event(x, y, triggers, normal)
    if @move_route_forcing
      $game_map.events_xy(x, y).each do |event|
        if event.trigger_in?(triggers) && event.normal_priority? == normal
          event.start
        end
      end
    else
      th_move_route_triggering_start_map_event(x, y, triggers, normal)
    end
  end
end

class Game_Event < Game_Character
  
  alias :th_move_route_triggering_check_event_trigger_touch :check_event_trigger_touch
  def check_event_trigger_touch(x, y)
    if @move_route_forcing
      if @trigger == 2 && $game_player.pos?(x, y)
        start if !jumping? && normal_priority?
      end
    else
      th_move_route_triggering_check_event_trigger_touch(x, y)
    end
  end
end