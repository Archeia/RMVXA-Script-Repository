#-skip:
module IEI
#-end:

  def self.item2sym_a item
    return [item_sym(item), item ? item.id : nil]
  end

  #-// Core
  def self.item_sym item
    case item
      when RPG::Item  ; :item
      when RPG::Skill ; :skill
      when RPG::Weapon; :weapon
      when RPG::Armor ; :armor
      else            ; :nil
    end
  end

  def self.sym_a2item sym_a
    return nil unless sym_a
    sym, id = sym_a
    case sym
    when :item   ; $data_items[id]
    when :skill  ; $data_skills[id]
    when :weapon ; $data_weapons[id]
    when :armor  ; $data_armors[id]
    else         ; nil
    end
  end

#-skip:
end
#-end:
