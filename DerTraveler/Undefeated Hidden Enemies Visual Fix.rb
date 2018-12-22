#==============================================================================
# 
# "Undefeated Hidden Enemies Visual Fix"
# Version 1.1
# Last Update: September 2nd, 2013
# Author: DerTraveler (dertraveler [at] gmail.com)
#
#==============================================================================
#
# Description:
#
# Fixes a small visual bug concerning hidden enemies that haven't appeared.
# Without the fix these enemies would appear for a very short moment before the
# battle ends, when the party flees from combat.
#
#==============================================================================
#
# How to use:
# 
# Just paste it anywhere in the Materials section.
#
#==============================================================================
#
# Changelog:
#   1.1:
#     - Change the implementation of Game_Enemy only instead of Game_Battler
#       and SceneManager, which were unneccessarily central changes.
#       Thanks to Mihel & Tsukihime for pointing out that the bug only occurs
#       when fleeing from battle and for hints regarding the cause of the
#       problem.
#
# Compatibility:
#
# Overwrites  - Game_Enemy: on_battle_end
#
#==============================================================================
#
# Terms of use:
#
# - Free to use in any commercial or non-commercial project.
# - Please mail me if you find bugs so I can fix them.
# - If you have feature requests, please also mail me, but I can't guarantee
#   that I will add every requested feature.
# - You don't need to credit me, if you don't want to for some reason, since
#   it's only a bugfix of a standard RPG Maker behaviour.
#
#==============================================================================

class Game_Enemy < Game_Battler
  
  # Identically to the implementation in Game_BattlerBase except of the removed
  # call to 'appear' in the end, which is unneccessary since the data of
  # defeated enemies aren't reused anywhere else.
  def on_battle_end
    @result.clear
    remove_battle_states
    remove_all_buffs
    clear_actions
    clear_tp unless preserve_tp?
  end
  
end 