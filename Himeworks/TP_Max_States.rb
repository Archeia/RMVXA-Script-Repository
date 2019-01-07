=begin
#===============================================================================
 Title: TP Max States
 Author: Hime
 Date: Jun 8, 2013
--------------------------------------------------------------------------------
 ** Change log
 Jun 8, 2013
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
 
 This script allows you to set states that will be added when an actor's TP
 is maxed. When the actor's TP is no longer maxed, the state is removed.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 Note-tag actors or classes with
 
   <TPmax states: id1, id2, id3, ... >
   ------------------------------------------------
   <TPmax states: 12>
   <TPmax states: 13, 14>
   
 The specified states will be added once the actor's TP reaches the maximum.
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_TPMaxStates"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module TP_Max_States
    
    Regex = /<TPmax[-_ ]states: (.*)>/i
#===============================================================================
# ** Rest of Script
#===============================================================================    
    def tpmax_states
      return @tpmax_states unless @tpmax_states.nil?
      load_notetag_tpmax_states
      return @tpmax_states
    end
    
    def load_notetag_tpmax_states
      @tpmax_states = []
      res = Regex.match(self.note)
      @tpmax_states.concat(res[1].split(",").map!{|id| id.to_i}) if res
    end
  end
end

module RPG
  class Actor
    include TH::TP_Max_States
  end
  
  class Class
    include TH::TP_Max_States
  end
end

class Game_BattlerBase
  
  #-----------------------------------------------------------------------------
  # Perform TP checks when the TP is changed. Assumes all TP changing goes
  # this setter method...
  #-----------------------------------------------------------------------------
  alias :th_tpmax_state_tp= :tp=
  def tp=(tp)
    self.th_tpmax_state_tp=(tp)
    if @tp == self.max_tp
      add_tpmax_states 
    else
      remove_tpmax_states
    end
  end
  
  #-----------------------------------------------------------------------------
  # New. Adds TP Max states
  #-----------------------------------------------------------------------------
  def add_tpmax_states
    tpmax_states.each do |id|
      add_state(id)
    end
  end
  
  #-----------------------------------------------------------------------------
  # New. Removes TP Max states
  #-----------------------------------------------------------------------------
  def remove_tpmax_states
    tpmax_states.each do |id|
      remove_state(id)
    end
  end
  
  #-----------------------------------------------------------------------------
  # New. Returns an array of TP Max state ID's
  #-----------------------------------------------------------------------------
  def tpmax_states
    []
  end
end

class Game_Actor < Game_Battler
  
  def tpmax_states
    super + actor.tpmax_states + self.class.tpmax_states
  end
end