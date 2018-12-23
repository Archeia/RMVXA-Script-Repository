#==============================================================================
# ** TDS Region Display
#    Ver: 1.3
#------------------------------------------------------------------------------
#  * Description:
#  This script allows you to see Region tiles in your game by pressing F8.
#------------------------------------------------------------------------------
#  * Features: 
#  Viewing Region tiles.
#------------------------------------------------------------------------------
#  * Instructions:
#  Just put it in your game and pres the F8 key while testing the game to toggle
#  the visibility of Region tiles.
#------------------------------------------------------------------------------
#  * Notes:
#  None.
#------------------------------------------------------------------------------
# WARNING:
#
# Do not release, distribute or change my work without my expressed written 
# consent, doing so violates the terms of use of this work.
#
# If you really want to share my work please just post a link to the original
# site.
#
# * Not Knowing English or understanding these terms will not excuse you in any
#   way from the consequenses.
#==============================================================================
# * Import to Global Hash *
#==============================================================================
($imported ||= {})[:TDS_Region_Display] = true

#==============================================================================
# ** Cache
#------------------------------------------------------------------------------
#  This module loads graphics, creates bitmap objects, and retains them.
# To speed up load times and conserve memory, this module holds the
# created bitmap object in the internal hash, allowing the program to
# return preexisting objects when the same bitmap is requested again.
#==============================================================================

module Cache
  #--------------------------------------------------------------------------
  # * Create Region Tileset
  #--------------------------------------------------------------------------
  def self.create_region_tileset_bitmap
    @cache ||= {}
    # If Cache Does not have Region Tileset Key
    if !@cache.has_key?(:region_tileset) or region_tileset_bitmap.disposed?
      # Create Region Tileset Bitmap
      bitmap = Bitmap.new(256, 544) ; bitmap.font.bold = true
      # Go Through 64 Region Tiles (2 times for over and under tiles)
      128.times {|i| 
        id = i % 64
        # Get Region Colors and X & Y Drawing Coordinates
        colors = region_colors(id, 110) ; x = (i % 8) * 32 ; y = (i / 8) * 32
        # Draw Region Color Rect
        bitmap.fill_rect(x, y, 32, 32, colors.at(0))
        bitmap.fill_rect(x + 3, y + 3, 26, 26, colors.at(1))
        # Draw Region ID
        bitmap.draw_text(x, y, 32, 32, id, 1) if id != 0
      }
      # Get Region Colors and X & Y Drawing Coordinates
      colors = region_colors(64, 110) ; x = (64 % 8) * 32 ; y = (64 / 8) * 32
      # Draw Region Color Rect
      bitmap.fill_rect(x, y, 32, 32, colors.at(0))
      bitmap.fill_rect(x + 3, y + 3, 26, 26, colors.at(1))      
      # Add Region Tileset bitmap to Cache
      @cache[:region_tileset] = bitmap
    end
  end
  #--------------------------------------------------------------------------
  # * Get Region Tileset Bitmap
  #--------------------------------------------------------------------------
  def self.region_tileset_bitmap ; @cache[:region_tileset] end
  #--------------------------------------------------------------------------
  # * Get Region Colors (Outer, Inner)
  #     id    : region id
  #     alpha : color alpha value
  #--------------------------------------------------------------------------
  def self.region_colors(id, alpha = 110)
    return [Color.new(0, 0, 0, alpha),  Color.new(0, 0, 0, alpha)] if id > 63
    case id % 12
    when 0  ; [Color.new(255, 68,  164, alpha),  Color.new(255, 52,  156, alpha)]
    when 1  ; [Color.new(255, 67,  67,  alpha),  Color.new(255, 51,  51,  alpha)]
    when 2  ; [Color.new(255, 161, 68,  alpha),  Color.new(255, 153, 52,  alpha)]
    when 3  ; [Color.new(255, 252, 68,  alpha),  Color.new(255, 252, 52,  alpha)]
    when 4  ; [Color.new(164, 255, 68,  alpha),  Color.new(156, 255, 52,  alpha)]
    when 5  ; [Color.new(68,  255, 68,  alpha),  Color.new(52,  255, 52,  alpha)]
    when 6  ; [Color.new(68,  255, 161, alpha),  Color.new(52,  255, 153, alpha)]
    when 7  ; [Color.new(68,  255, 252, alpha),  Color.new(52,  255, 252, alpha)]
    when 8  ; [Color.new(68,  164, 255, alpha),  Color.new(52,  156, 255, alpha)]
    when 9  ; [Color.new(68,  72,  255, alpha),  Color.new(52,  57,  255, alpha)]
    when 10 ; [Color.new(156, 68,  255, alpha),  Color.new(148, 52,  255, alpha)]
    when 11 ; [Color.new(252, 68,  255, alpha),  Color.new(252, 52,  255, alpha)]
    end 
  end    
