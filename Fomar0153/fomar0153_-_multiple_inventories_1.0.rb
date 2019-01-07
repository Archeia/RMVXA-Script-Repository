=begin
Multiple Inventories
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
Allows you to easily handle multiple inventories in game.
----------------------
Instructions
----------------------
The default inventory is called "Main" you can change it below
if you wish.
To change inventory call:
$game_party.change_inventory(name)
To merge two inventories call:
$game_party.merge_inventories(inv1, inv2)
inv1 will recieve all the gold and items in inv2
If ERASE_WHEN_MERGE is set to true then inv2 will be erased after
the merge.
----------------------
Known bugs
----------------------
None
=end
class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ● Set the name of your starting inventory here
  #--------------------------------------------------------------------------
  START_INVENTORY = "Main"
  #--------------------------------------------------------------------------
  # ● Set the name of your starting inventory here
  #--------------------------------------------------------------------------
  ERASE_WHEN_MERGE = true
  #--------------------------------------------------------------------------
  # ● Aliased 
  #--------------------------------------------------------------------------
  alias mi_initialize initialize
  def initialize
    mi_initialize
    @current_inventory = START_INVENTORY
    @gold = {}
    @gold[START_INVENTORY] = 0
    @last_item = Game_BaseItem.new
  end
  #--------------------------------------------------------------------------
  # ● New, example call $game_party.change_inventory(name)
  #--------------------------------------------------------------------------
  def change_inventory(name)
    if @gold[name].nil?
      @gold[name] = 0
      @items[name] = {}
      @weapons[name] = {}
      @armors[name] = {}
    end
    @current_inventory = name
  end
  #--------------------------------------------------------------------------
  # ● New, example call $game_party.merge_inventories(inv1, inv2)
  #--------------------------------------------------------------------------
  def merge_inventories(inv1, inv2)
    return if @gold[inv1].nil? or @gold[inv2].nil?
    @current_inventory = inv1
    @gold[inv1] += @gold[inv2]
    @gold[inv2] = nil if ERASE_WHEN_MERGE
    for item in @items[inv2].keys
      gain_item($data_items[item.to_i], @items[inv2][item])
    end
    @items[inv2] = nil if ERASE_WHEN_MERGE
    for weapon in @weapons[inv2].keys
      gain_item($data_weapons[weapon.to_i], @weapons[inv2][weapon])
    end
    @weapons[inv2] = nil if ERASE_WHEN_MERGE
    for armor in @armors[inv2].keys
      gain_item($data_armors[armor.to_i], @armors[inv2][armor])
    end
    @armors[inv2] = nil if ERASE_WHEN_MERGE
  end
  #--------------------------------------------------------------------------
  # ● Aliased
  #--------------------------------------------------------------------------
  alias mi_init_all_items init_all_items
  def init_all_items
    mi_init_all_items
    @items[START_INVENTORY] = {}
    @weapons[START_INVENTORY] = {}
    @armors[START_INVENTORY] = {}
  end
  #--------------------------------------------------------------------------
  # ● New
  #--------------------------------------------------------------------------
  def gold
    return @gold[START_INVENTORY]
  end
  #--------------------------------------------------------------------------
  # ● Rewrites 
  #--------------------------------------------------------------------------
  def items
    @items[@current_inventory].keys.sort.collect {|id| $data_items[id] }
  end
  #--------------------------------------------------------------------------
  # ● Rewrites 
  #--------------------------------------------------------------------------
  def weapons
    @weapons[@current_inventory].keys.sort.collect {|id| $data_weapons[id] }
  end
  #--------------------------------------------------------------------------
  # ● Rewrites 
  #--------------------------------------------------------------------------
  def armors
    @armors[@current_inventory].keys.sort.collect {|id| $data_armors[id] }
  end
  #--------------------------------------------------------------------------
  # ● Rewrites
  #--------------------------------------------------------------------------
  def item_container(item_class)
    return @items[@current_inventory]   if item_class == RPG::Item
    return @weapons[@current_inventory] if item_class == RPG::Weapon
    return @armors[@current_inventory]  if item_class == RPG::Armor
    return nil
  end
  #--------------------------------------------------------------------------
  # ● Rewrites
  #--------------------------------------------------------------------------
  def gain_gold(amount)
    @gold[@current_inventory] = [[@gold[@current_inventory] + amount, 0].max, max_gold].min
  end
end