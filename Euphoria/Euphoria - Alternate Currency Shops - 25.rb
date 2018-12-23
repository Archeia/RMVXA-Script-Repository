#┌──────────────────────────────────────────────────────────────────────────────
#│
#│                         *Alternate Currency Shops*
#│                              Version: 1.0
#│                            Author: Euphoria
#│                            Date: 8/20/2014
#│                        Euphoria337.wordpress.com
#│                        
#├──────────────────────────────────────────────────────────────────────────────
#│■ Important: None
#├──────────────────────────────────────────────────────────────────────────────
#│■ History: None                         
#├──────────────────────────────────────────────────────────────────────────────
#│■ Terms of Use: This script is free to use in non-commercial games only as 
#│                long as you credit me (the author). For Commercial use contact 
#│                me.
#├──────────────────────────────────────────────────────────────────────────────                          
#│■ Instructions: This script REQUIRES "Euphoria - Alternate Currencies" V1.1 or
#│                higher to work!
#│                 
#│                You can now create shops for your Alternate Currencies! to do
#│                so you must go into the editable region and create your shop!
#│                The format for creating a shop is:
#│
#│                "Shop Name" => {
#│                :ITEMS => [x, x, x], 
#│                  note: replace x with the item ID numbers, you can have more
#│                        than three or less than three or none, its up to you
#│                :ITEMS_P => [x, x, x],     
#│                  note: replace x with the desired price for the corresponding 
#│                        item, there MUST be the same number of prices as items
#│                :WEAPONS => [x, x],
#│                  note: same rules as :ITEMS
#│                :WEAPONS_P => [x, x],
#│                  note: same rules as :ITEMS_P
#│                :ARMORS => [x, x, x],
#│                  note: same rules as :ITEMS
#│                :ARMORS_P => [x, x, x],
#│                  note: same rules as :ITEMS_P
#│                },
#│
#│                When setting up a shop, DO NOT INCLUDE THE NOTES, those are 
#│                simply for instruction. You'll see examples below of what the
#│                shop setup looks like without the notes in between. Also DO
#│                NOT FORGET to add a comma (,) after each set of brackets, and
#│                after the ending curly bracket you can already see this is 
#│                done in the examples above and below.
#│
#│                OKAY! So now you have your shop(s) set up (you can make as
#│                many as you want). Now you need to call your shop. You will be
#│                calling each shop by name and the currency you want it to use,
#│                so it is important that each shop name is unique. The call for
#│                opening the shop in an event is:
#│
#│                $EShop.call("shop name", "currency name", purchase only = x)
#│
#│                Replace "shop name" with your shops name, but keep it in 
#│                quotes! Replace "currency name" with the name of your currency
#│                (created in Euphoria - Alternate Currencies) you wish to use.
#│                ONLY type in purchase_only if you want to set the x to true,
#│                if not you may leave out the purchase_only option as it is set
#│                to false by default. Here are some examples:
#│
#│                A shop that you can buy or sell at named "shop1" with "money"
#│                as the currency (note: money must be a created and enabled 
#│                currency in the other script):
#│
#│                $EShop.call("Shop1", "Money")
#│
#│                Notice how purchase_only is left out, because we want it set 
#│                to false! Now, for a shop that only allows the user to buy, 
#│                has the name "awesome shop" and uses the currency "Currency":
#│
#│                $EShop.call("awesome shop", "Currency", purchase_only = true)
#│
#│                Purchase_only is in this call ONLY because we wish to set it 
#│                to true! I think you should get it by now, but feel free to
#│                ask any questions you still have on my website or in the topic
#│                where I post the link to this script! Enjoy!           
#└──────────────────────────────────────────────────────────────────────────────
if $imported["EuphoriaAlternateCurrencies"] != true
msgbox_p("Euphoria - Alternate Currencies REQUIRED")
exit
else
$imported ||= {}
$imported["EuphoriaAlternateShops"] = true
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Editable Region
#└──────────────────────────────────────────────────────────────────────────────
module Euphoria
  module CurrencyShops


    CURRENCY_SHOPS = { #DO NOT TOUCH

      "Shop1" => {
      :ITEMS      => [ 1,  2,  3],
      :ITEMS_P    => [50, 20, 10],
      :WEAPONS    => [  1,  2],
      :WEAPONS_P  => [100, 75],
      :ARMORS     => [],
      :ARMORS_P   => [],
      },
      
      "Shop2" => {
      :ITEMS      => [ 5,  7,  9],
      :ITEMS_P    => [25, 20, 15],
      :WEAPONS    => [  7, 10],
      :WEAPONS_P  => [180, 90],
      :ARMORS     => [ 1,  3,   7],
      :ARMORS_P   => [66, 53, 107],
      },
      
    }#DO NOT TOUCH
    
  end
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ DO NOT EDIT BELOW HERE
#└──────────────────────────────────────────────────────────────────────────────


#┌──────────────────────────────────────────────────────────────────────────────
#│■ DataManager
#└──────────────────────────────────────────────────────────────────────────────
class << DataManager
  
  #ALIAS - CREATE_GAME_OBJECTS
  alias euphoria_currshops_datamanager_creategameobjects_25 create_game_objects
  def create_game_objects
    euphoria_currshops_datamanager_creategameobjects_25
    $EShop = EShop.new
  end

