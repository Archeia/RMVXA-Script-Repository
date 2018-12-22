#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
# Multiple Airships
# Author: Kread-EX, by request of press336
# Version 1.0
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
 
#  TERMS OF USAGE
# #------------------------------------------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work both for commercial and non-commercial work.
# #  Credit is appreciated.
# #------------------------------------------------------------------------------------------------------------------

#===========================================================
# INTRODUCTION
#
# Allows you to create a park of airships. Or just multiple airships.
# To use this script, there are several steps:
# 
# * In the very small config part, indicate the maximum number of airships.
# * When you use the Get On/Off Vehicle event command, you have to indicate which
# airship you are referring to. Do it through a Call Script command:
#                $game_system.current_airship = 3
# This example will invoke the second airship. Note that the airship numbers
# start at 2, not at 0 or 1.
#===========================================================

#==============================================================================
# ** Configuration
#==============================================================================

module KreadCFG
  
  MAX_AIRSHIPS = 12
  
end

#==============================================================================
# ** Game_Map
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # * Create Vehicles
  #--------------------------------------------------------------------------
  alias_method :krx_ma_game_map_create_vehicles, :create_vehicles unless $@
  def create_vehicles
    krx_ma_game_map_create_vehicles
    (3..(KreadCFG::MAX_AIRSHIPS + 3)).each {|i|
      @vehicles[i] = Game_Vehicle.new(2)
    }
  end
  #--------------------------------------------------------------------------
  # * Get Airship
  #--------------------------------------------------------------------------
  def airship
    return @vehicles[$game_system.current_airship]
  end
  #--------------------------------------------------------------------------
end
  
#==============================================================================
# ** Game_System
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :current_airship
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias_method :krx_ma_game_system_init, :initialize unless $@
  def initialize
    krx_ma_game_system_init
    @current_airship = 2
  end
  #--------------------------------------------------------------------------
end
  
#==============================================================================
# ** Game_Player
#==============================================================================

class Game_Player
  #--------------------------------------------------------------------------
  # * Update Vehicle
  #--------------------------------------------------------------------------
  def update_vehicle
    return unless in_vehicle?
    if @vehicle_type == 2
      vehicle = $game_map.airship
    else
      vehicle = $game_map.vehicles[@vehicle_type]
    end
    if @vehicle_getting_on                    # Boarding?
      if not moving?
        @direction = vehicle.direction        # Change direction
        @move_speed = vehicle.speed           # Change movement speed
        @vehicle_getting_on = false           # Finish boarding operation
        @transparent = true                   # Transparency
      end
    elsif @vehicle_getting_off                # Getting off?
      if not moving? and vehicle.altitude == 0
        @vehicle_getting_off = false          # Finish getting off operation
        @vehicle_type = -1                    # Erase vehicle type
        @transparent = false                  # Remove transparency
      end
    else                                      # Riding in vehicle
      vehicle.sync_with_player                # Move at the same time as player
    end
  end
  #--------------------------------------------------------------------------
  # * Get Off Vehicle
  #--------------------------------------------------------------------------
  def get_off_vehicle
    if in_airship?                                # Airship
      return unless airship_land_ok?(@x, @y)      # Can't land?
    else                                          # Boat/ship
      front_x = $game_map.x_with_direction(@x, @direction)
      front_y = $game_map.y_with_direction(@y, @direction)
      return unless can_walk?(front_x, front_y)   # Can't touch land?
    end
    if @vehicle_type == 2
      $game_map.airship.get_off
    else
      $game_map.vehicles[@vehicle_type].get_off   # Get off processing
    end
    if in_airship?                                # Airship
      @direction = 2                              # Face down
    else                                          # Boat/ship
      force_move_forward                          # Move one step forward
      @transparent = false                        # Remove transparency
    end
    @vehicle_getting_off = true                   # Start getting off operation
    @move_speed = 4                               # Return move speed
    @through = false                              # Passage OFF
    @walking_bgm.play                             # Restore walking BGM
    make_encounter_count                          # Initialize encounter
  end
  #--------------------------------------------------------------------------
  # * Board Vehicle
  #--------------------------------------------------------------------------
  def get_on_vehicle
    front_x = $game_map.x_with_direction(@x, @direction)
    front_y = $game_map.y_with_direction(@y, @direction)
    if $game_map.airship.pos?(@x, @y)       # Is it overlapping with airship?
      get_on_airship
      return true
    elsif $game_map.ship.pos?(front_x, front_y)   # Is there a ship in front?
      get_on_ship
      return true
    elsif $game_map.boat.pos?(front_x, front_y)   # Is there a boat in front?
      get_on_boat
      return true
    else
      (3...$game_map.vehicles.size).each {|i|
        $game_system.current_airship = i
        if $game_map.airship.pos?(@x, @y)
          get_on_airship
          return true
        end
      }
    end
    return false
  end
  #--------------------------------------------------------------------------
end