=begin
Custom Equipment Slots Script
by Fomar0153
Version 1.2
----------------------
Notes
----------------------
No requirements
Allows you to customise what equipment characters can equip
e.g. add new slots or increase the number of accessories.
----------------------
Instructions
----------------------
You will need to edit the script in two locations both are near
the top of the script look for:
Slots[7] = "Spell Tomes"
return [0,0,2,3,4,4,4,7] if dual_wield?
and follow the instructions where they are.
----------------------
Changle Log
----------------------
1.0 -> 1.1 : Fixed a bug that caused a crash when equipping a weapon.
1.1 -> 1.2 : Fixed a bug with optimisation and remove all
             Increased compatibility
----------------------
Known bugs
----------------------
None
=end
#--------------------------------------------------------------------------
# ● New Module Extra_Slots
#--------------------------------------------------------------------------
module Extra_Slots

  Slots = []
  # Edit here to add new slot types
  # Slots[armour_type_id] = "name"
  # I know it is named in the database but I don't believe you can access
  # that name through Vocab
  Slots[7] = "Spell Tomes"

end

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● Rewrites equip_slots
  #--------------------------------------------------------------------------
  # Edit here to change what slots are available to your characters
  # 0 - Weapon
  # 1 - Shield
  # 2 - Head
  # 3 - Body
  # 4 - Accessory
  # 5+ a custom slot
  def equip_slots
    return [0,0,2,3,4,4,4,7] if dual_wield?
    return [0,1,2,3,4,4,4,7]
  end
end

class Window_EquipSlot < Window_Selectable
  #--------------------------------------------------------------------------
  # ● Rewrites slot_name
  #--------------------------------------------------------------------------
  def slot_name(index)
    if @actor.equip_slots[index] >= 5
      Extra_Slots::Slots[@actor.equip_slots[index]]
    else
      @actor ? Vocab::etype(@actor.equip_slots[index]) : ""
    end
  end
end

class Scene_Equip < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● Aliases create_slot_window
  #--------------------------------------------------------------------------
  alias custom_slots_create_slot_window create_slot_window
  def create_slot_window
    custom_slots_create_slot_window
    @slot_window.create_contents
    @slot_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● Aliases on_actor_change
  #--------------------------------------------------------------------------
  alias custom_slots_on_actor_change on_actor_change
  def on_actor_change
    custom_slots_on_actor_change
    @slot_window.create_contents
    @slot_window.refresh
  end
end

module RPG
  class Armor
  #--------------------------------------------------------------------------
  # ● I wish I'd done this originally.
  #--------------------------------------------------------------------------
    def etype_id
      if Extra_Slots::Slots[self.atype_id] == nil
        return @etype_id
      else
        return self.atype_id
      end
    end
  end
end