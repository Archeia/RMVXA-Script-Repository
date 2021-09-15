#encoding:UTF-8
# Window_ShopBuy
#==============================================================================
# ** Window_ShopBuy
#------------------------------------------------------------------------------
#  This window displays a list of buyable goods on the shop screen.
#==============================================================================

class Window_ShopBuy < Window_Selectable
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :status_window            # Status window
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, height, shop_goods)
    super(x, y, window_width, height)
    @shop_goods = shop_goods
    @money = 0
    refresh
    select(0)
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return 304
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #--------------------------------------------------------------------------
  # * Get Item
  #--------------------------------------------------------------------------
  def item
    @data[index]
  end
  #--------------------------------------------------------------------------
  # * Set Party Gold
  #--------------------------------------------------------------------------
  def money=(money)
    @money = money
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Activation State of Selection Item
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index])
  end
  #--------------------------------------------------------------------------
  # * Get Price of Item
  #--------------------------------------------------------------------------
  def price(item)
    @price[item]
  end
  #--------------------------------------------------------------------------
  # * Display in Enabled State?
  #--------------------------------------------------------------------------
  def enable?(item)
    item && price(item) <= @money && !$game_party.item_max?(item)
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
  #--------------------------------------------------------------------------
  # * Create Item List
  #--------------------------------------------------------------------------
  def make_item_list
    @data = []
    @price = {}
    @shop_goods.each do |goods|
      case goods[0]
      when 0;  item = $data_items[goods[1]]
      when 1;  item = $data_weapons[goods[1]]
      when 2;  item = $data_armors[goods[1]]
      end
      if item
        @data.push(item)
        @price[item] = goods[2] == 0 ? item.price : goods[3]
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    rect = item_rect(index)
    draw_item_name(item, rect.x, rect.y, enable?(item))
    rect.width -= 4
    draw_text(rect, price(item), 2)
  end
  #--------------------------------------------------------------------------
  # * Set Status Window
  #--------------------------------------------------------------------------
  def status_window=(status_window)
    @status_window = status_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item) if @help_window
    @status_window.item = item if @status_window
  end
end
