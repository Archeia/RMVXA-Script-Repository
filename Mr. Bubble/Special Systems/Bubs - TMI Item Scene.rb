# ╔══════════════════════════════════════════════════════╤═══════╤═══════════╗
# ║ Too Much Information Item Scene                      │ v1.01 │ (5/22/13) ║
# ╚══════════════════════════════════════════════════════╧═══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
# Thanks:
#     Tsukihime, Tag Manager script
#--------------------------------------------------------------------------
# This script remodels the item scene so that more information about 
# items may be viewed by players. People familiar with my Tactics
# Ogre PSP Crafting System script will find the window aesthetic
# similar in style.
# 
# The type of information you can provide players is customized in the 
# Info Pages Window's customization module. 
# 
# Additionally, this script significantly changes the category selection 
# function in the item scene. By default, players must select a category
# before being able to view their inventory. With this script, players
# may select items immediately after entering the item scene. The
# item category is changed by using other gamepad buttons. This makes
# the inventory interface more inline with console RPGs.
# 
# More item category filters can be made with Tsukihime's Tag Manager 
# script.
#--------------------------------------------------------------------------
#      Changelog   
#--------------------------------------------------------------------------
# v1.01 : Compatibility Update: Tsukihime's "Inventory Sorting". (5/22/2013)
# v1.00 : Initial release. (4/14/2013)
#--------------------------------------------------------------------------
#      Installation and Requirements
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor. This script is not plug-and-play and requires 
# multiple other scripts in order to function.
#
#     "Info Pages Window" - by Mr. Bubble
#         http://wp.me/PxlCT-tA
#     "Reader Functions for Features/Effects" v1.4+ - by Mr. Bubble
#         http://wp.me/PxlCT-rC
#     
# Additionally, I recommend installing two extra, optional scripts in 
# order to fully utilize some settings in this script:
#
#     "Tag Manager" - by Tsukihime
#         http://himeworks.wordpress.com/2013/03/07/tag-manager/
#     "Text Cache" - by Mithran
#         http://forums.rpgmakerweb.com/index.php?/topic/1001-text-cache/
#--------------------------------------------------------------------------
#      Compatibility
#--------------------------------------------------------------------------
# This script overwrites the following default VXA methods:
#
#     Scene_Item#start
#     Scene_Item#create_category_window
#     Scene_Item#create_item_window
#     Scene_Item#on_item_cancel
#
# Built-in script compatibility with:
#
#     -Tsukihime's "Inventory Sorting"
#
# This script will have issues with other scripts that also modify the 
# default item scene.
#--------------------------------------------------------------------------
#      Terms and Conditions   
#--------------------------------------------------------------------------
# Please do not repost this script elsewhere without permission. 
# Free for non-commercial use. For commercial use, contact me first.
#
# Newest versions of this script can be found at 
#                                           http://mrbubblewand.wordpress.com/
#=============================================================================

$imported ||= {}
$imported["Bubs_TMI_ItemScene"] = 1.01

