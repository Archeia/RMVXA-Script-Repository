#==============================================================================
# Simple Magic Weapons Script
#------------------------------------------------------------------------------
# Author: Kread-EX
#==============================================================================

#The constant below is the only thing you need to configure.

#The first number is the ID of the weapon. The second, the ID of the skill.
#The third is the probability (should be 0-100).

MAGIC_WEAPONS = {1 => [59, 75], 2 => [60, 50]}
#In this example, the first weapon in the database has 75% chance of casting Fire, and the second 50% of casting Fire 2.

# If GTBS not detected
unless defined?(Scene_Battle_TBS)

#==============================================================================
# Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # Changes to execute_action
  #--------------------------------------------------------------------------
  alias_method :krx_mw_execute_action, :execute_action
  def execute_action
    if @active_battler.is_a?(Game_Actor) && MAGIC_WEAPONS.keys.include?(@active_battler.weapon_id) &&
     @active_battler.action.attack? && (rand(101) >= (100 - MAGIC_WEAPONS[@active_battler.weapon_id][1]))
     @active_battler.action.set_skill(MAGIC_WEAPONS[@active_battler.weapon_id][0])
   end
   krx_mw_execute_action
  end
end

# Support for GTBS
else
  
#==============================================================================
# Scene_Battle_TBS
#==============================================================================

class Scene_Battle_TBS < Scene_Base
  #----------------------------------------------------------------------------
  # Determine if Magic Weapon is active
  #----------------------------------------------------------------------------
  #----------------------------------------------------------------------------
  # Process Actions (Attack/Skill/Item)
  #----------------------------------------------------------------------------
  alias_method :krx_mw_gtbs_phase_9, :tbs_phase_9
  def tbs_phase_9
    if @active_battler.is_a?(Game_Actor) && MAGIC_WEAPONS.keys.include?(@active_battler.weapon_id) &&
      (rand(101) >= (100 - MAGIC_WEAPONS[@active_battler.weapon_id][1])) &&
      @active_battler.current_action.kind == 0 && @active_battler.current_action.basic == 0
      @active_battler.current_action.kind = 1
      @active_battler.current_action.skill_id = MAGIC_WEAPONS[@active_battler.weapon_id][0]
      @animation2 = $data_skills[@active_battler.current_action.skill_id].animation_id
    end
    krx_mw_gtbs_phase_9
  end
end

end