#==============================================================================#
# ** IEX(Icy Engine Xelion) - Scene Shop - CMV(Cosmetic Version) ALT
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : ReWrite + Cosmetic + ALT (Shop)
# ** Script Type   : Scene Shop
# ** Date Created  : 2010/10/26
# ** Date Modified : 2010/12/08
# ** Version       : 1.0.0.alt
#------------------------------------------------------------------------------#
#==============================================================================#
# **INTRODUCTION
#------------------------------------------------------------------------------#
#   This is the IEX version of the ICY_Scene_Shop(Really outdated...)
#   This is a partial rewrite of the Scene_Shop, allowing more control over the
#   window positions and appearnace.
#   There is also a custom shop name feature.
#   In addition there is also a Skinning feature (Using images instead of the
#                                                 window skin)
#------------------------------------------------------------------------------#
#==============================================================================#
# **CHANGES
#------------------------------------------------------------------------------#
# ** Scene_Shop
#    Overwriten
#      initialize
#      update
#      terminate
#
#------------------------------------------------------------------------------#
#==============================================================================#
# **FEATURES
#------------------------------------------------------------------------------#
# ** Custom Shop name and icon
#      Do a script call with the following (Before shop processing)
#      set_custom_shop_name("name")
#      set_custom_shop_icon(icon_index)
#    This is shown in the header window
#
#------------------------------------------------------------------------------#
#==============================================================================#
# **COMPATABILTIES
#------------------------------------------------------------------------------#
# * Well its suppose to work with almost everything. Unless somethings edits
#   something mentioned in the Changes
#
#------------------------------------------------------------------------------#
#==============================================================================#
# **KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# **CHANGE LOG
#------------------------------------------------------------------------------#
#
# 10/26/2010 V1.0  Ported to IEX and CMV'ed
# 12/08/2010 V1.0a Fixed Help Window wouldn't update
#
#------------------------------------------------------------------------------#
$imported = {} if $imported == nil
$imported["IEX_Scene_Shop_CMV"] = true
#==============================================================================
# ** IEX::SCENE_SHOP
#------------------------------------------------------------------------------
#==============================================================================
module IEX
  module SCENE_SHOP
#==============================================================================
#                           Start Customization
#------------------------------------------------------------------------------
#==============================================================================
    # Window Size and Positioing Information
    # If you are unsure of what to do, leave it.
    # Also DO NOT have the width or height LESS than 32.
    # But why would you do that? You couldn't see anything.
    WINDOW_POS_SIZE = {
    # :some window    => [x, y, width, height, opacity]
    :help_window      => [544 / 2, 56, 544 / 2, 56, 255],
    :header_window    => [0, 0, 544 - 156, 56, 255],
    :gold_window      => [544 - 156, 0, 156, 56, 255],
    :buy_dummy_window => [0, 112, 544, 304, 255],
    :buy_window       => [0, 112,(544 / 2) + 32, 304, 255],
    #:buy_window       => [0, 112, 544 / 2, 304, 255],
    :sell_window      => [0, 112, 544, 304, 255],
    :number_window    => [0, 112, 544 / 2, 304 / 2, 255],
    #:status_window    => [544 / 2, 112, 544 / 2, 304, 255],
    :status_window    => [(544 / 2) + 32, 112, (544 / 2) - 32, 304, 255],
    }

    SHOP_COMMAND_SETTINGS = {
    # :position => [x, y],
    :position => [0, 56],
    :width    => 544 / 2,
    :columns  => 3,
    :spacing  => 16,
    :font_size=> 16,
    }

    # Window Skins
    WINDOW_SKINS = {
    # These are located in your System Folder, they are expected to be the same
    # size as the window it self, but not limited to.
    # When set to nil, no skin is used for that window
    # Be sure to set the opacity of the window to 0 when using this
   #:some_window      => "Filename",
    :help_window      => nil,
    :header_window    => nil,
    :gold_window      => nil,
    :buy_dummy_window => nil,
    :buy_window       => nil,
    :sell_window      => nil,
    :number_window    => nil,
    :status_window    => nil,
    :command_window   => nil,
    }

    # Shop Icons
    SHOP_ICONS = {
   #:some_icon  => icon_index,
    :buy_icon   => 144,
    :sell_icon  => 147,
    :cancel_icon=> 213,
    :gold_icon  => 205,
 :def_shop_icon => 144,

   # Status Icons
    :atk_icon   => 2,
    :def_icon   => 52,
   # Shop Status Icons
    :weapon_icon=> 1,
    :armor_icon => 42,
    :item_icon  => 64,
:possesion_icon => 5962,
    }
    # Other settings
    # Number of Columns the Sell window has
    SHOP_TABS  = 2
    # Number of Columns the Sales window has / Buy Dummy Window
    DUMMY_SHOP_TABS = 2
    # Should items with a price of 0 be included
    SHOW_UNSELLABLE_ITEMS = true
    # Maximum number of an item that can be bought from the shop
    MAX_BUY_ITEMS = 99

    # Font size used when showing currency
    CURRENCY_FONT_SIZE = 18

    # Vocab
    DEF_SHOP_NAME = "Shop"
    PRICE_0_TEXT = "Free"
    UNIT_PRICE_FORMAT = "Unit Price: %d"
    CANT_EQUIP_TEXT = "Can't Equip"
    ITEM_TYPE_TEXTS = {
    :weapon => "Weapon",
    :armor  => "Armor",
    :useable_item => "Consume",
    :not_useable  => "Unusable",
    :not_consumable => "Non Consume",
    :battle_item  => "Battle",
    }
