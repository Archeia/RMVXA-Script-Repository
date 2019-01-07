=begin
#===============================================================================
 Title: Connected Maps
 Author: Hime
 Date: Jul 5, 2015
--------------------------------------------------------------------------------
 ** Change log
 Jul 5, 2015
   - offset transfer location only for current map
 Nov 2, 2014
   - updated more event commands. Locations need to be offset and map ID needs
     to be changed
 Apr 2, 2013
   - added note-tag shortcut for width and height
 Mar 17, 2013
   - updated to support area map addon
   - combined encounter lists
   - fixed bug where transferring was not done correctly
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
 
 This script allows you to connect maps together, providing a seamless
 transition from one map to another. You can create a map in separate parts
 and then connect it all together to produce one large map. This allows you
 to exceed the 500x500 limit imposed by the editor.

--------------------------------------------------------------------------------
 ** Usage
 
 Place this script below Materials and above Main.
 
 To connect a map to another, write a note-tag in the map object
 
   <connect map: map_id offset_x offset_y>
   <connect map: map_id offset_x offset_y recurse_limit>
   
 The map_id is the ID of the map that you want to the current map.
 Offset_x and Offset_y is the position that the new map will be placed.
 
 You can use the letter "w" for offset_x to mean the width of the map.
 You can use the letter "h" for offset_y to mean the height of the map.
 
 The recurse_limit is special and will be described later.
 
 -- Positioning modes --
 
 There are two types of map connecting modes in this script.

 1. Absolute connection.
    All offsets are specified relative to the current map, where the
    origin is located at (0, 0), the upper-left corner of the current map.
 
 2. Recursive connection.
    All offsets are specified relative to the parent map, where the
    origin is the position of the upper-left corner of the parent map.
    
 If you are using recursive mode, you can use the recurse limit in the note-tag.
  
 The recurse limit is meant to save you some effort when connecting maps.
 For example, suppose you have the following connection between two maps, A
 and B
 
 A --> B
 B --> A
 
 The recurse limit allows you to specify how many times these connections
 should repeat. For example, if recurse limit is 2, then the connection is
 allowed to repeat twice
 
 A --> B --> A --> B --> A -> B -> A
 
 There are some rules to follow when connecting maps
 
 1. You start from the top-left, and connect maps to the right or below. You
    cannot connect maps to the left or above, so plan carefully.
    
 2. Maps that do not have equal dimensions will leave empty black squares that
    are not passable.
    
 3. Events can only reference events on the same map. They cannot reference
    events from other maps.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_ConnectedMaps"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Connected_Maps
    
    # Recursive mode allows you to connect maps relative to each other.
    # Set this to false if youp refer absolute positioning. Though I think
    # it is easier to leave it as recursive.
    Recursive_Mode = true
    
    Regex = /<connect[-_ ]map: (\d+)\s+(w|-?\d+)\s+(h|-?\d+)\s*(\d+)?>/im
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  class Map
    
    def connected_maps
      return @connected_maps unless @connected_maps.nil?
      load_notetag_connected_maps
      return @connected_maps
    end
    
    def load_notetag_connected_maps
      @connected_maps = []
      res = self.note.scan(TH::Connected_Maps::Regex)
      res.each {|result|
        map_id = result[0].to_i
        offset_x = result[1] ? (result[1].downcase == "w" ? self.width : result[1].to_i) : 0
        offset_y = result[2] ? (result[2].downcase == "h" ? self.height : result[2].to_i) : 0
        recurse_limit = result[3] ? result[3].to_i : 1
        @connected_maps.push([map_id, offset_x, offset_y, recurse_limit])
      }
    end  
  end
  
  class Event
    def update_for_map_connection(orig_map_id, ofs_x, ofs_y, ofs_id)
      @pages.each {|page|
        update_page_events(page, orig_map_id, ofs_x, ofs_y, ofs_id)
      }
    end
    
    def update_page_events(page, orig_map_id, ofs_x, ofs_y, ofs_id)
      p [orig_map_id, ofs_x, ofs_y, ofs_id]
      page.list.each {|cmd|
        params = cmd.parameters
        case cmd.code
        # cond branch, character (0, 1, 2, ...)
        when 111 
          params[1] += offset if params[0] == 6 && params[1] > 0
        
        # variables, character (0, 1 2, ... )
        when 122 
          params[5] += offset if params[4] == 5 && params[5] > 0
          
        # player transfer. Need to update transfer map and offset location
        when 201
          if params[0] == 0
            if orig_map_id == params[1]
              params[1] = $game_map.map_id 
              params[2] += ofs_x
              params[3] += ofs_y
            end
          end
          
        # set vehicle location. Need to offset location
        when 202
          if params[1] == 0
            if orig_map_id == params[2]
              params[2] = $game_map.map_id 
              params[3] += ofs_x
              params[4] += ofs_y
            end
          end    
        # set event location
        when 203
          params[0] += offset if params[0] > 0
          # swap with character
          if params[1] == 2 && params[2] > 0
            params[2] += offset 
            
          # move to position by direct designation
          elsif params[1] == 0
            params[2] += ofs_x
            params[3] += ofs_y
          end
        when 205, 212, 213 # move route, animation, and balloon
          params[0] += offset if params[0] > 0
          
        # get location info. Need to offset location
        when 285
          if params[2] == 0
            params[3] += ofs_x
            params[4] += ofs_y
          end
        end               
      }
    end
  end
