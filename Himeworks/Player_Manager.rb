=begin
#===============================================================================
 ** Player Manager
 Author: Hime
 Date: Aug 18, 2013
--------------------------------------------------------------------------------
 ** Change log
 Aug 18, 2013
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
 
 This script allows you to manage multiple players. Each player has its own
 party, which allows you to separate actors into different groups and control
 them separately.
 
 Each players also has its own location, so if you switch between players, the
 game will change to the selected player's location.

--------------------------------------------------------------------------------
 ** Required
 
 Party Manager
 (http://himeworks.com/2013/08/19/party-manager/)
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Party Manager and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 All players must have a unique ID. The initial player has ID 1.
 
 Creating a player is a three-step process:
 
 -First, you will choose an ID for the player.
 -Then, you will choose which actors will be assigned to the player.
 -Finally, you must define a location for the player, using the script call
 
   create_player_location(map_id, x, y)
   
 To create a new player, you would do something like this:
 
   members = [2,3,4]
   location = create_player_location(5, 10, 12)
   create_player(2, members, location)
   
 This will create a new player with ID 2, with actors 2, 3, and 4.
 The player will be created at map 5, at position (10, 12).
 If a player with the specified ID already exists, then nothing will happen.
 
 To switch players, make the script call
 
   switch_player(player_id)
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_PlayerManager"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Player_Manager
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module DataManager
  
  class << self
    alias :th_player_manager_create_game_objects :create_game_objects
    alias :th_player_manager_make_save_contents :make_save_contents
    alias :th_player_manager_extract_save_contents :extract_save_contents
  end
  
  def self.create_game_objects
    th_player_manager_create_game_objects
    $game_players = Game_Players.new
  end
  
  def self.make_save_contents
    contents = th_player_manager_make_save_contents
    contents[:parties] = $game_parties
    contents
  end
  
  def self.extract_save_contents(contents)
    th_player_manager_extract_save_contents(contents)
    $game_parties = contents[:parties]
  end
end

#-------------------------------------------------------------------------------
# Stores the location of a player
#-------------------------------------------------------------------------------
class Game_PlayerLocation
  attr_accessor :map_id
  attr_accessor :x
  attr_accessor :y
  
  def initialize(map_id, x, y)
    @map_id = map_id
    @x = x
    @y = y
  end
end
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class Game_Players
  include Enumerable
  
  def initialize
    @data = {}
    setup_initial_player
  end
  
  def setup_initial_player
    location = Game_PlayerLocation.new($data_system.start_map_id, $data_system.start_x, $data_system.start_y)
    $game_player.id = 1
    $game_player.party = $game_party
    $game_player.location = location
    @data[1] = $game_player
  end

  def [](id)
    @data[id]
  end
  
  def size
    @data.size
  end
  
  def each(&block)
    @data.values.each(&block)
  end
  
  #-----------------------------------------------------------------------------
  # Creates a new player, assigning it a party with the given members
  #-----------------------------------------------------------------------------
  def create_player(id, members, location)
    return if @data[id]
    player = Game_Player.new
    player.id = id
    player.location = location
    player.moveto_location(player.location.x, player.location.y)
    player.party = $game_parties.create_party(id, members)
    @data[id] = player
    return player
  end
  
  def make_location
    return Game_PlayerLocation.new($data_system.start_map_id, $data_system.start_x, $data_system.start_y)
  end
  
  #-----------------------------------------------------------------------------
  # Switches to the specified player
  #-----------------------------------------------------------------------------
  def switch_player(id)
    return if $game_player.id == id
    pre_switch_processing(id)
    perform_switch(id)
    refresh
  end
  
  #-----------------------------------------------------------------------------
  # Some stuff to do before switching the player
  #-----------------------------------------------------------------------------
  def pre_switch_processing(player_id)
    $game_player.update_location
  end
  
  #-----------------------------------------------------------------------------
  # The actual switching
  #-----------------------------------------------------------------------------
  def perform_switch(player_id)
    enc_count = $game_player.encounter_count
    player = @data[player_id]
    $game_party = player.party
    $game_player = player
    $game_player.encounter_count = enc_count
  end
  
  def refresh
    refresh_map
    refresh_player
  end
  
  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def refresh_map
    if $game_player.location.map_id != $game_map.map_id
      $game_map.setup($game_player.location.map_id)
    end
    SceneManager.scene.instance_variable_get(:@spriteset).refresh_characters if SceneManager.scene_is?(Scene_Map)
  end
  
  def refresh_player
    $game_player.refresh
    $game_player.center($game_player.x, $game_player.y)
  end
end

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class Game_Player
  attr_accessor :location
  attr_accessor :party
  attr_accessor :id
  attr_accessor :encounter_count
  
  def update_location
    @location.map_id = $game_map.map_id
    @location.x = @x
    @location.y = @y
  end
  
  #-----------------------------------------------------------------------------
  # Same as move to except without the centering and other stuff...
  #-----------------------------------------------------------------------------
  def moveto_location(x, y)
    @x = x
    @y = y
    @real_x = @x
    @real_y = @y
    refresh
  end
end

class Game_Interpreter
  
  def create_player_location(map_id, x, y)
    return Game_PlayerLocation.new(map_id, x, y)
  end
  
  def create_player(player_id, members, location)
    $game_players.create_player(player_id, members, location)
  end
  
  def switch_player(player_id)
    $game_players.switch_player(player_id)
  end
end