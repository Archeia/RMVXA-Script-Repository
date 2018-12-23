#==============================================================================
#    Instance Items Base [VXA]
#    Version: 1.0.0
#    Author: modern algebra (rmrk.net)
#    Date: 26 December 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This script changes the item system in RMVX Ace to accomodate for items 
#   of the same ID to have different stats. It can thereby serve as a base for
#   scripts that require such functionality, such as durability for weapons and
#   armors, charges for items, weapons that level up, socketing, etc...
#
#    This script does none of that by default - it only sets up data structures
#   to permit that, and its only independent use is that you can manually 
#   change the stats on an item added to the party through events.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    Insert this script into its own slot in the Script Editor, above Main but
#   below Materials. This script must also be above every script that requires
#   it.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions for Scripters:
#
#    If you are a scripter and want to write a script that requires this script
#   in order to be used, you have my permission. I ask only that you link back
#   to this script at RMRK, as well as provide me with a link to your script so
#   that I can ensure compatibility.
#
#    I have tried to comment the script where there might be some confusion,
#   so you should be able to read through it to gain an understanding as to
#   how it works. For the most part, it is designed to mimic as much as
#   possible the default arrangement. So, if you access the first 999 indices
#   of $data_items, $data_weapons, or $data_armors, you will receive the basic
#   classes for those. New instances begin at ID 1000, and each new instance
#   will have a unique ID, which is what is returned when you call the #id
#   method. Instances will also have a #database_id method which returns the 
#   ID of its base item. Instance items are now of the Game_IItem, Game_IWeapon,
#   or Game_IArmor. Game_IItem inherits its methods from the module 
#   Game_IUsableItem, and the others inherit from the module Game_IEquipItem.
#   Both Game_IEquipItem and Game_IUsableItem inherit from Game_IBaseItem.
#
#    If you need to add a new notefield tag, it is recommended you also add it
#   to MA_INSTANCE_ITEMS_BASE[:regexp_array], as any regular expressions
#   included in that array will make the #instance_based? method in
#   RPG::BaseItem return true if the item has that in its note field.
#
#    Beyond that, I recommend you read the entire script in order to gain an
#   understanding of how it works. 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Support:
#
#    If you have any questions, feel free to ask them in the script's topic:
#
#        http://rmrk.net/index.php/topic,47427.0.html
#
#   I will try to answer as swiftly as possible. If you believe further 
#  documentation is required, please let me know.
#==============================================================================

$imported = {} unless $imported
$imported[:"MA_InstanceItemsBase 1.0.0"] = true

MA_INSTANCE_ITEMS_BASE = {
  #  This sets the first index used for instance items. It should be 1000 
  # unless you are using another script which makes extends the database
  # limitations beyond 999.
  :index_start => 1000,
  #  This array tracks the note field codes which identify that an item should
  # be created as new instances.
  :regexp_array => [/\\INS/i],
  #  This array holds methods which you would never want to distinguish between
  # instances
  :ignore_accessors => [],
}

#==============================================================================
# ** MAIIB_RPG_BaseItem
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This mixes in to RPG::Item, RPG::Weapon, and RPG::Armor, adding the
#  following methods: 
#    overwritten method - ==
#    new methods - instance_based?; database_id
#==============================================================================

module MAIIB_RPG_BaseItem
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Instance Based?
  #    This is true if the item is identified as instance-based.
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def instance_based?
    @ins_based = MA_INSTANCE_ITEMS_BASE[:regexp_array].any? { |regexp| 
      !self.note[regexp].nil? } unless @ins_based
    @ins_based
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Data ID
  #    Essentially just aliases #id, but in case any other script overwrites 
  #   or aliases #id, I made it so it just calls it
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def database_id(*args, &block)
    id(*args, &block)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Equality?
  #    Also returns true if other is an instance item with same data.
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def ==(other)
    super(other) || (other.is_a?(Game_BaseInstanceItem) && super(other.data))
  end
end

# MAIIB_RPG_UsableItem and MAIIB_RPG_EquipItem both inherit MAIIB_RPG_BaseItem
module MAIIB_RPG_UsableItem; include MAIIB_RPG_BaseItem; end
module MAIIB_RPG_EquipItem;  include MAIIB_RPG_BaseItem; end


