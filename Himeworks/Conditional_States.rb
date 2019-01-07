=begin
#===============================================================================
 Title: Conditional States
 Author: Hime
 Date: Mar 23, 2014
 URL: http://www.himeworks.com/2014/01/11/conditional-states/
--------------------------------------------------------------------------------
 ** Change log
 Mar 23, 2014
   - added support for resisting the placeholder state itself
 Jan 11, 2014
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
 
 This script allows you to create "conditional states".
 A conditional state is simply a placeholder for other states, depending on the
 conditions at the time the state is applied.
 
 For example, suppose you have a skill that adds a Weak Poison state to a target
 if it is not already poisoned, and adds a Strong Poison state if it has Weak
 Poison inflicted. You can use a formula to determine whether the weak poison
 has been added or not to determine which state should be added.

--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 To create a conditional state, note-tag a state with
 
   <conditional state>
     FORMULA
   </conditional state>
   
 Where the formula returns a number, which is the state ID that will be applied.
 If you don't want a state to be applied, you can use 0.
 
 The following formula variables are available
 
   a - the battler that the state will be added to
   p - game party
   t - game troop
   s - game switches
   v - game variables
 
--------------------------------------------------------------------------------
 ** Example
 
 Assuming you have two states Weak Poison (12) and Strong Poison (13), you can
 create a conditional state (14) that will add Strong Poison if Weak Poison is
 already applied, or apply Weak Poison otherwise.
 
   <conditional state>
     if a.state?(12)
       13
     else
       12
     end
   </conditional state>
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_ConditionalStates] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Conditional_States
    
    Regex = /<conditional[-_ ]state>(.*?)<\/conditional[-_ ]state>/im
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  class State < BaseItem
    def conditional_state_formula
      load_notetag_conditional_state unless @conditional_state_formula
      return @conditional_state_formula
    end
    
    def conditional_state?
      load_notetag_conditional_state if @is_conditional_state.nil?
      @is_conditional_state
    end
    
    def load_notetag_conditional_state
      @conditional_state_formula = "0"
      @is_conditional_state = false
      res = self.note.match(TH::Conditional_States::Regex)
      if res
        @conditional_state_formula = res[1]
        @is_conditional_state = true
      end
    end
    
    def eval_conditional_state(a, p=$game_party, t=$game_troop, v=$game_variables, s=$game_switches)
      eval(self.conditional_state_formula)
    end
  end
end

class Game_Battler < Game_BattlerBase
  
  alias :th_conditional_states_add_state :add_state
  def add_state(state_id)
    new_state_id = get_conditional_state(state_id)
    th_conditional_states_add_state(new_state_id)
  end
  
  def get_conditional_state(state_id)
    state = $data_states[state_id]
    return state_id unless state.conditional_state? && state_addable?(state_id)
    return state.eval_conditional_state(self)
  end
end