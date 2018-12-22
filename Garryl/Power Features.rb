=begin
-------------------------------------------------------------------------------

Power Features
Version 1.0

Created: Mar. 27, 2015
Last update: Mar. 27, 2015

Author: Garryl

-------------------------------------------------------------------------------

Description:

This script provides support for additional features, defined through note
tags, that improve the effects of a battler's actions. Any normal game object
that can have features (actors, classes, enemies, weapons, armor, and states)
supports these features. These "power features" can enhance the effectiveness
of attacks and heals that use a specific element, the application rates of
states and debuffs, or the effectiveness of individual skills and items.

-------------------------------------------------------------------------------

Installation:

Copy into a new script slot in the Materials section.

-------------------------------------------------------------------------------

Usage Instructions:

This script supports and requires note tags. See below for more information.

-------------------------------------------------------------------------------

Note Tags:

The following note tags are supported. Additional functionality can be
gained by putting the indicated text in the "Note" field of states or skill.

Element power: Multiplies damage/healing done with skills/items using an
  element, identified by the element ID (see the Terms tab).
Debuff power: Multiplies the application rate of a debuff when caused by
  skills/items that have a chance of applying it, identified by the stat
  the debuff applies to.
  (0: mhp, 1: mmp, 2: atk, 3: def, 4: mat, 5: mdf, 6: agi, 7:luk). 
State power: Multiplies the application rate of a state when caused by
  skills/items that have a chance of applying it, identified by the state ID.
Skill power: Multiplies the damage/healing done by usage of a skill,
  identified by the skill ID. Only affects the formula, not fixed/percentage
  hp/mp restoration in the "effects" section.
Item power: Multiplies the damage/healing done by usage of that item,
  identified by the item ID. Only affects the formula, not fixed/percentage
  hp/mp restoration in the "effects" section.

All five of the above note tags follow the same format.
ID# is a non-zero, positive integer (ie: 1 or greater).
Multiplier accepts both integers and floating point values, and can be either
positive or negative.
Any amount of white space is allowed around the numbers.
- Valid Locations: Actor, Class, Weapon, Armor, Enemy, State
- Valid Strings (case insensitive): <element/debuff/state/skill/item power: ID# Multiplier >
    Ex: <element power: 2 1.5>  #Increases the damage/healing of Absorb element
                                #skills and items by 50%.
    Ex: <skill power: 33 0.75>  #Reduces the damage/healing of skill 33 by 25%.
    Ex: <debuff power: 3 2>     #Doubles the application rate of def debuffs.
    Ex: <item power: 25 -1>     #Causes item 25 to heal instead of damage, and
                                #vice-versa.
    Ex: <state power: 12 0>     #Prevents the battler from applying state 12
                                #with skills or items.

Multiple tags can be placed in the same note, even of the same type. You could,
for example, have a weapon that modifies the power of multiple elements.
    Ex: <element power: 3 1.25>
        <element power: 4 1.5>
        <element power: 7 2.1>
        <element power: 9 0.7>

-------------------------------------------------------------------------------

References:
- Game_BattlerBase
- Game_Battler
- RPG::BaseItem
- DataManager

-------------------------------------------------------------------------------

Compatibility:

The following default script functions are overwritten:
- Game_Battler.make_damage_value
- Game_Battler.item_element_rate
- Game_Battler.elements_max_rate
- Game_Battler.item_effect_add_state_attack
- Game_Battler.item_effect_add_state_normal
- Game_Battler.item_effect_add_debuff

The following default script functions are aliased:
- DataManager.load_database

The following functions are added to default script classes:
- Game_BattlerBase.element_power
- Game_BattlerBase.debuff_power
- Game_BattlerBase.state_power
- Game_BattlerBase.skill_power
- Game_BattlerBase.item_power
- RPG::BaseItem.load_notetag_power
- RPG::BaseItem.load_notetag_arbitrary_power
- RPG::BaseItem.load_notetag_element_power
- RPG::BaseItem.load_notetag_debuff_power
- RPG::BaseItem.load_notetag_state_power
- RPG::BaseItem.load_notetag_skill_power
- RPG::BaseItem.load_notetag_item_power
- DataManager.load_power_notetags

-------------------------------------------------------------------------------
=end