end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ EShop
#└──────────────────────────────────────────────────────────────────────────────
class EShop
  
  #NEW - INITIALIZE
  def initialize
    @inventory = []
    @shop_name = ""
  end
  
  #NEW - INVENTORY
  def inventory
    @inventory
  end
  
  #NEW - CLEAR_INVENTORY
  def clear_inventory
    @inventory = []
  end
  
  #NEW - CALL
  def call(shop_name, currency, purchase_only = false)
    clear_inventory
    $EShop.items_for_creation(shop_name)
    SceneManager.call(Scene_ECurrencyShop)
    SceneManager.scene.prepare($EShop.inventory, currency, purchase_only)
  end
  
  #NEW - ITEMS_FOR_CREATION
  def items_for_creation(shop_name)
    Euphoria::CurrencyShops::CURRENCY_SHOPS.each {|name, val|
      if name == shop_name && Euphoria::CurrencyShops::CURRENCY_SHOPS.has_key?(shop_name)
        @shop_name = shop_name
        if val[:ITEMS].size != 0
          val[:ITEMS].size.times {|id|
            item = create_item(0, val[:ITEMS][id], val[:ITEMS_P][id])
            @inventory.push(item) unless @inventory.include?(item)
          }
        end
        if val[:WEAPONS].size !=0
          val[:WEAPONS].size.times {|id|
            item = create_item(1, val[:WEAPONS][id], val[:WEAPONS_P][id])
            @inventory.push(item) unless @inventory.include?(item)
          }
        end
        if val[:ARMORS].size != 0
          val[:ARMORS].size.times {|id|
            item = create_item(2, val[:ARMORS][id], val[:ARMORS_P][id])
            @inventory.push(item) unless @inventory.include?(item)
          }
        end
      end
    }
  end
      
  #NEW - CREATE_ITEM
  def create_item(item_type, item_id, price)
    item = EItem.new(item_type, item_id, price) 
    goods = [item.type, item.id, item.price]
    return goods
  end 
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ EItem
#└──────────────────────────────────────────────────────────────────────────────
class EItem
  attr_accessor :type
  attr_accessor :id
  attr_accessor :price
  
  #NEW - INITIALIZE
  def initialize(item_type, item_id, item_price)
    @type = item_type
    @id = item_id
    @price = item_price
  end
    
  #NEW - GET_ITEMS
  def get_items
    if @type == 0
      return @data_items[@id]
    end    
    if @type == 1
      return @data_weapons[@id]
    end
    if @type == 2
      return @data_armors[@id]
    end
  end
    
  #NEW - PRICE
  def price
    return @price
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Window_ECurrencyShopBuy
#└──────────────────────────────────────────────────────────────────────────────
class Window_ECurrencyShopBuy < Window_ShopBuy
  
  #NEW - MAKE_ITEM_LIST
  def make_item_list
    @data = []
    @price = {}
    @shop_goods.each do |goods|
      case goods[0]
      when 0;  item = $data_items[goods[1]]
      when 1;  item = $data_weapons[goods[1]]
      when 2;  item = $data_armors[goods[1]]
      end
      if item
        @data.push(item)
        @price[item] = goods[2]
      end
    end
  end  
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Window_ECurrencyShopGold
#└──────────────────────────────────────────────────────────────────────────────
class Window_ECurrencyShopGold < Window_Base
  
  #NEW - INITIALIZE
  def initialize(currency)
    super(384, 72, 160, 48)
    @currency = currency
    refresh
  end

  #NEW - REFRESH
  def refresh
    contents.clear
    draw_currency_value(amount, currency_symbol, 4, 0, contents.width - 8)
  end  
  
  #NEW - CURRENCY_SYMBOL
  def currency_symbol
    @currency.symbol
  end
  
  #NEW - AMOUNT
  def amount
    @currency.amount
  end
  
  #NEW - OPEN
  def open
    refresh
    super
  end 
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Scene_ECurrencyShop
#└──────────────────────────────────────────────────────────────────────────────
class Scene_ECurrencyShop < Scene_Shop
  
  #NEW - PREPARE
  def prepare(inventory, currency, purchase_only = false)
    @items = inventory
    @currency = $ECurrency.set_currency(currency)
    @purchase_only = purchase_only
  end

  #NEW - START
  def start
    super
    create_gold_window
    create_command_window
    create_dummy_window
    create_number_window
    create_status_window
    create_buy_window
    create_category_window
    create_sell_window
  end
  
  #NEW - CREATE_GOLD_WINDOW
  def create_gold_window
    @gold_window = Window_ECurrencyShopGold.new(@currency)
    @gold_window.viewport = @viewport
    @gold_window.x = Graphics.width - @gold_window.width
  end

  #NEW - CREATE_BUY_WINDOW
  def create_buy_window
    @buy_window = Window_ECurrencyShopBuy.new(0, 120, 296, @items)
    @buy_window.viewport = @viewport
    @buy_window.help_window = @help_window
    @buy_window.status_window = @status_window
    @buy_window.hide
    @buy_window.set_handler(:ok,     method(:on_buy_ok))
    @buy_window.set_handler(:cancel, method(:on_buy_cancel))
  end 
  
  #NEW - DO_BUY
  def do_buy(number)
    $ECurrency.decrease_currency(@currency.name, number * buying_price)
    $game_party.gain_item(@item, number)
  end
 
  #NEW - DO_SELL
  def do_sell(number)
    $ECurrency.increase_currency(@currency.name, number * selling_price)
    $game_party.lose_item(@item, number)
  end  

  #NEW - MONEY
  def money
    @currency.amount
  end
  
  #NEW - CURRENCY_UNIT
  def currency_unit
    @currency.symbol
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ End Script
#└──────────────────────────────────────────────────────────────────────────────