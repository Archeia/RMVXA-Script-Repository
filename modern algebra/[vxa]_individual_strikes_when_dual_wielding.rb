#==============================================================================
#    Individual Strikes when Dual Wielding
#    Version: 1.0.1
#    Author: modern algebra (rmrk.net)
#    Date: 2 February 2013
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    
#    This script changes the dual wielding option so that, instead of the actor
#   attacking only once with increased damage, the actor attacks twice, once 
#   with each weapon. Additionally, this script allows you to modify the
#   damage formula when dual wielding, thus allowing you to, for instance, make
#   the actor's proficiency with dual wielding dependent on the actor's
#   dexterity or some other stat.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials.
#
#    If you wish, you can assign a modifying formula at line 38. What that will
#   do is allow you to change the damage formula for a weapon when you are dual
#   wielding, and it serves as a way to assign a penalty to dual wielding for
#   balance purposes.
#==============================================================================

$imported ||= {}
$imported[:MA_DWIndividualStrikes] = true

#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#  BEGIN Editable Region
#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#  By modifying this constant, you are able to modify the damage formula when
# dual wielding. It must be a string, and the original damage formula will 
# replace the %s. In other words, if the original damage formula is something
# like "a.atk * 4 - b.def * 2", and you assign the constant to the following:
#    MAISDW_DUAL_DAMAGE_MODIFIER = "(%s)*0.75"
# then the formula when dual wielding would be: "(a.atk * 4 - b.def * 2)*0.75"
MAISDW_DUAL_DAMAGE_MODIFIER = "(%s)"
#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#  END Editable Region
#//////////////////////////////////////////////////////////////////////////////

#==============================================================================
# ** Scene_Battle
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - apply_item_effects
#==============================================================================

class Scene_Battle
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Apply Skill/Item Effect
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maisdw_aplyitm_2uv7 apply_item_effects
  def apply_item_effects(target, item, *args)
    # If Actor attacking with more than one weapon
    if @subject.actor? && !item.is_a?(RPG::Item) && 
      item.id == @subject.attack_skill_id && @subject.weapons.size > 1
      @subject.weapons.each { |weapon|
        maisdw_dual_wield_attack(target, item, weapon, *args) }
    else
      maisdw_aplyitm_2uv7(target, item, *args) # Call original method
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Dual Wield Attack
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maisdw_dual_wield_attack(target, item, weapon, *args)
    #  Select from equips to record position, accounting for extra equip 
    # scripts that might change order.
    equips_to_replace = [] # Record which equips are removed
    selected = false
    for i in 0...@subject.equips.size
      equip = @subject.equips[i]
      if equip.is_a?(RPG::Weapon)
        # Actual identity in case using an instantiated item system
        if weapon.equal?(equip) && !selected
          selected = true # Only keep it once if two of the same item
          next
        end
        equips_to_replace << [i, equip] # Preserve weapon
        @subject.change_equip(i, nil)   # Remove weapon
      end
    end
    # Get the attack skill
    attack_skill = $data_skills[@subject.attack_skill_id]
    attack_skill = item if attack_skill.nil?
    real_formula = attack_skill.damage.formula.dup # Preserve Formula
    # Modify damage formula
    unless MAISDW_DUAL_DAMAGE_MODIFIER.empty?
      attack_skill.damage.formula = sprintf(MAISDW_DUAL_DAMAGE_MODIFIER, real_formula)
    end
    # Call original apply_item_effects method
    maisdw_aplyitm_2uv7(target, attack_skill, *args)
    attack_skill.damage.formula = real_formula # Restore damage formula
    # Replace removed equips
    equips_to_replace.each { |i, weapon| @subject.change_equip(i, weapon) }
  end
end