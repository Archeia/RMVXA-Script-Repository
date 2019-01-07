=begin
#===============================================================================
 Title: Execution States
 Author: Hime
 Date: Jul 10, 2015
--------------------------------------------------------------------------------
 ** Change log
 May 30, 2015
   - fixed bug with note-tag
 Jul 10, 2014
   - Execution states can apply to the user, or the user's entire unit
 May 28, 2013
   - Execution states are now stored with the battler when they are added
     so if the action was cleared out the states can still be removed
 Mar 30, 2013
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
 
 This script adds execution states. These are states that are applied when a
 skill or item is being used, and are removed after the action has been
 executed.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this below Materials and above Main.

--------------------------------------------------------------------------------
 ** Usage 
 
 Tag skill or items with the following note-tag
 
   <exec state: x>
   <exec state: x type>
  
 For some state ID x.
 You can have multiple execution states.
 
 If you specify the type "unit", it will apply to everyone in the user's
 unit as well.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_ExecutionStates"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Execution_States
    
    Regex = /<exec[-_ ]state:\s*(\d+)\s*(\w+)?\s*>/i
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  class UsableItem < BaseItem
    
    def exec_states
      return @exec_states unless @exec_states.nil?
      load_notetag_execution_states
      return @exec_states
    end
    
    def load_notetag_execution_states
      @exec_states = []
      res = self.note.scan(TH::Execution_States::Regex)
      res.each do |result|
        execState = Data_ExecutionState.new
        execState.state_id = result[0].to_i
        execState.type = result[1].to_sym if result[1]
        @exec_states.push(execState)
      end
    end
  end
end

class Data_ExecutionState
  
  attr_accessor :state_id
  attr_accessor :type
  
  def initialize
    @state_id = 0
    @type = :user
  end
end

class Game_Battler < Game_BattlerBase
  
  attr_reader :added_execution_states
  
  #-----------------------------------------------------------------------------
  # Add casting states to the current battler when item is used
  #-----------------------------------------------------------------------------
  alias :th_exec_states_use_item :use_item
  def use_item(item)
    th_exec_states_use_item(item)
    add_execution_states(item)
  end
  
  def add_execution_states(item)
    @added_execution_states = item.exec_states
    item.exec_states.each do|state|
      if state.type == :unit
        friends_unit.members.each do |mem|
          mem.add_state(state.state_id)
        end
      else
        add_state(state.state_id)
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Remove casting states. This may include states that already existed
  # before the item was used though
  #-----------------------------------------------------------------------------
  def remove_execution_states
    @added_execution_states.each {|state| remove_state(state.state_id)}
  end
end

class Scene_Battle < Scene_Base
  
  #-----------------------------------------------------------------------------
  # Remove casting states after action has been executed
  #-----------------------------------------------------------------------------
  alias :th_exec_states_execute_action :execute_action
  def execute_action
    th_exec_states_execute_action
    @subject.remove_execution_states
  end
end