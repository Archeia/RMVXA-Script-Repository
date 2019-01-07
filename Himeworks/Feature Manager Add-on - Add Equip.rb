=begin
#==============================================================================
 ** Feature: Add Equip
 Author: Hime
 Date: Oct 11, 2012
------------------------------------------------------------------------------
 ** Change log
 Oct 11, 2012
   - initial release
------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Preserve this header
------------------------------------------------------------------------------
 ** Required
 -Feature Manager
------------------------------------------------------------------------------
 Allows actor to equip specific weapons or armors
 
 Tag object with
   <ft: equip_weapon equip_id>
   
   Where equip_id is of the form
      a123, if you can equip armor 123
      w456, if you can equip weapon 456
      
#==============================================================================
=end
$imported = {} if $imported.nil?
$imported["Feature_EquipWeapon"] = true
#==============================================================================
# ** Rest of the script
#==============================================================================
module Features
  module Add_Equip
    FeatureManager.register(:add_equip)
  end
end

class RPG::BaseItem
  
  def add_feature_add_equip(code, data_id, args)
    string = args[0]
    type = string[0].downcase
    value = string[1..-1].to_i
    data_id = type == "w" ? 0 : 1
    add_feature(code, data_id, value)
  end
end

class Game_BattlerBase
  
  # Returns whether we can equip the specific weapon
  alias :ft_equip_weapon_ok? :feature_equip_weapon_ok?
  def feature_equip_weapon_ok?(item)
    set = features_value_set_with_id(:add_equip, 1)
    return false if !(set.empty? || set.include?(item.id))
    return ft_equip_weapon_ok?(item)
  end
  
  # Returns whether we can equip the specific armor
  alias :ft_equip_armor_ok? :feature_equip_armor_ok?
  def feature_equip_armor_ok?(item)
    set = features_value_set_with_id(:add_equip, 1)
    return false if !(set.empty? || set.include?(item.id))
    return ft_equip_armor_ok?(item)
  end
end