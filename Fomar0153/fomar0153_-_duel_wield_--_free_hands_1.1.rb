=begin
Duel Wield -> Free Hands
by Fomar0153
Version 1.1
----------------------
Notes
----------------------
No requirements
Changes dual wielding to allow characters to equip shield or one handed
weapons in the shield slot. Also allows for two handed weapons.
----------------------
Instructions
----------------------
Notetag two handed weapon with <two-handed> and have them
disable the shield slot.
I would reccomend changing the slot name to Main Hand and Off Hand
or something similiar
----------------------
Change Log
----------------------
1.0 -> 1.1 Fixed a bug where the equip item in the second hand could
           overwrite the main hand's equip item.
----------------------
Known bugs
----------------------
None
=end
class Game_Actor
  
  def equip_slots
    return [0,1,2,3,4]
  end
  
  def change_equip(slot_id, item)
    return unless trade_item_with_party(item, equips[slot_id])
    return if (item && equip_slots[slot_id] != item.etype_id) and
      not (dual_wield? and (equip_slots[slot_id] == 1 and item.etype_id == 0))
    @equips[slot_id].object = item
    refresh
  end
  
  def release_unequippable_items(item_gain = true)
    @equips.each_with_index do |item, i|
      if !equippable?(item.object,equip_slots[i]) || (item.object.etype_id != equip_slots[i] and
          not (dual_wield? and (equip_slots[i] == 1 and item.object.etype_id == 0)))
        trade_item_with_party(nil, item.object) if item_gain
        item.object = nil
      end
    end
  end
  
  def equippable?(item, slot = nil)
    unless slot.nil?
      if slot == 1 and dual_wield?
        return (super(item) and not equip_type_sealed?(1)) if item.is_a?(RPG::Weapon)
      end
    end
    return super(item)
  end
  
  def slot_list(etype_id)
    result = []
    equip_slots.each_with_index {|e, i| result.push(i) if e == etype_id or ((e == 1 and etype_id == 0) and dual_wield?) }
    result
  end
end

class RPG::Weapon
  
  def two_handed?
    return self.note.include?("<two-handed>")
  end
  
end

class Window_EquipItem < Window_ItemList
  
  def include?(item)
    return true if item == nil
    return false unless item.is_a?(RPG::EquipItem)
    return false if @slot_id < 0
    return false if @actor.equip_slots[@slot_id] == 1 and 
      (item.is_a?(RPG::Weapon) and item.two_handed?)
    return false if (item.etype_id != @actor.equip_slots[@slot_id]) and 
      not (@actor.dual_wield? and (@actor.equip_slots[@slot_id] == 1 and item.etype_id == 0))
    return @actor.equippable?(item,@actor.equip_slots[@slot_id])
  end
  
end