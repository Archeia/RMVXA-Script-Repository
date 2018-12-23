# ╔═══════════════════════════════════════════════════════╤══════╤═══════════╗
# ║ Dismantle Items                                       │ v1.3 │ (4/27/13) ║
# ╚═══════════════════════════════════════════════════════╧══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
#--------------------------------------------------------------------------
# This script is based off the Dismantling mechanic from Final Fantasy 13.
# However, copying that exact system isn't very fun so I added a few
# extra optional features. You can also define the chance for items to
# be dismantled from the original item. Item dismantle information can
# also be masked until the player dismantles the item.
#
# My motivation for making this script comes from wanting to learn how
# windows interact with each other in VXA scenes. While the process of 
# making this script took much longer than I wanted, it was very much
# worth it.
#--------------------------------------------------------------------------
#   ++ Changelog ++
#--------------------------------------------------------------------------
# v1.3 : Changed how dismantled item data is stored. (4/27/2013)
# v1.2 : Bugfix: Custom sound effects should no longer crash the game.
#      : "Times Dismantled" values are now properly saved.
#      : Dismantle mask flags are now properly saved. 
#      : Dismantle scene script call has changed for consistency. The 
#      : old script call can still be used though. (4/05/2013)
# v1.1 : DISMANTLABLE_ITEMS_MASK_ICON_ID now works. (7/21/2012)
# v1.0 : Initial release. (7/21/2012)
#--------------------------------------------------------------------------
#   ++ Installation ++
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ++ Notetags ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Note: Some tags are given shorter tags for typing convenience. You only
#       need to use one <tag> from a given group for a notebox. 
#       Use common sense.
#
# The following Notetags are for Items, Weapons, and Armors only:
#
# <dismantle>
# setting
# setting
# </dismantle>
#   This tag allows you define custom dismantle settings. You can add as many 
#   settings between the <dismantle> tags as you like. Only items with this tag
#   will appear in the Dismantle Shop. Any settings you do not include will 
#   use the default values defined in the customization module if there are 
#   any. The following settings are available:
#   
#     item: id
#     item: id, chance%
#     i: id
#     i: id, chance%
#       This setting defines the item that is dismantled from the original
#       item, armor, or weapon where id is the Item ID number found in
#       your database. Chance is a value between 0.0 and 100.0. If chance 
#       is omitted, it will use the default chance value defined in the 
#       customization module. This setting can be used multiple times
#       within the tags.
#   
#     weapon: id
#     weapon: id, chance%
#     w: id
#     w: id, chance%
#       This setting defines the weapon that is dismantled from the original
#       item, armor, or weapon where id is the Weapon ID number found in
#       your database. Chance is a value between 0.0 and 100.0. If chance 
#       is omitted, it will use the default chance value defined in the 
#       customization module. This setting can be used multiple times
#       within the tags.
#   
#     armor: id
#     armor: id, chance%
#     armour: id
#     armour: id, chance%
#     a: id
#     a: id, chance%
#       This setting defines the armor that is dismantled from the original
#       item, armor, or weapon where id is the Armor ID number found in
#       your database. Chance is a value between 0.0 and 100.0. If chance 
#       is omitted, it will use the default chance value defined in the 
#       customization module. This setting can be used multiple times
#       within the tags.
#   
#     fee: amount
#       This setting defines the amount of Gold required to dismantle the
#       item, armor, or weapon where amount is any amount of gold. If this 
#       setting is omitted, it will use the default fee defined in the 
#       customization module.
#   
# Here are some examples of proper <dismantle> tags:
#
#     <dismantle>
#     item: 18
#     item: 19
#     item: 17
#     fee: 1000
#     </dismantle>
#
# In this example, each item setting has omitted the chance value. 
# This means that it will use the default chance value defined in 
# the customization module.
#
#     <dismantle>
#     i: 18
#     i: 18
#     i: 18, 25%
#     w: 4, 30%
#     a: 5, 5%
#     </dismantle>
#
# In this example, each line uses the short-hand version of a setting. 
# The dismantle chance values are included for some settings, but not 
# all.  The “fee” setting is omitted meaning it will use the default 
# fee value defined in the customization module.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ++ Script Calls ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# The following Script Calls are meant to be used in "Script..." event 
# commands found under Tab 3 when creating a new event.
#
# call_dismantle_scene
#   This script call opens up a Dismantle Shop scene.
#
# remove_dismantle_mask(:item, id)
# remove_dismantle_mask(:weapon, id)
# remove_dismantle_mask(:armor, id)
#   This script call allows you to remove the dismantle information mask
#   for a specified item, weapon, or armor where id is the database ID
#   number
#   
# remove_all_dismantle_masks
#   This script call removes all dismantle information masks on all
#   dismantlable items, weapons, and armors in the database.
#   
# get_dismantle_count(:item, id)
# get_dismantle_count(:weapon, id)
# get_dismantle_count(:armor, id)
#   This script call returns the "Times Dismantled" value of the 
#   specified item, weapon, and armor where id is the database ID number. 
#   This script call is meant to be used in the "Script" box within
#   "Control Variable" event commands.
#   
# get_all_dismantle_count
#   This script call returns the cumulative "Times Dismantled"
#   value of all items, weapons, and armors. This script call is meant to 
#   be used in the "Script" box within "Control Variable" event commands.
#   
#--------------------------------------------------------------------------
#   ++ Compatibility ++
#--------------------------------------------------------------------------
# This script aliases the following default VXA methods:
#
#     DataManager#load_database
#    
# There are no default method overwrites.
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

