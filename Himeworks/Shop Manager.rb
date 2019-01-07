=begin
#===============================================================================
 Title: Shop Manager
 Author: Hime
 Date: Aug 4, 2014
--------------------------------------------------------------------------------
 ** Change log
 2.3 Aug 4, 2014
   - added shop ID's
 2.2 Apr 9, 2014
   - fixed bug where calling a common event causes all shops to call wrong shop
 2.1 Apr 1, 2014
   - fixed bug where game crashes after loading from an event save
 2.0 Mar 12, 2014
   - added support for custom sell prices for each shop
 1.9 Dec 2, 2013
   - fixed bug where shop common event ID was not cleared out properly
 1.81 Nov 21, 2013
   - game shops are initialized on game load if necessary
 1.8 Nov 20, 2013
   - Game_ShopGood formulas are evaluated in the context of the interpreter
 1.7 Oct 24, 2013
   - added `add_shop_good` script call to add shop goods programmatically
   - added "price formulas" to specify a good's price using a formula
 1.6 Oct 15, 2013
   - removed page refreshing. It doesn't work.
 1.5 Mar 29, 2013
   - added simple shop refreshing on page change. Will need a better solution
     since this does not track the state of a shop on a different page
 1.4 Mar 13, 2013
   - fixed bug where common event shops were not handled appropriately when
     called through effects
 1.3 Mar 1, 2013
   - Game_ShopGood now determines whether it should be included or enabled
   - Two shop options implemented: hidden, disabled
 1.2 Feb 25
   - fixed issue where common event shops were not handled correctly
   - exposed Shop Good variables as readers
 1.1
   - ShopManager handles shop scene changing depending on the type of shop
   - added handling for different "types" of shops
   - all goods in a shop can be accessed via shop.shop_goods
   - reference to shop added to shop scene
   - added support for adding and removing goods from a shop
 1.0 Feb 22, 2013
   - Initial Release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script enhances the game shop, providing useful options that allow you
 to customize each shop good individually.

 This script provides functionality for remembering a shop’s “state”. Each
 shop is uniquely identified by a shop ID, and if you visit the same shop
 repeatedly, you should see the same settings.

 For example, if a shop holds 10 potions, and you bought 5, then you can
 expect that the next time you visit the shop, it will only have 5 potions
 remaining.

 Of course, you will need extra plugins to have that kind of functionality.
 
 In summary:
   -more control over your shops
   -simple API for developers to write shop-related scripts
 
--------------------------------------------------------------------------------
 ** Usage
 
 This script provides a number of built-in shop options for you to customize your shop goods for each shop.

 Each shop option requires you to pass in a “good ID”, which is basically the order that the items appear in your “shop processing” list. The shop good at the top of the list has a good ID of 1, the next has a good ID of 2, and so on.

 All shop options must be set before the shop processing command.

 The following variables are available for all formulas:

   v - game variables
   s - game switches
   p - game party
 
 -- Hiding Goods --

 You can prevent a shop good from appear in the shop list by using a
 “hide formula”. To set a hide formula for a particular good, use the
 script call
 
    hide_good(good_id, hide_formula)

 -- Disabling Goods --

 Disabling a shop good means the player can’t buy it, but it will still appear
 on the list. The default windows simply change the color of the good to
 indicate that it can’t be selected. You can disable a shop good using a
 “disable formula”, and can be set using the script call

    disable_good(good_id, hide_formula)

 -- Price Formulas --

 Each shop good can have a custom price by defining a “price formula”. The
 price is evaluated when the player visits the shop, so it is dynamically
 generated based on the current game state.
 
 To set a price formula, use the script call

    price_good(good_id, price_formula)
    
 -- Selling price formulas --
 
 You can specify the selling price of all items for a particular shop.
 To set the selling price, use the script call
 
    sell_price(item_string, price_formula)
    
 The item string uses the following format:
 
    i2 - item ID 2
    w4 - weapon ID 4
    a12 - armor ID 12
    
 If the sell price is not specified, then it is assumed to be half the
 buy price.
 
