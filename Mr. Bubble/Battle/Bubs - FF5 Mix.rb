# ╔═══════════════════════════════════════════════════════╤═══════╤═══════════╗
# ║ FF5 "Mix"                                             │ v2.00 │ (5/25/13) ║
# ╚═══════════════════════════════════════════════════════╧═══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
#--------------------------------------------------------------------------
# This script is based on the Chemist job class command "Mix" from Final 
# Fantasy 5. Mix allows the user to mix any items from the party's inventory 
# for a variety of effects in battle.
#
# All item combination formulae must be defined in the customization 
# module.
#--------------------------------------------------------------------------
#   ++ Changelog ++ 
#--------------------------------------------------------------------------
# v2.00 : You can now mix any amount of items together.
#       : You can now create mix formulae for any number of items.
#       : Combination search algorithm changed.
#       : The <mix> tag has changed.
#       : Script call 'get_mix_id_result' has changed. (5/25/2013)
# v1.03 : Added developer utility script calls. (8/04/2012)
# v1.02 : Compatibility: "YEA-BattleCommandList" support added.
#       : Compatibility: "YEA-BattleEngine" support added.
#       : Fixed issues related to Attack Times+.
#       : Unused mix items are now properly returned after battle.
#       : Unused mix items are now properly returned when an actor dies.
#       : Unused mix items are now properly returned when switching actors.
#       : Console window now outputs when items are returned to inventory.
#       : Game_Actor#prior_command is no longer aliased.
#       : Comments added/changed. 
#       : Efficiency update. (8/03/2012)
# v1.01 : Compatibility: Mix window properly resized for "YEA-BattleEngine".
#       : Fixed crashes when using items normally. 
#       : Efficiency update with console output. (8/03/2012)
# v1.00 : Initial release. (8/02/2012)
#--------------------------------------------------------------------------
#   ++ Installation ++
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor.
#
# I recommend pasting this script below all other scripts that also
# modify the battle system in your script editor.
#--------------------------------------------------------------------------
#   ++ Usage Notes ++
#--------------------------------------------------------------------------
# --The targeting Scope of the result item will stay intact when made 
#   through mixed items. If the result item requires a player-selected
#   target, the player can do so.
#
# --Spelling is very important with this script. Because of the high 
#   potential for user-errors to occur in regards with spelling errors, 
#   I've provided the option to have messages appear in the Playtest 
#   console window whenever certain errors or spelling mistakes associated 
#   with this script are encountered.
#
# --Item ID combinations will always take precedence over Mix Type 
#   combinations if the selected mix items have a potential result 
#   in both.
#
# --If DEBUG_INFO is true, you will sometimes be informed in the console 
#   window whenever mix items are returned to the party's inventory.
#   Please report to me when items are supposed to be returned to you but
#   are not with information on how to reproduce it.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ++ Notetags ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Note: Some tags are given shorter tags for typing convenience. You only
#       need to use one <tag> from a given group for a notebox. 
#       Use common sense.
#
# The following Notetags are for Skills only:
#
# <mix>
# <mix: n>
#   This tag turns the skill into a Mix skill, where n is the maximum
#   number of items the actor can mix together. When a Mix 
#   skill is selected in battle, a window with all possible mixable items 
#   will appear. The player will not know what item is produced until the
#   item is actually used. Mix skills do not have any special effect 
#   outside of battle. If n is not included with the tag, the default
#   maximum item selection is 2.
#
#--------------------------------------------------------------------------
# The following Notetags are for Items only:
#
# <mixtype: type>
#   This tag defines an item's Mix Type where type is any type name you 
#   defined in MIX_TYPES in the customization module WITHOUT the colon. For 
#   more information about Mix Types, see the comments in the Mix Type 
#   Formulae section in the customization module. If the type in the tag 
#   is not found in MIX_TYPES, a message in the console will tell you.
#
# <unmixable>
# <no mix>
#   This tag will flag the item as unmixable. Items with this tag will
#   not appear in the Mix window.
#
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ++ Script Calls ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# The following script calls are meant to be used in "Script..." event 
# commands found under Tab 3 when creating a new event command.
#
# output_mix_formulae(:id)
# output_mix_formulae(:type)
#   This script call will output all possible Mix ID formulae or Mix Type 
#   formulae to the console window.
#
# get_mix_id_result(id, id, id...)
#   Get the Item ID result of any given Item IDs where id is
#   Item ID numbers from your database. You can list any number of ID 
#   numbers separated by commas as you like. If a result cannot be found
#   with the given ID number arguments, it will return 0. This script 
#   call is meant to be used in the "Script" box within "Control Variable" 
#   event commands.
#
#--------------------------------------------------------------------------
#   ++ FAQ ++
#--------------------------------------------------------------------------
# --I received the Syntax Error "unexpected tLBRACK, expecting '}'. How 
#   do I fix it?
#
#     This means you forgot the comma after the result_item_id number.
#
# --How do I stop the debug messages from appearing in the console window?
#
#     Set DEBUG_INFO to false in the customization module.
#
#--------------------------------------------------------------------------
#   ++ Compatibility ++
#--------------------------------------------------------------------------
# !! IMPORTANT !!
# Due to the nature of this script, script incompatibilities with other
# scripts is likely and expected. Please do not ask if [insert script here]
# is compatible with this script. You can test it yourself.
# 
# Custom battle systems are very likely to have issues with this script
# especially ones that are not turn-based like the default battle system.
#
# If you run into incompatibilities, please report them to me with a link 
# to the script and I will try to make it compatible.
#
# This script aliases the following default VXA methods:
#
#     DataManager#load_normal_database
#     DataManager#load_battle_test_database
#     DataManager#load_database
#     Game_Action#clear
#     Game_Actor#initialize
#     Game_Actor#use_item
#     Game_Actor#consume_item
#     Game_Actor#on_turn_end
#     Game_Actor#clear_actions
#     Game_Actor#item_conditions_met
#     Scene_Battle#on_skill_ok
#     Scene_Battle#on_enemy_ok
#     Scene_Battle#on_enemy_cancel
#     Scene_Battle#on_actor_ok
#     Scene_Battle#on_actor_cancel
#     Scene_Battle#start_actor_command_selection
#    
# There are no default method overwrites.
#
# This script has built-in compatibility with the following scripts:
#
#     Yanfly Engine Ace – Ace Battle Engine
#     Yanfly Engine Ace – Battle Command List
#
# Requests for compatibility with other scripts are welcome.
#--------------------------------------------------------------------------
#   ++ Terms and Conditions ++
#--------------------------------------------------------------------------
# Please do not repost this script elsewhere without permission. 
# Free for non-commercial use. For commercial use, contact me first.
#
# Newest versions of this script can be found at 
#                                           http://mrbubblewand.wordpress.com/
#==============================================================================

