=begin
Equipment Level Requirements
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
Adds a level requirement to equipment.
----------------------
Instructions
----------------------
Notetag the weapons/armors like so:
<levelreq x>
----------------------
Known bugs
----------------------
None
=end
module RPG
  #--------------------------------------------------------------------------
  # ● Equip Item is inherited by both Weapon and Armor
  #--------------------------------------------------------------------------
  class EquipItem
    def levelreq
      if self.note =~ /<levelreq (.*)>/i
        return $1.to_i
      else
        return 0
      end
    end
  end
end

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● Check the levels
  #--------------------------------------------------------------------------
  alias level_equippable? equippable?
  def equippable?(item)
    return false unless item.is_a?(RPG::EquipItem)
    return false if @level < item.levelreq
    return level_equippable?(item)
  end
end