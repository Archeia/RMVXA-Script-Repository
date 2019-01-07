=begin
#===============================================================================
 Title: Sell Only Shop
 Author: Hime
 Date: Feb 25, 2013
--------------------------------------------------------------------------------
 ** Change log
 Feb 25
   - added support for allowing specific items to be sold, and their prices
 Feb 23, 2013
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Preserve this header
--------------------------------------------------------------------------------
 ** Required
 
 -Shop Manager
 (http://himeworks.com/2013/02/22/shop-manager/)
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to create a shop that only the player to sell things
 to the shop.

--------------------------------------------------------------------------------
 ** Usage
 
 In the interpreter, before the "Shop Processing" command, make a script call
 
    @shop_type = "SellOnlyShop"
    
 The list of items in the shop processing editor contain a list of items
 that you can sell to the shop. The price you input will be the price that
 it will be sold at.
 
 If you would like the shop to sell everything, check "purchase only"

#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_SellOnlyShop"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Sell_Only_Shop
  end
end
#===============================================================================
# ** Rest of the Script
#===============================================================================
class Game_SellOnlyShop < Game_Shop
end

class Window_SellOnlyShopCommand < Window_ShopCommand
  #--------------------------------------------------------------------------
  # No buying!
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::ShopSell,   :sell)
    add_command(Vocab::ShopCancel, :cancel)
  end
end

class Window_SellOnlyShopSell < Window_ShopSell
  
  def initialize(x, y, width, height, shop_goods, sell_all)
    super(x, y, width, height)
    @sell_all = sell_all
    @shop_goods = shop_goods
    @shop_data = shop_goods.collect{|good|good.item}
    @prices = {}
    shop_goods.each {|good| @prices[good] = good.price_type == 0 ? good.price / 2 : good.price}
  end

  def include?(item)
    return false unless @shop_data.include?(item) || @sell_all
    super
  end
  
  #-----------------------------------------------------------------------------
  # Return the currently selected good, if available. Need to perform a search
  # in case the shop is in "sell anything" mode, where goods may not
  # necessarily be specified nor in the same order they appear in the window
  #-----------------------------------------------------------------------------
  def current_good
    @shop_goods.detect {|good| good.item == @data[index]}
  end
  
  def price(good)
    @prices[good]
  end
end

class Scene_SellOnlyShop < Scene_Shop
  
  def create_command_window
    @command_window = Window_SellOnlyShopCommand.new(@gold_window.x, @purchase_only)
    @command_window.viewport = @viewport
    @command_window.y = @help_window.height
    @command_window.set_handler(:buy,    method(:command_buy))
    @command_window.set_handler(:sell,   method(:command_sell))
    @command_window.set_handler(:cancel, method(:return_scene))
  end
  
  def create_sell_window
    wy = @category_window.y + @category_window.height
    wh = Graphics.height - wy
    @sell_window = Window_SellOnlyShopSell.new(0, wy, Graphics.width, wh, @goods, @shop.purchase_only)
    @sell_window.viewport = @viewport
    @sell_window.help_window = @help_window
    @sell_window.hide
    @sell_window.set_handler(:ok,     method(:on_sell_ok))
    @sell_window.set_handler(:cancel, method(:on_sell_cancel))
    @category_window.item_window = @sell_window
  end
  
  def on_sell_ok
    @selected_good = @sell_window.current_good
    super
  end
  
  def selling_price
    @selected_good.nil? ? @item.price / 2 : @sell_window.price(@selected_good)
  end
end