--------------------------------------------------------------------------------
 ** Developers
 
 Here are some specifications that I have written.
 
 Have a look through each class to see what is available for use.
 If you have any suggestions that will improve the base script (ie: this), 
 I will consider adding them.
 
 -- Shop Manager --
 
 This module serves are the interface for all shop-related queries. It handles
 how shops are stored for you so that it is easy to properly obtain a reference
 to a shop.
 
 You should use the Shop Manager whenever possible.
 
 -- Game Shop --
 
 This script treats a shop as a concrete object. A shop is created the first
 time it is accessed, and will be stored with the game for the remainder of
 the game.
 
 A very basic shop is provided, which manages what items are available for sale.
 All shops are stored in a global Game_Shops hash in $game_shops
 
 -- Shop Type --
 
 On top of the basic Game_Shop class, you can define your own shops and
 associate them with custom scenes specific to those shops.
 
 The Shop Manager only requires you to be consistent with your shop name.
 For example, if your shop type is "CraftShop", then you must define a
 
   Game_CraftShop  - the shop object that the shop will be instantiated with
   Scene_CraftShop - the scene that will be called when visiting a CraftShop
   
 Users will set a @shop_type attribute in Game_Interpreter to determine
 what type of shop should be created
 
 -- Managing shops --
 
 This script assumes shops are only called through events or common events.
 Troop events are not supported.
 
 A shop is identified by a map ID and an event ID.
 Shops that are called via common events will have a map ID of 0.
 
 In order to determine whether a normal event or a common event called the
 shop, the "depth" of the interpreter is used.
 
    When depth = 0, then it is a normal event
    When depth > 0, then it is a common event
    
 The shop processing should be handled appropriately depending on the depth
 
 This script assumes that an event is triggered through "normal" interaction;
 that is, you can only interact with events within a map. Any events that should
 be treated as the same event should be done as a common event call.
 
 --- Shop Goods ---
 
 Rather than storing all goods as a simple array of values, this script
 provides a Game_ShopGood class. You can use this to store any additional
 information that you want.
 
 All shop related scenes and windows MUST provide support for handling shop
 goods. While backwards compatibility is provided for the default scripts,
 additional methods have been defined to allow you to retrieve the currently
 selected shop good.
 
 --- Shop Options ---
 
 Since there isn't actually a way to setup individual shop goods, external
 approaches must be used. There is not much specification here yet, so it
 is up to you how you wish to populate your ShopGood objects. I have provided
 a "setup_goods" method in Game_Interpreter that you can alias.
 
--------------------------------------------------------------------------------
 ** Compatibility
 
 This script changes the following from the default scripts
 
   DataManager
     aliased  - create_game_objects   
     aliased  - make_save_contents
     aliased  - extract_save_contents
   Game_Interpreter
     replaced - command_302
   Window_ShopBuy
     replaced - prepare
   Scene_Shop
     replaced - make_item_list 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_ShopManager"] = 2.4
