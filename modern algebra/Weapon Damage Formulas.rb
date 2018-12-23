#==============================================================================
#    Weapon Damage Formulas
#    Version: 1.0.0
#    Author: modern algebra (rmrk.net)
#    Date: 22 September 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    
#    By default, every weapon invokes Skill 1 when it is used, which means that
#   every weapon has the same damage formula. This script makes it so that you
#   can customize what skill is invoked when a weapon is used, thus allowing 
#   you to control any aspect of that attack just as you could any skill. If 
#   you want a weapon that does MP damage, for instance, this script lets you 
#   make it. If you want a weapon with a different damage formula and different 
#   use message, then you can do that too.
#
#    Please note that if an actor is dual wielding, it will only run the damage
#   formula for the item in the primary hand. If you want to fix that, I 
#   suggest you retrieve my "Individual Strikes when Dual Wielding" script,
#   available at:    http://rmrk.net/index.php/topic,46811.0.html
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials.
#
#    To use this script, simply set up a skill in the database which is the
#   skill you want to run when the weapon is used. Then, you can assign that
#   skill to the weapon by placing the following code in the weapon's note
#   field:
#
#      \asid[x]
#
#   where x is the ID of the skill you set up.
#
#  EXAMPLES:
#
#    \asid[3]                    # This weapon calls skill 3 when it is used.
#    \asID[ 46 ]                 # This weapon calls skill 46 when it is used.
#    \ASID[127]                  # This weapon calls skill 127 when it is used.
#==============================================================================

$imported ||= {}
$imported[:MA_WeaponDamageFormulas] = true

#==============================================================================
# ** RPG::Weapon
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new method - mawdf_attack_skill_id
#==============================================================================

class RPG::Weapon
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Attack Skill ID
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_writer :mawdf_attack_skill_id
  def mawdf_attack_skill_id
    unless @mawdf_attack_skill_id
      @mawdf_attack_skill_id = note[/\\ASID?\[\s*(\d+)\s*\]/i] ? $1.to_i : -1
    end
    @mawdf_attack_skill_id
  end
end

#==============================================================================
# ** Game_Actor
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    redefined method - attack_skill_id
#==============================================================================

class Game_Actor
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Attack Skill ID
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  unless instance_methods(false).include?(:attack_skill_id)
    #  Define the method in the Game_Actor class if undefined. This will ensure
    # that any changes to this method in Game_BattlerBase are retained, even if
    # the script that does so is below this one.
    def attack_skill_id(*args, &block); super; end 
  end
  alias mawdf_atkskillid_4fa6 attack_skill_id
  def attack_skill_id(*args, &block)
    if !weapons.empty? && weapons[0].mawdf_attack_skill_id > 0
      weapons[0].mawdf_attack_skill_id
    else
      mawdf_atkskillid_4fa6(*args, &block) # Call Original Method
    end
  end
end