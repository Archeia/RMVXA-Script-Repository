=begin
#===============================================================================
 Title: Enemy Action Conditions
 Author: Hime
 Date: Feb 23, 2014
 URL: http://www.himeworks.com/2014/02/23/enemy-action-conditions/
--------------------------------------------------------------------------------
 ** Change log
 Feb 23, 2014
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
 
 This script allows you to define custom action conditions on top of the
 conditions that are provided by the database.
 
 You can use a formula to determine whether an action is usable or not,
 enabling you to add any condition that you can imagine for an action.

--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 When setting up the enemy in the database, you can set up the actions that the
 enemy can use. Each action has an ID: the first action on the list is ID 1,
 the second action on the list is ID 2.
 
 To add an action condition to a particular action, use the note-tag
 
   <action condition: ID>
     FORMULA
   </action condition>
   
 Where the ID is the action ID, and the FORMULA is any valid formula that
 returns true or false. All conditions must be met in order for the action to
 be usable.
 
 The following formula variables are available:
 
   a - the enemy
   p - game party
   t - game troop
   s - game switches
   v - game variables
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_EnemyActionConditions] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Enemy_Action_Conditions
    
    Ext_Regex = /<action[-_ ]condition:\s*(\d+)\s*>(.*?)<\/action[-_ ]condition>/im
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  class Enemy
    
    alias :th_enemy_action_conditions_actions :actions
    def actions
      load_notetag_enemy_action_conditions unless @enemy_action_conditions_parsed
      th_enemy_action_conditions_actions
    end
    
    def load_notetag_enemy_action_conditions
      @enemy_action_conditions_parsed = true
      enemyActions = th_enemy_action_conditions_actions
      
      results = self.note.scan(TH::Enemy_Action_Conditions::Ext_Regex)
      results.each do |res|
        action_id = res[0].to_i - 1
        formula = res[1]
        
        act = enemyActions[action_id]
        act.formula_conditions ||= []
        act.formula_conditions << formula
      end
    end
  end
  
  class Enemy::Action
    
    attr_accessor :formula_conditions
    
    def formula_conditions_met?(user)
      return true if self.formula_conditions.nil? || self.formula_conditions.empty?
      return self.formula_conditions.all? do |formula|
        eval_formula_condition(formula, user)
      end
    end
    
    def eval_formula_condition(formula, a, p=$game_party, t=$game_troop, s=$game_switches, v=$game_variables)
      eval(formula)
    end
  end
end

class Game_Enemy < Game_Battler
  
  alias :th_enemy_action_conditions_conditions_met? :conditions_met?
  def conditions_met?(action)
    return false unless th_enemy_action_conditions_conditions_met?(action)
    return false unless action.formula_conditions_met?(self)  
    return true
  end
end