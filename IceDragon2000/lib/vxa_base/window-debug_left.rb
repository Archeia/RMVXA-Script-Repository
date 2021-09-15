#encoding:UTF-8
# Window_DebugLeft
#==============================================================================
# ** Window_DebugLeft
#------------------------------------------------------------------------------
#  This window designates switch and variable blocks on the debug screen.
#==============================================================================

class Window_DebugLeft < Window_Selectable
  #--------------------------------------------------------------------------
  # * Class Variable
  #--------------------------------------------------------------------------
  @@last_top_row = 0                      # For saving first line
  @@last_index   = 0                      # For saving cursor position
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :right_window             # Right window
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, window_width, window_height)
    refresh
    self.top_row = @@last_top_row
    select(@@last_index)
    activate
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return 164
  end
  #--------------------------------------------------------------------------
  # * Get Window Height
  #--------------------------------------------------------------------------
  def window_height
    Graphics.height
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items
  #--------------------------------------------------------------------------
  def item_max
    @item_max || 0
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    return unless @right_window
    @right_window.mode = mode
    @right_window.top_id = top_id
  end
  #--------------------------------------------------------------------------
  # * Get Mode
  #--------------------------------------------------------------------------
  def mode
    index < @switch_max ? :switch : :variable
  end
  #--------------------------------------------------------------------------
  # * Get ID Shown on Top
  #--------------------------------------------------------------------------
  def top_id
    (index - (index < @switch_max ? 0 : @switch_max)) * 10 + 1
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    @switch_max = ($data_system.switches.size - 1 + 9) / 10
    @variable_max = ($data_system.variables.size - 1 + 9) / 10
    @item_max = @switch_max + @variable_max
    create_contents
    draw_all_items
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    if index < @switch_max
      n = index * 10
      text = sprintf("S [%04d-%04d]", n+1, n+10)
    else
      n = (index - @switch_max) * 10
      text = sprintf("V [%04d-%04d]", n+1, n+10)
    end
    draw_text(item_rect_for_text(index), text)
  end
  #--------------------------------------------------------------------------
  # * Processing When Cancel Button Is Pressed
  #--------------------------------------------------------------------------
  def process_cancel
    super
    @@last_top_row = top_row
    @@last_index = index
  end
  #--------------------------------------------------------------------------
  # * Set Right Window
  #--------------------------------------------------------------------------
  def right_window=(right_window)
    @right_window = right_window
    update
  end
end
