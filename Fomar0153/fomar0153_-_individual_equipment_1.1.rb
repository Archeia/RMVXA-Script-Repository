=begin
Individual Equipment
by Fomar0153
Version 1.1
----------------------
Notes
----------------------
This script changes the way weapons and armours are handled
in game. This script make every weapon and armour unique.
----------------------
Instructions
----------------------
Plug and play.
If you want to be able to carry more than 150 weapons and 150 armors
edit MAX_INVENTORY_SIZE which you can find at the top of the script.
This script is designed to be a base for other scripts.
For example:
Proper Weapon and Armour Customisation.
----------------------
Change Log
----------------------
1.0 -> 1.1 Added a single character (@) to fix a bug where you 
           created new equipment when changing equipment.
----------------------
Known bugs
----------------------
None
=end

module CustomEquip
  
  MAX_INVENTORY_SIZE = 150
  
end

class Game_CustomEquip < Game_BaseItem
  #--------------------------------------------------------------------------
  # ● New attr_accessor & attr_reader
  #--------------------------------------------------------------------------
  attr_accessor :pos
  attr_reader   :item_id
  #--------------------------------------------------------------------------
  # ● Pos is used to identify weapons and armors
  #--------------------------------------------------------------------------
  def initialize
    super
    @pos = 0
  end
  #--------------------------------------------------------------------------
  # ● The rest of the methods allow this item to pretend to be RPG::Weapon
  #   and RPG::Armor in some cases, increasing compatability, thought not
  #   as much as I would like.
  #--------------------------------------------------------------------------
  def description
    return nil if is_nil?
    return object.description
  end
  
  def name
    return nil if is_nil?
    return object.name
  end
  
  def icon_index
    return nil if is_nil?
    return object.icon_index
  end
  
  def price
    return nil if is_nil?
    return object.price
  end
  
  def animation_id
    return nil if is_nil?
    return nil if is_armor? # variable only exists for RPG::Weapon
    return object.animation_id
  end
  
  def note
    return nil if is_nil?
    return object.note
  end
  
  def id
    return nil if is_nil?
    return object.id
  end
  
  def features
    return nil if is_nil?
    return object.features
  end
  
  def params
    return nil if is_nil?
    return object.params
  end
  
  def etype_id
    return nil if is_nil?
    return object.etype_id
  end
  
  def wtype_id
    return nil if is_nil?
    return nil if is_armor? # variable only exists for RPG::Weapon
    return object.wtype_id
  end
  
  def atype_id
    return nil if is_nil?
    return nil if is_weapon? # variable only exists for RPG::Armor
    return object.atype_id
  end
  
  
  # performance returns an integer calculated from the equip item's params.
  # each point in a param increasing performance by one, except
  # for attack and magic on weapon which counts double
  # for defence and magic defence on armours which counts double
  def performance
    return nil if is_nil?
    return object.performance
  end
  
end

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ● Aliases init_all_items
  #--------------------------------------------------------------------------
  alias ie_init_all_items init_all_items
  def init_all_items
    ie_init_all_items
    @weapons = []
    @armors = []
  end
  #--------------------------------------------------------------------------
  # ● Rewrites weapons 
  #--------------------------------------------------------------------------
  def weapons
    return @weapons
  end
  #--------------------------------------------------------------------------
  # ● Rewrites armors 
  #--------------------------------------------------------------------------
  def armors
    return @armors
  end
  #--------------------------------------------------------------------------
  # ● Aliases item_number + Probably rewrite
  #--------------------------------------------------------------------------
  alias ie_item_number item_number
  def item_number(item)
    if item.class == RPG::Weapon or item.class == RPG::Armor
      return 1 # I haven't found this to cause unexpected behaviour
               # but I don't like it
    else
      return ie_item_number(item)
    end
  end
  #--------------------------------------------------------------------------
  # ● Aliases gain_item
  #--------------------------------------------------------------------------
  alias ie_gain_item gain_item
  def gain_item(item, amount, include_equip = false)
    if item.class == RPG::Weapon
      if amount > 0
        for i in 1..amount
          t = Game_CustomEquip.new
          t.object = item
          @weapons.push(t)
        end
        weapon_sort
      end
    elsif item.is_a?(Game_CustomEquip) && item.is_weapon?
      if amount == 1
        @weapons.push(item)
        weapon_sort
      elsif amount == -1
        # Can't sell more than 1 at a time
        # (is there any other way to remove more than 1 at a time?
        # except through events?)
        @weapons.delete_at(item.pos)
        weapon_sort
      end
    elsif item.class == RPG::Armor
      if amount > 0
        for i in 1..amount
          t = Game_CustomEquip.new
          t.object = item
          @armors.push(t)
        end
        armor_sort
      end
    elsif item.is_a?(Game_CustomEquip) && item.is_armor?
      if amount == 1
        @armors.push(item)
        armor_sort
      elsif amount == -1
        # Can't sell more than 1 at a time
        # (is there any other way to remove more than 1 at a time?
        # except through events?)
        @armors.delete_at(item.pos)
        armor_sort
      end
    else
      ie_gain_item(item, amount, include_equip)
      return
    end
    $game_map.need_refresh = true
  end
  
  def weapon_sort
    @weapons.sort! { |a, b|  a.item_id <=> b.item_id }
    for i in 0..@weapons.size - 1
      @weapons[i].pos = i
    end
  end
  
  def armor_sort
    @armors.sort! { |a, b|  a.item_id <=> b.item_id }
    for i in 0..@armors.size - 1
      @armors[i].pos = i
    end
  end
  
  alias ie_max_item_number max_item_number
  def max_item_number(item)
    if item.class == RPG::Weapon
      return CustomEquip::MAX_INVENTORY_SIZE - @weapons.size
    elsif item.class == RPG::Armor
      return CustomEquip::MAX_INVENTORY_SIZE - @armors.size
    else
      return ie_max_item_number(item)
    end
  end