$imported = {} if $imported.nil?
$imported["BubsDismantle"] = true

#==========================================================================
# ++ START OF USER CUSTOMIZATION MODULE ++
#==========================================================================
module Bubs
  #==========================================================================
  # ++ Dismantle Shop Settings
  #==========================================================================
  module Dismantle
  #--------------------------------------------------------------------------
  #   Dismantle Command Vocab
  #--------------------------------------------------------------------------
  DISMANTLE_COMMAND_TEXT = "Dismantle"
  
  #--------------------------------------------------------------------------
  #   Dismantle Shop Category Setting
  #--------------------------------------------------------------------------
  # This setting determines what item categories appear in the
  # Dismantle Shop category window. If a category is not included
  # in the array then those types of items are not dismantlable.
  #
  # Available Categories:
  #   :items, :weapons, :armors, :key_items
  SHOP_CATEGORIES = [:items, :weapons, :armors]
  
  #--------------------------------------------------------------------------
  # Disable Dismantle Confirm Window Game Switch
  #--------------------------------------------------------------------------
  # This setting allows you to assign a switch ID that toggles 
  # whether the "Confirm Dismantle" window is used.
  #
  # If the Game Switch is OFF, the confirm window is used.
  # If the Game Switch is ON, the confirm window is disabled.
  DISABLE_CONFIRM_WINDOW_SWITCH_ID = 1
  
  #--------------------------------------------------------------------------
  #   Default Dismantle Chance
  #--------------------------------------------------------------------------
  # This setting determines the default chance for all dismantlable
  # items if a custom chance tag is not found.
  DEFAULT_DISMANTLE_CHANCE = 100.0  # (%)
  
  #--------------------------------------------------------------------------
  #   Show Dismantle Chance
  #--------------------------------------------------------------------------
  # Dismantle chance rates will still be used even if chance values
  # are hidden
  #
  # true  : Show dismantle chance info.
  # false : Hide dismantle chance info.
  SHOW_DISMANTLE_CHANCE = true
  
  #--------------------------------------------------------------------------
  #   Default Dismantle Fee
  #--------------------------------------------------------------------------
  # This setting determines the default Gold fee for all dismantlable
  # items if a custom fee tag is not found.
  DEFAULT_DISMANTLE_FEE = 250
    
  #--------------------------------------------------------------------------
  #   Dismantle Fee Text Settings
  #--------------------------------------------------------------------------
  # This setting determines whether the "Fee" for dismantlable items
  # can be see in the info window.
  #
  # true  : Fee can be seen in dismantle info window.
  # false : Fee is hidden.
  SHOW_DISMANTLE_FEE = true
  DISMANTLE_FEE_TEXT = "Dismantle Fee" # Dismantle Gold Fee Text
  
  #--------------------------------------------------------------------------
  #   Dismantlable Items List Settings
  #--------------------------------------------------------------------------
  # This setting toggles the Dismantlable Items list.
  #
  # true  : Player can see what item can dismantle into.
  # false : Player cannot see Dismantlable Items list.
  SHOW_DISMANTLABLE_ITEMS_LIST = true
  #--------------------------------------------------------------------------
  #   Dismantlable Items Info Window Settings
  #--------------------------------------------------------------------------
  DISMANTLABLE_ITEMS_LIST_TEXT = "Dismantlable Items" # Items List Text  
  DISMANTLABLE_COUNTER_TEXT    = "Times Dismantled" # Dismantle Counter Text
  RESULTS_HEADER_TEXT          = "You Received" # Results Header Window Text
  
  #--------------------------------------------------------------------------
  # Use Dismantlable Items Mask Setting
  #--------------------------------------------------------------------------
  # This setting allows you to use a mask for an item under the
  # "Dismantlable Items" list if the item has not yet been
  # dismantled from the item. The item's name and chance is
  # revealed when the player successfully dismantles that item.
  USE_DISMANTLABLE_ITEMS_MASK = true
  #--------------------------------------------------------------------------
  # Item Mask Settings
  #--------------------------------------------------------------------------
  DISMANTLABLE_ITEMS_MASK_ICON_ID = 0     # Mask Iconset ID
  DISMANTLABLE_ITEMS_MASK = "?????"       # Item Name Mask
  DISMANTLABLE_ITEMS_CHANCE_MASK = "??%"  # Chance Mask
  
  #--------------------------------------------------------------------------
  # Dismantle Sound Effect
  #--------------------------------------------------------------------------
  #               "filename", volume, pitch
  DISMANTLE_SE = [  "Hammer",     80,   100]

  end # module Dismantle