$imported ||= {}
$imported["BubsMix"] = true

#==========================================================================
# ++ START OF USER CUSTOMIZATION MODULE ++
#==========================================================================
module Bubs
  #==========================================================================
  # ++ Mix Settings
  #==========================================================================
  module Mix
  #--------------------------------------------------------------------------
  #   Default Mix Result Item ID
  #--------------------------------------------------------------------------
  # This defines the default item ID that is used when absolutely no 
  # formula is found for a chosen item combination.
  DEFAULT_MIX_RESULT_ITEM_ID = 1
  
  #--------------------------------------------------------------------------
  #   Unmixable Item IDs
  #--------------------------------------------------------------------------
  # This setting allows you define the Item IDs that are ineligible to be
  # selected in a mix combination. You can list as many Item IDs in the 
  # array as you like. This setting has the same effect as the <unmixable> 
  # tag.
  UNMIXABLE_ITEMS = []
  
  #--------------------------------------------------------------------------
  #   Debug Info Setting
  #--------------------------------------------------------------------------
  # This setting determines whether debug messages related to this
  # script will appear in the console window during Playtests.
  #
  # I highly recommend that you keep this setting true until your
  # game is complete.
  DEBUG_INFO = true
  
  #--------------------------------------------------------------------------
  #   Selected Mix Item Color Index
  #--------------------------------------------------------------------------
  # This setting determines the color a selected item in the Mix window
  # turns into. The value is a Window skin color index.
  SELECTED_MIX_ITEM_COLOR = 2 # Default 2 (orange)
  
  #--------------------------------------------------------------------------
  #   Item ID Formulae
  #--------------------------------------------------------------------------
  # This hash is where you define Item ID formulae. The syntax for defining
  # a formula is:
  #
  #       [item_id, item_id] => result_item_id,
  #
  # item_id is any existing item_id from your database. result_item_id is 
  # the item that will be used as a result of combination. The
  # colloquial term for "=>" is "hashrocket". Just think of it as an arrow
  # that points to the result item. The order of item_ids in the array does
  # not matter. That means [1,2] is the same as [2,1].
  #
  # ALWAYS remember the comma at the end of result_item_id or you will get
  # a Syntax Error.
  #
  # You can create mix combinations using any number of items.
  #
  # I *highly* recommend that you include comments for your own formulae 
  # so that you can easily reference them.
  MIX_FORMULA_BY_ID = {
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    #   Create your own formulae starting here.
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # Potion + Potion = Hi-Potion
    [1, 1] => 2,
    # Potion + Hi-Potion = Stimulant
    [1, 2] => 5,
    # Hi-Potion + Hi-Potion = Full Potion
    [2, 2] => 3,
    # Full Potion + Magic Water = Elixir
    [3, 4] => 8,
    # Antidote + Antidote = Dispel Herb
    [6, 6] => 7,
    # Potion + Potion + Potion = Full Potion
    [1, 1, 1] => 3,
    
    
    
    
    
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  } # <- Do not delete.
  
  #--------------------------------------------------------------------------
  #   Mix Types
  #--------------------------------------------------------------------------
  # This array is where you define Mix Types. Mix Types are basically
  # categories of mix items that you define. Items are assigned Mix Types
  # with the <mixtype: type> tag (see ++ Notetags ++ for more info).
  #
  # You must always add the name of any new Mix Types that you create
  # into this array. If DEBUG_INFO is true, you will be informed of any
  # missing Mix Types.
  # 
  # You can list as many Mix Types in the array separated by commas as 
  # you like.
  #
  # Mix Types are represented by symbols meaning that they begin with a 
  # colon ":". They should appear orange in the script editor. If the 
  # symbol is not orange, you are typing the symbol incorrectly.
  #
  # !! Important !!
  # :none must always be the first symbol listed in this array. However,
  # it can still be used in Mix Type formulae.
  MIX_TYPES = [:none, :potions1, :potions2, :statup]
  
  #--------------------------------------------------------------------------
  #   Mix Type Formulae
  #--------------------------------------------------------------------------
  # This hash is where you define Mix Type formulae. Mix Types are basically
  # categories of mix items that you define. Items are assigned Mix Types
  # with the <mixtype: type> tag (see ++ Notetags ++ for more info).
  #
  # Mix Types were created because it can be daunting to create item mix
  # formulae for every single possible item ID combination in a project.
  # To ease game development, you are able to use general category types 
  # that can combine into different results in the event that a specific 
  # item ID formula is not found.
  #
  # The syntax for defining a formula is:
  #
  #       [:mix_type, :mix_type] => result_item_id,
  #
  # :mix_type is any symbol that you created and defined in the MIX_TYPES
  # array. result_item_id is the item that will be used as a result of 
  # the type combination. The colloquial term for "=>" is "hashrocket". Just 
  # think of it as an arrow that points to the result. The order of the 
  # symbols in the array does not matter. That means [:potions1, :potions2] 
  # is the same as [:potions2, :potions1].
  #
  # ALWAYS remember the comma at the end of result_item_id or you will get
  # a Syntax Error.
  #
  # You can create mix combinations using any number of items.
  #
  # Mix Types are represented by symbols meaning that they begin with 
  # a colon ":". They should appear orange in the script editor. If the
  # symbol is not orange, you are typing the symbol incorrectly.
  MIX_FORMULA_BY_TYPE = {
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    #   Create your own formulae starting here.
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # Potions 1 + Potions 1 = Hi-Potion
    [:potions1, :potions1] => 2,
    
    # Potions 1 + Potions 2 = Full Potion
    [:potions1, :potions2] => 3,
    
    # Potions 2 + Potions 2 = Full Potion
    [:potions2, :potions2] => 3,
    
    # Potions 1 + Stat Up = Stimulant
    [:potions1, :statup]   => 5,
    
    # Potions 2 + Stat Up = Elixir
    [:potions2, :statup]   => 8,
    
    # Stat Up + Stat Up = Elixir
    [:statup, :statup]     => 8,
        
    # Potions 1 + Potions 1 + Potions 1 = Full Potion
    [:potions1, :potions1, :potions1] => 3,
    
    # Potions 1 + Potinos 1 + Potions 2 = Full Potion
    [:potions1, :potions1, :potions2] => 3,
    
    
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  } # <- Do not delete.

  end # module Mix
