=begin
#===============================================================================
 Title: Actor Inventory Scenes
 Author: Hime
 Date: Mar 10, 2014
--------------------------------------------------------------------------------
 ** Change log
 Mar 10, 2014
   - key item list is pulled from the leader
 Jul 27, 2013
   - Initial release
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
 
 This script provides scenes and windows to complement the Actor Inventory
 system. It is based on the default scenes and windows.
 
--------------------------------------------------------------------------------
 ** Required
 
 Actor Inventory
 (http://himeworks.com/2013/07/27/actor-inventory/)
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Actor Inventory and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 Plug and play.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_ActorInventoryScenes"] = true
#===============================================================================
# ** Rest of script
#===============================================================================
#-------------------------------------------------------------------------------
# Basic actor inventory scene and windows. Change it so that you first select
# an actor before opening the item menu. The item windows must obtain the data
# from the actor's inventory
#-------------------------------------------------------------------------------
class Window_ItemList < Window_Selectable
  
  alias :th_actor_inventory_initialize :initialize
  def initialize(x, y, width, height)
    th_actor_inventory_initialize(x, y, width, height)
    @actor ||= $game_party.leader
  end
  
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  
  def make_item_list
    @data = @actor.all_items.select {|item| include?(item) }
    @data.push(nil) if include?(nil)
  end
  
  def enable?(item)
    @actor.usable?(item)
  end
  
  def select_last
    select(@data.index(@actor.last_item.object) || 0)
  end
  
  def draw_item_number(rect, item)
    draw_text(rect, sprintf(":%2d", @actor.item_number(item)), 2)
  end
end

class Scene_Item < Scene_ItemBase
  
  alias :th_actor_inventory_create_category_window :create_category_window
  def create_category_window
    th_actor_inventory_create_category_window
    @category_window.set_handler(:pagedown, method(:next_actor))
    @category_window.set_handler(:pageup,   method(:prev_actor))
  end
  
  alias :th_actor_inventory_create_item_window :create_item_window
  def create_item_window
    th_actor_inventory_create_item_window
    @item_window.actor = @actor
    @item_window.set_handler(:pagedown, method(:next_actor))
    @item_window.set_handler(:pageup,   method(:prev_actor))
  end
  
  #-----------------------------------------------------------------------------
  # Replace
  #-----------------------------------------------------------------------------
  def user
    @actor
  end
  
  #-----------------------------------------------------------------------------
  # Replace
  #-----------------------------------------------------------------------------
  def on_item_ok
    @actor.last_item.object = item
    determine_item
  end
  
  def on_actor_change
    @item_window.actor = @actor
    activate_current_window
  end
  
  #-----------------------------------------------------------------------------
  # Activate the appropriate window depending on which window is currently
  # active
  #-----------------------------------------------------------------------------
  def activate_current_window
    if @item_window.index > -1
      @item_window.activate
    else
      @category_window.activate
    end
  end
end

#-------------------------------------------------------------------------------
# Need to change these as well
#-------------------------------------------------------------------------------
class Scene_Menu < Scene_MenuBase
  def command_item
    command_personal
  end
  
  alias :th_actor_inventory_on_personal_ok :on_personal_ok
  def on_personal_ok
    return SceneManager.call(Scene_Item) if @command_window.current_symbol == :item
    th_actor_inventory_on_personal_ok
  end
end
#-------------------------------------------------------------------------------
# Need to change these as well
#-------------------------------------------------------------------------------
class Window_BattleItem < Window_ItemList
    
  #--------------------------------------------------------------------------
  # * Include in Item List?
  #--------------------------------------------------------------------------
  def include?(item)
    @actor ? @actor.usable?(item) : false
  end
end

class Scene_Battle < Scene_Base
  
  alias :th_actor_inventory_command_item :command_item
  def command_item
    @item_window.actor = BattleManager.actor
    th_actor_inventory_command_item
  end
  
  alias :th_actor_inventory_on_item_ok :on_item_ok
  def on_item_ok
    th_actor_inventory_on_item_ok
    BattleManager.actor.last_item.object = @item
  end
end
#-------------------------------------------------------------------------------
# You must first choose who is going to buy
#-------------------------------------------------------------------------------
class Window_ShopStatus < Window_Base
  
  alias :th_actor_inventory_initialize :initialize
  def initialize(x, y, width, height)
    @actor = nil
    th_actor_inventory_initialize(x, y, width, height)
  end
  
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  
  def draw_current_actor(x, y)
    rect = Rect.new(x, y, contents.width - 4 - x, line_height)
    change_color(system_color)
    draw_text(rect, @actor.name)
  end
  
  alias :th_actor_inventory_draw_possession :draw_possession
  def draw_possession(x, y)
    if @actor
      draw_current_actor(x, y) 
      rect = Rect.new(x, y + line_height, contents.width - 4 - x, line_height)
      change_color(system_color)
      draw_text(rect, Vocab::Possession)
      change_color(normal_color)
      draw_text(rect, @actor.item_number(@item), 2)
    end
  end
end

class Window_ShopBuy < Window_Selectable
  
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  
  def enable?(item)
    item && price(item) <= @money && @actor && !@actor.item_max?(item)
  end
end

class Window_ShopSell < Window_ItemList
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
end

class Scene_Shop < Scene_MenuBase
  
  alias :th_actor_inventory_start :start
  def start
    th_actor_inventory_start
    @actor = $game_party.leader
  end
  
  alias :th_actor_inventory_create_status_window :create_status_window
  def create_status_window
    th_actor_inventory_create_status_window
    @status_window.actor = @actor
  end
  
  alias :th_actor_inventory_create_buy_window :create_buy_window
  def create_buy_window
    th_actor_inventory_create_buy_window
    @buy_window.set_handler(:pagedown, method(:next_actor))
    @buy_window.set_handler(:pageup,   method(:prev_actor))
    @buy_window.actor = @actor
  end
  
  alias :th_actor_inventory_create_sell_window :create_sell_window
  def create_sell_window
    th_actor_inventory_create_sell_window
    @sell_window.set_handler(:pagedown, method(:next_actor))
    @sell_window.set_handler(:pageup,   method(:prev_actor))
    @sell_window.actor = @actor
  end
  
  #-----------------------------------------------------------------------------
  # Overwrite
  #-----------------------------------------------------------------------------
  def max_buy
    max = @actor.max_item_number(@item) - @actor.item_number(@item)
    buying_price == 0 ? max : [max, money / buying_price].min
  end
  
  #-----------------------------------------------------------------------------
  # Overwrite
  #-----------------------------------------------------------------------------
  def max_sell
    @actor.item_number(@item)
  end
  
  #-----------------------------------------------------------------------------
  # Overwrite
  #-----------------------------------------------------------------------------
  def do_buy(number)
    $game_party.lose_gold(number * buying_price)
    @actor.gain_item(@item, number)
  end
  
  #-----------------------------------------------------------------------------
  # Overwrite
  #-----------------------------------------------------------------------------
  def do_sell(number)
    $game_party.gain_gold(number * selling_price)
    @actor.lose_item(@item, number)
  end
  
  def on_actor_change
    @status_window.actor = @actor    
    @buy_window.actor = @actor
    @sell_window.actor = @actor
    activate_current_window
  end
  
  def activate_current_window
    case @command_window.current_symbol
    when :buy
      @buy_window.activate
    when :sell
      @sell_window.activate
    end
  end
end