end # module Bubs

#==========================================================================
# ++ END OF USER CUSTOMIZATION MODULE ++
#==========================================================================



#==========================================================================
# ++ Bubs::Regexp
#==========================================================================
module Bubs
  module Regexp
    module BaseItem
      DISMANTLE_START = /<DISMANTLE>/i
      DISMANTLE_END   = /<\/DISMANTLE>/i
    end # module BaseItem
  end # module Regexp
end # module Bubs


#==============================================================================
# ++ Sound
#==============================================================================
module Vocab
  #--------------------------------------------------------------------------
  # new method : dismantle
  #--------------------------------------------------------------------------
  def self.dismantle
    Bubs::Dismantle::DISMANTLE_COMMAND_TEXT
  end
  
end # module Vocab


#==============================================================================
# ++ Sound
#==============================================================================
module Sound
  #--------------------------------------------------------------------------
  # new method : play_dismantle
  #--------------------------------------------------------------------------
  def self.play_dismantle
    filename = Bubs::Dismantle::DISMANTLE_SE[0]
    volume = Bubs::Dismantle::DISMANTLE_SE[1]
    pitch = Bubs::Dismantle::DISMANTLE_SE[2]
    Audio.se_play("Audio/SE/" + filename, volume, pitch) 
  end
  
end # module Sound


#==========================================================================
# ++ DataManager
#==========================================================================
module DataManager
  #--------------------------------------------------------------------------
  # alias : load_database
  #--------------------------------------------------------------------------
  class << self; alias load_database_bubs_dismantle load_database; end
  def self.load_database
    load_database_bubs_dismantle # alias
    load_notetags_bubs_dismantle
  end
  
  #--------------------------------------------------------------------------
  # new method : load_notetags_bubs_dismantle
  #--------------------------------------------------------------------------
  def self.load_notetags_bubs_dismantle
    groups = [$data_items, $data_weapons, $data_armors]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_bubs_dismantle
      end # for obj
    end # for group
  end # def
  
  #--------------------------------------------------------------------------
  # make_save_contents
  #--------------------------------------------------------------------------
  class << self; alias make_save_contents_bubs_dismantle make_save_contents; end
  def self.make_save_contents
    contents = make_save_contents_bubs_dismantle
    contents[:dismantle_counters] = save_dismantle_counters
    contents[:dismantle_masks] = save_dismantle_masks
    contents
  end
  
  #--------------------------------------------------------------------------
  # extract_save_contents
  #--------------------------------------------------------------------------
  class << self; alias extract_save_contents_bubs_dismantle extract_save_contents; end
  def self.extract_save_contents(contents)
    extract_save_contents_bubs_dismantle(contents)
    load_dismantle_counters(contents[:dismantle_counters])
    load_dismantle_masks(contents[:dismantle_masks])
  end
  
  #--------------------------------------------------------------------------
  # save_dismantle_counters
  #--------------------------------------------------------------------------
  def self.save_dismantle_counters
    keys = [:items, :weapons, :armors]
    groups = [$data_items, $data_weapons, $data_armors]
    hash = {}
    for key, group in keys.zip(groups)
      hash[key] = {}
      for obj in group
        next if obj.nil?
        hash[key][obj.id] = obj.dismantle_counter
      end # for obj
    end # for group
    return hash
  end # def
  
  #--------------------------------------------------------------------------
  # load_dismantle_counters
  #--------------------------------------------------------------------------
  def self.load_dismantle_counters(data)
    keys = [:items, :weapons, :armors]
    groups = [$data_items, $data_weapons, $data_armors]
    for key, group in keys.zip(groups)
      for obj in group
        next if obj.nil?
        obj.dismantle_counter = data[key][obj.id]
      end # for obj
    end # for group
  end # def
  
  #--------------------------------------------------------------------------
  # save_dismantle_masks
  #--------------------------------------------------------------------------
  def self.save_dismantle_masks
    keys = [:items, :weapons, :armors]
    groups = [$data_items, $data_weapons, $data_armors]
    hash = {}
    for key, group in keys.zip(groups)
      hash[key] = {}
      for obj in group
        next if obj.nil?
        hash[key][obj.id] = obj.dismantle_items
      end # for obj
    end # for group
    return hash
  end # def
  
  #--------------------------------------------------------------------------
  # load_dismantle_masks
  #--------------------------------------------------------------------------
  def self.load_dismantle_masks(data)
    keys = [:items, :weapons, :armors]
    groups = [$data_items, $data_weapons, $data_armors]
    for key, group in keys.zip(groups)
      for obj in group
        next if obj.nil?
        obj.dismantle_items = data[key][obj.id]
      end # for obj
    end # for group
  end # def

  
end # module DataManager



