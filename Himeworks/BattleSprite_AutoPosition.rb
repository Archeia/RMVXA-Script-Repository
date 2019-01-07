=begin
================================================================================
 Title: Battle Sprite Auto-position
 Author: Hime
 Date: Dec 19, 2014
--------------------------------------------------------------------------------
 ** Change log
 Dec 19, 2014
   - Use ratios to adjust the resolutions rather than offsetting by the
     difference between resolutions
 May 6, 2012
   -Initial release
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

 This script adjusts the position that the battle sprites are drawn
 relative to the game screen size. This allows you to set your enemy
 positions in the troop editor without having to consider the size of
 your window (544x416 default vs sizes)
 
-------------------------------------------------------------------------------- 
 ** Installation

 In the script editor, place this script below Materials and above Main 
 
-------------------------------------------------------------------------------- 
 ** Usage
 
 Plug-n-play
 
==============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_BattleSpriteAutoPosition] = true
#===============================================================================
# ** Rest of the Script
#=============================================================================== 
class Game_Troop < Game_Unit

  #--------------------------------------------------------------------------
  # alias method
  #--------------------------------------------------------------------------
  alias :th_sprite_autopos_setup :setup
  def setup(troop_id)
    th_sprite_autopos_setup(troop_id)
    adjust_coords
  end
  
  #--------------------------------------------------------------------------
  # new method: adjust enemy battler coords
  #--------------------------------------------------------------------------
  def adjust_coords
    adjust_x = Graphics.width / 544.0
    adjust_y = Graphics.height / 416.0
    @enemies.each do |enemy|
      enemy.screen_x *= adjust_x
      enemy.screen_y *= adjust_y
    end
  end
end