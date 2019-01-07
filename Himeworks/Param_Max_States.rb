=begin
#===============================================================================
 Title: Param Max States
 Author: Hime
 Date: Jun 10, 2013
--------------------------------------------------------------------------------
 ** Change log
 Jun 10, 2013
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
 
 This script allows you to set states that will be added when an actor's
 battle params are maxed out.
 
 You can add HP max states, MP max states, or TP max states.
 These states are removed when the battle param is no longer maxed.
 
 These are only applied in battle.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 Note-tag actors or classes with
 
   <param max states: TYPE id1 id2 id3 ... >
   ------------------------------------------------
   <param max states: tp 2>
   <param max states: hp 3 4 5>
   <param max states: mp 6 7>
   
 TYPE is the battle param to check, followed by the state ID's that will be
 added.
   
 The specified states will be added once the appropriate battle param has
 been maxed.
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_ParamMaxStates"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Param_Max_States
    
    Regex = /<param[-_ ]max[-_ ]states: (\w+) (.*)>/i
#===============================================================================
# ** Rest of Script
#===============================================================================    
    def param_max_states(type)
      return @param_max_states[type] unless @param_max_states.nil?
      load_notetag_param_max_states
      return @param_max_states[type]
    end
    
    def load_notetag_param_max_states
      @param_max_states = {}
      @param_max_states[:hp] = []
      @param_max_states[:tp] = []
      @param_max_states[:mp] = []
      
      res = self.note.scan(Regex)
      res.each do |results|
        type = results[0].downcase.to_sym
        @param_max_states[type].concat(results[1].split.map!{|id| id.to_i})
      end
    end
  end
end

module RPG
  class Actor
    include TH::Param_Max_States
  end
  
  class Class
    include TH::Param_Max_States
  end
end

class Game_BattlerBase
  
  #-----------------------------------------------------------------------------
  # Perform checks when battle params change.
  #-----------------------------------------------------------------------------
  alias :th_param_max_state_tp= :tp=
  def tp=(tp)
    self.th_param_max_state_tp=(tp)
    @tp == self.max_tp ? add_param_max_states(:tp) : remove_param_max_states(:tp)
  end
  
  alias :th_param_max_state_hp= :hp=
  def hp=(hp)
    self.th_param_max_state_hp=(hp)
    @hp == self.mhp ? add_param_max_states(:hp) : remove_param_max_states(:hp)
  end
  
  alias :th_param_max_state_mp= :mp=
  def mp=(mp)
    self.th_param_max_state_mp=(mp)
    @mp == self.mmp ? add_param_max_states(:mp) : remove_param_max_states(:mp)
  end
  
  #-----------------------------------------------------------------------------
  # New. Adds TP Max states
  #-----------------------------------------------------------------------------
  def add_param_max_states(type)
    param_max_states(type).each do |id|
      add_state(id)
    end
  end
  
  #-----------------------------------------------------------------------------
  # New. Removes TP Max states
  #-----------------------------------------------------------------------------
  def remove_param_max_states(type)
    param_max_states(type).each do |id|
      remove_state(id)
    end
  end
  
  #-----------------------------------------------------------------------------
  # New. Returns an array of TP Max state ID's
  #-----------------------------------------------------------------------------
  def param_max_states(type)
    []
  end
end

class Game_Actor < Game_Battler
  def param_max_states(type)
    super + actor.param_max_states(type) + self.class.param_max_states(type)
  end
end


#-------------------------------------------------------------------------------
# Perform checks at the beginning of the battle
#-------------------------------------------------------------------------------
module BattleManager
  class << self
    alias :th_param_max_states_setup :setup
  end
  
  def self.setup(*args)
    th_param_max_states_setup(*args)
    $game_party.members.each {|mem| mem.check_param_max_states}
  end
end

class Game_Actor < Game_Battler
  def check_param_max_states
    @tp == self.max_tp ? add_param_max_states(:tp) : remove_param_max_states(:tp)
    @hp == self.mhp ? add_param_max_states(:hp) : remove_param_max_states(:hp)
    @mp == self.mmp ? add_param_max_states(:mp) : remove_param_max_states(:mp)
  end
end