#==========================================================================
# ++ START OF USER CUSTOMIZATION MODULE ++
#==========================================================================
module Bubs
  #==========================================================================
  # ++ TMI Item Scene Settings
  #==========================================================================
  module TMI_ItemScene
  #--------------------------------------------------------------------------
  #   Item Scene Categories
  #--------------------------------------------------------------------------
  # This setting determines which categories appear in the item scene.
  # The order of symbols in the array determines
  # the order seen in the item scene.
  #
  # Custom categories can only be used if Tsukihime's Tag Manager
  # script is also installed. Define new categories in the 
  # TSUKIHIME_CATEGORY_TAGS setting. For example, if :sword is
  # defined in TSUKIHIME_CATEGORY_TAGS, you may add :sword into the
  # CATEGORIES array.
  #
  # There is no limit on the amount of symbols you may list in the array.
  #
  # Default category symbols:
  #   :all, :item, :weapon, :armor, :key_item
  CATEGORIES = [:all, :item, :weapon, :armor, :key_item]
  
  #--------------------------------------------------------------------------
  #   Custom Category Definitions
  #--------------------------------------------------------------------------
  # !! This section requires Tsukihime's Tag Manager script. !!
  #
  # This setting allows you to create custom categories based on the
  # tags you give them. For more information, please read the comments 
  # in the Tag Manager script.
  #
  # For example, if a weapon has the tag '<tag: sword, metal>' in its notebox, 
  # it will appear under any category which has "sword" or "metal" in 
  # its tag array.
  #
  # The pre-defined categories here serve as examples and can be freely
  # modified.
  CATEGORY_TAGS = {
  # :symbol         => ["string1", "string2", ...],
    :sword          => ["sword", "rapier", "great sword"],
    :polearm        => ["spear", "polearm", "scythe"],
    :axe            => ["axe", "ax", "great axe", "hatchet"],
    :staff          => ["staff", "stave", "cane"],
    :light_armor    => ["robe", "light_armor", "dress", "shirt"],
    :heavy_armor    => ["chain_mail", "mail", "plate_mail", "heavy_armor"],
    :shield         => ["shield", "buckler"],
    :accessory      => ["ring", "brooch", "necklace", "medal"],
    # Define more categories here!
    
  } # <- Do not delete.
  
  #--------------------------------------------------------------------------
  #   Category Icons
  #--------------------------------------------------------------------------
  # This setting lets you define which icons represent a category.
  # The format for creating a new entry is:
  #   
  #       :symbol => icon_index,
  #
  # where :symbol is a symbol from CATEGORY_TAGS hash.
  CATEGORY_ICONS = {
    # Default category icons
    :all          => 270,
    :item         => 192,
    :weapon       => 147,
    :armor        => 170,
    :key_item     => 243,
    # Custom category icons
    :sword        => 147,
    :polearm      => 146,
    :staff        => 152,
    :axe          => 144,
    :shield       => 506,
    :light_armor  => 183,
    :heavy_armor  => 170,
    # Define more icons here
    
  } # <- Do not delete.
  
  #--------------------------------------------------------------------------
  #   Default Category Icon
  #--------------------------------------------------------------------------
  # If a category icon index number is not defined in CATEGORY_ICONS, it will
  # use this default index.
  CATEGORY_ICONS.default = 261
  
  #--------------------------------------------------------------------------
  #   Category Background Icon
  #--------------------------------------------------------------------------
  # This setting defines the icon displayed behind category icons. If set 
  # to 0, a background icon will not be used.
  CATEGORY_ICON_BACKGROUND = 16
  
  #--------------------------------------------------------------------------
  #   Item Scene Button Settings
  #--------------------------------------------------------------------------
  # This setting determine which gamepad buttons change aspects of the
  # item scene such as changing categories or changing the info window.
  # Default buttons that you can use include: 
  #
  # :LEFT, :RIGHT
  # :A, :B, :C, :X, :Y, :Z, :L, :R
  # :SHIFT, :CTRL, :ALT 
  ITEM_SCENE_BUTTONS = {
    :next_category      => :RIGHT,
    :prev_category      => :LEFT,
    :itemlist_pagedown  => :R,
    :itemlist_pageup    => :L,
  } # <- Do not delete.
  
  #--------------------------------------------------------------------------
  #   Button Icons
  #--------------------------------------------------------------------------
  # This setting defines the icons used to represent buttons in the item
  # scene.
  BUTTON_ICONS = {
    :next_category      => 0, # Next Category Button Icon
    :prev_category      => 0, # Previous Category Button Icon
  } # <- Do not delete.
  
  #--------------------------------------------------------------------------
  #   Category Change Sound Effect
  #--------------------------------------------------------------------------
  # Filename : SE filename in Audio/SE/ folder
  # Volume   : Between 0~100
  # Pitch    : Between 50~150
  #
  #                      Filename, Volume, Pitch
  CATEGORY_CHANGE_SE = ["Cursor1",     80,   100]
  
  end # module TMI_ItemScene
end # module Bubs


#==========================================================================
# ++ END OF USER CUSTOMIZATION MODULE ++
#==========================================================================


