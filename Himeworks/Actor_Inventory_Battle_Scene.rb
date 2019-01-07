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