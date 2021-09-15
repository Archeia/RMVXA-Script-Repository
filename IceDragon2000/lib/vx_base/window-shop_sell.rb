#encoding:UTF-8
# Window_ShopSell
#==============================================================================
# ** Window_ShopSell
#------------------------------------------------------------------------------
#  This window displays items in possession for selling on the shop screen.
#==============================================================================

class Window_ShopSell < Window_Item
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x      : window x-coordinate
  #     y      : window y-coordinate
  #     width  : window width
  #     height : window height
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
  end
  #--------------------------------------------------------------------------
  # * Whether or not to include in item list
  #     item : item
  #--------------------------------------------------------------------------
  def include?(item)
    return item != nil
  end
  #--------------------------------------------------------------------------
  # * Whether or not to display in enabled state
  #     item : item
  #--------------------------------------------------------------------------
  def enable?(item)
    return (item.price > 0)
  end
end
