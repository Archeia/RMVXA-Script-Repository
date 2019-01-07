=begin
#===============================================================================
 Title: Enemy Re-position
 Author: Hime
 Date: Feb 15, 2014
--------------------------------------------------------------------------------
 ** Change log
 Feb 15, 2014
   - Checks whether enemy exists before trying to re-position
 Apr 6, 2013
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
 
 This script allows you to move your enemy's sprites around in battle using
 script calls.
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage

 Make a script call during battle

   position_enemy(enemy_index, x, y)
   move_enemy(enemy_index, x, y)
   
 The enemy_index is the index of the enemy, where 1 is the first enemy,
 2 is the second enemy, and so on.
 
 x, y is the position they will be moved to.
 
 The first call is an absolute position relative to the top-left corner of
 the screen.
 
 The second call is relative to the sprite's current position. So if you say
 x = 100, then it will shift it to the right 100 pixels.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_Enemy_Reposition"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Enemy_Reposition
    
    # how fast the sprite moves around the screen
    Move_Speed = 12
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
class Game_Interpreter
  
  #-----------------------------------------------------------------------------
  # Specify absolute position where the enemy should be placed
  #-----------------------------------------------------------------------------
  def position_enemy(index, x, y)
    enemy = $game_troop.members[index-1]
    return unless enemy
    enemy.set_new_position(x, y)
    
  end
  
  #-----------------------------------------------------------------------------
  # Specify relative position where the enemy should be placed.
  #-----------------------------------------------------------------------------
  def move_enemy(index, x, y)
    enemy = $game_troop.members[index-1]
    return unless enemy
    enemy.set_new_position(enemy.screen_x + x, enemy.screen_y + y)
  end
end

class Game_Enemy < Game_Battler
  
  attr_accessor :new_screen_x
  attr_accessor :new_screen_y
  attr_accessor :position_changing
  
  def position_changing?
    @position_changing
  end
  
  def set_new_position(x, y)
    @new_screen_x = x
    @new_screen_y = y
    @position_changing = true
  end
end

class Game_Troop < Game_Unit
  
  alias :th_enemy_reposition_setup :setup
  def setup(troop_id)
    th_enemy_reposition_setup(troop_id)
    setup_initial_positions
  end
  
  def setup_initial_positions
    @enemies.each do |enemy|
      enemy.new_screen_x = enemy.screen_x
      enemy.new_screen_y = enemy.screen_y
    end
  end
end

class Sprite_Battler < Sprite_Base
  
  alias :th_enemy_reposition_update :update
  def update
    th_enemy_reposition_update
    if @battler && @battler.enemy?
      update_move_position if @battler.position_changing?
    end
  end
  
  #-----------------------------------------------------------------------------
  # How fast the sprite's position is changed in pixels
  #-----------------------------------------------------------------------------
  def update_move_speed
    TH::Enemy_Reposition::Move_Speed
  end
  
  #-----------------------------------------------------------------------------
  # Move the sprite towards its new position
  #-----------------------------------------------------------------------------
  def update_move_position
    if @battler.screen_x != @battler.new_screen_x
      if @battler.screen_x < @battler.new_screen_x
        self.x = [@battler.screen_x + update_move_speed, @battler.new_screen_x].min
      else
        self.x = [@battler.screen_x - update_move_speed, @battler.new_screen_x].max
      end
      @battler.screen_x = self.x
    end
    
    if @battler.screen_y != @battler.new_screen_y
      if @battler.screen_x < @battler.new_screen_x
        self.y = [@battler.screen_y + update_move_speed, @battler.new_screen_y].min
      else
        self.y = [@battler.screen_y - update_move_speed, @battler.new_screen_y].max
      end
      @battler.screen_y = self.y
    end
    
    if @battler.screen_x == @battler.new_screen_x && @battler.screen_y == @battler.new_screen_y
      @battler.position_changing = false
    end
    self.z = @battler.screen_z
  end
end