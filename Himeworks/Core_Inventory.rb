=begin
#===============================================================================
 Title: Core - Inventory
 Author: Tsukihime
 Date: Mar 8, 2014
--------------------------------------------------------------------------------
 ** Change log
 Mar 8, 2014
   - inventory "gain_item" method conforms to existing interface
 Jul 27, 2013
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Tsukihime in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script provides core functionality for tracking and managing inventory.
 It provides a separate Inventory object modeled after the default party's
 inventory. This allows you to easily add inventories to other objects as well.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 Plug and play.
 For developers.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_CoreInventory"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Core_Inventory
    
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================

#-------------------------------------------------------------------------------
# An inventory object. Handles all inventory related functionality such as
# tracking inventory and managing transactions
#-------------------------------------------------------------------------------
class Game_Inventory

  def initialize
    init_all_items
  end
  
  def init_all_items
    @items = {}
    @weapons = {}
    @armors = {}
  end
  
  def items
    @items.keys.sort.collect {|id| $data_items[id] }
  end
  
  def weapons
    @weapons.keys.sort.collect {|id| $data_weapons[id] }
  end
  
  def armors
    @armors.keys.sort.collect {|id| $data_armors[id] }
  end
  
  def item_container(item_class)
    return @items   if item_class == RPG::Item
    return @weapons if item_class == RPG::Weapon
    return @armors  if item_class == RPG::Armor
    return nil
  end
  
  def item_number(item)
    container = item_container(item.class)
    container ? container[item.id] || 0 : 0
  end
  
  def max_item_number(item)
    return item_stack_size(item)
  end
  
  def item_stack_size(item)
    99
  end
  
  def has_item?(item)
    return true if item_number(item) > 0
  end
  
  def item_max?(item)
    item_number(item) >= max_item_number(item)
  end
  
  def gain_item(item, amount, include_equip=false)
    container = item_container(item.class)
    return unless container
    last_number = item_number(item)
    new_number = last_number + amount
    container[item.id] = [[new_number, 0].max, max_item_number(item)].min
    container.delete(item.id) if container[item.id] == 0
    $game_map.need_refresh = true
  end
end

#-------------------------------------------------------------------------------
# For backwards-compatibility
#-------------------------------------------------------------------------------
class Game_PartyInventory < Game_Inventory
  
  def members_equip_include?(item)
    $game_party.members.any? {|actor| actor.equips.include?(item) }
  end
  
  def has_item?(item, include_equip = false)
    return true if super(item)
    return include_equip ? members_equip_include?(item) : false
  end
  
  def gain_item(item, amount, include_equip = false)
    super(item, amount, include_equip)
    last_number = item_number(item)
    new_number = last_number + amount
    if include_equip && new_number < 0
      discard_members_equip(item, -new_number)
    end
    $game_map.need_refresh = true
  end
  
  def discard_members_equip(item, amount)
    n = amount
    $game_party.members.each do |actor|
      while n > 0 && actor.equips.include?(item)
        actor.discard_equip(item)
        n -= 1
      end
    end
  end
end

#-------------------------------------------------------------------------------
# All inventory related methods are delegated to the inventory object
#-------------------------------------------------------------------------------
class Game_Party < Game_Unit

  alias :th_core_inventory_initialize :initialize
  def initialize
    @inventory = Game_PartyInventory.new
    th_core_inventory_initialize
  end
  
  def init_all_items
    @inventory.init_all_items
  end
  
  def items
    @inventory.items
  end
  
  def weapons
    @inventory.weapons
  end
  
  def armors
    @inventory.armors
  end
  
  def item_number(item)
    @inventory.item_number(item)
  end
  
  def max_item_number(item)
    @inventory.max_item_number(item)
  end
  
  def item_max?(item)
    @inventory.item_max?(item)
  end
  
  def has_item?(item, include_equip = false)
    @inventory.has_item?(item, include_equip)
  end
  
  alias :th_core_inventory_gain_item :gain_item
  def gain_item(item, amount, include_equip = false)
    @inventory.gain_item(item, amount, include_equip)
  end
end

#===============================================================================
# Compatibility with SES - Instance Items
#===============================================================================
if $imported["SES - Instance Items"]  
  class Game_Inventory
    [:items, :weapons, :armors].each do |i|
      define_method(i) do
        eval("@#{i}.keys.sort.collect { |id| $game_#{i}[id] }")
      end
    end
  end
  
  class Game_Party < Game_Unit
    def gain_item(*args)
      oitem = args[0] if !args[0].nil?
      args[1].times do
        item = oitem
        if item && item.unique
          args[0] = if item.is_a?(RPG::Weapon) then new_item(item, :weapon)
          elsif item.is_a?(RPG::Armor) then args[0] = new_item(item, :armor)
          elsif item.is_a?(RPG::Item) then args[0] = new_item(item, :item) end
          end
        @inventory.gain_item(args[0], 1)
      end
    end
    
    def lose_item(*args)
      args[1] *= -1
      @inventory.gain_item(*args)
    end
  end
end