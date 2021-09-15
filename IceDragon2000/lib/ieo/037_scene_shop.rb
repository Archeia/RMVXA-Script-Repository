#encoding:UTF-8
# IEO-037(Scene Shop)
module IEX
  module SCENE_SHOP
#==============================================================================#
#                           Start Customization
#------------------------------------------------------------------------------#
#==============================================================================#
# ---------------------------------------------------------------------------- #
# Visuals
    # Window Size and Positioing Information
    # If you are unsure of what to do, leave it.
    # Also DO NOT have the width or height LESS than 56.
    # But why would you do that? You couldn't see anything.
    GWIDTH  = Graphics.width
    GHEIGHT = Graphics.height

    # Original Positioning for 640 x 480 display
    OWINDOW_POS_SIZE = {
    # :some window    => [x, y, width, height, opacity]
      :help_window      => [GWIDTH / 2, 56, GWIDTH / 2, 56, 255],
      :header_window    => [0, 0, GWIDTH - 156, 56, 255],
      :gold_window      => [GWIDTH - 156, 0, 156, 56, 255],
      :buy_dummy_window => [0, 112, GWIDTH, 304, 255],
      :buy_window       => [0, 112,(GWIDTH / 2) + 32, 304, 255],
      :sell_window      => [0, 112, GWIDTH, 304, 255],
      :number_window    => [0, 112, GWIDTH / 2, 304 / 2, 255],
      :status_window    => [(GWIDTH / 2) + 32, 112, (GWIDTH / 2) - 32, 304, 255],
      :item_type_strip  => [0, GHEIGHT-60, GWIDTH, 56, 255]
    }

    # FFX Style
    FFXWINDOW_POS_SIZE = {
    # :some window    => [x, y, width, height, opacity]
      :help_window      => [0, GHEIGHT-56, GWIDTH, 56, 255],
      :header_window    => [0, GHEIGHT-56*3, GWIDTH/4, 56, 255],
      :gold_window      => [0, GHEIGHT-56*2, GWIDTH/4, 56, 255],
      :buy_dummy_window => [GWIDTH/4, 168,(GWIDTH/4*3), GHEIGHT-168-56, 255],
      :buy_window       => [GWIDTH/4, 168,(GWIDTH/4*3), GHEIGHT-168-56, 255],
      :sell_window      => [GWIDTH/4,   0,(GWIDTH/4*3), GHEIGHT-56    , 255],
      :number_window    => [GWIDTH/4, 168,(GWIDTH/4*3), GHEIGHT-168-56, 255],
      :status_window    => [0, 112, GWIDTH/4, GHEIGHT-168-112, 255],
      :item_type_strip  => [GWIDTH/4, 112, (GWIDTH/4*3), 56, 255]
    }
    FFXWINDOW_POS_SIZE[:status_window] = [GWIDTH/4, 0, (GWIDTH/4*3), 112, 255]

    # Assign the window position data # DO NOT LEAVE AS NIL
    WINDOW_POS_SIZE = FFXWINDOW_POS_SIZE

    # Should the Icon Tab strip be used?
    USE_ICON_STRIP = true

    # Window Modes
    # 0 Default, 1 Detailed (Only Finished with Weapons and Armor)
    NUMBER_WINDOW_MODE = 1
    # 0 Default, 1 Detailed
    SHOP_WINDOW_MODE = 1
    # 0 Default, 1 ShortDefault, 2 Actor Strip
    STATUS_MODE = 2

    # Command_Window Settings (Original)
    OSHOP_COMMAND_SETTINGS = {
      # :position => [x, y],
      :position => [0, 56],
      :width    => GWIDTH / 2,
      :columns  => 3,
      :spacing  => 16,
      :font_size=> 16,
    }

    # Command_Window Settings (FFX)
    FFXSHOP_COMMAND_SETTINGS = {
      # :position => [x, y],
      :position => [0, 0],
      :width    => GWIDTH / 4,
      :columns  => 1,
      :spacing  => 16,
      :font_size=> 16,
    }

    SHOP_COMMAND_SETTINGS = FFXSHOP_COMMAND_SETTINGS

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
      :item_type_strip  => nil,
    }

    # This controls 2 things,
    # 1 Available Shop Types
    # 2 Shop Type Icons
    # Amazing huh?
    # Use this tag with any item, equipment, or even skill (Serves no purpose here)
    # <shoptype: phrase>
    # This will assign the item to a group stated here
    # NOTE* Items, Weapons, Armor, Skills are all auto-assigned
    # You can easily change thme by using the shoptype tag.
    SHOP_ITEM_TYPES = {
      # Name(Note this must be in full caps) => icon_index
      "ITEM"      => 64,
      "WEAPON"    => 1,
      "ARMOR"     => 42,
      "HELMET"    => 32,
      "ARMS"      => 50,
      "LEGS"      => 48,
      "BATTLE"    => 186,
    }
    SHOP_TYPE_ORDER = ["ITEM", "BATTLE", "WEAPON", "ARMOR", "HELMET", "ARMS", "LEGS"]

    # By changing this constant from nil, all items will become the written one
    # Use this if you decided not to use the icon strip
    FORCE_ASSIGN = nil

    # Shop Icons
    SHOP_ICONS = {
   #:some_icon  => icon_index,
      :buy_icon   => 144,
      :sell_icon  => 147,
      :cancel_icon=> 213,
      :gold_icon  => 205,
   :def_shop_icon => 144,
      :have_icon  => 144,
   # Status Icons
      :atk_icon   => 2,
      :def_icon   => 52,
   # Shop Status Icons
  :possesion_icon => 144,
    }
    # Font size used when showing currency
    CURRENCY_FONT_SIZE = 18
    # Other settings
    # Number of Columns the Sell window has
    SHOP_TABS = 1

    # Should items with a price of 0 be included
    SHOW_UNSELLABLE_ITEMS = false

