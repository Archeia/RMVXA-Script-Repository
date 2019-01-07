=begin
#===============================================================================
 Title: Disable Victory Music
 Author: Hime
 Date: Jul 1, 2013
--------------------------------------------------------------------------------
 ** Change log
 Jul 1, 2013
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
 
 This script allows you to disable the battle end victory or defeat music
 by turning on a switch. The music won't play if the switch is ON.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage

 Set the disable switch in the configuration and then control it in your
 project.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_DisableVictoryMusic"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Disable_Victory_Music
  
    Disable_Switch = 1
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
class Game_System
  
  def disable_victory_music
    $game_switches[TH::Disable_Victory_Music::Disable_Switch]
  end
end

module BattleManager
  
  class << self
    alias :th_disable_victory_music_play_battle_end_me :play_battle_end_me
    alias :th_disable_victory_music_replay_bgm_and_bgs :replay_bgm_and_bgs
    alias :th_disable_victory_music_battle_end :battle_end
  end
  
  def self.play_battle_end_me
    return if $game_system.disable_victory_music
    th_disable_victory_music_play_battle_end_me
  end
  
  def self.replay_bgm_and_bgs
    return if $game_system.disable_victory_music
    th_disable_victory_music_replay_bgm_and_bgs
  end
  
  def self.battle_end(result)
    th_disable_victory_music_replay_bgm_and_bgs if $game_system.disable_victory_music
    th_disable_victory_music_battle_end(result)
  end
end