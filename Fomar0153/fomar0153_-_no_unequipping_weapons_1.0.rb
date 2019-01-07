=begin
No Unequipping Weapons Script
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
No requirements
Prevents players from unequipping their weapons.
----------------------
Instructions
----------------------
Plug and play
----------------------
Known bugs
----------------------
None
=end
class Window_EquipItem < Window_ItemList
  #--------------------------------------------------------------------------
  # * Include in Item List?
  #--------------------------------------------------------------------------
  alias weapons_include? include?
  def include?(item)
    return false if item == nil && @slot_id == 0
    return weapons_include?(item)
  end
end

class Scene_Equip < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Slot [OK]
  #--------------------------------------------------------------------------
  alias weapons_on_slot_ok on_slot_ok
  def on_slot_ok
    if @item_window.item_max == 0
      @slot_window.activate
      return
    end
    weapons_on_slot_ok
  end
end