# ---------------------------------------------------------------------------- #
# Shop Settings

    # Maximum number of an item that can be bought from the shop
    MAX_BUY_ITEMS = 99

    # Items will sell at x% of there original price
    # Default is 50
    SELL_RATE = 75 # Items will sell back at 75% there original price

# ---------------------------------------------------------------------------- #
# Vocab

    # Vocab
    DEF_SHOP_NAME     = "Shop"
    PRICE_0_TEXT      = "Free"
    UNIT_PRICE_FORMAT = "Unit Price: %d"
    CANT_EQUIP_TEXT   = "Can't Equip"
    ITEM_TYPE_TEXTS = {
      :weapon         => "Weapon",
      :armor          => "Armor",
      :useable_item   => "Consume",
      :not_useable    => "Unusable",
      :not_consumable => "Non Consume",
      :battle_item    => "Battle",
    }
#==============================================================================
#                           End Customization
#------------------------------------------------------------------------------
#==============================================================================
  end
end

module IEX::SCENE_SHOP

  # You can create a custom resale rate for items here.
  def self.sell_rate(item)
    case item
    when RPG::UsableItem
      #
    when RPG::Weapon
      #
    when RPG::Armor
      #
    when RPG::Skill # Currently does nothing
    end
    return SELL_RATE
  end

end

class RPG::BaseItem

  def sscmv_cache
    @sscmv_cache_complete = false
    case self
    when RPG::UsableItem
      @shop_type = "ITEM"
    when RPG::Weapon
      @shop_type = "WEAPON"
    when RPG::Armor
      @shop_type = "ARMOR"
    when RPG::Skill # Now why did I do this?
      @shop_type = "SKILL"
    end
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when /<(?:SHOP_TYPE|SHOP TYPE|shoptype):[ ](.*)>/i
      @shop_type = $1.to_s.upcase
    end
    }
    @shop_type = IEX::SCENE_SHOP::FORCE_ASSIGN if IEX::SCENE_SHOP::FORCE_ASSIGN != nil
    @sscmv_cache_complete = true
  end

  def shop_type
    sscmv_cache unless @sscmv_cache_complete
    return @shop_type
  end

end

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

class Game_Interpreter

  def set_custom_shop_name(new_name)
    $game_system.custom_shop_name = new_name
  end

  def set_custom_shop_icon(new_icon)
    $game_system.custom_shop_icon = new_icon
  end

end

class Window_Base < Window

  def open_close_state?
    return true if @opening
    return true if @closing
    return false
  end

end

