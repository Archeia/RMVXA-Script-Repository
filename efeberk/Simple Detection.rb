#  -------------------------------------------------
#  Script Name : Detector
#  Scripter : efeberk
#  Date : 08.08.2012
#  Version : RPG Maker VX Ace(RGSS3)
#  Special Thanks to Bird Eater
#  ------------------------------------------------
#  
# Features :
# 
# This script allows an event detects player when player near to event.
# 
# Introductions :
#  
# Make a "Conditional Branch" event command and select Script.
# ------------------------------------------------------------------------
# Script : detected?(e, d, true)
# 
# e : event id 
# 
# 0  => Current Event
# 1+ => Event ID
# 
# d => distance range from player.
# 
# Example : Conditional Branch : detected?(3, 4, true)
# 
# This means : returns true if distance 4 from 3. event to player and 
# 3.event saw player.

#~ -----------------------------------------------------------------------
#~   Script : region_reached?(a)
#~   
#~   This method allows to return true if player reached a 
#~   specific region ID.
#~   
#~   a => region ID
#~   
#~   Example : region_reached?(6)

#~   This means : True if player is on region 6.
#~   
#~ -------------------------------------------------------------------------
#~   Script : saw_player?(e)
#~   
#~   This method allows to return true if an event saw the player.
#~   
#~   e => event ID
#~   
#~   0 = event that used script.
#~   1+ = event ID
#~   
#~   Example : saw_player?(3)
#~   
#~   Returns true if 3.event saw player.
  

class Game_Event < Game_Character
  
  def move_type_toward_player
    if near_the_player?
      move_toward_player
      
    else
      move_random
    end
  end
end


class Game_Interpreter
 
  def get_event(i)
        if i == 0
         return $game_map.events[@event_id]
        end
        if i > 0
          return $game_map.events[i] 
        end

  end
 
      
  def detected?(a, d, k = false) 
      if k == true
        return distance(a, d) && saw_player?(a)
      else
        return distance(a, d) 
      end
  end
 
  def distance(a,d)
        ax = (get_event(a).x - $game_player.x).abs
        ay = (get_event(a).y - $game_player.y).abs
        if((ax + ay) <= d)
          return true
        else
          return false
        end
  end

  
  def region_reached?(a)
    if $game_player.region_id == a
      return true
    else
      return false
    end 
      
  end
  
  def saw_player?(e)
    sx = distance_x_from(e, $game_player.x)
    sy = distance_y_from(e, $game_player.y)
    if sx.abs > sy.abs
      direction = sx > 0 ? 4 : 6
    else
      direction = sy > 0 ? 8 : 2
    end
    if (direction == get_event(e).direction)
      return true
    else
      return false
    end
    
  end
  
  def distance_x_from(e, x)
    result = get_event(e).x - x
    if $game_map.loop_horizontal? && result.abs > $game_map.width / 2
      if result < 0
        result += $game_map.width
      else
        result -= $game_map.width
      end
    end
    result
  end
  
  def distance_y_from(e, y)
    result = get_event(e).y - y
    if $game_map.loop_vertical? && result.abs > $game_map.height / 2
      if result < 0
        result += $game_map.height
      else
        result -= $game_map.height
      end
    end
    result
  end

end