end


#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
#  This class brings together map screen sprites, tilemaps, etc. It's used
# within the Scene_Map class.
#==============================================================================

class Spriteset_Map
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader :region_tilemap                                # Region Tilemap
  #--------------------------------------------------------------------------
  # * Alias Listing
  #--------------------------------------------------------------------------
  alias tds_region_display_spriteset_map_initialize         initialize
  alias tds_region_display_spriteset_map_refresh_characters refresh_characters
  alias tds_region_display_spriteset_map_dispose            dispose  
  alias tds_region_display_spriteset_map_update             update 
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(*args, &block)
    # Run Original Method
    tds_region_display_spriteset_map_initialize(*args, &block)
    # Create Region Display Tilemap
    create_region_display_tilemap
  end
  #--------------------------------------------------------------------------
  # * Refresh Characters
  #--------------------------------------------------------------------------
  def refresh_characters(*args, &block)    
    # Run Original Method
    tds_region_display_spriteset_map_refresh_characters(*args, &block)
    # Previous Visibility of Region Tilemap
    prev_vis = @region_tilemap.visible
    # Dispose of Region Tilemap & Recreate it
    dispose_region_tilemap ; create_region_display_tilemap 
    # Set Region Tilemap Visibility
    @region_tilemap.visible = prev_vis
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update(*args, &block)
    # Run Original Method
    tds_region_display_spriteset_map_update(*args, &block)
    # Update Region Tilemap
    update_region_tilemap
  end
  #--------------------------------------------------------------------------
  # * Free
  #--------------------------------------------------------------------------
  def dispose(*args, &block)
    # Run Original Method
    tds_region_display_spriteset_map_dispose(*args, &block) 
    # Dispose of Region Tilemap
    dispose_region_tilemap
  end
  #--------------------------------------------------------------------------
  # * Free Region Tilemap
  #--------------------------------------------------------------------------
  def dispose_region_tilemap ; @region_tilemap.dispose end  
  #--------------------------------------------------------------------------
  # * Create Region Display Tilemap
  #--------------------------------------------------------------------------
  def create_region_display_tilemap
    # Create Region Tileset
    Cache.create_region_tileset_bitmap    
    # Create Region Tilemap
    @region_tilemap = Tilemap.new(@viewport1)
    @region_tilemap.map_data = $game_map.data.dup
    @region_tilemap.flags = Table.new(8192)
    # Make Region Tilemap Invisible
    @region_tilemap.visible = false
    # Set Region Tilemap Flags (Over Character [?])
    64.upto(128) {|n| @region_tilemap.flags[n] = 0x10} 
    # Go Through Game Map Tiles
    $game_map.data.xsize.times {|x|
      $game_map.data.ysize.times {|y|
        # Clear Region Tilemap Info
        4.times {|z| @region_tilemap.map_data[x, y, z] = 0}
        # Get Region ID
        region_id = $game_map.region_id(x, y)
        # Get Passability Flags
        flag1 = $game_map.tileset.flags[$game_map.data[x, y, 2]]         
        # If Region ID is 0 or more
        if region_id > 0
          next @region_tilemap.map_data[x, y, 2] = 64 + region_id if flag1 > 16 and flag1 & 0x10 != 0
          @region_tilemap.map_data[x, y, 2] = region_id          
        else                    
          next @region_tilemap.map_data[x, y, 2] = 64 if flag1 > 16 and flag1 & 0x10 != 0
          next @region_tilemap.map_data[x, y, 1] = 64        
        end       
      }
    }
    # Set Region Tilemap Bitmap (Tile B)
    @region_tilemap.bitmaps[5] = Cache.region_tileset_bitmap
    # Update Region Tilemap
    update_region_tilemap
  end
  #--------------------------------------------------------------------------
  # * Update Region Tilemap
  #--------------------------------------------------------------------------
  def update_region_tilemap
    # Return if Region Tilemap is nil
    return if @region_tilemap.nil?
    # Set Region Tilemap OX & OY Values
    @region_tilemap.ox = $game_map.display_x * 32
    @region_tilemap.oy = $game_map.display_y * 32    
  end
end


#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  This class performs the map screen processing.
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # * Alias Listing
  #--------------------------------------------------------------------------
  alias tds_region_display_scene_map_update                            update
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update(*args, &block)
    # Update Region Display Input
    update_region_display_input
    # Run Original Method
    tds_region_display_scene_map_update(*args, &block)
  end
  #--------------------------------------------------------------------------
  # * Update Region Display Input
  #--------------------------------------------------------------------------
  def update_region_display_input
    # If Input Trigger F8
    if $TEST and Input.trigger?(:F8)
      # Toggle Region Tilemap Visibility
      @spriteset.region_tilemap.visible = !@spriteset.region_tilemap.visible
    end
  end  
end