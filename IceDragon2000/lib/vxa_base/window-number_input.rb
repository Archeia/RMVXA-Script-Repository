#encoding:UTF-8
# Window_NumberInput
#==============================================================================
# ** Window_NumberInput
#------------------------------------------------------------------------------
#  This window is used for the event command [Input Number].
#==============================================================================

class Window_NumberInput < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(message_window)
    @message_window = message_window
    super(0, 0, 0, 0)
    @number = 0
    @digits_max = 1
    @index = 0
    self.openness = 0
    deactivate
  end
  #--------------------------------------------------------------------------
  # * Start Input Processing
  #--------------------------------------------------------------------------
  def start
    @digits_max = $game_message.num_input_digits_max
    @number = $game_variables[$game_message.num_input_variable_id]
    @number = [[@number, 0].max, 10 ** @digits_max - 1].min
    @index = 0
    update_placement
    create_contents
    refresh
    open
    activate
  end
  #--------------------------------------------------------------------------
  # * Update Window Position
  #--------------------------------------------------------------------------
  def update_placement
    self.width = @digits_max * 20 + padding * 2
    self.height = fitting_height(1)
    self.x = (Graphics.width - width) / 2
    if @message_window.y >= Graphics.height / 2
      self.y = @message_window.y - height - 8
    else
      self.y = @message_window.y + @message_window.height + 8
    end
  end
  #--------------------------------------------------------------------------
  # * Move Cursor Right
  #     wrap : Wraparound allowed
  #--------------------------------------------------------------------------
  def cursor_right(wrap)
    if @index < @digits_max - 1 || wrap
      @index = (@index + 1) % @digits_max
    end
  end
  #--------------------------------------------------------------------------
  # * Move Cursor Left
  #     wrap : Wraparound allowed
  #--------------------------------------------------------------------------
  def cursor_left(wrap)
    if @index > 0 || wrap
      @index = (@index + @digits_max - 1) % @digits_max
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    process_cursor_move
    process_digit_change
    process_handling
    update_cursor
  end
  #--------------------------------------------------------------------------
  # * Cursor Movement Processing
  #--------------------------------------------------------------------------
  def process_cursor_move
    return unless active
    last_index = @index
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
    Sound.play_cursor if @index != last_index
  end
  #--------------------------------------------------------------------------
  # * Change Processing for Digits
  #--------------------------------------------------------------------------
  def process_digit_change
    return unless active
    if Input.repeat?(:UP) || Input.repeat?(:DOWN)
      Sound.play_cursor
      place = 10 ** (@digits_max - 1 - @index)
      n = @number / place % 10
      @number -= n * place
      n = (n + 1) % 10 if Input.repeat?(:UP)
      n = (n + 9) % 10 if Input.repeat?(:DOWN)
      @number += n * place
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Handling Processing for OK and Cancel
  #--------------------------------------------------------------------------
  def process_handling
    return unless active
    return process_ok     if Input.trigger?(:C)
    return process_cancel if Input.trigger?(:B)
  end
  #--------------------------------------------------------------------------
  # * Processing When OK Button Is Pressed
  #--------------------------------------------------------------------------
  def process_ok
    Sound.play_ok
    $game_variables[$game_message.num_input_variable_id] = @number
    deactivate
    close
  end
  #--------------------------------------------------------------------------
  # * Processing When Cancel Button Is Pressed
  #--------------------------------------------------------------------------
  def process_cancel
  end
  #--------------------------------------------------------------------------
  # * Get Rectangle for Displaying Item
  #--------------------------------------------------------------------------
  def item_rect(index)
    Rect.new(index * 20, 0, 20, line_height)
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    change_color(normal_color)
    s = sprintf("%0*d", @digits_max, @number)
    @digits_max.times do |i|
      rect = item_rect(i)
      rect.x += 1
      draw_text(rect, s[i,1], 1)
    end
  end
  #--------------------------------------------------------------------------
  # * Update Cursor
  #--------------------------------------------------------------------------
  def update_cursor
    cursor_rect.set(item_rect(@index))
  end
end
