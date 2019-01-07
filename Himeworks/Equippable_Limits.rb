=begin
#===============================================================================
 Title: Equippable Limits
 Author: Hime
 Date: Apr 12, 2013
--------------------------------------------------------------------------------
 ** Change log
 Apr 12
   - changed `equippable?` method to handle arbitrary arguments transparently
   - added support for limit by weapon/armor type
 Apr 11, 2013
   - addressed bug with equip optimizing. However, this excludes items that
     have excluded the limit from the list of equips
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
 
 This script allows you to limit how many instances of item any actor can equip
 at the same time. For example, if you have three accessory slots, you might
 disallow equipping more than one exp bonus accessory at any given time.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 Note-tag equips with
 
    <equippable limit: x>
    
 An actor cannot equip more than x instances of those equips.
 You can also specify limits based on weapon type
 
    <equippable limit: x type>
    
 This means that, for example, if you tag this on an axe, then you can only
 equip x axes at the same time.
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_EquippableLimits"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Equippable_Limits
    
    Regex = /<equippable limit:\s*(\d+)\s*(\w+)?>/i
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  class EquipItem < BaseItem
    def equippable_limit
      return @equippable_limit unless @equippable_limit.nil?
      load_notetag_equippable_limit
      return @equippable_limit
    end
    
    def equippable_limit_type
      return @equippable_limit_type unless @equippable_limit_type.nil?
      load_notetag_equippable_limit
      return @equippable_limit_type
    end
    
    def load_notetag_equippable_limit
      @equippable_limit = 9999
      @equippable_limit_type = :id
      res = self.note.match(TH::Equippable_Limits::Regex)
      if res
        @equippable_limit = res[1].to_i
        @equippable_limit_type = res[2].to_sym if res[2]
      end
    end
  end
end

class Game_Actor < Game_Battler
  
  #-----------------------------------------------------------------------------
  # New. Returns whether the actor has exceeded the limit on how many instances
  # of that item can be equipped. Note that the release checking method will
  # remove the equip when it is unequippable and includes the current
  # equips in the count, so we increase the limit by 1
  #-----------------------------------------------------------------------------
  def equippable_limit_ok?(item)
    return true if item.nil?
    limit = @is_release_check ? item.equippable_limit + 1 : item.equippable_limit
    case item.equippable_limit_type
    when :id
      return equips.count(item) < limit
    when :type
      if item.is_a?(RPG::Weapon)
        p equips.count {|eq| eq.is_a?(RPG::Weapon) && eq.wtype_id == item.wtype_id}
        return equips.count {|eq| eq.is_a?(RPG::Weapon) && eq.wtype_id == item.wtype_id} < limit
      elsif item.is_a?(RPG::Armor)
        return equips.count {|eq| eq.is_a?(RPG::Armor) && eq.atype_id == item.atype_id } < limit
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # For various equip tests such as optimization. The first argument is
  # an RPG weapon/armor object.
  #-----------------------------------------------------------------------------
  alias :th_equippable_limits_equippable? :equippable?
  def equippable?(*args)
    return false unless equippable_limit_ok?(args[0])
    th_equippable_limits_equippable?(*args)
  end
  
  #-----------------------------------------------------------------------------
  # Test equip limit before changing equip
  #-----------------------------------------------------------------------------
  alias :th_equippable_limits_change_equip :change_equip
  def change_equip(slot_id, item)
    return unless equippable_limit_ok?(item)
    th_equippable_limits_change_equip(slot_id, item)
  end
  
  alias :th_equippable_limits_release_unequippable_items :release_unequippable_items
  def release_unequippable_items(item_gain = true)
    @is_release_check = true
    th_equippable_limits_release_unequippable_items(item_gain)
    @is_release_check = false
  end
end