#===============================================================================
# ** Rest of the Script
#=============================================================================== 
#-------------------------------------------------------------------------------
# Main shop manager that acts as the interface between shops and other objects
# The main role of the ShopManager is to essentially manage any shop objects
# that exist in the game. In particular, it provides all of the methods for
# creating, retrieving, and deleting shops.
#-------------------------------------------------------------------------------
module ShopManager
  
  #-----------------------------------------------------------------------------
  # Return a reference to a specific shop
  #-----------------------------------------------------------------------------
  def self.get_shop(shop_id)
    return $game_shops[shop_id]
  end
  
  #-----------------------------------------------------------------------------
  # Indicate that a shop needs to be refreshed
  #-----------------------------------------------------------------------------
  def self.refresh_shop(shop_id)
    shop = get_shop(shop_id)
    shop.need_refresh = true if shop
  end
  
  #-----------------------------------------------------------------------------
  # Setup shop if first time visiting
  #-----------------------------------------------------------------------------
  def self.setup_shop(shop_id, goods, purchase_only, shop_type)
    shop = get_shop(shop_id)
    return shop if shop && !shop.need_refresh
    shop = shop_class(shop_type).new(goods, purchase_only)
    $game_shops[shop_id] = shop
    return shop
  end
  
  #-----------------------------------------------------------------------------
  # Return the appropriate shop class given the shop type
  #-----------------------------------------------------------------------------
  def self.shop_class(shop_type)
    shop_type = "Game_" + shop_type.to_s
    return Object.const_get(shop_type.to_sym)
  end
  
  #-----------------------------------------------------------------------------
  # Return the scene associated with this shop.
  # TO DO
  #-----------------------------------------------------------------------------
  def self.shop_scene(shop)
    shop_scene = "Scene_" + shop.class.name.gsub("Game_", "")
    return Object.const_get(shop_scene.to_sym)
  end
  
  #-----------------------------------------------------------------------------
  # Invokes SceneManager.call on the appropriate scene
  #-----------------------------------------------------------------------------
  def self.call_scene(shop)
    SceneManager.call(shop_scene(shop))
    SceneManager.scene.prepare(shop)
  end
  
  #-----------------------------------------------------------------------------
  # Invokes SceneManager.goto on the appropriate scene
  #-----------------------------------------------------------------------------
  def self.goto_scene(shop)
    SceneManager.goto(shop_scene(shop))
    SceneManager.scene.prepare(shop)
  end
  
  #-----------------------------------------------------------------------------
  # Returns a good ID, given a shop and an item. If the item is already in
  # the shop, it will return that good's ID. Otherwise, it will return a new ID
  #-----------------------------------------------------------------------------
  def self.get_good_id(shop, item)
    good = shop.shop_goods.detect {|good| good.item == item}
    return good.nil? ? shop.shop_goods.size + 1 : good.id
  end
  
  #-----------------------------------------------------------------------------
  # Returns a good, given a shop and an item. If the shop already has that good
  # just return it. Otherwise, make a new good. If the price is negative, then
  # the price is the default price. Otherwise, it is the specified price.
  #-----------------------------------------------------------------------------
  def self.get_good(shop, item, price=-1)
    good = shop.shop_goods.detect {|good| good.item == item}
    return good if good
    good_id = shop.shop_goods.size + 1
    type = item_type(item)
    if price < 0
      price_type = price = 0
    else
      price_type = 1
    end
    return Game_ShopGood.new(good_id, type, item.id, price_type, price)
  end
  
  #-----------------------------------------------------------------------------
  # Returns the type of an item.
  #-----------------------------------------------------------------------------
  def self.item_type(item)
    return 0 if item.is_a?(RPG::Item)
    return 1 if item.is_a?(RPG::Weapon)
    return 2 if item.is_a?(RPG::Armor)
    return -1
  end
end

#-------------------------------------------------------------------------------
# Shops are stored in a global variable `$game_shops`. This is dumped and
# loaded appropriately.
#-------------------------------------------------------------------------------
module DataManager
  
  class << self
    alias :th_shop_manager_create_game_objects :create_game_objects
    alias :th_shop_manager_make_save_contents :make_save_contents 
    alias :th_shop_manager_extract_save_contents :extract_save_contents
  end
  
  def self.create_game_objects
    th_shop_manager_create_game_objects
    $game_shops = Game_Shops.new
  end
  
  def self.make_save_contents
    contents = th_shop_manager_make_save_contents
    contents[:shops] = $game_shops
    contents
  end
  
  #-----------------------------------------------------------------------------
  # Load shop data
  #-----------------------------------------------------------------------------
  def self.extract_save_contents(contents)
    th_shop_manager_extract_save_contents(contents)
    $game_shops = contents[:shops] || Game_Shops.new
  end
end

class Game_Temp
  
  # even if we're not actually calling a shop, it shouldn't affect anything
  # because we are always setting this at each common event call by an event
  attr_accessor :shop_common_event_id
  
  alias :th_shop_manager_reserve_common_event :reserve_common_event
  def reserve_common_event(common_event_id)
    th_shop_manager_reserve_common_event(common_event_id)
    @shop_common_event_id = common_event_id
  end
  
  alias :th_shop_manager_clear_common_event :clear_common_event
  def clear_common_event
    th_shop_manager_clear_common_event
    clear_shop_event_id
  end
  
  def clear_shop_event_id
    @shop_common_event_id = nil
  end
end