class IEX_ShopWindow_Item < Window_Selectable

  attr_accessor :back_sprite

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

  def item
    return @data[self.index]
  end

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

  def enable?(item)
    return $game_party.item_can_use?(item)
  end

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

  def draw_item(index)
    item = @data[index]
    number = $game_party.item_number(item)
    #enabled = (item.price <= $game_party.gold and number < IEX::SCENE_SHOP::MAX_BUY_ITEMS)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    draw_item_name(item, rect.x, rect.y)#, enabled)
    rect.width -= 4
    def_size = self.contents.font.size
    self.contents.font.size = IEX::SCENE_SHOP::CURRENCY_FONT_SIZE
    case IEX::SCENE_SHOP::SHOP_WINDOW_MODE
    when 0
    when 1
      draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:have_icon], rect.x + (rect.width - 24),rect.y)
      self.contents.draw_text(rect.x - 24, rect.y, rect.width, rect.height, number, 2)
      rect.width -= 128
    end
    if item.price <= 0
      self.contents.draw_text(rect.x - 24, rect.y, rect.width, rect.height, IEX::SCENE_SHOP::PRICE_0_TEXT , 2)
    else
      price = IEX::SCENE_SHOP.sell_rate(item) * item.price / 100
      draw_currency_value(price, rect.x - 24, rect.y, rect.width)
      #self.contents.draw_text(rect.x - 24, rect.y, rect.width, rect.height, item.price, 2)
    end
    self.contents.font.size = def_size
    draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:gold_icon], rect.x + (rect.width - 24),rect.y)
  end

  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end

end

class IEX_Window_CurrentItems < IEX_ShopWindow_Item

  def initialize(x, y, width, height, columns)
    super(x, y, width, height, columns)
  end

  def enable?(item)
    return (item.price > 0)
  end

end

class IEX_Window_Gold < Window_Base

  attr_accessor :back_sprite

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

  def refresh
    self.contents.clear
    draw_currency_value($game_party.gold, 4, 0, self.contents.width - 4)
    draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:gold_icon], 0, 0, true)
  end

end

class IEX_Window_ShopBuy < Window_Selectable

  attr_accessor :back_sprite
  attr_reader   :type
  attr_reader   :last_coords

  def initialize(x, y, width, height, columns = 1, spacing = 32)
    super(x, y, width, height)
    @shop_goods = $game_temp.shop_goods
    @column_max = columns
    create_backsprite
    @last_coords = []
    @type = ""
    refresh
    self.index = 0
  end

  def create_backsprite
    @back_sprite = Sprite.new
    @back_sprite.x = self.x
    @back_sprite.y = self.y
  end

  def set_filter_type(new_type = nil)
    if new_type != nil
      @type = new_type
      refresh
    end
  end

  def set_coords(coords)
    return if self.disposed?
    self.x = coords[0]
    self.y = coords[1]
    self.width = coords[2]
    self.height = coords[3]
    self.opacity = coords[4]
    @last_coords = coords
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
    @back_sprite.visible = vis if @back_sprite != nil
    super(vis)
  end

  def item
    return @data[self.index]
  end

  def refresh
    @data = @shop_goods.inject([]) { |result, goods_item|
      case goods_item[0]
      when 0 ; item = $data_items[goods_item[1]]
      when 1 ; item = $data_weapons[goods_item[1]]
      when 2 ; item = $data_armors[goods_item[1]]
      else   ; item = nil
      end
      result.push(item ) if [item.shop_type, "ALL"].include?( @type) unless item.nil?()
      result
    }
    @item_max = @data.size
    create_contents()
    for i in 0...@item_max ; draw_item(i) ; end
  end

  def any_valid_items?
    return @data.size > 0
  end

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
    case IEX::SCENE_SHOP::SHOP_WINDOW_MODE
    when 0
    when 1
      draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:have_icon], rect.x + (rect.width - 24),rect.y)
      self.contents.draw_text(rect.x - 24, rect.y, rect.width, rect.height, number, 2)
      rect.width -= 128
    end
    if item.price <= 0
      self.contents.draw_text(rect.x - 24, rect.y, rect.width, rect.height, IEX::SCENE_SHOP::PRICE_0_TEXT , 2)
    else
      draw_currency_value(item.price, rect.x - 24, rect.y, rect.width)
      #self.contents.draw_text(rect.x - 24, rect.y, rect.width, rect.height, item.price, 2)
    end
    self.contents.font.size = def_size
    draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:gold_icon], rect.x + (rect.width - 24),rect.y)
  end

  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end

end

class IEX_Shop_ItemWindow_Help < Window_Base

  attr_accessor :back_sprite

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

class IEX_Shop_ItemCommand < Window_Selectable

  attr_reader   :commands                 # command
  attr_accessor :back_sprite

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

  def refresh
   create_contents
    for i in 0...@item_max
      icon = @commands[i][1]
      enable = @commands[i][2]
      draw_item(i, icon, enable)
    end
  end

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

