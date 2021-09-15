#encoding:UTF-8
# Window_ShopNumber
#==============================================================================
# ** Window_ShopNumber
#------------------------------------------------------------------------------
#  This window is for inputting quantity of items to buy or sell on the shop
# screen.
#==============================================================================

class Window_ShopNumber < Window_Selectable
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :number                   # quantity entered
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, height)
    super(x, y, window_width, height)
    @item = nil
    @max = 1
    @price = 0
    @number = 1
    @currency_unit = Vocab::currency_unit
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return 304
  end
  #--------------------------------------------------------------------------
  # * Set Item, Max Quantity, Price, and Currency Unit
  #--------------------------------------------------------------------------
  def set(item, max, price, currency_unit = nil)
    @item = item
    @max = max
    @price = price
    @currency_unit = currency_unit if currency_unit
    @number = 1
    refresh
  end
  #--------------------------------------------------------------------------
  # * Set Currency Unit
  #--------------------------------------------------------------------------
  def currency_unit=(currency_unit)
    @currency_unit = currency_unit
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_item_name(@item, 0, item_y)
    draw_number
    draw_total_price
  end
  #--------------------------------------------------------------------------
  # * Draw Quantity
  #--------------------------------------------------------------------------
  def draw_number
    change_color(normal_color)
    draw_text(cursor_x - 28, item_y, 22, line_height, "×")
    draw_text(cursor_x, item_y, cursor_width - 4, line_height, @number, 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Total Price
  #--------------------------------------------------------------------------
  def draw_total_price
    width = contents_width - 8
    draw_currency_value(@price * @number, @currency_unit, 4, price_y, width)
  end
  #--------------------------------------------------------------------------
  # * Y Coordinate of Item Name Display Line
  #--------------------------------------------------------------------------
  def item_y
    contents_height / 2 - line_height * 3 / 2
  end
  #--------------------------------------------------------------------------
  # * Y Coordinate of Price Display Line
  #--------------------------------------------------------------------------
  def price_y
    contents_height / 2 + line_height / 2
  end
  #--------------------------------------------------------------------------
  # * Get Cursor Width
  #--------------------------------------------------------------------------
  def cursor_width
    figures * 10 + 12
  end
  #--------------------------------------------------------------------------
  # * Get X Coordinate of Cursor
  #--------------------------------------------------------------------------
  def cursor_x
    contents_width - cursor_width - 4
  end
  #--------------------------------------------------------------------------
  # * Get Maximum Number of Digits for Quantity Display
  #--------------------------------------------------------------------------
  def figures
    return 2
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if active
      last_number = @number
      update_number
      if @number != last_number
        Sound.play_cursor
        refresh
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Update Quantity
  #--------------------------------------------------------------------------
  def update_number
    change_number(1)   if Input.repeat?(:RIGHT)
    change_number(-1)  if Input.repeat?(:LEFT)
    change_number(10)  if Input.repeat?(:UP)
    change_number(-10) if Input.repeat?(:DOWN)
  end
  #--------------------------------------------------------------------------
  # * Change Quantity
  #--------------------------------------------------------------------------
  def change_number(amount)
    @number = [[@number + amount, @max].min, 1].max
  end
  #--------------------------------------------------------------------------
  # * Update Cursor
  #--------------------------------------------------------------------------
  def update_cursor
    cursor_rect.set(cursor_x, item_y, cursor_width, line_height)
  end
end
