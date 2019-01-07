=begin
#===============================================================================
 Title: State Rate Popups
 Author: Hime
 Date: Jun 15, 2013
--------------------------------------------------------------------------------
 ** Change log
 Jun 15, 2013
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
 
 Yanfly's Damage Popup script.
--------------------------------------------------------------------------------
 ** Description
 
 This script is an add-on for Yanfly's Damage Popup script, either the
 standalone version or built into Ace Battle Engine. It displays popups
 when you use a skill that inflicts a state, informing you whether the enemy
 is resistant or immune to a state.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Damage Popups and above Main.

--------------------------------------------------------------------------------
 ** Usage 
 
 Plug-and-play.
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_StateRatePopups"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module State_Animations
    
    Add_Regex = /<add animation: (\d+)>/i

  end
end
#===============================================================================
# ** Rest of Script
#=============================================================================== 
class Game_BattlerBase
  
  #-----------------------------------------------------------------------------
  # Create the state rate popup.
  #-----------------------------------------------------------------------------
  def make_state_rate_popup(state_id)
    rate = state_rate(state_id)
    
    # don't care about weakpoint since it doesn't really matter
    # Nor do we care about absorbing states that doesn't even make sense
    return if rate < 0 || rate >= 1.0
    state = $data_states[state_id]
    return if state.icon_index == 0
    flags = ["state", state.icon_index]
    if rate == 0
      text = YEA::BATTLE::POPUP_SETTINGS[:immune]
      rules = "ADDSTATE"
    else
      text = YEA::BATTLE::POPUP_SETTINGS[:resistant]
      rules = "ADDSTATE"
    end
    create_popup(text, rules, flags)
  end
end

class Game_Battler < Game_BattlerBase
  
  alias :th_state_rate_popup_item_effect_add_state_normal :item_effect_add_state_normal
  def item_effect_add_state_normal(user, item, effect)
    old_states = @states.clone
    th_state_rate_popup_item_effect_add_state_normal(user, item, effect)
    new_states = @states - old_states
    make_state_rate_popup(effect.data_id) unless dead? || new_states.include?(effect.data_id)
  end
end