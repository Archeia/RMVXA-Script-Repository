=begin
#===============================================================================
 Title: Overlay - Passage Map
 Author: Hime
 Date: Mar 9, 2013
--------------------------------------------------------------------------------
 ** Change log
 Mar 9, 2013
   - updated to support looping maps
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
 
 This script overlays a passage map over the game map.
 The arrows indicate the 4-dir passage settings for that tile.
 
--------------------------------------------------------------------------------
 ** Usage
 
 Download the regionID spritesheet and place it in your Graphics/System folder.
 
 You can choose which sprites you want to use in the configuration.
 You can also add your own by adding additional rows to the image.
 
 You can enable/disable the passage map using a script call
    $game_system.passage_map_disabled = true/false
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_OverlayPassageMap"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Passage_Overlay
    
    # Which sprites do you want to use.
    # 1 is the first row, 2 is the second row, ...
    Image_Type = 4
    
    # The passage map's opacity
    Opacity = 128
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================

class Game_Temp
  attr_accessor :passage_map_updated
  
  alias :th_passage_map_init :initialize
  def initialize
    th_passage_map_init
    @passage_map_updated = false
  end
end

class Game_System
  attr_accessor :passage_map_disabled
  
  alias :th_passage_map_init :initialize
  def initialize
    th_passage_map_init
    @passage_map_disabled = false
  end
end

class Game_Map
  
  alias :th_passage_map_setup :setup
  def setup(map_id)
    th_passage_map_setup(map_id)
    $game_temp.passage_map_updated = true
  end
end

class Spriteset_Map
  
  alias :th_passage_map_update :update
  def update
    th_passage_map_update
    update_passage_map
  end
  
  alias :th_passage_map_dispose :dispose
  def dispose
    th_passage_map_dispose
    dispose_passage_map
  end
  
  def draw_passage_map
    bitmap = Bitmap.new($game_map.width * 32, $game_map.height * 32)
    sheet = Cache.system("passage_4dir")
    rect = Rect.new(0,(TH::Passage_Overlay::Image_Type - 1) * 32, 32, 32)
    for x in 0...$game_map.width
      for y in 0...$game_map.height
        2.downto(0) {|z|
          tile_id = $game_map.tile_id(x, y, z)
          if tile_id != 0
            index = $game_map.tileset.flags[tile_id] & 0x0F
            rect.x = (index) * 32
            bitmap.blt(x * 32, y * 32, sheet, rect, TH::Passage_Overlay::Opacity)
            break
          end
        }
      end
    end
    sheet.dispose
    return bitmap
  end
  
  def create_passage_map
    @passage_map = Plane.new(@viewport3)
    @passage_map.bitmap = draw_passage_map
  end
  
  def update_passage_map
    if $game_system.passage_map_disabled 
      dispose_passage_map if @passage_map
    else
      create_passage_map if @passage_map.nil? || @passage_map.disposed?
      @passage_map.ox = $game_map.display_x * 32
      @passage_map.oy = $game_map.display_y * 32
    end
  end
  
  def dispose_passage_map
    if @passage_map && !@passage_map.disposed?
      @passage_map.bitmap.dispose if @passage_map.bitmap
      @passage_map.dispose 
    end
  end
end