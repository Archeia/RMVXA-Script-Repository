=begin
#===============================================================================
 Title: Multiple Equip Types
 Author: Hime
 Date: Jan 31, 2016
--------------------------------------------------------------------------------
 ** Change log
 Jan 31, 2016
   - updated to check for @actor in Window_ItemEquip
 Aug 15, 2014
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
 
 This script allows you to assign multiple equip types to an equip.
 By default, each equip has only equip type. For example, a sword is a "Weapon"
 equip type and can only be placed in "Weapon" slots. A wooden shield is a
 "Shield" equip type and can only be placed in "Shield" slots.
  
 With multiple equip types, you can place an equip in any slot that it is
 compatible with. For example, you could create a slot called "left hand" and
 another slot called "right hand" and then specify that certain equips can only
 be held in your left hand, certain equips in your right hand, and certain
 equips in any hand.
 
--------------------------------------------------------------------------------
 ** Required
 
 Core Equip Slots
 (http://www.himeworks.com/2013/07/13/core-equip-slots/)
 
 Custom Equip Types
 (http://www.himeworks.com/2013/07/25/custom-equip-types/)
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Custom Equip Types and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 Equip types can be specified using the following note-tag
 
   <equip type: x>
   
 Where `x` is the equip type ID. These are defined in the Custom Equip Type
 table that you set up.
 
--------------------------------------------------------------------------------
 ** Example
 
 Suppose equip type 0 is left hand, and equip type 1 is right hand.
 You can specify that an equip can be placed in both left and right hands
 using the note-tags:
 
    <equip type: 0>
    <equip type: 1>
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_MultipleEquipTypes"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module Th
  module Multiple_Equip_Types
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  class EquipItem < BaseItem
    
    def etype_ids
      load_notetag_multiple_equip_types unless @etype_ids
      return @etype_ids
    end
    
    def load_notetag_multiple_equip_types
      @etype_ids = [self.etype_id]
      results = self.note.scan(TH::Custom_Equip_Types::Regex)
      results.each do |res|
        @etype_ids.push(res[0].to_i)
      end
    end
  end
end

class Game_Actor
  
  #-----------------------------------------------------------------------------
  # Overwrite. etype ID's is an array
  #-----------------------------------------------------------------------------
  def change_equip(slot_id, item)
    return unless trade_item_with_party(item, equips[slot_id])
    return if item && !item.etype_ids.include?(equip_slots[slot_id])
    @equips[slot_id].object = item
    refresh
  end
  
  #-----------------------------------------------------------------------------
  # Overwrite. etype ID's is an array
  #-----------------------------------------------------------------------------
  def release_unequippable_items(item_gain = true)
    loop do
      last_equips = equips.dup
      @equips.each_with_index do |item, i|
        if !equippable?(item.object) || !item.object.etype_ids.include?(equip_slots[i])
          trade_item_with_party(nil, item.object) if item_gain
          item.object = nil
        end
      end
      return if equips == last_equips
    end
  end
end

class Window_EquipItem
  def include?(item)
    return true if item == nil
    return false unless item.is_a?(RPG::EquipItem)
    return false if @slot_id < 0
    return false unless @actor && item.etype_ids.include?(@actor.equip_slots[@slot_id])
    return @actor.equippable?(item)
  end
end