end # module Bubs



#==========================================================================
# ++ END OF USER CUSTOMIZATION MODULE ++
#==========================================================================


#==========================================================================
# ++ MixData
#------------------------------------------------------------------------------
#  This class performs formulae initialization defined by the user and 
# is used to compare player mix item choices what is possible. Also handles 
# developer error messages.
#==========================================================================
class MixData
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_reader :id_formula         # stores all id formulae
  attr_reader :type_formula       # stores all mix type formulae
  attr_reader :type_values        # stores mix type integer values
  attr_accessor :debug_info       # debug window message flag
  attr_accessor :default_mix_id   # default item id for failed mixes
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize
    @id_formula = {}
    @type_formula = {}
    @type_values = {}
    @debug_info = Bubs::Mix::DEBUG_INFO
    @default_mix_id = Bubs::Mix::DEFAULT_MIX_RESULT_ITEM_ID
    create_type_values
    create_id_formula
    create_type_formula
  end
  
  #--------------------------------------------------------------------------
  # create_type_values
  #--------------------------------------------------------------------------
  def create_type_values
    Bubs::Mix::MIX_TYPES.each_with_index do |symbol, index|
      @type_values[symbol] = index
    end
    # Sets default return value to 0 if key is not found
  end
  
  #--------------------------------------------------------------------------
  # create_id_formula
  #--------------------------------------------------------------------------
  def create_id_formula
    Bubs::Mix::MIX_FORMULA_BY_ID.each do |key, value|
      @id_formula[key.sort] = value
    end
    @id_formula.default = 0
  end
  
  #--------------------------------------------------------------------------
  # create_type_formula
  #--------------------------------------------------------------------------
  def create_type_formula
    Bubs::Mix::MIX_FORMULA_BY_TYPE.each do |key, value|
      key.each { |symbol| output_type_formula_error(symbol) }
      # converts symbols to integer values based on the index of the key
      # in MIX_TYPES
      array = key.collect { |symbol| get_mix_type_value(symbol) }
      array.sort!
      @type_formula[array] = value
    end # do
    @type_formula.default = 0
  end
  
  #--------------------------------------------------------------------------
  # test_item_type_symbol
  #--------------------------------------------------------------------------
  def test_item_type_symbol(item)
    output_mix_type_error(item) unless mix_type_ok?(item)
  end
  
  #--------------------------------------------------------------------------
  # mix_type_ok?
  #--------------------------------------------------------------------------
  # Checks item's mix_type symbol was provided by the user.
  def mix_type_ok?(item)
    Bubs::Mix::MIX_TYPES.include?(item.mix_type)
  end

  #--------------------------------------------------------------------------
  # output_mix_type_error
  #--------------------------------------------------------------------------
  def output_mix_type_error(item)
    return unless $TEST && @debug_info
    p sprintf("An error occurred with Item ID %s: %s", item.id, item.name)
    p sprintf(":%s does not exist in MIX_TYPES", item.mix_type)
  end
  
  #--------------------------------------------------------------------------
  # output_mix_id_result
  #--------------------------------------------------------------------------
  def output_mix_id_result(id_array, result_id) #(item1, item2, result_item)
    return unless $TEST && @debug_info
    names = id_array.collect { |id| $data_items[id].name }.join(" + ")
    # If you get an error on this line, it means that the result item ID
    # doesn't exist in your database.
    result_name = $data_items[result_id].name
    p sprintf("%s = %s", names, result_name)
  end
  
  #--------------------------------------------------------------------------
  # output_mix_type_result
  #--------------------------------------------------------------------------
  def output_mix_type_result(id_array, result_id) #(item1, item2, result_item)
    return unless $TEST && @debug_info
    symbols = id_array.collect { |symbol| symbol.to_s }.join(" + ")
    # If you get an error on this line, it means that the result item ID
    # doesn't exist in your database.
    result_name = $data_items[result_id].name
    p sprintf("%s = %s", symbols, result_name)
  end
  
  #--------------------------------------------------------------------------
  # output_default_result
  #--------------------------------------------------------------------------
  def output_default_result
    return unless $TEST && @debug_info
    name = $data_items[@default_mix_id].name
    p sprintf("Default mix result: %s", name)
  end
  
  #--------------------------------------------------------------------------
  # output_nil_result_error
  #--------------------------------------------------------------------------
  def output_nil_result_error(item, id)
    return unless $TEST && @debug_info
    return unless item.nil?
    p sprintf("Item ID %s doesn't exist in your Database!", id)
  end
  
  #--------------------------------------------------------------------------
  # output_type_formula_error
  #--------------------------------------------------------------------------
  def output_type_formula_error(symbol)
    return unless $TEST && @debug_info
    return if Bubs::Mix::MIX_TYPES.include?(symbol)
    p "An error occurred with a Mix Type formula:"
    p sprintf(":%s does not exist in MIX_TYPES", symbol)
  end
  
  #--------------------------------------------------------------------------
  # output_returned_items
  #--------------------------------------------------------------------------
  def output_returned_items(id_array) #(item1, item2)
    return unless $TEST && @debug_info
    names = id_array.collect { |id| $data_items[id].name }.join(", ")
    p sprintf("Returned mix items: %s ", names)
  end
  
  #--------------------------------------------------------------------------
  # output_all_id_formulae
  #--------------------------------------------------------------------------
  def output_all_id_formulae
    p "--Displaying all Mix Item ID formulae:"
    @id_formula.each do |key, value|
      #result_name = $data_items[value]
      output_mix_id_result(key, value)
    end
  end
  
  #--------------------------------------------------------------------------
  # output_all_type_formulae
  #--------------------------------------------------------------------------
  def output_all_type_formulae
    p "--Displaying all Mix Type formulae:"
    Bubs::Mix::MIX_FORMULA_BY_TYPE.each do |key, value|
      result_name = $data_items[value].name
      names = key.collect {|type| ":" + type.to_s }.join(" + ")
      p sprintf("%s = %s", names, result_name)
    end
  end
  
  #--------------------------------------------------------------------------
  # get_id_result
  #--------------------------------------------------------------------------
  # Used in Game_Interpreter
  def get_id_result(id_array)#(id1, id2)
    return @id_formula[id_array.sort]
  end
    
  #--------------------------------------------------------------------------
  # get_mix_type_value
  #--------------------------------------------------------------------------
  # returns the value the given mix type symbol
  # returns 0 if symbol does not exist
  def get_mix_type_value(symbol)
    @type_values[symbol]
  end
  
  #--------------------------------------------------------------------------
  # determine_id_formula
  #--------------------------------------------------------------------------
  # Compares the pair of item IDs to find any matching mix formula
  # returns 0 if none is found
  def determine_id_formula(id_array) #(item1, item2)
    return @id_formula[id_array.sort]
  end
  
  #--------------------------------------------------------------------------
  # determine_type_formula
  #--------------------------------------------------------------------------
  # Compares the pair of item mix_types to find any matching mix formula
  # returns 0 if none is found
  def determine_type_formula(id_array) #(item1, item2)
    type_array = id_array.collect {|id| $data_items[id].mix_type }
    type_values = type_array.collect {|type| get_mix_type_value(type) }
    type_values.sort!
    return @type_formula[type_values]
  end
  
  #--------------------------------------------------------------------------
  # process_id_formula_result
  #--------------------------------------------------------------------------
  def process_id_formula_result(id_array, result_id) #(item1, item2, id)
    result = $data_items[result_id]
    output_nil_result_error(result, result_id)
    output_mix_id_result(id_array, result_id) #item1, item2, result)
    return result
  end
  
  #--------------------------------------------------------------------------
  # process_type_formula_result
  #--------------------------------------------------------------------------
  def process_type_formula_result(id_array, result_id) #(item1, item2, id)
    result = $data_items[id]
    output_nil_result_error(result, id)
    output_mix_type_result(id_array, result_id)
    return result
  end
  
  #--------------------------------------------------------------------------
  # get_mix_item_result
  #--------------------------------------------------------------------------
  # This should be the most used method from this class. Returns an item 
  # to be used after comparing all possible formulae.
  def get_mix_item_result(id_array) #(item1, item2)
    
    # Checks if id formula exists for the two given item arguments
    id = determine_id_formula(id_array) #(item1, item2)
    return process_id_formula_result(id_array, id) if id > 0
    
    # Checks if type formula exists for the two given item arguments
    id = determine_type_formula(id_array) #(item1, item2)
    return process_type_formula_result(id_array, id) if id > 0

    output_default_result
    # return default item id if no formula is found
    return $data_items[@default_mix_id]
  end