#==============================================================================
#                           End Customization
#------------------------------------------------------------------------------
#==============================================================================
  end
end

#==============================================================================
# ** Game System
#------------------------------------------------------------------------------
#==============================================================================
class Game_System

  attr_accessor :custom_shop_name
  attr_accessor :custom_shop_icon

  alias iex_scene_shop_cmv_gt_initialize initialize unless $@
  def initialize(*args)
    iex_scene_shop_cmv_gt_initialize(*args)
    iex_init_custom_shop
  end

  def iex_init_custom_shop
    @custom_shop_icon = nil
    @custom_shop_name = nil
  end

end

#==============================================================================
# ** Game Interpreter
#------------------------------------------------------------------------------
#==============================================================================
class Game_Interpreter

  def set_custom_shop_name(new_name)
    $game_system.custom_shop_name = new_name
  end

  def set_custom_shop_icon(new_icon)
    $game_system.custom_shop_icon = new_icon
  end

end

#==============================================================================
# ** IEX_ShopWindow_Item
#------------------------------------------------------------------------------
#==============================================================================
class IEX_ShopWindow_Item < Window_Selectable
  attr_accessor :back_sprite
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, columns)
    super(x, y, width, height)
    @column_max = columns
    self.index = 0
    @back_sprite = Sprite.new
    @back_sprite.x = self.x
    @back_sprite.y = self.y
    refresh
  end

  def set_coords(coords)
    self.x = coords[0]
    self.y = coords[1]
    self.width = coords[2]
    self.height = coords[3]
    self.opacity = coords[4]
    refresh
  end

  def dispose
    if @back_sprite != nil
      @back_sprite.dispose
      @back_sprite = nil
    end
    super
  end

  def update
    super
    if @back_sprite != nil
      @back_sprite.visible = self.visible
      @back_sprite.x = self.x
      @back_sprite.y = self.y
    end
  end

  def visible=(vis)
    @back_sprite.visible = vis
    super(vis)
  end
  #--------------------------------------------------------------------------
  # * Get Item
  #--------------------------------------------------------------------------
  def item
    return @data[self.index]
  end
  #--------------------------------------------------------------------------
  # * Whether or not to include in item list
  #     item : item
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item == nil
    unless IEX::SCENE_SHOP::SHOW_UNSELLABLE_ITEMS
      return false if item.price == 0
    end
    if $game_temp.in_battle
      return false unless item.is_a?(RPG::Item)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Whether or not to display in enabled state
  #     item : item
  #--------------------------------------------------------------------------
  def enable?(item)
    return $game_party.item_can_use?(item)
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
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
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw number with currency unit
  #     value : Number (gold, etc)
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : Width
  #--------------------------------------------------------------------------
  def draw_currency_value(value, x, y, width)
    cx = contents.text_size(Vocab::gold).width
    self.contents.font.color = normal_color
    def_size = self.contents.font.size
    self.contents.font.size = IEX::SCENE_SHOP::CURRENCY_FONT_SIZE
    self.contents.draw_text(x, y, width-cx-2, WLH, value, 2)
    self.contents.font.size = def_size
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, width, WLH, Vocab::gold, 2)
  end

  #--------------------------------------------------------------------------
  # * Draw Item
  #     index : item number
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    item = @data[index]
    if item != nil
      number = $game_party.item_number(item)
      enabled = enable?(item)
      rect.width -= 4
      def_size = self.contents.font.size
      self.contents.font.size = 18
      draw_item_name(item, rect.x, rect.y, enabled)
      self.contents.font.size = def_size
      draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:gold_icon], rect.x + rect.width - 20, rect.y, true)
      self.contents.font.color = normal_color

      def_size = self.contents.font.size
      self.contents.font.size = IEX::SCENE_SHOP::CURRENCY_FONT_SIZE
      if item.price <= 0
        self.contents.draw_text(rect.x - 24, rect.y, rect.width, rect.height, IEX::SCENE_SHOP::PRICE_0_TEXT , 2)
      else
        draw_currency_value(item.price, rect.x + 64, rect.y, rect.width - 88)
      end
      self.contents.font.size = def_size
      self.contents.font.color = normal_color
      rect.width -= 72
      def_size = self.contents.font.size
      self.contents.font.size = 16
      self.contents.draw_text(rect, sprintf("x%2d", number), 2)
      self.contents.font.size = def_size
    end
  end
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end

end

#==============================================================================
# ** IEX_Window_Current_Items
#------------------------------------------------------------------------------
#  This window displays items in possession for selling on the shop screen.
#==============================================================================
class IEX_Window_CurrentItems < IEX_ShopWindow_Item
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x      : window x-coordinate
  #     y      : window y-coordinate
  #     width  : window width
  #     height : window height
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, columns)
    super(x, y, width, height, columns)
  end

  #--------------------------------------------------------------------------
  # * Whether or not to display in enabled state
  #     item : item
  #--------------------------------------------------------------------------
  def enable?(item)
    return (item.price > 0)
  end

end

