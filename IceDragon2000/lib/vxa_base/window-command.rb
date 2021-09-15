#encoding:UTF-8
# Window_Command
#==============================================================================
# ** Window_Command
#------------------------------------------------------------------------------
#  This window deals with general command choices.
#==============================================================================

class Window_Command < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y)
    clear_command_list
    make_command_list
    super(x, y, window_width, window_height)
    refresh
    select(0)
    activate
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return 160
  end
  #--------------------------------------------------------------------------
  # * Get Window Height
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)
  end
  #--------------------------------------------------------------------------
  # * Get Number of Lines to Show
  #--------------------------------------------------------------------------
  def visible_line_number
    item_max
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items
  #--------------------------------------------------------------------------
  def item_max
    @list.size
  end
  #--------------------------------------------------------------------------
  # * Clear Command List
  #--------------------------------------------------------------------------
  def clear_command_list
    @list = []
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
  end
  #--------------------------------------------------------------------------
  # * Add Command
  #     name    : Command name
  #     symbol  : Corresponding symbol
  #     enabled : Activation state flag
  #     ext     : Arbitrary extended data
  #--------------------------------------------------------------------------
  def add_command(name, symbol, enabled = true, ext = nil)
    @list.push({:name=>name, :symbol=>symbol, :enabled=>enabled, :ext=>ext})
  end
  #--------------------------------------------------------------------------
  # * Get Command Name
  #--------------------------------------------------------------------------
  def command_name(index)
    @list[index][:name]
  end
  #--------------------------------------------------------------------------
  # * Get Activation State of Command
  #--------------------------------------------------------------------------
  def command_enabled?(index)
    @list[index][:enabled]
  end
  #--------------------------------------------------------------------------
  # * Get Command Data of Selection Item
  #--------------------------------------------------------------------------
  def current_data
    index >= 0 ? @list[index] : nil
  end
  #--------------------------------------------------------------------------
  # * Get Activation State of Selection Item
  #--------------------------------------------------------------------------
  def current_item_enabled?
    current_data ? current_data[:enabled] : false
  end
  #--------------------------------------------------------------------------
  # * Get Symbol of Selection Item
  #--------------------------------------------------------------------------
  def current_symbol
    current_data ? current_data[:symbol] : nil
  end
  #--------------------------------------------------------------------------
  # * Get Extended Data of Selected Item
  #--------------------------------------------------------------------------
  def current_ext
    current_data ? current_data[:ext] : nil
  end
  #--------------------------------------------------------------------------
  # * Move Cursor to Command with Specified Symbol
  #--------------------------------------------------------------------------
  def select_symbol(symbol)
    @list.each_index {|i| select(i) if @list[i][:symbol] == symbol }
  end
  #--------------------------------------------------------------------------
  # * Move Cursor to Command with Specified Extended Data
  #--------------------------------------------------------------------------
  def select_ext(ext)
    @list.each_index {|i| select(i) if @list[i][:ext] == ext }
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    change_color(normal_color, command_enabled?(index))
    draw_text(item_rect_for_text(index), command_name(index), alignment)
  end
  #--------------------------------------------------------------------------
  # * Get Alignment
  #--------------------------------------------------------------------------
  def alignment
    return 0
  end
  #--------------------------------------------------------------------------
  # * Get Activation State of OK Processing
  #--------------------------------------------------------------------------
  def ok_enabled?
    return true
  end
  #--------------------------------------------------------------------------
  # * Call OK Handler
  #--------------------------------------------------------------------------
  def call_ok_handler
    if handle?(current_symbol)
      call_handler(current_symbol)
    elsif handle?(:ok)
      super
    else
      activate
    end
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    clear_command_list
    make_command_list
    create_contents
    super
  end
end
