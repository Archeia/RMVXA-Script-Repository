=begin
Additional Equipment Slots
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
Requires my Custom Equipment Slots Script
Allows you to add "slots" to equipment
----------------------
Instructions
----------------------
Set Extra_SlotType to the type of your slots.
Then notetag your equipment like so:
<slots x>
where x is the number of slots
----------------------
Known bugs
----------------------
None
=end
module Extra_Slots
  # Set this type as the type for all additional slots
  Extra_SlotType = 7
end

module RPG
  class EquipItem
  #--------------------------------------------------------------------------
  # ● Note tagging for the masses
  #--------------------------------------------------------------------------
    def slots
      if self.note =~ /<slots (.*)>/i
        return $1.to_i
      else
        return 0
      end
    end
  end
end

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● Aliases equip_slots
  #--------------------------------------------------------------------------
  alias extra_equip_slots equip_slots
  def equip_slots
    slots = extra_equip_slots
    for equip in @equips
      if (not equip.nil? and not equip.object.nil?) and 
        (equip.is_weapon? or equip.is_armor?)
        if equip.object.slots > 0
          for i in 1..equip.object.slots
            slots.push(Extra_Slots::Extra_SlotType)
          end
        end
      end
    end
    for i in 0..slots.size
      @equips[i] = Game_BaseItem.new if @equips[i].nil?
    end
    return slots
  end
end