#==============================================================================
# Bravo Storage System
#------------------------------------------------------------------------------
# Author: Bravo2Kilo
# Version: 2.0
#
# Version History:
#   v1.0 = Initial Release
#   v1.1 = Fixed a bug and added some commands.
#   v2.0 = Added the ability to have multiple storage containers.
#==============================================================================
# Notes
#   If category and gold are both set to false, you can only exchange items,
#   if category is set to false and gold is set to true, you can only exchange
#   gold.
#==============================================================================
# To open the storage scene use this command in a script call.
#   open_storage(name, name_window, category, gold)
#     name = the name of the storage
#     name_window = (true or false)true to show the name window
#     category = (true or false)true to show the category window
#     gold = (true or false)true to show gold in the category window
#
# To add or remove items from a certain storage use this command in a script call
#   storage_add_item(name, type, id, amount)
#   storage_remove_item(name, type, id, amount)
#     name = the name of the storage
#     type = the type of item, can be(:item, :weapon, :armor)
#     id = the database id of the item
#     amount = the amount to add or remove
#
# To remove all items and gold in a certain storage use this command in a script call
#   clear_storage(name)
#     name = the name of the storage
#
# To check the amount of an item in a certain storage use this command in a script call
#   storage_item_number(name, type, id)
#     name = the name of the storage
#     type = the type of item, can be(:item, :weapon, :armor)
#     id = the database id of the item
#
# To add or remove gold from a certain storage use this command in a script call
#   storage_add_gold(name, amount)
#   storage_remove_gold(name, amount)
#     name = the name of the storage
#     amount = the amount to add or remove
#
# To check the amount of gold in a certain storage use this command in a script call
#   storage_gold_number(name)
#     name = the name of the storage
#
# If you want to set the max ammount of each item that can be in the storage,
# use this notetag, if a notetage isn't used it will use the default max that
# is defined below.
#   <storagemax: X> were X = the max.
#==============================================================================
module BRAVO_STORAGE
  # The default max of an item that can be in storage.
  ITEM_MAX = 99
  # The max amount of gold that can be stored.
  GOLD_MAX = 99999999
  # The command name for removing items from storage.
  WITHDRAW_TEXT = "Take Out"
  # The command name for putting items into storage.
  STORE_TEXT = "Put In"
  # The command name for leaving the storage scene.
  CANCEL_TEXT = "Leave"
  # The storage name window width
  NAME_WIDTH = 160
#==============================================================================
# End of Configuration
#==============================================================================
end
$imported ||= {}
$imported[:Bravo_Storage] = true

#==============================================================================
# ** RPG::BaseItem
#==============================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # * Item Storage Max
  #--------------------------------------------------------------------------
  def storage_max
    if @note =~ /<storagemax: (.*)>/i
      return $1.to_i
    else
      return BRAVO_STORAGE::ITEM_MAX
    end
  end
end

#==============================================================================
# ** Game_Temp
#==============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :storage_gold
  attr_accessor :storage_category
  attr_accessor :storage_name_window
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias bravo_storage_initialize initialize
  def initialize
    bravo_storage_initialize
    @storage_gold = true
    @storage_category = true
    @storage_name_window = true
  end
end

