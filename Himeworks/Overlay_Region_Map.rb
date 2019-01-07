=begin
#===============================================================================
 Title: Region Overlay
 Author: Hime
 Date: Mar 5, 2013
--------------------------------------------------------------------------------
 ** Change log
 Mar 5, 2013
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
 
 This script overlays a region map over the game map.
 It is purely for fun and may be useful for debug purposes.
 
--------------------------------------------------------------------------------
 ** Usage
 
 Download the regionID spritesheet and place it in your Graphics/System folder.
 You can change region ID's for a given (x, y) position using a script call
 
    change_region_id(x, y, regionID)
 
 You can enable/disable the region map using a script call
    $game_system.region_map_disabled = true/false
    
 In the configuration, you can set the opacity and the Z-level of the region
 map. The Z-level determines whether it's drawn above or below characters.
    
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_RegionOverlay"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Region_Overlay
    
    # Don't draw region ID 0
    Ignore_Zero = true
    
    # The region map's opacity
    Opacity = 192
    
    # Under character sprites.
    Z_Level = 100
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================

class Game_Temp
  attr_accessor :region_map_updated
  
  alias :th_region_map_init :initialize
  def initialize
    th_region_map_init
    @region_map_updated = false
  end
end

class Game_System
  attr_accessor :region_map_disabled
  
  alias :th_region_map_init :initialize
  def initialize
    th_region_map_init
    @region_map_disabled = false
  end
end

class Game_Interpreter
  def change_region_id(x, y, rid)
    $game_map.data[x,y,3] |= 0x3F00
    $game_map.data[x,y,3] &= (rid << 8) | 0xF
    $game_temp.region_map_updated = true
  end
end

class Game_Map
  
  alias :th_region_map_setup :setup
  def setup(map_id)
    th_region_map_setup(map_id)
    $game_temp.region_map_updated = true
  end
end

class Spriteset_Map
  
  alias :th_region_map_update :update
  def update
    th_region_map_update
    update_region_map
  end
  
  alias :th_region_map_dispose :dispose
  def dispose
    th_region_map_dispose
    dispose_region_map
  end
  
  def create_region_map
    @region_map = Plane.new(@viewport1)
    @region_map.z = TH::Region_Overlay::Z_Level
    @region_map.bitmap = Bitmap.new($game_map.width * 32, $game_map.height * 32)
    sheet = Cache.system("sheet_regionID")
    rect = Rect.new(0,0, 32, 32)
    for x in 0...$game_map.width
      for y in 0...$game_map.height
        rid = $game_map.region_id(x, y)
        next if rid == 0 && TH::Region_Overlay::Ignore_Zero
        rect.x = (rid % 8) * 32
        rect.y = (rid / 8) * 32
        @region_map.bitmap.blt(x * 32, y * 32, sheet, rect, TH::Region_Overlay::Opacity)
      end
    end
    sheet.dispose
  end
  
  def update_region_map
    if $game_system.region_map_disabled 
      dispose_region_map
    elsif $game_temp.region_map_updated
      dispose_region_map
      create_region_map
      $game_temp.region_map_updated = false
    else
      create_region_map if @region_map.nil? || @region_map.disposed? || @region_map.bitmap.disposed?
      @region_map.ox = $game_map.display_x * 32
      @region_map.oy = $game_map.display_y * 32
    end
  end
  
  def dispose_region_map
    if @region_map && !@region_map.disposed?
      @region_map.bitmap.dispose if @region_map.bitmap 
      @region_map.dispose 
    end
  end
end