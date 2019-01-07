=begin
#===============================================================================
 ** Effect: Recoil Damage
 Author: Hime
 Date: Sep 12, 2013
--------------------------------------------------------------------------------
 ** Change log
 Sep 12, 2013
   - added element type for recoil damage
 Aug 28, 2013
   - added "guard" trigger for all objects
 Aug 25, 2013
   - recoil effect occurs when battler gets hit
 May 14, 2013
   - initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Preserve this header
--------------------------------------------------------------------------------
 ** Required
 
 -Effects Manager
  (http://himeworks.com/2012/10/05/effects-manager/)

--------------------------------------------------------------------------------
 ** Description
 
 This effect is activated when an attack is successfully made.
 The user will take some amount of damage according to the effect.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Effect Manager and above Main.
 
--------------------------------------------------------------------------------
 ** Usage
 
 Tag effect objects with
 
    <eff: recoil_damage formula element_id>
    
 Where the formula is any valid ruby statement that evaluates to a number.
 
 The `element_id` is the ID of the element you want the recoil damage to be.
 Look up the ID in the Terms tab. If you set it to -1, then it will be the
 "atk element" of the target which can be set using features.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["Effect_RecoilDamage"] = true
#===============================================================================
# ** Rest of the script
#===============================================================================
module Effect
  module Recoil_Damage
    
    Vocab = "%s took %s damage from the recoil!"
    Effect_Manager.register_effect(:recoil_damage)
  end
end

module RPG
  class BaseItem
    def add_effect_recoil_damage(code, data_id, args)
      args[1] = args[1] ? eval(args[1]) : 0
      add_effect(code, data_id, args)
    end
  end
end

class Game_Battler < Game_BattlerBase
  
  def effect_recoil_damage(user, item, effect)
    elementID = effect.value1[1]
    value = eval(effect.value1[0]).to_i
    value *= effect_recoil_element_rate(user, elementID)
    value = value.to_i
    user.hp -= value
    user.perform_collapse_effect if user.dead?
    @result.effect_results.push(sprintf(Effect::Recoil_Damage::Vocab, user.name, value))
    @result.success = true
  end
  
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def effect_recoil_element_rate(user, elementID)
    if elementID < 0
      atk_elements.empty? ? 1.0 : user.elements_max_rate(atk_elements)
    else
      user.element_rate(elementID)
    end
  end
  
  alias :state_effect_recoil_damage_attack :effect_recoil_damage
  alias :state_effect_recoil_damage_guard :effect_recoil_damage
  alias :item_effect_recoil_damage :effect_recoil_damage
  alias :enemy_effect_recoil_damage_attack :effect_recoil_damage
  alias :enemy_effect_recoil_damage_guard :effect_recoil_damage
  alias :actor_effect_recoil_damage_attack :effect_recoil_damage
  alias :actor_effect_recoil_damage_guard :effect_recoil_damage
end

class Game_Actor < Game_Battler
  
  alias :armor_effect_recoil_damage_attack :effect_recoil_damage
  alias :armor_effect_recoil_damage_guard :effect_recoil_damage
  alias :weapon_effect_recoil_damage_attack :effect_recoil_damage
  alias :weapon_effect_recoil_damage_guard :effect_recoil_damage
  alias :class_effect_recoil_damage_attack :effect_recoil_damage
  alias :class_effect_recoil_damage_guard :effect_recoil_damage
end