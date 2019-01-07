=begin
#===============================================================================
 Title: Enemy Reinforcement Events
 Author: Hime
 Date: Sep 12, 2014
 URL: http://himeworks.com/2014/01/12/enemy-events/
--------------------------------------------------------------------------------
 ** Change log
 Sep 12, 2014
   - Updated to new enemy reinforcements interface
 Feb 13, 2014
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
 
 This is an add-on to the Enemy Reinforcements script that will add enemy
 events when a new enemy is added, and remove enemy events when an enemy
 is removed.
 
--------------------------------------------------------------------------------
 ** Required
 
 Enemy Events
 (http://himeworks.com/2014/01/12/enemy-events/)
 
 Enemy Reinforcements
 (http://himeworks.com/2013/03/08/enemy-reinforcements/)
 
--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below both Enemy Events and Enemy
 Reinforcements, and above main.
 
--------------------------------------------------------------------------------
 ** Usage
 
 Plug and play
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_EnemyReinforcementEvents] = true
#===============================================================================
# ** Rest of Script
#===============================================================================

class Game_Troop < Game_Unit
  alias :th_enemy_events_add_member :add_member
  def add_member(member, troop_id)
    enemy = th_enemy_events_add_member(member, troop_id)
    add_enemy_event_pages(enemy)
  end
  
  alias :th_enemy_events_remove_enemy :remove_enemy
  def remove_enemy(enemy)
    th_enemy_events_remove_enemy(enemy)
    remove_enemy_event_pages(enemy)
  end
end