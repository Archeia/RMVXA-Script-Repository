=begin
#===============================================================================
 Title: Party Trade Scene
 Author: Hime
 Date: Nov 8, 2013
--------------------------------------------------------------------------------
 ** Change log
 Nov 8, 2013
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
 
 This script provides a scene that allows you to trade items between parties.
 Two parties are displayed in the scene, and you can easily swap items between
 them.
 
--------------------------------------------------------------------------------
 ** Required 
 
 Party Manager
 (http://himeworks.com/2013/08/19/party-manager/)
--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Party Manager and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 To call the party trade scene, make the script call
 
   SceneManager.call(Scene_PartyTrade)
   prepare_party_trade(party1_id, party2_id)
   
 You must pass in two party IDs to be able to trade items between them.
 
 In the scene, you would select a category and press OK to scroll through
 the item list. You can press the "left" or "right" direction keys to
 switch between the two lists.
 
 Pressing OK on an item will trade it over if possible. If the other party's
 inventory is full, the item will not be traded.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_PartyTradeScene"] = true
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

class Window_TradeStatus < Window_Base
  
  attr_reader :party
  
  def initialize(x, y, width, height)
    super
    @party = nil
    refresh
  end
  
  def party=(party)
    if @party != party
      @party = party
      refresh
    end
  end
  
  def draw_status(x, y)
    actor = @party.leader
    draw_actor_face(actor, 0, 0)
    draw_actor_name(actor, x, y)
    draw_actor_level(actor, x, y + line_height * 1)
    draw_actor_icons(actor, x, y + line_height * 2)
  end
  
  def refresh
    return unless @party
    draw_status(108, 0)
    if @item_window
      @item_window.party = @party
    end
  end
  
  def item_window=(item_window)
    @item_window = item_window
    refresh
  end
end

class Window_TradeItemList < Window_ItemList
  
  def initialize(x, y, width, height)
    super
    @party = nil
  end
  
  def col_max
    1
  end
  
  def party=(party)
    if @party != party
      @party = party
      refresh
    end
  end
  
  def enable?(item)
    return false unless item
    true
  end
  
  def select_last
    select(@data.index(@party.last_item.object) || 0)
  end
  
  def make_item_list
    @data = @party.all_items.select {|item| include?(item) }
    @data.push(nil) if include?(nil)
  end
  
  def draw_item_number(rect, item)
    draw_text(rect, sprintf(":%2d", @party.item_number(item)), 2)
  end
  
  def refresh
    return unless @party
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

class Scene_PartyTrade < Scene_Base
  
  def start
    super
    create_all_windows
    @category_window.activate
    refresh_parties
  end
  
  def prepare(id1, id2)
    @source_party = $game_parties[id1]
    @target_party = $game_parties[id2]
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
  end
  
  def create_source_status_window
    wy = @category_window.y + @category_window.height
    @source_status_window = Window_TradeStatus.new(0, wy, Graphics.width / 2, 96)
  end
  
  def create_target_status_window
    wy = @category_window.y + @category_window.height
    @target_status_window = Window_TradeStatus.new(Graphics.width / 2, wy, Graphics.width / 2, 96)
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
  
  def refresh_parties
    @source_status_window.party = @source_party
    @target_status_window.party = @target_party
  end
  
  def refresh_windows
    @source_status_window.refresh
    @target_status_window.refresh
    @source_trade_window.refresh
    @target_trade_window.refresh
  end
  
  def on_window_change
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
  
  def on_category_ok
    @source_trade_window.select_last
    @source_trade_window.activate
  end
  
  def on_category_cancel
    return_scene
  end
  
  def on_source_trade_window_ok
    item = @source_trade_window.item
    if check_trade_ok(@target_party, item)
      perform_trade(@source_party, @target_party, item)
    end
    @source_trade_window.activate
  end
  
  def on_source_trade_window_cancel
    @source_trade_window.unselect
    @category_window.activate
  end
  
  def on_target_trade_window_ok
    item = @target_trade_window.item
    if check_trade_ok(@source_party, item)
      perform_trade(@target_party, @source_party, item)
    end
    @target_trade_window.activate
  end
  
  def on_target_trade_window_cancel
    @target_trade_window.unselect
    @category_window.activate
  end
  
  def check_trade_ok(target_party, item)
    if target_party.item_max?(item)
      Sound.play_buzzer
      return false 
    end
    return true
  end
  
  def perform_trade(source_party, target_party, item)
    source_party.lose_item(item, 1)
    target_party.gain_item(item, 1)
    Sound.play_ok
    refresh_windows
  end
end


class Game_Interpreter

  #-----------------------------------------------------------------------------
  # Convenience method. Takes two party ID's
  #-----------------------------------------------------------------------------
  def prepare_party_trade(party1_id, party2_id)
    SceneManager.scene.prepare(party1_id, party2_id)
  end
end