#==============================================================================
# ** Game_Party
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :storage_name
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias bravo_storage_initialize initialize
  def initialize
    bravo_storage_initialize
    @storage_gold = {}
    @storage_items = {}
    @storage_weapons = {}
    @storage_armors = {}
    @storage_name = nil
  end
  #--------------------------------------------------------------------------
  # * Initialize Storage
  #--------------------------------------------------------------------------
  def init_storage(name)
    @storage_gold[name] ||= 0
    @storage_items[name] ||= {}
    @storage_weapons[name] ||= {}
    @storage_armors[name] ||= {}
  end
  #--------------------------------------------------------------------------
  # * Storage Name =
  #--------------------------------------------------------------------------
  def storage_name=(name)
    return if @storage_name == name
    @storage_name = name
    init_storage(name)
  end
  #--------------------------------------------------------------------------
  # * Clear Storage
  #--------------------------------------------------------------------------
  def clear_storage
    @storage_gold[name] = 0
    @storage_items[name] = {}
    @storage_weapons[name] = {}
    @storage_armors[name] = {}
  end
  #--------------------------------------------------------------------------
  # * Get Item Object Array 
  #--------------------------------------------------------------------------
  def storage_items
    @storage_items[@storage_name].keys.sort.collect {|id| $data_items[id] }
  end
  #--------------------------------------------------------------------------
  # * Get Weapon Object Array 
  #--------------------------------------------------------------------------
  def storage_weapons
    @storage_weapons[@storage_name].keys.sort.collect {|id| $data_weapons[id] }
  end
  #--------------------------------------------------------------------------
  # * Get Armor Object Array 
  #--------------------------------------------------------------------------
  def storage_armors
    @storage_armors[@storage_name].keys.sort.collect {|id| $data_armors[id] }
  end
  #--------------------------------------------------------------------------
  # * Get Array of All Equipment Objects
  #--------------------------------------------------------------------------
  def storage_equip_items
    storage_weapons + storage_armors
  end
  #--------------------------------------------------------------------------
  # * Get Array of All Item Objects
  #--------------------------------------------------------------------------
  def storage_all_items
    storage_items + storage_equip_items
  end
  #--------------------------------------------------------------------------
  # * Get Container Object Corresponding to Item Class
  #--------------------------------------------------------------------------
  def storage_item_container(item_class)
    return @storage_items[@storage_name]   if item_class == RPG::Item
    return @storage_weapons[@storage_name] if item_class == RPG::Weapon
    return @storage_armors[@storage_name]  if item_class == RPG::Armor
    return nil
  end
  #--------------------------------------------------------------------------
  # * Storage Gold
  #--------------------------------------------------------------------------
  def storage_gold
    @storage_gold[@storage_name]
  end
  #--------------------------------------------------------------------------
  # * Increase Storage Gold
  #--------------------------------------------------------------------------
  def storage_gain_gold(amount)
    @storage_gold[@storage_name] = [[@storage_gold[@storage_name] + amount, 0].max, BRAVO_STORAGE::GOLD_MAX].min
  end
  #--------------------------------------------------------------------------
  # * Decrease Storage Gold
  #--------------------------------------------------------------------------
  def storage_lose_gold(amount)
    storage_gain_gold(-amount)
  end
  #--------------------------------------------------------------------------
  # * Get Maximum Number of Items in Storage
  #--------------------------------------------------------------------------
  def storage_max_item_number(item)
    return item.storage_max
  end
  #--------------------------------------------------------------------------
  # * Determine if Maximum Number of Items Are Possessed
  #--------------------------------------------------------------------------
  def storage_item_max?(item)
    storage_item_number(item) >= storage_max_item_number(item)
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items Possessed
  #--------------------------------------------------------------------------
  def storage_item_number(item)
    container = storage_item_container(item.class)
    container ? container[item.id] || 0 : 0
  end
  #--------------------------------------------------------------------------
  # * Increase/Decrease Storage Items
  #--------------------------------------------------------------------------
  def storage_gain_item(item, amount)
    container = storage_item_container(item.class)
    return unless container
    last_number = storage_item_number(item)
    new_number = last_number + amount
    container[item.id] = [[new_number, 0].max, storage_max_item_number(item)].min
    container.delete(item.id) if container[item.id] == 0
  end
  #--------------------------------------------------------------------------
  # * Remove Storage Items
  #--------------------------------------------------------------------------
  def storage_lose_item(item, amount)
    storage_gain_item(item, -amount)
  end
end