#==============================================================================
# ** IEX_Window_Gold
#------------------------------------------------------------------------------
#  This window displays the amount of gold.
#==============================================================================

class IEX_Window_Gold < Window_Base
  attr_accessor :back_sprite
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x : window X coordinate
  #     y : window Y coordinate
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, 160, WLH + 32)
    @back_sprite = Sprite.new
    @back_sprite.x = self.x
    @back_sprite.y = self.y
    refresh
  end

  def set_coords(coords)
    self.x = coords[0]
    self.y = coords[1]
    self.width = coords[2]
    self.height = coords[3]
    self.opacity = coords[4]
    create_contents
    refresh
  end

  def dispose
    if @back_sprite != nil
      @back_sprite.dispose
      @back_sprite = nil
    end
    super
  end

  def update
    super
    if @back_sprite != nil
      @back_sprite.visible = self.visible
      @back_sprite.x = self.x
      @back_sprite.y = self.y
    end
  end

  def visible=(vis)
    @back_sprite.visible = vis
    super(vis)
  end

  #--------------------------------------------------------------------------
  # * Draw number with currency unit
  #     value : Number (gold, etc)
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : Width
  #--------------------------------------------------------------------------
  def draw_currency_value(value, x, y, width)
    cx = contents.text_size(Vocab::gold).width
    self.contents.font.color = normal_color
    def_size = self.contents.font.size
    self.contents.font.size = IEX::SCENE_SHOP::CURRENCY_FONT_SIZE
    self.contents.draw_text(x, y, width-cx-2, WLH, value, 2)
    self.contents.font.size = def_size
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, width, WLH, Vocab::gold, 2)
  end

  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    draw_currency_value($game_party.gold, 4, 0, self.contents.width - 4)
    draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:gold_icon], 0, 0, true)
  end

end

#==============================================================================
# ** IEX_Window_ShopBuy
#------------------------------------------------------------------------------
#  This window displays buyable goods on the shop screen.
#==============================================================================

class IEX_Window_ShopBuy < Window_Selectable
  attr_accessor :back_sprite
  attr_reader   :type

  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x : window X coordinate
  #     y : window Y coordinate
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, columns = 1, spacing = 32)
    super(x, y, width, height)
    @shop_goods = $game_temp.shop_goods
    @column_max = columns
    @back_sprite = Sprite.new
    @back_sprite.x = self.x
    @back_sprite.y = self.y
    @type = ""
    refresh
    self.index = 0
  end

  def set_filter_type(new_type = nil)
    if new_type != nil
      @type = new_type
      refresh
    end
  end

  def set_coords(coords)
    self.x = coords[0]
    self.y = coords[1]
    self.width = coords[2]
    self.height = coords[3]
    self.opacity = coords[4]
    create_contents
    refresh
  end

  def dispose
    if @back_sprite != nil
      @back_sprite.dispose
      @back_sprite = nil
    end
    super
  end

  def update
    super
    if @back_sprite != nil
      @back_sprite.visible = self.visible
      @back_sprite.x = self.x
      @back_sprite.y = self.y
    end
  end

  def visible=(vis)
    @back_sprite.visible = vis
    super(vis)
  end

  #--------------------------------------------------------------------------
  # * Get Item
  #--------------------------------------------------------------------------
  def item
    return @data[self.index]
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    @data = []
    for goods_item in @shop_goods
      item = nil
      case goods_item[0]
      when 0
        if @type == "All" or @type == "Item"
          item = $data_items[goods_item[1]]
        end
      when 1
        if @type == "All" or @type == "Weapon"
          item = $data_weapons[goods_item[1]]
        end
      when 2
        if @type == "All" or @type == "Armor"
          item = $data_armors[goods_item[1]]
        end
      end
      if item != nil
        @data.push(item)
      end
    end
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end

  def any_valid_items?
    return true if @data.size > 0
    return false
  end

  #--------------------------------------------------------------------------
  # * Draw Item
  #     index : item number
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    number = $game_party.item_number(item)
    enabled = (item.price <= $game_party.gold and number < IEX::SCENE_SHOP::MAX_BUY_ITEMS)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    draw_item_name(item, rect.x, rect.y, enabled)
    rect.width -= 4
    def_size = self.contents.font.size
    self.contents.font.size = IEX::SCENE_SHOP::CURRENCY_FONT_SIZE
    if item.price <= 0
      self.contents.draw_text(rect.x - 24, rect.y, rect.width, rect.height, IEX::SCENE_SHOP::PRICE_0_TEXT , 2)
    else
      self.contents.draw_text(rect.x - 24, rect.y, rect.width, rect.height, item.price, 2)
    end
    self.contents.font.size = def_size
    draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:gold_icon], rect.x + (rect.width - 24),rect.y)
  end
  #--------------------------------------------------------------------------
  # * Help Text Update
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end

end

#==============================================================================
# ** IEX_Window_Help
#------------------------------------------------------------------------------
#  This window shows explanations.
#==============================================================================