class Game_Interpreter
  
  alias :th_shop_manager_initialize :initialize
  def initialize(*args)
    @shop_common_event_id = $game_temp.shop_common_event_id if $game_temp
    th_shop_manager_initialize(*args)
  end
  
  alias :th_shop_manager_clear :clear
  def clear
    th_shop_manager_clear
    clear_shop_options
    @custom_goods = {}
    @shop_type = nil
    @shop_id = nil
  end
  
  def shop_options
    return @shop_options if @shop_options
    clear_shop_options
    return @shop_options
  end
  
  def custom_goods
    @custom_goods ||= {}
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def clear_shop_options
    @shop_options = {}
    @shop_options[:hidden] = {}
    @shop_options[:disabled] = {}
    @shop_options[:price] = {}
    @shop_options[:sell_price] = {}
  end
  
  #-----------------------------------------------------------------------------
  # New. We are in a common event only if the shop common event ID is set.
  #-----------------------------------------------------------------------------
  def shop_map_id
    @shop_common_event_id ? 0 : @map_id
  end
  
  def shop_event_id
    @shop_common_event_id ? @shop_common_event_id : @event_id
  end
  
  #-----------------------------------------------------------------------------
  # Set the shop's common event ID so that the child interpreter can pick it
  # up. Then clear it out
  #-----------------------------------------------------------------------------
  alias :th_shop_manager_command_117 :command_117
  def command_117
    $game_temp.shop_common_event_id = @params[0]
    th_shop_manager_command_117
    $game_temp.clear_shop_event_id
  end
  
  #-----------------------------------------------------------------------------
  # Replaced. A shop is setup only once, and is retrieved whenever it is
  # called in the future. This assumes the shop is invoked through "normal"
  # event interactions.
  #-----------------------------------------------------------------------------
  def command_302
    return if $game_party.in_battle
    shop_type = @shop_type || :Shop
    
    # load goods
    goods = load_all_goods
    
    shop_id = @shop_id || [shop_map_id, shop_event_id]
    
    # Setup shop if needed
    shop = ShopManager.setup_shop(shop_id, goods, @params[4], shop_type)
    setup_shop(shop)
    
    # prepare the shop with a reference to the actual shop
    ShopManager.call_scene(shop)
    Fiber.yield
  end
  
  def load_all_goods
    good_id = 1
    goods = []

    # setup goods
    good = make_good(@params[0..-1], good_id) # last param is for the shop
    goods.push(good)
    good_id +=1
    
    while next_event_code == 605
      @index += 1
      good = make_good(@list[@index].parameters, good_id)
      goods.push(good)
      good_id +=1
    end

    goods.concat(load_custom_goods)
    return goods
  end
  
  #-----------------------------------------------------------------------------
  # Goods that should be added to the shop, but are not added through the
  # shop editor (eg: script calls)
  #-----------------------------------------------------------------------------
  def load_custom_goods
    goods = []
    custom_goods.each do |id, goods_array|
      good = make_good(goods_array, id)
      goods.push(good)
    end
    return goods
  end
  
  #-----------------------------------------------------------------------------
  # New. This is where the goods are setup.
  #-----------------------------------------------------------------------------
  def make_good(goods_array, good_id)
    item_type, item_id, price_type, price = goods_array
    good = Game_ShopGood.new(good_id, item_type, item_id, price_type, price)
    
    # additional setup
    setup_good(good, good_id)
    return good
  end
  
  #-----------------------------------------------------------------------------
  # New. Adds a shop good to the list of goods. Note that you must check
  # that ID of the shop good is unique. I will not generate an ID automatically
  # because otherwise you'd have no way of applying shop options to it
  #-----------------------------------------------------------------------------
  def add_shop_good(good_id, item_type, item_id, price=nil)
    if item_type == :item
      item_type = 0
    elsif item_type == :weapon
      item_type = 1
    elsif item_type == :armor
      item_type = 2
    end
    price_type = price ? 1 : 0
    custom_goods[good_id] = [item_type, item_id, price_type, price]
  end
  
  def get_shop(id)
    @shop_id = id
  end
  
  def setup_shop(shop)
    setup_sell_prices(shop)
  end
  
  def setup_sell_prices(shop)
    shop_options[:sell_price].each do |item_str, formula|
      type, id = item_str[0].downcase, item_str[1..-1].to_i
      case type
      when "i"
        item = $data_items[id]
      when "w"
        item = $data_weapons[id]
      when "a"
        item = $data_armors[id]
      end
      shop.set_sell_price(item, formula)
    end
  end
  
  #-----------------------------------------------------------------------------
  # New. You can do more things with your good here
  #-----------------------------------------------------------------------------
  def setup_good(good, good_id)
    setup_hidden_option(good, good_id)
    setup_disabled_option(good, good_id)
    setup_price_option(good, good_id)
  end
  
  #-----------------------------------------------------------------------------
  # New. Shop options
  #-----------------------------------------------------------------------------
  def price_good(good_id, price_formula)
    shop_options[:price][good_id] = price_formula
  end
  
  def hide_good(good_id, condition)
    shop_options[:hidden][good_id] = condition
  end
  
  def disable_good(good_id, condition)
    shop_options[:disabled][good_id] = condition
  end
  
  def sell_price(item_str, price_formula)
    shop_options[:sell_price][item_str] = price_formula
  end
  
  #-----------------------------------------------------------------------------
  # New. Apply shop option to the goods
  #-----------------------------------------------------------------------------  
  def setup_hidden_option(good, good_id)
    return unless shop_options[:hidden][good_id]
    good.hidden_condition = shop_options[:hidden][good_id]
  end
  
  def setup_disabled_option(good, good_id)
    return unless shop_options[:disabled][good_id]
    good.disable_condition = shop_options[:disabled][good_id]
  end
  
  def setup_price_option(good, good_id)
    return unless shop_options[:price][good_id]
    good.price_formula = shop_options[:price][good_id].to_s
  end
  
  def eval_shop_condition(formula, v=$game_variables, s=$game_switches, p=$game_party, t=$game_troop)
    eval(formula)
  end
