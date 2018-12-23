#==============================================================================
# VXAce Star Passability Bug Fix
#   by NeonBlack
# -- Level: Easy, Normal
# -- Requires: n/a
# -- This simply checks if the tile is a star before checking passability.  
# If the tile is a star and it is passable, it then checks the tile UNDER it.  
# If not, it returns falseas always. This prevents everything that is a star 
# tile from being passable.
#
# -- Original Topic:
# http://forums.rpgmakerweb.com/index.php?/topic/7625-vxace-passabilities-bug/
#==============================================================================

class Game_Map

  def check_passage(x, y, bit)
        all_tiles(x, y).each do |tile_id|
          flag = tileset.flags[tile_id]
          if flag & 0x10 != 0                       # [☆]: No effect on passage
                next             if flag & bit == 0 # [○] : Passable but star
                return false if flag & bit == bit   # [×] : Impassable
          else
                return true  if flag & bit == 0  # [○] : Passable
                return false if flag & bit == bit   # [×] : Impassable
          end
        end
        return false                                              # Impassable
  end
end