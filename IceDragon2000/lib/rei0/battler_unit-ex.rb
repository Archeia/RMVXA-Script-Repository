module REI
  class BattlerUnit
    def ko_exp
      value = 0
      value += param(0) / 4
      value += param(1) / 2
      for i in 2..7
        value += param(i)
      end
      return (exp / level / 3) + value / level / 3
    end

    # // 01/??/2012
    def init_equips(equips)
      @equips = Array.new(equip_slots.size) { Game::EquipItem.new }#Game::BaseItem.new }
      equips.each_with_index do |item_id, i|
        etype_id = index_to_etype_id(i)
        slot_id = empty_slot(etype_id)
        @equips[slot_id].set_equip(etype_id == 0, item_id) if slot_id if item_id > 0
        #self.inventory.gain_item( @equips[slot_id].object, 1 )
      end
      refresh
    end

    def change_equip!(slot_id, item)
      return unless valid_slot?( slot_id, item )
      @equips[slot_id].object = item
      refresh
    end

    def change_equip(slot_id, item)
      return unless trade_item_with_party(item, equips[slot_id])
      change_equip!(slot_id, item)
    end

    def valid_slot?( slot_id, item )
      return false if item && equip_slots[slot_id] != item.etype_id
      return true
    end

    # // 02/28/2012
    def party
      _map.party(@party_id)
    end

    #--------------------------------------------------------------------------
    # ● 味方ユニットを取得
    #--------------------------------------------------------------------------
    def friends_unit
      party#$game.party
    end

    #--------------------------------------------------------------------------
    # ● 敵ユニットを取得
    #--------------------------------------------------------------------------
    def opponents_unit
      _map.enemy_party(@party_id)#$game.troop
    end

    def atk_range
      @atk_range ||= RPG::BaseItem::Range.new(MakeRange::RANGE_DIAMOND,1,0)
      weapon, = weapons
      weapon ? weapon.atk_range : @atk_range
    end

    def atk_effect_range
      @atk_effect_range ||= RPG::BaseItem::Range.new(MakeRange::RANGE_DIAMOND,0,0)
      weapon, = weapons
      weapon ? weapon.effect_range : @atk_effect_range
    end

    def attack_skill?(item)
      ExDatabase.skill?(item) && item.id == attack_skill_id
    end

    def get_range(item)
      return RPG::BaseItem::Range.new(MakeRange::RANGE_DIAMOND,0,0) unless item
      attack_skill?(item) ? atk_range : item.atk_range
    end

    def get_effect_range(item)
      return RPG::BaseItem::Range.new(MakeRange::RANGE_DIAMOND,0,0) unless item
      attack_skill?(item) ? atk_effect_range : item.effect_range
    end

    def range_color(item)
      return ((item && item.element_id > 0) ? Palette["element#{item.element_id}".to_sym] : Palette[:sys_orange]).subtract(0.4)
    end

    # // 02/29/2012
    def params_a
      (0...8).map{|i|param(i)}
    end

    def find_slot_id(etype_id)
      equip_slots.index{|i|i == etype_id}
    end

    def test_equip_item(slot_id,item=nil)
      result = []
      old_item = equips[slot_id]
      change_equip!(slot_id, nil)
      result << params_a # // No Equip
      change_equip!(slot_id, item)
      result << params_a # // New Equip
      change_equip!(slot_id, old_item) # // Restore old equip
      result << params_a # // Old Equip
      result # // [params(no_equip), params(new_equip), params(old_equip)]
    end

    def mk_params_for item
      params = [0]*8 #item.params.clone
      a = test_equip_item find_slot_id(item.etype_id),item
      base, add = a[0], a[1]
      base.each_with_index { |n,i|params[i] += (add[i] - n) }
      params
    end

    def item_performance item
      if ExDatabase.weapon? item
        a = mk_params_for(item)
        n = a[2] + a[4] + a.inject(&:+)
      elsif ExDatabase.armor? item
        a = mk_params_for(item)
        n = a[3] + a[5] + a.inject(&:+)
      else
        n = item.performance
      end
      Integer(n * (ExDatabase.ex_equip_item?(item) ? 1.2 : 1.0))
    end

    def mk_temp_self
      Marshal.load(Marshal.dump(self))
    end

    def optimize_equipments
      clear_equipments
      temp = mk_temp_self
      equip_slots.size.times do |i|
        next if !equip_change_ok?(i)
        items = $game.party.equip_items.select do |item|
          item.etype_id == equip_slots[i] &&
          equippable?(item) && temp.item_performance(item) >= 0
        end
        change_equip(i, items.max_by {|item| temp.item_performance(item) })
      end
    end
  end
end
