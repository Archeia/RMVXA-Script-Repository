=begin
#===============================================================================
 Title: Equip Slot Sealing
 Author: Hime
 Date: Nov 18, 2014
--------------------------------------------------------------------------------
 ** Change log
 Nov 18, 2014
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
 
 This script allows you to use note-tags to seal your equip slots. When you
 seal an equip slot, you cannot place an equip in that slot, and any equips
 that are already in the slot will be removed.

 By default, you can seal equip slots by equip type using features, but they
 only allow you to seal the default equip types:
 
   - Weapon
   - Shield
   - Bodygear
   - Headgear
   - Accessory

 If your game had custom equip types, you would need another solution to seal
 those slots.

--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 To seal equip slots by equip type, use the note-tag
 
   <seal etype: x>
   
 Where `x` is the equip type ID that you want to seal.
 You can note-tag any objects that support features, such as
 
   - actors
   - classes
   - weapons
   - armors
   - states

--------------------------------------------------------------------------------
 ** Example
 
 Suppose "Weapon" was equip type 0, and you wanted to seal all weapon
 equip slots, then you would say
 
   <seal etype: 0>
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_EquipSlotSealing] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Equip_Slot_Sealing
    
    Regex = /<seal[-_ ]etype:\s*(\d+)\s*>/i
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  class BaseItem
    
    alias :th_equip_slot_sealing_features :features
    def features
      load_notetag_equip_slot_sealing unless @equip_slot_sealing_checked
      th_equip_slot_sealing_features
    end
    
    def load_notetag_equip_slot_sealing
      @equip_slot_sealing_checked = true
      results = self.note.scan(TH::Equip_Slot_Sealing::Regex)
      results.each do |res|
        id = res[0].to_i
        ft = RPG::BaseItem::Feature.new(54, id)
        @features << ft
      end      
    end
  end
end