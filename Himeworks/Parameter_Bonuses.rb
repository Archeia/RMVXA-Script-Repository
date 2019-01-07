=begin
#===============================================================================
 Title: Parameter Bonuses
 Author: Hime
 Date: Aug 1, 2014
 URL: http://himeworks.com/2013/12/09/parameter-bonuses/
--------------------------------------------------------------------------------
 ** Change log
 Aug 1, 2014
   - added a reference to the tagged object
 Jul 24, 2014
   - added support for class, armors, weapons, and states
 Dec 20, 2013
   - added support for "recursive" references
   - added support for passing in the base parameter
   - added support for enemy parameter bonuses
 Dec 9, 2013
   - initial release
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
 
 This script allows you to define "Parameter bonuses" for your actors and
 enemies. A paramter bonus is simply a bonus that will be added to your
 parameters based on a formula. The bonus itself could be an increase, or
 even a decrease in stats if you provide a negative value.
 
 For example, suppose you had custom parameters that allowed you to define
 stats like "strength" or "intelligence", where str increases your atk and
 max HP params while int increases magic attack and magic defense stats. You
 can use parameter bonuses to define formulas that will allow your str and int
 stats to contribute to the other parameters.
 
 Since the parameter bonus can be any formula, you can define bonuses based
 on anything.
 
 Parameter bonuses can be defined in actors, classes, weapons, armors, states,
 and enemies. Actors will inherit any bonuses defined in their class, equips,
 and states. Enemies will inherit any bonuses defined in their states.
 
 Because equips and states can be changed, you can use this to create unique
 effects.

--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage
 
 To define a parameter bonus, note-tag actors with
 
   <param bonus: TYPE>
     FORMULA
   </param bonus>
   
 Where the TYPE is one of
 
   mhp - max HP
   mmp - max MP
   atk - attack
   def - defense
   mat - magic attack
   mdf - magic defense
   agi - agility
   luk - luck
   
 And the formula can be any valid ruby formula.
 The following formula variables are available
 
   a - the current battler (actor or enemy)
 obj - the tagged object
   p - game party
   t - game troop
   v - game variables
   s - game switches
   
 You can have a bonus reference itself. For example
 
   <param bonus: atk>
     a.atk * 1.5
   </param bonus>
   
 Will increase the battler's atk value by 50%. This atk value does not
 include the bonus, but includes base params and extra params.
   
 You can define multiple parameter bonuses for an actor, and you can define
 multiple bonuses for the same stat; simply add more of the note-tag.
 
 == Object Reference ==
 
 The `obj` variable is a special variable that you can use to refer
 to the object that the bonus is attached to. For example, suppose
 you notetagged a weapon with
 
 <param bonus: mhp>
    obj.params[2] * 10
 </param bonus>
 
 This means that you receive an HP bonus equal to the weapon's atk times 10.
 All of the attributes that you can access in a weapon is available.
 
 If the bonus is attached to an armor, then `obj` references that armor, and
 so on.
 
--------------------------------------------------------------------------------
 ** Example
 
 Suppose we have a custom stat called "str", and for each point of str, it
 increases HP by 10 and atk by 2. You would use two parameter bonuses:
 
   <param bonus: mhp>
     a.str * 10
   </param bonus>
   
   <param bonus: atk>
     a.str * 2
   </param bonus>
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_ParameterBonus"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Parameter_Bonuses
    Regex = /<param[-_ ]bonus:\s*(\w+)\s*>(.*?)<\/param[-_ ]bonus>/im

#===============================================================================
# ** Rest of Script
#===============================================================================
    Table = {
      :mhp => 0,
      :mmp => 1,
      :atk => 2,
      :def => 3,
      :mat => 4,
      :mdf => 5,
      :agi => 6,
      :luk => 7
    }
  end
end

module RPG
  class BaseItem
    def param_bonuses
      load_notetag_param_bonuses unless @param_bonuses
      return @param_bonuses
    end
    
    def load_notetag_param_bonuses
      @param_bonuses = []
      results = self.note.scan(TH::Parameter_Bonuses::Regex)
      results.each do |res|
        param = res[0].downcase.to_sym
        formula = res[1].strip
        id = TH::Parameter_Bonuses::Table[param]
        data = Data_ParamBonus.new(id, formula, self)
        @param_bonuses << data
      end
    end
  end
end

class Data_ParamBonus
  
  attr_accessor :param_id
  attr_accessor :formula
	attr_accessor :obj
  
  def initialize(param_id, formula="0", obj)
    @param_id = param_id
    @formula = formula
		@obj = obj
  end
  
  def value(a, p=$game_party, t=$game_troop, s=$game_switches, v=$game_variables)
    eval(@formula)
  end
end

class Game_BattlerBase
  
  def param_bonus_objects
    states
  end
  
  alias :th_param_bonuses_param_plus :param_plus
  def param_plus(param_id)
    th_param_bonuses_param_plus(param_id) + param_bonus(param_id)
  end
  
  #-----------------------------------------------------------------------------
  # Calculates the bonus parameter.
  #-----------------------------------------------------------------------------
  def param_bonus(param_id)
    return 0 if @check_param_bonus
    @check_param_bonus = true
    val = param_bonus_objects.inject(0) do |r, bonus_obj|
      bonus_obj.param_bonuses.inject(r) do |r2, obj|
        obj.param_id == param_id ? r2 += obj.value(self) : r2
      end
    end
    @check_param_bonus = false
    return val
  end
end

class Game_Actor < Game_Battler
  
  alias :th_parameter_bonuses_param_bonus_objects :param_bonus_objects
  def param_bonus_objects
    feature_objects
  end
end

class Game_Enemy < Game_Battler
  
  alias :th_parameter_bonuses_param_bonus_objects :param_bonus_objects
  def param_bonus_objects
    feature_objects
  end
end