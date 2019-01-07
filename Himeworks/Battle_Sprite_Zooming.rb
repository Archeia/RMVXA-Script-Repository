=begin
#===============================================================================
 Title: Battle Sprite Zooming
 Author: Hime
 Date: Nov 11, 2013
 URL: http://himeworks.com/2013/11/11/battle-sprite-zooming/
--------------------------------------------------------------------------------
 ** Change log
 Nov 11, 2013
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
 
 This script allows you to control the zoom-level for each battle sprite in
 battle. You can increase or decrease the size of sprites, allowing you to
 provide a more realistic feel to your battles.

--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage
 
 In your troop events, make the script call
 
   zoom_enemy_sprite(enemy_index, zoom_percent)
   zoom_enemy_sprite(enemy_index, zoom_x, zoom_y)
   
 You can look up the index by selecting one of the "enemy battle" event
 commands such as "Change Enemy HP", showing the dropdown list, and looking at
 the index before the enemy name.
 
 The `zoom_percent` is how much that you want to increase or decrease the
 sprite's size by. 1 is original size, 0.5 is half the size, 2 is double size.
 You are free to choose any other number in between.
 
 If you choose to specify both the zoom_x and zoom_y separately, they are used
 to stretch the sprite horizontally or vertically if that is what you want.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_BattleSpriteZoom"] = true
#===============================================================================
# ** Rest of script
#===============================================================================
class Sprite_Battler < Sprite_Base
  
  alias :th_battle_sprite_zoom_update :update
  def update
    th_battle_sprite_zoom_update
    update_zoom if @battler && @battler.use_sprite?
  end
  
  #-----------------------------------------------------------------------------
  # Update the zoom based on the battler's zoom settings
  #-----------------------------------------------------------------------------
  def update_zoom
    self.zoom_x = @battler.zoom_x
    self.zoom_y = @battler.zoom_y
  end
end

class Game_BattlerBase
  attr_accessor :zoom_x
  attr_accessor :zoom_y
  
  alias :th_battle_sprite_zoom_initialize :initialize
  def initialize
    th_battle_sprite_zoom_initialize
    @zoom_x = 1.0
    @zoom_y = 1.0
  end
end


class Game_Troop < Game_Unit

  #-----------------------------------------------------------------------------
  # hack-ish solution to running turn-zero troop events
  #-----------------------------------------------------------------------------
  alias :th_battle_sprite_zoom_setup :setup
  def setup(troop_id)
    th_battle_sprite_zoom_setup(troop_id)
    setup_battle_event
    @interpreter.update
  end
end

class Game_Interpreter
  
  def zoom_enemy_sprite(enemy_index, zoom_x=1.0, zoom_y=nil)
    enemy = $game_troop.members[enemy_index-1]
    zoom_y ||= zoom_x
    enemy.zoom_x = zoom_x
    enemy.zoom_y = zoom_y
  end
end