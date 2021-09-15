#==============================================================================#
# ** IEX(Icy Engine Xelion) - Distance From
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Characters)
# ** Script-Type   : Math
# ** Date Created  : 12/04/2010 (DD/MM/YYYY)
# ** Date Modified : 07/17/2011 (DD/MM/YYYY)
# ** Script Tag    : IEX - Distance From
# ** Difficulty    : Easy
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# This script allows to apply a set of fog effects above or and below your map.
# These effects are customizable.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** HOW TO USE
#------------------------------------------------------------------------------#
# 1.0 Script Calls - Inside Move Route
#------------------------------------------------------------------------------#
# fr_distance_from(x, y)
# This will return the total distance from the object to the target x, y
#
# If you wish to store the value in a variable
# In a move route call
# $game_variables[var_id] = fr_distance_from(x, y)
#
# In a script call
# For events
# $game_variables[var_id] = $game_map.events[event_id].fr_distance_from(x, y)
#
# For the Player
# $game_variables[var_id] = $game_player.fr_distance_from(x, y)
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
#
# Should have no problems
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#------------------------------------------------------------------------------#
# 
# Below 
#  Materials
#  Anything that makes changes to sprites
#
# Above 
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES 
#------------------------------------------------------------------------------# 
# Classes
#   Game_Character
#     new-method :fr_distance_from(x, y)
#     new-method :fr_distance_x_from(targ_x)
#     new-method :fr_distance_y_from(targ_y)
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
#
# (DD/MM/YYYY)
#  12/04/2010 - V1.0  Started And Finished Script
#  12/04/2010 - V1.0a Bug Fix
#  01/08/2011 - V1.0b Small Change
#  07/17/2011 - V1.1  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment
#
#------------------------------------------------------------------------------#
$imported ||= {} 
$imported["IEX_DistanceFrom"] = true
#==============================================================================#
# ** Game_Character
#==============================================================================#
class Game_Character

  #--------------------------------------------------------------------------#
  # * new-method :fr_distance_from
  #--------------------------------------------------------------------------#   
  def fr_distance_from( x, y )
    dx = fr_distance_x_from( x )
    dy = fr_distance_y_from( y )
    return Integer(dx.abs + dy.abs)
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :fr_distance_x_from
  #--------------------------------------------------------------------------#   
  def fr_distance_x_from( targ_x )
    sx = self.x - targ_x
    if $game_map.loop_horizontal?         # When looping horizontally
      if sx.abs > $game_map.width / 2     # Larger than half the map width?
        sx -= $game_map.width             # Subtract map width
      end
    end
    return sx
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :fr_distance_y_from
  #--------------------------------------------------------------------------#   
  def fr_distance_y_from( targ_y )
    sy = self.y - targ_y
    if $game_map.loop_vertical?           # When looping vertically
      if sy.abs > $game_map.height / 2    # Larger than half the map height?
        sy -= $game_map.height            # Subtract map height
      end
    end
    return sy
  end
  
end  

#==============================================================================#
# ** END OF FILE
#==============================================================================#