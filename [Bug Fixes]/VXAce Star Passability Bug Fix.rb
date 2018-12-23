#--------------------------------------------------------------------------
# VXAce Star Passability Bug Fix 
# Author(s):
# Neon Black
# Shaz
# Merged by Archeia
#--------------------------------------------------------------------------
# The fix checks if the tile is a star before checking passability. If the 
# tile is a star and it is passable, it then checks the tile UNDER it. If 
# not, it returns false as always. This prevents everything that is a star 
# tile from being passable.
#
#--------------------------------------------------------------------------
class Game_Map  
  def check_passage(x, y, bit)    
    all_tiles(x, y).each do |tile_id|      
    flag = tileset.flags[tile_id]      
    next if flag >> 12 == 1              
    # ignore passability on terrain 1      
    if flag & 0x10 != 0                  
    # [☆]: No effect on passage        
    next if flag & bit == 0            
    # [○] : Passable but star      
    else        
    return true if flag & bit == 0     
    # [○] : Passable      
    end      
    return false if flag & bit == bit    
    # [×] : Impassable    
    end    
    return false                           
    # Impassable  
  end
end