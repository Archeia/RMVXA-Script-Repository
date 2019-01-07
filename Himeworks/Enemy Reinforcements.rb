=begin
#===============================================================================
 Title: Enemy Reinforcements
 Author: Hime
 Date: Sep 23, 2016
--------------------------------------------------------------------------------
 ** Change log
 Aug 31, 2016
   - add_member should return the actual enemy added
 Sep 23, 2015
   - corrected order that sprites are inserted
 Jan 2, 2015
   - added support for checking if a troop is in the battle
 Feb 13, 2014
   - standardized all enemy removal using a "remove_enemy" method
 Jan 4, 2014
   - fixed bug with yanfly visual battler add-on
 Oct 14, 2013
   - improved new enemy drawing
 Jun 20, 2013
   - updated to support yanfly's visual battlers
 Mar 8, 2013
   - fixed bug where enemy battle window did display all of the enemies
     when new enemies were added
 Jul 8, 2012
   - added "remove troop" feature
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
 
 This script allows you to create "enemy reinforcements" by specifying
 which troop an enemy should be fetched from
 
 Enemy reinforcements are just new enemies that enter the battle.
 The enemies are selected from existing Troops from the troop editor and
 basically copies them over into the current battle.
 
 This means that the position and appearance of the sprite can be
 set in the editor.

--------------------------------------------------------------------------------
 ** Usage
 
 There are two ways to add new enemies
   -add one enemy
   -add an entire troop
 
 To add a new enemy to the battle, use the script call
 
    add_enemy(troop_id, index)
    
 where the troop_id is the ID of the troop that the enemy is in, and
 the index is the order that they were added in the editor.
 
 You may need to test it a few times to get the right index
 
 To add an entire troop, use the script call

    add_troop(troop_id)
    
 And the entire troop will be copied over.
 
 It is also possible to remove an entire troop from battle.
 All members of that troop will disappear when this script is called
 
    remove_troop(troop_id)
    
 You can check whether a certain troop is in the battle using the script call
 
   troop_exists?(troop_id)
   
 Which returns true if there exists an enemy with the specified troop ID and
 is alive.
 
--------------------------------------------------------------------------------
 Credits to Victor Sant for coming up with the idea of using troops
 to specify positions of sprites
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_EnemyReinforcements] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Enemy_Reinforcements
  end
end
#===============================================================================
# ** Rest of the script
#=============================================================================== 
class Spriteset_Battle
  
  #-----------------------------------------------------------------------------
  # New. Update the enemy sprites
  #-----------------------------------------------------------------------------
  def refresh_new_enemies
    battlers = @enemy_sprites.collect {|spr| spr.battler }
    new_battlers = $game_troop.members - battlers
    new_battlers.each do |enemy|
      @enemy_sprites.insert(0, Sprite_Battler.new(@viewport1, enemy))
    end
  end
end

class Game_Interpreter
  
  #-----------------------------------------------------------------------------
  # Adds the enemy from the specified troop ID, by index
  #-----------------------------------------------------------------------------
  def add_enemy(troop_id, index)
    $game_troop.add_enemy(troop_id, index)
  end
  
  #-----------------------------------------------------------------------------
  # Adds the selected troop to the battle
  #-----------------------------------------------------------------------------
  def add_troop(troop_id)
    $game_troop.add_troop(troop_id)
  end
  
  #-----------------------------------------------------------------------------
  # Removes the selected troop from battle. Enemies do not "die" they just
  # disappear
  #-----------------------------------------------------------------------------
  def remove_troop(troop_id)
    $game_troop.remove_troop(troop_id)
  end

  #-----------------------------------------------------------------------------
  # Returns true if there's an enemy in the troop with the specified troop
  # ID and is alive.
  #-----------------------------------------------------------------------------
  def troop_exists?(troop_id)
    $game_troop.alive_members.any? {|mem| mem.troop_id == troop_id }
  end
end

class Game_Enemy < Game_Battler
  
  attr_accessor :troop_id   #NEW: stores which troop the enemy is in
  
  # opposite of `appear
  def disappear
    @hidden = true
  end
end

class Game_Troop < Game_Unit
  
  alias :th_enemy_reinforcements_setup :setup
  def setup(troop_id)
    th_enemy_reinforcements_setup(troop_id)
    setup_troop_ids(troop_id)
  end
  
  def setup_troop_ids(troop_id)
    @enemies.each {|enemy| enemy.troop_id = troop_id}
  end
  
  def add_member(member, troop_id)
    enemy = Game_Enemy.new(@enemies[-1].index + 1, member.enemy_id)
    
    enemy.hide if member.hidden
    enemy.screen_x = member.x
    enemy.screen_y = member.y
    enemy.troop_id = troop_id
    @enemies.push(enemy)
    make_unique_names
    return enemy
  end
  
  def add_enemy(troop_id, index)
    member = $data_troops[troop_id].members[index - 1]
    return unless member
    add_member(member, troop_id)
    SceneManager.scene.refresh_enemies
  end
  
  def remove_enemy(enemy)
    enemy.hide
  end
  
  def add_troop(troop_id)
    $data_troops[troop_id].members.each { |member|
      next unless member
      add_member(member, troop_id)
    }
    SceneManager.scene.refresh_enemies
  end
  
  def remove_troop(troop_id)
    @enemies.each {|enemy|
      remove_enemy(enemy) if enemy.troop_id == troop_id
    }
  end
end

class Window_BattleEnemy < Window_Selectable
  
  # update to display all enemies, not just 8 of them
  def contents_height
    line_height * item_max
  end
  
  alias :th_enemy_reinforcements_refresh :refresh
  def refresh
    create_contents
    th_enemy_reinforcements_refresh
  end
end

class Scene_Battle < Scene_Base
  
  # refresh sprites on screen
  def refresh_enemies
    @spriteset.refresh_new_enemies
    @enemy_window.refresh
  end
end

#-------------------------------------------------------------------------------
# Compatibility with yanfly's visual battlers
#-------------------------------------------------------------------------------
if $imported["YEA-VisualBattlers"]
  class Game_Troop < Game_Unit
    alias :add_enemy_vb :add_enemy
    def add_enemy(troop_id, index)
      add_enemy_vb(troop_id, index)
      set_coordinates
    end
    
    alias :add_troop_vb :add_troop
    def add_troop(troop_id)
      add_troop_vb(troop_id)
      set_coordinates
    end
  end
end