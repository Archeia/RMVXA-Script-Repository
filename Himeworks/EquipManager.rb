4=begin
#===============================================================================
 ** Equip Manager
 Author: Hime
 Date: Jul 16, 2013
--------------------------------------------------------------------------------
 ** Change log
 Jul 16, 2013
   - fixed bug in note-tag parsing again
 May 15, 2013
   - fixed bug in note-tag parsing
 Mar 19, 2013
   - fixed bug where optimizing equips checked etype instead of wtype or atype
 Jan 23, 2013
   - Demo release
-------------------------------------------------------------------------------- 
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Preserve this header
--------------------------------------------------------------------------------
 ** Compatibility
 
 This script overwrites a lot of methods related to equips.
 
 Appears to work with Yanfly's Ace Equip Engine. This script must be placed
 below Ace Equip Engine

 --------------------------------------------------------------------------------
 ** Description
 
 This script provides a variety of equip-related functionality.
 
 1. Custom equip slots
 
 Define custom equip slots and setup slots based on actors/classes. Actor slots
 take precedence over class slots. You can setup regular slots as well as
 dual wield slots. Use note-tags to setup initial equipment.
 
 2. Equip Type mapping
 
 This script changes how equip types (etypes) are handled by the engine.
 By default, there are 5 etypes:
 
   -weapon
   -shield
   -bodygear
   -headgear
   -accessory
 
 All weapons have "weapon" etype, while you can specify which etype each
 armor is.
 
 This script allows you to describe which weapon types (wtypes) or armor types
 can be equipped in a particular equip slot.
    
--------------------------------------------------------------------------------
 ** Usage
 
 1. Set up your equip types in the Equip_Types table in the config section.
    Everything will depend on this.
    
 2. Set up the wtype and atype mappings for each equip type in the Etype_Map
    table. Each type contains an array of numbers that represent the 
    corresponding weapon type or armor type defined in the database. The arrays
    describe which types of weapons/armors can be equipped in that slot.
    
 3. Give your actors or classes equip slots and dual wield slots using
    the following note-tags
    
      <equip_slots: 0 1 2 3 4> 
      <dual_slots: 0 0 2 3 4>
 
 4. Give your actors some initial equips, using the following notetag
 
      <init_equips: w1 a3 0 a20 a40>
      
    Where w means weapon, a means armor, the number is the ID of the equip,
    and 0 means the slot is initially empty.
    
--------------------------------------------------------------------------------
 ** Alerts
 
 Things to look out for
 
 -equip related event commands will not work properly. They assume a hardcoded
  equip system, and there is no way to use it with a custom equip type system
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_EquipManager"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module EquipManager
    
    # This table stores the types of equips. Equip slots will use the 
    # name provided.
    Equip_Types = {
      0 => "Hands",
      1 => "Shield",
      2 => "Bodygear",
      3 => "Headgear",
      4 => "Accessory",
      
      # Custom equip types
      5 => "Bow",
      6 => "Gloves",
      7 => "Arrows",
      8 => "Hat",
      9 => "Blade",
      10 => "Sword"
    }
    
    # Just something if you don't want to set up slots for your actors yourself
    Default_Equip_Slots = [0, 1, 2, 3, 4]
    Default_Dual_Slots = [0, 0, 2, 3, 4]
    
    # This table represents the etype mapping.
    # The indices correspond to the types defined in the Equip Type table.
    # Each entry is a hash describing which wtypes and atypes can be placed
    # in that slot. Sample entries have been provided
    Etype_Map = {
      0 => { :wtypes => [1,2,3,4,5,7,8,9,10],
             :atypes => [5,6]
           },
      1 => { :wtypes => [],
             :atypes => [5,6]
           },
      2 => { :wtypes => [],
             :atypes => [2]
           },
      3 => { :wtypes => [],
             :atypes => [1]
           },
      4 => { :wtypes => [],
             :atypes => [1,2,3,4]
           },
      5 => { :wtypes => [6],
             :atypes => [],
           },
      7 => { :wtypes => [11]
           },
      9 => { :wtypes => [4, 5]
           },
      10 => { :wtypes => [4]
           }
    }
#===============================================================================
# ** Rest of the script
#===============================================================================    
    Initial_Equip_Regex = /<init_equips: (.*)>/i
    Equip_Slot_Regex = /<equip[-_ ]slots: (.*)>/i
    Dual_Slot_Regex = /<dual[-_ ]slots: (.*)>/i
  
    #---------------------------------------------------------------------------
    # Regular equip slots
    #---------------------------------------------------------------------------
    def equip_slots
      return @equip_slots unless @equip_slots.nil?
      load_notetag_equip_slots
      return @equip_slots
    end
    
    #---------------------------------------------------------------------------
    # Dual wield equip slots
    #---------------------------------------------------------------------------
    def dual_slots
      return @dual_slots unless @dual_slots.nil?
      load_notetag_dual_slots
      return @dual_slots
    end
    
    def load_notetag_equip_slots
      @equip_slots = TH::EquipManager::Default_Equip_Slots
      res = self.note.match(TH::EquipManager::Equip_Slot_Regex)
      if res
        @equip_slots = res[1].scan(/\d+/).map!{|etype_id| etype_id.to_i}
      end
    end
    
    def load_notetag_dual_slots
      @dual_slots = TH::EquipManager::Default_Dual_Slots
      results = self.note.scan(TH::EquipManager::Dual_Slot_Regex)
      results.each do |res|
        @dual_slots = res[1].scan(/\d+/).map!{|etype_id| etype_id.to_i}
      end
    end
  end
