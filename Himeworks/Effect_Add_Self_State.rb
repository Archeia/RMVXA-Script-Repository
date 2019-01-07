=begin
#===============================================================================
 Title: Effect: Add Self State
 Author: Hime
 Date: Apr 20, 2013
--------------------------------------------------------------------------------
 ** Change log
 Apr 20, 2013
   - initial release
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
 
 This effect adds a state to the user of a skill/item

--------------------------------------------------------------------------------
 ** Required
 
 Effects Manager
 (http://himeworks.com/2012/10/05/effects-manager/)
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Effect Manager and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 Tag items or skills with
 
   <eff: add_self_state stateID probability>
   
 Where `stateID` is the ID of the state to apply
 `probability` is the chance that it will be added, as a float
 
 For example, 
   0 is 0%
   0.5 is 50%
   1 is 100%
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_AddSelfState"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Add_Self_State
#===============================================================================
# ** Rest of Script
#===============================================================================
    Effect_Manager.register_effect(:add_self_state, 2.6)
  end
end

module RPG
  class UsableItem < BaseItem
    def add_effect_add_self_state(code, data_id, args)
      data_id = args[0].to_i
      value = args[1].to_f
      add_effect(code, data_id, value)
    end 
  end
end

class Game_Battler < Game_BattlerBase
  
  def item_effect_add_self_state(user, item, effect)
    state_id = effect.data_id
    prob = effect.value1
    
    if rand < prob
      user.add_state(state_id)
    end
  end
end