#==========================================================================
# ++ DismantleObj
#==========================================================================
class DismantleObj
  attr_accessor :item
  attr_accessor :chance
  attr_accessor :mask
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize
    @item = :none
    @chance = default_chance
    @mask = default_mask
  end
  #--------------------------------------------------------------------------
  # default_chance
  #--------------------------------------------------------------------------
  def default_chance
    Bubs::Dismantle::DEFAULT_DISMANTLE_CHANCE
  end
  #--------------------------------------------------------------------------
  # default_mask
  #--------------------------------------------------------------------------
  def default_mask
    !Bubs::Dismantle::USE_DISMANTLABLE_ITEMS_MASK
  end
  
end # class DismantleObj



#==========================================================================
# ++ RPG::BaseItem
#==========================================================================
class RPG::BaseItem
  attr_accessor :dismantle_items
  attr_accessor :dismantle_gold_fee
  attr_accessor :dismantle_reagents
  attr_accessor :dismantle_counter
  #--------------------------------------------------------------------------
  # common cache : load_notetags_bubs_dismantle
  #--------------------------------------------------------------------------
  def load_notetags_bubs_dismantle
    @dismantle_items = []
    @dismantle_gold_fee = Bubs::Dismantle::DEFAULT_DISMANTLE_FEE
    @dismantle_reagents = {}
    @dismantle_counter = 0
    
    dismantle_tag = false
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when /<dismantle>/i
        dismantle_tag = true
      when /<\/dismantle>/i
        dismantle_tag = false
      when /(\w+):\s*(\d+)\s*[,:]?\s*(\d+\.?\d*)?/i
        next unless dismantle_tag
        
        new_obj = DismantleObj.new
        
        case $1.upcase
        when "I", "ITEM"
          new_obj.item = $data_items[$2.to_i]
          new_obj.chance = $3.to_f unless $3.nil?
          @dismantle_items.push( new_obj )
          
        when "W", "WEAPON", "WEP"
          new_obj.item = $data_weapons[$2.to_i]
          new_obj.chance = $3.to_f unless $3.nil?
          @dismantle_items.push( new_obj )
          
        when "A", "ARMOR", "ARMOUR", "ARM"
          new_obj.item = $data_armors[$2.to_i]
          new_obj.chance = $3.to_f unless $3.nil?
          @dismantle_items.push( new_obj )
          
        when "F", "FEE"
          @dismantle_gold_fee = $2.to_i
          
        end # case
      end # case
    } # self.note.split
  end
  
  #--------------------------------------------------------------------------
  # new method : dismantlable?
  #--------------------------------------------------------------------------
  def dismantlable?
    return false unless self.is_a?(RPG::Item) || self.is_a?(RPG::EquipItem)
    return true unless @dismantle_items.empty?
    return false
  end
  
  #--------------------------------------------------------------------------
  # new method : set_dismantle_mask_flags
  #--------------------------------------------------------------------------
  def set_dismantle_mask_flags(flag = true)
    return unless self.is_a?(RPG::Item) || self.is_a?(RPG::EquipItem)
    @dismantle_items.each do |obj| obj.mask = flag end
  end
end # class RPG::BaseItem


#==============================================================================
# ++ Window_DismantleShopCommand
#==============================================================================
class Window_DismantleShopCommand < Window_HorzCommand
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(window_width)
    @window_width = window_width
    super(0, 0)
  end
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    @window_width
  end
  
  #--------------------------------------------------------------------------
  # col_max
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  
  #--------------------------------------------------------------------------
  # make_command_list
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::dismantle,  :dismantle)
    add_command(Vocab::ShopCancel, :cancel)
  end
end


#==============================================================================
# ++ Window_DismantleShopItemList
#------------------------------------------------------------------------------
#  This window displays a list of items in possession for dismantling on the 
# shop screen.
#==============================================================================

class Window_DismantleShopItemList < Window_ItemList
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, window_width, height)
  end
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width / 2
  end
  
  #--------------------------------------------------------------------------
  # current_item_enabled?           # Get Activation State of Selection Item
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index])
  end
  
  #--------------------------------------------------------------------------
  # enable?                               # Display in Enabled State?
  #--------------------------------------------------------------------------
  def enable?(item)
    return false if item.nil?
    return false if $game_party.gold < item.dismantle_gold_fee 
    return item.dismantlable?
  end
  
  #--------------------------------------------------------------------------
  # col_max
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  
  #--------------------------------------------------------------------------
  # include?                              # Include in Item List?
  #--------------------------------------------------------------------------
  def include?(item)
    case @category
    when :item
      item.is_a?(RPG::Item) && !item.key_item? && item.dismantlable?
    when :weapon
      item.is_a?(RPG::Weapon) && item.dismantlable?
    when :armor
      item.is_a?(RPG::Armor) && item.dismantlable?
    when :key_item
      item.is_a?(RPG::Item) && item.key_item? && item.dismantlable?
    else
      false
    end
  end

  #--------------------------------------------------------------------------
  # status_window=
  #--------------------------------------------------------------------------
  def status_window=(status_window)
    @status_window = status_window
    call_update_help
  end
  
  #--------------------------------------------------------------------------
  # update_help
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item) if @help_window
    @status_window.item = item if @status_window
  end

