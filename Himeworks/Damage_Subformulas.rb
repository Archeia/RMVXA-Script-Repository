=begin
#===============================================================================
 Title: Damage Subformulas
 Author: Hime
 Date: Apr 9, 2013
--------------------------------------------------------------------------------
 ** Change log
 Apr 9, 2014
   - updated to support formula for all types
 Apr 8, 2013
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
 
 This script allows you to specify custom damage formulas depending on who
 the attacker and target are. The default formula allows you to specify
 A and B, but it doesn't take into consideration whether they are actors
 or enemies.
 
 This script provides 4 sub-formulas that will be used depending on who is
 A and B. There are four cases
 
   A is actor, B is enemy
   A is actor, B is actor
   A is enemy, B is actor
   A is enemy, B is enemy
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 The general format of the note-tag to use is
 
 <damage formula: TYPE>
   FORMULA
 </damage formula>
 
 Where TYPE is one of
 
   AA - actor to actor
   AE - actor to enemy
   EA - enemy to actor
   EA - enemy to enemy
   
 And the FORMULA is a valid formula that returns a number.
 
 If a sub-formula is not specified, then it is assumed to be the main formula
 that is defined in the damage box built into the database editor.
 
 You can leave out the TYPE if you want to apply to all types like this:
 
 <damage formula>
   FORMULA
 </damage formula>
 
--------------------------------------------------------------------------------
 ** Compatibility
 
 This script overwrites the `eval` formula in UsableItem::Damage
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_DamageSubformulas"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Damage_Subformulas
    
    Regex = /<damage[-_ ]formula(?::\s*(AA|AE||EA|EE))?\s*>(.*?)<\/damage[-_ ]formula>/im
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  
  class UsableItem < BaseItem
    
    def load_notetag_damage_subformulas
      self.damage.load_notetag_damage_subformulas(self.note)
    end
  end
  
  class UsableItem::Damage
    
    #---------------------------------------------------------------------------
    # Return the appropriate formula depending on the battler objects
    #---------------------------------------------------------------------------
    def subformula(a, b)
      if a.actor? && b.enemy?
        ae_subformula
      elsif a.actor? && b.actor?
        aa_subformula
      elsif a.enemy? && b.actor?
        ea_subformula
      elsif a.enemy? && b.enemy?
        ee_subformula
      else
        self.formula
      end
    end
    
    def aa_subformula
      return @aa_subformula
    end
    
    def ae_subformula
      return @ae_subformula
    end
    
    def ea_subformula
      return @ea_subformula
    end
    
    def ee_subformula
      return @ee_subformula
    end

    def load_notetag_damage_subformulas(note)
      @aa_subformula = @ae_subformula = @ea_subformula = @ee_subformula = @formula
      res = note.scan(TH::Damage_Subformulas::Regex)
      res.each do |type, formula|
        if !type
          @aa_subformula = @ae_subformula = @ea_subformula = @ee_subformula = formula
        else          
          case type.upcase
          when "AA"
            @aa_subformula = formula
          when "AE"
            @ae_subformula = formula
          when "EA"
            @ea_subformula = formula
          when "EE"
            @ee_subformula = formula
          end
        end
      end
    end
    
    def eval(a, b, v)
      [Kernel.eval(self.subformula(a, b)), 0].max * sign
    end
  end
end

#-------------------------------------------------------------------------------
# RPG Damage objects don't have note-tags, nor do they have a reference to
# the object that holds them
#-------------------------------------------------------------------------------
module DataManager
  
  class << self
    alias :th_damage_subformulas_load_database :load_database
  end
  
  def self.load_database
    th_damage_subformulas_load_database
    load_notetags_damage_subformulas
  end
  
  def self.load_notetags_damage_subformulas
    ($data_items | $data_skills).each do |obj|
      next unless obj
      obj.load_notetag_damage_subformulas
    end
  end
end