end

class Window_ItemList < Window_Selectable
  
  alias ie_include? include?
  def include?(item)
    case @category
    when :weapon
      item.is_a?(Game_CustomEquip) && item.object.is_a?(RPG::Weapon)
    when :armor
      item.is_a?(Game_CustomEquip) && item.object.is_a?(RPG::Armor)
    else
      ie_include?(item)
    end
  end
  
  alias ie_draw_item draw_item
  def draw_item(index)
    item = @data[index]
    if item && !item.is_a?(Game_CustomEquip)
      ie_draw_item(index)
    elsif item && item.is_a?(Game_CustomEquip)
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enable?(item))
      #draw_item_number(rect, item) just this line removed from the default
    end
  end
  
end


class Window_EquipItem < Window_ItemList
  #--------------------------------------------------------------------------
  # ● Aliases include?
  #--------------------------------------------------------------------------
  alias ie2_include? include?
  def include?(item)
    return true if item == nil
    return false unless item.is_a?(Game_CustomEquip)
    return ie2_include?(item.object)
  end
  #--------------------------------------------------------------------------
  # ● Rewrites update_help
  #--------------------------------------------------------------------------
  def update_help
    super
    if @actor && @status_window
      temp_actor = Marshal.load(Marshal.dump(@actor))
      temp_actor.force_change_equip(@slot_id, item) unless item.nil?
      @status_window.set_temp_actor(temp_actor)
    end
  end
end


class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● Rewrites init_equips
  #--------------------------------------------------------------------------
  def init_equips(equips)
    @equips = Array.new(equip_slots.size) { Game_CustomEquip.new } # only change
    equips.each_with_index do |item_id, i|
      etype_id = index_to_etype_id(i)
      slot_id = empty_slot(etype_id)
      @equips[slot_id].set_equip(etype_id == 0, item_id) if slot_id
    end
    refresh
  end
  #--------------------------------------------------------------------------
  # ● Rewrites change_equip
  #--------------------------------------------------------------------------
  def change_equip(slot_id, item)
    return unless trade_item_with_party(item, @equips[slot_id])
    return if item && equip_slots[slot_id] != item.etype_id
    if item.nil?
      @equips[slot_id] = Game_CustomEquip.new
    else
      @equips[slot_id] = item
    end
    refresh
  end
  #--------------------------------------------------------------------------
  # ● Rewrites force_change_equip
  #--------------------------------------------------------------------------
  def force_change_equip(slot_id, item)
    if item.nil?
      @equips[slot_id] = Game_CustomEquip.new
    else
      @equips[slot_id] = item
    end
    release_unequippable_items(false)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● Rewrites trade_item_with_party
  #--------------------------------------------------------------------------
  def trade_item_with_party(new_item, old_item)
    #return false if new_item && !$game_party.has_item?(new_item) removed
    $game_party.gain_item(old_item, 1)
    $game_party.lose_item(new_item, 1)
    return true
  end
  #--------------------------------------------------------------------------
  # ● Rewrites change_equip_by_id
  #--------------------------------------------------------------------------
  def change_equip_by_id(slot_id, item_id)
    if equip_slots[slot_id] == 0
      t = Game_CustomEquip.new
      t.object = $data_weapons[item_id]
      $game_party.gain_item(t, 1)
      change_equip(slot_id, t)
    else
      t = Game_CustomEquip.new
      t.object = $data_armors[item_id]
      $game_party.gain_item(t, 1)
      change_equip(slot_id, t)
    end
  end
  #--------------------------------------------------------------------------
  # ● Rewrites optimize_equipments or does it
  #--------------------------------------------------------------------------
  def optimize_equipments
    clear_equipments
    equip_slots.size.times do |i|
      next if !equip_change_ok?(i)
      items = $game_party.equip_items.select do |item|
        item.etype_id == equip_slots[i] &&
        equippable?(item.object) && item.performance >= 0
      end
      change_equip(i, items.max_by {|item| item.performance })
    end
  end
end


class Window_ShopStatus < Window_Base
  
  alias ie_draw_possession draw_possession
  def draw_possession(x, y)
    return if @item.is_a?(RPG::EquipItem)
    ie_draw_possession(x, y)
  end
  
  alias ie_draw_equip_info draw_equip_info
  def draw_equip_info(x, y)
    ie_draw_equip_info(x, y - line_height * 2)
  end
end