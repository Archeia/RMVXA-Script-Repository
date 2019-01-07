=begin
#===============================================================================
 Title: Permanent States
 Author: Hime
 Date: Oct 20, 2014
--------------------------------------------------------------------------------
 ** Change log
 Oct 20, 2014
   - state? now includes a check for permanent states
 Jan 14, 2014
   - fixed bug where invalid states are being checked if they are permastates
 Apr 16, 2013
   - updated to initialize permastates on game load
 Apr 14, 2013
   - updated script with some more state-query methods
 Mar 9, 2013
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
 
 This script adds "permanent states" (permastates) to your game.
 A permastate is just a state, except are not removed upon death.
 
 A permastate is very useful for managing features on your actors, since you
 can control which features will be applied to your actors using event
 commands and you can remove them when needed.
 
--------------------------------------------------------------------------------
 ** Usage
 
 Tag states with 
 
   <permastate>
   
 Use event commands to add or remove states.
 
 You can check whether a battler has a permament state using
 
   battler.permastate?(state_id)

#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_PermanentStates"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Permanent_States
    Regex = /<permastate>/i
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module DataManager
  class << self
    alias :th_permanent_states_extract_save_contents :extract_save_contents
  end
  
  def self.extract_save_contents(contents)
    th_permanent_states_extract_save_contents(contents)
    initialize_permanent_states
  end
  
  def self.initialize_permanent_states
    ($data_actors.size - 1).times do |i|
      $game_actors[i+1].init_permastates
    end
  end
end

module RPG
  class State < BaseItem
    
    #---------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------
    def permastate?
      return @permastate unless @permastate.nil?
      return @permastate = !(self.note =~ TH::Permanent_States::Regex).nil?
    end
  end
end

class Game_BattlerBase
  
  alias :th_permanent_states_init :initialize
  def initialize
    init_permastates
    th_permanent_states_init
  end
  
  #-----------------------------------------------------------------------------
  # Initialize permanant state array if necessary
  #-----------------------------------------------------------------------------
  def init_permastates
    @permastates ||= []
  end
  
  #-----------------------------------------------------------------------------
  # Clear out all permanent states
  #-----------------------------------------------------------------------------
  def clear_permastates
    @permastates.clear
  end
  
  alias :th_permanent_states_feature_objects :feature_objects
  def feature_objects
    permastates + th_permanent_states_feature_objects
  end
  
  #-----------------------------------------------------------------------------
  # Returns true if the specified permanent state is applied
  #-----------------------------------------------------------------------------
  def permastate?(state_id)
    @permastates.include?(state_id)
  end
  
  #-----------------------------------------------------------------------------
  # Returns set of permanent states that are currently applied
  #-----------------------------------------------------------------------------
  def permastates
    @permastates.collect {|state_id| $data_states[state_id]}
  end

  #-----------------------------------------------------------------------------
  # Return true if the specified state is a permanent state
  #-----------------------------------------------------------------------------
  def is_permastate?(state_id)
    return false unless state_id > 0
    $data_states[state_id].permastate?
  end
  
  alias :th_permanent_states_state? :state?
  def state?(state_id)
    th_permanent_states_state?(state_id) || permastate?(state_id)
  end
end

class Game_Battler < Game_BattlerBase

  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  alias :th_permanent_states_add_state :add_state
  def add_state(state_id)
    if is_permastate?(state_id)
      add_permastate(state_id)
    else
      th_permanent_states_add_state(state_id)
    end
  end
  
  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  alias :th_permanent_states_remove_state :remove_state
  def remove_state(state_id)
    if is_permastate?(state_id)
      remove_permastate(state_id)
    else
      th_permanent_states_remove_state(state_id)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Store permanent state ID's in a separate array
  #-----------------------------------------------------------------------------
  def add_permastate(state_id)
    @permastates |= [state_id]
  end
  
  #-----------------------------------------------------------------------------
  # Remove permanent state
  #-----------------------------------------------------------------------------
  def remove_permastate(state_id)
    @permastates -= [state_id]
  end
end