end

#-------------------------------------------------------------------------------
# A shop good.
# This is a wrapper around a raw item (RPG::Item, RPG::Weapon, etc).
#-------------------------------------------------------------------------------

class Game_ShopGood
  
  attr_reader :id         # ID of this good
  attr_reader :item_type
  attr_reader :item_id
  attr_reader :price_type
  attr_accessor :hidden_condition
  attr_accessor :disable_condition
  attr_accessor :price_formula
  
  @@interpreter = Game_Interpreter.new
  
  def initialize(id, item_type, item_id, price_type, price)
    @id = id
    @item_type = item_type
    @item_id = item_id
    @price_type = price_type
    @price = price
    @hidden_condition = ""
    @disable_condition = ""
    @price_formula = ""
  end
  
  #-----------------------------------------------------------------------------
  # Determines whether the shop item should be included
  #-----------------------------------------------------------------------------
  def include?
    return false if eval_shop_condition(@hidden_condition)
    return true
  end
  
  #-----------------------------------------------------------------------------
  # Determines whether the shop item is enabled
  #-----------------------------------------------------------------------------
  def enable?
    return false if eval_shop_condition(@disable_condition)
    return true
  end
  
  #-----------------------------------------------------------------------------
  # Returns the appropriate object based on the item type. This implementation
  # is limited because it assumes you are pulling objects from the database.
  # Currently designed for compatibility with default implementation
  #-----------------------------------------------------------------------------
  def item
    return $data_items[@item_id] if @item_type == 0
    return $data_weapons[@item_id] if @item_type == 1
    return $data_armors[@item_id] if @item_type == 2
  end
  
  #-----------------------------------------------------------------------------
  # Returns the price of the shop good.
  #-----------------------------------------------------------------------------
  def price
    return eval_shop_condition(@price_formula) unless @price_formula.empty?
    return item.price if @price_type == 0
    return @price
  end
  
  #-----------------------------------------------------------------------------
  # Any shop formula that needs to be evaluated goes through here
  #-----------------------------------------------------------------------------
  def eval_shop_condition(formula)
    @@interpreter.eval_shop_condition(formula)
  end
end

