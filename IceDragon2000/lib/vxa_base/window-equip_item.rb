#encoding:UTF-8
# Window_EquipItem
#==============================================================================
# ** Window_EquipItem
#------------------------------------------------------------------------------
#  This window displays choices when opting to change equipment on the
# equipment screen.
#==============================================================================

class Window_EquipItem < Window_ItemList
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :status_window            # Status window
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @actor = nil
    @slot_id = 0
  end
  #--------------------------------------------------------------------------
  # * Set Actor
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
    self.oy = 0
  end
  #--------------------------------------------------------------------------
  # * Set Equipment Slot ID
  #--------------------------------------------------------------------------
  def slot_id=(slot_id)
    return if @slot_id == slot_id
    @slot_id = slot_id
    refresh
    self.oy = 0
  end
  #--------------------------------------------------------------------------
  # * Include in Item List?
  #--------------------------------------------------------------------------
  def include?(item)
    return true if item == nil
    return false unless item.is_a?(RPG::EquipItem)
    return false if @slot_id < 0
    return false if item.etype_id != @actor.equip_slots[@slot_id]
    return @actor.equippable?(item)
  end
  #--------------------------------------------------------------------------
  # * Display in Enabled State?
  #--------------------------------------------------------------------------
  def enable?(item)
    return true
  end
  #--------------------------------------------------------------------------
  # * Restore Previous Selection Position
  #--------------------------------------------------------------------------
  def select_last
  end
  #--------------------------------------------------------------------------
  # * Set Status Window
  #--------------------------------------------------------------------------
  def status_window=(status_window)
    @status_window = status_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    super
    if @actor && @status_window
      temp_actor = Marshal.load(Marshal.dump(@actor))
      temp_actor.force_change_equip(@slot_id, item)
      @status_window.set_temp_actor(temp_actor)
    end
  end
end
