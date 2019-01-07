=begin
#===============================================================================
 Title: NeonBlack Passive Conditional States patch
 Author: Hime
 Date: May 9, 2015
--------------------------------------------------------------------------------
 ** Change log
 May 9, 2015
   - fixed crashing bug due to recursive evaluation
 Sep 25, 2014
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
 
 This script allows you to use conditional states with neon black's
 passive states script.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below NeonBlack's passive states script, Conditional States,
 and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 Plug and play
  
#===============================================================================
=end
class Game_Actor < Game_Battler
  def passives
    res = []
    @passover = true
    skills.each do |skill|
      next if skill.passives.empty?
      res += skill.passives
    end    
    states = res.collect {|ps| get_passive_conditional_state(ps)}
    @passover = false
    return states
  end
  
  def get_passive_conditional_state(state_id)
    state = $data_states[state_id]
    return state unless state.conditional_state?
    return $data_states[state.eval_conditional_state(self)]
  end
end