#==============================================================================
# ** Game_Interpreter
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Open Storage Scene
  #--------------------------------------------------------------------------
  def open_storage(name, name_window = true, category = true, gold = true)
    $game_party.storage_name = name
    $game_temp.storage_name_window = name_window
    $game_temp.storage_category = category
    $game_temp.storage_gold = gold
    SceneManager.call(Scene_Storage)
  end
  #--------------------------------------------------------------------------
  # * Clear Storage
  #--------------------------------------------------------------------------
  def clear_storage(name)
    $game_party.clear_storage(name)
  end
  #--------------------------------------------------------------------------
  # * Storage Add Item
  #--------------------------------------------------------------------------
  def storage_add_item(name, type, id, amount)
    $game_party.storage_name = name
    case type
    when :item
      item = $data_items[id]
    when :weapon
      item = $data_weapons[id]
    when :armor
      item = $data_armors[id]
    end
    $game_party.storage_gain_item(item, amount)
  end
  #--------------------------------------------------------------------------
  # * Storage Remove Item
  #--------------------------------------------------------------------------
  def storage_remove_item(name, type, id, amount)
    $game_party.storage_name = name
    case type
    when :item
      item = $data_items[id]
    when :weapon
      item = $data_weapons[id]
    when :armor
      item = $data_armors[id]
    end
    $game_party.storage_lose_item(item, amount)
  end
  #--------------------------------------------------------------------------
  # * Storage Item Number
  #--------------------------------------------------------------------------
  def storage_item_number(name, type, id)
    $game_party.storage_name = name
    case type
    when :item
      item = $data_items[id]
    when :weapon
      item = $data_weapons[id]
    when :armor
      item = $data_armors[id]
    end
    $game_party.storage_item_number(item)
  end
  #--------------------------------------------------------------------------
  # * Storage Add Gold
  #--------------------------------------------------------------------------
  def storage_add_gold(name, amount)
    $game_party.storage_name = name
    $game_party.storage_gain_gold(amount)
  end
  #--------------------------------------------------------------------------
  # * Storage Remove Gold
  #--------------------------------------------------------------------------
  def storage_remove_gold(name, amount)
    $game_party.storage_name = name
    $game_party.storage_lose_gold(amount)
  end
  #--------------------------------------------------------------------------
  # * Storage Gold Number
  #--------------------------------------------------------------------------
  def storage_gold_number(name)
    $game_party.storage_name = name
    $game_party.storage_gold
  end
end

#==============================================================================
# ** Window_StorageCategory
#==============================================================================

class Window_StorageCategory < Window_ItemCategory
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(gold)
    @gold = gold
    super()
  end
  #--------------------------------------------------------------------------
  # * Get Digit Count
  #--------------------------------------------------------------------------
  def col_max
    if @gold == true
      return 4
    else
      return 3
    end
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::item, :item)
    add_command(Vocab::weapon, :weapon)
    add_command(Vocab::armor, :armor)
    add_command(Vocab::currency_unit, :gold) if @gold == true
  end
end

#==============================================================================
# ** Window_ItemList
#------------------------------------------------------------------------------
#  This window displays a list of party items on the item screen.
#==============================================================================

class Window_StorageItemList < Window_ItemList
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @storage = :none
  end
  #--------------------------------------------------------------------------
  # * Set Storage Flag
  #--------------------------------------------------------------------------
  def storage=(storage)
    return if @storage == storage
    @storage = storage
    refresh
    self.oy = 0
  end
  #--------------------------------------------------------------------------
  # * Include in Item List?
  #--------------------------------------------------------------------------
  def include?(item)
    case @category
    when :item
      item.is_a?(RPG::Item)
    when :weapon
      item.is_a?(RPG::Weapon)
    when :armor
      item.is_a?(RPG::Armor)
    when :all
      item
    else
      false
    end
  end
  #--------------------------------------------------------------------------
  # * Display in Enabled State?
  #--------------------------------------------------------------------------
  def enable?(item)
    if item.is_a?(RPG::Item)
      return true if !item.key_item?
    elsif item.is_a?(RPG::Weapon) || item.is_a?(RPG::Armor)
      return true
    else
      return false
    end
  end
  #--------------------------------------------------------------------------
  # * Create Item List
  #--------------------------------------------------------------------------
  def make_item_list
    case @storage
    when :store
      @data = $game_party.all_items.select {|item| include?(item) }
      @data.push(nil) if include?(nil)
    when :withdraw
      @data = $game_party.storage_all_items.select {|item| include?(item) }
      @data.push(nil) if include?(nil)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Number of Items
  #--------------------------------------------------------------------------
  def draw_item_number(rect, item)
    case @storage
    when :store
      draw_text(rect, sprintf(":%2d", $game_party.item_number(item)), 2)
    when :withdraw
      draw_text(rect, sprintf(":%2d", $game_party.storage_item_number(item)), 2)
    end
  end
