=begin
#===============================================================================
 Title: Core - Equip Slots
 Author: Hime
 Date: Sep 6, 2014
--------------------------------------------------------------------------------
 ** Change log
 Sep 6, 2014
   - fixed bug where initial equips weren't assigned properly
 Apr 11, 2014
   - fixed bug where having less slots than default crashed the game when
     no custom equips were specified
 Feb 23, 2014
   - fixed bug where etype 0 is assumed to be the only weapon equip type
 Dec 10, 2013
   - fixed issue with battle test
 Nov 1, 2013
   - added support for setting initial equips
 Sep 22, 2013
   - added support for dual wield feature
 Jul 12, 2013
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
 
 This script provides core functionality for extending equip slots.
 It improves the way equip slots are handled and allows you to assign
 equip slots for each actor individually. It also sorts equip slots
 automatically based on your order of choice.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 -- Assign initial equip slots --
 
 Note-tag actors or classes with
 
   <equip slot: x>
   
 Where `x` is the equip type ID (etype ID). By default, they are as follows:
   0 - weapon
   1 - shield
   2 - headgear
   3 - bodygear
   4 - accessory
  
 Actor equip slots take precedence over class equip slots if both have been
 assigned. If no equip slots are assigned, then the class receives default
 equip slots defined in the configuration.
   
 If you are using a custom equip script that allows you to define your own
 equip types, you can use those etype ID's as well.
 
 -- Sorting equip slots --
 
 In the configuration, there is a Sort_Order that determines how your equip
 slots will be sorted based on etype ID. You must provide a value for every
 etype ID in your project.
 
 -- Initial equips --
 
 You can set initial equips by specifying the item in your equip slot:
 
   <equip slot: 0 w4>
   <equip slot: 1 a2>
   
 This equips the first slot with weapon 4, and the second slot with armor 2.
 Note that the script currently only allows one type of equip in a slot, so
 you can't equip both weapons OR armors in the same slot.
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_CoreEquipSlots"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Core_Equip_Slots
    
    # Order that the equip slots will be sorted. You must include all
    # etype ID's defined in your project
    Sort_Order = [0, 1, 2, 3, 4, 5, 10, 11, 12, 13]
    
    # Default slots to assign to actor if no slots are provided.
    Default_Slots = [0, 1, 2, 3, 4]
    
    # Assigns an equip slot
    Regex = /<equip[-_ ]slot:\s*(\d+)\s*(?:(.*))\s*>/i

#===============================================================================
# ** Rest of script
#===============================================================================
    def self.sort_order
      Sort_Order
    end
    
    def initial_slots
      load_notetag_core_equip_slots if @initial_slots.nil?
      return @initial_slots
    end
  end
end

#-------------------------------------------------------------------------------
# Load initial slots for actors and classes
#-------------------------------------------------------------------------------
module RPG
  class Actor
    include TH::Core_Equip_Slots
    
    def load_notetag_core_equip_slots
      @initial_slots = []
      @initial_etypes = []
      @initial_equips = []
      res = self.note.scan(TH::Core_Equip_Slots::Regex)
      res.each do |data|
        @initial_slots << data[0].to_i
        unless data[1].empty?
          type = data[1][0].downcase
          id = data[1][1..-1].to_i
          case type
          when "w"
            type = :weapon
          when "a"
            type = :armor
          end
          @initial_equips << id
          @initial_etypes << type
        else
          @initial_equips << 0
          @initial_etypes << "w"
        end
      end
    end
    
    def has_slots?
      load_notetag_core_equip_slots if @initial_slots.nil?
      return !@initial_slots.empty?
    end
    
    def initial_etypes
      load_notetag_core_equip_slots unless @initial_etypes
      return @initial_etypes
    end
    
    alias :th_core_equip_slots_equips :equips
    def equips
      load_notetag_core_equip_slots if @initial_equips.nil?
      @equips = @initial_equips unless @initial_equips.empty?
      th_core_equip_slots_equips
    end
  end
  
  class Class
    include TH::Core_Equip_Slots
    
    def load_notetag_core_equip_slots
      @initial_slots = []
      res = self.note.scan(TH::Core_Equip_Slots::Regex)
      res.each do |data|
        @initial_slots << data[0].to_i
      end
      @initial_slots = Default_Slots if @initial_slots.empty?
    end
  end
end

