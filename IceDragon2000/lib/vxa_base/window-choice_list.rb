#encoding:UTF-8
# Window_ChoiceList
#==============================================================================
# ** Window_ChoiceList
#------------------------------------------------------------------------------
#  This window is used for the event command [Show Choices].
#==============================================================================

class Window_ChoiceList < Window_Command
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(message_window)
    @message_window = message_window
    super(0, 0)
    self.openness = 0
    deactivate
  end
  #--------------------------------------------------------------------------
  # * Start Input Processing
  #--------------------------------------------------------------------------
  def start
    update_placement
    refresh
    select(0)
    open
    activate
  end
  #--------------------------------------------------------------------------
  # * Update Window Position
  #--------------------------------------------------------------------------
  def update_placement
    self.width = [max_choice_width + 12, 96].max + padding * 2
    self.width = [width, Graphics.width].min
    self.height = fitting_height($game_message.choices.size)
    self.x = Graphics.width - width
    if @message_window.y >= Graphics.height / 2
      self.y = @message_window.y - height
    else
      self.y = @message_window.y + @message_window.height
    end
  end
  #--------------------------------------------------------------------------
  # * Get Maximum Width of Choices
  #--------------------------------------------------------------------------
  def max_choice_width
    $game_message.choices.collect {|s| text_size(s).width }.max
  end
  #--------------------------------------------------------------------------
  # * Calculate Height of Window Contents
  #--------------------------------------------------------------------------
  def contents_height
    item_max * item_height
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    $game_message.choices.each do |choice|
      add_command(choice, :choice)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect_for_text(index)
    draw_text_ex(rect.x, rect.y, command_name(index))
  end
  #--------------------------------------------------------------------------
  # * Get Activation State of Cancel Processing
  #--------------------------------------------------------------------------
  def cancel_enabled?
    $game_message.choice_cancel_type > 0
  end
  #--------------------------------------------------------------------------
  # * Call OK Handler
  #--------------------------------------------------------------------------
  def call_ok_handler
    $game_message.choice_proc.call(index)
    close
  end
  #--------------------------------------------------------------------------
  # * Call Cancel Handler
  #--------------------------------------------------------------------------
  def call_cancel_handler
    $game_message.choice_proc.call($game_message.choice_cancel_type - 1)
    close
  end
end