class IEX_Shop_ItemHeader < Window_Base

  attr_accessor :font_size
  attr_accessor :back_sprite

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

  def reset_font_size
    @font_size = 26
  end

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
  attr_accessor :icon_strip

  def initialize(x, y)
    super(x, y)
    @back_sprite = Sprite.new
    @back_sprite.x = self.x
    @back_sprite.y = self.y
    @type = "ALL"
    if IEX::SCENE_SHOP::USE_ICON_STRIP
      window_skins = IEX::SCENE_SHOP::WINDOW_SKINS
      @icon_strip = IEX_ShopType_BarWindow.new(0, 0, Graphics.width, 56)
      @icon_strip.set_coords(IEX::SCENE_SHOP::WINDOW_POS_SIZE[:item_type_strip])
      if window_skins[:item_type_strip] != nil
        @icon_strip.back_sprite.bitmap = Cache.system(window_skins[:item_type_strip])
      end
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
    if @icon_strip != nil
      @icon_strip.dispose
      @icon_strip = nil
    end
    super
  end

  def update_win_type(new_type)
    if new_type != @type and new_type != nil
      @type = new_type
      @icon_strip.update_win_type(new_type) if @icon_strip != nil
    end
  end

  def draw_actor_graphic(actor, x, y, enabled=true)
    draw_character(actor.character_name, actor.character_index, x, y, enabled)
  end

  def draw_character(character_name, character_index, x, y, enabled=true)
    return if character_name == nil
    bitmap = Cache.character(character_name)
    sign = character_name[/^[\!\$]./]
    if sign != nil and sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new((n%4*3+1)*cw, (n/4*4)*ch, cw, ch)
    self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect, enabled ? 255 : 128)
  end

  def refresh
    self.contents.clear
    yo = 0 # 56
    case IEX::SCENE_SHOP::STATUS_MODE
    when 0
      if @item != nil
        number = $game_party.item_number(@item)
        draw_possession(4, yo, number)
        for actor in $game_party.members
          x = 4
          y = yo + WLH * (2 + actor.index * 2)
          draw_actor_parameter_change(actor, x, y, 0)
        end
      end
    when 1
      if @item != nil
        number = $game_party.item_number(@item)
        draw_possession(4, yo, number)
        for actor in $game_party.members
          x = 4
          y = yo + WLH * (2 + actor.index * 2)
          draw_actor_parameter_change(actor, x, y, 1)
        end
      end
    when 2
      coun = 0
      for actor in $game_party.members
        y = yo + WLH + 16
        perwidth = self.contents.width / $game_party.members.size
        sx = (self.contents.width - (32 * $game_party.members.size)) / $game_party.members.size / 2
        x = 16+sx+(perwidth * coun)
        draw_actor_graphic(actor, x, y, actor.equippable?(@item))
        coun += 1
      end
      coun = 0
      if @item != nil
        number = $game_party.item_number(@item)
        for actor in $game_party.members
          perwidth = self.contents.width / $game_party.members.size
          sx = (self.contents.width - (32 * $game_party.members.size)) / $game_party.members.size / 2
          x = sx+(perwidth * coun)
          y = yo + WLH
          draw_actor_parameter_change(actor, x - 8, y, 2)
          coun += 1
        end
      end
    end
  end

  def draw_possession(x, y, number)
    self.contents.font.color = system_color
    draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:possesion_icon], x, y)
    self.contents.draw_text(x + 28, y, self.contents.width-x-32, WLH, Vocab::Possession)
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 28, y, self.contents.width-x-32, WLH, number.to_i, 2)
  end

  def draw_actor_parameter_change(actor, x, y, mode = 0)
    return if @item.is_a?(RPG::Item)
    enabled = actor.equippable?(@item)
    self.contents.font.color = system_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    if mode != 2
      self.contents.draw_text(x, y, self.contents.width - 32, WLH, actor.name)
    end
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

      case mode
      when 0
        self.contents.font.size = 18
        draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:atk_icon], self.contents.width - 92, y) #x
        draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:def_icon], self.contents.width - 20, y)
        stat_height = 28
        self.contents.draw_text(x, y, self.contents.width - 96, stat_height, sprintf("%+d %s", change_atk, stat_name_atk), 2)
        self.contents.draw_text(x, y, self.contents.width - 24, stat_height, sprintf("%+d %s", change_def, stat_name_def), 2)
        self.contents.font.size = def_size
      when 1
        atk_x = self.contents.width - 64
        def_x = self.contents.width - 32
        draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:atk_icon], atk_x, y) #x
        draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:def_icon], def_x, y)
        stat_height = 28
        self.contents.font.size = 21
        if change_atk >= 0 then ; self.contents.font.color = hp_gauge_color2
        else ; self.contents.font.color = crisis_color
        end
        self.contents.draw_text(atk_x, y, 24, stat_height, change_atk, 2)
        if change_def >= 0 then ; self.contents.font.color = mp_gauge_color2
        else ; self.contents.font.color = crisis_color
        end
        self.contents.draw_text(def_x, y, 24, stat_height, change_def, 2)
        self.contents.font.size = def_size
        self.contents.font.color = normal_color
      when 2
        atk_x = x
        atk_y = y
        def_x = x + 24
        def_y = y + 24
        draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:atk_icon], atk_x, atk_y) #x
        draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:def_icon], def_x, def_y)
        stat_height = 28
        self.contents.font.size = 21
        if change_atk >= 0 then ; self.contents.font.color = hp_gauge_color2
        else ; self.contents.font.color = crisis_color
        end
        self.contents.draw_text(atk_x, atk_y, 24, stat_height, change_atk, 2)
        if change_def >= 0 then ; self.contents.font.color = mp_gauge_color2
        else ; self.contents.font.color = crisis_color
        end
        self.contents.draw_text(def_x, def_y, 24, stat_height, change_def, 2)
        self.contents.font.size = def_size
        self.contents.font.color = normal_color
      end
    else
      self.contents.font.color.alpha = 255
      if mode == 2
        self.contents.font.size = 12
        self.contents.draw_text(x, y, 64, WLH, IEX::SCENE_SHOP::CANT_EQUIP_TEXT, 0)
      else
        self.contents.font.size = 18
        self.contents.draw_text(x, y, self.contents.width - x, WLH, IEX::SCENE_SHOP::CANT_EQUIP_TEXT, 2)
      end
    end
    def_size = self.contents.font.size
    if mode != 2
      self.contents.font.size = 18
      draw_item_name(item1, x + 16, y + WLH, enabled)
    end
    self.contents.font.size = def_size
  end

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
    if @icon_strip != nil
      @icon_strip.update if @icon_strip != nil
    end
  end

  def visible=(vis)
    @back_sprite.visible = vis
    @icon_strip.visible = vis if @icon_strip != nil
    super(vis)
  end

