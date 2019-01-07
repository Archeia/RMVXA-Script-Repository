=begin
#===============================================================================
 Title: Item Stack Size
 Author: Hime
 Date: May 4, 2014
--------------------------------------------------------------------------------
 ** Change log
 May 4, 2014
   - refactored max item number
 Nov 1, 2013
   - compatibility with Core: Inventory
 Nov 25, 2012
   - initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Preserve this header
--------------------------------------------------------------------------------
  ** Description
  
 This script allows you to set the "stack" size for an item. By default,
 you can only have 99 instances of an item per stack. You can now set the
 stack size higher or lower than 99. For example, maybe you can only carry
 10 potions at a time.

--------------------------------------------------------------------------------
  ** Installation
  
  In the script editor, place this script below Materials and above Main
 
--------------------------------------------------------------------------------
  ** Usage
  
 Tag items, weapons, armors with

   <stack_size: n>
   
 Where n is some integer
--------------------------------------------------------------------------------
  ** Compatibility
  
  This script replaces one method
    Game_Party#max_item_number
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["Tsuki_StackSize"] = true
#==============================================================================
# ** Configuration
#==============================================================================
module Tsuki
  module Stack_Size
    
    # Default stack sizes for each type of item
    Item_Stack_Size   = 500
    Weapon_Stack_Size = 99
    Armor_Stack_Size  = 99
    
    Regex = /<stack[-_ ]size:?\s*(\d+)\s*/i
  end
end
#==============================================================================
# ** Rest of the script
#==============================================================================

module RPG
  
  # Stack size for items
  class Item < UsableItem
    def stack_size
      return @stack_limit unless @stack_limit.nil?
      res = self.note.match(Tsuki::Stack_Size::Regex)
      return @stack_limit = res ? res[1].to_i : Tsuki::Stack_Size::Item_Stack_Size
    end
  end
  
  # Stack size for equips
  class EquipItem < BaseItem
    def stack_size
      return @stack_limit unless @stack_limit.nil?
      res = self.note.match(Tsuki::Stack_Size::Regex)
      return @stack_limit = res ? res[1].to_i : default_stack_size
    end
  end
  
  class Weapon < EquipItem
    
    # Weapon default stack size
    def default_stack_size
      Tsuki::Stack_Size::Weapon_Stack_Size
    end
  end
  
  class Armor < EquipItem
    
    # Armor default stack size
    def default_stack_size
      Tsuki::Stack_Size::Armor_Stack_Size
    end
  end
end

class Game_Actor < Game_Battler
  
  # Can't remove if stack size exceeded
  alias :th_stack_size_trade_with_party :trade_item_with_party
  def trade_item_with_party(new_item, old_item)
    return false if old_item && $game_party.item_number(old_item) >= old_item.stack_size
    return th_stack_size_trade_with_party(new_item, old_item)
  end
end

class Game_Party < Game_Unit
  
  # Replaced. Change the stack limit based on the item's individual limits.
  def max_item_number(item)
    return item_stack_size(item)
  end
  
  def item_stack_size(item)
    item.stack_size
  end
end

#===============================================================================
# Compatibility with Core Inventory
#===============================================================================
if $imported["TH_CoreInventory"]
  class Game_Inventory
    def max_item_number(item)
      return item.stack_size
    end
  end
end