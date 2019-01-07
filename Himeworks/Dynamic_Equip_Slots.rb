=begin
#===============================================================================
 Title: Dynamic Equip Slots
 Author: Hime
 Date: Jul 13, 2013
--------------------------------------------------------------------------------
 ** Change log
 Jul 13, 2013
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
 
 This script allows you to add or remove equip slots during the game using
 script calls. You can add or remove equip slots as many times as you want
 using simple script calls.

--------------------------------------------------------------------------------
 ** Required
 
 Core - Equip Slots
 (http://himeworks.com/2013/07/13/core-equip-slots/)
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Core - Equip Slots and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 The following methods are available for adding or removing equip slots
 using script calls:
 
   add_equip_slot(actor_id, etype_id)
   remove_equip_slot(actor_id, etype_id)
   
 When an equip is removed, the item is returned to your inventory.
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_DynamicEquipSlots"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Dynamic_Equip_Slots
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
class Game_Interpreter
  
  #-----------------------------------------------------------------------------
  # New. Adds an equip slot with the given etype to the specified actor.
  #-----------------------------------------------------------------------------
  def add_equip_slot(actor_id, etype_id)
    $game_actors[actor_id].add_equip_slot(etype_id)
  end
  
  #-----------------------------------------------------------------------------
  # New. Removes an equip slot with the given etype from the specified actor.
  #-----------------------------------------------------------------------------
  def remove_equip_slot(actor_id, etype_id)
    $game_actors[actor_id].remove_equip_slot(etype_id)
  end
end

class Game_Actor < Game_Battler
  #-----------------------------------------------------------------------------
  # New. Adds an equip slot to the actor with the given etype id
  #-----------------------------------------------------------------------------
  def add_equip_slot(etype_id)
    @equips.push(Game_EquipSlot.new(etype_id))
    sort_equip_slots
  end

  #-----------------------------------------------------------------------------
  # New. Deletes an equip slot for the given etype. If there are multiple slots
  # with that etype, simply removes one at random. Any equipped items in that
  # slot is returned to the inventory.
  #-----------------------------------------------------------------------------
  def remove_equip_slot(etype_id)
    slot_id = @equips.index {|eslot| eslot.etype_id == etype_id }
    return unless slot_id
    change_equip(slot_id, nil)
    @equips.delete_at(slot_id)
  end
end