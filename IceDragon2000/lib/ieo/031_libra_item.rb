#encoding:UTF-8
#==============================================================================#
# ** IEO(Icy Engine Omega) - Libra Item
#-*--------------------------------------------------------------------------*-#
# ** Author        : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Change (Item Scene)
# ** Script Type   : Item Scene Mod
# ** Date Created  : 04/09/2011
# ** Date Modified : 04/12/2011
# ** Script Tag    : IEO-031(Libra Item)
# ** Difficulty    : Easy, Medium, Lunatic
# ** Version       : 1.0
# ** IEO ID        : 031
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# ** CREDITS/USED STUFF/EDITING
#-*--------------------------------------------------------------------------*-#
# You may:
# Edit and Adapt this script as long you credit aforementioned author(s).
#
# You may not:
# Claim this as your own work, or redistribute without the consent of the author.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#-*--------------------------------------------------------------------------*-#
# @.@ My head hurts...
# Okay this here script is a rewrite of the Item Scene, it changes a few
# things like the windows drawing methods, and adds some item catergorizing.
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#-*--------------------------------------------------------------------------*-#
#
# Breaks a lot of the core methods in the Scene_Item, and Window_Item
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#-*--------------------------------------------------------------------------*-#
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
#
#-*--------------------------------------------------------------------------*-#
# Below
#   Materials
#
# Above
#   Main
#   Everything else
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES
#-*--------------------------------------------------------------------------*-#
# Classes
#   RPG::BaseItem
#     new-method   :ieo031_baseitemcache
#   RPG::Weapon
#     new-method   :ieo031_weaponcache
#   RPG::Armor
#     new-method   :ieo031_armorcache
#   RPG::Item
#     new-method   :ieo031_itemcache
#   Game_System
#     alias-method :initialize
#   Window_Item
#     overwrite    :initilaize
#     overwrite    :include?
#     overwrite    :refresh
#     overwrite    :item_rect
#     overwrite    :draw_item
#     alias-method :update
#   Scene_Title
#     alias-method :load_database
#     alias-method :load_bt_database
#     new-method   :load_ieo031_cache
#   Scene_Item
#     overwrite    :initilaize
#     overwrite    :start
#     overwrite    :return_scene
#     overwrite    :update
#     overwrite    :update_item_selection
#     alias-method :terminate
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#-*--------------------------------------------------------------------------*-#
# (DD/MM/YYYY)
#  04/09/2011 - V1.0  Started Script
#  04/12/2011 - V1.0  Finished Script
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#
#  Breaks stuff, lots of stuff with the item scene, and window
#
#------------------------------------------------------------------------------#
#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
($imported ||= {})["IEO-LibraItem"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
($ieo_script = {})[[31, "LibraItem"]] = 1.0
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
#==============================================================================#
# IEO::ITEM_SYSTEM
#==============================================================================#
module IEO
  module ITEM_SYSTEM
#==============================================================================#
#                      Start Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  #--------------------------------------------------------------------------#
  # * SORT_LIST
  #--------------------------------------------------------------------------#
  # This is the default list sorting list for the items
  # You can always change it, during the game.
  # $game_system.item_sort_list
  # In item, weapon or armor noteboxes, use the following tag
  # <item group: phrase>
  # NOTE* phrase is downcased and changed to a symbol (:phrase)
  #--------------------------------------------------------------------------#
    SORT_LIST = [:item, :weapon, :armor]#[:all, :item, :weapon, :armor] #[:all, :item, :equipment]
  # // ------------------------------------------------------------------ // #
  # >.> Some auto catergorizing happens on start up
  # :equipment - Weapons and Armor get this
  # :weapon    - Weapons get this
  # :armor     - Armors get this
  # :item      - Items get this
  #--------------------------------------------------------------------------#
  # * STYLES
  #--------------------------------------------------------------------------#
  # This controls the drawing style for the windows
  #--------------------------------------------------------------------------#
  # // :normal, :hm_style, :hm_style_plus
  # :normal, as the name states this will draw the items in its normal way
  # :hm_style, draws the items icon and item number
  # :hm_style_plus, in addition to the :hm_style, draws the items name
  # (WARNING, use short names with _plus)
    ITEM_WINDOW_STYLE = :normal
  # // :normal, :normal_plus, :hm_style
  # :normal, draws only the name of the sort groups
  # :normal_plus, draws the sort group name, and icon
  # :hm_style, draws only the icon
    TAB_WINDOW_STYLE  = :normal_plus

#==============================================================================#
#                        End Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  end
end

#==============================================================================#
# IEO::Vocab
#==============================================================================#
module IEO
  module Vocab
#==============================================================================#
#                      Start Secondary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
    module_function # // Do Not Touch
    def item_group(type)
      case type
      when :all       ; return "All"
      when :item      ; return "Item"
      when :equipment ; return ::Vocab.equip
      when :weapon    ; return "Weapons"
      when :armor     ; return "Armor"
      end
    end
#==============================================================================#
#                        End Secondary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  end
end

#==============================================================================#
# Sound
#==============================================================================#
module Sound
  #--------------------------------------------------------------------------#
  # * new method :play_itemtab
  #--------------------------------------------------------------------------#
  def self.play_itemtab ; self.play_cursor end
end

#==============================================================================#
# IEO::REGEX::ITEM_SYSTEM
#==============================================================================#
module IEO
  module REGEXP
    module ITEM_SYSTEM
      module BASE_ITEM
        ITEM_GROUP = /<(ITEM_GROUP|item group|itemgroup|GROUP):[ ](.*)>/i
      end
    end
  end
end

#==============================================================================#
# IEO::Icon
#==============================================================================#
module IEO
  module Icon
    module_function
    def item_group(type) ; return 0 end
  end
end

#==============================================================================#
# RPG::BaseItem
#==============================================================================#
class RPG::BaseItem

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :sort_groups

  #--------------------------------------------------------------------------#
  # * new method :ieo031_baseitemcache
  #--------------------------------------------------------------------------#
  def ieo031_baseitemcache
    @ieo031_baseitemcache_complete = false
    @sort_groups = [:all]
    self.note.split(/[\r\n]+/i).each { |line|
      case line
      when IEO::REGEXP::ITEM_SYSTEM::BASE_ITEM::ITEM_GROUP
        @sort_groups |= [$1.downcase.to_sym]
      end
    }
    @ieo031_baseitemcache_complete = true
  end

end

#==============================================================================#
# RPG::Weapon
#==============================================================================#
class RPG::Weapon

  #--------------------------------------------------------------------------#
  # * new method :ieo031_weaponcache
  #--------------------------------------------------------------------------#
  def ieo031_weaponcache
    @sort_groups << :weapon
    @sort_groups << :equipment
  end

end

#==============================================================================#
# RPG::Armor
#==============================================================================#
class RPG::Armor

  #--------------------------------------------------------------------------#
  # * new method :ieo031_armorcache
  #--------------------------------------------------------------------------#
  def ieo031_armorcache
    @sort_groups << :armor
    @sort_groups << :equipment
  end

end

#==============================================================================#
# RPG::Item
#==============================================================================#
class RPG::Item

  #--------------------------------------------------------------------------#
  # * new method :ieo031_itemcache
  #--------------------------------------------------------------------------#
  def ieo031_itemcache
    @sort_groups << :item
  end

end

#==============================================================================#
# Game_System
#==============================================================================#
class Game_System

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :item_sort_list
  attr_accessor :item_lastindex_list
  attr_accessor :item_display_style
  attr_accessor :item_sort_style

  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
  alias ieo031_initialize initialize unless $@
  def initialize
    ieo031_initialize
    @item_sort_list      = IEO::ITEM_SYSTEM::SORT_LIST
    @item_lastindex_list = {}
    @item_sort_list.each { |t| @item_lastindex_list[t] = 0 }
    @item_display_style  = IEO::ITEM_SYSTEM::ITEM_WINDOW_STYLE
    @item_sort_style     = IEO::ITEM_SYSTEM::TAB_WINDOW_STYLE
  end

end

#==============================================================================#
# Window_Item
#==============================================================================#
class Window_Item < Window_Selectable

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :active_filter

  #--------------------------------------------------------------------------#
  # * overwrite method :initialize
  #--------------------------------------------------------------------------#
  def initialize(x, y, width, height)
    @display_mode = $game_system.item_display_style
    super(x, y, width, height)
    @column_max    = 2
    @active_filter = :all
    @spacing       = 2
    self.index     = 0
    refresh
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :include?
  #--------------------------------------------------------------------------#
  def include?(item)
    return false if item == nil
    if item.kind_of?(RPG::BaseItem)
      return false unless item.sort_groups.include?(@active_filter)
    end
    if $game_temp.in_battle
      return false unless item.is_a?(RPG::Item)
    end
    return true
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :refresh
  #--------------------------------------------------------------------------#
  def refresh
    @data = []
    for item in $game_party.items
      next unless include?(item)
      @data.push(item)
      if item.is_a?(RPG::Item) and item.id == $game_party.last_item_id
        self.index = @data.size - 1
      end
    end
    @data.push(nil) if include?(nil)
    case @display_mode
    when :normal                   ; @column_max = 2
    when :hm_style, :hm_style_plus ; @column_max = 8
    end
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
    if $game_system.item_lastindex_list[@active_filter] != nil
      self.index = $game_system.item_lastindex_list[@active_filter]
      while self.item.nil?
        break if item != nil or self.index == 0
        self.index -= 1
      end
    else
      self.index = 0
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :item_rect
  #--------------------------------------------------------------------------#
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    case @display_mode
    when :normal
      rect.width = (contents.width + @spacing) / @column_max - @spacing
      rect.height = WLH
      rect.x = index % @column_max * (rect.width + @spacing)
      rect.y = index / @column_max * WLH
    when :hm_style, :hm_style_plus
      rect.width = 42
      rect.height = 42
      offset = contents.width
      offset-= (rect.width + @spacing) * @column_max
      offset/= 2
      rect.x = index % @column_max * (rect.width + @spacing) + offset
      rect.y = index / @column_max * (rect.height + @spacing)
    end
    return rect
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :draw_item
  #--------------------------------------------------------------------------#
  def draw_item(index, enabled=true)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    item = @data[index]
    if item != nil
      number = $game_party.item_number(item)
      enabled = enable?(item)
      case @display_mode
      when :normal
        rect.width -= 4
        self.contents.font.size = Font.default_size
        draw_item_name(item, rect.x, rect.y, enabled)
        self.contents.font.size = 18
        self.contents.draw_text(rect, sprintf(":%2d", number), 2)
      when :hm_style, :hm_style_plus
        draw_icon(item.icon_index, rect.x+((rect.width-24) / 2), rect.y+((rect.height-24) / 2))
        if @display_mode == :hm_style_plus
          self.contents.font.size = 12
          trect = rect.clone;trect.height = WLH;trect.y -= 4;trect.width -= 2
          self.contents.draw_text(trect, item.name)
        end
        self.contents.font.size = 14
        rect.y += rect.height - WLH
        rect.width -= 4 ; rect.height = WLH
        self.contents.draw_text(rect, sprintf(":%2d", number), 2)
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * alias method :update
  #--------------------------------------------------------------------------#
  alias ieo031_wi_update update unless $@
  def update
    ieo031_wi_update
    $game_system.item_lastindex_list[@active_filter] = self.index
  end

end

#==============================================================================#
# Window_ItemSortList
#==============================================================================#
class Window_ItemSortList < Window_Selectable

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :sort_filter

  #--------------------------------------------------------------------------#
  # * super method :initilaize
  #--------------------------------------------------------------------------#
  def initialize(x, y, width, height)
    @display_mode= $game_system.item_sort_style
    super(x, y, width, height)
    @sort_list   = $game_system.item_sort_list
    @sort_filter = @sort_list[0]
    @last_sort   = :nil
    self.index   = 0
    refresh
  end

  #--------------------------------------------------------------------------#
  # * new method :update_index
  #--------------------------------------------------------------------------#
  def update_index ; @last_sort = @sort_filter = @sort_list[self.index] end
  #--------------------------------------------------------------------------#
  # * new method :set_sort_field
  #--------------------------------------------------------------------------#
  def set_sort_field(new_sort) ; @sort_filter = new_sort end

  #--------------------------------------------------------------------------#
  # * new method :refresh
  #--------------------------------------------------------------------------#
  def refresh
    @item_max = @sort_list.size
    @column_max = @item_max
    create_contents
    for i in 0...@item_max ; draw_item(i) end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :item_rect
  #--------------------------------------------------------------------------#
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    case @display_mode
    when :normal, :normal_plus
      rect.width = (contents.width + @spacing) / @column_max - @spacing
      rect.height = WLH
      rect.x = index % @column_max * (rect.width + @spacing)
      rect.y = index / @column_max * WLH
    when :hm_style
      rect.width = 32
      rect.height = 32
      offset = contents.width
      offset-= (rect.width + @spacing) * @column_max
      offset/= 2
      rect.x = index % @column_max * (rect.width + @spacing) + offset
      rect.y = index / @column_max * (rect.height + @spacing)
      rect.y -= 4
    end
    return rect
  end

  #--------------------------------------------------------------------------#
  # * new method :draw_item
  #--------------------------------------------------------------------------#
  def draw_item(index, enabled=true)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    gro = @sort_list[index]
    self.contents.font.size = 18
    case @display_mode
    when :normal
      self.contents.draw_text(rect, IEO::Vocab.item_group(gro))
    when :normal_plus
      xo = yo = 0
      draw_icon(IEO::Icon.item_group(gro), rect.x+xo, rect.y+yo, enabled)
      rect.x += 24
      self.contents.draw_text(rect, IEO::Vocab.item_group(gro))
    when :hm_style
      xo = (rect.width - 24) / 2
      yo = (rect.height - 24) / 2
      draw_icon(IEO::Icon.item_group(gro), rect.x+xo, rect.y+yo, enabled)
    end
  end

  #--------------------------------------------------------------------------#
  # * super method :update
  #--------------------------------------------------------------------------#
  def update
    if @last_sort != @sort_filter
      self.index = @sort_list.index(@sort_filter)
      @last_sort = @sort_filter
    end
    super
  end

  #--------------------------------------------------------------------------#
  # * kill method :cursor_pageup
  #--------------------------------------------------------------------------#
  def cursor_pageup   ; end
  #--------------------------------------------------------------------------#
  # * kill method :cursor_pagedown
  #--------------------------------------------------------------------------#
  def cursor_pagedown ; end

end

#==============================================================================#
# Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base

  #--------------------------------------------------------------------------#
  # alias method :load_database
  #--------------------------------------------------------------------------#
  alias ieo031_load_database load_database unless $@
  def load_database
    ieo031_load_database
    load_ieo031_cache
  end

  #--------------------------------------------------------------------------#
  # alias method :load_bt_database
  #--------------------------------------------------------------------------#
  alias ieo031_load_bt_database load_database unless $@
  def load_bt_database
    ieo031_load_bt_database
    load_ieo031_cache
  end

  #--------------------------------------------------------------------------#
  # new method :load_ieo031_cache
  #--------------------------------------------------------------------------#
  def load_ieo031_cache
    objs = [$data_items, $data_weapons, $data_armors]
    objs.each { |group| group.each { |obj|
      next if obj.nil? ; obj.ieo031_baseitemcache
      obj.ieo031_weaponcache if obj.is_a?(RPG::Weapon)
      obj.ieo031_armorcache  if obj.is_a?(RPG::Armor)
      obj.ieo031_itemcache   if obj.is_a?(RPG::Item) } }
  end

end

#==============================================================================#
# Scene_Item
#==============================================================================#
class Scene_Item < Scene_Base

  include IEX::SCENE_ACTIONS if $imported["IEX_SceneActions"]

  #--------------------------------------------------------------------------#
  # * Constants
  #--------------------------------------------------------------------------#
  SLIDY_WINDOWS = false
  SLIDY_WINDOWS = ($imported["IEX_SceneActions"] && SLIDY_WINDOWS)

  #--------------------------------------------------------------------------#
  # * overwrite method :initialize
  #--------------------------------------------------------------------------#
  def initialize(called = :menu, return_index=0)
    super()
    # ---------------------------------------------------- #
    @calledfrom = called
    @return_index = return_index
    # ---------------------------------------------------- #
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :start
  #--------------------------------------------------------------------------#
  def start
    super
    create_menu_background
    @viewport             = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @help_window          = Window_Help.new
    @help_window.viewport = @viewport
    @item_window          = Window_Item.new(0, 112, Graphics.width, 304)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.active   = false
    @itemgroup_window     = Window_ItemSortList.new(0, 56, Graphics.width, 56)
    @itemgroup_window.active = false
    @itemgroup_window.update
    @target_window        = Window_MenuStatus.new(0, 0)
    hide_target_window
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :terminate
  #--------------------------------------------------------------------------#
  alias ieo031_terminate terminate unless $@
  def terminate
    ieo031_terminate
    @itemgroup_window.dispose unless @itemgroup_window.nil?
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :return_scene
  #--------------------------------------------------------------------------#
  def return_scene
    if SLIDY_WINDOWS
      # ---------------------------------------------------- #
      #pull_windows_right(["SStat"], @windows["SStat"].width)
      #pull_windows_left(["Level", "Skill"], @windows["Skill"].width)
      #pull_windows_up(["Party"], @windows["Party"].height)
      # ---------------------------------------------------- #
    end
    case @calledfrom
    when :map
      $scene = Scene_Map.new
    when :menu
      $scene = Scene_Menu.new(@return_index)
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :update
  #--------------------------------------------------------------------------#
  def update
    super
    update_menu_background
    @help_window.update
    @item_window.update
    @target_window.update
    @itemgroup_window.update
    if @item_window.active_filter != @itemgroup_window.sort_filter
      @item_window.active_filter = @itemgroup_window.sort_filter
      @item_window.refresh
    end
    if @item_window.active
      update_item_selection
    elsif @target_window.active
      update_target_selection
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :update_item_selection
  #--------------------------------------------------------------------------#
  def update_item_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::C)
      @item = @item_window.item
      if @item != nil
        $game_party.last_item_id = @item.id
      end
      if $game_party.item_can_use?(@item)
        Sound.play_decision
        determine_item
      else
        Sound.play_buzzer
      end
    elsif Input.trigger?(Input::L)
      Sound.play_itemtab
      @itemgroup_window.index -= 1
      @itemgroup_window.index %= @itemgroup_window.item_max
      @itemgroup_window.update_index()
    elsif Input.trigger?(Input::R)
      Sound.play_itemtab
      @itemgroup_window.index += 1
      @itemgroup_window.index %= @itemgroup_window.item_max
      @itemgroup_window.update_index()
    end
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