end # class Window_DismantleShopItemList


#==============================================================================
# ++ Window_DismantleShopCategory
#==============================================================================
class Window_DismantleShopCategory < Window_HorzCommand
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_reader   :item_window
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0)
  end
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width / 2
  end
  
  #--------------------------------------------------------------------------
  # col_max
  #--------------------------------------------------------------------------
  def col_max
    Bubs::Dismantle::SHOP_CATEGORIES.size
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    super
    @item_window.category = current_symbol if @item_window
  end
  
  #--------------------------------------------------------------------------
  # make_command_list
  #--------------------------------------------------------------------------
  def make_command_list
    config = Bubs::Dismantle::SHOP_CATEGORIES
    add_command(Vocab::item,     :item)     if config.include?(:items)
    add_command(Vocab::weapon,   :weapon)   if config.include?(:weapons)
    add_command(Vocab::armor,    :armor)    if config.include?(:armors)
    add_command(Vocab::key_item, :key_item) if config.include?(:key_items)
  end
  
  #--------------------------------------------------------------------------
  # item_window=
  #--------------------------------------------------------------------------
  def item_window=(item_window)
    @item_window = item_window
    update
  end
  
end # class Window_DismantleShopCategory


#==============================================================================
# ++ Window_DismantleShopInfo
#==============================================================================
class Window_DismantleShopInfo < Window_Base
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @item = nil
    @page_index = 0
    refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_dismantle_counter(4, 0)
    draw_dismantle_fee(4, line_height * 1)
    draw_dismantle_info(4, line_height * 3)
  end
  
  #--------------------------------------------------------------------------
  # draw_dismantle_fee
  #--------------------------------------------------------------------------
  def draw_dismantle_fee(x, y)
    return unless Bubs::Dismantle::SHOW_DISMANTLE_FEE
    rect = Rect.new(x, y, contents.width - 4 - x, line_height)
    change_color(system_color)
    draw_text(rect, Bubs::Dismantle::DISMANTLE_FEE_TEXT)
    if @item
      draw_currency_value(@item.dismantle_gold_fee, Vocab::currency_unit, x, y, contents.width - 4 - x)
    else
      change_color(normal_color)
      draw_text(rect, "-", 2)
    end # if 
  end 
  
  #--------------------------------------------------------------------------
  # draw_dismantle_info
  #--------------------------------------------------------------------------
  def draw_dismantle_info(x, y)
    return unless Bubs::Dismantle::SHOW_DISMANTLABLE_ITEMS_LIST
    rect = Rect.new(x, y, contents.width - 4 - x, line_height)
    change_color(system_color)
    draw_text(rect, Bubs::Dismantle::DISMANTLABLE_ITEMS_LIST_TEXT)
    return unless @item
    @item.dismantle_items.each_with_index do |dism_obj, i|
      if dism_obj.mask
        draw_normal_dismantle_info(dism_obj, x, y + line_height * (i + 1))
      else
        draw_masked_item_info(x, y + line_height * (i + 1))
      end # if
    end # do
  end
  
  #--------------------------------------------------------------------------
  # draw_normal_dismantle_info
  #--------------------------------------------------------------------------
  def draw_normal_dismantle_info(dism_obj, x, y)
    width = Bubs::Dismantle::SHOW_DISMANTLE_CHANCE ? 172 : contents.width
    draw_item_name(dism_obj.item, x, y, true, width)
    draw_dismantle_chance(dism_obj.chance, x, y)
  end
  
  #--------------------------------------------------------------------------
  # draw_masked_item_info
  #--------------------------------------------------------------------------
  def draw_masked_item_info(x, y)
    draw_masked_item_name(x, y)
    draw_masked_dismantle_chance(x, y)
  end
  
  #--------------------------------------------------------------------------
  # draw_masked_item_name
  #--------------------------------------------------------------------------
  def draw_masked_item_name(x, y)
    draw_icon(Bubs::Dismantle::DISMANTLABLE_ITEMS_MASK_ICON_ID, x, y)
    change_color(normal_color)
    draw_text(x + 24, y, width, line_height, Bubs::Dismantle::DISMANTLABLE_ITEMS_MASK)
  end
  
  #--------------------------------------------------------------------------
  # draw_masked_dismantle_chance
  #--------------------------------------------------------------------------
  def draw_masked_dismantle_chance(x, y)
    return unless Bubs::Dismantle::SHOW_DISMANTLE_CHANCE
    rect = Rect.new(x, y + 3, contents.width - 4 - x, line_height)
    contents.font.size = 16
    draw_text(rect, Bubs::Dismantle::DISMANTLABLE_ITEMS_CHANCE_MASK, 2)
    contents.font.size = Font.default_size
  end
  
  #--------------------------------------------------------------------------
  # draw_dismantle_chance
  #--------------------------------------------------------------------------
  def draw_dismantle_chance(chance, x, y)
    return unless Bubs::Dismantle::SHOW_DISMANTLE_CHANCE
    rect = Rect.new(x, y + 3, contents.width - 4 - x, line_height)
    contents.font.size = 16
    draw_text(rect, sprintf("%3.1f%%", chance), 2)
    contents.font.size = Font.default_size
  end
  
  #--------------------------------------------------------------------------
  # item=                                        # Set Item
  #--------------------------------------------------------------------------
  def item=(item)
    @item = item
    refresh
  end
  
  #--------------------------------------------------------------------------
  # draw_dismantle_counter
  #--------------------------------------------------------------------------
  def draw_dismantle_counter(x, y)
    rect = Rect.new(x, y, contents.width - 4 - x, line_height)
    change_color(system_color)
    draw_text(rect, Bubs::Dismantle::DISMANTLABLE_COUNTER_TEXT)
    change_color(normal_color)
    counter = @item ? @item.dismantle_counter : "-"
    draw_text(rect, counter.to_s, 2)
  end