class IEX_Shop_ItemWindow_Help < Window_Base
  attr_accessor :back_sprite
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, fontsize = 18)
    super(x, y, width, height)
    @fontsize = fontsize
    @back_sprite = Sprite.new
    @back_sprite.x = self.x
    @back_sprite.y = self.y
  end

  def set_coords(coords)
    self.x = coords[0]
    self.y = coords[1]
    self.width = coords[2]
    self.height = coords[3]
    self.opacity = coords[4]
    create_contents
  end

  def dispose
    if @back_sprite != nil
      @back_sprite.dispose
      @back_sprite = nil
    end
    super
  end

  def update
    super
    if @back_sprite != nil
      @back_sprite.visible = self.visible
      @back_sprite.x = self.x
      @back_sprite.y = self.y
    end
  end

  def visible=(vis)
    @back_sprite.visible = vis
    super(vis)
  end
  #--------------------------------------------------------------------------
  # * Set Text
  #  text  : character string displayed in window
  #  align : alignment (0..flush left, 1..center, 2..flush right)
  #--------------------------------------------------------------------------
  def set_text(text, align = 0)
    if text != @text or align != @align
      self.contents.clear
      self.contents.font.size = @fontsize
      self.contents.font.color = normal_color
      self.contents.draw_text(4, 0, self.width - 40, WLH, text, align)
      @text = text
      @align = align
    end
  end
end

#==============================================================================
# ** IEX_Window_Command
#------------------------------------------------------------------------------
#  This window deals with general command choices.
#==============================================================================

class IEX_Shop_ItemCommand < Window_Selectable
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :commands                 # command
  attr_accessor :back_sprite
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     width      : window width
  #     commands   : command array [[command, icon, enabled]]
  #     column_max : digit count (if 2 or more, horizontal selection)
  #     row_max    : row count (0: match command count)
  #     spacing    : blank space when items are arrange horizontally
  #--------------------------------------------------------------------------
  def initialize(width, commands, fontsize = 18, column_max = 1, row_max = 0, spacing = 32)
    if row_max == 0
      row_max = (commands.size + column_max - 1) / column_max
    end
    super(0, 0, width, row_max * WLH + 32, spacing)
    @commands = commands
    @item_max = commands.size
    @column_max = column_max
    @fontsize = fontsize
    @back_sprite = Sprite.new
    @back_sprite.x = self.x
    @back_sprite.y = self.y
    refresh
    self.index = 0
  end

  def set_coords(coords)
    self.x = coords[0]
    self.y = coords[1]
    self.width = coords[2]
    self.height = coords[3]
    self.opacity = coords[4]
    refresh
  end

  def dispose
    if @back_sprite != nil
      @back_sprite.dispose
      @back_sprite = nil
    end
    super
  end

  def update
    super
    if @back_sprite != nil
      @back_sprite.visible = self.visible
      @back_sprite.x = self.x
      @back_sprite.y = self.y
    end
  end

  def visible=(vis)
    @back_sprite.visible = vis
    super(vis)
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
   create_contents
    for i in 0...@item_max
      icon = @commands[i][1]
      enable = @commands[i][2]
      draw_item(i, icon, enable)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #     index   : item number
  #     enabled : enabled flag. When false, draw semi-transparently.
  #--------------------------------------------------------------------------
  def draw_item(index, icon_index, enabled = true)
    rect = item_rect(index)
    rect.x += 24
    rect.width -= 8
    draw_icon(icon_index, (rect.x - 24), rect.y, enabled)
    self.contents.clear_rect(rect)
    self.contents.font.size = @fontsize
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(rect, @commands[index][0])
  end

end

#==============================================================================
# ** IEX_Header_Window
#------------------------------------------------------------------------------
#  This window displays a header.
#==============================================================================
class IEX_Shop_ItemHeader < Window_Base
  attr_accessor :font_size
  attr_accessor :back_sprite
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x      : window x-coordinate
  #     y      : window y-coordinate
  #     width  : window width
  #     height : window height
  #--------------------------------------------------------------------------
  def initialize(arx, y = 0, width = 544, height = 56)
    if arx.is_a?(Array)
      x = arx[0]
      y = arx[1]
      width = arx[2]
      height = arx[3]
    else
      x = arx
    end
    super(x, y, width, height)
    @back_sprite = Sprite.new
    @back_sprite.x = self.x
    @back_sprite.y = self.y
  end

  def set_coords(coords)
    self.x = coords[0]
    self.y = coords[1]
    self.width = coords[2]
    self.height = coords[3]
    self.opacity = coords[4]
    create_contents
  end

  def dispose
    if @back_sprite != nil
      @back_sprite.dispose
      @back_sprite = nil
    end
    super
  end

  def update
    super
    if @back_sprite != nil
      @back_sprite.visible = self.visible
      @back_sprite.x = self.x
      @back_sprite.y = self.y
    end
  end

  def visible=(vis)
    @back_sprite.visible = vis
    super(vis)
  end
  #--------------------------------------------------------------------------
  # ** Reset Font Size
  #   Resets the font size to 26
  #--------------------------------------------------------------------------
  def reset_font_size
    @font_size = 26
  end
  #--------------------------------------------------------------------------
  # ** Set Header
  #     text   : text
  #     icon   : icon_index
  #     align  : align
  #--------------------------------------------------------------------------
  def set_header(text = "", icon = nil, align = 0)
    icon_offset = 32
    if icon == nil
      x = 0
    else
      x = icon_offset
      draw_icon(icon, 0, 0)
    end
     y = 0
     old_font_size = self.contents.font.size
     self.contents.font.size = 26
     self.contents.font.color = system_color
     self.contents.draw_text(x, y, (self.width - x) - 48, WLH, text, align)
     self.contents.font.color = normal_color
     self.contents.font.size = old_font_size
  end

