=begin
#===============================================================================
 Title: Post-Battle Events
 Author: Hime
 Date: Nov 18, 2015
--------------------------------------------------------------------------------
 ** Change log 
 Nov 18, 2015
   - fixed bug where post battle victory event only ran once
 Aug 10, 2013
   - Re-structured script to make compatibility easier to handle
 May 12, 2013
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
 
 This script allows you to set up troop event pages as "post battle" events.
 These events will run after the battle is over, but before the game leaves
 the battle scene. It allows you to run extra events that should occur after
 the victory/defeat message.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage

 To set a post-battle event page, add one of the following comments
 
   <post battle victory> - runs after victory
   <post battle defeat> - runs after defeat
   
 The page will automatically be run when the condition is met.
 
--------------------------------------------------------------------------------
 ** Compatibility
 
 This script defines custom victory and defeat processing methods in
 BattleManager.   
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_PostBattleEvents"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Post_Battle_Events
    
    Victory_Regex = /<post battle victory>/i
    Defeat_Regex = /<post battle defeat>/i
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  
  class Troop
    def post_battle_victory_event
      return @post_battle_events[:victory] unless @post_battle_events.nil?
      parse_post_battle_event
      return @post_battle_events[:victory]
    end
  
    def post_battle_defeat_event
      return @post_battle_events[:defeat] unless @post_battle_events.nil?
      parse_post_battle_event
      return @post_battle_events[:defeat]
    end
    
    def parse_post_battle_event
      @post_battle_events = {}
      
      to_delete = []
      @pages.each do |page|
        if page.parse_post_battle_event(@post_battle_events)
          to_delete << page
        end
      end
      
      to_delete.each do |page|
        @pages -= to_delete
      end
    end
  end
  
  class Troop::Page
    def parse_post_battle_event(post_events)
      @list.each do |cmd|
        if cmd.code == 108
          if cmd.parameters[0] =~ TH::Post_Battle_Events::Victory_Regex
            post_events[:victory] = self
            return true
          elsif cmd.parameters[0] =~ TH::Post_Battle_Events::Defeat_Regex
            post_events[:defeat] = self
            return true
          end
        end
      end
      return false
    end
  end
end

module BattleManager

  #-----------------------------------------------------------------------------
  # Overwrite.
  #-----------------------------------------------------------------------------
  def self.process_victory
    play_battle_end_me
    replay_bgm_and_bgs
    $game_message.add(sprintf(Vocab::Victory, $game_party.name))
    display_exp
    gain_gold
    gain_drop_items
    gain_exp
    process_post_victory_event #-- you can customize this
    SceneManager.return
    battle_end(0)
    return true
  end

  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  def self.process_defeat
    $game_message.add(sprintf(Vocab::Defeat, $game_party.name))
    wait_for_message
    process_post_defeat_event #-- you can customize this
    if @can_lose
      revive_battle_members
      replay_bgm_and_bgs
      SceneManager.return
    else
      SceneManager.goto(Scene_Gameover)
    end
    battle_end(2)
    return true
  end
  
  def self.process_post_victory_event
    SceneManager.scene.process_post_victory_event if $game_troop.post_battle_victory_event
  end
  
  def self.process_post_defeat_event
    SceneManager.scene.process_post_defeat_event if $game_troop.post_battle_defeat_event
  end
end

#-------------------------------------------------------------------------------
# Post battle process events defined in the troop objects
#-------------------------------------------------------------------------------
class Game_Troop < Game_Unit
  
  def post_battle_victory_event
    troop.post_battle_victory_event
  end
  
  def post_battle_defeat_event
    troop.post_battle_defeat_event
  end
  
  def setup_victory_event
    return unless post_battle_victory_event
    @interpreter.setup(post_battle_victory_event.list)
  end
  
  def setup_defeat_event
    return unless post_battle_defeat_event
    @interpreter.setup(post_battle_defeat_event.list)
  end
end

#-------------------------------------------------------------------------------
# Perform post-process battle event processing
#-------------------------------------------------------------------------------
class Scene_Battle < Scene_Base
  
  def process_post_victory_event
    $game_troop.setup_victory_event
    while !scene_changing?
      $game_troop.interpreter.update
      wait_for_message
      wait_for_effect if $game_troop.all_dead?
      process_forced_action
      break unless $game_troop.interpreter.running?
      update_for_wait
    end
  end
  
  def process_post_defeat_event
    $game_troop.setup_defeat_event
    while !scene_changing?
      $game_troop.interpreter.update
      wait_for_message
      wait_for_effect if $game_party.all_dead?
      process_forced_action
      break unless $game_troop.interpreter.running?
      update_for_wait
    end
  end
end