=begin
#===============================================================================
 Title: Preserve Data
 Author: Hime
 Date: Feb 22, 2013
--------------------------------------------------------------------------------
 ** Change log
 Feb 22
   - fixed bug related to interpreter marshal dumping
 Feb 15, 2013
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to "preserve" data throughout the game without requiring
 the user to save the game. For example, if a player enters a room and a switch
 is turned on, you can preserve the state of the switch even if the player
 chooses to reload.
 
 You can preserve variables and switches, and the values of the data will
 carry over across game loads. However, this only applies to the most
 recently saved/loaded file.
 
 If the player starts a new game, and there is already a save file in the first
 slot, that will be treated as the "last saved" file.
 
--------------------------------------------------------------------------------
 ** Usage
 
 Use this script call in an event to save any data that should be preserved.
   
    preserve_data

 More generally, you can use this call outside of the interpreter
 
    DataManager.preserve_data
    
 In the configuration, enter all of the ID's for the switches and variables
 that should be preserved when you choose to preserve data.
 
--------------------------------------------------------------------------------
 ** Bugs
 
 There is currently a bug where if you saved in the middle of an event
 (using the open save menu command) and preserved some data. Usually, the
 event is supposed to start at the very next command (so you don't loop on
 the save), but right now it is actually starting two commands after.
 
 There seems to be some indexing issues.

#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_PreserveData"] = true
#===============================================================================
# ** Rest of the Script
#=============================================================================== 
module TH
  module Preserve_Data
    
    # list of switches and variables that should be preserved
    Switches = [1,2,3]
    Variables = [1,2,3]
  end
end
#===============================================================================
# ** Rest of the Script
#=============================================================================== 
module DataManager
  
  # Open the most recent save-file and modify the preserved data
  def self.preserve_data
    $game_temp.preserving_data = true
    filename = make_filename(last_savefile_index)
    return unless File.exist?(filename)
    header = {}
    contents = {}
    
    # get data from most recent savefile
    File.open(make_filename(last_savefile_index), "rb") do |file|
      header = Marshal.load(file)
      contents = Marshal.load(file)
    end
    # Update preserved data
    TH::Preserve_Data::Switches.each {|id|
      contents[:switches][id] = $game_switches[id]
    }
    TH::Preserve_Data::Variables.each {|id, val|
      contents[:variables][id] = $game_variables[id]
    }
    
    # write modified data into save file
    File.open(make_filename(last_savefile_index), "wb") do |file|
      Marshal.dump(header, file)
      Marshal.dump(contents, file)    
    end
    $game_temp.preserving_data = false
  end
end

class Game_Temp
  
  attr_accessor :preserving_data
end

class Game_Interpreter
  
  def preserve_data
    DataManager.preserve_data
  end
  
  alias :th_preserve_data_marshal_dump :marshal_dump
  def marshal_dump
    
    # don't update the index if we're preserving data
    if $game_temp.preserving_data
      return [@depth, @map_id, @event_id, @list, @index, @branch]
    else
      th_preserve_data_marshal_dump
    end
  end
end