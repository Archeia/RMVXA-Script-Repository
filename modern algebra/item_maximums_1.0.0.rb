#==============================================================================
#    Item Maximums
#    Version: 1.0.0
#    Author: modern algebra (rmrk.net)
#    Date: July 19, 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This script allows you to set the maximum number of any item that the
#   party can hold at any given time on an individual basis. 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    Paste this script into its own slot in the Script Editor, above Main and
#   below Materials.
#
#    To set a new maximum for any item, just place the following code in its 
#   notebox:
#
#        \item_max[n]
#      where: n is the maximum number of that item the party can hold at one
#            time.
#
#    EXAMPLES:
#      \item_max[15]   # The party can hold only 15 of this item at any time.
#      \item_max[35]   # The party can hold only 35 of this item at any time.
#
#    For any item where you do not specify a maximum through the note field, 
#   its maximum will be determined by the value of MAIM_DEFAULT_ITEM_MAXIMUM, 
#   which can be set by you at line 42.
#==============================================================================

$imported ||= {}
if !$imported[:"MA_ItemMaximums 1.0.0"] # If not already installed
$imported[:"MA_ItemMaximums 1.0.0"] = true

#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#    BEGIN Editable Region
#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#  The following value will be the maximum number of items for any items for
# which you do not set a maximum in the note field.
MAIM_DEFAULT_ITEM_MAXIMUM = 99
#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#    END Editable Region
#//////////////////////////////////////////////////////////////////////////////

#==============================================================================
# ** RPG::BaseItem
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new method - maim_item_max
#==============================================================================

class RPG::BaseItem
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Instance Max
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maim_item_max
    (@maim_item_max = self.note[/\\ITEM[ _]MAX\[\s*(\d+)\s*\]/i] ? $1.to_i : 
      MAIM_DEFAULT_ITEM_MAXIMUM) if !@maim_item_max
    return @maim_item_max
  end
end

#==============================================================================
# ** Game_Party
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - max_item_number
#==============================================================================

class Game_Party
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Max Item Number
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maim_mxitmnum_3fj4 max_item_number
  def max_item_number(item, *args, &block)
    if item && item.maim_item_max > 0
      return item.maim_item_max
    end
    maim_mxitmnum_3fj4(item, *args, &block)
  end
end

else # If Item Maximums already installed
  p "Item Maximums 1.0.0 is already installed. It cannot be installed twice."
end