#==============================================================================
# ++ Sound
#==============================================================================
module Sound
  #--------------------------------------------------------------------------
  # new method : play_tmi_category_change
  #--------------------------------------------------------------------------
  def self.play_tmi_category_change
    filename = Bubs::TMI_ItemScene::CATEGORY_CHANGE_SE[0]
    volume   = Bubs::TMI_ItemScene::CATEGORY_CHANGE_SE[1]
    pitch    = Bubs::TMI_ItemScene::CATEGORY_CHANGE_SE[2]
    Audio.se_play("Audio/SE/" + filename, volume, pitch) 
  end
end # module Sound



#==============================================================================
# ++ Window_TMI_ItemCategory
#==============================================================================
class Window_TMI_ItemCategory < Window_Base
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    self.opacity = 0
    @category_index = 0
    initialize_categories
    adjust_index_range
    refresh
  end
  
  #--------------------------------------------------------------------------
  # initialize_categories
  #--------------------------------------------------------------------------
  def initialize_categories
    @category_symbols = Bubs::TMI_ItemScene::CATEGORIES
    @category = @category_symbols[@category_index]
  end
  
  #--------------------------------------------------------------------------
  # category=
  #--------------------------------------------------------------------------
  def category=(symbol)
    @category = symbol
    @category_index = @category_symbols.index(@category)
    refresh
  end
    
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_horz_line(line_height)
    adjust_index_range
    draw_category_icons
    draw_category_button_icons(0, 0)
  end
   
  #--------------------------------------------------------------------------
  # draw_horz_line
  #--------------------------------------------------------------------------
  def draw_horz_line(y)
    line_y = y + line_height / 2 - 1
    color = normal_color
    color.alpha = 48
    contents.fill_rect(0, line_y, contents_width, 2, color)
  end
  
  #--------------------------------------------------------------------------
  # draw_category_icons
  #--------------------------------------------------------------------------
  def draw_category_icons
    x = (contents_width / 2) - (icon_row_width / 2) - icon_adjustment
    for index in @index_range[0]..@index_range[1]
      bool = index == @category_index
      x += icon_width
      draw_icon(16, x, 0, bool)
      draw_icon(category_icon_index(index), x, 0, bool)
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_category_button_icons
  #--------------------------------------------------------------------------
  def draw_category_button_icons(x, y)
    draw_icon(category_button_icon_index(:prev_category), x, y)
    x = x + contents_width - icon_width
    draw_icon(category_button_icon_index(:next_category), x, y)
  end
  
  #--------------------------------------------------------------------------
  # category_button_icon_index
  #--------------------------------------------------------------------------
  def category_button_icon_index(symbol)
    Bubs::TMI_ItemScene::BUTTON_ICONS[symbol]
  end
  
  #--------------------------------------------------------------------------
  # icon_adjustment
  #--------------------------------------------------------------------------
  def icon_adjustment
    return 25
  end
  
  #--------------------------------------------------------------------------
  # icon_width
  #--------------------------------------------------------------------------
  def icon_width
    return 24
  end
  
  #--------------------------------------------------------------------------
  # icon_row_width
  #--------------------------------------------------------------------------
  def icon_row_width
    icon_width * icon_max
  end
  
  #--------------------------------------------------------------------------
  # icon_max
  #--------------------------------------------------------------------------
  def icon_max
    num = @category_symbols.size
    return [10, num].min if Graphics.width == 640
    return [8, num].min
  end
  
  #--------------------------------------------------------------------------
  # icon_by_index
  #--------------------------------------------------------------------------
  def category_icon_index(index)
    Bubs::TMI_ItemScene::CATEGORY_ICONS[@category_symbols[index]]
  end
  
  #--------------------------------------------------------------------------
  # adjust_index_range
  #--------------------------------------------------------------------------
  def adjust_index_range
    sz = @category_symbols.size - 1
    if @category_index == 0
      @index_range = initial_range
    elsif @category_index == sz
      @index_range = final_range
    elsif @category_index > @index_range[1]
      @index_range[0] += 1
      @index_range[1] += 1
    elsif @category_index < @index_range[0]
      @index_range[0] -= 1
      @index_range[1] -= 1
    end
  end
  
  #--------------------------------------------------------------------------
  # initial_range
  #--------------------------------------------------------------------------
  def initial_range
    [0, icon_max - 1]
  end
  
  #--------------------------------------------------------------------------
  # final_range
  #--------------------------------------------------------------------------
  def final_range
    [@category_symbols.size - icon_max, @category_symbols.size - 1]
  end