module RPG
  class Item;   include MAIIB_RPG_UsableItem; end
  class Weapon; include MAIIB_RPG_EquipItem;  end
  class Armor;  include MAIIB_RPG_EquipItem;  end
end

#==============================================================================
# *** DataManager
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  These modifications preserve the 
#``````````````````````````````````````````````````````````````````````````````
#  Summary of Changes:
#    aliased methods - init; extract_save_contents; create_game_objects
#    new method - maiib_preserve_old_saves; set_data_to_instance_items
#==============================================================================

class << DataManager
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Initialize
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maiib_inz_2tg6 init
  def init(*args, &block)
    Game_BaseInstanceItem.init_auto_accessors # Initialize automatic
    maiib_inz_2tg6(*args, &block)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Extract Save Contents
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maiib_extractsave_2jw6 extract_save_contents
  def extract_save_contents(contents, *args, &block)
    maiib_extractsave_2jw6(contents, *args, &block) # Call Original Methods
    maiib_preserve_old_saves
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Game Objects
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maiib_creatgameobj_4hi8 create_game_objects
  def create_game_objects(*args, &block)
    maiib_creatgameobj_4hi8(*args, &block) # Call Original Method
    set_data_to_instance_items
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Preserve Save Contents
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maiib_preserve_old_saves
    $game_system.init_maiib_data unless $game_system.instance_items
    set_data_to_instance_items
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Data Instance Items
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def set_data_to_instance_items
    $game_system.instance_items[:item].reset_data_array($data_items)
    $game_system.instance_items[:weapon].reset_data_array($data_weapons)
    $game_system.instance_items[:armor].reset_data_array($data_armors)
    $data_items = $game_system.instance_items[:item]
    $data_weapons = $game_system.instance_items[:weapon]
    $data_armors = $game_system.instance_items[:armor]
  end
end

#==============================================================================
# ** Game_BaseInstanceItem
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This class holds an instance of an Item, Weapon, or Armor
#==============================================================================