# *****************************************************************************
# * Import marker key                                                         *
# *****************************************************************************
$imported ||= {}
$imported["Garryl"] ||= {}
$imported["Garryl"]["Extra Features"] ||= {}
$imported["Garryl"]["Extra Features"]["Element Power"] = true
$imported["Garryl"]["Extra Features"]["Debuff Power"] = true
$imported["Garryl"]["Extra Features"]["State Power"] = true
$imported["Garryl"]["Extra Features"]["Skill Power"] = true
$imported["Garryl"]["Extra Features"]["Item Power"] = true

module Garryl
  module ExtraFeatures
    module BattlerBase
      #--------------------------------------------------------------------------
      # * Constants (Features)
      #--------------------------------------------------------------------------
      FEATURE_ELEMENT_POWER = 367011          # Element Power
      FEATURE_DEBUFF_POWER  = 367012          # Debuff Power
      FEATURE_STATE_POWER   = 367013          # State Power
      FEATURE_SKILL_POWER   = 367014          # Skill Power
      FEATURE_ITEM_POWER    = 367015          # Item Power
    end
    
    module Regex
      #base items (essentially, anything that has features)
      ELEMENT_POWER = /<element power:\s*([1-9][0-9]*)\s*([\-\+]?[0-9]*(\.[0-9]+)?)\s*>/i
      DEBUFF_POWER  = /<debuff power:\s*([1-9][0-9]*)\s*([\-\+]?[0-9]*(\.[0-9]+)?)\s*>/i
      STATE_POWER   = /<state power:\s*([1-9][0-9]*)\s*([\-\+]?[0-9]*(\.[0-9]+)?)\s*>/i
      SKILL_POWER   = /<skill power:\s*([1-9][0-9]*)\s*([\-\+]?[0-9]*(\.[0-9]+)?)\s*>/i
      ITEM_POWER    = /<item power:\s*([1-9][0-9]*)\s*([\-\+]?[0-9]*(\.[0-9]+)?)\s*>/i
    end
  end
end  
  
class Game_BattlerBase
  # *************************************************************************
  # * Constants                                                             *
  # *************************************************************************
  #--------------------------------------------------------------------------
  # * Constants (Features)
  #--------------------------------------------------------------------------
  FEATURE_ELEMENT_POWER = Garryl::ExtraFeatures::BattlerBase::FEATURE_ELEMENT_POWER
  FEATURE_DEBUFF_POWER  = Garryl::ExtraFeatures::BattlerBase::FEATURE_DEBUFF_POWER
  FEATURE_STATE_POWER   = Garryl::ExtraFeatures::BattlerBase::FEATURE_STATE_POWER
  FEATURE_SKILL_POWER   = Garryl::ExtraFeatures::BattlerBase::FEATURE_SKILL_POWER
  FEATURE_ITEM_POWER    = Garryl::ExtraFeatures::BattlerBase::FEATURE_ITEM_POWER
  
  # *************************************************************************
  # * New Functions                                                         *
  # *************************************************************************
  #--------------------------------------------------------------------------
  # * Get Element Power
  #--------------------------------------------------------------------------
  def element_power(element_id)
    features_pi(FEATURE_ELEMENT_POWER, element_id)
  end
  
  #--------------------------------------------------------------------------
  # * Get Debuff Power
  #--------------------------------------------------------------------------
  def debuff_power(param_id)
    features_pi(FEATURE_DEBUFF_POWER, param_id)
  end
  
  #--------------------------------------------------------------------------
  # * Get State Power
  #--------------------------------------------------------------------------
  def state_power(state_id)
    features_pi(FEATURE_STATE_POWER, state_id)
  end
  
  #--------------------------------------------------------------------------
  # * Get Skill Power
  #--------------------------------------------------------------------------
  def skill_power(skill_id)
    features_pi(FEATURE_SKILL_POWER, skill_id)
  end
  
  #--------------------------------------------------------------------------
  # * Get Item Power
  #--------------------------------------------------------------------------
  def item_power(item_id)
    features_pi(FEATURE_ITEM_POWER, item_id)
  end
  
end