end # class Window_TMI_ItemCategory



#==============================================================================
# ++ Window_TMI_ItemList
#==============================================================================
class Window_TMI_ItemList < Window_ItemList
  attr_accessor :category_index
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    self.opacity = 0
    @category_index = 0
    initialize_categories
    refresh
  end
  #--------------------------------------------------------------------------
  # initialize_categories
  #--------------------------------------------------------------------------
  def initialize_categories
    @category_keys = Bubs::TMI_ItemScene::CATEGORIES
    @category = @category_keys[@category_index]
  end
  
  #--------------------------------------------------------------------------
  # update_help
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item)
    @info_window.item = item if @info_window
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    make_item_list
    create_contents
    draw_all_items
    @category_window.category = @category if @category_window
    call_update_help
  end
  
  #--------------------------------------------------------------------------
  # info_window=
  #--------------------------------------------------------------------------
  def info_window=(info_window)
    @info_window = info_window
  end
  
  #--------------------------------------------------------------------------
  # category_window=
  #--------------------------------------------------------------------------
  def category_window=(category_window)
    @category_window = category_window
  end

  #--------------------------------------------------------------------------
  # col_max
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  
  #--------------------------------------------------------------------------
  # item_max                                    # Get Number of Items
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #--------------------------------------------------------------------------
  # item                                          # Get Item
  #--------------------------------------------------------------------------
  def item
    @data && index >= 0 ? @data[index] : nil
  end
  
  #--------------------------------------------------------------------------
  # current_item_enabled?         # Get Activation State of Selection Item
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index])
  end
  
  #--------------------------------------------------------------------------
  # include?                              # Include in Item List?
  #--------------------------------------------------------------------------
  def include?(item)
    if $imported["Tsuki_TagManager"] && category_tags.include?(@category)
      return has_tag?(item)
    end
    
    case @category
    when :all
      true
    when :item
      item.is_a?(RPG::Item) && !item.key_item?
    when :weapon
      item.is_a?(RPG::Weapon)
    when :armor
      item.is_a?(RPG::Armor)
    when :key_item
      item.is_a?(RPG::Item) && item.key_item?
    else
      false
    end
  end
  
  #--------------------------------------------------------------------------
  # has_tag?          # Check if item has matching tag string
  #--------------------------------------------------------------------------
  def has_tag?(item)
    return false unless item
    return false unless category_tags.include?(@category)
    category_tags[@category].each do |string|
      return true if item.object_tags.include?(string.downcase)
    end
    return false
  end
  
  #--------------------------------------------------------------------------
  # category_tags
  #--------------------------------------------------------------------------
  def category_tags
    Bubs::TMI_ItemScene::CATEGORY_TAGS
  end
  
  #--------------------------------------------------------------------------
  # enable?                       # Display in Enabled State?
  #--------------------------------------------------------------------------
  def enable?(item)
    $game_party.usable?(item)
  end
  #--------------------------------------------------------------------------
  # make_item_list                    # Create Item List
  #--------------------------------------------------------------------------
  def make_item_list
    @data = $game_party.all_items.select {|item| include?(item) }
    sort_list if $imported["Tsuki_InventorySort"]
  end
  
  #--------------------------------------------------------------------------
  # select_last                   # Restore Previous Selection Position
  #--------------------------------------------------------------------------
  def select_last
    select(@data.index($game_party.last_item.object) || 0)
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
      draw_item_number(rect, item)
    end
  end
  #--------------------------------------------------------------------------
  # draw_item_number                        # Draw Number of Items
  #--------------------------------------------------------------------------
  def draw_item_number(rect, item)
    draw_text(rect, sprintf(":%2d", $game_party.item_number(item)), 2)
  end
  
  #--------------------------------------------------------------------------
  # next_category_button
  #--------------------------------------------------------------------------
  def next_category_button
    Bubs::TMI_ItemScene::ITEM_SCENE_BUTTONS[:next_category]
  end
  
  #--------------------------------------------------------------------------
  # prev_category_button
  #--------------------------------------------------------------------------
  def prev_category_button
    Bubs::TMI_ItemScene::ITEM_SCENE_BUTTONS[:prev_category]
  end
  
  #--------------------------------------------------------------------------
  # cursor_pagedown_button
  #--------------------------------------------------------------------------
  def cursor_pagedown_button
    Bubs::TMI_ItemScene::ITEM_SCENE_BUTTONS[:itemlist_pagedown]
  end
  
  #--------------------------------------------------------------------------
  # cursor_pageup_button
  #--------------------------------------------------------------------------
  def cursor_pageup_button
    Bubs::TMI_ItemScene::ITEM_SCENE_BUTTONS[:itemlist_pageup]
  end  
  #--------------------------------------------------------------------------
  # process_cursor_move                   # Cursor Movement Processing
  #--------------------------------------------------------------------------
  def process_cursor_move
    change_category(1)   if Input.trigger?(next_category_button)
    change_category(-1)    if Input.trigger?(prev_category_button)
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_pagedown   if Input.trigger?(cursor_pagedown_button)
    cursor_pageup     if Input.trigger?(cursor_pageup_button)
    Sound.play_cursor if @index != last_index
  end
  
  #--------------------------------------------------------------------------
  # change_category
  #--------------------------------------------------------------------------
  def change_category(value = 0)
    @category_index += value
    @category_index = @category_index % @category_keys.size
    @category = @category_keys[@category_index]
    self.select(0)
    Sound.play_tmi_category_change
    refresh
  end
  
