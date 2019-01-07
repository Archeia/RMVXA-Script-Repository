=begin
#===============================================================================
 ** Effect: Toggle State
 Author: Hime
 Date: Oct 23, 2012
--------------------------------------------------------------------------------
 ** Change log
 Oct 23, 2012
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
 -Effect Manager
  (http://himeworks.com/2012/10/05/effects-manager)
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to reflect a percentage of all damage received back
 to the attacker. The damage you actually take is the difference between
 the received damage and the reflected damage.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Effects Manager and above Main
 
--------------------------------------------------------------------------------
 ** Usage

 Tag effect objects with
    <eff: reflect_damage x>
    -----------------------
    <eff: reflect_damage 0.3>
    
 Where `x` is some percentage, as a float. The example notetag will reflect
 30% of all damage taken.
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["Effect_ReflectDamage"] = true
#===============================================================================
# ** Rest of the script
#===============================================================================
module Effects
  module Reflect_Damage
    Effect_Manager.register_effect(:reflect_damage, 2.0)
  end
end

module RPG
  class BaseItem
    def add_effect_reflect_damage(code, data_id, args)
      args[0] = args[0].to_f
      add_effect(code, data_id, args)
    end
  end
end

class Game_Battler < Game_BattlerBase
  
  def effect_reflect_damage(user, obj, effect)
    return if user == self
    return unless @result.hp_damage > 0
    # calculate damage
    reflect_damage = (@result.hp_damage * effect.value1[0]).to_i
    taken_damage = @result.hp_damage - reflect_damage
    
    # restore old HP
    self.hp = @result.old_hp
    
    # inflict damage to attacker
    user.hp -= reflect_damage
    
    # inflict received damage
    self.hp -= taken_damage
    
    @result.hp_damage = taken_damage
    @result.effect_results.push(sprintf("%d damage was reflected to %s", reflect_damage, user.name))
  end
  
  alias :actor_effect_reflect_damage_guard :effect_reflect_damage
  alias :class_effect_reflect_damage_guard :effect_reflect_damage
  alias :armor_effect_reflect_damage_guard :effect_reflect_damage
  alias :weapon_effect_reflect_damage_guard :effect_reflect_damage
  alias :state_effect_reflect_damage_guard :effect_reflect_damage
  alias :enemy_effect_reflect_damage_guard :effect_reflect_damage
end