=begin
#===============================================================================
 Title: Action Targets
 Author: Hime
 Date: Aug 9, 2013
--------------------------------------------------------------------------------
 ** Change log
 Aug 9, 2013
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
 
 This script stores the targets of an action with the action itself so that
 you can access the action's targets if needed.

--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 Plug and play.
 
 An example use of the targets is if you wanted to write damage formulas based
 on the number of targets. You would access the targets from the user's
 current action as such:
 
   a.current_action.targets
   
 This returns an array of Game_Battler objects.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_ActionTargets"] = true
#===============================================================================
# ** Rest of Script
#===============================================================================
class Game_Action
  
  attr_reader :targets
  
  alias :th_action_targets_clear :clear
  def clear
    th_action_targets_clear
    @targets = []
  end
  
  alias :th_action_targets_make_targets :make_targets
  def make_targets
    @targets = th_action_targets_make_targets
  end
end