end # class Window_DismantleShopInfo


#==============================================================================
# ++ Window_DismantleShopConfirm
#==============================================================================
class Window_DismantleShopConfirm < Window_Command
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0)
  end
  
  #--------------------------------------------------------------------------
  # make_command_list
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::dismantle,   :ok)
    add_command(Vocab::ShopCancel, :cancel)
  end
  
end # class Window_DismantleShopConfirm


#==============================================================================
# ++ Window_DismantleResults
#==============================================================================
class Window_DismantleResults < Window_ItemList
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y)
    @gained_items = []
    super(x, y, window_width, window_height)
  end
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width / 2
  end
  
  #--------------------------------------------------------------------------
  # window_height
  #--------------------------------------------------------------------------
  def window_height
    fitting_height( [[@gained_items.uniq.size, 1].max, 8].min )
  end
  
  #--------------------------------------------------------------------------
  # current_item_enabled?
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index])
  end
  
  #--------------------------------------------------------------------------
  # enable?                                 # Display in Enabled State?
  #--------------------------------------------------------------------------
  def enable?(item)
    true
  end
  
  #--------------------------------------------------------------------------
  # col_max
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  
  #--------------------------------------------------------------------------
  # items=
  #--------------------------------------------------------------------------
  def items=(item_array)
    @gained_items = item_array
    refresh
  end
  
  #--------------------------------------------------------------------------
  # clear
  #--------------------------------------------------------------------------
  def clear
    @gained_items = []
  end

  #--------------------------------------------------------------------------
  # make_item_list
  #--------------------------------------------------------------------------
  def make_item_list
    @data = @gained_items.uniq
  end
  
  #--------------------------------------------------------------------------
  # draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enable?(item))
      draw_gained_item_number(rect, item)
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_gained_item_number
  #--------------------------------------------------------------------------
  def draw_gained_item_number(rect, item)
    draw_text(rect, sprintf(":%2d", @gained_items.count(item)), 2)
  end

  #--------------------------------------------------------------------------
  # status_window=                          # Set Status Window
  #--------------------------------------------------------------------------
  def status_window=(status_window)
    @status_window = status_window
    call_update_help
  end
  
  #--------------------------------------------------------------------------
  # update_help                             # Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item) if @help_window
    @status_window.item = item if @status_window
  end

end # Window_DismantleResults


#==============================================================================
# ++ Window_DismantleResultsHeader
#==============================================================================
class Window_DismantleResultsHeader < Window_Base
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, window_width, window_height)
    refresh
  end
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width / 2
  end
  
  #--------------------------------------------------------------------------
  # window_height
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(1)
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_dismantle_header_text(4, 0)
  end
  
  #--------------------------------------------------------------------------
  # draw_dismantle_header_text
  #--------------------------------------------------------------------------
  def draw_dismantle_header_text(x, y)
    rect = Rect.new(x, y, contents.width - 4 - x, line_height)
    change_color(system_color)
    draw_text(rect, Bubs::Dismantle::RESULTS_HEADER_TEXT, 1)
  end
  
end # class Window_DismantleResultsHeader


