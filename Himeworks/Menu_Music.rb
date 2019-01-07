=begin
#===============================================================================
 Title: Menu Music
 Author: Hime
 Date: Jul 3, 2015
--------------------------------------------------------------------------------
 ** Change log
 Jul 3, 2015
   - updated to use a list of BGM and BGS
 Sep 6, 2013
   - Bug fix: menu music was saved with the save file as the last bgm
 Aug 19, 2013
   - Bug Fix: Music stops when calling common event effect from menu
 May 10, 2013
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
 
 This script allows you to assign a BGM and BGS to play in the menu. They will
 be played until you return to the map, where the map music will then replay.
 
 You can compile a list of music that will be played and control which one
 to use during the game using variables.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage

 In the configuration below, start by choosing a BGM variable, which is the
 ID of the variable that will hold the BGM to play. Then choose a BGS
 variable. You can set it to 0 if it is not needed.
 
 Next, set up the list of BGM and BGS to be played. Each file has a number
 assigned to it: this is the number that you will set the variables to in order
 to play the appropriate music.
 
 The "Disable Switch" is used to prevent the menu music from auto-playing when
 the switch is on, in case you want the map BGM to continue while in the menu.
 You can assign it to any switch.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_MenuMusic"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Menu_Music
    
    # This variable holds which music will be played.
    BGM_Variable = 1
    BGS_Variable = 2
    
    # List of background music that are available. 
    BGM_List = {
      1 => "theme1",
      2 => "theme2",
      3 => "theme3",
    }
    
    # List of background sounds that are available. 
    BGS_List = {
      1 => "Rain",
      2 => "Rain",
    }
    
    # Turn this switch ON to disable menu music
    Disable_Switch = 327
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
class Game_Temp
  
  attr_accessor :map_bgm
  attr_accessor :map_bgs
  
  alias :th_menu_music_initialize :initialize
  def initialize
    th_menu_music_initialize
    @map_bgm = RPG::BGM.new
    @map_bgs = RPG::BGS.new
    @menu_bgm_name = ""
    @menu_bgs_name = ""
    @menu_bgm = nil
    @menu_bgs = nil
  end
  
  def replay_map_music
    @map_bgm.replay
    @map_bgs.replay
  end
  
  def play_menu_bgm
    return if TH::Menu_Music::BGM_Variable == 0
    name = TH::Menu_Music::BGM_List[$game_variables[TH::Menu_Music::BGM_Variable]]
    if name && @menu_bgm_name != name
      @menu_bgm_name = name
      @menu_bgm = RPG::BGM.new(name)
    end
    @menu_bgm.play if @menu_bgm
  end
  
  def play_menu_bgs
    return if TH::Menu_Music::BGS_Variable == 0
    name = TH::Menu_Music::BGS_List[$game_variables[TH::Menu_Music::BGS_Variable]]
    if name && @menu_bgs_name != name
      @menu_bgs_name = name
      @menu_bgs = RPG::BGS.new(name)
    end
    @menu_bgs.play if @menu_bgs
  end
end

class Game_System
  
  attr_accessor :menu_music_disabled
  
  def menu_music_disabled=(val)
    $game_switches[TH::Menu_Music::Disable_Switch] = val
  end
  
  def menu_music_disabled
    $game_switches[TH::Menu_Music::Disable_Switch]
  end
  
  alias :th_menu_music_on_before_save :on_before_save
  def on_before_save
    th_menu_music_on_before_save
    @bgm_on_save = $game_temp.map_bgm
    @bgs_on_save = $game_temp.map_bgs
  end
end

class Scene_Map < Scene_Base
  
  alias :th_menu_music_call_menu :call_menu
  def call_menu
    $game_temp.map_bgm = RPG::BGM.last
    $game_temp.map_bgs = RPG::BGS.last
    th_menu_music_call_menu
  end
end

class Scene_Menu < Scene_MenuBase
  
  alias :th_menu_music_start :start
  def start
    th_menu_music_start
    play_menu_bgm unless $game_system.menu_music_disabled
  end
  
  def play_menu_bgm
    $game_temp.play_menu_bgm
    $game_temp.play_menu_bgs
  end
  
  alias :th_menu_music_pre_terminate :pre_terminate
  def pre_terminate
    th_menu_music_pre_terminate
    $game_temp.replay_map_music if SceneManager.scene_is?(Scene_Map)
  end
end

class Scene_ItemBase < Scene_MenuBase
  alias :th_menu_music_check_common_event :check_common_event
  def check_common_event
    th_menu_music_check_common_event
    $game_temp.replay_map_music if SceneManager.scene_is?(Scene_Map)
  end
end