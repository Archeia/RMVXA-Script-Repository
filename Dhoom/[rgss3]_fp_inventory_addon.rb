class Game_Inventory
  alias dhoom_fp_inventory_gminv_update_inventory update_inventory
  def update_inventory(container, item, added)
    return if item.is_a?(RPG::Item) and item.itype_id == 2
    dhoom_fp_inventory_gminv_update_inventory(container, item, added)
  end
end

class Window_ItemList < Window_Selectable
  def get_item_rect
    item_rect(self.index)
  end
  
  def current_item_enabled?
    return true if SceneManager.scene_is?(Scene_Item)
    return enable?(@data[index])
  end
  
  def category
    @category
  end
end

class Window_Item_Discard < Window_Command
  def window_width
    return 160
  end
  
  def make_command_list
    add_command("Use", :use)
    add_command("Discard", :discard)
  end
end

class Window_Item_Discard2 < Window_Command
  def window_width
    return 160
  end
  
  def make_command_list
    add_command("Discard", :discard)
  end
end

class Scene_Item < Scene_ItemBase
  
  alias dhoom_fpinv_scitem_start start
  def start
    dhoom_fpinv_scitem_start
    create_discard_windows
  end
  
  def create_discard_windows
    @discard_window = Window_Item_Discard.new(0,0)
    @discard_window.set_handler(:use, method(:on_item_ok))
    @discard_window.set_handler(:discard, method(:on_discard_ok))
    @discard_window.set_handler(:cancel, method(:on_discard_cancel))
    @discard2_window = Window_Item_Discard2.new(0,0)
    @discard2_window.set_handler(:discard, method(:on_discard_ok))
    @discard2_window.set_handler(:cancel, method(:on_discard_cancel))
    @discard_window.z = @discard2_window.z = 9999
    @discard_window.deactivate
    @discard2_window.deactivate
    @discard_window.visible = @discard2_window.visible = false
    @item_window.set_handler(:ok,     method(:on_item_discarduse_ok))
  end
  
  def on_discard_ok
    $game_party.lose_item(item, 1, true)
    @item_window.refresh
    on_discard_cancel
  end
  
  def on_discard_cancel
    @discard_window.deactivate
    @discard2_window.deactivate
    @discard_window.visible = @discard2_window.visible = false
    @item_window.activate
  end
  
  alias dhoom_fpinv_scitem_on_item_ok on_item_ok
  def on_item_ok
    @discard_window.visible = @discard2_window.visible = false
    dhoom_fpinv_scitem_on_item_ok
  end
  
  def on_item_discarduse_ok
    if @item_window.category == :key_item
      on_item_ok
      return
    end
    rect = @item_window.get_item_rect
    rect.x += @item_window.x
    rect.y += @item_window.y
    if @item_window.enable?(item)
      @discard_window.x, @discard_window.y = rect.x, rect.y
      @discard_window.visible = true
      @discard_window.activate
    else
      @discard2_window.x, @discard2_window.y = rect.x, rect.y
      @discard2_window.visible = true
      @discard2_window.activate
    end
  end  
end