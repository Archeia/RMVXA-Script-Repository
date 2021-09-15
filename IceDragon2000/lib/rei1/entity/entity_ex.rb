module REI
class Entity < EntityBattler

  NULL_SKILL_ID = 100

  def base_skill_id(sym)
    @base_skill_ids[sym] || NULL_SKILL_ID
  end

  [:attack, :guard, :skip, :nudge, :tame, :move].each do |s|
    module_eval(%Q(
    def #{s}_skill_id
      base_skill_id(:#{s})
    end

    def #{s}_skill
      $data_skills[#{s}_skill_id]
    end))
  end

  def wt=(new_wt)
    @wt = new_wt
  end

  def inc_wt(n=1)
    self.wt = (self.wt + n).clamp(0, mwt)
  end

  def dec_wt(n=1)
    inc_wt(-n)
  end

  def mwt
    # Base WT - (Max WT Mod * agi / agi_cap)
    (500 - (200 * agi / 256.0)).to_i
  end

  def wt_rate
    self.wt.to_f / self.mwt.max(1)
  end

  def reset_wt
    self.wt = self.mwt
  end

  def wt_done?
    self.wt == 0
  end

  def equippable?(item)
    return false unless ExDatabase.equip_item?( item )
    return false if equip_type_sealed?(item.etype_id)
    return equip_wtype_ok?(item.wtype_id) if ExDatabase.weapon?(item)
    return equip_atype_ok?(item.atype_id) if ExDatabase.armor?(item)
    return false
  end

  def item_can?( item, op )
    case op
    when :use
      return usable?( item )
    when :equip
      return equippable?( item )
    when :set
      return !ExDatabase.equip_item?( item )
    when :drop
      return !item.nil? # //
    when :throw
      return !item.nil?
    end
    return true
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

  def params_a
    (0...8).map { |i| param(i) }
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

  def mk_params_for(item)
    params = [0]*8 #item.params.clone
    a = test_equip_item find_slot_id(item.etype_id),item
    base, add = a[0], a[1]
    base.each_with_index { |n,i|params[i] += (add[i] - n) }
    params
  end

  def item_kind_prefrence(item)
    ExDatabase.ex_equip_item?(item) ? 2 : 1
  end

  def item_performance(item)
    if ExDatabase.weapon?(item)
      a = mk_params_for(item)
      n = a[2] + a[4] + a.inject(&:+)
    elsif ExDatabase.armor?(item)
      a = mk_params_for(item)
      n = a[3] + a[5] + a.inject(&:+)
    else
      n = item.performance
    end
    return Integer(n)
  end

  def item_pref(item)
    return 200 unless item
    if ExDatabase.weapon?(item)
      self.class.wtype_pref[item.wtype_id] || 100
    elsif ExDatabase.armor?(item)
      self.class.atype_pref[item.atype_id] || 100
    else
      100
    end
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
      itm = items.max_by do |item|
        [200 - temp.item_pref(item),
         temp.item_performance(item),
         temp.item_kind_prefrence(item)]
      end
      change_equip(i, itm)
    end
  end

end
end
