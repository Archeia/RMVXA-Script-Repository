=begin
#===============================================================================
 Title: Troop Battle BGM
 Author: Hime
 Date: Jul 10, 2015
--------------------------------------------------------------------------------
 ** Change log
 Jul 10, 2015
   - Added support for changing Battle End Victory ME as well
 Dec 14, 2013
   - Added support for using a "Change Battle BGM" command
 Mar 5, 2013
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
 
 This script allows you to assign a BGM and/or Victory ME to a troop.
 The BGM/ME will be played whenever that troop is encountered instead of the
 default one.
 
--------------------------------------------------------------------------------
 ** Usage
 
   -- Battle BGM --
 
 For BGM, add a comment on the *first* page of the troop, with the string
 
   <battle bgm>
   
 Followed by a "change battle BGM" or a "Play BGM" command.
 For existing users, the script still supports the comment
 
   <battle bgm: filename>
 
 Where the `filename` is a file in the Audio/BGM folder.
 
   -- Victory ME --
 
 For Victory ME, use the note-tag
 
   <battle end me>
   
 Followed by a "change battle ME" or a "Play ME" command.
 You can also specify the filename directly using the note-tag
 
   <battle end me: filename>
   
 Where the `filename` is a file in the Audio/ME folder.   
   
   
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_TroopBattleBGM"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Troop_Battle_BGM
    Regex = /<battle[-_ ]bgm(?::\s*(\w+))?>/i
    ME_Regex = /<battle[-_ ]end[-_ ]me(?::\s*(\w+))?>/i
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  class Troop
    
    def battle_bgm
      return @battle_bgm unless @battle_bgm.nil?
      parse_battle_bgm
      return @battle_bgm
    end
    
    def battle_end_me
      parse_battle_bgm if @battle_end_me.nil?      
      return @battle_end_me
    end
    
    def parse_battle_bgm
      list = self.pages[0].list
      list.size.times do |i|
        cmd = list[i]
        if cmd.code == 108
          if cmd.parameters[0] =~ TH::Troop_Battle_BGM::Regex
            # If name is supplied, used that
            if $1
              @battle_bgm = RPG::BGM.new($1)
              next
            # otherwise, check for "change battle BGM" command
            else
              next_cmd = list[i+1]
              if next_cmd.code == 132 || next_cmd.code == 241
                @battle_bgm = next_cmd.parameters[0]
                next
              end
            end
            
          # Maybe it's victory ME?
          elsif cmd.parameters[0] =~ TH::Troop_Battle_BGM::ME_Regex
            if $1
              @battle_end_me = RPG::BGM.new($1)
              next
            # otherwise, check for "change battle BGM" command
            else
              next_cmd = list[i+1]
              if next_cmd.code == 133 || next_cmd.code == 249
                @battle_end_me = next_cmd.parameters[0]
                next
              end
            end
          end
        end
      end
    end
  end
end

module BattleManager
  class << self
    alias :th_troop_battle_bgm_play_battle_bgm :play_battle_bgm
    alias :th_troop_battle_bgm_play_battle_end_me :play_battle_end_me
  end
  
  def self.play_battle_bgm
    if $game_troop.battle_bgm
      $game_troop.battle_bgm.play
      RPG::BGS.stop
    else
      th_troop_battle_bgm_play_battle_bgm
    end
  end
  
  def self.play_battle_end_me
    if $game_troop.battle_end_me
      $game_troop.battle_end_me.play
    else
      th_troop_battle_bgm_play_battle_end_me
    end
  end
end

class Game_Troop < Game_Unit
  
  def battle_bgm
    troop.battle_bgm
  end
  
  def battle_end_me
    troop.battle_end_me
  end
end