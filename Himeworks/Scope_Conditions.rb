=begin
#===============================================================================
 Title: Scope Conditions
 Author: Hime
 Date: Apr 25, 2015
--------------------------------------------------------------------------------
 ** Change log
 Apr 25, 2015
   - updated note-tag to support > in formulas
 Nov 28, 2014
   - fixed bug where target filtering does not check for nil objects
 Apr 6, 2013
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
 
 This script allows you to specify a scope condition for your items and skills.
 
 A scope condition is a formula that is used to determine whether a skill
 or item has an effect on a target or not. If it has no effect on a target then
 the action not do anything to that target.

--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 To specify a generic scope condition, note-tag skills/items with
 
   <scope condition: formula />
   
 Where the formula is some valid ruby statement.
 The following variables are available for your formula
 
   a - current attacker
   b - target
   f - friends unit
   o - opponents unit
   v - game variables
   s - game switches
   
 The target is all of the targets that the skill/item can affect. For example,
 if a skill affects all enemies, then `b` will be replaced with each enemy
 during action execution.
   
 The f and o variables depend on who the current attacker is.
 If the attacker is an actor, then the friends unit is the game party.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_ScopeConditions] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Scope_Conditions
    
    Regex = /<scope[-_ ]condition:\s*(.*?)\/>/im
    Ext_Regex = /<scope[-_ ]condition>(.*?)<\/scope[-_ ]condition>/im
    Battler_Regex = /<scope[-_ ]condition: (\w+)>(.*?)<\/scope[-_ ]condition>/im
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  class UsableItem
    
    #---------------------------------------------------------------------------
    # Returns the scope condition for the item/skill
    #---------------------------------------------------------------------------
    def scope_condition
      return @scope_condition unless @scope_condition.nil?
      load_notetag_scope_condition
      return @scope_condition
    end
    
    #---------------------------------------------------------------------------
    # Parse scope condition
    #---------------------------------------------------------------------------
    def load_notetag_scope_condition
      res = self.note.match(TH::Scope_Conditions::Regex)
      @scope_condition = res ? res[1] : ""
    end
  end
end

class Game_Action
  
  alias :th_scope_conditions_make_targets :make_targets
  def make_targets
    targets = th_scope_conditions_make_targets
    return targets.select {|target| target && target.scope_condition_met?(@subject, item)}
  end
end

class Game_Battler < Game_BattlerBase
  
  alias :th_scope_conditions_item_test :item_test
  def item_test(user, item)
    return false unless scope_condition_met?(user, item)
    th_scope_conditions_item_test(user, item)
  end
  
  def scope_condition(user, item)
    return item.scope_condition
  end
  
  #-----------------------------------------------------------------------------
  # Test on the item's scope condition
  #-----------------------------------------------------------------------------
  def scope_condition_met?(user, item)
    condition = scope_condition(user, item)
    return true if condition.empty?
    return eval_scope_condition(condition, user, self, user.friends_unit, user.opponents_unit)
  end
  
  def eval_scope_condition(formula, a, b, f, o, v=$game_variables, s=$game_switches)
    eval(formula)
  end
end