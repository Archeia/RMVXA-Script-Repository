=begin
#===============================================================================
 Title: Equip Slot Fixing
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
 
 This script allows you to use note-tags to fix your equip slots. When you fix
 an equip to a slot, you cannot change the equip manually. This allows you to
 effectively prevent the player from changing certain equips.

 By default, you can fix equip slots by equip type using features, but they only
 allow you to fix the default equip types:
 
   - Weapon
   - Shield
   - Bodygear
   - Headgear
   - Accessory

 If your game had custom equip types, you would need another solution to fix
 those slots.

--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 To fix equip slots by equip type, use the note-tag
 
   <fix etype: x>
   
 Where `x` is the equip type ID that you want to fix.
 You can note-tag any objects that support features, such as
 
   - actors
   - classes
   - weapons
   - armors
   - states

--------------------------------------------------------------------------------
 ** Example
 
 Suppose "Weapon" was equip type 0, and you wanted to fix all weapon
 equip slots, then you would say
 
   <fix etype: 0>
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_EquipSlotFixing] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Equip_Slot_Fixing
    
    Regex = /<fix[-_ ]etype:\s*(\d+)\s*>/i
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  class BaseItem
    
    alias :th_equip_slot_fixing_features :features
    def features
      load_notetag_equip_slot_fixing unless @equip_slot_fixing_checked
      th_equip_slot_fixing_features
    end
    
    def load_notetag_equip_slot_fixing
      @equip_slot_fixing_checked = true
      results = self.note.scan(TH::Equip_Slot_Fixing::Regex)
      results.each do |res|
        id = res[0].to_i
        ft = RPG::BaseItem::Feature.new(53, id)
        @features << ft
      end      
    end
  end
end