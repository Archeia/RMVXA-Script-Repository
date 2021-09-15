#encoding:UTF-8
# Game_Party
#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  This class handles parties. Information such as gold and items is included.
# Instances of this class are referenced by $game_party.
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  ABILITY_ENCOUNTER_HALF    = 0           # halve encounters
  ABILITY_ENCOUNTER_NONE    = 1           # disable encounters
  ABILITY_CANCEL_SURPRISE   = 2           # disable surprise
  ABILITY_RAISE_PREEMPTIVE  = 3           # increase preemptive strike rate
  ABILITY_GOLD_DOUBLE       = 4           # double money earned
  ABILITY_DROP_ITEM_DOUBLE  = 5           # double item acquisition rate
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :gold                     # party's gold
  attr_reader   :steps                    # number of steps
  attr_reader   :last_item                # for cursor memorization:  item
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super
    @gold = 0
    @steps = 0
    @last_item = Game_BaseItem.new
    @menu_actor_id = 0
    @target_actor_id = 0
    @actors = []
    init_all_items
  end
  #--------------------------------------------------------------------------
  # * Initialize All Item Lists
  #--------------------------------------------------------------------------
  def init_all_items
    @items = {}
    @weapons = {}
    @armors = {}
  end
  #--------------------------------------------------------------------------
  # * Determine Existence
  #--------------------------------------------------------------------------
  def exists
    !@actors.empty?
  end
  #--------------------------------------------------------------------------
  # * Get Members
  #--------------------------------------------------------------------------
  def members
    in_battle ? battle_members : all_members
  end
  #--------------------------------------------------------------------------
  # * Get All Members
  #--------------------------------------------------------------------------
  def all_members
    @actors.collect {|id| $game_actors[id] }
  end
  #--------------------------------------------------------------------------
  # * Get Battle Members
  #--------------------------------------------------------------------------
  def battle_members
    all_members[0, max_battle_members].select {|actor| actor.exist? }
  end
  #--------------------------------------------------------------------------
  # * Get Maximum Number of Battle Members
  #--------------------------------------------------------------------------
  def max_battle_members
    return 4
  end
  #--------------------------------------------------------------------------
  # * Get Leader
  #--------------------------------------------------------------------------
  def leader
    battle_members[0]
  end
  #--------------------------------------------------------------------------
  # * Get Item Object Array 
  #--------------------------------------------------------------------------
  def items
    @items.keys.sort.collect {|id| $data_items[id] }
  end
  #--------------------------------------------------------------------------
  # * Get Weapon Object Array 
  #--------------------------------------------------------------------------
  def weapons
    @weapons.keys.sort.collect {|id| $data_weapons[id] }
  end
  #--------------------------------------------------------------------------
  # * Get Armor Object Array 
  #--------------------------------------------------------------------------
  def armors
    @armors.keys.sort.collect {|id| $data_armors[id] }
  end
  #--------------------------------------------------------------------------
  # * Get Array of All Equipment Objects
  #--------------------------------------------------------------------------
  def equip_items
    weapons + armors
  end
  #--------------------------------------------------------------------------
  # * Get Array of All Item Objects
  #--------------------------------------------------------------------------
  def all_items
    items + equip_items
  end
  #--------------------------------------------------------------------------
  # * Get Container Object Corresponding to Item Class
  #--------------------------------------------------------------------------
  def item_container(item_class)
    return @items   if item_class == RPG::Item
    return @weapons if item_class == RPG::Weapon
    return @armors  if item_class == RPG::Armor
    return nil
  end
  #--------------------------------------------------------------------------
  # * Initial Party Setup
  #--------------------------------------------------------------------------
  def setup_starting_members
    @actors = $data_system.party_members.clone
  end
  #--------------------------------------------------------------------------
  # * Get Party Name
  #    If there is only one, returns the actor's name.
  #    If there are more, returns "XX's Party".
  #--------------------------------------------------------------------------
  def name
    return ""           if battle_members.size == 0
    return leader.name  if battle_members.size == 1
    return sprintf(Vocab::PartyName, leader.name)
  end
  #--------------------------------------------------------------------------
  # * Set Up Battle Test
  #--------------------------------------------------------------------------
  def setup_battle_test
    setup_battle_test_members
    setup_battle_test_items
  end
  #--------------------------------------------------------------------------
  # * Battle Test Party Setup
  #--------------------------------------------------------------------------
  def setup_battle_test_members
    $data_system.test_battlers.each do |battler|
      actor = $game_actors[battler.actor_id]
      actor.change_level(battler.level, false)
      actor.init_equips(battler.equips)
      actor.recover_all
      add_actor(actor.id)
    end
  end
  #--------------------------------------------------------------------------
  # * Set Up Items for Battle Test
  #--------------------------------------------------------------------------
  def setup_battle_test_items
    $data_items.each do |item|
      gain_item(item, max_item_number(item)) if item && !item.name.empty?
    end
  end
  #--------------------------------------------------------------------------
  # * Get Highest Level of Party Members
  #--------------------------------------------------------------------------
  def highest_level
    lv = members.collect {|actor| actor.level }.max
  end
  #--------------------------------------------------------------------------
  # * Add an Actor
  #--------------------------------------------------------------------------
  def add_actor(actor_id)
    @actors.push(actor_id) unless @actors.include?(actor_id)
    $game_player.refresh
    $game_map.need_refresh = true
  end
  #--------------------------------------------------------------------------
  # * Remove Actor
  #--------------------------------------------------------------------------
  def remove_actor(actor_id)
    @actors.delete(actor_id)
    $game_player.refresh
    $game_map.need_refresh = true
  end
  #--------------------------------------------------------------------------
  # * Increase Gold
  #--------------------------------------------------------------------------
  def gain_gold(amount)
    @gold = [[@gold + amount, 0].max, max_gold].min
  end
  #--------------------------------------------------------------------------
  # * Decrease Gold
  #--------------------------------------------------------------------------
  def lose_gold(amount)
    gain_gold(-amount)
  end
  #--------------------------------------------------------------------------
  # * Get Maximum Value of Gold
  #--------------------------------------------------------------------------
  def max_gold
    return 99999999
  end
  #--------------------------------------------------------------------------
  # * Increase Steps
  #--------------------------------------------------------------------------
  def increase_steps
    @steps += 1
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items Possessed
  #--------------------------------------------------------------------------
  def item_number(item)
    container = item_container(item.class)
    container ? container[item.id] || 0 : 0
  end
  #--------------------------------------------------------------------------
  # * Get Maximum Number of Items Possessed
  #--------------------------------------------------------------------------
  def max_item_number(item)
    return 99
  end
  #--------------------------------------------------------------------------
  # * Determine if Maximum Number of Items Are Possessed
  #--------------------------------------------------------------------------
  def item_max?(item)
    item_number(item) >= max_item_number(item)
  end
  #--------------------------------------------------------------------------
  # * Determine Item Possession Status
  #     include_equip : Include equipped items
  #--------------------------------------------------------------------------
  def has_item?(item, include_equip = false)
    return true if item_number(item) > 0
    return include_equip ? members_equip_include?(item) : false
  end
  #--------------------------------------------------------------------------
  # * Determine if Specified Item Is Included in Members' Equipment
  #--------------------------------------------------------------------------
  def members_equip_include?(item)
    members.any? {|actor| actor.equips.include?(item) }
  end
  #--------------------------------------------------------------------------
  # * Increase/Decrease Items
  #     include_equip : Include equipped items
  #--------------------------------------------------------------------------
  def gain_item(item, amount, include_equip = false)
    container = item_container(item.class)
    return unless container
    last_number = item_number(item)
    new_number = last_number + amount
    container[item.id] = [[new_number, 0].max, max_item_number(item)].min
    container.delete(item.id) if container[item.id] == 0
    if include_equip && new_number < 0
      discard_members_equip(item, -new_number)
    end
    $game_map.need_refresh = true
  end
  #--------------------------------------------------------------------------
  # * Discard Members' Equipment
  #--------------------------------------------------------------------------
  def discard_members_equip(item, amount)
    n = amount
    members.each do |actor|
      while n > 0 && actor.equips.include?(item)
        actor.discard_equip(item)
        n -= 1
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Lose Items
  #     include_equip : Include equipped items
  #--------------------------------------------------------------------------
  def lose_item(item, amount, include_equip = false)
    gain_item(item, -amount, include_equip)
  end
  #--------------------------------------------------------------------------
  # * Consume Items
  #    If the specified object is a consumable item, the number in investory
  #    will be reduced by 1.
  #--------------------------------------------------------------------------
  def consume_item(item)
    lose_item(item, 1) if item.is_a?(RPG::Item) && item.consumable
  end
  #--------------------------------------------------------------------------
  # * Determine Skill/Item Usability
  #--------------------------------------------------------------------------
  def usable?(item)
    members.any? {|actor| actor.usable?(item) }
  end
  #--------------------------------------------------------------------------
  # * Determine Command Inputability During Battle
  #--------------------------------------------------------------------------
  def inputable?
    members.any? {|actor| actor.inputable? }
  end
  #--------------------------------------------------------------------------
  # * Determine if Everyone is Dead
  #--------------------------------------------------------------------------
  def all_dead?
    super && ($game_party.in_battle || members.size > 0)
  end
  #--------------------------------------------------------------------------
  # * Processing Performed When Player Takes 1 Step
  #--------------------------------------------------------------------------
  def on_player_walk
    members.each {|actor| actor.on_player_walk }
  end
  #--------------------------------------------------------------------------
  # * Get Actor Selected on Menu Screen
  #--------------------------------------------------------------------------
  def menu_actor
    $game_actors[@menu_actor_id] || members[0]
  end
  #--------------------------------------------------------------------------
  # * Set Actor Selected on Menu Screen
  #--------------------------------------------------------------------------
  def menu_actor=(actor)
    @menu_actor_id = actor.id
  end
  #--------------------------------------------------------------------------
  # * Select Next Actor on Menu Screen
  #--------------------------------------------------------------------------
  def menu_actor_next
    index = members.index(menu_actor) || -1
    index = (index + 1) % members.size
    self.menu_actor = members[index]
  end
  #--------------------------------------------------------------------------
  # * Select Previous Actor on Menu Screen
  #--------------------------------------------------------------------------
  def menu_actor_prev
    index = members.index(menu_actor) || 1
    index = (index + members.size - 1) % members.size
    self.menu_actor = members[index]
  end
  #--------------------------------------------------------------------------
  # * Get Actor Targeted by Skill/Item Use
  #--------------------------------------------------------------------------
  def target_actor
    $game_actors[@target_actor_id] || members[0]
  end
  #--------------------------------------------------------------------------
  # * Set Actor Targeted by Skill/Item Use
  #--------------------------------------------------------------------------
  def target_actor=(actor)
    @target_actor_id = actor.id
  end
  #--------------------------------------------------------------------------
  # * Change Order
  #--------------------------------------------------------------------------
  def swap_order(index1, index2)
    @actors[index1], @actors[index2] = @actors[index2], @actors[index1]
    $game_player.refresh
  end
  #--------------------------------------------------------------------------
  # * Character Image Information for Save File Display
  #--------------------------------------------------------------------------
  def characters_for_savefile
    battle_members.collect do |actor|
      [actor.character_name, actor.character_index]
    end
  end
  #--------------------------------------------------------------------------
  # * Determine Party Ability
  #--------------------------------------------------------------------------
  def party_ability(ability_id)
    battle_members.any? {|actor| actor.party_ability(ability_id) }
  end
  #--------------------------------------------------------------------------
  # * Halve Encounters?
  #--------------------------------------------------------------------------
  def encounter_half?
    party_ability(ABILITY_ENCOUNTER_HALF)
  end
  #--------------------------------------------------------------------------
  # * Disable Encounters?
  #--------------------------------------------------------------------------
  def encounter_none?
    party_ability(ABILITY_ENCOUNTER_NONE)
  end
  #--------------------------------------------------------------------------
  # * Disable Surprise?
  #--------------------------------------------------------------------------
  def cancel_surprise?
    party_ability(ABILITY_CANCEL_SURPRISE)
  end
  #--------------------------------------------------------------------------
  # * Increase Preemptive Strike Rate?
  #--------------------------------------------------------------------------
  def raise_preemptive?
    party_ability(ABILITY_RAISE_PREEMPTIVE)
  end
  #--------------------------------------------------------------------------
  # * Double Money Earned?
  #--------------------------------------------------------------------------
  def gold_double?
    party_ability(ABILITY_GOLD_DOUBLE)
  end
  #--------------------------------------------------------------------------
  # * Double Item Acquisition Rate?
  #--------------------------------------------------------------------------
  def drop_item_double?
    party_ability(ABILITY_DROP_ITEM_DOUBLE)
  end
  #--------------------------------------------------------------------------
  # * Calculate Probability of Preemptive Attack
  #--------------------------------------------------------------------------
  def rate_preemptive(troop_agi)
    (agi >= troop_agi ? 0.05 : 0.03) * (raise_preemptive? ? 4 : 1)
  end
  #--------------------------------------------------------------------------
  # * Calculate Probability of Surprise
  #--------------------------------------------------------------------------
  def rate_surprise(troop_agi)
    cancel_surprise? ? 0 : (agi >= troop_agi ? 0.03 : 0.05)
  end
end
