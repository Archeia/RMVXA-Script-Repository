=begin
#===============================================================================
 Title: Common Event Shop
 Author: Hime
 Date: Feb 28, 2013
--------------------------------------------------------------------------------
 ** Change log
 Mar 1
   - updated to support shop options
 Feb 28, 2013
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
 ** Required
 
 -Shop Manager
 (http://himeworks.com/2013/02/22/shop-manager/)
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to create shops that sell common event items; that is,
 items that will trigger common events when purchased.
 
--------------------------------------------------------------------------------
 ** Usage
 
 -- setup shop goods --
 
 In the Items tab in the database, create some items that will be sold
 as "common event items".
 
 You can set the name, icon, description, and default price of the item.
 
 The scope is important, since you may want certain common events to
 target certain actors. You should select "one ally" if you want to choose an
 actor, and "none" if no selection is necessary.
 
 Then, add some "common event" effects that should be executed. 
 
 -- setup shop variable --
 
 The "shop variable" is the variable that the selected actor ID will be stored,
 if applicable. You can set this in the configuration section.
 
 -- setup shop --
 
 In the interpreter, before the "Shop Processing" command, make a script call
 
    @shop_type = "CommonEventShop"
    
 The list of goods will represent services that may be used.
 When purchased, any common events effects on the item will be run.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_CommonEventShop"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Common_Event_Shop
    
    Shop_Variable = 1   # selected index will be stored in this variable
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
class Game_CommonEventShop < Game_Shop
end

class Window_CommonEventShopCommand < Window_ShopCommand
  def make_command_list
    add_command(Vocab::ShopBuy,    :buy)
    add_command(Vocab::ShopCancel, :cancel)
  end
end

class Window_CommonEventShopBuy < Window_ShopBuy

  alias :th_common_event_shop_enable? :enable?
  def enable?(item)
    return false unless item && price(item) <= @money
    th_common_event_shop_enable?(item)
  end
  
  def window_width
    return 256
  end
  
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
  
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
end

class Window_CommonEventShopStatus < Window_Selectable
  
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @item = nil
    @data = []
    refresh
  end
  
  def actor
    @data[index]
  end
  
  def item=(item)
    @item = item
    refresh
  end
  
  def item_height
    (height - standard_padding * 2) / 4
  end
  
  def item_max
    $game_party.members.size
  end
  
  def make_item_list
    @data = $game_party.members
  end
  
  def enable?(actor)
    return true
  end

  def draw_item(index)
    return unless @item
    rect = item_rect(index)
    actor = @data[index]
    change_color(normal_color, enable?(actor))
    draw_actor_simple_status(actor, rect.x + 8, rect.y + line_height / 2)
  end
  
  def draw_actor_simple_status(actor, x, y)
    draw_actor_name(actor, x, y)
    draw_actor_level(actor, x, y + line_height * 1)
    draw_actor_icons(actor, x, y + line_height * 2)
    draw_character(actor.character_name, actor.character_index, x + 88, y + line_height * 2)
    draw_actor_hp(actor, x + 120, y)
    draw_actor_mp(actor, x + 120, y + line_height)
  end
  
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
  
  def select_last
    select(0)
  end
end

class Scene_CommonEventShop < Scene_Shop
  
  alias :th_common_event_shop_start :start
  def start
    th_common_event_shop_start
    create_interpreter
    create_message_window
  end
  
  def create_interpreter
    @interpreter = Game_Interpreter.new
  end
  
  def create_status_window
    wx = 256
    wy = @dummy_window.y
    ww = Graphics.width - wx
    wh = @dummy_window.height
    @status_window = Window_CommonEventShopStatus.new(wx, wy, ww, wh)
    @status_window.viewport = @viewport
    @status_window.hide
    @status_window.set_handler(:ok, method(:on_status_ok))
    @status_window.set_handler(:cancel, method(:on_status_cancel))
  end
  
  def create_message_window
    @message_window = Window_Message.new
  end
  
  def create_command_window
    @command_window = Window_CommonEventShopCommand.new(@gold_window.x, @purchase_only)
    @command_window.viewport = @viewport
    @command_window.y = @help_window.height
    @command_window.set_handler(:buy,    method(:command_buy))
    @command_window.set_handler(:cancel, method(:return_scene))
  end
  
  def create_buy_window
    wy = @dummy_window.y
    wh = @dummy_window.height
    @buy_window = Window_CommonEventShopBuy.new(0, wy, wh, @goods)
    @buy_window.viewport = @viewport
    @buy_window.help_window = @help_window
    @buy_window.status_window = @status_window
    @buy_window.hide
    @buy_window.set_handler(:ok,     method(:on_buy_ok))
    @buy_window.set_handler(:cancel, method(:on_buy_cancel))
  end
  
  def update_interpreter
    update_basic
    @interpreter.update
    #SceneManager.return if $game_player.transfer?
  end
  
  def set_shop_variable
    $game_variables[TH::Common_Event_Shop::Shop_Variable] = @status_window.actor.id
  end
  
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def on_status_ok
    set_shop_variable
    do_buy
    if money < buying_price
      @status_window.unselect
      @buy_window.activate
    else
      @status_window.activate
    end
  end
  
  def on_status_cancel
    @status_window.unselect
    @buy_window.activate
  end
  
  def on_buy_ok
    @item = @buy_window.item
    if @item.need_selection?
      @status_window.select_last
      @status_window.activate
    else
      do_buy
      @buy_window.activate
    end
  end
  
  def do_buy
    $game_party.lose_gold(buying_price)
    effects = @item.effects.select {|eff|eff.code == 44}
    effects.each {|eff|
      run_common_event(eff.data_id) 
    }
  end
  
  def run_common_event(event_id)
    $game_temp.reserve_common_event(event_id)
    @interpreter.setup_reserved_common_event
    update_interpreter while @interpreter.running?
    @status_window.refresh
    @buy_window.refresh
    @buy_window.money = money
    @gold_window.refresh
  end
  #-----------------------------------------------------------------------------
  # Logic for handling battle and return to title common events
  #-----------------------------------------------------------------------------
  def pre_terminate
    super
    pre_battle_scene if SceneManager.scene_is?(Scene_Battle)
    pre_title_scene  if SceneManager.scene_is?(Scene_Title)
  end
  
  def pre_battle_scene
    BattleManager.save_bgm_and_bgs
    BattleManager.play_battle_bgm
    Sound.play_battle_start
  end
  
  def pre_title_scene
    fadeout(fadeout_speed_to_title)
  end
  
  def perform_battle_transition
    Graphics.transition(60, "Graphics/System/BattleStart", 100)
    Graphics.freeze
  end
  
  def terminate
    super
    perform_battle_transition if SceneManager.scene_is?(Scene_Battle)
  end
  
  #-----------------------------------------------------------------------------
  # Logic for handling player transfer events
  #-----------------------------------------------------------------------------

end