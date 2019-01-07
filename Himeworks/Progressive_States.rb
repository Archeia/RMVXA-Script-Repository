=begin
#===============================================================================
 Title: Progressive State
 Author: Hime
 Date: Jan 14, 2013
--------------------------------------------------------------------------------
 ** Change log
 Jan 14, 2014
   - fixed bug where game tries to add state 0
 Jun 6, 2013
   - fixed bug: progressive states were not properly checking removal timing
   - bug fix: crash on removal by walking
 Mar 28, 2013
   - added support for out-of-battle state progression
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
 
 This script adds "progressive state" functionality to your project.
 
 A progressive state is one that automatically changes to another state
 after a certain amount of turns.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage
 
 Add the following note-tag to a state
 
   <progressive state: x>
   
 For some state ID x. When the state is automatically removed due to timing 
 (turn count, action count), the new state will be applied and the
 old state removed.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_ProgressiveStates"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Progressive_States
    Regex = /<progressive[-_ ]state:\s*(\d+)\s*>/i
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  class State < BaseItem
    def progressive_state
      return @progressive_state unless @progressive_state.nil?
      load_notetag_progressive_state
      return @progressive_state
    end
    
    def load_notetag_progressive_state
      res = self.note.match(TH::Progressive_States::Regex)
      @progressive_state = res ? res[1].to_i : 0
    end
  end
end

class Game_Battler < Game_BattlerBase
  
  #-----------------------------------------------------------------------------
  # Add new states, then remove old ones
  #-----------------------------------------------------------------------------
  alias :th_progressive_states_remove_states_auto :remove_states_auto
  def remove_states_auto(timing)
    states.each do |state|
      if @state_turns[state.id] == 0 && state.auto_removal_timing == timing
        add_progressive_state(state)
      end
    end
    th_progressive_states_remove_states_auto(timing)
  end
  
  def add_progressive_state(state)
    return if state.progressive_state == 0
    add_state(state.progressive_state)
  end
  
  def add_progressive_states
    states.each do |state|
      next if state.progressive_state == 0
      add_state(state.progressive_state) if @state_turns[state.id] == 0
    end
  end
end

class Game_Actor < Game_Battler
  
  alias :th_progressive_states_update_state_steps :update_state_steps
  def update_state_steps(state)
    th_progressive_states_update_state_steps(state)
    add_progressive_state_by_steps(state) if state.remove_by_walking
  end
  
  def add_progressive_state_by_steps(state)
    if @state_steps[state.id].nil?
      add_state(state.progressive_state) 
    end
  end
end