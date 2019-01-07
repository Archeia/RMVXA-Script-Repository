=begin
Equipment Requirements
by Fomar0153
Version 1.1
----------------------
Notes
----------------------
Adds a level requirement to equipment.
----------------------
Instructions
----------------------
Notetag the weapons/armors like so:
<levelreq x>
<mhpreq x>
<mmpreq x>
<atkreq x>
<defreq x>
<matreq x>
<mdfreq x>
<agireq x>
<lukreq x>
----------------------
Change Log
----------------------
1.0 -> 1.1 Added stat requirements
           Changed script name from Equipment Level Requirements
           to just Equipment Requirements
----------------------
Known bugs
----------------------
None
=end

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● If set to true then it compares the requirement with the actor's base 
  #   stat rather than their current.
  #--------------------------------------------------------------------------
  EQUIPREQ_USE_BASE_STAT = true
  #--------------------------------------------------------------------------
  # ● Check the requirements
  #--------------------------------------------------------------------------
  alias level_equippable? equippable?
  def equippable?(item)
    return false unless item.is_a?(RPG::EquipItem)
    return false if @level < item.levelreq
    return false if reqstat(0) < item.mhpreq
    return false if reqstat(1) < item.mmpreq
    return false if reqstat(2) < item.atkreq
    return false if reqstat(3) < item.defreq
    return false if reqstat(4) < item.matreq
    return false if reqstat(5) < item.mdfreq
    return false if reqstat(6) < item.agireq
    return false if reqstat(7) < item.lukreq
    return level_equippable?(item)
  end
  #--------------------------------------------------------------------------
  # ● New Method
  #--------------------------------------------------------------------------
  def reqstat(id)
    if EQUIPREQ_USE_BASE_STAT
      return param_base(id)
    else
      return param(id)
    end
  end
end

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
    def mhpreq
      if self.note =~ /<mhpreq (.*)>/i
        return $1.to_i
      else
        return 0
      end
    end
    def mmpreq
      if self.note =~ /<mmpreq (.*)>/i
        return $1.to_i
      else
        return 0
      end
    end
    def atkreq
      if self.note =~ /<atkreq (.*)>/i
        return $1.to_i
      else
        return 0
      end
    end
    def defreq
      if self.note =~ /<defreq (.*)>/i
        return $1.to_i
      else
        return 0
      end
    end
    def matreq
      if self.note =~ /<matreq (.*)>/i
        return $1.to_i
      else
        return 0
      end
    end
    def mdfreq
      if self.note =~ /<mdfreq (.*)>/i
        return $1.to_i
      else
        return 0
      end
    end
    def agireq
      if self.note =~ /<agireq (.*)>/i
        return $1.to_i
      else
        return 0
      end
    end
    def lukreq
      if self.note =~ /<lukreq (.*)>/i
        return $1.to_i
      else
        return 0
      end
    end
  end
end