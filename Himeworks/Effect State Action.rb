=begin
#===============================================================================
 Title: Effect: State Action
 Author: Hime
 Date: Mar 13, 2013
--------------------------------------------------------------------------------
 ** Change log
 Mar 13, 2013
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
 ** Required
 
 Effect Manager
 (http://himeworks.com/2012/10/05/effects-manager)
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to force an action with your skill, depending
 on whether the enemy has a specific state applied or not.
 
--------------------------------------------------------------------------------
 ** Usage
 
 Tag skills/items with
 
   <eff: state_action `state_id` `skill_id` `apply_state?` >
   
 Where
   state_id is an integer, the ID of the state to check
   skill_id is an integer, the ID of the skill to use
   apply_state? is a boolean, whether it should apply the state or not
   
 If the state is not applied, then it will be added to the target if the
 apply_state? value is true.
 
 If the state is already added, then the specified skill will be used
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["Effect_StateAction"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module Effects
  module State_Action
    Effect_Manager.register_effect(:state_action, 2.6)
  end
end

class RPG::UsableItem
  def add_effect_state_action(code, data_id, args)
    apply_state = args[2] ? args[2].downcase == "true" : false
    add_effect(code, args[0].to_i, [args[1].to_i, apply_state])
  end
end

class Game_Battler < Game_BattlerBase
  
  def item_effect_state_action(user, item, effect)
    state_id = effect.data_id
    skill_id, apply_state = effect.value1
    if self.state?(state_id)
      user.effect_force_action(skill_id, self.index)
      remove_state(state_id)
    else
      add_state(state_id) if apply_state
    end
  end
  
  def effect_force_action(skill_id, target_index)
    action = Game_Action.new(self, true)
    action.set_skill(skill_id)
    if target_index == -2
      action.target_index = last_target_index
    elsif target_index == -1
      action.decide_random_target
    else
      action.target_index = target_index
    end
    @actions.push(action)
  end
end