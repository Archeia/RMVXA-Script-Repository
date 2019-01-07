=begin
#===============================================================================
 Title: Enemy Exp Formulas
 Author: Hime
 Date: Dec 31, 2013
--------------------------------------------------------------------------------
 ** Change log
 Dec 31, 2013
   - added support for "current enemy" formula variable
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
 
 This script allows you to use a formula to calculate how much exp is obtained
 from an enemy.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage

 Note-tag enemies with
 
   <exp formula: FORMULA>
   
 Where the FORMULA is any valid ruby formula that returns a number.
 You can use the following variables in your formula:
 
   exp - the default exp value set in the database for that enemy
     a - the current enemy
     p - game party
     t - game troop
     v - game variables
     s - game switches
   
 If no exp formula is specified, then the default exp is given.
 
 If you would like to use ruby statements that extend across multiple lines,
 you can use the extended note-tag:
 
   <exp formula>
     if v[1]
       exp + 200
     else
       exp - 200
     end
   </exp formula>
   
 This may be useful if you have complex logic and you don't want to write it as
 a one-liner.
   
--------------------------------------------------------------------------------
 ** Examples
 
 Divide exp by the number of battle members
   <exp formula: exp / p.battle_members.size>
   
 Increase exp by some multiplier based on variable 1  
   <exp formula: exp + (v[1] * 100)>
   
 Give a nice bonus based on whether switch 1 is ON
   <exp formula: s[1] ? exp * 10000 : exp >
   
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_EnemyExpFormulas"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Enemy_Exp_Formula
    
    Regex = /<exp[-_ ]formula: (.*)>/i
    Ext_Regex = /<exp[-_ ]formula>(.*?)<\/exp[-_ ]formula>/im
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
    def eval_exp_formula(a, exp, p=$game_party, t=$game_troop, v=$game_variables, s=$game_switches)
      eval(self.exp_formula)
    end
    
    #---------------------------------------------------------------------------
    # Exp formula to use. Used internally for the most part
    #---------------------------------------------------------------------------
    def exp_formula
      return @exp_formula unless @exp_formula.nil?
      load_notetag_exp_formula
      return @exp_formula
    end
    
    def load_notetag_exp_formula
      @exp_formula = "exp"
      res = self.note.match(TH::Enemy_Exp_Formula::Regex)
      @exp_formula = res[1] if res
        
      res = self.note.match(TH::Enemy_Exp_Formula::Ext_Regex)
      @exp_formula = res[1] if res
    end
  end
end

class Game_Enemy < Game_Battler
  
  alias :th_enemy_exp_formula_exp :exp
  def exp
    enemy.eval_exp_formula(self, th_enemy_exp_formula_exp)
  end
end