=begin
#===============================================================================
 Title: Actor Trade Scene
 Author: Hime
 Date: Jul 20, 2013
--------------------------------------------------------------------------------
 ** Change log
 Jul 20, 2014
   - added some checks to verify that a target actor exists for trading
 Nov 11, 2013
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to HimeWorks in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to trade items between actors using a custom trade
 scene.
 
--------------------------------------------------------------------------------
 ** Required 
 
 Actor Inventory
 (http://himeworks.com/2013/07/27/actor-inventory/)
 
--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Actor Inventory and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 To access the trade scene, use the script call
 
   SceneManager.call(Scene_ActorTrade)
   
 This script provides the command in the party menu.
 When you click on the "Trade" command, it will go to the trade scene.
 
 In the trade scene, select a category, and the actor face will be selected.
 You can press left or right to switch between the two windows.
 Press page up and page down to change actors.
 
 Press OK on the actor to activate the item list. When you select an item, it
 will be traded to the other actor.
 
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_ActorTradeScene"] = true
#===============================================================================
# ** Rest of Script
#===============================================================================
class Window_TradeItemCategory < Window_HorzCommand
  
  def window_width
    Graphics.width
  end
  
  def col_max
    return 4
  end
  
  def update
    super
    @source_item_window.category = current_symbol if @source_item_window
    @target_item_window.category = current_symbol if @target_item_window
  end
  
  def make_command_list
    add_command(Vocab::item,     :item)
    add_command(Vocab::weapon,   :weapon)
    add_command(Vocab::armor,    :armor)
    add_command(Vocab::key_item, :key_item)
  end
  
  def source_item_window=(item_window)
    @source_item_window = item_window
    update
  end
  
  def target_item_window=(item_window)
    @target_item_window = item_window
    update
  end
end

class Window_TradeStatus < Window_Selectable
  
  attr_reader :actor
  
  def initialize(x, y, width, height)
    super
    @actor = nil
    refresh
  end
  
  def item_width
    width - padding * 2
  end 
  
  def item_height
    height - padding * 2
  end
  
  def actor=(actor)
    if @actor != actor
      @actor = actor
      refresh
    end
  end
  
  def draw_status(actor, x, y)
    draw_actor_face(actor, 0, 0)
    draw_actor_name(actor, x, y)
    draw_actor_level(actor, x, y + line_height * 1)
    draw_actor_icons(actor, x, y + line_height * 2)
  end
  
  def refresh
    return unless @actor
    contents.clear
    draw_status(@actor, 108, 0)
    if @item_window
      @item_window.actor = @actor
    end
  end
  
  def item_window=(item_window)
    @item_window = item_window
    refresh
  end
  
  def update_help
    @help_window.set_text("Press page-up or page-down to scroll through actors.\nPress -> or <- to switch between windows")
  end
  
  def process_handling
    return unless open? && active
    return process_change if Input.trigger?(:LEFT) || Input.trigger?(:RIGHT)
    super
  end
  
  def process_change
    Input.update
    call_handler(:change)
  end
end

class Window_TradeItemList < Window_ItemList
  
  def initialize(x, y, width, height)
    super
    @actor = nil
  end
  
  def col_max
    1
  end
  
  def actor=(actor)
    if @actor != actor
      @actor = actor
      refresh
    end
  end
  
  def enable?(item)
    return false unless item
    true
  end
  
  def select_last
    idx = @actor.nil? ? 0 : @data.index(@actor.last_item.object) || 0
    select(idx)
  end
  
  def make_item_list
    @data = @actor.all_items.select {|item| include?(item) }
    @data.push(nil) if include?(nil)
  end
  
  def draw_item_number(rect, item)
    draw_text(rect, sprintf(":%2d", @actor.item_number(item)), 2)
  end
  
  def refresh
    return unless @actor
    super
  end
  
  def process_handling
    return unless open? && active
    return process_change if Input.trigger?(:LEFT) || Input.trigger?(:RIGHT)
    super
  end
  
  #-----------------------------------------------------------------------------
  # We should let the scene handle all the logic
  #-----------------------------------------------------------------------------
  def process_ok
    if current_item_enabled?
      Input.update
      deactivate
      call_ok_handler
    else
      Sound.play_buzzer
    end
  end
  
  def process_change
    Input.update
    call_handler(:change)
  end
end

class Scene_ActorTrade < Scene_Base
  
  def start
    super
    create_all_windows
    @source_actor = $game_party.members[0]
    @target_actor = $game_party.members[1]
    refresh_actors
  end
  
  def create_all_windows
    create_help_window
    create_category_window
    create_source_status_window
    create_target_status_window
    create_source_trade_window
    create_target_trade_window
  end
  
  def create_help_window
    @help_window = Window_Help.new
  end
  
  def create_category_window
    wy = @help_window.y + @help_window.height
    @category_window = Window_TradeItemCategory.new(0, wy)
    @category_window.set_handler(:ok, method(:on_category_ok))
    @category_window.set_handler(:cancel, method(:on_category_cancel))
    @category_window.help_window = @help_window
  end
  
  def create_source_status_window
    wy = @category_window.y + @category_window.height
    @source_status_window = Window_TradeStatus.new(0, wy, Graphics.width / 2, 96)
    @source_status_window.set_handler(:ok, method(:on_source_status_ok))
    @source_status_window.set_handler(:cancel, method(:on_source_status_cancel))
    @source_status_window.set_handler(:change, method(:on_status_change))
    @source_status_window.set_handler(:pageup, method(:on_source_actor_change))
    @source_status_window.set_handler(:pagedown, method(:on_source_actor_change))
    @source_status_window.help_window = @help_window
  end
  
  def create_target_status_window
    wy = @category_window.y + @category_window.height
    @target_status_window = Window_TradeStatus.new(Graphics.width / 2, wy, Graphics.width / 2, 96)
    @target_status_window.set_handler(:ok, method(:on_target_status_ok))
    @target_status_window.set_handler(:cancel, method(:on_target_status_cancel))
    @target_status_window.set_handler(:change, method(:on_status_change))
    @target_status_window.set_handler(:pageup, method(:on_target_actor_change))
    @target_status_window.set_handler(:pagedown, method(:on_target_actor_change))
    @target_status_window.help_window = @help_window
  end
  
  def create_source_trade_window
    wy = @source_status_window.y + @source_status_window.height
    height = Graphics.height - wy
    @source_trade_window = Window_TradeItemList.new(0, wy, Graphics.width / 2, height)
    @source_trade_window.set_handler(:ok, method(:on_source_trade_window_ok))
    @source_trade_window.set_handler(:cancel, method(:on_source_trade_window_cancel))
    @source_trade_window.set_handler(:change, method(:on_window_change))
    @source_trade_window.help_window = @help_window
    @source_status_window.item_window = @source_trade_window
    @category_window.source_item_window = @source_trade_window
  end
  
  def create_target_trade_window
    wy = @target_status_window.y + @target_status_window.height
    height = Graphics.height - wy
    @target_trade_window = Window_TradeItemList.new(Graphics.width / 2, wy, Graphics.width / 2, height)
    @target_trade_window.set_handler(:ok, method(:on_target_trade_window_ok))
    @target_trade_window.set_handler(:cancel, method(:on_target_trade_window_cancel))
    @target_trade_window.set_handler(:change, method(:on_window_change))
    @target_trade_window.help_window = @help_window
    @target_status_window.item_window = @target_trade_window
    @category_window.target_item_window = @target_trade_window
  end
  
  def refresh_actors
    @source_status_window.actor = @source_actor 
    @target_status_window.actor = @target_actor
  end
  
  def refresh_windows
    @source_status_window.refresh
    @target_status_window.refresh
    @source_trade_window.refresh
    @target_trade_window.refresh
  end
  
  def on_window_change
    return unless @target_actor
    if @source_trade_window.active
      @source_trade_window.unselect
      @source_trade_window.deactivate
      @target_trade_window.select_last
      @target_trade_window.activate
    else
      @target_trade_window.unselect
      @target_trade_window.deactivate
      @source_trade_window.select_last
      @source_trade_window.activate
    end
  end
  
  def on_status_change
    return unless @target_actor
    if @source_status_window.active
      @source_status_window.unselect
      @source_status_window.deactivate
      @target_status_window.select(0)
      @target_status_window.activate
    else
      @target_status_window.unselect
      @target_status_window.deactivate
      @source_status_window.select(0)
      @source_status_window.activate
    end
  end
  
  def next_actor(actor)
    members = $game_party.members
    index = members.index(actor) || -1
    index = (index + 1) % members.size
    return members[index]
  end
  
  def on_source_actor_change
    @source_actor = next_actor(@source_actor)
    while @source_actor == @target_actor
      @source_actor = next_actor(@source_actor)
    end
    refresh_actors
    @source_status_window.activate
  end
  
  def on_target_actor_change
    @target_actor = next_actor(@target_actor)
    while @target_actor == @source_actor
      @target_actor = next_actor(@target_actor)
    end    
    refresh_actors
    @target_status_window.activate
  end
  
  def on_category_ok
    @source_status_window.select(0)
    @source_status_window.activate
  end
  
  def on_category_cancel
    return_scene
  end
  
  def on_source_status_ok
    @source_status_window.unselect
    @source_trade_window.select_last
    @source_trade_window.activate
  end
  
  def on_source_status_cancel
    @source_status_window.unselect
    @category_window.activate
  end
  
  def on_target_status_ok
    @target_status_window.unselect
    @target_trade_window.select_last
    @target_trade_window.activate
  end
  
  def on_target_status_cancel
    @target_status_window.unselect
    @category_window.activate
  end
  
  def on_source_trade_window_ok
    item = @source_trade_window.item
    if check_trade_ok(@target_actor, item)
      perform_trade(@source_actor, @target_actor, item)
    end
    @source_trade_window.activate
  end
  
  def on_source_trade_window_cancel
    @source_status_window.select(0)
    @source_trade_window.unselect
    @source_status_window.activate
  end
  
  def on_target_trade_window_ok
    item = @target_trade_window.item
    if check_trade_ok(@source_actor, item)
      perform_trade(@target_actor, @source_actor, item)
    end
    @target_trade_window.activate
  end
  
  def on_target_trade_window_cancel
    @target_status_window.select(0)
    @target_trade_window.unselect
    @target_status_window.activate
  end
  
  def check_trade_ok(target_actor, item)
    return unless target_actor
    if target_actor.item_max?(item)
      Sound.play_buzzer
      return false 
    end
    return true
  end
  
  def perform_trade(source_actor, target_actor, item)
    source_actor.lose_item(item, 1)
    target_actor.gain_item(item, 1)
    Sound.play_ok
    refresh_windows
  end
end

#-------------------------------------------------------------------------------
# Add the command to the menu
#-------------------------------------------------------------------------------
class Window_MenuCommand < Window_Command
  
  alias :th_actor_trade_scene_add_original_commands :add_original_commands
  def add_original_commands
    th_actor_trade_scene_add_original_commands
    add_command("Trade",   :trade,   main_commands_enabled)
  end
end

class Scene_Menu < Scene_MenuBase
  
  alias :th_actor_trade_scene_create_command_window :create_command_window
  def create_command_window
    th_actor_trade_scene_create_command_window
    @command_window.set_handler(:trade,    method(:command_actor_trade))
  end
  
  def command_actor_trade
    SceneManager.call(Scene_ActorTrade)
  end
end