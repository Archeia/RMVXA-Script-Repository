=begin
#===============================================================================
 Title: State Charges
 Author: Hime
 Date: Jun 14, 2015
--------------------------------------------------------------------------------
 ** Change log
 Jun 14, 2015
   - only reset state counts if state is still applied
 Mar 22, 2014
   - fixed bug where states with charges are not removed after battle
 Feb 28, 2014
   - state is correctly removed when charges drop to zero
 Nov 16, 2013
   - is it possible to have the state but no state charge recorded?
 Sep 14, 2013
   - added some methods for adding/removing state charges
 Jun 23, 2013
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
 
 This script adds "charges" to states. These charges represent how many
 times is required to remove a state. For example, a state with 4 charges
 means it must be removed 4 times in order for it to be completely removed.
 
 This is different from "stacked" states in the sense that the state itself
 is not applied multiple times.
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main.
 If you are using Yanfly's state maanger, place this script below the state
 manager

--------------------------------------------------------------------------------
 ** Usage
 
 Note-tag states with
 
   <state charges: x>
   
 Where x is the number of charges a state has when it is applied.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_StateCharges"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module State_Charges
    
    Regex = /<state[-_ ]charges: (\d+)>/i
  end
end
#===============================================================================
# ** Rest of the script
#=============================================================================== 
module RPG
  class State
    def state_charges
      return @state_charges unless @state_charges.nil?
      load_notetag_state_charges
      return @state_charges
    end
    
    def load_notetag_state_charges
      res = self.note.match(TH::State_Charges::Regex)
      @state_charges = res ? res[1].to_i : 1
    end
  end
end

class Game_BattlerBase
  
  alias :th_state_charges_clear_states :clear_states
  def clear_states
    th_state_charges_clear_states
    @state_charges = {}
  end
  
  alias :th_state_charges_erase_state :erase_state
  def erase_state(state_id)
    th_state_charges_erase_state(state_id)
    @state_charges.delete(state_id)
  end
end

class Game_Battler < Game_BattlerBase
  
  alias :th_state_charges_remove_state :remove_state
  def remove_state(state_id)
    if has_state_charges?(state_id)
      remove_state_charges(state_id, 1)
      reset_state_counts(state_id) if state?(state_id)
    else
      th_state_charges_remove_state(state_id)
    end
  end
  
  alias :th_state_charges_add_new_state :add_new_state
  def add_new_state(state_id)
    set_state_charges(state_id, $data_states[state_id].state_charges)
    th_state_charges_add_new_state(state_id)
  end
  
  def state_charges(state_id)
    return @state_charges[state_id]
  end
  
  def set_state_charges(state_id, amount)
    @state_charges[state_id] = amount
  end
  
  def add_state_charges(state_id, amount)
    @state_charges[state_id] += amount
  end
  
  def remove_state_charges(state_id, amount)
    @state_charges[state_id] = [@state_charges[state_id]-amount, 0].max
    th_state_charges_remove_state(state_id) if @state_charges[state_id] == 0
  end
  
  def has_state_charges?(state_id)
    return state?(state_id) && @state_charges[state_id] && @state_charges[state_id] > 0
  end
  
  alias :th_state_charges_remove_battle_states :remove_battle_states
  def remove_battle_states
    remove_battle_state_charges
    th_state_charges_remove_battle_states
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def remove_battle_state_charges
    states.each do |state|
      @state_charges[state.id] = 0 if state.remove_at_battle_end
    end
  end
end