end

#==============================================================================
# ** IEX_Window_ShopStatus
#------------------------------------------------------------------------------
#==============================================================================
class IEX_Icon_Sprite < Sprite

  def initialize(viewport = nil)
    super(viewport)
    self.bitmap = Cache.system("Iconset")
    set_icon(0)
  end

  def set_icon(icon_index)
    self.src_rect.set(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
  end

end

class IEX_Window_ShopStatus < Window_ShopStatus
  attr_accessor :back_sprite

  def initialize(x, y)
    super(x, y)
    @back_sprite = Sprite.new
    @back_sprite.x = self.x
    @back_sprite.y = self.y
    @type = "All"
    @type_icons = {}
    @type_icons["Armor"]  = IEX_Icon_Sprite.new
    @type_icons["Item"]   = IEX_Icon_Sprite.new
    @type_icons["Weapon"] = IEX_Icon_Sprite.new
    @type_icons["Armor"].set_icon(IEX::SCENE_SHOP::SHOP_ICONS[:armor_icon])
    @type_icons["Item"].set_icon(IEX::SCENE_SHOP::SHOP_ICONS[:item_icon])
    @type_icons["Weapon"].set_icon(IEX::SCENE_SHOP::SHOP_ICONS[:weapon_icon])
    @type_icons["Armor"].z  = 200
    @type_icons["Item"].z   = 200
    @type_icons["Weapon"].z = 200
    @icon_order = ["Item", "Weapon", "Armor"]
    update_icon_type
  end

  def set_coords(coords)
    self.x = coords[0]
    self.y = coords[1]
    self.width = coords[2]
    self.height = coords[3]
    self.opacity = coords[4]
    create_contents
    refresh
  end

  def dispose
    if @back_sprite != nil
      @back_sprite.dispose
      @back_sprite = nil
    end
    for spr in @type_icons.values
      next if spr == nil
      spr.dispose
      spr = nil
    end

    super
  end

  def update_win_type(new_type)
    if new_type != @type and new_type != nil
      @type = new_type
      update_icon_type
    end
  end

  def update_icon_type
    for spr in @type_icons.values
      next if spr == nil
      spr.opacity = 128
    end
    case @type
    when "All"
      for spr in @type_icons.values
        next if spr == nil
        spr.opacity = 255
      end
    else
      if @type_icons.has_key?(@type)
        @type_icons[@type].opacity = 255
      end
    end
    update
  end

  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    if @item != nil
      number = $game_party.item_number(@item)
      update_icon_type
      self.contents.font.color = system_color
      draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:possesion_icon], 4, 56)
      self.contents.draw_text(4 + 28, 56, self.contents.width - 32, WLH, Vocab::Possession)
      self.contents.font.color = normal_color
      self.contents.draw_text(4 + 28, 56, self.contents.width - 32, WLH, number, 2)
      for actor in $game_party.members
        x = 4
        y = 56 + WLH * (2 + actor.index * 2)
        draw_actor_parameter_change(actor, x, y)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Actor's Current Equipment and Parameters
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_actor_parameter_change(actor, x, y)
    return if @item.is_a?(RPG::Item)
    enabled = actor.equippable?(@item)
    self.contents.font.color = system_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(x, y, self.contents.width - 32, WLH, actor.name)
    self.contents.font.color = normal_color
    if @item.is_a?(RPG::Weapon)
      item1 = weaker_weapon(actor)
    elsif actor.two_swords_style and @item.kind == 0
      item1 = nil
    else
      item1 = actor.equips[1 + @item.kind]
    end
    if enabled
      atk1 = item1 == nil ? 0 : item1.atk
      atk2 = @item == nil ? 0 : @item.atk
      change_atk = atk2 - atk1
      stat_name_atk = Vocab.atk
      def1 = item1 == nil ? 0 : item1.def
      def2 = @item == nil ? 0 : @item.def
      change_def = def2 - def1
      stat_name_def = Vocab.def

      def_size = self.contents.font.size
      self.contents.font.size = 18
      draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:atk_icon], self.contents.width - 92, y) #x
      draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:def_icon], self.contents.width - 20, y)
      stat_height = 28
      self.contents.draw_text(x, y, self.contents.width - 96, stat_height, sprintf("%+d %s", change_atk, stat_name_atk), 2)
      self.contents.draw_text(x, y, self.contents.width - 24, stat_height, sprintf("%+d %s", change_def, stat_name_def), 2)
      self.contents.font.size = def_size
    else
      self.contents.font.color.alpha = 255
      self.contents.draw_text(x, y, self.contents.width - 24, WLH, IEX::SCENE_SHOP::CANT_EQUIP_TEXT, 2)
    end
    def_size = self.contents.font.size
    self.contents.font.size = 18
    draw_item_name(item1, x + 16, y + WLH, enabled)
    self.contents.font.size = def_size
  end

  #--------------------------------------------------------------------------
  # * Set Item
  #     item : new item
  #--------------------------------------------------------------------------
  def item=(item)
    if @item != item
      @item = item
      refresh
    end
  end

  def update
    super
    if @back_sprite != nil
      @back_sprite.visible = self.visible
      @back_sprite.x = self.x
      @back_sprite.y = self.y
    end
    coun = 1

    for ty in @icon_order
      spr = @type_icons[ty]
      next if spr == nil
      spr.x = 16 + self.x + ((self.contents.width / 4) * coun)
      spr.y = self.y + 24
      coun += 1
    end
  end

  def visible=(vis)
    @back_sprite.visible = vis
    for spr in @type_icons.values
      next if spr == nil
      spr.visible = vis
    end
    super(vis)
  end

