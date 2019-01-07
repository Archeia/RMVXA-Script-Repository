=begin
#===============================================================================
 Title: Vehicle Routes
 Author: Hime
 Date: Apr 9, 2013
--------------------------------------------------------------------------------
 ** Change log
 Apr 9, 2013
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
 
 This script allows you to set move routes for vehicles on the screen using
 the move route editor.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 Before a move route command, make a script call
 
   set_vehicle_route(TYPE)
   
 Where TYPE is one of the following

   :boat
   :ship
   :airship
   
 The next move route command will be applied to the specified vehicle, if
 the vehicle is on the same map.
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_VehicleRoutes"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Vehicle_Routes
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
class Game_Interpreter
  
  alias :th_vehicle_routes_clear :clear
  def clear
    th_vehicle_routes_clear
    @vehicle_route_type = nil
  end
  
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  alias :th_vehicle_routes_command_205 :command_205
  def command_205
    $game_map.refresh if $game_map.need_refresh
    if @vehicle_route_type
      vehicle = $game_map.vehicle(@vehicle_route_type)
      if vehicle
        vehicle.force_move_route(@params[1])
        Fiber.yield while vehicle.move_route_forcing if @params[1].wait
      end
      
      # reset it in case there are other move routes
      @vehicle_route_type = nil
    else
      th_vehicle_routes_command_205
    end
  end
  
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def set_vehicle_route(type)
    @vehicle_route_type = type.to_sym
  end
end

#-------------------------------------------------------------------------------
# Since the vehicles will be moving by themselves, they should follow their
# own passage rules
#-------------------------------------------------------------------------------
class Game_Vehicle < Game_Character
  def map_passable?(x, y, d)
    case @type
    when :boat
      return $game_map.boat_passable?(x, y)
    when :ship
      return $game_map.ship_passable?(x, y)
    when :airship
      return true
    end
  end
end