#-------------------------------------------------------------------------------
# A shop object. Stores information about the shop such as its inventory
# and other shop-related data
#-------------------------------------------------------------------------------
class Game_Shop
  attr_reader   :purchase_only
  attr_reader   :shop_goods      # all goods that this shop has. 
  attr_accessor :need_refresh  # shop needs to be refreshed
  attr_accessor :sell_prices
  
  @@interpreter = Game_Interpreter.new
  
  def initialize(goods, purchase_only=false)
    @shop_goods = goods
    @purchase_only = purchase_only
    @need_refresh = false
    setup_sell_prices
  end
  
  def setup_sell_prices
    @items = {}
    @weapons = {}
    @armors = {}
  end
  
  #-----------------------------------------------------------------------------
  # Returns true if the goods should be included
  #-----------------------------------------------------------------------------
  def include?(index)
    true
  end
  
  #-----------------------------------------------------------------------------
  # Return a set of goods for sale
  #-----------------------------------------------------------------------------
  def goods
    @shop_goods
  end
  
  #-----------------------------------------------------------------------------
  # Add a new good to the shop
  #-----------------------------------------------------------------------------
  def add_good(good)
    @shop_goods.push(good) unless @shop_goods.include?(good)
  end
  
  #-----------------------------------------------------------------------------
  # Remove the specified good from the shop
  #-----------------------------------------------------------------------------
  def remove_good(good_id)
    @shop_goods.delete_at(good_id - 1)
  end
  
  def item_container(item)
    return @weapons if item.is_a?(RPG::Weapon)
    return @armors if item.is_a?(RPG::Armor)
    return @items if item.is_a?(RPG::Item)
  end
  
  def set_sell_price(item, price_formula)
    container = item_container(item)
    container[item.id] = price_formula
  end
  
  def sell_price(item)
    container = item_container(item)
    if container.include?(item.id)
      return @@interpreter.eval_shop_condition(container[item.id])
    else
      return 0
    end
  end
end

#-------------------------------------------------------------------------------
# A wrapper containing all shops in the game.
#-------------------------------------------------------------------------------
class Game_Shops
  
  #-----------------------------------------------------------------------------
  # Initializes a hash of game shops. Each key is a map ID, pointing to another
  # hash whose keys are event ID's and values are Game_Shop objects.
  #-----------------------------------------------------------------------------
  def initialize
    @data = {}
  end
  
  def [](id)
    @data[id]
  end
  
  def []=(id, shop)
    @data[id] = shop
  end
end

#-------------------------------------------------------------------------------
# The shop scene now works with the Shop and ShopGood objects
#-------------------------------------------------------------------------------
class Scene_Shop < Scene_MenuBase
  #--------------------------------------------------------------------------
  # Replaced. The scene now takes a Game_Shop object
  #--------------------------------------------------------------------------
  def prepare(shop)
    @shop = shop
    @goods = shop.goods
    @purchase_only = shop.purchase_only
  end
  
  alias :th_shop_manager_on_buy_ok :on_buy_ok
  def on_buy_ok
    @selected_good = @buy_window.current_good
    th_shop_manager_on_buy_ok
  end
  
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  alias :th_shop_manager_selling_price :selling_price
  def selling_price
    price = @shop.sell_price(@sell_window.item)
    if price != 0
      return price
    else
      return th_shop_manager_selling_price
    end
  end
end

#-------------------------------------------------------------------------------
# @shop_goods is now an array of Game_ShopGoods
#-------------------------------------------------------------------------------
class Window_ShopBuy < Window_Selectable
    
  #--------------------------------------------------------------------------
  # New. Returns true if the good should be included in the shop inventory
  #--------------------------------------------------------------------------
  def include?(shopGood)
    shopGood.include?
  end
  
  alias :th_shop_manager_enable? :enable?
  def enable?(item)
    return false unless @goods[item].enable?
    th_shop_manager_enable?(item)
  end
  
  #--------------------------------------------------------------------------
  # New. Get the currently selected good
  #--------------------------------------------------------------------------
  def current_good
    @goods[item]
  end
  
  #-----------------------------------------------------------------------------
  # Replaced. ShopGood takes care of most information. The data still contains
  # a list of RPG items for now since I don't want to change them to goods yet
  # A separate list of goods for sale is used for 1-1 correspondence
  #-----------------------------------------------------------------------------
  def make_item_list
    @data = []
    @goods = {}
    @price = {}
    @shop_goods.each do |shopGood|
      next unless include?(shopGood)
      item = shopGood.item
      @data.push(item)
      @goods[item] = shopGood
      @price[item] = shopGood.price
    end
  end
end