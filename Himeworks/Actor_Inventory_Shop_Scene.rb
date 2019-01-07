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