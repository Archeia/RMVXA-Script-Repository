=begin
#===============================================================================
 Title: Utils - Change Equip
 Author: Hime
 Date: Sep 26, 2014
 URL: http://www.himeworks.com/utils-change-equips/
--------------------------------------------------------------------------------
 ** Change log
 Sep 26, 2014
   - equip by etype will try to find first empty slot
 Feb 23, 2014
   - added methods for automatically detecting slot ID using etype ID
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

 This script provides several utility functions for changing equips.
 If you are using scripts that provide custom equip types, you won't be able
 to use the default change weapon/change armor.
 
--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Party Manager and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 There are two ways to equip something: specifying a particular slot ID, or
 specifying a particular etype ID.
 
 Slot ID's are numbered based on the order that they appear for a given actor.
 The first slot in your list is slot 1, the second slot is 2, and so on.
 
 When you specify a slot ID, the engine will simply try to equip it in that
 slot. If it doesn't work, then it will automatically be removed.
 
 The script calls for this are
 
   equip_weapon(actor_id, slot_id, weapon_id)
   equip_armor(actor_id, slot_id, armor_id)
   equip_item(actor_id, slot_id, item_id)
   remove_equip(actor_id, slot_id)
 
 When you specify an etype ID, the engine will try to find a slot that has
 the appropriate etype ID. If it finds one, it will equip the item in that slot.
 If it doesn't, then it will not do anything.
 
 The script calls for this are
   
   equip_weapon_by_etype(actor_id, etype_id, weapon_id)
   equip_armor_by_etype(actor_id, etype_id, armor_id)
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_UtilsChangeEquips"] = true
#===============================================================================
# ** Rest of Script
#===============================================================================
class Game_Interpreter
  
  #-----------------------------------------------------------------------------
  # Equips the given weapon in the specified slot for the chosen actor
  #-----------------------------------------------------------------------------
  def equip_weapon(actor_id, slot_id, weapon_id)
    $game_actors[actor_id].change_equip(slot_id-1, $data_weapons[weapon_id])
  end
  
  #-----------------------------------------------------------------------------
  # Equips the given weapon for the chosen actor. It automatically finds an
  # equip slot that has the specified etype ID
  #-----------------------------------------------------------------------------
  def equip_weapon_by_etype(actor_id, etype_id, weapon_id)
    actor = $game_actors[actor_id]
    slot_id = actor.empty_slot_with_etype(etype_id)
    return unless slot_id
    $game_actors[actor_id].change_equip(slot_id, $data_weapons[weapon_id])
  end
  
  #-----------------------------------------------------------------------------
  # Equips the given armor in the specified slot for the chosen actor
  #-----------------------------------------------------------------------------
  def equip_armor(actor_id, slot_id, armor_id)
    $game_actors[actor_id].change_equip(slot_id-1, $data_armors[armor_id])
  end
  
  #-----------------------------------------------------------------------------
  # Equips the given armor for the chosen actor. It automatically finds an
  # equip slot that has the specified etype ID
  #-----------------------------------------------------------------------------
  def equip_armor_by_etype(actor_id, etype_id, armor_id)
    actor = $game_actors[actor_id]
    slot_id = actor.empty_slot_with_etype(etype_id)
    return unless slot_id
    $game_actors[actor_id].change_equip(slot_id, $data_armors[armor_id])
  end
  
  #-----------------------------------------------------------------------------
  # Equips the given item in the specified slot for the chosen actor
  #-----------------------------------------------------------------------------
  def equip_item(actor_id, slot_id, item_id, find_slot=true)
    actor = $game_actors[actor_id]
    slot_id = actor.empty_slot_with_etype(etype_id)
    $game_actors[actor_id].change_equip(slot_id, $data_items[armor_id])
  end
  
  #-----------------------------------------------------------------------------
  # Removes the equip in the specified slot for the chosen actor
  #-----------------------------------------------------------------------------
  def remove_equip(actor_id, slot_id)
    $game_actors[actor_id].change_equip(slot_id-1, nil)
  end
end

class Game_Actor < Game_Battler
  def empty_slot_with_etype(etype_id)
    slot_id = -1
    equip_slots.each_with_index do |slot_etype, i|
      if slot_etype == etype_id
        if @equips[i].object.nil?
          slot_id = i
          break
        elsif slot_id == -1
          slot_id = i
        end
      end
    end
    return slot_id
  end
end

#===============================================================================
# Compatibility with Core Equip Slots
#===============================================================================
if $imported["TH_CoreEquipSlots"]
  class Game_Actor < Game_Battler
    
    #-----------------------------------------------------------------------------
    # Returns the ID of a slot with the specified etype ID that is empty. If
    # none are empty, returns the first one. If no slots of that type exist,
    # returns nil
    #-----------------------------------------------------------------------------
    def empty_slot_with_etype(etype_id)
      slot_id = -1
      @equips.each_with_index do |slot, i|
        if slot.etype_id == etype_id
          if slot.object.nil?
            slot_id = i
            break
          elsif slot_id == -1         
            slot_id = i
          end
        end
      end
      return slot_id
    end
  end
end