class Game_Battler < Game_BattlerBase
  # *************************************************************************
  # * Overwritten Functions                                                 *
  # *************************************************************************
  #--------------------------------------------------------------------------
  # * Calculate Damage
  #--------------------------------------------------------------------------
  def make_damage_value(user, item)
    #puts "DEBUG: Make damage value"
    #puts "  User: #{user.name}"
    #puts "  Subject: #{name}"
    #puts "  Item: #{item.name} (ID: #{item.id})"
    value = item.damage.eval(user, self, $game_variables)
    #puts "  Base Damage: #{value}"
    value *= user.skill_power(item.id) if item.is_a?(RPG::Skill)  #Skill power
    #puts "  User Skill Power: #{user.skill_power(item.id)}" if item.is_a?(RPG::Skill)
    value *= user.item_power(item.id) if item.is_a?(RPG::Item)    #Item power
    #puts "  User Item Power: #{user.item_power(item.id)}" if item.is_a?(RPG::Item)
    value *= item_element_rate(user, item)
    value *= pdr if item.physical?
    value *= mdr if item.magical?
    value *= rec if item.damage.recover?
    value = apply_critical(value) if @result.critical
    value = apply_variance(value, item.damage.variance)
    value = apply_guard(value)
    @result.make_damage(value.to_i, item)
  end
  
  #--------------------------------------------------------------------------
  # * Get Element Modifier for Skill/Item
  #--------------------------------------------------------------------------
  def item_element_rate(user, item)
    #puts "DEBUG: Element rate"
    #puts "  User: #{user.name}"
    #puts "  Subject: #{name}"
    if (item.damage.element_id < 0)
      return (user.atk_elements.empty? ? 1.0 : elements_max_rate(user.atk_elements))
    else
      #puts "  Fixed Element ID: #{item.damage.element_id}"
      #puts "    Element Rate: #{element_rate(item.damage.element_id)}"
      #puts "    User Element Power: #{user.element_power(item.damage.element_id)}"
      #puts "    Final Rate: #{element_rate(item.damage.element_id) * user.element_power(item.damage.element_id)}"
      return element_rate(item.damage.element_id) * user.element_power(item.damage.element_id)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get Maximum Elemental Adjustment Amount
  #     elements : An array of attribute IDs
  #    Returns the most effective adjustment of all elemental alignments.
  #--------------------------------------------------------------------------
  def elements_max_rate(elements, user = nil)
    #puts "  Using best element"
    #return elements.inject([0.0]) {|r, i| r.push(element_rate(i) * (user == nil ? 1.0 : user.element_power(i))) }.max
    return elements.inject([0.0]) {|r, i|
      e_rate = element_rate(i)
      e_pwr = (user == nil ? 1.0 : user.element_power(i))
      rate = e_rate * e_pwr
      r.push(rate)
      #puts "  Element ID: #{i}"
      #puts "    Element Rate: #{e_rate}"
      #puts "    User Element Power: #{e_pwr}"
      #puts "    Final Rate: #{rate}"
    }.max
  end
  
  #--------------------------------------------------------------------------
  # * [Add State] Effect: Normal Attack
  #--------------------------------------------------------------------------
  def item_effect_add_state_attack(user, item, effect)
    #puts "DEBUG: State application (normal attack)"
    #puts "  User: #{user.name}"
    #puts "  Subject: #{name}"
    user.atk_states.each do |state_id|
      chance = effect.value1
      chance *= state_rate(state_id)
      chance *= user.atk_states_rate(state_id)
      chance *= user.state_power(state_id)      #State power
      chance *= luk_effect_rate(user)
      #puts "  State ID: #{state_id}"
      #puts "    Base Chance: #{effect.value1}"
      #puts "    State Rate: #{state_rate(state_id)}"
      #puts "    User Attack States Rate: #{user.atk_states_rate(state_id)}"
      #puts "    User State Power: #{user.state_power(state_id)}"
      #puts "    Luck Effect Rate: #{luk_effect_rate(user)}"
      #puts "    Final Chance: #{chance}"
      if rand < chance
        add_state(state_id)
        @result.success = true
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * [Add State] Effect: Normal
  #--------------------------------------------------------------------------
  def item_effect_add_state_normal(user, item, effect)
    #puts "DEBUG: State application (direct)"
    #puts "  User: #{user.name}"
    #puts "  Subject: #{name}"
    chance = effect.value1
    chance *= state_rate(effect.data_id) if opposite?(user)
    chance *= user.state_power(effect.data_id)              #State power
    chance *= luk_effect_rate(user)      if opposite?(user)
    #puts "  State ID: #{effect.data_id}"
    #puts "    Base Chance: #{effect.value1}"
    #puts "    State Rate: #{state_rate(effect.data_id)}"
    #puts "    User State Power: #{user.state_power(effect.data_id)}"
    #puts "    Luck Effect Rate: #{luk_effect_rate(user)}"
    #puts "    Final Chance: #{chance}"
    if rand < chance
      add_state(effect.data_id)
      @result.success = true
    end
  end
  
  #--------------------------------------------------------------------------
  # * [Debuff] Effect
  #--------------------------------------------------------------------------
  def item_effect_add_debuff(user, item, effect)
    #puts "DEBUG: Debuff application"
    #puts "  User: #{user.name}"
    #puts "  Subject: #{name}"
    chance = debuff_rate(effect.data_id) * luk_effect_rate(user)
    chance *= user.debuff_power(effect.data_id)                 #Debuff power
    #puts "  Debuff ID: #{effect.data_id}"
    #puts "    Debuff Rate: #{debuff_rate(effect.data_id)}"
    #puts "    Luck Effect Rate: #{luk_effect_rate(user)}"
    #puts "    User Debuff Power: #{user.debuff_power(effect.data_id)}"
    #puts "    Final Chance: #{chance}"
    if rand < chance
      add_debuff(effect.data_id, effect.value1)
      @result.success = true
    end
  end
  