end

class IEX_ShopType_BarWindow < Window_Base

  attr_accessor :back_sprite

  def initialize(*args)
    super(*args)
    @back_sprite = Sprite.new
    @back_sprite.x = self.x
    @back_sprite.y = self.y
    @type = "ALL"
    @type_icons = {}
    for wi in IEX::SCENE_SHOP::SHOP_ITEM_TYPES.keys
      @type_icons[wi]  = IEX_Icon_Sprite.new
      @type_icons[wi].z = 200
      @type_icons[wi].set_icon(IEX::SCENE_SHOP::SHOP_ITEM_TYPES[wi])
    end
    @icon_order = IEX::SCENE_SHOP::SHOP_TYPE_ORDER
    update_icon_pos
    update_icon_type
  end

  def set_coords(coords)
    self.x = coords[0]
    self.y = coords[1]
    self.width = coords[2]
    self.height = coords[3]
    self.opacity = coords[4]
    create_contents
    update
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
  end

  def set_icon_opacity(val)
    for spr in @type_icons.values
      next if spr == nil
      spr.opacity = val
    end
  end

  def update_fadein
    for key in @type_icons.keys
      spr = @type_icons[key]
      next if spr == nil
      olimit = 128 if @type == key
      olimit = 255 if @type == key
      spr.opacity = [spr.opacity + (255/60), olimit].min
    end
  end

  def update_fadeout
  end

  def update
    super
    update_icon_pos
    if @back_sprite != nil
      @back_sprite.visible = self.visible
      @back_sprite.x = self.x
      @back_sprite.y = self.y
    end
  end

  def update_win_type(new_type)
    if new_type != @type and new_type != nil
      @type = new_type
      update_icon_type
    end
  end

  def update_icon_pos
    coun = 0
    for ty in @icon_order
      spr = @type_icons[ty]
      next if spr == nil
      perwidth = self.contents.width / @icon_order.size
      sx = (self.contents.width - (24 * @icon_order.size)) / @icon_order.size / 2
      spr.x = 16+self.x+sx+(perwidth * coun)
      spr.y = self.y + (self.height-24) / 2
      coun += 1
    end
  end

  def update_icon_type
    for spr in @type_icons.values
      next if spr == nil
      spr.opacity = 128
    end
    case @type.upcase
    when "ALL"
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

  def visible=(vis)
    @back_sprite.visible = vis
    for spr in @type_icons.values
      next if spr == nil
      spr.visible = vis
    end
    super(vis)
  end