#==============================================================================
# ++ Game_Interpreter
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # new method : call_dismantle_scene
  #--------------------------------------------------------------------------
  def call_dismantle_scene
    SceneManager.call(Scene_DismantleShop)
  end
  alias open_dismantle_shop call_dismantle_scene
  #--------------------------------------------------------------------------
  # new method : remove_dismantle_mask
  #--------------------------------------------------------------------------
  def remove_dismantle_mask(key, id)
    case key
    when :item
      $data_items[id].set_dismantle_mask_flags(true)
    when :armor
      $data_armors[id].set_dismantle_mask_flags(true)
    when :weapon
      $data_weapons[id].set_dismantle_mask_flags(true)
    end
  end
  
  #--------------------------------------------------------------------------
  # new method : remove_all_dismantle_masks
  #--------------------------------------------------------------------------
  def remove_all_dismantle_masks
    groups = [$data_items, $data_armors, $data_weapons]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.set_dismantle_mask_flags(true)
      end # for
    end # for
  end # def 
  
  #--------------------------------------------------------------------------
  # new method : get_dismantle_count
  #--------------------------------------------------------------------------
  def get_dismantle_count(key, id)
    case key
    when :item
      $data_items[id].dismantle_counter
    when :armor
      $data_armors[id].dismantle_counter
    when :weapon
      $data_weapons[id].dismantle_counter
    end # case
  end # def
  
  #--------------------------------------------------------------------------
  # new method : get_all_dismantle_count
  #--------------------------------------------------------------------------
  def get_all_dismantle_count
    count = 0
    groups = [$data_items, $data_armors, $data_weapons]
    for group in groups
      for obj in group
        next if obj.nil?
        count += obj.dismantle_counter
      end # for
    end # for
    return count
  end # def
  
end # class Game_Interpreter


