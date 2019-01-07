=begin
Equipment Levels Up
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
This script allows weapons to grow stronger and level up when they
gain exp or ap.
----------------------
Instructions
----------------------
Requires my individual equipment script. (Make sure it is version 1.1+)
Requires an AP script if leveling weapons using AP.
Customise the variables in the module below to set up the script to your
liking.

Notetags
<maxlevel x> - adds a non-default max level to the tagged equipment.
----------------------
Known bugs
----------------------
None
=end

module Fomar
  
  # If you only want to implement this for weapons or armours set
  # the following to false as you see fit
  WLU_WEAPONS_LEVEL_UP = true
  WLU_ARMOURS_LEVEL_UP = true
  # This script can be set up to use either EXP or AP
  # For AP you will also need an AP system.
  # true -> uses AP
  # false -> uses EXP
  WLU_USE_AP = false
  # Determines the order of the substitutions
  # true -> level, name
  # false -> name, level
  WLU_PREFIX = false
  # the %s are replaced by the level and name of the weapon
  WLU_VOCAB_WEAPON_NAME = "%s LV %s"
  # Default max level
  # set to 0 to only allow chosen weapons to level up
  WLU_DEF_MAX_LEVEL = 5
  # Default stat increase per level (percentage)
  WLU_DEF_PARAM_INC = 25
  # Set to false if you want the price of the item to be unaffected
  # by leveling up
  WLU_PRICE_LEVEL_UP = true
  # Default experience per level
  # I have provided two defaults, one designed for EXP and one for AP
  def self.WLU_EXP_FOR_LEVEL(item); return item.performance * 10; end
  def self.WLU_AP_FOR_LEVEL(item); return item.performance; end
  
end


class Game_CustomEquip < Game_BaseItem
  
  alias wlu_initialize initialize
  def initialize
    wlu_initialize
    @exp = 0
    @level = 1
  end
  
  def gain_exp(exp)
    return unless levels?
    @exp += exp
    last_level = @level
    unless Fomar::WLU_USE_AP
      while @exp >= @level * Fomar.WLU_EXP_FOR_LEVEL(object) and @level < object.max_level
        @level += 1
        $game_message.add(object.name + " levels up.")
      end
    else
      while @exp >= @level * Fomar.WLU_AP_FOR_LEVEL(object) and @level < object.max_level
        @level += 1
        $game_message.add(object.name + " levels up.")
      end
    end
  end
  
  def levels?
    return false if is_nil?
    return (((is_weapon? and Fomar::WLU_WEAPONS_LEVEL_UP) or
            (is_armor? and Fomar::WLU_ARMOURS_LEVEL_UP)) and
            object.max_level > 0)
  end
  
  alias wlu_name name
  def name
    return nil if is_nil?
    return wlu_name unless levels?
    return sprintf(Fomar::WLU_VOCAB_WEAPON_NAME,@level,wlu_name) if Fomar::WLU_PREFIX
    return sprintf(Fomar::WLU_VOCAB_WEAPON_NAME,wlu_name,@level)
  end
  
  alias wlu_price price
  def price
    return nil if is_nil?
    return wlu_price unless levels?
    return wlu_price unless Fomar::WLU_PRICE_LEVEL_UP
    return (100 + Fomar::WLU_DEF_PARAM_INC * @level + object.price)/100
  end
  
  def params
    return nil if is_nil?
    par = object.params.clone
    for i in 0..par.size - 1
      par[i] *= 100 + Fomar::WLU_DEF_PARAM_INC * (@level - 1)
      par[i] /= 100
    end
    return par
  end
  
  alias wlu_performance performance
  def performance
    return nil if is_nil?
    return wlu_performance unless levels?
    par = params
    p = 0
    for pa in par
      p += pa
    end
    if is_weapon?
      p += par[2] + par[4]
    else
      p += par[3] + par[5]
    end
    return p
  end
  
end

module RPG
  class EquipItem
    def max_level
      if self.note =~ /<maxlevel (.*)>/i
        return $1.to_i
      else
        return Fomar::WLU_DEF_MAX_LEVEL
      end
    end
  end
end

class Game_Actor < Game_Battler
  
  alias wlu_gain_exp gain_exp
  def gain_exp(exp)
    for equip in @equips
      equip.gain_exp(exp)
    end
    wlu_gain_exp(exp)
  end
  
  def gain_ap(ap)
    for equip in @equips
      equip.gain_exp(ap)
    end
  end
  
  def custom_equips
    return @equips
  end
  
  # rewrites param_plus
  def param_plus(param_id)
    p = super(param_id)
    for equip in @equips
      p += equip.params[param_id] unless equip.is_nil?
    end
    return p
  end
  
end


class Window_Base < Window
  
  alias wlu_draw_item_name draw_item_name
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    if item.is_a?(Game_CustomEquip)
      return if item.is_nil?
    end
    wlu_draw_item_name(item, x, y, enabled = true, width)
  end
  
end

class Window_EquipSlot < Window_Selectable
  
  # rewrites draw_item
  def draw_item(index)
    return unless @actor
    rect = item_rect_for_text(index)
    change_color(system_color, enable?(index))
    draw_text(rect.x, rect.y, 92, line_height, slot_name(index))
    draw_item_name(@actor.custom_equips[index], rect.x + 92, rect.y, enable?(index))
  end
  
end