module Game_BaseInstanceItem
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_writer   :id
  attr_accessor :data_type
  attr_accessor :database_id
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize(id, data_type, database_id)
    @id = id
    @data_type = data_type
    @database_id = database_id
    self.class.auto_accessors.each { |method|
      instance_variable_set(:"@#{method}", Marshal.load(Marshal.dump(data.send(method))))
    }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get ID
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def id
    ($game_system && $game_system.retrieve_database_id) ? database_id : @id
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Data
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def data
    case data_type
    when :item   then $data_items[database_id]
    when :weapon then $data_weapons[database_id]
    when :armor  then $data_armors[database_id]
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Method Missing
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def method_missing(method, *args, &block)
    if method.to_s[/^(.*?[^=])=$/] && !MA_INSTANCE_ITEMS_BASE[:ignore_accessors].include?(method)
      instance_exec($1.to_sym) { |new_meth| 
        eval("def #{new_meth}=(val); @#{new_meth} = val; end;
              def #{new_meth}; @#{new_meth}; end")
      }
      send(method, *args, &block)
    else
      data ? data.send(method, *args, &block) : super(method, *args, &block)
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Equality?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def ==(other); super(other) || (data && data == other); end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Is A?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def is_a?(*args, &block)
    super(*args, &block) || (data && data.is_a?(*args, &block))
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Initialize All Automatic Accessors
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.init_auto_accessors
    # For all descendants
    ObjectSpace.each_object(Class) { |klass|
      klass.class_eval { klass.auto_accessors.each { |method| 
        attr_accessor(method) } } if klass < self
    }
  end
end

module Game_IUsableItem; include Game_BaseInstanceItem; end
module Game_IEquipItem;  include Game_BaseInstanceItem; end

class Game_IItem
  include Game_IUsableItem
  def initialize(*args); super(*args); end 
  def self.auto_accessors; [:effects]; end
end
class Game_IWeapon
  include Game_IEquipItem
  def initialize(*args); super(*args); end 
  def self.auto_accessors; [:params, :features]; end
end
class Game_IArmor
  include Game_IEquipItem
  def initialize(*args); super(*args); end 
  def self.auto_accessors; [:params, :features]; end
end

#==============================================================================
# ** Game_InstanceItems
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This is a special subclass of an array which holds instance items in a 
# separate hashes. It replaces the $data_ classe for items, weapons, and armors 
#==============================================================================

class Game_InstanceItems < Array
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_accessor :instance_items
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize(type, data_array = [])
    @instance_items = {}
    @type = type
    @index_start = MA_INSTANCE_ITEMS_BASE[:index_start]
    @last_index = @index_start
    @free_indices = []
    reset_data_array(data_array)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Type Class
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def type_class
    case @type
    when :item   then Game_IItem
    when :weapon then Game_IWeapon
    when :armor  then Game_IArmor
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Reset Data Array
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def reset_data_array(data_array)
    clear
    for item in data_array do self << item end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Instance
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def create_instance(base_item)
    base_item = self[base_item] if base_item.is_a?(Integer)
    return base_item if base_item.is_a?(Game_BaseInstanceItem) || !base_item.instance_based?
    # Get next free index
    if @free_indices.empty?
      index = @last_index
      @last_index += 1
    else
      index = @free_indices.shift
    end
    @instance_items[index] = type_class.new(index, @type, base_item.id)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Destroy Instance
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def destroy_instance(index)
    @free_indices.push(index)
    @instance_items.delete(index)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Retrieve Value from key
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def [](key)
    return key < @index_start ? super(key) : @instance_items[key]
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Value to Key
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def []=(key, value)
    key < @index_start ? super(key, value) : @instance_items[key] = value
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Items with ID
  #    This will return an array of all items with the specified ID
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def items_with_id(item_id)
    return [self[item_id]] unless self[item_id].instance_based?
    return @instance_items.values.select { |ins| ins.item_id == item_id }
  end
end

#==============================================================================
# ** Game_System
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new attr_reader - instance_items
#    new attr_accessor - retrieve_database_id
#    aliased method - initialize
#    new method - init_maiib_data
#==============================================================================

class Game_System
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader   :instance_items
  attr_accessor :retrieve_database_id
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maiib_intz_2sh7 initialize
  def initialize(*args, &block)
    maiib_intz_2sh7(*args, &block) # Call Original Method
    init_maiib_data
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Initialize Instance Items Base Data
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def init_maiib_data
    @instance_items = {
      item:   Game_InstanceItems.new(:item),
      weapon: Game_InstanceItems.new(:weapon),
      armor:  Game_InstanceItems.new(:armor)   }
    @retrieve_database_id = false
  end
end

#==============================================================================
# ** Game_BaseItem
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - set_equip; is_item?; is_weapon?; is_armor?
#==============================================================================

class Game_BaseItem
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Is Item/Weapon/Armor?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  [:Item, :Weapon, :Armor].each { |ic|
    alias_method(:"maiib_is_#{ic.downcase}_8jf9", :"is_#{ic.downcase}?")
    define_method(:"is_#{ic.downcase}?") do |*args|
      send(:"maiib_is_#{ic.downcase}_8jf9", *args) || 
        @class == Kernel.const_get(:"Game_I#{ic}")
    end
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Equipment
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maiib_seteqp_1gn8 set_equip
  def set_equip(is_weapon, item_id, *args, &block)
    data = is_weapon ? $data_weapons : $data_armors
    item_id = data.create_instance(item_id).id if data[item_id] && 
      !data[item_id].is_a?(Game_BaseInstanceItem) && data[item_id].instance_based?
    maiib_seteqp_1gn8(is_weapon, item_id, *args, &block) # Call Original Method
  end
end

#==============================================================================
# ** Game_Party
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - initialize; items; weapons; armors; item_container; 
#      item_number; members_equip_include?; gain_item; discard_members_equip
#    new methods - instance_item_container; instance_item_type; 
#      instance_item_number; gain_instance_item
#==============================================================================

class Game_Party
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader :newest_instance_items
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maiib_nitialz_4ld5 initialize
  def initialize(*args, &block)
    @newest_instance_items = []
    maiib_nitialz_4ld5(*args, &block) # Call Original Method
  end
  [:items, :weapons, :armors].each { |method|
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Items/Weapons/Armors
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    alias_method(:"maiib_#{method}_3js6", method)
    define_method(method) do |*args|
      result = send(:"maiib_#{method}_3js6", *args) # Call Original Method
      # Delete the database items if they are instance items
      deletables = []
      for i in 0...result.size
        item = result[i]
        next if item.nil?
        break if item.is_a?(Game_BaseInstanceItem)
        deletables << i if item.instance_based? 
      end
      deletables.reverse.each { |i| result.delete_at(i) }
      # Sort by Database ID, then ID.
      result.sort {|a, b| (a.database_id <=> b.database_id).nonzero? || a.id <=> b.id }
    end
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Held Instances Of
  #    item : the Item to check
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def held_instances_of(item)
    maiib_items_of_type(item).select { |item2| item2.database_id == item.database_id }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Item Container
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maiib_itmcontain_7hq9 item_container
  def item_container(item_class, *args, &block)
    return @items   if item_class == Game_IItem
    return @weapons if item_class == Game_IWeapon
    return @armors  if item_class == Game_IArmor
    maiib_itmcontain_7hq9(item_class, *args, &block) # Call Original Method
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Items of Type
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maiib_items_of_type(item)
    case instance_item_type(item)
    when :item   then items
    when :weapon then weapons
    when :armor  then armors
    else []
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Instance Type
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def instance_item_type(item)
    case item
    when RPG::Item, Game_IItem     then :item
    when RPG::Weapon, Game_IWeapon then :weapon
    when RPG::Armor, Game_IArmor   then :armor
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Gain Item
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maiib_gainitm_3ky7 gain_item
  def gain_item(item, amount, include_equip = false, *args, &block)
    return if amount == 0
    if item.is_a?(MAIIB_RPG_BaseItem) && item.instance_based? 
      count = item_number(item)
      amount = [[amount, max_item_number(item) - count].min, 0].max if amount > 0
      gain_instance_item(item, amount, include_equip)
      # Add the new items to the container
      @newest_instance_items.each { |ins| 
        maiib_gainitm_3ky7(ins, amount <=> 0, include_equip) }
      # Prepare for database count 
      item = item.data if item.is_a?(Game_BaseInstanceItem) 
    end
    # Call Original Method and modify the count for database items
    maiib_gainitm_3ky7(item, amount, include_equip, *args, &block)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Gain Instance Item
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def gain_instance_item(item, amount, include_equip = false)
    @newest_instance_items.clear
    if item.is_a?(Game_BaseInstanceItem)
      if amount > 0 || (item_number(item) > 0 && amount < 0)
        # Add the item 
        @newest_instance_items << item
        amount -= amount <=> 0
      end
      # If amount was not 1 or -1, apply method to the database item
      item = item.data 
    end
    return unless item
    if amount > 0    # Create new instances
      add_instance_items(item, amount)
    elsif amount < 0 # Find and remove instances of the same database item 
      subtract_instance_items(item, -amount, include_equip)
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Lose Instance Item
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def lose_instance_item (item, amount, include_equip = false)
    gain_instance_item(item, -amount, include_equip)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Add Instance Item
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def add_instance_items(item, amount)
    data_array = $game_system.instance_items[instance_item_type(item)]
    amount.times { @newest_instance_items << data_array.create_instance(item) }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Subtract Instance Item
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def subtract_instance_items(item, amount, include_equip = false)
    data_array = $game_system.instance_items[instance_item_type(item)]
    for ins in held_instances_of(item)
      break if amount == 0
      @newest_instance_items << ins
      amount -= 1
    end
    # Rely on discard_members_equip to dispose of equipped items
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Discard Members Equip
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maiib_discardequip_3hx7 discard_members_equip
  def discard_members_equip(item, amount, *args, &block)
    if item.is_a?(MAIIB_RPG_BaseItem) && item.instance_based? && 
      !item.is_a?(Game_BaseInstanceItem)
      n = amount
      members.each { |actor|
        while n > 0 
          ins = actor.equips.find { |equip| equip.database_id == item.database_id }
          break unless ins
          @newest_instance_items << ins
          actor.discard_equip(ins)
          n -= 1
        end
      }
    else
      # Call Original Method
      maiib_discardequip_3hx7(item, amount, *args, &block) 
    end
  end
end