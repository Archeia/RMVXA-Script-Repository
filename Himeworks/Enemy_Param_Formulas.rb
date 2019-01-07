=begin
#===============================================================================
 Title: Enemy Param Formulas
 Author: Hime
 Date: Feb 17, 2014
 URL: http://himeworks.com/2013/07/24/enemy-param-formulas/
--------------------------------------------------------------------------------
 ** Change log
 Feb 17, 2014
   - updated to prevent recursive logic
   - basic params support the "val" variable now
 Nov 11, 2013
   - added support for xparam and sparam
 Jul 23, 2013
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
 
 This script allows you to use a formula to calculate an enemy's parameters.
 You can use literal values or a set of variables provided for the formulas.
 Formulas are available for basic parameters, EX-parameters, and SP-parameters.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage

 There are formulas available for every built-in parameter.
 Use the notetag
 
   <param formula: PARAM_CODE FORMULA> 
 
 Where the PARAM_CODE is one of the following (descriptions can be found in
 the help file under "Reference Material --> Parameters and Formulas"
 
   mhp - Max HP
   mmp - Max MP
   atk - Attack
   def - Defense
   mat - Magic Attack
   mdf - Magic Defense
   agi - Agility
   luk - Luck
   hit - Hit Rate
   eva - Evasion
   cri - Critical Hit Rate
   cev - Critical Evasion Rate
   mev - Magic Evasion Rate
   mrf - Magic Reflection Rate
   cnt - Counter attack rate
   hrg - HP Regen Rate
   mrg - MP Regen Rate
   trg - TP Regen Rate
   tgr - Target rate
   grd - Defense Effectiveness
   rec - Recovery Effectiveness
   pha - Medicine Lore
   mcr - MP Consumption Rate
   tcr - TP Consumption Rate
   pdr - Physical Damage Rate
   mdr - Magic Damage Rate
   fdr - Floor Damage Rate
   exr - Exp Acquisition Rate
   
 The FORMULA is any valid ruby formula that returns a number.
 You can use the following variables in your formula:
 
    val - original parameter value specified in the database
   self - the RPG::Enemy object
      a - the subject (this Game_Enemy object)
      p - game party
      t - game troop
      v - game variables
      s - game switches
   
 If no formula is specified, then the default value is given.
 
 If you would like to use ruby statements that extend across multiple lines,
 you can use the extended note-tag:
 
   <param formula: mhp>
     if s[1]
       400
     else
       200
     end
   </param formula>
   
 This is only if you need more flexibility.
   
--------------------------------------------------------------------------------
 ** Examples
   
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_EnemyParamFormulas"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Enemy_Param_Formulas
    
    Regex = /<param[-_ ]formula: (\w+) (.*)>/i
    Ext_Regex = /<param[-_ ]formula: (\w+)>(.*?)<\/param[-_ ]formula>/im
    
    Param_Map = {
      :mhp => 0,
      :mmp => 1,
      :atk => 2,
      :def => 3,
      :mat => 4,
      :mdf => 5,
      :agi => 6,
      :luk => 7
    }
    
    XParam_Map = {
      :hit => 0,
      :eva => 1,
      :cri => 2,
      :cev => 3,
      :mev => 4,
      :mrf => 5,
      :cnt => 6,
      :hrg => 7,
      :mrg => 8,
      :trg => 9
    }
    
    SParam_Map = {
      :tgr => 0,
      :grd => 1,
      :rec => 2,
      :pha => 3,
      :mcr => 4,
      :tcr => 5,
      :pdr => 6,
      :mdr => 7,
      :fdr => 8,
      :exr => 9
    }
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  class Enemy < BaseItem
    
    def param_formula(index)
      load_notetag_param_formulas if @param_formulas.nil?
      return @param_formulas[index]
    end
    
    def xparam_formula(index)
      load_notetag_param_formulas if @xparam_formulas.nil?
      return @xparam_formulas[index]
    end
    
    def sparam_formula(index)
      load_notetag_param_formulas if @sparam_formulas.nil?
      return @sparam_formulas[index]
    end
    
    def param_base_formula(index, value, subject)
      eval_param_formula(self.param_formula(index), @params[index], subject)
    end
    
    def eval_xparam_formula(index, value, subject)
      eval_param_formula(self.xparam_formula(index), value, subject)
    end
    
    def eval_sparam_formula(index, value, subject)
      eval_param_formula(self.sparam_formula(index), value, subject)
    end
    
    def eval_param_formula(formula, val, a, p=$game_party, t=$game_troop, v=$game_variables, s=$game_switches) 
      eval(formula)
    end
    
    def load_notetag_param_formulas
      @param_formulas = []
      @xparam_formulas = []
      @sparam_formulas = []
      load_notetag_compact_param_formulas
      load_notetag_extended_param_formulas
    end
    
    def load_notetag_compact_param_formulas
      res = self.note.scan(TH::Enemy_Param_Formulas::Regex)
      res.each do |data|
        type = data[0].downcase.to_sym
        formula = data[1]
        load_notetag_add_param_formula(type, formula)
      end
    end
    
    def load_notetag_extended_param_formulas
      res = self.note.scan(TH::Enemy_Param_Formulas::Ext_Regex)
      res.each do |data|
        p data
        type = data[0].downcase.to_sym
        formula = data[1]
        load_notetag_add_param_formula(type, formula)
      end
    end
    
    #---------------------------------------------------------------------------
    # Add it to the param formula arrays
    #---------------------------------------------------------------------------
    def load_notetag_add_param_formula(type, formula)
      param_id = TH::Enemy_Param_Formulas::Param_Map[type]
      if param_id
        @param_formulas[param_id] = formula
        return
      end
      
      xparam_id = TH::Enemy_Param_Formulas::XParam_Map[type]
      if xparam_id
        @xparam_formulas[xparam_id] = formula
        return
      end
      
      sparam_id = TH::Enemy_Param_Formulas::SParam_Map[type]
      if sparam_id
        @sparam_formulas[sparam_id] = formula
        return
      end
    end
  end
end

class Game_Enemy < Game_Battler
  
  # Give it some arbitrarily high value
  def param_max(param_id)
    9999999999
  end
  
  alias :th_enemy_param_formulas_xparam :xparam
  def xparam(xparam_id)
    val = th_enemy_param_formulas_xparam(xparam_id)
    if enemy.xparam_formula(xparam_id) && !@param_recurse_check
      @param_recurse_check = true
      val = enemy.eval_xparam_formula(xparam_id, val, self)
      @param_recurse_check = false
    end
    return val
  end
  
  alias :th_enemy_param_formulas_sparam :sparam
  def sparam(sparam_id)
    val = th_enemy_param_formulas_sparam(sparam_id)
    if enemy.sparam_formula(sparam_id) && !@param_recurse_check
      @param_recurse_check = true
      val =  enemy.eval_sparam_formula(sparam_id, val, self)
      @param_recurse_check = false
    end
    return val
  end
  
  alias :th_enemy_param_formulas_param_base :param_base
  def param_base(param_id)
    val = th_enemy_param_formulas_param_base(param_id)
    if enemy.param_formula(param_id) && !@param_recurse_check
      @param_recurse_check = true
      val = enemy.param_base_formula(param_id, val, self)
      @param_recurse_check = false
    end
    return val
  end
end