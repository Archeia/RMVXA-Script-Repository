#==============================================================================
# ++ Limit Sell Items to Buy Item Selections - v1.1 (1/01/12)
#==============================================================================
# Original RMVX/RGSS2 script by: 
#             Mithran
# Ported to RMVXA/RGSS3 by:
#             Mr. Bubble
#--------------------------------------------------------------------------
# This script restricts the types of items the player can sell to a shop
# to only what the player can buy from the shop. Sellable item restrictions
# can optionally be turned off or on with a game switch.
#
# Original script port request by Seiryuki.
#--------------------------------------------------------------------------
# ++ This script aliases the following methods:
#       Scene_Shop#create_sell_window
#==============================================================================

#--------------------------------------------------------------------------
# ++ Customization Module - START
#--------------------------------------------------------------------------

module Bubs
  module MithranLimitSellItems
  # ++ Limit Shop Default
  #    Determines whether all shops only buyback items they can 
  #    sell by default
  LIMIT_SHOP_SELL_DEFAULT = true
  
  # ++ Limit Shop Game Switch
  #    Set whether you want a game switch ID to determine when Limit Shop
  #    is active. Otherwise, you can leave it as nil.
  LIMIT_SHOP_SELL_SWITCH = nil
  
  end
end

#--------------------------------------------------------------------------
# ++ Customization Module - END
#--------------------------------------------------------------------------

$imported = {} if $imported.nil?
$imported["MithranLimitSellItems"] = true

#==============================================================================
# ++ Window_LimitShopSell : new class
#==============================================================================
# $game_temp.shop_goods no longer exists in RGSS3. Because of this, a new
# class was created.

class Window_LimitShopSell < Window_ShopSell
  #--------------------------------------------------------------------------
  # ++ Object Initialization
  #     x      : window x-coordinate
  #     y      : window y-coordinate
  #     width  : window width
  #     height : window height
  #     shop_goods : array of shop goods
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, shop_goods)
    super(x, y, width, height)
    @shop_goods = shop_goods
  end
  #--------------------------------------------------------------------------
  # ++ Whether or not to include in item list
  #     item : item
  #--------------------------------------------------------------------------
  def include?(item)
    return false if @shop_goods.nil?
    return false if item.nil?
    for pair in @shop_goods
      case @category
      when :item
        if item.is_a?(RPG::Item) && !item.key_item?
          return true if pair[0] == 0 && pair[1] == item.id
        end
      when :weapon
        if item.is_a?(RPG::Weapon)
          return true if pair[0] == 1 && pair[1] == item.id
        end
      when :armor
        if item.is_a?(RPG::Armor)
          return true if pair[0] == 2 && pair[1] == item.id
        end
      when :key_item
        if item.is_a?(RPG::Item) && item.key_item?
          return true if pair[0] == 0 && pair[1] == item.id
        end
      else
        return false
      end # case
    end # for
    return false
  end # def include?(item)
end # class

#==============================================================================
# ++ Scene_Shop
#==============================================================================
class Scene_Shop < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ++ create_sell_window : alias
  #--------------------------------------------------------------------------
  alias create_sell_window_limit_shop_sell create_sell_window
  def create_sell_window
    if Bubs::MithranLimitSellItems::LIMIT_SHOP_SELL_DEFAULT || 
                $game_switches[Bubs::MithranLimitSellItems::LIMIT_SHOP_SELL_SWITCH]
                
      wy = @category_window.y + @category_window.height
      wh = Graphics.height - wy
      # changed to Window_LimitShopSell.new
      @sell_window = Window_LimitShopSell.new(0, wy, Graphics.width, wh, @goods)
      @sell_window.viewport = @viewport
      @sell_window.help_window = @help_window
      @sell_window.hide
      @sell_window.set_handler(:ok,     method(:on_sell_ok))
      @sell_window.set_handler(:cancel, method(:on_sell_cancel))
      @category_window.item_window = @sell_window
    else
      create_sell_window_limit_shop_sell # alias
    end # if
  end # def create_sell_window
end # class