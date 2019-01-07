=begin
#===============================================================================
 Title: Corpse Retrieval
 Author: Hime
 Date: Aug 17, 2013
--------------------------------------------------------------------------------
 ** Change log
 Aug 17, 2013
   - bug fix: game crashes when creating corpse on map with no events
 Mar 28, 2013
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
 
 This script adds "corpse retrieval" functionality to your project.
 
 It provides a script call that allows you to create a "corpse" of your
 current active party. All of the equips that are equipped will be removed
 from the members and placed in an event. When you retrieve your corpse,
 you will recover all of those equips.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage
 
 To create a corpse, make a script call

    create_party_corpse
    
 Then perform any other commands as needed. When the player returns to pick up
 the corpse all lost equips will be recovered.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_CorpseRetrieval"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Corpse_Retrieval

    # Character name and index to use for the corpse
    Corpse_Name = "$Coffin"
    Corpse_Index = 0
    
#===============================================================================
# ** Rest of script
#===============================================================================

    #---------------------------------------------------------------------------
    # 
    #---------------------------------------------------------------------------
    def self.create_corpse_event(corpse_items, x, y)
      ev = RPG::Event.new(x, y)
      setup_event_page(ev.pages[0])
      ev.pages[0].list = []
      setup_event_commands(corpse_items, ev.pages[0].list)
      return ev
    end
    
    #---------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------
    def self.setup_event_page(page)
      page.trigger = 0
      page.direction_fix = true
      page.priority_type = 1
      page.graphic.character_name = Corpse_Name
      page.graphic.character_index = Corpse_Index
    end
    
    #---------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------
    def self.setup_event_commands(corpse_items, list)
      list << RPG::EventCommand.new(101, 0, ["", 0, 0, 2])
      list << RPG::EventCommand.new(401, 0, ["Corpse retrieved"])
      corpse_items[:weapons].each do |id, amount|
        list << RPG::EventCommand.new(127, 0, [id, 0, 0, amount, false])
      end
      corpse_items[:armors].each do |id, amount|
        list << RPG::EventCommand.new(128, 0, [id, 0, 0, amount, false])
      end
      list << RPG::EventCommand.new("delete_corpse_event")
      list << RPG::EventCommand.new
    end
  end
end

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class Game_Interpreter
  
  #-----------------------------------------------------------------------------
  # Call this method to unequip all currently equipped items in the active
  # battle party and place them in an event.
  #-----------------------------------------------------------------------------
  def create_party_corpse(map_id=$game_map.map_id, x=$game_player.x, y=$game_player.y)
    corpse_items = $game_party.create_party_corpse
    corpse_event = TH::Corpse_Retrieval.create_corpse_event(corpse_items, x, y)
    $game_system.add_corpse_event(map_id, corpse_event)
    $game_map.setup_corpse_events
  end
  
  #-----------------------------------------------------------------------------
  # Deletes the current corpse event and removes it from the system and map.
  #-----------------------------------------------------------------------------
  def command_delete_corpse_event
    corpse_event = $game_map.events[@event_id].instance_variable_get(:@event)
    $game_system.remove_corpse_event(@map_id, corpse_event)
    $game_map.remove_corpse_event(@event_id)
  end
end

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class Game_System
  
  attr_reader :party_corpses  # stores locations of party corpses
  
  alias :th_corpse_retrieval_initialize :initialize
  def initialize
    th_corpse_retrieval_initialize
    @party_corpses = {}
  end
  
  def get_corpse_events(map_id)
    @party_corpses[map_id] ||= []
    @party_corpses[map_id]
  end
  
  def add_corpse_event(map_id, event)
    @party_corpses[map_id] ||= []
    @party_corpses[map_id].push(event)
  end
  
  def remove_corpse_event(map_id, event)
    @party_corpses[map_id].delete(event)
  end
end

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class Game_Map
  
  alias :th_corpse_retrieval_setup_events :setup_events
  def setup_events
    th_corpse_retrieval_setup_events
    setup_corpse_events
  end
  
  def setup_corpse_events
    event_id = (@events.keys.max || 0) + 1
    $game_system.get_corpse_events(@map_id).each do |ev|
      ev.id = event_id
      @events[event_id] = Game_Event.new(@map_id, ev)
      event_id += 1
    end
    SceneManager.scene.instance_variable_get(:@spriteset).refresh_characters if SceneManager.scene_is?(Scene_Map)
    @need_refresh = true
  end
  
  def remove_corpse_event(event_id)
    @events.delete(event_id)
    SceneManager.scene.instance_variable_get(:@spriteset).refresh_characters if SceneManager.scene_is?(Scene_Map)
    @need_refresh = true
  end
end

#-------------------------------------------------------------------------------
# Delete all currently equipped items after storing them
#-------------------------------------------------------------------------------
class Game_Actor < Game_Battler
  
  def delete_equips
    @equips = Array.new(equip_slots.size) { Game_BaseItem.new }
    refresh
  end
end

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class Game_Party < Game_Unit
  
  def collect_corpse_armors
    corpse_armors = {}
    battle_members.each do |actor|
      actor.armors.each do |armor|
        next unless armor
        corpse_armors[armor.id] ||= 0
        corpse_armors[armor.id] += 1
      end
    end
    return corpse_armors
  end
  
  def collect_corpse_weapons
    corpse_weapons = {}
    battle_members.each do |actor|
      actor.weapons.each do |weapon|
        next unless weapon
        corpse_weapons[weapon.id] ||= 0
        corpse_weapons[weapon.id] += 1
      end
    end
    return corpse_weapons
  end
  
  def collect_corpse_items
    corpse_items = {}
    corpse_items[:armors] = collect_corpse_armors
    corpse_items[:weapons] = collect_corpse_weapons
    corpse_items
  end
  
  def create_party_corpse
    corpse_items = collect_corpse_items
    delete_battle_member_equips
    return corpse_items
  end
  
  def delete_battle_member_equips
    battle_members.each do |actor|
      actor.delete_equips
    end
  end
end

