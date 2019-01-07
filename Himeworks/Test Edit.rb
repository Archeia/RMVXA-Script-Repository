=begin
#===============================================================================
 Title: Test Edit
 Author: Hime
 Date: Jan 11, 2014
--------------------------------------------------------------------------------
 ** Change log
 Jan 11, 2014
   - test mode enabled for the test edit instance
 Mar 9, 2013
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
 
 This script allows you to edit your game while testplaying the project.
 You can also reload data by pressing a button.
 
 Currently you can only reload the map.
 
--------------------------------------------------------------------------------
 ** Usage
 
 Press F7 to reload the map.
 Any changes that were made in the editor and saved will be applied.
--------------------------------------------------------------------------------
 ** Credits
 
 Based on FenixFyreX's test & play for VX
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_TestEdit"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Test_Edit
    
    Reload_Map_Button = :F7
    Reload_All_Button = :F8
    
    Excluded_Files = []
#===============================================================================
# ** Rest of script
#===============================================================================    

    #---------------------------------------------------------------------------
    # Reload almost everything. Based on FenixFyre's reload code
    #---------------------------------------------------------------------------
    def self.reload_all
      for file in (Dir.entries("Data") - [".", "..", *Excluded_Files])
        next if (file.include?("Map"))
        basename = File.basename(file, ".*").downcase!
        next if (basename == "scripts")
        eval("$data_#{basename} = load_data('Data/#{file}')")
      end
      reload
    end
    
    # Not working
    def self.reload_map
      reload_all
    end
    
    def self.reload
      $game_map.editplay_reload_map if SceneManager.scene_is?(Scene_Map)
    end
  end
end

class Game_Map
  def editplay_reload_map
    setup(@map_id)
    $game_player.center($game_player.x, $game_player.y)
    @need_refresh = true
    SceneManager.scene.editplay_reload_map
  end
end

class Scene_Map < Scene_Base
  
  def editplay_reload_map
    @spriteset.refresh_characters
  end
end

module SceneManager
  class << self
    alias :th_editplay_run :run
  end
  
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  def self.run
    attach_console
    $TEST = true
    th_editplay_run
  end
  
  #-----------------------------------------------------------------------------
  # You always want a console.
  #-----------------------------------------------------------------------------
  def self.attach_console
    # Get game window text
    console_w = Win32API.new('user32','GetForegroundWindow', 'V', 'L').call
    buf_len = Win32API.new('user32','GetWindowTextLength', 'L', 'I').call(console_w)
    str = ' ' * (buf_len + 1)
    Win32API.new('user32', 'GetWindowText', 'LPI', 'I').call(console_w , str, str.length)
    
    # Initiate console
    Win32API.new('kernel32.dll', 'AllocConsole', '', '').call
    Win32API.new('kernel32.dll', 'SetConsoleTitle', 'P', '').call('RGSS3 Console')
    $stdout.reopen('CONOUT$')
    
    # Sometimes pressing F12 will put the editor in focus first,
    # so we have to remove the program's name
    game_title = str.strip
    game_title.sub! ' - RPG Maker VX Ace', ''
    
    # Set game window to be foreground
    hwnd = Win32API.new('user32.dll', 'FindWindow', 'PP','N').call(0, game_title)
    Win32API.new('user32.dll', 'SetForegroundWindow', 'P', '').call(hwnd)
  
  end
end

module Input
  class << self
    alias :th_editplay_update :update
  end
  
  def self.update
    TH::Test_Edit.reload_map if press?(TH::Test_Edit::Reload_Map_Button)
    TH::Test_Edit.reload_all if press?(TH::Test_Edit::Reload_All_Button)
    th_editplay_update    
  end
end

#-------------------------------------------------------------------------------
# Dispose original testplay process, make a new one
#-------------------------------------------------------------------------------
if ($TEST)
  Thread.new {
    system("Game.exe")
  }
  sleep(0.01)
  exit
end