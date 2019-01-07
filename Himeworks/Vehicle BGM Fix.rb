=begin
#===============================================================================
 Title: Vehicle BGM Fix
 Author: Hime
 Date: Sep 26, 2013
--------------------------------------------------------------------------------
 ** Change log
 Sep 26, 2013
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
 
 This script fixes vehicle BGM related bugs:
 
 - when you get on a vehicle, transfer maps, and get off, the BGM played is
   the BGM that was playing when you got on the vehicle
   
 - when you transfer maps on a vehicle, if the new map has autoplay BGM
   it will start playing instead
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 Plug and Play
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_VehicleBGMFix"] = true
#===============================================================================
# ** Rest of Script
#===============================================================================

#-------------------------------------------------------------------------------
# Don't autoplay map music after setting up
#-------------------------------------------------------------------------------
class Game_Map
  alias :th_vehicle_bgm_fix_autoplay :autoplay
  def autoplay
    return unless $game_player.is_walk?
    th_vehicle_bgm_fix_autoplay 
  end
  
  def play_music
    @map.bgm.play if @map.autoplay_bgm
    @map.bgs.play if @map.autoplay_bgs
  end
end

class Game_Player
  def is_walk?
    @vehicle_type == :walk
  end
end

#-------------------------------------------------------------------------------
# If different map has different music, play the new music
#-------------------------------------------------------------------------------
class Game_Vehicle < Game_Character
  
  alias :th_vehicle_bgm_fix_get_on :get_on
  def get_on
    th_vehicle_bgm_fix_get_on
    @walking_map_id = $game_map.map_id
  end
  
  alias :th_vehicle_bgm_fix_get_off :get_off
  def get_off
    th_vehicle_bgm_fix_get_off
    if $game_map.map_id != @walking_map_id
      RPG::BGM.stop
      $game_map.play_music
    end
  end
end