end # class MixData



#==========================================================================
# ++ DataManager
#==========================================================================
module DataManager

  #--------------------------------------------------------------------------
  # alias : load_normal_database
  #--------------------------------------------------------------------------
  class << self; alias load_normal_database_bubs_mix load_normal_database; end
  def self.load_normal_database
    load_normal_database_bubs_mix # alias
    
    $data_mix = MixData.new
  end
  #--------------------------------------------------------------------------
  # alias : load_battle_test_database
  #--------------------------------------------------------------------------
  class << self; alias load_battle_test_database_bubs_mix load_battle_test_database; end
  def self.load_battle_test_database
    load_battle_test_database_bubs_mix # alias
    
    $data_mix = MixData.new
  end

  #--------------------------------------------------------------------------
  # alias : load_database
  #--------------------------------------------------------------------------
  class << self; alias load_database_bubs_mix load_database; end
  def self.load_database
    load_database_bubs_mix # alias
    load_notetags_bubs_mix
  end
  
  #--------------------------------------------------------------------------
  # new method : load_notetags_bubs_mix
  #--------------------------------------------------------------------------
  def self.load_notetags_bubs_mix
    groups = [$data_skills, $data_items]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_bubs_mix
      end # for obj
    end # for group
  end # def
  
end # module DataManager


