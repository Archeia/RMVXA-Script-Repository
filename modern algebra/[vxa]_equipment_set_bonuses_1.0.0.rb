#==============================================================================
#    Equipment Set Bonuses
#    Version: 1.0.0
#    Author: modern algebra (rmrk.net)
#    Date: 12 January 2014
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This script allows you to group together pieces of equipments and apply
#   bonuses if all of them are equipped on the same actor.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    To create an equipment set, simply create an armor (not a weapon) with all
#   of the stat changes and features you want added when the entire set is
#   equipped. Then, in the notebox, use the following codes to determine which
#   items belong to the set:
#
#      \set[x1, x2, ..., xn]
#
#   Where each element is the ID of the piece of equipment, preceded by either 
#   A or W to indicate whether it is a weapon or armor.
#
#    For example, a54 would mean the armor with ID 54, while w2 would be the
#   weapon with ID 2.
#
#    As well, you can write more than one of these codes in the notebox, and 
#   then the bonuses will be applied if any of the sets are equipped.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Examples:
#
#      \set[w50, a67, a71]
#    If an actor has equipped the weapon with ID 50 and the armors with IDs 67 
#    and 71, then the bonuses of this equipment set will be applied.
#
#      \set[a32, a33]\set[a32, a34]\set[a33, a34]
#    If an actor has equipped any two pieces of the armors with IDs 32, 33, and
#    34, then the bonuses of this equipment set will be applied.
#==============================================================================

$imported = {} unless $imported
$imported[:MA_EquipmentSetBonuses] = true

#==============================================================================
# ** MAESB EquipmentSet
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  A class to hold data of each set
#==============================================================================

class MAESB_EquipmentSet
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #    set_string : a string with each armor and weapon as "[AW]\d+"
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize(set_string = "")
    # Initialize arrays to track IDs of equips in set
    @weapons, @armors = [], []
    # Populate Set
    set_string.scan(/([AW]?)\s*?(\d+)/mi) { |type, id|
      (type.upcase == 'W' ? @weapons : @armors).push(id.to_i) }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Items
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def items
    (@weapons.collect {|id| $data_weapons[id] }) + # RPG::Weapons +
      (@armors.collect {|id| $data_armors[id] })   # RPG::Armors
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Complete?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def set_complete?(eqps = [])
    itms = items
    !itms.empty? && ((itms & eqps).size == itms.size)
  end
end

module RPG
  #============================================================================
  # ** RPG::EquipItem
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  Summary of Items:
  #    new methods - maesb_generate_equip_set
  #============================================================================
  
  class EquipItem
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Public Instance Variables
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    attr_accessor :maesb_belongs_to_sets
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Generate Equip Set
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def maesb_generate_equip_set
      @maesb_belongs_to_sets = []
    end
  end
  
  #============================================================================
  # ** RPG::Armor
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  Summary of Items:
  #    new methods - maesb_generate_equip_set
  #============================================================================
  
  class Armor
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Public Instance Variables
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    attr_reader   :maesb_sets
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Generate Equip Set
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def maesb_generate_equip_set
      super
      @maesb_sets = note.scan(/\\SET\s*\[(.+?)\]/i).collect { |set_s| 
        MAESB_EquipmentSet.new(set_s[0]) }
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Set Complete?
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def maesb_set_complete?(maesb_equips)
      maesb_sets.each { |set| return true if set && set.set_complete?(maesb_equips) }
      return false
    end
  end
end

#==============================================================================
# *** DataManager
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - load_database
#    new method - maesb_generate_equipment_sets
#==============================================================================

class <<  DataManager
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Load Database
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maesb_loadata_9fg4 load_database
  def load_database(*args, &block)
    maesb_loadata_9fg4(*args, &block) # Call Original Method
    maesb_generate_equipment_sets
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Generate Equipment Sets
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maesb_generate_equipment_sets
    # Generate Equipment Sets
    ($data_weapons + $data_armors).compact.each { |equip| equip.maesb_generate_equip_set }
    # Update items to refer to the set to which they belong
    set_items = $data_armors.compact.select {|armor| !armor.maesb_sets.empty? }
    set_items.each { |set_item| 
      set_item.maesb_sets.collect {|set| set.items }.flatten.uniq.each { |equip|
        equip.maesb_belongs_to_sets.push(set_item.id) 
      }
    }
  end
end

#==============================================================================
# *** MAESB_GameActr_CreateSets
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This module is intended to be mixed in to Game_Actor 
#==============================================================================

module MAESB_GameActr_CreateSets
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Sets
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maesb_sets
    eqps = equips.compact
    if @maesb_set_last_equips != eqps # update if equipment has changed
      @maesb_set_last_equips = eqps
      # Get array of all set items currently equipped
      sets = eqps.inject([]) { |r, eqp| r |= eqp.maesb_belongs_to_sets }
      # Select from them any sets that are complete
      @maesb_sets = (sets.collect {|id| $data_armors[id] }).select {|set| 
        set.maesb_set_complete?(eqps) }
    end
    @maesb_sets  # return array of set items
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get Array of All Objects Retaining Features
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def feature_objects(*args, &block)
    maesb_sets.compact + (super(*args, &block))
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get Added Value of Parameter
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def param_plus(param_id, *args, &block)
    val = super(param_id, *args, &block)
    maesb_sets.compact.inject(val) {|r, item| r += item.params[param_id] }
  end
end

#==============================================================================
# ** Game_Actor
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    included modules - MAESB_GameActr_CreateSets
#==============================================================================

class Game_Actor
  include MAESB_GameActr_CreateSets
end