end

#==============================================================================
# ** IEX_Window_ShopNumber
#------------------------------------------------------------------------------
#==============================================================================
class IEX_Window_ShopNumber < Window_ShopNumber

  attr_accessor :back_sprite

  def initialize(x, y)
    super(x, y)
    @back_sprite = Sprite.new
    @back_sprite.x = self.x
    @back_sprite.y = self.y
  end

  def set_coords(coords)
    self.x = coords[0]
    self.y = coords[1]
    self.width = coords[2]
    self.height = coords[3]
    self.opacity = coords[4]
    create_contents
    refresh
  end

  def dispose
    if @back_sprite != nil
      @back_sprite.dispose
      @back_sprite = nil
    end
    super
  end

  #--------------------------------------------------------------------------
  # * Draw number with currency unit
  #     value : Number (gold, etc)
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : Width
  #--------------------------------------------------------------------------
  def draw_currency_value(value, x, y, width)
    cx = contents.text_size(Vocab::gold).width
    self.contents.font.color = normal_color
    def_size = self.contents.font.size
    self.contents.font.size = IEX::SCENE_SHOP::CURRENCY_FONT_SIZE
    self.contents.draw_text(x, y, width-cx-2, WLH, value, 2)
    self.contents.font.size = def_size
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, width, WLH, Vocab::gold, 2)
  end

  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    def_size = self.contents.font.size
    self.contents.font.size = 18
    draw_item_name(@item, 4, 4)
    self.contents.font.size = def_size
    draw_item_special_data(@item, self.contents.width / 2, 4, self.contents.width / 2, 2)
    self.contents.font.color = normal_color
    pri = sprintf(IEX::SCENE_SHOP::UNIT_PRICE_FORMAT, @price)
    draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:gold_icon], 4, 28)

    self.contents.draw_text(28, 28, self.contents.width, WLH, pri)
    self.contents.font.color = normal_color
    self.contents.draw_text(4, self.contents.height - 64, 24, WLH, "x")
    self.contents.draw_text(32, self.contents.height - 64, 24, WLH, @number, 2)
    self.cursor_rect.set(36, self.contents.height - 64, 28, WLH)
    draw_currency_value(@price * @number, 4, self.contents.height - 64, self.contents.width - 64)
    draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:gold_icon], self.contents.width - 32, self.contents.height - 64)
  end

  def draw_item_special_data(item, x, y, width, align = 0)
    return if item == nil
    self.contents.font.color = system_color
    def_size = self.contents.font.size
    self.contents.font.size = 16
    if item.is_a?(RPG::Weapon)
      self.contents.draw_text(x, y, width, WLH, IEX::SCENE_SHOP::ITEM_TYPE_TEXTS[:weapon], align)
    elsif item.is_a?(RPG::Armor)
      self.contents.draw_text(x, y, width, WLH, IEX::SCENE_SHOP::ITEM_TYPE_TEXTS[:armor], align)
    else
      self.contents.draw_text(x, y, width, WLH, IEX::SCENE_SHOP::ITEM_TYPE_TEXTS[:armor], align)
      if item.occasion == 3
        self.contents.draw_text(x, y, width, WLH, IEX::SCENE_SHOP::ITEM_TYPE_TEXTS[:not_useable], align)
      elsif item.consumable and [0, 2].include?(item.occasion)
        self.contents.draw_text(x, y, width, WLH, IEX::SCENE_SHOP::ITEM_TYPE_TEXTS[:useable_item], align)
      elsif item.consumable and item.occasion == 1
        self.contents.draw_text(x, y, width, WLH, IEX::SCENE_SHOP::ITEM_TYPE_TEXTS[:battle_item], align)
      else
        self.contents.draw_text(x, y, width, WLH, IEX::SCENE_SHOP::ITEM_TYPE_TEXTS[:not_consumable], align)
      end
    end
    self.contents.font.size = def_size
  end

  def update
    if @back_sprite != nil
      @back_sprite.visible = self.visible
      @back_sprite.x = self.x
      @back_sprite.y = self.y
    end
    super
  end

  def visible=(vis)
    @back_sprite.visible = vis
    super(vis)
  end

end