end

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

  def refresh
    self.contents.clear
    def_size = self.contents.font.size
    self.contents.font.size = 18
    draw_item_name(@item, 4, 4)
    self.contents.font.size = def_size
    draw_item_special_data(@item, 0, 4, self.contents.width / 2, 2)
    self.contents.font.color = normal_color
    pri = sprintf(IEX::SCENE_SHOP::UNIT_PRICE_FORMAT, @price)
    draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:gold_icon], 4, 28)

    self.contents.draw_text(28, 28, self.contents.width, WLH, pri)
    self.contents.font.color = normal_color
    self.contents.draw_text(4, self.contents.height - 32, 24, WLH, "x")
    self.contents.draw_text(32, self.contents.height - 32, 24, WLH, @number, 2)
    self.cursor_rect.set(36, self.contents.height - 32, 28, WLH)
    draw_currency_value(@price * @number, 4, self.contents.height - 32, self.contents.width - 64)
    draw_icon(IEX::SCENE_SHOP::SHOP_ICONS[:gold_icon], self.contents.width - 32, self.contents.height - 32)
    case IEX::SCENE_SHOP::NUMBER_WINDOW_MODE
    when 1
      case @item
      when RPG::Weapon, RPG::Armor
        stats = ['atk', 'def', 'spi', 'agi']
        stats.unshift('maxmp') if $imported["EquipmentOverhaul"]
        stats.unshift('maxhp') if $imported["EquipmentOverhaul"]
        stats << 'dex' if $imported["DEX Stat"]
        stats << 'res' if $imported["RES Stat"]
        line_limit = self.contents.height - 32 - 64
        line_limit /= 24
        x_coun = 0 ; y_coun = 0 ; coun = 0
        for stat in stats
          x_coun = coun / line_limit ; y_coun = coun % line_limit
          ww = self.contents.width / 4
          rect = Rect.new(8+(ww*x_coun), 56+(24*y_coun), self.contents.width / 2, WLH)
          if $imported["IconModuleLibrary"]
            case stat.to_sym
            when :hp, :maxhp
              draw_icon(YEM::ICON[:basic_stats][:hp], rect.x, rect.y)
            when :mp, :maxmp
              draw_icon(YEM::ICON[:basic_stats][:mp], rect.x, rect.y)
            else
              draw_icon(YEM::ICON[:basic_stats][stat.to_sym], rect.x, rect.y)
            end
            rect.x += 24
          end
          def_size = self.contents.font.size
          self.contents.font.size = 18
          self.contents.font.color = system_color
          case stat.to_sym
          when :hp, :maxhp
            tx = Vocab.hp_a
          when :mp, :maxmp
            tx = Vocab.mp_a
          else
            tx = Vocab.send(stat)
          end
          self.contents.draw_text(rect, tx)
          self.contents.font.size = 16
          self.contents.font.color = normal_color
          tx = @item.send(stat)
          rect.x += 48
          self.contents.draw_text(rect, tx)
          coun += 1
          self.contents.font.size = def_size
        end
      end
    end
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

