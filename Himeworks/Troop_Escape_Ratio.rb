=begin
#===============================================================================
 Title: Troop Escape Ratio
 Author: Hime
 Date: Mar 30, 2013
--------------------------------------------------------------------------------
 ** Change log
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
 
 This script allows you to specify a custom escape ratio formula for each
 troop.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this below Materials and above Main.

--------------------------------------------------------------------------------
 ** Usage 
 
 In the first page of a troop event, create a comment of the form
 
   <escape ratio: formula>

 Where `formula` is a valid ruby statement that returns a number.
 Four variables are available in your formula

    p - current game party
    t - current troop
    v - game variables
    s - game switches
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_TroopEscapeRatio"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Troop_Escape_Ratio
    
    # Default escape ratio if none specified.
    # This is what the default project uses
    Global_Ratio = "1.5 - 1.0 * t.agi / p.agi"
    
    Regex = /<escape ratio:\s*(.*)>/i
  end
end

module BattleManager
  
  class << self
    alias :th_troop_escape_rate_make_escape_ratio :make_escape_ratio
  end

  def self.make_escape_ratio
    if $game_troop.custom_escape_ratio?
      @escape_ratio = $game_troop.escape_ratio
    else
      th_troop_escape_rate_make_escape_ratio
    end
    p @escape_ratio
  end
end

module RPG
  class Troop
    
    #---------------------------------------------------------------------------
    # Our custom troop escape formula
    #---------------------------------------------------------------------------
    def escape_ratio_formula
      return @escape_ratio_formula unless @escape_ratio_formula.nil?
      parse_troop_escape_ratio_formula
      return @escape_ratio_formula
    end
    
    #---------------------------------------------------------------------------
    # Only parses the first page
    #---------------------------------------------------------------------------
    def parse_troop_escape_ratio_formula
      @escape_ratio_formula = TH::Troop_Escape_Ratio::Global_Ratio
      @pages[0].list.each do |cmd|
        if cmd.code == 108 && cmd.parameters[0] =~ TH::Troop_Escape_Ratio::Regex
          @escape_ratio_formula = $1
        end
      end
    end
  end
end

class Game_Troop < Game_Unit
  
  #-----------------------------------------------------------------------------
  # Evaluate the escape ratio
  #-----------------------------------------------------------------------------
  def eval_escape_ratio(formula, p, t, v=$game_variables, s=$game_switches)
    eval(formula)
  end
  
  #-----------------------------------------------------------------------------
  # Returns the evaluated escape ratio
  #-----------------------------------------------------------------------------
  def escape_ratio
    return eval_escape_ratio(troop.escape_ratio_formula, $game_party, self)
  end
  
  #-----------------------------------------------------------------------------
  # Returns true if the troop has a custom escape ratio formula
  #-----------------------------------------------------------------------------
  def custom_escape_ratio?
    !troop.escape_ratio_formula.empty?
  end
end