end

class Game_Map
  
  alias :th_connected_maps_setup :setup
  def setup(map_id)
    @new_width = nil
    @new_height = nil
    th_connected_maps_setup(map_id)
    add_connected_maps(@map, {})
    @map.width ||= @new_width 
    @map.height ||= @new_height
  end
  
  alias :th_connected_maps_width :width
  def width
    @new_width || th_connected_maps_width
  end
  
  alias :th_connected_maps_height :height
  def height
    @new_height || th_connected_maps_height
  end
  
  #-----------------------------------------------------------------------------
  # Connect maps together with the current map. The recursive limit is a global
  # limit, not a local limit, and is based on the number of times a map has
  # been visited. TO-DO: implement as BFS...
  #-----------------------------------------------------------------------------
  def add_connected_maps(map, visited, ox=0, oy=0)
    map.connected_maps.each {|map_id, offset_x, offset_y, recurse_limit|
      visited[map_id] ||= 1
      return if visited[map_id] > recurse_limit
      visited[map_id] += 1
      conmap = load_data(sprintf("Data/Map%03d.rvdata2", map_id)) 
      setup_connected_map(map_id, ox, oy, offset_x, offset_y)
      combine_maps(conmap.data, ox + offset_x, oy + offset_y)
      combine_encounters(conmap.encounter_list)
      combine_events(conmap.events, map_id, ox + offset_x, oy + offset_y, @events.keys.max || 0)
      add_connected_maps(conmap, visited, ox + offset_x, oy + offset_y)
    }
  end
  
  #-----------------------------------------------------------------------------
  # Setup map metadata
  #-----------------------------------------------------------------------------
  def setup_connected_map(map_id, ox, oy, offset_x, offset_y)
  end
  
  #-----------------------------------------------------------------------------
  # Extend the current map's tilemap with the new map's tile map. Resize
  # only if needed. Remember that we are always connecting to the right or
  # bottom.
  #-----------------------------------------------------------------------------
  def combine_maps(new_data, ox, oy)
    new_x = ox + new_data.xsize >= width ? ox + new_data.xsize : width
    new_y = oy + new_data.ysize >= height ? oy + new_data.ysize : height
    @new_width =  new_x
    @new_height = new_y
    @map.data.resize(new_x, new_y, @map.data.zsize)
    for z in 0 ... 4
      for x in 0 ... new_data.xsize
        for y in 0 ... new_data.ysize
          next if ox + x < 0 || oy + y < 0
          @map.data[ox + x, oy + y, z] = new_data[x, y, z]
        end
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Extend the current map's encounters with the new map's events, updating all
  # events and event references as necessary
  #-----------------------------------------------------------------------------
  def combine_encounters(new_enc_list)
    @map.encounter_list.concat(new_enc_list)
  end
  
  #-----------------------------------------------------------------------------
  # Extend the current map's events with the new map's events, updating all
  # events and event references as necessary
  #-----------------------------------------------------------------------------
  def combine_events(events, orig_map_id, ofs_x, ofs_y, ofs_evt)
    new_events = {}
    events.each {|id, event|
      new_id = id + ofs_evt
      event.id = new_id
      event.x += ofs_x
      event.y += ofs_y
      event.update_for_map_connection(orig_map_id, ofs_x, ofs_y, ofs_evt)
      @map.events[new_id] = event
      new_events[new_id] = event
    }
    setup_new_events(new_events)
  end
  
  #-----------------------------------------------------------------------------
  # Set up our new events
  #-----------------------------------------------------------------------------
  def setup_new_events(events)
    events.each do |i, event|
      @events[i] = Game_Event.new(@map_id, event)
    end
  end
end