#==========================================================================
# ++ Bubs::Regexp
#==========================================================================
module Bubs
  module Regexp
    MIX_TAG = /<MIX:?\s*(\d+)?>/i
    MIX_TYPE_TAG = /<MIX[_\s]?TYPE:\s*(\w+)>/i
    UNMIXABLE_TAG = /<(?:UNMIXABLE|no[_\s]?mix)>/i
  end # module Regexp
end # module Bubs


#==========================================================================
# ++ RPG::BaseItem
#==========================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :mix
  attr_accessor :mix_type
  attr_accessor :mix_max_select
  attr_accessor :unmixable
  #--------------------------------------------------------------------------
  # common cache : load_notetags_bubs_mix
  #--------------------------------------------------------------------------
  def load_notetags_bubs_mix
    @mix = false
    @mix_type = :none
    @unmixable = false
    @mix_max_select = 2
    
    if self.is_a?(RPG::Item)
      @unmixable = Bubs::Mix::UNMIXABLE_ITEMS.include?(self.id)
    end
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when Bubs::Regexp::MIX_TAG
        @mix = true
        @mix_max_select = $1.to_i unless $1.nil?
        
      when Bubs::Regexp::MIX_TYPE_TAG
        next unless self.is_a?(RPG::Item)
        @mix_type = $1.to_sym
        $data_mix.test_item_type_symbol(self)
        
      when Bubs::Regexp::UNMIXABLE_TAG
        @unmixable = true
        
      end # case
    } # self.note.split
  end # def

end # class RPG::BaseItem



#==========================================================================
# ++ Game_Action
#==========================================================================
class Game_Action
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :mixed_item  # flag that determine if action was result of Mix
  #--------------------------------------------------------------------------
  # alias : clear
  #--------------------------------------------------------------------------
  alias clear_bubs_mix clear
  def clear
    clear_bubs_mix
    
    @mixed_item = false
  end
end # class Game_Action


#==========================================================================
# ++ Game_Actor
#==========================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :mix_items
  #--------------------------------------------------------------------------
  # alias : initialize
  #--------------------------------------------------------------------------
  alias initialize_bubs_mix initialize
  def initialize(actor_id)
    # Mix item combos are kept as a 2D array [[item1, item2], ...]
    @mix_items = []
    
    initialize_bubs_mix(actor_id) # alias
  end
  
  #--------------------------------------------------------------------------
  # alias : use_item
  #--------------------------------------------------------------------------
  alias use_item_bubs_mix use_item
  def use_item(item)
    # pay the item cost of the mix item
    if $game_party.in_battle && current_action && current_action.mixed_item
      consume_mix_items
    end
    
    use_item_bubs_mix(item) # alias
  end
  
  #--------------------------------------------------------------------------
  # alias : consume_item
  #--------------------------------------------------------------------------
  alias consume_item_bubs_mix consume_item
  def consume_item(item)
    # prevent losing item if it was a mixed item
    return if $game_party.in_battle && current_action && current_action.mixed_item
    consume_item_bubs_mix(item) # alias
  end

  #--------------------------------------------------------------------------
  # alias : on_turn_end
  #--------------------------------------------------------------------------
  alias on_turn_end_bubs_mix on_turn_end
  def on_turn_end
    return_all_mix_items
    
    on_turn_end_bubs_mix # alias
  end
  
  #--------------------------------------------------------------------------
  # alias : clear_actions
  #--------------------------------------------------------------------------
  alias clear_actions_bubs_mix clear_actions
  def clear_actions
    clear_actions_bubs_mix # alias
    
    return_all_mix_items
  end
  
  #--------------------------------------------------------------------------
  # alias : item_conditions_met
  #--------------------------------------------------------------------------
  # Avoids the issue of not being to used mixed items when the player
  # doesn't have one in their inventory
  alias item_conditions_met_bubs_mix item_conditions_met?
  def item_conditions_met?(item)
    if $game_party.in_battle && current_action && current_action.mixed_item
      return usable_item_conditions_met?(item)
    else
      return item_conditions_met_bubs_mix(item) # alias
    end
  end
  
  #--------------------------------------------------------------------------
  # new method : consume_mix_items
  #--------------------------------------------------------------------------
  # Pay the cost of the mixed items
  def consume_mix_items
    @mix_items.shift
  end
  
  #--------------------------------------------------------------------------
  # new method : return_last_mix_items
  #--------------------------------------------------------------------------
  # Return last pair of mix items stored by the actor
  def return_last_mix_items
    return if @mix_items.empty?
    id_array = @mix_items.pop
    items = id_array.collect { |id| $data_items[id] }
    items.each { |item| $game_party.gain_item(item, 1) }
    $data_mix.output_returned_items(id_array)
  end
  
  #--------------------------------------------------------------------------
  # new method : return_all_mix_items
  #--------------------------------------------------------------------------
  # Return all mix items stored by the actor
  def return_all_mix_items
    @mix_items.each do |id_array|
      id_array.each {|id| $game_party.gain_item($data_items[id], 1) }
      $data_mix.output_returned_items(id_array)
    end
    @mix_items.clear
  end
  