class Scene_Shop < Scene_Base

  def start
    super
    create_menu_background
    create_command_window
    @win_index = 0
    @help_window   = IEX_Shop_ItemWindow_Help.new(0, (416 - 56), 544, 56)
    @header_window = IEX_Shop_ItemHeader.new(0, 0, 384, 56)
    @gold_window   = IEX_Window_Gold.new(384, 0)
    @buy_windows = {}
    for wi in IEX::SCENE_SHOP::SHOP_ITEM_TYPES.keys
      @buy_windows[wi] = IEX_Window_ShopBuy.new(544 / 2, 112, 544 / 2, 248, 1)
      @buy_windows[wi].set_filter_type(wi)
    end
    @buy_window_scroll_list = []
    @window_order = IEX::SCENE_SHOP::SHOP_TYPE_ORDER
    for ke in @window_order
      if @buy_windows[ke].any_valid_items?
        @buy_window_scroll_list.push(ke)
      end
    end
    @sell_window   = IEX_Window_CurrentItems.new(0, 112, 544, 248, IEX::SCENE_SHOP::SHOP_TABS)
    @number_window = IEX_Window_ShopNumber.new(252, 112)
    @status_window = IEX_Window_ShopStatus.new(0, 112)

    align_windows
    apply_window_skins

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
    @buy_dummy_window.index = -1 if @buy_dummy_window != nil
    @buy_dummy_window.active = false if @buy_dummy_window != nil
    @buy_window.active       = false
    @buy_window.visible      = false
    @buy_window.help_window  = @help_window
    @sell_window.active      = false
    @sell_window.visible     = false
    @sell_window.help_window = @help_window
    @number_window.active    = false
    @number_window.visible   = false
    @status_window.visible   = false
  end

  def align_windows
    @help_window.set_coords(IEX::SCENE_SHOP::WINDOW_POS_SIZE[:help_window])
    @header_window.set_coords(IEX::SCENE_SHOP::WINDOW_POS_SIZE[:header_window])
    @gold_window.set_coords(IEX::SCENE_SHOP::WINDOW_POS_SIZE[:gold_window])
    @buy_dummy_window.set_coords(IEX::SCENE_SHOP::WINDOW_POS_SIZE[:buy_dummy_window]) if @buy_dummy_window != nil
    for win in @buy_windows.values
      next if win == nil
      win.set_coords(IEX::SCENE_SHOP::WINDOW_POS_SIZE[:buy_window])
      win.visible = false
      win.active = false
      win.openness = 0
    end
    @sell_window.set_coords(IEX::SCENE_SHOP::WINDOW_POS_SIZE[:sell_window])
    @number_window.set_coords(IEX::SCENE_SHOP::WINDOW_POS_SIZE[:number_window])
    @status_window.set_coords(IEX::SCENE_SHOP::WINDOW_POS_SIZE[:status_window])
  end

  def apply_window_skins
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
      @buy_dummy_window.back_sprite.bitmap = Cache.system(window_skins[:buy_dummy_window]) if @buy_dummy_window  != nil
    end
    if window_skins[:buy_window] != nil
      for win in @buy_windows.values
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
  end

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

  def terminate()
    super()
    dispose_menu_background()
    dispose_command_window()
    @help_window.dispose()
    @gold_window.dispose()
    @sell_window.dispose()
    @number_window.dispose()
    @status_window.dispose()
    @header_window.dispose()
    @buy_windows.values.each { |win| win.dispose() }
    @buy_windows      = nil
    @buy_window       = nil
    @help_window      = nil
    @gold_window      = nil
    @buy_dummy_window = nil
    @buy_window       = nil
    @sell_window      = nil
    @number_window    = nil
    @status_window    = nil
    @header_window    = nil
    $game_system.custom_shop_name = nil
    $game_system.custom_shop_icon = nil
  end

  def dispose_command_window()
    @command_window.dispose() ; @command_window = nil
  end

  def update()
    super()
    update_menu_background()
    @help_window.update        if @help_window.active
    @command_window.update     if @command_window.active
    @gold_window.update        if @gold_window.active
    if @buy_window.active
      @buy_window.update
    elsif !@buy_window.active && @buy_window.open_close_state?()
      @buy_window.update
    end
    if @sell_window.active
      @sell_window.update
    elsif !@sell_window.active && @sell_window.open_close_state?()
      @sell_window.update
    end
    @number_window.update      if @number_window.active
    @status_window.update_win_type(@buy_window_scroll_list[@win_index])
    @status_window.update      if @status_window.active
    for win in @buy_windows.values
      next if win == nil
      next if win == @buy_window
      win.update if win.open_close_state?
    end
    if @command_window.active
      update_command_selection
    elsif @buy_window.active
      update_tab_switching
      update_buy_selection
    elsif @sell_window.active
      update_sell_selection
    elsif @number_window.active
      update_number_input
    end
  end

  def update_tab_switching
    if Input.trigger?(Input::LEFT)
      Sound.play_cursor
      @buy_window.visible = true
      @buy_window.close #visible = false
      @buy_window.active = false
      @win_index = (@win_index - 1) % @buy_window_scroll_list.size
      @buy_window = @buy_windows[@buy_window_scroll_list[@win_index]]
      @buy_window.active = true
      @buy_window.help_window = @help_window
      @buy_window.open
      @buy_window.visible = true
    elsif Input.trigger?(Input::RIGHT)
      Sound.play_cursor
      @buy_window.visible = true
      @buy_window.close #visible = false
      @buy_window.active = false
      @win_index = (@win_index + 1) % @buy_window_scroll_list.size
      @buy_window = @buy_windows[@buy_window_scroll_list[@win_index]]
      @buy_window.active = true
      @buy_window.help_window = @help_window
      @buy_window.open
      @buy_window.visible = true
    end
  end

  def update_command_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = Scene_Map.new
    elsif Input.trigger?(Input::C)
      case @command_window.index
      when 0  # buy
        Sound.play_decision
        @command_window.active = false
        @buy_dummy_window.visible = false if @buy_dummy_window != nil
        @buy_window.active = true
        @buy_window.visible = true
        @buy_window.refresh
        @status_window.visible = true
        @buy_window.openness = 0
        @status_window.openness = 0
        @buy_window.open
        @status_window.open
        open_icon_strip
        series_update
      when 1  # sell
        if $game_temp.shop_purchase_only
          Sound.play_buzzer
        else
          Sound.play_decision
          @command_window.active = false
          @buy_dummy_window.visible = false if @buy_dummy_window != nil
          @sell_window.active = true
          @sell_window.openness = 0
          @sell_window.open
          @sell_window.visible = true
          @sell_window.refresh
        end
      when 2  # Quit
        Sound.play_decision
        $scene = Scene_Map.new
      end
    end
  end

  def open_icon_strip
    if @status_window.icon_strip != nil
      @status_window.icon_strip.open
    end
  end

  def close_icon_strip
    if @status_window.icon_strip != nil
      @status_window.icon_strip.open
    end
  end

  def series_update
    for i in 0..7
      @buy_window.update
      Graphics.update
      if i > 3
        @status_window.update
      end
    end
  end

  def update_buy_selection
    @status_window.item = @buy_window.item
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @command_window.active = true
      @buy_dummy_window.visible = true if @buy_dummy_window != nil
      @buy_window.active = false
      @buy_window.close
      @status_window.close
      close_icon_strip
      series_update
      @buy_window.visible = false
      @status_window.visible = false
      @status_window.item = nil
      @help_window.set_text("")
    elsif Input.trigger?(Input::C)
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
        @buy_window.close
        @buy_window.visible = false
        @number_window.set(@item, max, @item.price)
        @number_window.active = true
        @number_window.visible = true
      end
    end
  end

  def update_sell_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @command_window.active = true
      @buy_dummy_window.visible = true if @buy_dummy_window != nil
      @sell_window.active = false
      @sell_window.close #visible = false
      @status_window.item = nil
      @help_window.set_text("")
    elsif Input.trigger?(Input::C)
      @item = @sell_window.item
      @status_window.item = @item
      if @item == nil or @item.price == 0
        Sound.play_buzzer()
      else
        Sound.play_decision()
        max = $game_party.item_number(@item)
        @sell_window.active = false
        @sell_window.close #visible = false
        open_icon_strip()
        prc = IEX::SCENE_SHOP.sell_rate(@item) * @item.price / 100
        @number_window.set(@item, max, prc)
        @number_window.active = true
        @number_window.visible = true
        @status_window.visible = true
        @status_window.openness = 0
        @status_window.open
      end
    end
  end

  def cancel_number_input()
    Sound.play_cancel()
    @number_window.active = false
    @number_window.visible = false
    case @command_window.index
    when 0  # Buy
      @buy_window.active = true
      @buy_window.visible = true
      @buy_window.open
    when 1  # Sell
      @sell_window.active = true
      @sell_window.visible = true
      @status_window.visible = false
      @sell_window.open
    end
  end

  def decide_number_input()
    Sound.play_shop()
    @number_window.active = false
    @number_window.visible = false
    case @command_window.index
    when 0  # Buy
      $game_party.lose_gold(@number_window.number * @item.price)
      $game_party.gain_item(@item, @number_window.number)
      @gold_window.refresh()
      @buy_window.refresh()
      @status_window.refresh()
      @buy_window.active = true
      @buy_window.visible = true
      @buy_window.open()
    when 1  # Sell
      prc = IEX::SCENE_SHOP.sell_rate(@item) * @item.price / 100
      $game_party.gain_gold(@number_window.number * prc)
      $game_party.lose_item(@item, @number_window.number)
      @gold_window.refresh()
      @sell_window.refresh()
      @status_window.refresh()
      @sell_window.active = true
      @sell_window.visible = true
      @status_window.visible = false
      @sell_window.open()
    end
    @buy_windows.values.each { |win| win.refresh() }
  end

end

#==============================================================================#
IEO::REGISTER.log_script(37, "SceneShop", 1.0) if $imported["IEO-Register"]
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
