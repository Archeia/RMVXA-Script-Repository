=begin
#===============================================================================
 Title: Region Events
 Author: Hime
 Date: Dec 29, 2013
 URL: http://himeworks.com/2013/12/29/region-events/
--------------------------------------------------------------------------------
 ** Change log
 Dec 29, 2013
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
 
 This script allows you to create "Region Events". Basically, it allows you to
 turn an entire region into an event based on an existing event on your map.
 
 For example, suppose you have some Region 1 tiles. Using this script, you can
 connect Region 1 to an event on the map. The result is called "Region Event 1",
 and when you activate Region Event 1, it will run the event it is connected to.
 
 Region events obey all event rules. They do not have a graphic, because they
 are simply regions on your map. Region events are useful when you want
 multiple tiles to all run the same event.
 
--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, install this script below Materisls and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 -- Understanding Region Events --
 
 Region events obey event trigger rules. If the region event is activated by
 "action trigger", then players must press the "OK" button in order to activate
 the event. Similarly, if the region event is activated by "player touch", then
 the player can activate the event by walking onto the tile.
 
 Region events obey priority rules. If the region event is "same as character",
 then you can activate it when you stand in front of it. If the region event is
 "below character", then you must stand on it to activate it.
 
 Region events obey page conditions.
 
 -- Creating Region Events --
 
 There are several ways to create a region event. One way is to note-tag the
 map with
 
   <region event: regionID eventID> 
   
 One region can only have at most one referenced event. For example, region 1
 might reference event 2.
 
 Multiple regions can reference the same event. For example, both region 1 and
 region 2 might reference event 2.
 
 Simply add more note-tags for each region as required.
 An extended note-tag is also available for maps:
 
   <region events>
     regionID: eventID
     regionID: eventID
   </region events>
   
 It is just an alternative if you prefer that over individual note-tags.
 
 The second way to creating region events is to note-tag events themselves.
 Create a comment, then note-tag it with
 
   <region event: regionID>
   
 Note that the event ID used will be the ID of this event.
 
 -- Changing Region Events --
 
 Region events can be changed during the game using script calls:
 
   change_region_event(regionID, eventID)
   remove_region_event(regionID)
   
--------------------------------------------------------------------------------
 ** Example
 
 If you want to have region 1 reference event 3, you would make the script call
 
   change_region_event(1, 3)
   
 This means that when region event 1 is activated, it will run event 3.
 To remove region event 1, you can use the script call
 
   remove_region_event(1)
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_RegionEvents"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Region_Events
    
    # Specify both region ID and event ID for map note-tag
    Regex = /<region[-_ ]event:\s*(\d+)\s*(\d+)\s*>/i
    Ext_Regex = /<region[-_ ]events>(.*?)<\/region[-_ ]events>/im
    
    # Event ID is implied with event note-tags
    Event_Regex = /<region[-_ ]event:\s*(\d+)\s*>/i
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  class Event
    
    def region_event
      parse_region_event unless @region_event
      return @region_event
    end
    
    def parse_region_event
      @region_event = Data_RegionEvent.new
      self.pages[0].list.each do |cmd|
        if cmd.code == 108 && cmd.parameters[0] =~ TH::Region_Events::Event_Regex
          @region_event.region_id = $1.to_i
          break
        end
      end
    end
  end
  
  class Map
    def region_events
      load_notetag_region_events unless @region_events
      return @region_events
    end
    
    def load_notetag_region_events
      @region_events = {}
      
      # compact note-tag
      results = self.note.scan(TH::Region_Events::Regex)
      results.each do |res|
        region_id = res[0].to_i
        event_id = res[1].to_i
        @region_events[region_id] = event_id
      end
      
      # extended note-tag
      results = self.note.scan(TH::Region_Events::Ext_Regex)
      results.each do |res|
        res[0].strip.split("\r\n").each do |line|
          data = line.split(":")
          region_id = data[0].to_i
          event_id = data[1].to_i
          @region_events[region_id] = event_id
        end
      end
    end
  end
end

class Data_RegionEvent
  
  attr_accessor :region_id
  
  def initialize
    @region_id = -1
  end
end

class Game_Map
  
  alias :th_region_events_setup_events :setup_events
  def setup_events
    setup_region_events
    th_region_events_setup_events
  end
  
  #-----------------------------------------------------------------------------
  # Create a hash of region events. The key is the region ID, and the value is
  # the ID of the event that will be called. The ID can be changed at anytime
  #-----------------------------------------------------------------------------
  def setup_region_events
    @region_events = {}
    # Region events from map note-tag
    @map.region_events.each do |region_id, event_id|
      @region_events[region_id] = event_id
    end
    # Region events from events on the map
    @map.events.each do |id, event|
      data = event.region_event
      if data.region_id != -1
        @region_events[data.region_id] = id
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Also need to check if there are any region events at this position.
  # Assumes only the player can trigger this.
  #-----------------------------------------------------------------------------
  alias :th_region_events_events_xy :events_xy
  def events_xy(x, y)
    res = th_region_events_events_xy(x, y)
    region_id = region_id(x, y)
    region_event_id = @region_events[region_id]
    event = @events[region_event_id]
    if event
      res.push(event)
    end
    return res
  end
  
  def set_region_event(region_id, event_id)
    if @events[event_id]
      @region_events[region_id] = event_id
    end
  end
  
  def remove_region_event(region_id)
    @region_events.delete(region_id)
  end
end

class Game_Interpreter
  
  def change_region_event(region_id, event_id)
    $game_map.set_region_event(region_id, event_id)
  end
  
  def remove_region_event(region_id)
    $game_map.remove_region_event(region_id)
  end
end