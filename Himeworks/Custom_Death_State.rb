=begin
#===============================================================================
 Title: Custom Death State
 Author: Hime
 Date: May 3, 2013
--------------------------------------------------------------------------------
 ** Change log
 May 3, 2013
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
 
 This script allows you to set a custom state as the battler's death state.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage

 Note-tag actors or enemies with

   <death state: x>
   
 For some state ID x
 The specified state will be treated as the battler's death state. When the
 state is added, the battler will die.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_CustomDeathState"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Custom_Death_State
    
    Regex = /<death[-_ ]state:\s*(\d+)>/i
    
    def death_state_id
      return @death_state_id unless @death_state_id.nil?
      load_notetag_custom_death_state
      return @death_state_id
    end
    
    def load_notetag_custom_death_state
      @death_state_id = self.note =~ Regex ? $1.to_i : 1
    end
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  class Actor < BaseItem
    include TH::Custom_Death_State
  end
  
  class Enemy < BaseItem
    include TH::Custom_Death_State
  end
end

class Game_Actor < Game_Battler
  
  #-----------------------------------------------------------------------------
  # Overwrite. Return actor's death state ID
  #-----------------------------------------------------------------------------
  def death_state_id
    actor.death_state_id
  end
end

class Game_Enemy < Game_Battler
  
  #-----------------------------------------------------------------------------
  # Overwrite. Return enemy's death state ID
  #-----------------------------------------------------------------------------
  def death_state_id
    enemy.death_state_id
  end
end