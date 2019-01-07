=begin
#==============================================================================
 ** Core: Damage Processing
 Author: Hime
 Date: Oct 13, 2012
------------------------------------------------------------------------------
 ** Change log
 Oct 13, 2012
   - initial release
------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Preserve this header
------------------------------------------------------------------------------
 ** Usage
 Place this script above all custom materials.
------------------------------------------------------------------------------
 ** Description
 
 This script re-writes the damage processing method in Game_Battler, 
 increasing flexibility and consequently compatibility between scripts.
 
 All it does is re-arrange each line of the original method into several
 methods, each performing certain types of calculations.
 
 The damage is then returned and passed to the result to apply it to the
 battler.
 
 By adding more methods, there is more opportunity to insert extra calculations
 before or after certain modifiers are applied.
      
#==============================================================================
=end
$imported = {} if $imported.nil?
$imported["Core_DamageProcessing"] = true
#==============================================================================
# ** Rest of the script
#==============================================================================
class Game_Battler < Game_BattlerBase
  
  # overwritten original method. Damage calculation is performed elsewhere
  def make_damage_value(user, item)
    value = make_damage(user, item)
    @result.make_damage(value.to_i, item)
  end
  
  # Calculate damage performed
  def make_damage(user, item)
    value = make_base_damage(user, item)
    value = apply_damage_modifiers(user, item, value)
    return value
  end
  
  # Calculate base damage from skill/item
  def make_base_damage(user, item)
    item.damage.eval(user, self, $game_variables)
  end
  
  # Apply modifiers from various features
  def apply_damage_modifiers(user, item, value)
    value = apply_element_modifiers(user, item, value)
    value = apply_item_modifiers(user, item, value)
    value = apply_hit_modifiers(user, item, value)
    return value
  end

  def apply_element_modifiers(user, item, value)
    value *= item_element_rate(user, item)
    return value
  end

  def apply_item_modifiers(user, item, value)
    value *= pdr if item.physical?
    value *= mdr if item.magical?
    value *= rec if item.damage.recover?
    return value
  end

  def apply_hit_modifiers(user, item, value)
    value = apply_critical(value) if @result.critical
    value = apply_variance(value, item.damage.variance)
    value = apply_guard(value)
    return value
  end
end