=begin
#===============================================================================
 Title: Collision Map Overlay
 Author: Hime
 Date: Sep 8, 2013
--------------------------------------------------------------------------------
 ** Change log
 Sep 8, 2013
   - draws the collision map from the table directly
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
 
 This script draws the collision map on your screen while you are testplaying
 so that you can test whether they work or not.
 
--------------------------------------------------------------------------------
 ** Required
 
 Collision Maps
 (http://himeworks.com/2013/09/06/collision-maps/)
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this below Collision Maps and above Main.

--------------------------------------------------------------------------------
 ** Usage 
 
 Plug and play.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_CollisionMapOverlay"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Collision_Map_Overlay
    
    # How transparent the overlay will appear.
    # 0 is transparent, 255 is opaque
    Opacity = 128

#===============================================================================
# ** Rest of Script
#===============================================================================    
    @@drawCollisionMap = Win32API.new("System/CollisionMaps.dll", "drawCollisionTable", ["L", "L"], "")
    
    def self.draw_collision_map(map_id)
      colltable = Cache.collision_map(map_id)
      bmp = Bitmap.new(colltable.xsize, colltable.ysize)
      @@drawCollisionMap.call(bmp.__id__, colltable.__id__)
      return bmp
    end
  end
end

class Spriteset_Map
  
  alias :th_collision_maps_create_tilemap :create_tilemap
  def create_tilemap
    th_collision_maps_create_tilemap
    create_collision_map if $game_map.use_collision_map?
  end
  
  def create_collision_map
    @collision_map_sprite = Sprite.new
    bmp = TH::Collision_Map_Overlay.draw_collision_map($game_map.map_id)
    @collision_map_sprite.bitmap = Bitmap.new(bmp.width, bmp.height)
    @collision_map_sprite.bitmap.blt(0, 0, bmp, bmp.rect, TH::Collision_Map_Overlay::Opacity)
  end
  
  alias :th_collision_maps_update :update
  def update
    refresh_collision_map if @map_id != $game_map.map_id
    th_collision_maps_update
    update_collision_map if @collision_map_sprite
  end
  
  def refresh_collision_map
    dispose_collision_map
    create_collision_map
  end
  
  def update_collision_map
    @collision_map_sprite.ox = $game_map.display_x * 32
    @collision_map_sprite.oy = $game_map.display_y * 32
    @collision_map_sprite.update
  end
  
  alias :th_collision_maps_dispose :dispose
  def dispose
    th_collision_maps_dispose
    dispose_collision_map if @collision_map_sprite
  end
  
  def dispose_collision_map
    @collision_map_sprite.bitmap.dispose unless @collision_map_sprite.bitmap.disposed?
    @collision_map_sprite.dispose
  end
end