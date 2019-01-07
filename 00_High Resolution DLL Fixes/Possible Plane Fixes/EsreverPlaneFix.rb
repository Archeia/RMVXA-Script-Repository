#==============================================================================
# ▼ Viewports/Map Fix for Modified RGSS300.dll File
#   Origin of Code: Yanfly Engine Ace - Ace Core Engine v1.06
# -- Last Updated: 2011.12.26
# -- Level: Easy, Normal
# -- Requires: n/a
# 
#==============================================================================

Graphics.resize_screen(1024,768)

#==============================================================================
# ■ Game_Map
#==============================================================================

class Game_Map

  #--------------------------------------------------------------------------
  # overwrite method: scroll_down
  #--------------------------------------------------------------------------
  def scroll_down(distance)
    if loop_vertical?
      @display_y += distance
      @display_y %= @map.height * 256
      @parallax_y += distance
    else
      last_y = @display_y
      dh = Graphics.height > height * 32 ? height : screen_tile_y
      @display_y = [@display_y + distance, height - dh].min
      @parallax_y += @display_y - last_y
    end
  end

  #--------------------------------------------------------------------------
  # overwrite method: scroll_right
  #--------------------------------------------------------------------------
  def scroll_right(distance)
    if loop_horizontal?
      @display_x += distance
      @display_x %= @map.width * 256
      @parallax_x += distance
    else
      last_x = @display_x
      dw = Graphics.width > width * 32 ? width : screen_tile_x
      @display_x = [@display_x + distance, width - dw].min
      @parallax_x += @display_x - last_x
    end
  end

end # Game_Map

#==============================================================================
# ■ Spriteset_Map
#==============================================================================

class Spriteset_Map

  #--------------------------------------------------------------------------
  # overwrite method: create_viewports
  #--------------------------------------------------------------------------
  def create_viewports
    if Graphics.width > $game_map.width * 32 && !$game_map.loop_horizontal?
      dx = (Graphics.width - $game_map.width * 32) / 2
    else
      dx = 0
    end
    dw = [Graphics.width, $game_map.width * 32].min
    dw = Graphics.width if $game_map.loop_horizontal?
    if Graphics.height > $game_map.height * 32 && !$game_map.loop_vertical?
      dy = (Graphics.height - $game_map.height * 32) / 2
    else
      dy = 0
    end
    dh = [Graphics.height, $game_map.height * 32].min
    dh = Graphics.height if $game_map.loop_vertical?
    @viewport1 = Viewport.new(dx, dy, dw, dh)
    @viewport2 = Viewport.new(dx, dy, dw, dh)
    @viewport3 = Viewport.new(dx, dy, dw, dh)
    @viewport2.z = 50
    @viewport3.z = 100
  end

  #--------------------------------------------------------------------------
  # new method: update_viewport_sizes
  #--------------------------------------------------------------------------
  def update_viewport_sizes
    if Graphics.width > $game_map.width * 32 && !$game_map.loop_horizontal?
      dx = (Graphics.width - $game_map.width * 32) / 2
    else
      dx = 0
    end
    dw = [Graphics.width, $game_map.width * 32].min
    dw = Graphics.width if $game_map.loop_horizontal?
    if Graphics.height > $game_map.height * 32 && !$game_map.loop_vertical?
      dy = (Graphics.height - $game_map.height * 32) / 2
    else
      dy = 0
    end
    dh = [Graphics.height, $game_map.height * 32].min
    dh = Graphics.height if $game_map.loop_vertical?
    rect = Rect.new(dx, dy, dw, dh)
    for viewport in [@viewport1, @viewport2, @viewport3]
      viewport.rect = rect
    end
  end

end # Spriteset_Map

#==============================================================================
# ■ Scene_Map
#==============================================================================

class Scene_Map < Scene_Base

  #--------------------------------------------------------------------------
  # alias method: post_transfer
  #--------------------------------------------------------------------------
  alias scene_map_post_transfer_ace post_transfer
  def post_transfer
    @spriteset.update_viewport_sizes
    scene_map_post_transfer_ace
  end

end # Scene_Map

#==============================================================================
# ■ Game_Event
#==============================================================================

class Game_Event < Game_Character
  
  #--------------------------------------------------------------------------
  # overwrite method: near_the_screen?
  #--------------------------------------------------------------------------
  def near_the_screen?(dx = nil, dy = nil)
    dx = [Graphics.width, $game_map.width * 256].min/32 - 5 if dx.nil?
    dy = [Graphics.height, $game_map.height * 256].min/32 - 5 if dy.nil?
    ax = $game_map.adjust_x(@real_x) - Graphics.width / 2 / 32
    ay = $game_map.adjust_y(@real_y) - Graphics.height / 2 / 32
    ax >= -dx && ax <= dx && ay >= -dy && ay <= dy
  end
  
end # Game_Event