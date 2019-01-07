=begin
#===============================================================================
 Title: Collision Maps
 Author: Hime
 Date: Sep 6, 2013
--------------------------------------------------------------------------------
 ** Change log
 Sep 8, 2013
   - processes table in dll now
 Sep 6, 2013
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
 
 This script allows you to replace your tile passage settings with a collision
 map. Collision maps are optional; a map can use the default tile passage
 settings. However, you can only choose between one or the other.
 
 The collision map is straightforward: it is an image the size of your map.
 Anywhere that is colored red is cannot be passed. The collision map can be
 created in any image editor of your choice.
 
 This is a very simple collision map and only supports two passage settings:
 Passable, not passable.

 -------------------------------------------------------------------------------
 ** Required
 
 CollisionMaps.dll
 (http://himeworks.com/2013/09/06/collision-maps/)
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this below Materials and above Main.
 Place the CollisionMaps.dll in your System folder

--------------------------------------------------------------------------------
 ** Usage 
 
 -- Setting up passage settings --
 
 If you want a map to use a collision map, note-tag it with

   <collision map>
   
 It will automatically use the associated collision map.
 
 -- Creating collision maps --
 
 To create your collision maps
 
 1. Take a mapshot of your map and open it in an image editor.
 2. Create a layer on top of your image, which will be your collision map
 3. Anywhere that is not passable will be red. Anywhere that is passable will
    be black.
 4. Save the collision map and place it in the Collision Maps folder with
    the appropriate filename
 
 By default, the collision maps are stored in the following folder
 
   Graphics/CollisionMaps
   
 The name of each collision map contains the map ID as follows
 
   map001
   map002
  
 And so on. You can customize these in the configuration if needed.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_CollisionMaps"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Collision_Maps
    
    # The width and height of your tiles. This is really only used for
    # optimization purposes
    Tile_Width = 32
    Tile_Height = 32
    
    # The format of the filenames. You must include the map ID
    Path_Name = "Graphics/CollisionMaps/map%03d"
#===============================================================================
# ** Rest of Script
#===============================================================================    
    Regex = /<collision[-_ ]map>/i
    #---------------------------------------------------------------------------
    # This is pretty terrible, but it does the job.
    #---------------------------------------------------------------------------
    @@makeCollisionTable = Win32API.new("System/CollisionMaps.dll", "makeCollisionTable", ["L", "L", "L", "L"], "")
    
    def self.load_collision_map(map_id)
      path = sprintf(Path_Name, map_id)
      bmp = Bitmap.new(path)
      colltable = Table.new(bmp.width, bmp.height, 1)
      @@makeCollisionTable.call(bmp.__id__, colltable.__id__, Tile_Width, Tile_Height)
      return colltable
    end
  end
end

#-------------------------------------------------------------------------------
# You can choose to use a collision map or not
#-------------------------------------------------------------------------------
module RPG
  class Map
    
    def use_collision_map?
      load_notetag_collision_maps if @use_collision_map.nil?
      return @use_collision_map
    end
    
    def load_notetag_collision_maps
      res = self.note.match(TH::Collision_Maps::Regex)
      @use_collision_map = !res.nil?
    end
  end
end

#-------------------------------------------------------------------------------
# We don't want to do load it too many times cause our pure ruby implementation
# is really really slow!
#-------------------------------------------------------------------------------
module Cache
  
  def self.collision_map(map_id)
    @collision_map_cache ||= {}
    return @collision_map_cache[map_id] if @collision_map_cache[map_id]
    return @collision_map_cache[map_id] = TH::Collision_Maps.load_collision_map(map_id)
  end
end

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class Game_Map
  
  def use_collision_map?
    @map.use_collision_map?
  end
  
  alias :th_collision_maps_check_passage :check_passage
  def check_passage(x, y, bit)
    if use_collision_map?
      x = x * TH::Collision_Maps::Tile_Width
      y = y * TH::Collision_Maps::Tile_Height
      return Cache.collision_map(@map_id)[x, y, 0] == 0
    else
      th_collision_maps_check_passage(x, y, bit)
    end
  end
end