#==============================================================================#
# ** ICY-CORE - HM_Window_Selectable 
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Version       : 1.2
# ** Date Modified : 01/08/2011
#------------------------------------------------------------------------------#
#  This is a superclass for the HM Style Window Selectable.
#==============================================================================#
$imported = {} if $imported == nil
$imported["ICY_HM_Window_Selectable"] = true

class ICY_HM_Window_Selectable < Window_Selectable
  attr_accessor :column_max
  attr_accessor :item_sq_spacing
  attr_accessor :rect_size
  attr_accessor :selection_size

  def initialize(x, y, width, height)
    @column_max = 1
    @item_sq_spacing = 48
    @rect_size = 32
    @selection_size = 42
    @index = 0
    @reset = 0
    @nw_x = 0
    @nw_y = 0
    @coun = 0
    super(x, y, width, height)
  end
  
  def off_x
    width_break = (self.width - 32)
    column_size = ([(@column_max * @item_sq_spacing), width_break].min)
    return Integer(((width_break - column_size) / 2))
  end
  
  def off_y
    height_break = (self.height - 32)
    row_size = ([(page_row_max * @item_sq_spacing), height_break].min)
    return Integer(((height_break - row_size) / 2))
  end
  
  #--------------------------------------------------------------------------
  # * Create Window Contents
  #--------------------------------------------------------------------------
  def create_contents
    self.contents.dispose
    maxbitmap = 8192
    dw = [width - 32, maxbitmap].min
    dh = [[height - 32, row_max * @item_sq_spacing].max, maxbitmap].min
    bitmap = Bitmap.new(dw, dh)
    self.contents = bitmap
  end
  
  #--------------------------------------------------------------------------
  # * Get rectangle for displaying items
  #     index : item number
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new(off_x, off_y, 0, 0)
    rect.width += @rect_size
    rect.height += @rect_size
    rect.x += index % @column_max * @item_sq_spacing
    rect.y += index / @column_max * @item_sq_spacing
    return rect
  end
  
  def refresh
    prep_coord_vars
  end
  
  def prep_coord_vars
    @reset = off_x
    @nw_x = @reset
    @nw_y = off_y
    @coun = 0
  end
  
  def advance_space
    @coun += 1
    @nw_x += @item_sq_spacing
    if @coun == @column_max
      @coun = 0
      @nw_x = @reset
      @nw_y += @item_sq_spacing 
    end
  end
  #--------------------------------------------------------------------------
  # * Get Top Row
  #--------------------------------------------------------------------------
  def top_row
    return self.oy / @item_sq_spacing#WLH
  end
  #--------------------------------------------------------------------------
  # * Set Top Row
  #     row : row shown on top
  #--------------------------------------------------------------------------
  def top_row=(row)
    row = 0 if row < 0
    row = row_max - 1 if row > row_max - 1
    self.oy = row * @item_sq_spacing
  end
  #--------------------------------------------------------------------------
  # * Get Number of Rows Displayable on 1 Page
  #--------------------------------------------------------------------------
  def page_row_max
    return (self.height / @item_sq_spacing) 
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items Displayable on 1 Page
  #--------------------------------------------------------------------------
  def page_item_max
    return page_row_max * @column_max #+ @item_sq_spacing
  end
  #--------------------------------------------------------------------------
  # * Move cursor one page down
  #--------------------------------------------------------------------------
  def cursor_pagedown
    if top_row + page_row_max < row_max
      @index = [@index + page_item_max, @item_max - 1].min
      self.top_row += page_row_max - @item_sq_spacing 
    end
  end
  #--------------------------------------------------------------------------
  # * Move cursor one page up
  #--------------------------------------------------------------------------
  def cursor_pageup
    if top_row > 0
      @index = [@index - page_item_max, 0].max
      self.top_row -= page_row_max - @item_sq_spacing 
    end
  end
  #--------------------------------------------------------------------------
  # * Update cursor
  #--------------------------------------------------------------------------
  def update_cursor
    if @index < 0                   # If the cursor position is less than 0
      self.cursor_rect.empty        # Empty cursor
    else                            # If the cursor position is 0 or more
      row = @index / @column_max    # Get current row
      if row < top_row              # If before the currently displayed
        self.top_row = row          # Scroll up
      end
      if row > bottom_row           # If after the currently displayed
        self.bottom_row = row       # Scroll down
      end
       y_l = @index / @column_max
       y_pos = ((@item_sq_spacing * y_l)- self.oy) + off_y
       x_l = self.index - (@column_max * y_l)
       x_pos = (x_l * @item_sq_spacing) + off_x
       if @selection_size > @rect_size
         subitive = (@selection_size - @rect_size) / 2
         self.cursor_rect.set(x_pos.to_i - subitive, y_pos.to_i - subitive, @selection_size, @selection_size)
       elsif @selection_size < @rect_size
         additive = (@rect_size - @selection_size) / 2
         self.cursor_rect.set(x_pos.to_i + additive, y_pos.to_i + additive, @selection_size, @selection_size)
        else
        self.cursor_rect.set(x_pos.to_i, y_pos.to_i, @selection_size, @selection_size)
       end
    end
  end
  
end
  
class ICY_HM_Window_Command < ICY_HM_Window_Selectable
  
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :commands                 # command
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     width      : window width
  #     commands   : command string array
  #     column_max : digit count (if 2 or more, horizontal selection)
  #     row_max    : row count (0: match command count)
  #     spacing    : blank space when items are arrange horizontally
  #--------------------------------------------------------------------------
  def initialize(width, commands, column_max = 1, row_max = 0, spacing = 32)
    if row_max == 0
      row_max = (commands.size + column_max - 1) / column_max
    end
    super(0, 0, width, 48+(24 * row_max))
    @commands = commands
    @item_max = commands.size
    @column_max = column_max
    refresh
    self.index = 0
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    prep_coord_vars
    self.contents.clear
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #     index   : item number
  #     enabled : enabled flag. When false, draw semi-transparently.
  #--------------------------------------------------------------------------
  def draw_item(index, enabled = true)
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    draw_icon(@commands[index], rect.x, rect.y, enabled)
  end
  
end

class HM_Window_Selectable < ICY_HM_Window_Selectable ; end
class HM_Window_Command < ICY_HM_Window_Command ; end