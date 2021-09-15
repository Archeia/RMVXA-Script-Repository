module RPG
  class BaseItem
    def kind_id
      IEK::ItemKinds::BASE
    end

    def to_mix_key
      [kind_id, id]
    end
  end
  class Item
    def kind_id
      IEK::ItemKinds::ITEM
    end
  end
  class Weapon
    def kind_id
      IEK::ItemKinds::WEAPON
    end
  end
  class Armor
    def kind_id
      IEK::ItemKinds::ARMOR
    end
  end
  class Skill
    def kind_id
      IEK::ItemKinds::SKILL
    end
  end
end
