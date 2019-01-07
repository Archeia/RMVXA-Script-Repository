=begin
#===============================================================================
 Title: Attack Element Modifiers
 Author: Hime
 Date: Oct 9, 2014
 URL: http://himeworks.com/2014/01/03/attack-element-modifiers/
--------------------------------------------------------------------------------
 ** Change log
 Oct 9, 2014
   - normal element works the default way if no tags are specified
 Mar 2, 2014
   - added atk element rates to all feature objects as well
 Jan 3, 2014
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to set up "attack element modifiers". Basically, you can
 
 1. Set up skills with multiple attack elements
 2. Specify the attack element rate for each element
 
 By default, damage calculations are done by first calculating the skill's
 "base" damage, then applying the elemental modifiers. An elemental modifier
 is the difference between "elemental damage rate" and "elemental resist rate".
 For example, if your fire damage rate is 100% and the target's fire resist
 rate is 25%, then the actual fire damage is 75%. If your damage was 100% fire,
 then that means the actual damage you inflict is reduced by the target's
 resistance.
 
 Suppose you have a skill that inflicts both fire and earth
 elemental damage, and you want to make it so that the damage is 70% fire and
 30% earth. With this script, it properly calculates the total damage dealt,
 after all elemental resistances have been applied.
 
 If an enemy has no fire resistance and has 50% earth resistance, then your
 final element multiplier is equal to 70% from fire + 15% from earth, for a
 total of 85% of the skill's base damage.
 
--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 To specify an attack element, note-tag objects with
 
   <attack element: ELEMENT_NAME>
   
 Where the ELEMENT_NAME is the name of your element in the database. Refer to
 the Terms tab.
 
 You can note-tag actors, classes, weapons, armors, items, skills, states, or
 enemies.
 
 To specify attack element rates for each element, add the rate to the note-tag
 as a percentage
 
   <attack element: ELEMENT_NAME RATE>
 
 Some example rates are
   0.5 means it deals 50%
   1.0 means it deals 100%
   2.0 means it deals 200%
   
 -- Damage Element Type --
 
 Elemental damage is calculated in two different ways depending on the skill's
 element type.
 
 If the element type is "normal", then it takes the user's attack elements and
 calculates damage based on those.
 
 If there are multiple objects contributing to atk elements, then it will
 average out each element individually. For example, if you were dual-wielding
 a sword that does 30% fire damage and 70% physical damage, and you had another
 sword that does 50% fire and 50% physical damage, then the total damage that
 you will do is 40% fire and 60% physical. You can verify that the math is
 correct.
 
 If the element type is anything else, then it takes the skill's attack
 elements. 
 
 When you note-tag a skill with atk elements, then that is assumed to be the
 skill's damage element types.
   
--------------------------------------------------------------------------------
 ** Example
 
 To specify that your skill inflicts 70% fire and 30% earth damage, you would
 note-tag it with
 
   <attack element: fire 0.7>
   <attack element: earth 0.3>
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_AttackElementModifiers] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Attack_Element_Modifiers
    Regex = /<attack[-_ ]element:\s*(\w+)(?:\s*(.*))?\s*>/i
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  
  class BaseItem
    
    def atk_element_modifiers
      load_notetag_atk_element_modifiers unless @atk_element_modifiers
      return @atk_element_modifiers
    end
    
    def load_notetag_atk_element_modifiers
      @atk_element_modifiers = {}
      
      # Get all of the element modifiers
      elements = $data_system.elements.map {|name| name.downcase}
      results = self.note.scan(TH::Attack_Element_Modifiers::Regex)
      results.each do |res|
        element_id = elements.index(res[0].downcase)
        value = res[1].empty? ? 1.0 : res[1].to_f
        @atk_element_modifiers[element_id] = value
      end
    end
  end
  
  class UsableItem < BaseItem
    def load_notetag_atk_element_modifiers
      super      
      self.damage.element_id = 0 unless @atk_element_modifiers.empty?
    end
    
    alias :th_attack_atk_element_modifiers_damage :damage
    def damage
      load_notetag_atk_element_modifiers unless @atk_element_modifiers
      th_attack_atk_element_modifiers_damage
    end
  end
end

class Game_Battler < Game_BattlerBase
  
  alias :th_attack_atk_element_modifiers_item_element_rate :item_element_rate
  def item_element_rate(user, item)
    if item.damage.element_id < 0
      normal_atk_element_modifiers(user, item)
    else
      # Check if it uses multiple elements
      if item.atk_element_modifiers.empty?
        return th_attack_atk_element_modifiers_item_element_rate(user, item)
      else
        return item_multi_element_rate(user, item)
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Takes atk element rates from all feature objects. If multiple objects
  # define atk elements, then it divides the rates proportionally. If there
  # are no atk elements, then we assume it s a "null" element type which means
  # there is no elemental modifiers.
  #-----------------------------------------------------------------------------
  def normal_atk_element_modifiers(user, item)
    count = 0
    rates = {}
    user.feature_objects.each do |obj|
      next if obj.atk_element_modifiers.empty?
      count += 1 
      obj.atk_element_modifiers.each do |id, val|
        rates[id] ||= 0
        rates[id] += val
      end
    end
    
    return th_attack_atk_element_modifiers_item_element_rate(user, item) if rates.empty?
    return rates.inject(0) do |r, (id, val)|
      r + element_rate(id) / count * val
    end
  end

  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def item_multi_element_rate(user, item)
    return item.atk_element_modifiers.inject(0) do |r, (id, val)|
      r + element_rate(id) * val
    end
  end
end