end # class Window_TMI_ItemList



#==============================================================================
# ++ Scene_Item
#------------------------------------------------------------------------------
#  This class performs the item screen processing.
#==============================================================================
class Scene_Item < Scene_ItemBase
  #--------------------------------------------------------------------------
  # overwrite : start
  #--------------------------------------------------------------------------
  def start
    super
    check_tmi_scripts
    create_help_window
    create_dummy_window
    create_category_window
    create_info_window
    create_item_window
  end
  
  #--------------------------------------------------------------------------
  # new method : check_tmi_scripts
  #--------------------------------------------------------------------------
  def check_tmi_scripts
    return if $imported["BubsInfoPages"]
    msgbox("TMI Item Scene requires the script \"Info Pages Window\"\n
    Find it at http://mrbubblewand.wordpress.com/")
    exit
  end
  
  #--------------------------------------------------------------------------
  # new method : create_dummy_window
  #--------------------------------------------------------------------------
  def create_dummy_window
    wy = @help_window.height
    ww = Graphics.width / 2
    wh = Graphics.height - wy
    @dummy_window = Window_Base.new(0, wy, ww, wh)
    @dummy_window.viewport = @viewport
  end
  
  #--------------------------------------------------------------------------
  # overwrite : create_category_window
  #--------------------------------------------------------------------------
  def create_category_window
    wx = 0
    wy = @help_window.height
    ww = Graphics.width / 2
    wh = @help_window.height
    @category_window = Window_TMI_ItemCategory.new(wx, wy, ww, wh)
    @category_window.viewport = @viewport
  end  
  #--------------------------------------------------------------------------
  # new method : create_category_window
  #--------------------------------------------------------------------------
  def create_info_window
    wx = Graphics.width / 2
    wy = @help_window.height
    ww = Graphics.width / 2
    wh = Graphics.height - wy
    @info_window = Window_InfoPages.new(wx, wy, ww, wh)
    @info_window.viewport = @viewport
  end

  #--------------------------------------------------------------------------
  # overwrite : create_item_window
  #--------------------------------------------------------------------------
  def create_item_window
    wy = @help_window.height * 2 - 24
    wh = Graphics.height - wy
    @item_window = Window_TMI_ItemList.new(0, wy, Graphics.width / 2, wh)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:return_scene))
    @item_window.category_window = @category_window
    @item_window.info_window = @info_window
    @item_window.activate.select(0)
  end

  #--------------------------------------------------------------------------
  # inherit overwrite : on_item_cancel
  #--------------------------------------------------------------------------
  def on_item_cancel
  end
  
  #--------------------------------------------------------------------------
  # inherit overwrite : cursor_left? # Determine if Cursor Is in Left Column
  #--------------------------------------------------------------------------
  def cursor_left?
    return true
  end
  
end # class Scene_Item
