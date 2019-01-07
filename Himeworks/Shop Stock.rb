=begin
#===============================================================================
 Title: Shop Stock
 Author: Hime
 Date: Feb 22, 2013
--------------------------------------------------------------------------------
 ** Change log
 Feb 22, 2013
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
 
 This script adds a "stock" count to each shop good.
 Once a good's stock reaches 0, it will no longer be available in the shop.

--------------------------------------------------------------------------------
 ** Usage
 
 In your event, before the Shop Processing command, use a script call
 
   @shop_stock[id] = amount
   
 Where
   `id` is the ID of the shop good, which is the index they appear in the
        shop list. The first item has ID of 1.
   
   `amount` is how much of the item they have in stock
   
--------------------------------------------------------------------------------
 ** Developers   
 
 How much stock that a shop has remaining of a shop good is stored in the
 "stock" attribute of that good. There are three cases

   stock < 0, then there is no limit
   stock == 0, then there is none left
   stock > 0, then there is that much left

#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_ShopStock"] = true
#===============================================================================
# ** Configuration
#=============================================================================== 
module TH
  module Shop_Stock
  end
end
#===============================================================================
# ** Rest of the Script
#=============================================================================== 
class Game_Interpreter
  
  alias :th_shop_stock_clear :clear
  def clear
    th_shop_stock_clear
    @shop_stock = []
  end
  
  alias :th_shop_stock_setup_good :setup_good
  def setup_good(good, id)
    th_shop_stock_setup_good(good, id)
    stock = @shop_stock[id]
    return unless stock
    good.stock = stock
  end
end
class Game_ShopGood
  attr_reader :stock
  
  alias :th_shop_stock_init :initialize
  def initialize(*args)
    th_shop_stock_init(*args)
    @stock = -1
    @unlimited = true
  end
  
  def stock=(amount)
    @stock = amount
    @unlimited = (amount < 0)
  end
  
  def unlimited?
    @unlimited
  end
  
  def increase_stock(amount)
    @stock += amount
  end
  
  def decrease_stock(amount)
    return if @unlimited
    @stock = [@stock - amount, 0].max
  end
end

class Game_Shop
  
  alias :th_shop_stock_include? :include?
  def include?(index)
    return false if stock(index) == 0
    th_shop_stock_include?(index)
  end
  
  def stock(index)
    @shop_goods[index].stock
  end
end

class Window_ShopBuy < Window_Selectable
  
  alias :th_shop_stock_include? :include?
  def include?(shopGood)
    return false if shopGood.stock == 0
    th_shop_stock_include?(shopGood)
  end
  
  alias :th_shop_stock_draw_item :draw_item
  def draw_item(index)
    th_shop_stock_draw_item(index)
    rect = item_rect(index)
    item = @data[index]
    shopGood = @goods[item]
    draw_text(rect, shopGood.stock, 1) unless shopGood.unlimited?
  end

  alias :th_shop_stock_process_ok :process_ok
  def process_ok
    unless @data[index]
      Sound.play_buzzer 
      return
    end
    th_shop_stock_process_ok
  end
end

class Scene_Shop < Scene_MenuBase
  
  #--------------------------------------------------------------------------
  # Get amount you could buy, compared to the amount in-stock
  #--------------------------------------------------------------------------
  alias :th_shop_stock_max_buy :max_buy
  def max_buy
    party_max = th_shop_stock_max_buy
    @selected_good.unlimited? ? party_max : [party_max, @selected_good.stock].min
  end
  
  #--------------------------------------------------------------------------
  # Decrease the amount of stock of the selected good
  #--------------------------------------------------------------------------
  alias :th_shop_stock_do_buy :do_buy
  def do_buy(number)
    th_shop_stock_do_buy(number)
    @selected_good.decrease_stock(number)
  end
end