end




class RPG::BaseItem
  # *************************************************************************
  # * New Functions                                                         *
  # *************************************************************************
  #--------------------------------------------------------------------------
  # * Load power notetags
  #--------------------------------------------------------------------------
  def load_notetag_power
    load_notetag_element_power
    load_notetag_debuff_power
    load_notetag_state_power
    load_notetag_skill_power
    load_notetag_item_power
  end
  
  #--------------------------------------------------------------------------
  # * Load arbitrary power notetags
  #--------------------------------------------------------------------------
  def load_notetag_arbitrary_power(regex, feature_code)
    #puts "#{self.note}"
    self.note.scan(regex) {|id, value|
      #puts "Captured [#{id}, #{value}]"
      @features.push(RPG::BaseItem::Feature.new(feature_code, id.to_i, value.to_f))
    }
  end
  
  #--------------------------------------------------------------------------
  # * Load element power notetags
  #--------------------------------------------------------------------------
  def load_notetag_element_power
    load_notetag_arbitrary_power(Garryl::ExtraFeatures::Regex::ELEMENT_POWER, Game_BattlerBase::FEATURE_ELEMENT_POWER)
  end
  
  #--------------------------------------------------------------------------
  # * Load debuff power notetags
  #--------------------------------------------------------------------------
  def load_notetag_debuff_power
    load_notetag_arbitrary_power(Garryl::ExtraFeatures::Regex::DEBUFF_POWER, Game_BattlerBase::FEATURE_DEBUFF_POWER)
  end
  
  #--------------------------------------------------------------------------
  # * Load state power notetags
  #--------------------------------------------------------------------------
  def load_notetag_state_power
    load_notetag_arbitrary_power(Garryl::ExtraFeatures::Regex::STATE_POWER, Game_BattlerBase::FEATURE_STATE_POWER)
  end
  
  #--------------------------------------------------------------------------
  # * Load skill power notetags
  #--------------------------------------------------------------------------
  def load_notetag_skill_power
    load_notetag_arbitrary_power(Garryl::ExtraFeatures::Regex::SKILL_POWER, Game_BattlerBase::FEATURE_SKILL_POWER)
  end
  
  #--------------------------------------------------------------------------
  # * Load item power notetags
  #--------------------------------------------------------------------------
  def load_notetag_item_power
    load_notetag_arbitrary_power(Garryl::ExtraFeatures::Regex::ITEM_POWER, Game_BattlerBase::FEATURE_ITEM_POWER)
  end
  
end



module DataManager
  # *************************************************************************
  # * Aliases                                                               *
  # *************************************************************************
  class << self
    alias garryl_alias_datamanager_load_database        load_database
  end
  
  # *************************************************************************
  # * Aliased Functions                                                     *
  # *************************************************************************
  #--------------------------------------------------------------------------
  # * Load Database
  #--------------------------------------------------------------------------
  def self.load_database
    garryl_alias_datamanager_load_database
    load_power_notetags
  end
  
  # *************************************************************************
  # * New Functions                                                         *
  # *************************************************************************
  #--------------------------------------------------------------------------
  # * Loads the note tags into features
  #--------------------------------------------------------------------------
  def self.load_power_notetags
    #puts "DEBUG: Loading power notetags"
    groups = [$data_actors, $data_classes, $data_weapons, $data_armors, $data_enemies, $data_states]
    for group in groups
      for obj in group
        next if obj.nil?
        next if obj.note == ""
        #puts "DEBUG: Loading for #{obj.name}"
        obj.load_notetag_power
      end
    end
    #puts "DEBUG: Finished loading power notetags"
  end
end