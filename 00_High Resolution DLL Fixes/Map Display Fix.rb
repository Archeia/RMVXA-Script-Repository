#==============================================================================
# ** Map Display Fix by Hudell
#------------------------------------------------------------------------------
#
# You can now use resolutions that are not a multiple of 32, with Hudell's 
# script snippet! 
#
# To use this, extend your map's area to the right by one tile - it essentially 
# tricks the engine into thinking there is one tile less than what it is 
# displaying, thereby preventing a wraparound. 
#
# This updated snippet allows you to use smaller maps that have been centered 
# by Yanfly's Engine snippet.
#==============================================================================
class Game_Map  
  def width    
    if Graphics.width % 32 == 0      
      @map.width    
    else      
      @map.width - 1    
    end  
  end    
  def height    
    if Graphics.height % 32 == 0      
      @map.height    
    else      
      @map.height - 1    
    end  
  end  
end 

class Game_Player < Game_Character  
  def center_x    
    ((Graphics.width / 32).floor - 1) / 2.0  
  end   
  def center_y    
    ((Graphics.height / 32).floor - 1) / 2.0  
    end
  end