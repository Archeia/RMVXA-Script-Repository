#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
# RPG Maker VX Ace Buildings System
#------------------------------------------------------------------------------
# Author: Mason Wheeler
#------------------------------------------------------------------------------
#
# Allows a map to contain custom map elements that can be copied from another map
# and placed dynamically.  These elements are known in this script as "buildings",
# though they may look like any sort of map element.
#
#------------------------------------------------------------------------------
#
# LICENSE
#
# The contents of this script are used with permission, subject to
# the Mozilla Public License Version 1.1 (the "License"); you may
# not use this file except in compliance with the License. You may
# obtain a copy of the License at
# http://www.mozilla.org/MPL/MPL-1.1.html
#
# Software distributed under the License is distributed on an
# "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
# implied. See the License for the specific language governing
# rights and limitations under the License.
#
#------------------------------------------------------------------------------
#
# SETUP
#
# Any map that contains buildings should be named "Buildings".  You can place as
# many buildings into the map as you want.  You define the coordinates for your
# buildings in the Notes section of the map.  Each line should begin with a
# name, a colon, then 4 numbers separated by commas, denoting the x, y, width,
# and height values of a Rect that encloses the building, like so:
#
# Custom House 1:0,0,16,20
#
# Every building should have a name that is unique throughout the entire project.
# (Duplicate names will throw an error during setup.)
#
# Copying a building will copy any Events within the rect, with a few
# restrictions.  Bear in mind that each copied Event is a *copy*, that will end
# up somewhere other than the original map.  Therefore, nothing in the Rvent's
# script should reference elements of the original map, including other events
# or map coordinates.  If your building contains a Transfer Player command to an
# indoor location which has a door leading back out, this will need to save the
# player's coordinates to variables for the return teleport to use.
#
#------------------------------------------------------------------------------
#
# USAGE
#
# This script defines a global object named $custom_buildings whose data property
# holds information about building locations.  To place buildings, call the
# add_building method on it.
#
# The method takes 5 arguments: (map, name, x, y, id).  The map value is the ID
# number of the map on which the building should be placed.  The name is a
# string, the name of the building.  It should match a building name as defined
# above.  Next are the X and Y coordinates on the destination map where the
# too-left corner of the building should begin.  The final value is a building
# ID, a custom tag that will be added to any Event copied with the building as
# its "building_id" property, which can be used in scripts to distinguish
# between two copies of the same original Event.  It should be unique within
# each map, and will raise an error if it is not.

# The building id value is also used in the remove_building method, to locate
# the buiding to be removed.
#
# $custom_buildings is scanned for buildings each time a map is setup.
# Therefore, changing the entry for a map while on that map will have no effect
# until the player leaves and returns to it or Buildings.map_refresh is called,
# which causes the map to reload itself.
#
# The Buildings.event_created(event) routine is provided as a convenient hook
# for other scripts to override.  Each time an event is copied as part of
# placing a building, this routine will be called, passing the new Game_Event
# object to it.
#
#------------------------------------------------------------------------------
#
# COMPATIBILITY
#
# This script can be used with RMX-OS.  It should be placed in the Materials
# section below the RMX-OS script, if applicable.
#
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

class Building_Data
  attr_reader :data
  attr_reader :events
  attr_reader :coords
  
  def initialize(data, events, coords)
      @data = data
      @events = events
      @coords = coords
  end
end

class Scene_Title
  alias title_start start
  def start
    title_start
    Buildings.setup_houses
  end    
end

class Game_Event
  attr_accessor :building_id
  attr_reader :event
  
  alias ge_initialize initialize
  def initialize(map_id, event)
    ge_initialize(map_id, event)
    building_id = -1
  end
end

module DataManager
  
  class << self
    alias DM_save make_save_contents
    alias DM_load extract_save_contents
  end
  
  #--------------------------------------------------------------------------
  # * Create Save Contents
  #--------------------------------------------------------------------------
  def self.make_save_contents
    contents = DM_save
    contents[:custom_buildings] = $custom_buildings
    contents
  end
  #--------------------------------------------------------------------------
  # * Extract Save Contents
  #--------------------------------------------------------------------------
  def self.extract_save_contents(contents)
    DM_load(contents)
    $custom_buildings = contents[:custom_buildings]
  end
  
end

module Buildings

  class Custom_Buildings
    attr_accessor :data
    
    def initialize
      @data = {}
    end
    
    def add_building(map, name, x, y, id)
      mapdata = @data[map]
      if mapdata.nil?
        mapdata = {}
        @data[map] = mapdata
      end
      raise "Duplicate ID #{id} on map # #{map}" if mapdata.has_key?(id)
      mapdata[id] = [name, x, y]
    end
    
    def remove_building(map, id)
      mapdata = @data[map]
      unless mapdata.nil?
        mapdata.delete(id)
        @data.delete(map) if mapdata.empty?
      end
    end
  end
  
  def self.setup_houses
    $houses = {}
    houses = $data_mapinfos.find_all{|id, map| map.name == "Buildings"}.map{|a| a[0]}
    houses.each do |id|
      mapinfo = load_data(sprintf("Data/Map%03d.rvdata2", id))
      mapinfo.note.split('\n').each do |line|
        name, values = line.split(':')
        coords = values.split(',').map{|v| v.to_i}.to_a
        rect = Rect.new(coords[0], coords[1], coords[2], coords[3])
        raise "Duplite building name #{name}" if $houses[name]
        $houses[name] = Building_Data.new(mapinfo.data, mapinfo.events, rect)
      end
    end
  end
  
  def self._blit_house(map, house_id, left, top, building_id)
    house = $houses[house_id]
    data = house.data
    coords = house.coords
    coords.height.times do |y|
      y2 = y + top + coords.y
      coords.width.times do |x|
        x2 = x + left + coords.x
        4.times{|z| map.data[x2, y2, z] = data[x, y, z]}
      end
    end
    
    house.events.each do |i, event|
      if (event.x >= coords.x) && (event.x < coords.x + coords.width) && (event.y >= coords.y) && (event.y < coords.y + coords.height)
        _blit_house_event(map, i, event, left, top, building_id, coords)
      end
    end
  end

  def self._blit_house_event(map, i, event, left, top, building_id, coords)
    event_id = map.events.size + 1
    newEvent = Game_Event.new(map.map_id, event)
    newEvent.moveto(event.x + left - coords.x, event.y + top - coords.y)
    newEvent.id = event_id
    newEvent.building_id = building_id
    map.events[event_id] = newEvent
    event_created(newEvent)
  end

  def self.map_refresh
    $game_map.setup($game_map.map_id)
    $game_player.center($game_player.x, $game_player.y)
    $game_player.make_encounter_count
  end

  def self.event_created(event) #override this as needed
  end
end

class Game_Map
  $custom_buildings = Buildings::Custom_Buildings.new
  
  alias gm_setup setup
  def setup(map_id)
    gm_setup(map_id)
    cust = $custom_buildings.data[map_id]
    if cust
      cust.each do |id, value|
        map, left, top = value
        Buildings._blit_house(self, map, left, top, id)
      end
    end
  end
end

def this_event
  $game_map.events[$game_map.interpreter.event_id]
end

if defined? RMXOS
  
  class Scene_Servers
    alias servers_setup setup_scene
    def setup_scene
      servers_setup
      Buildings.setup_houses
    end    
  end
  
  module RMXOS
    module Options
      SAVE_CONTAINERS.push('$custom_buildings')
      SAVE_DATA[Buildings::Custom_Buildings] = ['@data']
    end
  end