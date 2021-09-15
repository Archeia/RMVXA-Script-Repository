#encoding:UTF-8
# Window_ShopStatus
#==============================================================================
# ** Window_ShopStatus
#------------------------------------------------------------------------------
#  This window displays number of items in possession and the actor's
# equipment on the shop screen.
#==============================================================================

class Window_ShopStatus < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @item = nil
    @page_index = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_possession(4, 0)
    draw_equip_info(4, line_height * 2) if @item.is_a?(RPG::EquipItem)
  end
  #--------------------------------------------------------------------------
  # * Set Item
  #--------------------------------------------------------------------------
  def item=(item)
    @item = item
    refresh
  end
  #--------------------------------------------------------------------------
  # * Draw Quantity Possessed
  #--------------------------------------------------------------------------
  def draw_possession(x, y)
    rect = Rect.new(x, y, contents.width - 4 - x, line_height)
    change_color(system_color)
    draw_text(rect, Vocab::Possession)
    change_color(normal_color)
    draw_text(rect, $game_party.item_number(@item), 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Equipment Information
  #--------------------------------------------------------------------------
  def draw_equip_info(x, y)
    status_members.each_with_index do |actor, i|
      draw_actor_equip_info(x, y + line_height * (i * 2.4), actor)
    end
  end
  #--------------------------------------------------------------------------
  # * Array of Actors for Which to Draw Equipment Information
  #--------------------------------------------------------------------------
  def status_members
    $game_party.members[@page_index * page_size, page_size]
  end
  #--------------------------------------------------------------------------
  # * Number of Actors Displayable at Once
  #--------------------------------------------------------------------------
  def page_size
    return 4
  end
  #--------------------------------------------------------------------------
  # * Get Maximum Number of Pages
  #--------------------------------------------------------------------------
  def page_max
    ($game_party.members.size + page_size - 1) / page_size
  end
  #--------------------------------------------------------------------------
  # * Draw Actor Equipment Information
  #--------------------------------------------------------------------------
  def draw_actor_equip_info(x, y, actor)
    enabled = actor.equippable?(@item)
    change_color(normal_color, enabled)
    draw_text(x, y, 112, line_height, actor.name)
    item1 = current_equipped_item(actor, @item.etype_id)
    draw_actor_param_change(x, y, actor, item1) if enabled
    draw_item_name(item1, x, y + line_height, enabled)
  end
  #--------------------------------------------------------------------------
  # * Draw Actor Parameter Change
  #--------------------------------------------------------------------------
  def draw_actor_param_change(x, y, actor, item1)
    rect = Rect.new(x, y, contents.width - 4 - x, line_height)
    change = @item.params[param_id] - (item1 ? item1.params[param_id] : 0)
    change_color(param_change_color(change))
    draw_text(rect, sprintf("%+d", change), 2)
  end
  #--------------------------------------------------------------------------
  # * Get Parameter ID Corresponding to Selected Item
  #    By default, ATK if weapon and DEF if armor.
  #--------------------------------------------------------------------------
  def param_id
    @item.is_a?(RPG::Weapon) ? 2 : 3
  end
  #--------------------------------------------------------------------------
  # * Get Current Equipment
  #    Returns the weaker equipment if there is more than one of the same type,
  #    such as with dual wield.
  #--------------------------------------------------------------------------
  def current_equipped_item(actor, etype_id)
    list = []
    actor.equip_slots.each_with_index do |slot_etype_id, i|
      list.push(actor.equips[i]) if slot_etype_id == etype_id
    end
    list.min_by {|item| item ? item.params[param_id] : 0 }
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    update_page
  end
  #--------------------------------------------------------------------------
  # * Update Page
  #--------------------------------------------------------------------------
  def update_page
    if visible && Input.trigger?(:A) && page_max > 1
      @page_index = (@page_index + 1) % page_max
      refresh
    end
  end
end
