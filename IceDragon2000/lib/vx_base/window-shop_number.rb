#encoding:UTF-8
# Window_ShopNumber
#==============================================================================
# ** Window_ShopNumber
#------------------------------------------------------------------------------
#  This window is for inputting quantity of items to buy or sell on the
# shop screen.
#==============================================================================

class Window_ShopNumber < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x : window X coordinate
  #     y : window Y coordinate
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, 304, 304)
    @item = nil
    @max = 1
    @price = 0
    @number = 1
  end
  #--------------------------------------------------------------------------
  # * Set Items, Max Quantity, and Price
  #--------------------------------------------------------------------------
  def set(item, max, price)
    @item = item
    @max = max
    @price = price
    @number = 1
    refresh
  end
  #--------------------------------------------------------------------------
  # * Set Inputted Quantity
  #--------------------------------------------------------------------------
  def number
    return @number
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    y = 96
    self.contents.clear
    draw_item_name(@item, 0, y)
    self.contents.font.color = normal_color
    self.contents.draw_text(212, y, 20, WLH, "×")
    self.contents.draw_text(248, y, 20, WLH, @number, 2)
    self.cursor_rect.set(244, y, 28, WLH)
    draw_currency_value(@price * @number, 4, y + WLH * 2, 264)
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if self.active
      last_number = @number
      if Input.repeat?(Input::RIGHT) and @number < @max
        @number += 1
      end
      if Input.repeat?(Input::LEFT) and @number > 1
        @number -= 1
      end
      if Input.repeat?(Input::UP) and @number < @max
        @number = [@number + 10, @max].min
      end
      if Input.repeat?(Input::DOWN) and @number > 1
        @number = [@number - 10, 1].max
      end
      if @number != last_number
        Sound.play_cursor
        refresh
      end
    end
  end
end