end # class Game_Actor


#==============================================================================
# ++ Game_Interpreter
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # new method : output_mix_formulae
  #--------------------------------------------------------------------------
  def output_mix_formulae(symbol = :id)
    case symbol
    when :id
      $data_mix.output_all_id_formulae
    when :type
      $data_mix.output_all_type_formulae
    end
  end
  
  #--------------------------------------------------------------------------
  # new method : get_mix_id_result
  #--------------------------------------------------------------------------
  def get_mix_id_result(*args)#(id1, id2)
    $data_mix.get_id_result(args)
  end
end




#==============================================================================
# ++ Window_MixItem
#==============================================================================
class Window_MixItem < Window_ItemList
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :selected_items
  attr_accessor :last_window
  attr_accessor :last_item
  attr_accessor :max_select
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(help_window, info_viewport)
    y = help_window.height
    super(0, y, Graphics.width, info_viewport.rect.y - y)
    self.visible = false
    @last_item = Game_BaseItem.new
    @help_window = help_window
    @info_viewport = info_viewport
    @selected_items = []
    @last_window = :skill_window
    @max_select = 1
  end
  
  #--------------------------------------------------------------------------
  # include?
  #--------------------------------------------------------------------------
  def include?(item)
    return false unless item.is_a?(RPG::Item)
    return false if item.unmixable
    return true
  end
  
  #--------------------------------------------------------------------------
  # enable?                             # Display in Enabled State?
  #--------------------------------------------------------------------------
  def enable?(item)
    return false if item.nil?
    return true
  end

  #--------------------------------------------------------------------------
  # show
  #--------------------------------------------------------------------------
  def show
    @help_window.show
    super
  end
  
  #--------------------------------------------------------------------------
  # hide
  #--------------------------------------------------------------------------
  def hide
    @help_window.hide
    super
  end
  
  #--------------------------------------------------------------------------
  # dispose
  #--------------------------------------------------------------------------
  def dispose
    return_selected_items unless disposed?
    super
  end
  
  #--------------------------------------------------------------------------
  # add_item
  #--------------------------------------------------------------------------
  def add_item
    $game_party.lose_item(item, 1)
    @selected_items.push(item.id)
    refresh
  end
  
  #--------------------------------------------------------------------------
  # remove_item
  #--------------------------------------------------------------------------
  def remove_item
    id = @selected_items.pop
    $game_party.gain_item($data_items[id], 1) if id
    refresh
  end
  
  #--------------------------------------------------------------------------
  # clear_selected_items
  #--------------------------------------------------------------------------
  def clear_selected_items
    @selected_items = []
    refresh
  end
  
  #--------------------------------------------------------------------------
  # return_selected_items
  #--------------------------------------------------------------------------
  def return_selected_items
    @selected_items.size.times do remove_item end
    refresh
  end
  
  #--------------------------------------------------------------------------
  # mix_done?
  #--------------------------------------------------------------------------
  def mix_done?
    @last_item.object = item
    return true if @selected_items.size == @max_select
    return false
  end
  
  #--------------------------------------------------------------------------
  # mix_cancel?
  #--------------------------------------------------------------------------
  def mix_cancel?
    return true if @selected_items.empty?
    remove_item
    refresh
    return false
  end

  #--------------------------------------------------------------------------
  # mix_result
  #--------------------------------------------------------------------------
  def mix_result
    return $data_mix.get_mix_item_result(@selected_items)
  end
  
  #--------------------------------------------------------------------------
  # select_last                   # Restore Previous Selection Position
  #--------------------------------------------------------------------------
  def select_last
    select(@data.index(@last_item.object) || 0)
  end

  #--------------------------------------------------------------------------
  # draw_item_name
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    change_color(normal_color, enabled)
    selected_mix_item_color if @selected_items.include?(item.id)
    draw_text(x + 24, y, width, line_height, item.name)
  end
  
  #--------------------------------------------------------------------------
  # selected_mix_item_color
  #--------------------------------------------------------------------------
  def selected_mix_item_color
    change_color(text_color(Bubs::Mix::SELECTED_MIX_ITEM_COLOR)) 
  end
  
  #--------------------------------------------------------------------------
  # inh ov : process_handling
  #--------------------------------------------------------------------------
  def process_handling
    super
    #return unless cursor_movable?
    #return process_confirm if handle?(:confirm) && Input.trigger?(:X)
  end
  
  #--------------------------------------------------------------------------
  # process_confirm       # Processing When OK Button Is Pressed
  #--------------------------------------------------------------------------
  def process_confirm
    if @selected_items.empty?
      Sound.play_buzzer
    else
      Sound.play_ok
      Input.update
      deactivate
      call_confirm_handler
    end
  end
  
  #--------------------------------------------------------------------------
  # call_confirm_handler          # Call OK Handler
  #--------------------------------------------------------------------------
  def call_confirm_handler
    call_handler(:confirm)
  end
  