#-------------------------------------------------------------------------------
# An equip slot object. Holds a Game_BaseItem object and delegates most calls
# to it for backwards compatibility. The purpose of this class is to
# synchronize the slot ID's and the actual equip items themselves rather than
# storing them as two separate arrays in Game_Actor
#-------------------------------------------------------------------------------
class Game_EquipSlot
  
  attr_reader :etype_id
  attr_reader :initial_etype_id
  
  def initialize(etype_id)
    @etype_id = etype_id
    @item = Game_BaseItem.new
    @initial_etype_id = etype_id
  end
  
  def is_skill?;   @item.is_skill?;   end
  def is_item?;    @item.is_item?;    end
  def is_weapon?;  @item.is_weapon?;  end
  def is_armor?;   @item.is_armor?;   end
  def is_nil?;     @item.is_nil?      end
  
  def object
    @item.object
  end
  
  def object=(obj)
    @item.object = obj
  end
  
  def set_etype(etype_id)
    @etype_id = etype_id
  end
  
  def set_equip(weapon, item_id)
    @item.set_equip(weapon, item_id)
  end
  
  def restore_etype
    @etype_id = @initial_etype_id
  end
end

#-------------------------------------------------------------------------------
# Abstract the equip slots to reference actual EquipSlot objects. Also
# synchronizes the slot ID's with the slot types.
#-------------------------------------------------------------------------------
class Game_Actor < Game_Battler
  
  alias :th_core_equip_slots_initialize :initialize
  def initialize(actor_id)
    th_core_equip_slots_initialize(actor_id)
    @last_dual_weapon_status = false
  end
  
  #-----------------------------------------------------------------------------
  # Check
  #-----------------------------------------------------------------------------
  alias :th_core_equip_slots_refresh :refresh
  def refresh
    check_equip_slots
    th_core_equip_slots_refresh
  end
  
  #-----------------------------------------------------------------------------
  # Replaced. Create an array of EquipSlot objects instead of just Game_BaseItem
  #-----------------------------------------------------------------------------
  def init_equips(equips)
    @equips = Array.new(initial_slots.size) {|i| Game_EquipSlot.new(initial_slots[i]) }
    equips.each_with_index do |item_id, i|
      etype_id = index_to_etype_id(i)
      slot_id = empty_slot(etype_id)
      etype = actor.initial_etypes[i]
      if etype
        @equips[slot_id].set_equip(etype == :weapon, item_id) if slot_id
      else
        @equips[slot_id].set_equip(etype_id == 0, item_id) if slot_id
      end
    end
    sort_equip_slots
    refresh
    
  end

  #-----------------------------------------------------------------------------
  # Replaced. Etype can be retrieved from the slot directly
  #-----------------------------------------------------------------------------
  def index_to_etype_id(index)
    return -1 if @equips.length - 1 < index
    @equips[index].etype_id
  end
  
  #-----------------------------------------------------------------------------
  # Replaced. Etype ID's are pulled from the slots themselves
  #-----------------------------------------------------------------------------
  def equip_slots
    @equips.collect {|slot| slot.etype_id } 
  end
  
  #-----------------------------------------------------------------------------
  # New. Returns the initial slots for the actor. Actor slots take precedence
  # over class slots.
  #-----------------------------------------------------------------------------
  def initial_slots
    return actor.initial_slots if actor.has_slots?
    return self.class.initial_slots 
  end
  
  #-----------------------------------------------------------------------------
  # New. Sort equip slots based on sort order
  #-----------------------------------------------------------------------------
  def sort_equip_slots
    @equips.sort_by! {|eslot| TH::Core_Equip_Slots.sort_order.index(eslot.etype_id)}
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def check_equip_slots
    check_dual_wield_slots if @last_dual_weapon_status != dual_wield?
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def check_dual_wield_slots
    @last_dual_weapon_status = dual_wield?
    @equips.each do |slot|
      if slot.initial_etype_id == 1
        @last_dual_weapon_status ? slot.set_etype(0) : slot.restore_etype
      end
    end
  end
end

#-------------------------------------------------------------------------------
# Adjust contents size to account for additional slots
#-------------------------------------------------------------------------------
class Window_EquipSlot < Window_Selectable

  def refresh
    create_contents
    super
  end
end

#===============================================================================
# Compatibility with battle test
#===============================================================================
if $BTEST
  class Game_Actor < Game_Battler
    def index_to_etype_id(index)
      initial_slots[index]
    end
  end
end