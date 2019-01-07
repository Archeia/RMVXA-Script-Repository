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
    @data = @actor ? @actor.all_items.select {|item| include?(item) } : []
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