end

#==============================================================================
# ** Window_StorageCommand
#==============================================================================

class Window_StorageCommand < Window_HorzCommand
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0)
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    if $game_temp.storage_name_window == false
      return 544
    else
      Graphics.width - BRAVO_STORAGE::NAME_WIDTH
    end
  end
  #--------------------------------------------------------------------------
  # * Get Digit Count
  #--------------------------------------------------------------------------
  def col_max
    return 3
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(BRAVO_STORAGE::WITHDRAW_TEXT, :withdraw)
    add_command(BRAVO_STORAGE::STORE_TEXT, :store)
    add_command(BRAVO_STORAGE::CANCEL_TEXT, :cancel)
  end
end

#==============================================================================
# ** Window_StorageName
#==============================================================================
class Window_StorageName < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, fitting_height(1))
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return BRAVO_STORAGE::NAME_WIDTH
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    name = $game_party.storage_name
    draw_text(0, 0, window_width, line_height, name)
  end
  #--------------------------------------------------------------------------
  # * Open Window
  #--------------------------------------------------------------------------
  def open
    refresh
    super
  end
end

#==============================================================================
# ** Window_StorageNumber
#==============================================================================

class Window_StorageNumber < Window_Selectable
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :number                   # quantity entered
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, window_height) 
    @item = nil
    @max = 1
    @number = 1
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return 304
  end
  #--------------------------------------------------------------------------
  # * Get Window Height
  #--------------------------------------------------------------------------
  def window_height
    return 48
  end
  #--------------------------------------------------------------------------
  # * Set Item, Max Quantity
  #--------------------------------------------------------------------------
  def set(item, max)
    @item = item
    @max = max
    @number = 1
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_item_name(@item, 0, 0)
    draw_number
  end
  #--------------------------------------------------------------------------
  # * Draw Quantity
  #--------------------------------------------------------------------------
  def draw_number
    change_color(normal_color)
    draw_text(cursor_x - 28, 0, 22, line_height, "×")
    draw_text(cursor_x, 0, cursor_width - 4, line_height, @number, 2)
  end
  #--------------------------------------------------------------------------
  # * Get Cursor Width
  #--------------------------------------------------------------------------
  def cursor_width
    figures * 10 + 12
  end
  #--------------------------------------------------------------------------
  # * Get X Coordinate of Cursor
  #--------------------------------------------------------------------------
  def cursor_x
    contents_width - cursor_width - 4
  end
  #--------------------------------------------------------------------------
  # * Get Maximum Number of Digits for Quantity Display
  #--------------------------------------------------------------------------
  def figures
    return 2
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if active
      last_number = @number
      update_number
      if @number != last_number
        Sound.play_cursor
        refresh
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Update Quantity
  #--------------------------------------------------------------------------
  def update_number
    change_number(1)   if Input.repeat?(:RIGHT)
    change_number(-1)  if Input.repeat?(:LEFT)
    change_number(10)  if Input.repeat?(:UP)
    change_number(-10) if Input.repeat?(:DOWN)
  end
  #--------------------------------------------------------------------------
  # * Change Quantity
  #--------------------------------------------------------------------------
  def change_number(amount)
    @number = [[@number + amount, @max].min, 1].max
  end
  #--------------------------------------------------------------------------
  # * Update Cursor
  #--------------------------------------------------------------------------
  def update_cursor
    cursor_rect.set(cursor_x, 0, cursor_width, line_height)
  end
end

#==============================================================================
# ** Window_GoldTransfer
#==============================================================================

