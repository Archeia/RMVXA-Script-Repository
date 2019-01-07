=begin
#===============================================================================
 Title: Shared EXP
 Author: Hime
 Date: May 17, 2013
--------------------------------------------------------------------------------
 ** Change log
 May 17, 2013
   - removed unnecessary type casting
 May 13, 2013
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
 
 This script changes exp gain after battle to distribute the total exp
 based on the number of alive battle members in the party.
 
 One actor in the battle will receive all of the exp, whereas if there are 
 four actors in the battle they will each receive a quarter.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage

 Plug and play
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_SharedExp"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Shared_Exp
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
class Game_Troop < Game_Unit
  
  alias :th_shared_exp_exp_total :exp_total
  def exp_total
    total = th_shared_exp_exp_total
    return apply_exp_modifiers(total)
  end
  
  def apply_exp_modifiers(total)
    return total / $game_party.alive_members.size
  end
end