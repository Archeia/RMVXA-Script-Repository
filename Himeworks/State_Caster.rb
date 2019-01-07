=begin
#===============================================================================
 Title: State Caster
 Author: Hime
 Date: Oct 10, 2013
--------------------------------------------------------------------------------
 ** Change log
 Oct 10, 2013
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
 
 This script allows battlers to store a state's caster, the battler that
 applied the state. If the state was applied through events or other means,
 then there is no caster.
 
 It is useful for scripts that need to know who applied a state.
 
--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 

 For scripters, you can check what caused a state using
 
   <Battler>.state_caster(state_id)
   
 which will return a Game_Battler object if a battler caused it, or nil.
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_StateCaster"] = true
#===============================================================================
# ** Rest of Script
#===============================================================================
class Game_Battler < Game_BattlerBase
  
  #-----------------------------------------------------------------------------
  # Returns the cause of the particular state ID
  #-----------------------------------------------------------------------------
  def state_caster(state_id)
    self.state_casters[state_id]
  end
  
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def state_casters
    @state_casters = {} unless @state_casters
    return @state_casters
  end
  
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  alias :th_state_caster_remove_state :remove_state
  def remove_state(state_id)
    th_state_caster_remove_state(state_id)
    @result.removed_states.each do |state_id|
      self.state_casters[state_id] = nil
    end
  end
  
  #-----------------------------------------------------------------------------
  # Assign the current user as the state applier
  #-----------------------------------------------------------------------------
  alias :th_state_caster_item_effect_add_state :item_effect_add_state
  def item_effect_add_state(user, item, effect)
    th_state_caster_item_effect_add_state(user, item, effect)
    
    # assign the user for each added state.
    @result.added_states.each do |state_id|
      self.state_casters[state_id] = user
    end
  end
end