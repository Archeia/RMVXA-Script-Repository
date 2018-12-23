#==============================================================================
# Bravo Item Max Scriptlet
#------------------------------------------------------------------------------
# Author: Bravo2Kilo
# Version: 1.0
#
# Version History:
#   v1.0 = Initial Release
#==============================================================================
# If you want to set the max amount of each item that can be carried by the
# player use this notetag. If the notetag isnt present it will use the default
# max defined in the module below.
#   <itemmax: X> were X = the max.
#==============================================================================
module BRAVO
  # The default amount of one item the player can carry.
  ITEM_MAX = 99
end
#==============================================================================
# ** RPG::BaseItem
#==============================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # * Item Storage Max
  #--------------------------------------------------------------------------
  def item_max
    if @note =~ /<itemmax: (.*)>/i
      return $1.to_i
    else
      return BRAVO::ITEM_MAX
    end
  end
end
#==============================================================================
# ** Game_Party
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # * Get Maximum Number of Items Possessed
  #--------------------------------------------------------------------------
  def max_item_number(item)
    return item.item_max
  end
end