end # class Window_MixItem



#==============================================================================
# ++ Scene_Battle
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # alias : create_mix_window
  #--------------------------------------------------------------------------
  alias create_all_windows_bubs_mix create_all_windows
  def create_all_windows
    create_all_windows_bubs_mix # alias
    
    create_mix_window
  end
  
  #--------------------------------------------------------------------------
  # new method : create_mix_window
  #--------------------------------------------------------------------------
  def create_mix_window
    @mix_window = Window_MixItem.new(@help_window, @info_viewport)
    @mix_window.set_handler(:ok,          method(:on_mixitem_ok))
    @mix_window.set_handler(:confirm,     method(:on_mixitem_confirm))
    @mix_window.set_handler(:cancel,      method(:on_mixitem_cancel))
    resize_mix_window_yea_abe
  end
  
  #--------------------------------------------------------------------------
  # new method : on_mixitem_ok
  #--------------------------------------------------------------------------
  def on_mixitem_ok
    @mix_window.add_item
    if @mix_window.mix_done?
      @mix_window.hide
      determine_mix_target
    else
      @mix_window.activate
    end
  end
  
  #--------------------------------------------------------------------------
  # new method : on_mixitem_cancel
  #--------------------------------------------------------------------------
  def on_mixitem_cancel
    case @mix_window.last_window
    when :skill_window
      on_mixitem_cancel_to_skill_window
    when :yea_bcl # $imported["YEA-BattleCommandList"]
      on_mixitem_cancel_to_yea_bcl
    end
  end
  
  #--------------------------------------------------------------------------
  # new method : on_mixitem_confirm
  #--------------------------------------------------------------------------
  def on_mixitem_confirm
    if @mix_window.selected_items.empty?
      @mix_window.activate
    else
      @mix_window.hide
      determine_mix_target
    end
  end
  
  #--------------------------------------------------------------------------
  # alias : on_skill_ok
  #--------------------------------------------------------------------------
  alias on_skill_ok_bubs_mix on_skill_ok
  def on_skill_ok
    @skill = @skill_window.item
    
    # set skill cursor memorization
    BattleManager.actor.last_skill.object = @skill
    
    # override normal skill processing if Mix skill
    if @skill.mix
      @mix_window.return_selected_items
      @mix_window.last_window = :skill_window
      @mixing = true
      @skill_window.hide
      @mix_window.max_select = @skill.mix_max_select
      @mix_window.refresh
      @mix_window.show.activate.select(0)
    else
      on_skill_ok_bubs_mix # alias
    end
  end
  
  #--------------------------------------------------------------------------
  # alias : on_enemy_ok
  #--------------------------------------------------------------------------
  alias on_enemy_ok_bubs_mix on_enemy_ok
  def on_enemy_ok
    set_actor_mix_items if @mixing
    #@mixing = false
    
    on_enemy_ok_bubs_mix # alias
  end
  
  #--------------------------------------------------------------------------
  # alias : on_enemy_cancel
  #--------------------------------------------------------------------------
  alias on_enemy_cancel_bubs_mix on_enemy_cancel
  def on_enemy_cancel
    @enemy_window.hide
    if @mixing
      BattleManager.actor.input.clear
      
      if $imported["YEA-BattleEngine"]
        @status_aid_window.refresh
        @status_window.refresh
      end
      
      @mix_window.remove_item
      @mix_window.refresh
      @mix_window.show.activate
      @mix_window.select_last
    else
      on_enemy_cancel_bubs_mix # alias
    end
  end
  
  #--------------------------------------------------------------------------
  # alias : on_actor_ok
  #--------------------------------------------------------------------------
  alias on_actor_ok_bubs_mix on_actor_ok
  def on_actor_ok
    set_actor_mix_items if @mixing
    #@mixing = false
    
    on_actor_ok_bubs_mix # alias
  end

  #--------------------------------------------------------------------------
  # alias : on_actor_cancel
  #--------------------------------------------------------------------------
  alias on_actor_cancel_bubs_mix on_actor_cancel
  def on_actor_cancel
    @actor_window.hide
    if @mixing
      BattleManager.actor.input.clear
      
      if $imported["YEA-BattleEngine"]
        @status_aid_window.refresh
        @status_window.refresh
      end
      
      @mix_window.remove_item
      @mix_window.refresh
      @mix_window.show.activate
      @mix_window.select_last
    else
      on_actor_cancel_bubs_mix # alias
    end
  end
  
  #--------------------------------------------------------------------------
  # alias : start_actor_command_selection
  #--------------------------------------------------------------------------
  alias start_actor_command_selection_bubs_mix start_actor_command_selection
  def start_actor_command_selection
    @mixing = false
    cancel_mix_items
    
    start_actor_command_selection_bubs_mix # alias
  end
  
  #--------------------------------------------------------------------------
  # new method : cancel_mix_items
  #--------------------------------------------------------------------------
  def cancel_mix_items
    actor = BattleManager.actor
    if actor && actor.input.mixed_item
      BattleManager.actor.return_last_mix_items
      BattleManager.actor.input.mixed_item = false
    end
  end

  #--------------------------------------------------------------------------
  # compatibility method : resize_mix_window_yea_abe
  #--------------------------------------------------------------------------
  def resize_mix_window_yea_abe
    return unless $imported["YEA-BattleEngine"]
    @mix_window.height = @skill_window.height
    @mix_window.width = @skill_window.width
    @mix_window.y = Graphics.height - @item_window.height
  end
  
  #--------------------------------------------------------------------------
  # new method : on_mixitem_cancel
  #--------------------------------------------------------------------------
  def on_mixitem_cancel_to_skill_window
    if @mix_window.mix_cancel?
      # return to @skill_window
      @mixing = false
      @mix_window.hide
      @skill_window.refresh
      @skill_window.show.activate
    else
      @mix_window.activate
    end
  end
  
  #--------------------------------------------------------------------------
  # compatibility method : on_mixitem_cancel_to_yea_bcl
  #--------------------------------------------------------------------------
  def on_mixitem_cancel_to_yea_bcl
    if @mix_window.mix_cancel?
      
      # YEA - Battle Engine Ace
      if $imported["YEA-BattleEngine"]
        @status_window.show
        @actor_command_window.show
        @status_aid_window.hide
      end
      
      # return to @actor_command_window
      @mixing = false
      @mix_window.hide
      @actor_command_window.show.activate
    else
      @mix_window.activate
    end
  end
  
  #--------------------------------------------------------------------------
  # compatibility alias : command_use_skill
  #--------------------------------------------------------------------------
  if $imported["YEA-BattleCommandList"]
  alias command_use_skill_bubs_mix command_use_skill
  def command_use_skill
    @skill = $data_skills[@actor_command_window.current_ext]
    # override normal skill processing if Mix skill
    if @skill.mix
      # set skill cursor memorization
      BattleManager.actor.last_skill.object = @skill
      # from YEA-BattleCommandList
      status_redraw_target(BattleManager.actor)
      
      if $imported["YEA-BattleEngine"]
        @status_window.hide
        @actor_command_window.hide
        @status_aid_window.show
      end
      
      # set last_window symbol for cancel memorization
      @mix_window.last_window = :yea_bcl
      @mix_window.return_selected_items
      @mixing = true
      @mix_window.refresh
      @mix_window.show.activate.select(0)
    else
      command_use_skill_bubs_mix # alias
    end # if
  end # def
  end # $imported["YEA-BattleCommandList"]

  #--------------------------------------------------------------------------
  # new method : determine_mix_target
  #--------------------------------------------------------------------------
  def determine_mix_target
    if $imported["YEA-BattleCommandList"]
      determine_mix_target_yea_bcl
    elsif $imported["YEA-BattleEngine"]
      determine_mix_target_yea_abe
    else # default battle system
      @item = @mix_window.mix_result
      BattleManager.actor.input.set_item(@item.id)
      
      if !@item.need_selection?
        set_actor_mix_items # mix
        next_command
      elsif @item.for_opponent?
        select_enemy_selection
      else
        select_actor_selection
      end # if
    end # if
  end

  #--------------------------------------------------------------------------
  # compatibility method : determine_mix_target_yea_abe
  #--------------------------------------------------------------------------
  # This method is only used when "YEA-BattleEngine" is installed
  def determine_mix_target_yea_abe
    @item = @mix_window.mix_result
    $game_temp.battle_aid = @item
    BattleManager.actor.input.set_item(@item.id)
    if @item.for_opponent?
      select_enemy_selection
    elsif @item.for_friend?
      select_actor_selection
    else
      set_actor_mix_items # mix
      next_command
      $game_temp.battle_aid = nil
    end
  end
  
  #--------------------------------------------------------------------------
  # compatibility method : determine_mix_target_yea_bcl
  #--------------------------------------------------------------------------
  # This method is only used when "YEA-BattleCommandList" is installed
  def determine_mix_target_yea_bcl
    @item = @mix_window.mix_result
    BattleManager.actor.input.set_item(@item.id)

    status_redraw_target(BattleManager.actor)
    if $imported["YEA-BattleEngine"]
      $game_temp.battle_aid = @item
      if @item.for_opponent?
        select_enemy_selection
      elsif @item.for_friend?
        select_actor_selection
      else
        set_actor_mix_items # mix
        next_command
        $game_temp.battle_aid = nil
      end
    else
      if !@item.need_selection?
        set_actor_mix_items # mix
        next_command
      elsif @item.for_opponent?
        select_enemy_selection
      else
        select_actor_selection
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # new method : set_actor_mix_items
  #--------------------------------------------------------------------------
  def set_actor_mix_items
    return if @mix_window.selected_items.empty?
    # push mix item pair into the $game_actor
    BattleManager.actor.mix_items.push(@mix_window.selected_items)
    # set current action flag
    BattleManager.actor.input.mixed_item = true
    # clear @selected_items
    @mix_window.clear_selected_items
    @mixing = false
  end

end # class Scene_Battle


