=begin
#===============================================================================
 Title: Map Folders
 Author: Hime
 Date: Mar 19, 2014
--------------------------------------------------------------------------------
 ** Change log
 Mar 19, 2014
   - overwrites the way maps are loaded.
 Apr 3, 2013
   - added support for explicit transfer designation using script call
 Feb 24, 2013
   - added "load from zero folder" option
   - added support for custom folder naming schemes
   - added support for specifying (x, y) on the new map
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credit Hime Works
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to manage more than 999 maps in a single project.
 It allows you to place extra maps into separate sub-folders in your Data
 folder.
 
 For example, maps 1000 to 1999 will be placed in Map1, maps 2000
 to 2999 will be placed in Map2, and so on.
 
 All maps directly under the Data folder are considered part of the
 "zero folder".
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this below Materials and above Main.
 You should place this script above other custom scripts.
 
--------------------------------------------------------------------------------
 ** Usage
 
 Create folders with the name
 
   Maps#
   
 For some number #. eg: Map1, Map2, Map23
 You can change the naming scheme in the configuration section. The naming
 scheme must take exactly one number, which represents the folder ID.
 
 You can place up to 999 maps into one folder. Remember to move the
 mapInfos.rvdata2 file as well, since the editor will need that to correctly
 load the map tree.
 
 You will use script calls to change to different folders in the game.
 You should place these script calls before the actual map transfer command.
 
   change_map_folder(id)
   $game_system.change_map_folder(id)
   
 If you want to switch to maps in Map12, then you will use
 
   change_map_folder(12)
   
 You can specify an the position you want the player to be
 transferred to in case the position on your new map is not available in the
 editor.
 
 You can pass in the map_id and x, y coordinates in the script call as well
 
   change_map_folder(id, map_id, x, y)
 
 NOTE: due to how the default scripts work, if you transfer to a map with
 the same ID, the game won't actually setup a new map! This can be solved
 easily but for compatibility reasons it has not been changed.
 
--------------------------------------------------------------------------------
 ** Compatibility
 
 The following classes/functions have been modified
 
     aliased - load_data
   Game_Interpreter
     command_201
   Game_Map
     aliased - setup
   Game_System
     aliased - initialize
    
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_MapFolders"] = true
#===============================================================================
# ** Configuration
#=============================================================================== 
module TH
  module Map_Folders
    
    # naming scheme for your folder
    Folder_Names = "Map%d"  
    
    # loads from the zero folder rather than Data folder. Might be useful if
    # you are currently developing maps from other folders
    Load_From_Zero_Folder = false
    
    # The folder to use when you start a new game.
    Start_Folder = 0
  end
end
#===============================================================================
# ** Rest of script
#=============================================================================== 

#-------------------------------------------------------------------------------
# Store the current folder ID somewhere
#-------------------------------------------------------------------------------
class Game_System
  attr_reader :map_folder_id
  
  alias :th_map_folders_init :initialize
  def initialize
    th_map_folders_init 
    @map_folder_id = TH::Map_Folders::Start_Folder
  end
  
  def change_map_folder(folder_id)
    @map_folder_id = folder_id
  end
end

class Game_Temp
  attr_accessor :map_folder_transfer_x
  attr_accessor :map_folder_transfer_y
  attr_accessor :map_folder_transfer_map_id
end

#-------------------------------------------------------------------------------
# Game map setup includes folder ID
#-------------------------------------------------------------------------------
class Game_Map
  
  alias :th_map_folders_setup :setup
  def setup(map_id)
    @map_id = map_id
    @map = load_folder_map(map_id)
    @tileset_id = @map.tileset_id
    @display_x = 0
    @display_y = 0
    referesh_vehicles
    setup_events
    setup_scroll
    setup_parallax
    setup_battleback
    @need_refresh = false
  end
  
  def load_folder_map(map_id)
    map_id += 1000 * $game_system.map_folder_id
    folder_id = map_id / 1000
    map_id = map_id % 1000
    if folder_id == 0 && !TH::Map_Folders::Load_From_Zero_Folder
      load_data("Data/Map%03d.rvdata2" %map_id)
    else
      load_data(sprintf("Data/%s/Map%03d.rvdata2", sprintf(TH::Map_Folders::Folder_Names, folder_id), map_id))
    end    
  end
end

class Game_Player < Game_Character
  
  alias :th_map_folders_reserve_transfer :reserve_transfer
  def reserve_transfer(map_id, x, y, d = 2)
    th_map_folders_reserve_transfer(map_id, x, y, d)
    @new_x = $game_temp.map_folder_transfer_x if $game_temp.map_folder_transfer_x
    @new_y = $game_temp.map_folder_transfer_y if $game_temp.map_folder_transfer_y
    @new_map_id = $game_temp.map_folder_transfer_map_id if $game_temp.map_folder_transfer_map_id
  end
end

#-------------------------------------------------------------------------------
# For convenience
#-------------------------------------------------------------------------------
class Game_Interpreter
  
  alias :th_map_folders_clear :clear
  def clear
    th_map_folders_clear
    $game_temp.map_folder_transfer_x = nil
    $game_temp.map_folder_transfer_y = nil
    $game_temp.map_folder_transfer_map_id = nil
  end
  
  def change_map_folder(folder_id, map_id=nil, x=nil, y=nil)
    $game_system.change_map_folder(folder_id)
    $game_temp.map_folder_transfer_map_id = map_id
    $game_temp.map_folder_transfer_x = x
    $game_temp.map_folder_transfer_y = y
  end
  
  alias :th_map_folders_command_201 :command_201
  def command_201
    @params[1] = $game_temp.map_folder_transfer_map_id || @params[1]
    @params[2] = $game_temp.map_folder_transfer_x || @params[2]
    @params[3] = $game_temp.map_folder_transfer_y || @params[3]
    th_map_folders_command_201
  end
end