#==============================================================================
# ** IEX_Scene_Shop
#------------------------------------------------------------------------------
#==============================================================================
class Scene_Shop < Scene_Base
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    create_command_window
    @win_index = 0
    @help_window = IEX_Shop_ItemWindow_Help.new(0, (416 - 56), 544, 56)
    @header_window = IEX_Shop_ItemHeader.new(0, 0, 384, 56)
    @gold_window = IEX_Window_Gold.new(384, 0)
    @buy_dummy_window = IEX_Window_ShopBuy.new(0, 112, 544, 248, IEX::SCENE_SHOP::DUMMY_SHOP_TABS)
    @buy_windows = {}
    @buy_windows["Item"] = IEX_Window_ShopBuy.new(544 / 2, 112, 544 / 2, 248, 1)
    @buy_windows["Weapon"] = IEX_Window_ShopBuy.new(544 / 2, 112, 544 / 2, 248, 1)
    @buy_windows["Armor"] = IEX_Window_ShopBuy.new(544 / 2, 112, 544 / 2, 248, 1)
    @buy_windows["Item"].set_filter_type("Item")
    @buy_windows["Weapon"].set_filter_type("Weapon")
    @buy_windows["Armor"].set_filter_type("Armor")
    @buy_window_scroll_list = []
    @window_order = ["Item", "Weapon", "Armor"]
    for ke in @window_order
      next if ke == nil
      if @buy_windows[ke].any_valid_items?
        @buy_window_scroll_list.push(ke)
      end
    end
    @sell_window = IEX_Window_CurrentItems.new(0, 112, 544, 248, IEX::SCENE_SHOP::SHOP_TABS)
    @number_window = IEX_Window_ShopNumber.new(252, 112)
    @status_window = IEX_Window_ShopStatus.new(0, 112)

    @help_window.set_coords(IEX::SCENE_SHOP::WINDOW_POS_SIZE[:help_window])
    @header_window.set_coords(IEX::SCENE_SHOP::WINDOW_POS_SIZE[:header_window])
    @gold_window.set_coords(IEX::SCENE_SHOP::WINDOW_POS_SIZE[:gold_window])
    @buy_dummy_window.set_coords(IEX::SCENE_SHOP::WINDOW_POS_SIZE[:buy_dummy_window])
    #@buy_window.set_coords(IEX::SCENE_SHOP::WINDOW_POS_SIZE[:buy_window])
    for win in @buy_windows.values
      next if win == nil
      win.set_coords(IEX::SCENE_SHOP::WINDOW_POS_SIZE[:buy_window])
      win.visible = false
    end
    @sell_window.set_coords(IEX::SCENE_SHOP::WINDOW_POS_SIZE[:sell_window])
    @number_window.set_coords(IEX::SCENE_SHOP::WINDOW_POS_SIZE[:number_window])
    @status_window.set_coords(IEX::SCENE_SHOP::WINDOW_POS_SIZE[:status_window])

    window_skins = IEX::SCENE_SHOP::WINDOW_SKINS
    if window_skins[:help_window] != nil
      @help_window.back_sprite.bitmap = Cache.system(window_skins[:help_window])
    end
    if window_skins[:header_window] != nil
      @header_window.back_sprite.bitmap = Cache.system(window_skins[:header_window])
    end
    if window_skins[:gold_window] != nil
      @gold_window.back_sprite.bitmap = Cache.system(window_skins[:gold_window])
    end
    if window_skins[:buy_dummy_window] != nil
      @buy_dummy_window.back_sprite.bitmap = Cache.system(window_skins[:buy_dummy_window])
    end
    if window_skins[:buy_window] != nil
      for win in @buy_windows.values
        next if win == nil
        win.back_sprite.bitmap = Cache.system(window_skins[:buy_window])
        win.update
      end
      #@buy_window.back_sprite.bitmap = Cache.system(window_skins[:buy_window])
    end
    if window_skins[:sell_window] != nil
      @sell_window.back_sprite.bitmap = Cache.system(window_skins[:sell_window])
    end
    if window_skins[:number_window] != nil
      @number_window.back_sprite.bitmap = Cache.system(window_skins[:number_window])
    end
    if window_skins[:status_window] != nil
      @status_window.back_sprite.bitmap = Cache.system(window_skins[:status_window])
    end

    if $game_system.custom_shop_name != nil
      name = $game_system.custom_shop_name
    else
      name = IEX::SCENE_SHOP::DEF_SHOP_NAME
    end
    if $game_system.custom_shop_icon != nil
      icon = $game_system.custom_shop_icon
    else
      icon = IEX::SCENE_SHOP::SHOP_ICONS[:def_shop_icon]
    end

    @buy_window = @buy_windows[@buy_window_scroll_list[@win_index]]

    @header_window.set_header(name, icon)
    @buy_dummy_window.index = -1
    @buy_dummy_window.active = false
    @buy_window.active = false
    @buy_window.visible = false
    @buy_window.help_window = @help_window
    @sell_window.active = false
    @sell_window.visible = false
    @sell_window.help_window = @help_window
    @number_window.active = false
    @number_window.visible = false
    @status_window.visible = false
  end

  #--------------------------------------------------------------------------
  # * Create Command Window
  #--------------------------------------------------------------------------
  def create_command_window
    i1 = IEX::SCENE_SHOP::SHOP_ICONS[:buy_icon]
    i2 = IEX::SCENE_SHOP::SHOP_ICONS[:sell_icon]
    i3 = IEX::SCENE_SHOP::SHOP_ICONS[:cancel_icon]
    s1 = Vocab::ShopBuy
    s2 = Vocab::ShopSell
    s3 = Vocab::ShopCancel
    coma = [[s1, i1, true], [s2, i2, !$game_temp.shop_purchase_only], [s3, i3, true]]
    sett = IEX::SCENE_SHOP::SHOP_COMMAND_SETTINGS
    @command_window = IEX_Shop_ItemCommand.new(sett[:width], coma, sett[:font_size], sett[:columns], 0, sett[:spacing])
    @command_window.x = sett[:position][0]
    @command_window.y = sett[:position][1]
    if IEX::SCENE_SHOP::WINDOW_SKINS[:command_window] != nil
      @command_window.back_sprite.bitmap = Cache.system(IEX::SCENE_SHOP::WINDOW_SKINS[:command_window])
    end
  end

  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    dispose_command_window
    @help_window.dispose
    @gold_window.dispose
    @buy_dummy_window.dispose
    #@buy_window.dispose
    for win in @buy_windows.values
      next if win == nil
      win.dispose
      win = nil
    end
    @buy_windows.clear
    @buy_windows = []
    @buy_window = nil
    @sell_window.dispose
    @number_window.dispose
    @status_window.dispose
    @header_window.dispose
    @help_window = nil
    @gold_window = nil
    @buy_dummy_window = nil
    @buy_window = nil
    @sell_window = nil
    @number_window = nil
    @status_window = nil
    @header_window = nil
    $game_system.custom_shop_name = nil
    $game_system.custom_shop_icon = nil
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @help_window.update        if @help_window.active
    @command_window.update     if @command_window.active
    @gold_window.update        if @gold_window.active
    @buy_dummy_window.update   if @buy_dummy_window.active
    @buy_window.update         if @buy_window.active
    @sell_window.update        if @sell_window.active
    @number_window.update      if @number_window.active
    @status_window.update_win_type(@buy_window_scroll_list[@win_index])
    @status_window.update      if @status_window.active
    if @command_window.active
      update_command_selection
    elsif @buy_window.active
      if Input.trigger?(Input::LEFT)
        Sound.play_cursor
        @buy_window.visible = false
        @win_index = (@win_index - 1) % @buy_window_scroll_list.size
        @buy_window = @buy_windows[@buy_window_scroll_list[@win_index]]
        @buy_window.help_window = @help_window
        @buy_window.visible = true
      elsif Input.trigger?(Input::RIGHT)
        Sound.play_cursor
        @buy_window.visible = false
        @win_index = (@win_index + 1) % @buy_window_scroll_list.size
        @buy_window = @buy_windows[@buy_window_scroll_list[@win_index]]
        @buy_window.help_window = @help_window
        @buy_window.visible = true
      end
      update_buy_selection
    elsif @sell_window.active
      update_sell_selection
    elsif @number_window.active
      update_number_input
    end
  end

  #--------------------------------------------------------------------------
  # * Dispose of Command Window
  #--------------------------------------------------------------------------
  def dispose_command_window
    @command_window.dispose
    @command_window = nil
  end

  #--------------------------------------------------------------------------
  # * Update Command Selection
  #--------------------------------------------------------------------------
  def update_command_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = Scene_Map.new
    elsif Input.trigger?(Input::C)
      case @command_window.index
      when 0  # buy
        Sound.play_decision
        @command_window.active = false
        @buy_dummy_window.visible = false
        @buy_window.active = true
        @buy_window.visible = true
        @buy_window.refresh
        @status_window.visible = true
      when 1  # sell
        if $game_temp.shop_purchase_only
          Sound.play_buzzer
        else
          Sound.play_decision
          @command_window.active = false
          @buy_dummy_window.visible = false
          @sell_window.active = true
          @sell_window.visible = true
          @sell_window.refresh
        end
      when 2  # Quit
        Sound.play_decision
        $scene = Scene_Map.new
      end
    end
  end

  #--------------------------------------------------------------------------
  # * Update Buy Item Selection
  #--------------------------------------------------------------------------
  def update_buy_selection
    @status_window.item = @buy_window.item
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @command_window.active = true
      @buy_dummy_window.visible = true
      @buy_window.active = false
      @buy_window.visible = false
      @status_window.visible = false
      @status_window.item = nil
      @help_window.set_text("")
      return
    end
    if Input.trigger?(Input::C)
      @item = @buy_window.item
      number = $game_party.item_number(@item)
      item_lim = IEX::SCENE_SHOP::MAX_BUY_ITEMS
      if @item == nil or @item.price > $game_party.gold or number == item_lim
        Sound.play_buzzer
      else
        Sound.play_decision
        max = @item.price == 0 ? item_lim : $game_party.gold / @item.price
        max = [max, item_lim - number].min
        @buy_window.active = false
        @buy_window.visible = false
        @number_window.set(@item, max, @item.price)
        @number_window.active = true
        @number_window.visible = true
      end
    end
  end

  #--------------------------------------------------------------------------
  # * Update Sell Item Selection
  #--------------------------------------------------------------------------
  def update_sell_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @command_window.active = true
      @buy_dummy_window.visible = true
      @sell_window.active = false
      @sell_window.visible = false
      @status_window.item = nil
      @help_window.set_text("")
    elsif Input.trigger?(Input::C)
      @item = @sell_window.item
      @status_window.item = @item
      if @item == nil or @item.price == 0
        Sound.play_buzzer
      else
        Sound.play_decision
        max = $game_party.item_number(@item)
        @sell_window.active = false
        @sell_window.visible = false
        @number_window.set(@item, max, @item.price / 2)
        @number_window.active = true
        @number_window.visible = true
        @status_window.visible = true
      end
    end
  end

end
