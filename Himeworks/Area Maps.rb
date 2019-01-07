=begin
#===============================================================================
 Title: Area Maps
 Author: Hime
 Date: Mar 31, 2013
--------------------------------------------------------------------------------
 ** Change log
 Mar 31
   - All events are now local to each area. They will only update if the
     player is in the area
 Mar 17, 2013
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
 ** Required
 
 Connected Maps
 http://himeworks.com/2013/03/17/connected-maps/
--------------------------------------------------------------------------------
 ** Description
 
 This is an add-on for Connected Maps. It allows you to treat each additional
 map as a separate area, rather than simply an extension to the current map.

 Each area has its own display name as well as list of encounters.
 Areas can be useful if you want to divide a large map into multiple
 different parts, while managing each part separately.

--------------------------------------------------------------------------------
 ** Usage
 
 Place this script below Materials, below Connected Maps, and above main.
 This script automatically converts any connected maps into an area map.
 
 Area maps have the following properties
   - display name
   - encounter list
   - encounter steps
   - battlebacks
   - bgm and bgs
 
 Unfortunately, area maps use the same tileset as the current map
 
 You can access the current area using a script call

    $game_map.area
    
 This will return a Game_Area object. You can get the area ID using
 
    $game_map.area.id
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_AreaMaps"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Area_Maps
    
    # All events are local to their own areas. They will only be updated
    # if the player is in the area. You can turn this off.
    Use_Area_Events = false
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
#-------------------------------------------------------------------------------
# An area is a section of the map. It is really just another map, but you can
# have different encounters and a unique area name
#-------------------------------------------------------------------------------
class Game_Area
  attr_reader :battleback1_name         # battle background (floor) filename
  attr_reader :battleback2_name         # battle background (wall) filename
  attr_reader :id       # the idea of the area
  attr_reader :x        # position of the start of the area
  attr_reader :y        
  
  def initialize(map_id, area_id, x, y)
    @map_id = map_id
    @id = area_id
    @x = x
    @y = y
    setup
  end
  
  def setup
    @map = load_data(sprintf("Data/Map%03d.rvdata2", @map_id)) 
    setup_battleback
  end
  
  def width
    @map.width
  end
  
  def height
    @map.height
  end
  
  def display_name
    @map.display_name 
  end
  
  def encounter_list
    @map.encounter_list
  end
  
  def encounter_step
    @map.encounter_step
  end
  
  def setup_battleback
    if @map.specify_battleback
      @battleback1_name = @map.battleback1_name
      @battleback2_name = @map.battleback2_name
    else
      @battleback1_name = nil
      @battleback2_name = nil
    end
  end
  
  def autoplay
    @map.bgm.play if @map.autoplay_bgm
    @map.bgs.play if @map.autoplay_bgs
  end
end

class Game_Map
  
  attr_reader :areas
  
  alias :th_area_maps_setup :setup
  def setup(map_id)
    @areas = [Game_Area.new(map_id, 1, 0, 0)]
    @area = @areas[0]
    @area_events = {}
    th_area_maps_setup(map_id)
  end
  
  alias :th_area_maps_setup_events :setup_events
  def setup_events
    th_area_maps_setup_events
    @area_events[1] = []
    @events.each_value {|event| @area_events[1].push(event)}
  end
  
  #-----------------------------------------------------------------------------
  # Treat the new map as an area
  #-----------------------------------------------------------------------------
  alias :th_area_maps_setup_connected_map :setup_connected_map
  def setup_connected_map(map_id, ox, oy, offset_x, offset_y)
    th_area_maps_setup_connected_map(map_id, ox, oy, offset_x, offset_y)
    area_id = @areas.size + 1
    area = Game_Area.new(map_id, area_id, ox + offset_x, oy + offset_y)
    @areas.push(area)
  end
  
  #-----------------------------------------------------------------------------
  # Store events in a hash indexed by area ID
  #-----------------------------------------------------------------------------
  alias :th_area_maps_setup_new_events :setup_new_events
  def setup_new_events(events)
    if TH::Area_Maps::Use_Area_Events    
      area_id = @areas.size
      @area_events[area_id] = []
      events.each do |i, event|
        @events[i] = Game_Event.new(@map_id, event)
        @area_events[area_id].push(@events[i])
      end
    else
      th_area_maps_setup_new_events(events)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Update only events in the area.
  #-----------------------------------------------------------------------------
  alias :th_area_maps_update_events :update_events
  def update_events
    if TH::Area_Maps::Use_Area_Events
      @area_events[@area.id].each {|event| event.update}
      @common_events.each {|event| event.update }
    else
      th_area_maps_update_events
    end
  end
  
  #-----------------------------------------------------------------------------
  # Return the current area's display name
  #-----------------------------------------------------------------------------
  alias :th_area_maps_display_name :display_name
  def display_name
    @area ? @area.display_name : th_area_maps_display_name
  end
  
  #-----------------------------------------------------------------------------
  # Encounters are retrieved from current area
  #-----------------------------------------------------------------------------
  alias :th_area_maps_encounter_list :encounter_list
  def encounter_list
    @area ? @area.encounter_list : th_area_maps_encounter_list
  end
  
  alias :th_area_maps_encounter_step :encounter_step
  def encounter_step
    @area ? @area.encounter_step : th_area_maps_encounter_step
  end
  
  alias :th_area_maps_battleback1_name :battleback1_name
  def battleback1_name
    @area ? @area.battleback1_name : th_area_maps_battleback1_name
  end
  
  alias :th_area_maps_battleback2_name :battleback2_name
  def battleback2_name
    @area ? @area.battleback2_name : th_area_maps_battleback2_name
  end
  
  alias :th_area_maps_setup_battleback :setup_battleback
  def setup_battleback
    @area ? @area.setup_battleback : th_area_maps_setup_battleback
  end
  
  alias :th_area_maps_autoplay :autoplay
  def autoplay
    @area ? @area.autoplay : th_area_maps_autoplay
  end
  
  #-----------------------------------------------------------------------------
  # New. Return the player's current area.
  #-----------------------------------------------------------------------------
  def area(x=$game_player.x, y=$game_player.y)
    new_area = @areas.reverse.detect {|area| x >= area.x && y >= area.y }
    @area = new_area  if @area != new_area
    @area
  end
end

class Scene_Map < Scene_Base
  
  alias :th_area_maps_start :start
  def start
    th_area_maps_start
    @area_id = $game_map.area.id
  end
  
  alias :th_area_maps_update :update
  def update
    if @area_id != $game_map.area.id
      @map_name_window.open 
      $game_map.autoplay
    end
    @area_id = $game_map.area.id
    th_area_maps_update
  end
end