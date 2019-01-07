=begin
#===============================================================================
 Title: Custom Equip Types
 Author: Hime
 Date: Jul 25, 2013
--------------------------------------------------------------------------------
 ** Change log
 Jul 25, 2013
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
 
 This script allows you to create custom equip types with their own equip
 slot names. You can then assign custom equip types to different items.

--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 In the configuration section, set up the Equip_Types table with the custom
 equip types. Each equip type is given a unique number and a name.
 
 To assign a custom equip type to an item, note-tag it with
 
   <equip type: x>

 Where x is one of the equip type ID's that you have set up in the table.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_CustomEquipTypes"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Custom_Equip_Types
    
    # Set up your equip types here.
    # Format: etypeID => name
    Equip_Types = {
      
      #-Default Equips Types----------------------------------------------------
      0 => "Weapon",
      1 => "Shield",
      2 => "Headgear",
      3 => "Bodygear",      
      4 => "Accessory",
      #-Custom Equips Types-----------------------------------------------------
      5 => "Gloves",
      6 => "Boots",
      7 => "Hands"
    }
#===============================================================================
# ** Rest of script
#===============================================================================
    Regex = /<equip[-_ ]type:\s*(\d+)/i
  end
end

module RPG
  class EquipItem < BaseItem
    
    alias :th_custom_equip_types_etype_id :etype_id
    def etype_id
      load_notetag_custom_equip_type unless @custom_etype_checked
      th_custom_equip_types_etype_id
    end
    
    def load_notetag_custom_equip_type
      @custom_etype_checked = true
      res = self.note.match(TH::Custom_Equip_Types::Regex)
      @etype_id = res[1].to_i if res
    end
  end
end

module Vocab
  def self.etype(etype_id)
    TH::Custom_Equip_Types::Equip_Types[etype_id]
  end
end