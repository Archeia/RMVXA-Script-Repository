=begin
#===============================================================================
 Title: Idle Party Events
 Author: Hime
 Date: Jan 3, 2015
 URL: http://himeworks.com/2013/10/11/idle-party-events/
--------------------------------------------------------------------------------
 ** Change log
 Jan 3, 2015
   - improved idle event removal
 Oct 11, 2013
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
 
 This script allows you to set up "idle party" events. These are special events
 that appear when you have other parties on the same map. You can interact
 with idle parties the same way you would with an event.
 
 A party is idle when
 
 1. it is not the currently active party, and
 2. it is not synchronized to the currently active party
 
 Each map must have its own set of idle party events in order for the party
 to appear. Each event is given a party ID, which is used to associate that
 event with a particular party. When the party is idle, the idle party event
 will move to the party's position when it went idle.
 
 An idle party event behaves exactly as a normal event would, with custom
 move routes and parallel processes. However, even if they move around, when
 you switch parties, they will be reset to the party's location.

--------------------------------------------------------------------------------
 ** Required 
 
 Party Manager
 (http://himeworks.com/2013/08/19/party-manager/)
--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Party Manager and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 To create an idle party event, in the first page of an event, add the comment:

   <idle party id: x>
   
 Where `x` is the ID of the party to assign to
 
 Repeat this for any parties that you would like an idle event for.
 Every map must have their own set of idle party events.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_IdlePartyEvents"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Idle_Party_Events
    Regex = /<idle[-_ ]party[-_ ]id:\s*(\d+)\s*>/i
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  class Event
    
    def idle_party_id
      parse_idle_party_id unless @idle_party_id
      return @idle_party_id
    end
    
    def parse_idle_party_id
      @idle_party_id = 0
      @pages[0].list.each do |cmd|
        if cmd.code == 108 && cmd.parameters[0] =~ TH::Idle_Party_Events::Regex
          @idle_party_id = $1.to_i
        end
      end
    end
  end
end

class Game_Parties
  def idle_parties
    @data.values.select {|party| party.id != $game_party.id && party.location.map_id == $game_map.map_id }
  end
  
  alias :th_idle_party_events_create_party :create_party
  def create_party(*args)
    party = th_idle_party_events_create_party(*args)
    $game_map.setup_idle_party_events
    party
  end
  
  alias :th_idle_party_events_switch_party :switch_party
  def switch_party(*args)
    party = th_idle_party_events_switch_party(*args)
    party
  end
end

class Game_Map
    
  alias :th_idle_party_events_initialize :initialize
  def initialize
    th_idle_party_events_initialize
    @idle_events = {}
  end
  
  alias :th_idle_party_events_setup :setup
  def setup(map_id)
    th_idle_party_events_setup(map_id)
    setup_idle_party_events
  end
  
  alias :th_idle_party_events_setup_events :setup_events
  def setup_events
    remove_idle_events
    th_idle_party_events_setup_events
  end
  
  #-----------------------------------------------------------------------------
  # Go through the map's event data and pull out all of the idle events
  #-----------------------------------------------------------------------------
  def remove_idle_events
    remove_list = []
    @map.events.each do |i, event|
      if event.idle_party_id > 0
        @idle_events[event.idle_party_id] = event
        remove_list << i
      end
    end
    remove_list.each do |id|
      @map.events.delete(id)
    end
  end
  
  def setup_idle_party_events
    delete_idle_party_events
    @idle_party_events = {}
    $game_parties.idle_parties.each do |party|
      create_idle_party_event(party)
    end
    refresh_idle_party_events
  end
  
  def create_idle_party_event(party)
    id = party.id
    return unless @idle_events[id]
    leader = party.leader
    event = @idle_events[id]
    event.x = party.location.x
    event.y = party.location.y
    event.pages[0].graphic.character_name = leader.character_name
    event.pages[0].graphic.character_index = leader.character_index
    event.pages[0].graphic.direction = party.direction
    @events[event.id] = Game_Event.new(@map_id, event)
    @idle_events[party.id] = event
    @needs_refresh = true
  end
  
  def update_idle_party_events
    event = @idle_events[$game_party.id]
    @events.delete(event.id)
    @idle_party_events = {}
    $game_parties.idle_parties.each do |party|
      create_idle_party_event(party)
    end
    refresh_idle_party_events
  end
  
  def refresh_idle_party_events
    return unless SceneManager.scene_is?(Scene_Map) && @needs_refresh    
    SceneManager.scene.instance_variable_get(:@spriteset).refresh_characters
  end
  
  def delete_idle_party_events
    @idle_events.values.each do |event|
      @events.delete(event.id)
    end
  end
end

class Scene_Map < Scene_Base  
  
  alias :th_idle_party_events_post_transfer_party_processing :post_transfer_party_processing
  def post_transfer_party_processing
    th_idle_party_events_post_transfer_party_processing
    $game_map.setup_idle_party_events
  end
end