=begin
#===============================================================================
 Title: Custom Use Conditions
 Author: Hime
 Date: Jan 4, 2014
 URL: http://himeworks.com/2013/11/26/custom-use-conditions/
--------------------------------------------------------------------------------
 ** Change log
 Jan 4, 2014
   - allows for "recursive" calls. Recursive calls do not check custom use
     conditions
   - added "Actor" condition
 Nov 29, 2013
   - fixed bug where no use conditions caused it to always fail
 Nov 26, 2013
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
 
 This script allows you to define custom skill requirements for your skills.
 By default, you can choose two require up to two weapon types. This script
 allows you to define requirements based on things like
 
   - actor's class
   - equipped weapons
   - equipped armors
   - equipped weapon types
   - equipped armor types
   - learned skills
   - active states
   - formulas, for anything else
   
 You can create conditions to require multiple conditions to be met, or
 require at least one condition to be met.
 
--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage
 
 -- Specifying Use Conditions --
 
 Note-tag your skills or items with the following
 
   <use conditions>
    TYPE1: VALUE1
    TYPE2: VALUE2
   </use conditions>
   
 Refer to the reference section for a list of available use conditions.
 
 There is a special "formula" type that allows you to evaluate any arbitrary
 formula. The following formula variables are available
 
   a - current actor
   p - game party
   t - game troop
   s - game switches
   v - game variables
   
 -- Use Condition Groups --
 
 All use conditions are organized into separate "use condition groups". The
 notetag that you see above describes a single condition group. You can
 have multiple condition groups by simply defining multiple notetags.
 
 A skill is said to be "usable" if at least one condition group is satisfied. 
 A condition group is satisfied only if all conditions within the group are
 satisfied. That is, they evaluate to true. Therefore, if you have multiple
 condition groups, you are only required to satisfy one group in order to
 use the skill. See the example to understand how condition groups are used.

-------------------------------------------------------------------------------- 
 ** Example
 
 Suppose you have a Fire Slash skill that can be used under two different
 conditions as follows
 
 1. You must have the "fire enchant" state (state 7), and equip a sword type
    weapon (wtype 2)
 2. You are using the "Fire Dragon Sword" (weapon 21)
 
 To accomplish this, you will define two use condition groups by notetagging
 your skill with
 
 <use conditions>
   state: 7
   wtype: 2
 </use conditions>
 
 <use conditions>
   weapon: 21
 </use conditions>
 
-------------------------------------------------------------------------------- 
 ** Reference
 
 The following use condition types are available
 
 type: weapon
 value: ID
 desc: requires the weapon to be equipped
 
 type: armor
 value: ID
 desc: requires the armor to be equipped
 
 type: wtype
 value: ID
 desc: requires the weapon type to be equipped
 
 type: atype
 value: ID
 desc: requires the armor type to be equipped
 
 type: actor
 value: ID
 desc: requires the user to be a specific actor
 
 type: class
 value: ID
 desc: requires the actor to have the given class
 
 type: state
 value: ID
 desc: requires the state to be currently applied to the actor
 
 type: learned
 value: ID
 desc: requires the actor to have learned the specified skill
 
 type: formula
 value: ruby formula
 desc: requires the formula to evaluate to true
 
-------------------------------------------------------------------------------- 
 ** Examples
 
 
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_CustomUseConditions"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Custom_Use_Conditions
    
    Regex = /<use[-_ ]conditions>(.*?)<\/use[-_ ]conditions>/im
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  class UsableItem < BaseItem
    
    def use_conditions
      load_notetag_use_conditions unless @use_conditions
      return @use_conditions
    end
    
    def load_notetag_use_conditions
      @use_conditions = []
      
      res = self.note.scan(TH::Custom_Use_Conditions::Regex)
      res.each do |result|
        group = Data_UseConditionGroup.new
        result[0].strip.split("\r\n").each do |option|
          case option.strip
          when /weapon:\s*(\d+)\s*/i
            cond = make_custom_use_condition(:weapon, $1.to_i)
          when /armor:\s*(\d+)\s*/i
            cond = make_custom_use_condition(:armor, $1.to_i)
          when /learned:\s*(\d+)\s*/i
            cond = make_custom_use_condition(:learned, $1.to_i)
          when /wtype:\s*(\d+)\s*/i
            cond = make_custom_use_condition(:wtype, $1.to_i)
          when /atype:\s*(\d+)\s*/i
            cond = make_custom_use_condition(:atype, $1.to_i)
          when /actor:\s*(\d+)\s*/i
            cond = make_custom_use_condition(:actor, $1.to_i)
          when /class:\s*(\d+)\s*/i
            cond = make_custom_use_condition(:class, $1.to_i)
          when /state:\s*(\d+)\s*/i
            cond = make_custom_use_condition(:state, $1.to_i)
          when /formula:\s*(.*)\s*/i
            cond = make_custom_use_condition(:formula, $1)
          end
          group.conditions << cond
        end
        @use_conditions << group
      end
    end
    
    def make_custom_use_condition(type, value)
      return Data_UseCondition.new(type, value)
    end
  end
end

class Data_UseConditionGroup
  
  attr_reader :conditions
  
  def initialize
    @conditions = []
  end
end

class Data_UseCondition
  
  attr_reader :type
  attr_reader :value
  
  def initialize(type, value)
    @type = type
    @value = value
  end
  
  def eval_use_condition(a, p=$game_party, t=$game_troop, s=$game_switches, v=$game_variables)
    eval(@value)
  end
end

class Game_BattlerBase
  
  def custom_use_conditions_met?(item)
    true
  end
end

class Game_Actor < Game_Battler
  
  alias :th_use_conditions_usable? :usable?
  def usable?(item)
    bool = th_use_conditions_usable?(item)
    return false unless bool
    unless @check_use_custom_conditions
      @check_use_custom_conditions = true
      bool = custom_use_conditions_met?(item)
      @check_use_custom_conditions = false
    end
    return bool
  end
  
  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  alias :th_use_conditions_custom_use_conditions_met? :custom_use_conditions_met?
  def custom_use_conditions_met?(item)
    return false unless th_use_conditions_custom_use_conditions_met?(item)
    return true if item.nil? || item.use_conditions.empty?
    weapons = self.weapons
    armors = self.armors
    
    weapon_ids = weapons.collect {|obj| obj.id}
    wtype_ids = weapons.collect {|obj| obj.wtype_id}
    armor_ids = armors.collect {|obj| obj.id}
    atype_ids = armors.collect {|obj| obj.atype_id}
    state_ids = self.states.collect {|obj| obj.id }

    # for each group
    item.use_conditions.each do |group|      
      # skip if any are not satisfied
      next if group.conditions.any? do |cond|
        value = cond.value
        case cond.type
        when :weapon
          !weapon_ids.include?(value)
        when :armor
          !armor_ids.include?(value)
        when :state
          !state_ids.include?(value)
        when :class
          !(@class_id == value)
        when :actor
          !(@actor_id == value)
        when :wtype
          !wtype_ids.include?(value)
        when :atype
          !atype_ids.include?(value)
        when :learned
          !@skills.include?(value)
        when :formula
          !cond.eval_use_condition(self)
        end
      end
      
      # all are satisfied, so this group is satisfied
      return true
    end
    return false
  end
end

class Window_BattleItem < Window_ItemList
  
  #--------------------------------------------------------------------------
  # Overwrite. Item usability is based on actor, not party
  #--------------------------------------------------------------------------
  def include?(item)
    BattleManager.actor.usable?(item)
  end
end