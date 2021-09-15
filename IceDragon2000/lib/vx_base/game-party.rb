#encoding:UTF-8
# Game_Party
#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  This class handles the party. It includes information on amount of gold 
# and items. The instance of this class is referenced by $game_party.
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  MAX_MEMBERS = 4                         # Maximum number of party members
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :gold                     # amount of gold
  attr_reader   :steps                    # number of steps
  attr_accessor :last_item_id             # for cursor memory: Item
  attr_accessor :last_actor_index         # for cursor memory: Actor
  attr_accessor :last_target_index        # for cursor memory: Target
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super
    @gold = 0
    @steps = 0
    @last_item_id = 0
    @last_actor_index = 0
    @last_target_index = 0
    @actors = []      # Party member (actor ID)
    @items = {}       # Inventory item hash (item ID)
    @weapons = {}     # Inventory item hash (weapon ID)
    @armors = {}      # Inventory item hash (armor ID)
  end
  #--------------------------------------------------------------------------
  # * Get Members
  #--------------------------------------------------------------------------
  def members
    result = []
    for i in @actors
      result.push($game_actors[i])
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Get Item Object Array (including weapons and armor)
  #--------------------------------------------------------------------------
  def items
    result = []
    for i in @items.keys.sort
      result.push($data_items[i]) if @items[i] > 0
    end
    for i in @weapons.keys.sort
      result.push($data_weapons[i]) if @weapons[i] > 0
    end
    for i in @armors.keys.sort
      result.push($data_armors[i]) if @armors[i] > 0
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Initial Party Setup
  #--------------------------------------------------------------------------
  def setup_starting_members
    @actors = []
    for i in $data_system.party_members
      @actors.push(i)
    end
  end
  #--------------------------------------------------------------------------
  # * Get Party Name
  #    If there is only one, returns the actor's name. If there are more,
  #    returns "XX's Party".
  #--------------------------------------------------------------------------
  def name
    if @actors.size == 0
      return ''
    elsif @actors.size == 1
      return members[0].name
    else
      return sprintf(Vocab::PartyName, members[0].name)
    end
  end
  #--------------------------------------------------------------------------
  # * Battle Test Party Setup
  #--------------------------------------------------------------------------
  def setup_battle_test_members
    @actors = []
    for battler in $data_system.test_battlers
      actor = $game_actors[battler.actor_id]
      actor.change_level(battler.level, false)
      actor.change_equip_by_id(0, battler.weapon_id, true)
      actor.change_equip_by_id(1, battler.armor1_id, true)
      actor.change_equip_by_id(2, battler.armor2_id, true)
      actor.change_equip_by_id(3, battler.armor3_id, true)
      actor.change_equip_by_id(4, battler.armor4_id, true)
      actor.recover_all
      @actors.push(actor.id)
    end
    @items = {}
    for i in 1...$data_items.size
      if $data_items[i].battle_ok?
        @items[i] = 99 unless $data_items[i].name.empty?
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Get Maximum Level
  #--------------------------------------------------------------------------
  def max_level
    level = 0
    for i in @actors
      actor = $game_actors[i]
      level = actor.level if level < actor.level
    end
    return level
  end
  #--------------------------------------------------------------------------
  # * Add an Actor
  #     actor_id : actor ID
  #--------------------------------------------------------------------------
  def add_actor(actor_id)
    if @actors.size < MAX_MEMBERS and not @actors.include?(actor_id)
      @actors.push(actor_id)
      $game_player.refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Remove Actor
  #     actor_id : actor ID
  #--------------------------------------------------------------------------
  def remove_actor(actor_id)
    @actors.delete(actor_id)
    $game_player.refresh
  end
  #--------------------------------------------------------------------------
  # * Gain Gold (or lose)
  #     n : amount of gold
  #--------------------------------------------------------------------------
  def gain_gold(n)
    @gold = [[@gold + n, 0].max, 9999999].min
  end
  #--------------------------------------------------------------------------
  # * Lose Gold
  #     n : amount of gold
  #--------------------------------------------------------------------------
  def lose_gold(n)
    gain_gold(-n)
  end
  #--------------------------------------------------------------------------
  # * Increase Steps
  #--------------------------------------------------------------------------
  def increase_steps
    @steps += 1
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items Possessed
  #     item : item
  #--------------------------------------------------------------------------
  def item_number(item)
    case item
    when RPG::Item
      number = @items[item.id]
    when RPG::Weapon
      number = @weapons[item.id]
    when RPG::Armor
      number = @armors[item.id]
    end
    return number == nil ? 0 : number
  end
  #--------------------------------------------------------------------------
  # * Determine Item Possession Status
  #     item          : Item
  #     include_equip : Include equipped items
  #--------------------------------------------------------------------------
  def has_item?(item, include_equip = false)
    if item_number(item) > 0
      return true
    end
    if include_equip
      for actor in members
        return true if actor.equips.include?(item)
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Gain Items (or lose)
  #     item          : Item
  #     n             : Number
  #     include_equip : Include equipped items
  #--------------------------------------------------------------------------
  def gain_item(item, n, include_equip = false)
    number = item_number(item)
    case item
    when RPG::Item
      @items[item.id] = [[number + n, 0].max, 99].min
    when RPG::Weapon
      @weapons[item.id] = [[number + n, 0].max, 99].min
    when RPG::Armor
      @armors[item.id] = [[number + n, 0].max, 99].min
    end
    n += number
    if include_equip and n < 0
      for actor in members
        while n < 0 and actor.equips.include?(item)
          actor.discard_equip(item)
          n += 1
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Lose Items
  #     item          : Item
  #     n             : Number
  #     include_equip : Include equipped items
  #--------------------------------------------------------------------------
  def lose_item(item, n, include_equip = false)
    gain_item(item, -n, include_equip)
  end
  #--------------------------------------------------------------------------
  # * Consume Items
  #     item : item
  #    If the specified object is a consumable item, the number in investory
  #    will be reduced by 1.
  #--------------------------------------------------------------------------
  def consume_item(item)
    if item.is_a?(RPG::Item) and item.consumable
      lose_item(item, 1)
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Item is Usable
  #     item : item
  #--------------------------------------------------------------------------
  def item_can_use?(item)
    return false unless item.is_a?(RPG::Item)
    return false if item_number(item) == 0
    if $game_temp.in_battle
      return item.battle_ok?
    else
      return item.menu_ok?
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Command is Inputable
  #    Automatic battle is handled as inputable.
  #--------------------------------------------------------------------------
  def inputable?
    for actor in members
      return true if actor.inputable?
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Determine Everyone is Dead
  #--------------------------------------------------------------------------
  def all_dead?
    if @actors.size == 0 and not $game_temp.in_battle
      return false 
    end
    return existing_members.empty?
  end
  #--------------------------------------------------------------------------
  # * Processing Performed When Player Takes 1 Step
  #--------------------------------------------------------------------------
  def on_player_walk
    for actor in members
      if actor.slip_damage?
        actor.hp -= 1 if actor.hp > 1   # Poison damage
        $game_map.screen.start_flash(Color.new(255,0,0,64), 4)
      end
      if actor.auto_hp_recover and actor.hp > 0
        actor.hp += 1                   # HP auto recovery
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Perform Automatic Recovery (called at end of turn)
  #--------------------------------------------------------------------------
  def do_auto_recovery
    for actor in members
      actor.do_auto_recovery
    end
  end
  #--------------------------------------------------------------------------
  # * Remove Battle States (called when battle ends)
  #--------------------------------------------------------------------------
  def remove_states_battle
    for actor in members
      actor.remove_states_battle
    end
  end
end