end

module Vocab
  
  class << self
    alias :th_etype_map_etype :etype
  end
  
  #-----------------------------------------------------------------------------
  # Replaced. Draw name from type map
  #-----------------------------------------------------------------------------
  def self.etype(etype_id)
    if TH::EquipManager::Equip_Types.include?(etype_id)
      TH::EquipManager::Equip_Types[etype_id]
    else
      th_etype_map_etype(etype_id)
    end
  end
end

module RPG
  class Actor < BaseItem
    include TH::EquipManager
    
    attr_accessor :use_actor_slots
    
    def equips
      return @equips if @init_equip_checked
      load_notetag_init_equips
      return @equips
    end
    
    #---------------------------------------------------------------------------
    # Custom method for loading initial equipment.
    # For internal use only. negative = weapon, positive = armor
    # Will change next update to support items
    #---------------------------------------------------------------------------
    def load_notetag_init_equips
      @equips = []
      res = self.note.match(TH::EquipManager::Initial_Equip_Regex)
      if res
        res[1].split.each {|info|
          type, id = info[0], info[1..-1].to_i
          id *= -1 if type == "w"
          @equips.push id
        }
      else
        @equips = [0]
      end
      @init_equip_checked = true
    end
  end
  
  #-----------------------------------------------------------------------------
  # Same thing for classes
  #-----------------------------------------------------------------------------
  class Class < BaseItem
    include TH::EquipManager
  end
end

class Game_Actor < Game_Battler
  
  #-----------------------------------------------------------------------------
  # Overwrite. Return custom slots unique to each actor
  #-----------------------------------------------------------------------------
  def equip_slots
    if dual_wield?
      return actor.dual_slots ? actor.dual_slots : self.class.dual_slots
    else
      return actor.equip_slots ? actor.equip_slots : self.class.equip_slots
    end
  end
  
  #-----------------------------------------------------------------------------
  # Overwrite. New way of initializing equips
  #-----------------------------------------------------------------------------
  def init_equips(equips)
    @equips = Array.new(equip_slots.size) { Game_BaseItem.new }
    equips.each_with_index do |item_id, i|
      break if i > @equips.size - 1
      @equips[i].set_equip(item_id < 0, item_id.abs)
    end
    refresh
  end
  
  #-----------------------------------------------------------------------------
  # New. 
  #-----------------------------------------------------------------------------  
  def etype_can_equip?(slot_id, item)
    etype_id = equip_slots[slot_id]
    if TH::EquipManager::Etype_Map.include?(etype_id)
      if item.is_a?(RPG::Weapon)
        types = TH::EquipManager::Etype_Map[etype_id][:wtypes]
        return false unless types && types.include?(item.wtype_id)
      end
      if item.is_a?(RPG::Armor)
        types = TH::EquipManager::Etype_Map[etype_id][:atypes]
        return false unless types && types.include?(item.atype_id)
      end
    else
      return false if equip_slots[slot_id] != item.etype_id
    end
    return true
  end
  
  #-----------------------------------------------------------------------------
  # Overwrite. Check type mapping instead of etype ID
  #-----------------------------------------------------------------------------
  def change_equip(slot_id, item)
    return unless trade_item_with_party(item, equips[slot_id])
    return if item && !etype_can_equip?(slot_id, item)
    @equips[slot_id].object = item
    refresh
  end
  
  #-----------------------------------------------------------------------------
  # Overwrite. Check etype mapping instead of etype ID
  #-----------------------------------------------------------------------------
  def release_unequippable_items(item_gain = true)
    loop do
      last_equips = equips.dup
      @equips.each_with_index do |item, i|
        if !equippable?(item.object) || !etype_can_equip?(i, item.object)
          trade_item_with_party(nil, item.object) if item_gain
          item.object = nil
        end
      end
      return if equips == last_equips
    end
  end
  
  #-----------------------------------------------------------------------------
  # Overwrite. Check etype mapping instead of etype ID
  #-----------------------------------------------------------------------------
  def optimize_equipments
    clear_equipments
    equip_slots.size.times do |i|
      next if !equip_change_ok?(i)
      items = $game_party.equip_items.select do |item|
        etype_can_equip?(i, item) &&
        equippable?(item) && item.performance >= 0
      end
      change_equip(i, items.max_by {|item| item.performance })
    end
  end
end

#-------------------------------------------------------------------------------
# Equip item list should filter by wtype or atype, not etype
#-------------------------------------------------------------------------------
class Window_EquipItem < Window_ItemList
  
  #-----------------------------------------------------------------------------
  # Overwrite. Check etype mapping instead of etype ID's
  #-----------------------------------------------------------------------------
  def include?(item)
    return true if item == nil
    return false unless item.is_a?(RPG::EquipItem)
    return false if @slot_id < 0
    return false unless @actor.etype_can_equip?(@slot_id, item)
    return @actor.equippable?(item)
  end
end

#-------------------------------------------------------------------------------
# Display all equip slots
#-------------------------------------------------------------------------------
class Window_EquipSlot < Window_Selectable
    
  #-----------------------------------------------------------------------------
  # Overwrite. Refresh the contents to account for variable number of slots
  #-----------------------------------------------------------------------------
  def refresh
    create_contents
    draw_all_items
  end
end