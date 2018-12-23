##------
## Display rounding error fix created by Neon Black.
##
## When certain slow display panning speeds are used, events will improperly
## round floating values to determine their position on screen.  This causes
## them to appear off from the tilemap by a single pixel.  Though minor this is
## noticable.  This snippet fixes this behaviour.
##
## This snippet may be used in any project.
##
## -- Original Topic:
## http://forums.rpgmakerweb.com/index.php?/topic/17448-event-jitter-fix-display-rounding-error-fix
##------
class Game_Map ## Rounds X and Y display values DOWN so the nearest 32 is found.
  def display_x
    (@display_x * 32).floor.to_f / 32
  end
  
  def display_y
    (@display_y * 32).floor.to_f / 32
  end
  
  def adjust_x(x)
    if loop_horizontal? && x < display_x - (width - screen_tile_x) / 2
      x - display_x + @map.width
    else
      x - display_x
    end
  end
  
  def adjust_y(y)
    if loop_vertical? && y < display_y - (height - screen_tile_y) / 2
      y - display_y + @map.height
    else
      y - display_y
    end
  end
end