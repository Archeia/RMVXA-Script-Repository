#encoding:UTF-8
# Window_EquipSlot
#==============================================================================
# ** Window_EquipSlot
#------------------------------------------------------------------------------
#  This window displays items the actor is currently equipped with on the
# equipment screen.
#==============================================================================

class Window_EquipSlot < Window_Selectable
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :status_window            # Status window
  attr_reader   :item_window              # Item window
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width)
    super(x, y, width, window_height)
    @actor = nil
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Window Height
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)
  end
  #--------------------------------------------------------------------------
  # * Get Number of Lines to Show
  #--------------------------------------------------------------------------
  def visible_line_number
    return 5
  end
  #--------------------------------------------------------------------------
  # * Set Actor
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    @item_window.slot_id = index if @item_window
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items
  #--------------------------------------------------------------------------
  def item_max
    @actor ? @actor.equip_slots.size : 0
  end
  #--------------------------------------------------------------------------
  # * Get Item
  #--------------------------------------------------------------------------
  def item
    @actor ? @actor.equips[index] : nil
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    return unless @actor
    rect = item_rect_for_text(index)
    change_color(system_color, enable?(index))
    draw_text(rect.x, rect.y, 92, line_height, slot_name(index))
    draw_item_name(@actor.equips[index], rect.x + 92, rect.y, enable?(index))
  end
  #--------------------------------------------------------------------------
  # * Get Equipment Slot Name
  #--------------------------------------------------------------------------
  def slot_name(index)
    @actor ? Vocab::etype(@actor.equip_slots[index]) : ""
  end
  #--------------------------------------------------------------------------
  # * Display Equipment Slot in Enabled State?
  #--------------------------------------------------------------------------
  def enable?(index)
    @actor ? @actor.equip_change_ok?(index) : false
  end
  #--------------------------------------------------------------------------
  # * Get Activation State of Selection Item
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(index)
  end
  #--------------------------------------------------------------------------
  # * Set Status Window
  #--------------------------------------------------------------------------
  def status_window=(status_window)
    @status_window = status_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # * Set Item Window
  #--------------------------------------------------------------------------
  def item_window=(item_window)
    @item_window = item_window
    update
  end
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    super
    @help_window.set_item(item) if @help_window
    @status_window.set_temp_actor(nil) if @status_window
  end
end
