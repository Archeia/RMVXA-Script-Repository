=begin
#===============================================================================
 Title: Enemy Gold Formulas
 Author: Hime
 Date: Dec 31, 2013
--------------------------------------------------------------------------------
 ** Change log
 Dec 31, 2013
   - added support for referencing the current enemy
 Jun 12, 2013
   - added support for extended note-tag
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
 
 This script allows you to use a formula to calculate how much gold is obtained
 from an enemy.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage

 Note-tag enemies with
 
   <gold formula: FORMULA>
   
 Where the FORMULA is any valid ruby formula that returns a number.
 You can use the following variables in your formula:
 
   gold - the default gold value set in the database for that enemy
      a - the current enemy
      p - game party
      t - game troop
      v - game variables
      s - game switches
   
 If no gold formula is specified, then the default gold is given.
 
 If you would like to use ruby statements that extend across multiple lines,
 you can use the extended note-tag:
 
   <gold formula>
     if v[1]
       gold + 200
     else
       gold - 200
     end
   </gold formula>
   
 This is only if you need more flexibility.
   
--------------------------------------------------------------------------------
 ** Examples
   
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_EnemyGoldFormulas"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Enemy_Gold_Formula
    
    Regex = /<gold[-_ ]formula: (.*)>/i
    Ext_Regex = /<gold[-_ ]formula>(.*?)<\/gold[-_ ]formula>/im
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  class Enemy < BaseItem
    
    #---------------------------------------------------------------------------
    # New. Evaluates the exp formula
    #---------------------------------------------------------------------------
    def eval_gold_formula(a, gold, p=$game_party, t=$game_troop, v=$game_variables, s=$game_switches)
      eval(self.gold_formula)
    end
    
    #---------------------------------------------------------------------------
    # Gold formula to use. Used internally for the most part
    #---------------------------------------------------------------------------
    def gold_formula
      return @gold_formula unless @gold_formula.nil?
      load_notetag_gold_formula
      return @gold_formula
    end
    
    def load_notetag_gold_formula
      @gold_formula = ""
      res = self.note.match(TH::Enemy_Gold_Formula::Regex)
      @gold_formula = res[1] if res
      res = self.note.match(TH::Enemy_Gold_Formula::Ext_Regex)
      @gold_formula = res[1] if res
    end
  end
end

class Game_Enemy < Game_Battler
  
  #-----------------------------------------------------------------------------
  # Pass it in for another evaluation, this time with the current enemy
  #-----------------------------------------------------------------------------
  alias :th_enemy_gold_formula_gold :gold
  def gold
    enemy.eval_gold_formula(self, th_enemy_gold_formula_gold)
  end
end