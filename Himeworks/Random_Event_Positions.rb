=begin
#===============================================================================
 Title: Random Event Positions
 Author: Hime
 Date: Apr 6, 2014
--------------------------------------------------------------------------------
 ** Change log
 Apr 6, 2014
   - fixed bug where "page" randomization was not working
 Aug 12, 2013
   - fixed regex
   - added "start" randomization type.
 Aug 9, 2013
   - added support for variable region ID's
 Jul 20, 2013
   - fixed issue where events could overlap each other
 May 3, 2013
   - fixed issue where game crashed if no page selected
 Apr 28, 2013
   - added option for determining when the event position is randomized
 Apr 25, 2013
   - added global disable switch
   - fixed bug where event was assigned to a region that was not on the map
   - initial release
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
 
 This script allows you to randomize an event's position when you enter the
 map. Regions are used to designate the tiles where an event can appear.

--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 To designate an event page where the event's position is randomized, create
 a comment and write
 
   <random position region: x type>
   
 For some region ID x
 The region ID can be a fixed number such as 1 or 2, or it can be a reference
 to a game variable such as v[2] which will take the value of variable 2.
 
 The type determines when position randomization occurs
 
   start - only once in the game: the first time the event is loaded
   init - whenever the event is created (eg: map loading)
   page - whenever you change to that page
 
 If that page is active when the map is loaded, then the event will be randomly
 moved to a tile in that region.
 
 This is applied to events on a per-page basis, so you may need to add the
 comment to multiple pages.
 
 In the configuration there is a switch that will allow you to disable
 random event positioning if the switch is ON.
 
 Note that the "start" type does not memorize the event's location, so you will
 need a different script for that.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_RandomEventPositions"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Random_Event_Positions
    
    # Global switch that determines whether positions should be randomized
    # If it's ON, then positions will not be randomized
    Disable_Switch = 928
    
    # type of randomization by default
    Default_Type = :init
    
    Regex = /<random[-_ ]position[-_ ]region:\s*(v\[\d+\]|\d+)\s*(\w+)?>/i
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  class Event::Page
    
    #---------------------------------------------------------------------------
    # Returns true if event's position should be randomized on this page.
    # True only if random position region > 0
    #---------------------------------------------------------------------------
    def random_position?
      return @is_random_position unless @is_random_position.nil?
      load_notetag_random_event_positions
      return @is_random_position
    end
    
    #---------------------------------------------------------------------------
    # Determines when the position randomization will occur
    #---------------------------------------------------------------------------
    def random_position_type
      return @random_position_type unless @random_position_type.nil?
      load_notetag_random_event_positions
      return @random_position_type
    end
    
    #---------------------------------------------------------------------------
    # Returns the random position region for this event page
    #---------------------------------------------------------------------------
    def random_position_region
      return eval_random_position_region unless @random_position_region.nil?
      load_notetag_random_event_positions
      return eval_random_position_region
    end
    
    def eval_random_position_region(v=$game_variables, s=$game_switches)
      eval(@random_position_region)
    end
    
    #---------------------------------------------------------------------------
    # Parse event page commands looking for the required comment
    #---------------------------------------------------------------------------
    def load_notetag_random_event_positions
      @is_random_position = false
      @random_position_region = "0"
      @random_position_type = TH::Random_Event_Positions::Default_Type
      @list.each do |cmd|
        if cmd.code == 108 && cmd.parameters[0] =~ TH::Random_Event_Positions::Regex
          @random_position_region = $1
          @random_position_type = $2.to_sym unless $2.nil?
          @is_random_position = @random_position_region != 0
          break
        end
      end
    end
  end
end

class Game_System
  
  alias :th_random_event_positions :initialize
  def initialize
    th_random_event_positions
    @random_position_event = {}
  end
  
  def random_position_event
    @random_position_events ||= {}
  end
end

class Game_Map
  
  attr_reader :region_tile_mapping
  
  #-----------------------------------------------------------------------------
  # Setup the region tile mapping before creating events
  #-----------------------------------------------------------------------------
  alias :th_random_event_positions_setup_events :setup_events
  def setup_events
    setup_region_tile_mapping
    th_random_event_positions_setup_events
  end
  
  #-----------------------------------------------------------------------------
  # Sets up a hash, where the keys are region ID's and values are arrays of
  # positions stored as [x, y]. This is to cache the tiles based on their
  # regions. Assumes regions do not change after the map is loaded.
  #-----------------------------------------------------------------------------
  def setup_region_tile_mapping
    @region_tile_mapping = {}
    (0..63).each {|i| @region_tile_mapping[i] = []}
    for x in 0..data.xsize
      for y in 0..data.ysize
        @region_tile_mapping[region_id(x, y)] << [x,y]
      end
    end
  end
end
 
class Game_Event < Game_Character
  
  #-----------------------------------------------------------------------------
  # Move the event to a new position if necessary
  #-----------------------------------------------------------------------------
  alias :th_random_event_positions_initialize :initialize
  def initialize(map_id, event)
    th_random_event_positions_initialize(map_id, event)
    randomize_position
  end
  
  #-----------------------------------------------------------------------------
  # Picks a random tile based on the event's random position region.
  # Seed is randomized so that events with the same position region don't
  # all appear on the same tiles
  #-----------------------------------------------------------------------------
  def randomize_position
    return if @page.nil?
    return if $game_switches[TH::Random_Event_Positions::Disable_Switch] || !@page.random_position?
    # if randomize type is ":start", check if it's already been visited
    # else, check if randomize type is ":init"
    if @page.random_position_type == :start
      return if $game_system.random_position_event[[@map_id, @id]]
    elsif @page.random_position_type == :init
      return if @position_randomized
    end
    @position_randomized = true
    
    srand
    $game_system.random_position_event[[@map_id, @id]] = true
    begin
      pos = get_random_position
      return unless pos
    end while !$game_map.events_xy(pos[0], pos[1]).empty?
    
    moveto(pos[0], pos[1])
  end
  
  #-----------------------------------------------------------------------------
  # Pick a random tile and remove it from the list of available positions
  #-----------------------------------------------------------------------------
  def get_random_position
    arr = $game_map.region_tile_mapping[@page.random_position_region]
    return arr.delete_at(rand(arr.length))
  end
  
  alias :th_random_event_positions_setup_page_settings :setup_page_settings
  def setup_page_settings
    th_random_event_positions_setup_page_settings
    randomize_position if @page.random_position_type == :page
  end
end