class Window_GoldTransfer < Window_Selectable
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :number                   # quantity entered
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, window_height) 
    @item = nil
    @max = 1
    @number = 1
    @cursor_y = 0
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return 330
  end
  #--------------------------------------------------------------------------
  # * Get Window Height
  #--------------------------------------------------------------------------
  def window_height
    return 72
  end
  #--------------------------------------------------------------------------
  # * Set Item, Max Quantity
  #--------------------------------------------------------------------------
  def set(max, position)
    @max = max
    @number = 1
    @cursor_y = position
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_gold_info
    draw_number
  end
  #--------------------------------------------------------------------------
  # * Display in Enabled State?
  #--------------------------------------------------------------------------
  def enabled?
    if @cursor_y == 0
      return true if $game_party.gold > 0
    else
      return true if $game_party.storage_gold > 0
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Processing When OK Button Is Pressed
  #--------------------------------------------------------------------------
  def process_ok
    if enabled?
      Sound.play_ok
      Input.update
      deactivate
      call_ok_handler
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Gold Info
  #--------------------------------------------------------------------------
  def draw_gold_info
    party = "Party " + Vocab::currency_unit + " :"
    storage = "Storage " + Vocab::currency_unit + " :"
    draw_text(0, 0, 280, line_height, party)
    draw_text(0, 24, 280, line_height, storage)
    draw_text(0, 0, 225, line_height, $game_party.gold, 2)
    draw_text(0, 24, 225, line_height, $game_party.storage_gold, 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Quantity
  #--------------------------------------------------------------------------
  def draw_number
    change_color(normal_color)
    draw_text(cursor_x - 28, @cursor_y, 22, line_height, "×")
    draw_text(cursor_x, @cursor_y, cursor_width - 4, line_height, @number, 2)
  end
  #--------------------------------------------------------------------------
  # * Get Cursor Width
  #--------------------------------------------------------------------------
  def cursor_width
    figures * 10 + 12
  end
  #--------------------------------------------------------------------------
  # * Get X Coordinate of Cursor
  #--------------------------------------------------------------------------
  def cursor_x
    contents_width - cursor_width - 4
  end
  #--------------------------------------------------------------------------
  # * Get Maximum Number of Digits for Quantity Display
  #--------------------------------------------------------------------------
  def figures
    return 3
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if active
      last_number = @number
      update_number
      if @number != last_number
        Sound.play_cursor
        refresh
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Update Quantity
  #--------------------------------------------------------------------------
  def update_number
    change_number(1)   if Input.repeat?(:RIGHT)
    change_number(-1)  if Input.repeat?(:LEFT)
    change_number(10)  if Input.repeat?(:UP)
    change_number(-10) if Input.repeat?(:DOWN)
  end
  #--------------------------------------------------------------------------
  # * Change Quantity
  #--------------------------------------------------------------------------
  def change_number(amount)
    @number = [[@number + amount, @max].min, 1].max
  end
  #--------------------------------------------------------------------------
  # * Update Cursor
  #--------------------------------------------------------------------------
  def update_cursor
    @cursor_y ||= 0
    cursor_rect.set(cursor_x, @cursor_y, cursor_width, line_height)
  end
end

#==============================================================================
# ** Scene_Storage
#==============================================================================

class Scene_Storage < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    @storage_gold = $game_temp.storage_gold
    @storage_category = $game_temp.storage_category
    @storage_name_window = $game_temp.storage_name_window
    create_help_window
    create_command_window
    create_name_window
    create_dummy_window
    create_category_window
    create_item_window
    create_number_window
    create_gold_window
  end
  #--------------------------------------------------------------------------
  # * Create Command Window
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_StorageCommand.new
    @command_window.viewport = @viewport
    @command_window.y = @help_window.height
    @command_window.set_handler(:withdraw, method(:command_withdraw))
    @command_window.set_handler(:store, method(:command_store))
    @command_window.set_handler(:cancel, method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # * Create Storage Name Window
  #--------------------------------------------------------------------------
  def create_name_window
    @name_window = Window_StorageName.new
    @name_window.viewport = @viewport
    @name_window.x = @command_window.width
    @name_window.y = @help_window.height
    if @storage_name_window == true
      @name_window.show
    end
  end
  #--------------------------------------------------------------------------
  # * Create Dummy Window
  #--------------------------------------------------------------------------
  def create_dummy_window
    wy = @command_window.y + @command_window.height
    wh = Graphics.height - wy
    @dummy_window = Window_Base.new(0, wy, Graphics.width, wh)
    @dummy_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # * Create Quantity Input Window
  #--------------------------------------------------------------------------
  def create_number_window
    @number_window = Window_StorageNumber.new
    @number_window.viewport = @viewport
    @number_window.x = ((Graphics.width / 2) - (@number_window.width / 2)) 
    @number_window.y = ((Graphics.height / 2) - (@number_window.height / 2)) 
    @number_window.hide
    @number_window.set_handler(:ok,     method(:on_number_ok))
    @number_window.set_handler(:cancel, method(:on_number_cancel))
  end
  #--------------------------------------------------------------------------
  # * Create Category Window
  #--------------------------------------------------------------------------
  def create_category_window
    @category_window = Window_StorageCategory.new(@storage_gold)
    @category_window.viewport = @viewport
    @category_window.help_window = @help_window
    @category_window.y = @dummy_window.y
    @category_window.hide.deactivate
    @category_window.set_handler(:ok,     method(:on_category_ok))
    @category_window.set_handler(:cancel, method(:on_category_cancel))
  end
  #--------------------------------------------------------------------------
  # * Create Item Window
  #--------------------------------------------------------------------------
  def create_item_window
    if @storage_category == false
      wy = @command_window.y + @command_window.height
    else
      wy = @category_window.y + @category_window.height
    end
    wh = Graphics.height - wy
    @item_window = Window_StorageItemList.new(0, wy, Graphics.width, wh)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.hide
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    if @storage_category == false
      @item_window.category = :all
    else
      @category_window.item_window = @item_window
    end
  end
  #--------------------------------------------------------------------------
  # * Create Item Window
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_GoldTransfer.new
    @gold_window.viewport = @viewport
    @gold_window.x = ((Graphics.width / 2) - (@gold_window.width / 2)) 
    @gold_window.y = ((Graphics.height / 2) - (@gold_window.height / 2)) 
    @gold_window.hide
    @gold_window.set_handler(:ok,     method(:on_gold_ok))
    @gold_window.set_handler(:cancel, method(:on_gold_cancel))
  end
  #--------------------------------------------------------------------------
  # * Start Category Selection
  #--------------------------------------------------------------------------
  def start_category_selection
    @dummy_window.hide
    @item_window.show
    @item_window.unselect
    @item_window.refresh
    @item_window.storage = @command_window.current_symbol
    @category_window.show.activate
  end
  #--------------------------------------------------------------------------
  # * [Withdraw] Command
  #--------------------------------------------------------------------------
  def command_withdraw
    if @storage_category == false and @storage_gold == true
      case @command_window.current_symbol
      when :withdraw
        @gold_window.set(max_withdraw, 24)
      when :store
        @gold_window.set(max_store, 0)
      end
      @gold_window.show.activate
    elsif @storage_category == false
      @dummy_window.hide
      @item_window.show.activate
      @item_window.storage = @command_window.current_symbol
      @item_window.select_last
    else
      start_category_selection
    end
  end
  #--------------------------------------------------------------------------
  # * [Store] Command
  #--------------------------------------------------------------------------
  def command_store
    if @storage_category == false and @storage_gold == true
      case @command_window.current_symbol
      when :withdraw
        @gold_window.set(max_withdraw, 24)
      when :store
        @gold_window.set(max_store, 0)
      end
      @gold_window.show.activate
    elsif @storage_category == false
      @dummy_window.hide
      @item_window.show.activate
      @item_window.storage = @command_window.current_symbol
      @item_window.select_last
    else
      start_category_selection
    end
  end
  #--------------------------------------------------------------------------
  # * Category [OK]
  #--------------------------------------------------------------------------
  def on_category_ok
    case @category_window.current_symbol
    when :item, :weapon, :armor
      @item_window.activate
      @item_window.select_last
    when :gold
      case @command_window.current_symbol
      when :withdraw
        @gold_window.set(max_withdraw, 24)
      when :store
        @gold_window.set(max_store, 0)
      end
      @gold_window.show.activate
    end
  end
  #--------------------------------------------------------------------------
  # * Category [Cancel]
  #--------------------------------------------------------------------------
  def on_category_cancel
    @command_window.activate
    @dummy_window.show
    @item_window.hide
    @category_window.hide
  end
  #--------------------------------------------------------------------------
  # * Item [OK]
  #--------------------------------------------------------------------------
  def on_item_ok
    @item = @item_window.item
    case @command_window.current_symbol
    when :withdraw
      @number_window.set(@item, max_withdraw)
    when :store
      @number_window.set(@item, max_store)
    end
    @number_window.show.activate
  end
  #--------------------------------------------------------------------------
  # * Item [Cancel]
  #--------------------------------------------------------------------------
  def on_item_cancel
    @item_window.unselect
    if @storage_category == false
      @item_window.hide
      @dummy_window.show
      @command_window.activate
    else
      @category_window.activate
    end
  end
  #--------------------------------------------------------------------------
  # * Quantity Input [OK]
  #--------------------------------------------------------------------------
  def on_number_ok
    Sound.play_ok
    case @command_window.current_symbol
    when :withdraw
      do_withdraw(@number_window.number)
    when :store
      do_store(@number_window.number)
    end
    @number_window.hide
    @item_window.refresh
    @item_window.activate
    @item_window.select_last
  end
  #--------------------------------------------------------------------------
  # * Quantity Input [Cancel]
  #--------------------------------------------------------------------------
  def on_number_cancel
    Sound.play_cancel
    @number_window.hide
    @item_window.activate
  end
  #--------------------------------------------------------------------------
  # * Gold Quantity Input [OK]
  #--------------------------------------------------------------------------
  def on_gold_ok
    case @command_window.current_symbol
    when :withdraw
      gold_withdraw(@gold_window.number)
      @gold_window.set(max_withdraw, 24)
    when :store
      gold_store(@gold_window.number)
      @gold_window.set(max_store, 0)
    end
    @gold_window.show.activate
    @gold_window.refresh
    Sound.play_ok
  end
  #--------------------------------------------------------------------------
  # * Gold Quantity Input [Cancel]
  #--------------------------------------------------------------------------
  def on_gold_cancel
    Sound.play_cancel
    if @storage_category == false && @storage_gold == true
      @command_window.activate
    else
      start_category_selection
    end
    @gold_window.hide
  end
  #--------------------------------------------------------------------------
  # * Execute Withdraw
  #--------------------------------------------------------------------------
  def do_withdraw(number)
    $game_party.storage_lose_item(@item, number)
    $game_party.gain_item(@item, number)
  end
  #--------------------------------------------------------------------------
  # * Execute Store
  #--------------------------------------------------------------------------
  def do_store(number)
    $game_party.storage_gain_item(@item, number)
    $game_party.lose_item(@item, number)
  end
  #--------------------------------------------------------------------------
  # * Gold Withdraw
  #--------------------------------------------------------------------------
  def gold_withdraw(number)
    $game_party.storage_lose_gold(number)
    $game_party.gain_gold(number)
  end
  #--------------------------------------------------------------------------
  # * Gold Store
  #--------------------------------------------------------------------------
  def gold_store(number)
    $game_party.lose_gold(number)
    $game_party.storage_gain_gold(number)
  end
  #--------------------------------------------------------------------------
  # * Get Maximum Quantity Withdrawable
  #--------------------------------------------------------------------------
  def max_withdraw
    case @category_window.current_symbol
    when :item, :weapon, :armor
      if $game_party.storage_item_number(@item) > 99
        return 99
      else
        $game_party.storage_item_number(@item)
      end
    when :gold
      if $game_party.storage_gold > 999
        return 999
      else
        $game_party.storage_gold
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Get Maximum Quantity Storable
  #--------------------------------------------------------------------------
  def max_store
    case @category_window.current_symbol
    when :item, :weapon, :armor
      if $game_party.item_number(@item) > 99
        return 99
      else
        $game_party.item_number(@item)
      end
    when :gold
      if $game_party.gold > 999
        return 999
      else
        $game_party.gold
      end
    end
  end
end