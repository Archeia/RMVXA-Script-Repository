=begin
#===============================================================================
 Title: Custom Start Locations
 Author: Hime
 Date: Jul 21, 2013
--------------------------------------------------------------------------------
 ** Change log
 Jul 21, 2013
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
 
 This script allows you to manage multiple start locations, giving each a
 unique name that you can use in your scripts or script calls. You can create
 as many start locations as you want provided that each location has its own
 name.
 
 This script only provides functionality for creating multiple start locations.
 Currently there is only support for player start locations.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 In the configuration section there is a table that allows you to create custom
 start locations. The name of the start location that you specify in the
 editor is called "default" and should not be used.
 
 To move players to a custom start location, you just need to make the script
 call
 
   $game_player.move_to_start_location(name)
   
 Where `name` is the name of a start location defined in the start location
 table.
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_CustomStartLocations"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Custom_Start_Locations
    
    # Start location table for the player
    # Format: location_name => [map_id, x, y]
    Player_Locations = {
      :custom1 => [1, 1, 1],
      :custom2 => [2, 1, 1]
    }
    
    # Name of the default start location. This is the one used
    # when you hit "New Game" in the default title menu
    Default_Start = :default
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================

#-------------------------------------------------------------------------------
# An object that represents a start location
#-------------------------------------------------------------------------------
class Game_StartLocation
  attr_accessor :map_id
  attr_accessor :x
  attr_accessor :y
  
  def initialize(map_id, x, y)
    @map_id = map_id
    @x = x
    @y = y
  end
end

module DataManager
  class << self
    alias :th_custom_start_locations_setup_new_game :setup_new_game
  end
  
  #-----------------------------------------------------------------------------
  # Move the player to the custom start location automatically. Note that
  # this actually sets up the original start map because I simply aliased
  # it instead of overwriting it.
  #-----------------------------------------------------------------------------
  def self.setup_new_game
    th_custom_start_locations_setup_new_game
    $game_player.move_to_start_location(TH::Custom_Start_Locations::Default_Start)
  end
end
  
#-------------------------------------------------------------------------------
# Start locations are stored with the save files. It is possible that these
# start locations may change throughout the game for some reason...
#-------------------------------------------------------------------------------
class Game_System
  
  attr_reader :start_locations
  
  #-----------------------------------------------------------------------------
  # Initializes an array of start locations
  #-----------------------------------------------------------------------------
  alias :th_custom_start_locations_initialize :initialize
  def initialize
    th_custom_start_locations_initialize
    initialize_start_locations
  end
  
  def initialize_start_locations
    @start_locations = {}
    
    # set up default start location
    loc = Game_StartLocation.new($data_system.start_map_id, $data_system.start_x, $data_system.start_y)
    @start_locations[:default] = loc
    
    # set up custom start locations
    TH::Custom_Start_Locations::Player_Locations.each do |name, location|
      loc = Game_StartLocation.new(*location)
      @start_locations[name] = loc
    end
  end
  
  #-----------------------------------------------------------------------------
  # Returns the start location, which is an array consisting of three pieces
  # of information: [start_map_id, start_x, start_y]
  #-----------------------------------------------------------------------------
  def get_start_location(name=:default)
    name = name.to_sym
    return @start_locations[name]
  end
end

class Game_Player < Game_Character
  
  #-----------------------------------------------------------------------------
  # New. Moves player to the specified start location
  #-----------------------------------------------------------------------------
  def move_to_start_location(name)
    loc = $game_system.get_start_location(name)
    $game_map.setup(loc.map_id)
    moveto(loc.x, loc.y)
    refresh
  end
end