#==============================================================================
# ++ Scene_DismantleShop
#==============================================================================
class Scene_DismantleShop < Scene_MenuBase
  #--------------------------------------------------------------------------
  # start
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_gold_window
    create_command_window
    create_dummy_window
    create_info_window
    create_category_window
    create_itemlist_window
    create_dummy2_window
    create_confirm_window
    create_results_header_window
    create_results_window
  end
  
  #--------------------------------------------------------------------------
  # create_results_window
  #--------------------------------------------------------------------------
  def create_results_header_window
    wx = Graphics.width / 4
    wy = @category_window.y - 24
    @header_window = Window_DismantleResultsHeader.new(wx, wy)
    @header_window.viewport = @viewport
    @header_window.hide
  end
  
  #--------------------------------------------------------------------------
  # create_results_window
  #--------------------------------------------------------------------------
  def create_results_window
    wx = Graphics.width / 4
    wy = @header_window.y + @header_window.height
    @results_window = Window_DismantleResults.new(wx, wy)
    @results_window.viewport = @viewport
    @results_window.help_window = @help_window
    @results_window.hide
    @results_window.close
    @results_window.set_handler(:ok,     method(:on_results_ok))
    @results_window.set_handler(:cancel, method(:on_results_cancel))
  end
    
  #--------------------------------------------------------------------------
  # create_dummy2_window
  #--------------------------------------------------------------------------
  def create_dummy2_window
    wx = @itemlist_window.width
    wy = @gold_window.y + @gold_window.height
    wh = Graphics.height - wy
    ww = Graphics.width - wx
    @dummy2_window = Window_Base.new(wx, wy, ww, wh)
    @dummy2_window.viewport = @viewport
    @dummy2_window.hide
  end
  
  #--------------------------------------------------------------------------
  # create_confirm_window
  #--------------------------------------------------------------------------
  def create_confirm_window
    @confirm_window = Window_DismantleShopConfirm.new
    @confirm_window.viewport = @viewport
    @confirm_window.x = (Graphics.width / 2) - @confirm_window.width / 2
    @confirm_window.y = (Graphics.height / 2) - @confirm_window.height / 2
    @confirm_window.set_handler(:ok,     method(:on_confirm_ok))
    @confirm_window.set_handler(:cancel, method(:on_confirm_cancel))
    @confirm_window.hide
  end

  #--------------------------------------------------------------------------
  # create_gold_window
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_Gold.new
    @gold_window.viewport = @viewport
    @gold_window.x = Graphics.width - @gold_window.width
    @gold_window.y = @help_window.height
  end
  
  #--------------------------------------------------------------------------
  # create_command_window
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_DismantleShopCommand.new(@gold_window.x)
    @command_window.viewport = @viewport
    @command_window.y = @help_window.height
    @command_window.set_handler(:dismantle,   method(:command_dismantle))
    @command_window.set_handler(:cancel,      method(:return_scene))
  end
  
  #--------------------------------------------------------------------------
  # create_dummy_window
  #--------------------------------------------------------------------------
  def create_dummy_window
    wy = @command_window.y + @command_window.height
    wh = Graphics.height - wy
    @dummy_window = Window_Base.new(0, wy, Graphics.width, wh)
    @dummy_window.viewport = @viewport
  end
  
  #--------------------------------------------------------------------------
  # create_info_window
  #--------------------------------------------------------------------------
  def create_info_window
    wx = Graphics.width / 2
    wy = @dummy_window.y
    ww = Graphics.width - wx
    wh = @dummy_window.height
    @info_window = Window_DismantleShopInfo.new(wx, wy, ww, wh)
    @info_window.viewport = @viewport
    @info_window.hide
  end

  #--------------------------------------------------------------------------
  # create_category_window
  #--------------------------------------------------------------------------
  def create_category_window
    @category_window = Window_DismantleShopCategory.new
    @category_window.viewport = @viewport
    @category_window.help_window = @help_window
    @category_window.y = @dummy_window.y
    @category_window.hide.deactivate
    @category_window.set_handler(:ok,     method(:on_category_ok))
    @category_window.set_handler(:cancel, method(:on_category_cancel))
  end
  
  #--------------------------------------------------------------------------
  # create_itemlist_window
  #--------------------------------------------------------------------------
  def create_itemlist_window
    wy = @category_window.y + @category_window.height
    wh = Graphics.height - wy
    @itemlist_window = Window_DismantleShopItemList.new(0, wy, Graphics.width, wh)
    @itemlist_window.viewport = @viewport
    @itemlist_window.help_window = @help_window
    @itemlist_window.status_window = @info_window
    @itemlist_window.hide
    @itemlist_window.set_handler(:ok,     method(:on_itemlist_ok))
    @itemlist_window.set_handler(:cancel, method(:on_itemlist_cancel))
    @category_window.item_window = @itemlist_window
  end

  #--------------------------------------------------------------------------
  # activate_itemlist_window
  #--------------------------------------------------------------------------
  def activate_itemlist_window
    @category_window.show
    @itemlist_window.show.activate
    @itemlist_window.select_last
    refresh
  end

  #--------------------------------------------------------------------------
  # command_dismantle
  #--------------------------------------------------------------------------
  def command_dismantle
    @dummy_window.hide
    @category_window.show.activate
    @itemlist_window.show
    @itemlist_window.unselect
    @dummy2_window.show
    refresh
  end

  #--------------------------------------------------------------------------
  # on_category_ok
  #--------------------------------------------------------------------------
  def on_category_ok
    activate_itemlist_window
    @info_window.show
    @dummy2_window.hide
    @itemlist_window.select(0)
  end
  
  #--------------------------------------------------------------------------
  # on_category_cancel
  #--------------------------------------------------------------------------
  def on_category_cancel
    @command_window.activate
    @dummy_window.show
    @category_window.hide
    @itemlist_window.hide
    @dummy2_window.hide
  end
  
  #--------------------------------------------------------------------------
  # on_itemlist_ok
  #--------------------------------------------------------------------------
  def on_itemlist_ok
    @item = @itemlist_window.item
    $game_party.last_item.object = @item
    @info_window.item = @item
    @confirm_window.show.activate
  end
  
  #--------------------------------------------------------------------------
  # on_itemlist_cancel
  #--------------------------------------------------------------------------
  def on_itemlist_cancel
    @info_window.hide
    @dummy2_window.show
    @itemlist_window.unselect
    @category_window.activate
    @help_window.clear
  end
  
  #--------------------------------------------------------------------------
  # on_results_ok
  #--------------------------------------------------------------------------
  def on_results_ok
    @header_window.hide
    @results_window.close
    @results_window.clear
    @results_window.hide
    activate_itemlist_window
  end
  
  #--------------------------------------------------------------------------
  # on_results_cancel
  #--------------------------------------------------------------------------
  def on_results_cancel
    on_results_ok
  end
  
  #--------------------------------------------------------------------------
  # on_confirm_ok
  #--------------------------------------------------------------------------
  def on_confirm_ok
    @confirm_window.hide
    process_dismantle
  end
  
  #--------------------------------------------------------------------------
  # on_confirm_cancel
  #--------------------------------------------------------------------------
  def on_confirm_cancel
    activate_itemlist_window
    @info_window.show
    @confirm_window.hide
  end
  
  #--------------------------------------------------------------------------
  # process_dismantle
  #--------------------------------------------------------------------------
  def process_dismantle
    return unless @item
    $game_party.last_item.object = @item
    @item.dismantle_counter += 1
    $game_party.lose_item(@item, 1)
    $game_party.lose_gold(@item.dismantle_gold_fee)
    gained_items = determine_dismantled_items
    gain_dismantled_items(gained_items)
    @results_window.items = gained_items
    @results_window.height = @results_window.window_height
    @header_window.show
    @results_window.open
    @results_window.show.activate.select(0)
    Sound.play_dismantle
    refresh
  end
  
  #--------------------------------------------------------------------------
  # determine_dismantled_items
  #--------------------------------------------------------------------------
  def determine_dismantled_items
    gained_items = []
    @item.dismantle_items.each_with_index do |dism_obj, index| 
      if rand < (dism_obj.chance * 0.01)
        gained_items.push(dism_obj.item)
        dism_obj.mask = true
      end
    end
    return gained_items
  end
  
  #--------------------------------------------------------------------------
  # gain_dismantled_items
  #--------------------------------------------------------------------------
  def gain_dismantled_items(items)
    items.each do |item|
      $game_party.gain_item(item, 1)
    end
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    @results_window.refresh
    @gold_window.refresh
    @info_window.refresh
    @header_window.refresh
    @help_window.refresh
    @itemlist_window.refresh
  end
  
  #--------------------------------------------------------------------------
  # currency_unit
  #--------------------------------------------------------------------------
  def currency_unit
    @gold_window.currency_unit
  end
  
end # class Scene_DismantleShop