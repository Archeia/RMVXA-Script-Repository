=begin
#===============================================================================
 Title: Actor Inventory
 Author: Hime
 Date: Sep 16, 2015
--------------------------------------------------------------------------------
 ** Change log
 Sep 16, 2015
   - fixed bug where optimize equips were still being pulled from the party
 Jul 30, 2014
   - item_number is pulled from the leader instead of the party
 Mar 19, 2014
   - fixed bug where checking if item is inventory always returns true
 Mar 8, 2014
   - updated conflicting inventory method names
 Jul 27, 2013
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
 
 This script changes the inventory system from a party-based inventory to
 an actor-based inventory. Each actor now has its own inventory. The
 inventories are preserved even if you remove an actor from the party and then
 add them later.
 
 By default, any "gain item" or "remove item" calls will remove items from
 the party leader. You will need to use script calls to add items to other
 members.
 
 This script does not provide any scenes or windows so you will need to
 install other scripts that will provide those. This script also does not
 provide a way to exchange items between actors.
 
--------------------------------------------------------------------------------
 ** Required
 
 Core - Inventory
 (http://himeworks.com/2013/07/27/core-inventory/)
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Core - Inventory and above Main
 All custom menus should be placed below the actor inventory scenes.

--------------------------------------------------------------------------------
 ** Usage 
 
 The following script calls are available:
 
   gain_weapon(id, amount, actor_id)
   gain_armor(id, amount, actor_id)
   gain_item(id, amount, actor_id)
   lose_weapon(id, amount, actor_id)
   lose_armor(id, amount, actor_id)
   lose_item(id, amount, actor_id)

 Where `id` is the database ID of the object you want to add/remove, `amount`
 is the amount of you want to add/remove, and `actor_id` is the actor that you
 want to add to or remove from.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_ActorInventory"] = true
#===============================================================================
# ** Rest of script
#===============================================================================
class Game_ActorInventory < Game_Inventory
  
  def initialize(actor)
    super()
    @actor = actor
  end
  
  def actor
    @actor
  end
  
  def has_item?(item, include_equip = false)
    return true if super(item)
    return include_equip ? actor_equip_include?(item) : false
  end
  
  def gain_item(item, amount, include_equip = false)
    super(item, amount, include_equip)
    last_number = item_number(item)
    new_number = last_number + amount
    if include_equip && new_number < 0
      discard_actor_equip(item, -new_number)
    end
    $game_map.need_refresh = true
  end
  
  def actor_equip_include?(item)
    actor.equips.include?(item)
  end
  
  def discard_actor_equip(item, amount)
    actor.discard_equip(item)
  end
end

class Game_Actor < Game_Battler
  
  attr_reader :last_item
  
  alias :th_actor_inventory_initialize :initialize
  def initialize(actor_id)
    @inventory = Game_ActorInventory.new(self)
    @last_item = Game_BaseItem.new
    th_actor_inventory_initialize(actor_id)
  end
  
  def inventory_items
    @inventory.items
  end
  
  def inventory_weapons
    @inventory.weapons
  end
  
  def inventory_armors
    @inventory.armors
  end
  
  def equip_items
    inventory_weapons + inventory_armors
  end

  def all_items
    inventory_items + equip_items
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
  
  def gain_item(item, amount, include_equip = false)
    @inventory.gain_item(item, amount, include_equip)
  end
  
  def lose_item(item, amount, include_equip = false)
    gain_item(item, -amount, include_equip)
  end
  
  #-----------------------------------------------------------------------------
  # Replaced. Just move to actor's own inventory
  #-----------------------------------------------------------------------------
  def trade_item_with_party(new_item, old_item)
    return false if new_item && !$game_party.has_item?(new_item)
    gain_item(old_item, 1)
    lose_item(new_item, 1)
    return true
  end
  
  def consume_item(item)
    lose_item(item, 1) if item.is_a?(RPG::Item) && item.consumable
  end
  
  def item_conditions_met?(item)
    usable_item_conditions_met?(item) && has_item?(item)
  end
  
  #-----------------------------------------------------------------------------
  # Overwrite. Pull equips from the actor's inventory
  #-----------------------------------------------------------------------------
  def optimize_equipments
    clear_equipments
    equip_slots.size.times do |i|
      next if !equip_change_ok?(i)
      items = self.equip_items.select do |item|
        item.etype_id == equip_slots[i] &&
        equippable?(item) && item.performance >= 0
      end
      change_equip(i, items.max_by {|item| item.performance })
    end
  end
end

class Game_Party < Game_Unit
  
  #-----------------------------------------------------------------------------
  # Replaced. Check if any members have the item
  #-----------------------------------------------------------------------------
  def has_item?(item, include_equip = false)
    members.any? do |actor|
      actor.has_item?(item, include_equip)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Replaced. Check if any members have the item
  #-----------------------------------------------------------------------------
  def item_number(*args)
    leader.item_number(*args)
  end
  
  #-----------------------------------------------------------------------------
  # Replaced. Leader gets the item
  #-----------------------------------------------------------------------------
  def gain_item(item, amount, include_equip = false)
    leader.gain_item(item, amount, include_equip)
  end
end

class Game_Interpreter
  
  def gain_weapon(id, amount, actor_id, include_equip=false)
    $game_actors[actor_id].gain_item($data_weapons[id], amount, include_equip)
  end
  
  def gain_armor(id, amount, actor_id, include_equip=false)
    $game_actors[actor_id].gain_item($data_armors[id], amount, include_equip)
  end
  
  def gain_item(id, amount, actor_id, include_equip=false)
    $game_actors[actor_id].gain_item($data_items[id], amount, include_equip)
  end
  
  def lose_weapon(id, amount, actor_id, include_equip=false)
    gain_weapon(id, -amount, actor_id, include_equip)
  end
  
  def lose_armor(id, amount, actor_id, include_equip=false)
    gain_armor(id, -amount, actor_id, include_equip)
  end
  
  def lose_item(id, amount, actor_id, include_equip=false)
    gain_item(id, -amount, actor_id, include_equip)
  end
end

#===============================================================================
# Compatibility with SES - Instance Items
#===============================================================================
if $imported["SES - Instance Items"]  
  
  def new_item(item, type)
    newi = Marshal.load(Marshal.dump(item))
    newi.old_id = item.id
    newi.instanced = true
    newi.id = eval("$game_#{type}s.size")
    newi = process_new_item(newi)
    eval("$game_#{type}s.push(newi)
    $game_#{type}s[newi.id].vary unless type == :item
    return $game_#{type}s[newi.id]")
  end
  
  def process_new_item(item)
    return item
  end
  
  class Game_Actor < Game_Battler
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