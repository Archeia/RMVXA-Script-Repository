#encoding:UTF-8
# Window_Message
#==============================================================================
# ** Window_Message
#------------------------------------------------------------------------------
#  This message window is used to display text.
#==============================================================================

class Window_Message < Window_Selectable
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  MAX_LINE = 4                            # Maximum number of lines
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 288, 544, 128)
    self.z = 200
    self.active = false
    self.index = -1
    self.openness = 0
    @opening = false            # WIndow opening flag
    @closing = false            # Window closing flag
    @text = nil                 # Remaining text to be displayed
    @contents_x = 0             # X coordinate for drawing next character
    @contents_y = 0             # Y coordinate for drawing next character
    @line_count = 0             # Line count drawn up until now
    @wait_count = 0             # Wait count
    @background = 0             # Background type
    @position = 2               # Display position
    @show_fast = false          # Fast forward flag
    @line_show_fast = false     # Fast forward by line flag
    @pause_skip = false         # Input standby omission flag
    create_gold_window
    create_number_input_window
    create_back_sprite
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    dispose_gold_window
    dispose_number_input_window
    dispose_back_sprite
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    update_gold_window
    update_number_input_window
    update_back_sprite
    update_show_fast
    unless @opening or @closing             # Window is not opening or closing
      if @wait_count > 0                    # Waiting within text
        @wait_count -= 1
      elsif self.pause                      # Waiting for text advancement
        input_pause
      elsif self.active                     # Inputting choice
        input_choice
      elsif @number_input_window.visible    # Inputting number
        input_number
      elsif @text != nil                    # More text exists
        update_message                        # Update message
      elsif continue?                       # If continuing
        start_message                         # Start message
        open                                  # Open window
        $game_message.visible = true
      else                                  # If not continuing
        close                                 # Close window
        $game_message.visible = @closing
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Create Gold Window
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_Gold.new(384, 0)
    @gold_window.openness = 0
  end
  #--------------------------------------------------------------------------
  # * Create Number Input Window
  #--------------------------------------------------------------------------
  def create_number_input_window
    @number_input_window = Window_NumberInput.new
    @number_input_window.visible = false
  end
  #--------------------------------------------------------------------------
  # * Create Background Sprite
  #--------------------------------------------------------------------------
  def create_back_sprite
    @back_sprite = Sprite.new
    @back_sprite.bitmap = Cache.system("MessageBack")
    @back_sprite.visible = (@background == 1)
    @back_sprite.z = 190
  end
  #--------------------------------------------------------------------------
  # * Dispose of Gold Window
  #--------------------------------------------------------------------------
  def dispose_gold_window
    @gold_window.dispose
  end
  #--------------------------------------------------------------------------
  # * Dispose of Number Input Window
  #--------------------------------------------------------------------------
  def dispose_number_input_window
    @number_input_window.dispose
  end
  #--------------------------------------------------------------------------
  # * Dispose of Background Sprite
  #--------------------------------------------------------------------------
  def dispose_back_sprite
    @back_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Update Gold Window
  #--------------------------------------------------------------------------
  def update_gold_window
    @gold_window.update
  end
  #--------------------------------------------------------------------------
  # * Update Number Input Window
  #--------------------------------------------------------------------------
  def update_number_input_window
    @number_input_window.update
  end
  #--------------------------------------------------------------------------
  # * Update Background Sprite
  #--------------------------------------------------------------------------
  def update_back_sprite
    @back_sprite.visible = (@background == 1)
    @back_sprite.y = y - 16
    @back_sprite.opacity = openness
    @back_sprite.update
  end
  #--------------------------------------------------------------------------
  # * Update Fast Forward Flag
  #--------------------------------------------------------------------------
  def update_show_fast
    if self.pause or self.openness < 255
      @show_fast = false
    elsif Input.trigger?(Input::C) and @wait_count < 2
      @show_fast = true
    elsif not Input.press?(Input::C)
      @show_fast = false
    end
    if @show_fast and @wait_count > 0
      @wait_count -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if the Next Message Should be Displayed Continuously
  #--------------------------------------------------------------------------
  def continue?
    return true if $game_message.num_input_variable_id > 0
    return false if $game_message.texts.empty?
    if self.openness > 0 and not $game_temp.in_battle
      return false if @background != $game_message.background
      return false if @position != $game_message.position
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Start Message
  #--------------------------------------------------------------------------
  def start_message
    @text = ""
    for i in 0...$game_message.texts.size
      @text += "    " if i >= $game_message.choice_start
      @text += $game_message.texts[i].clone + "\x00"
    end
    @item_max = $game_message.choice_max
    convert_special_characters
    reset_window
    new_page
  end
  #--------------------------------------------------------------------------
  # * New Page
  #--------------------------------------------------------------------------
  def new_page
    contents.clear
    if $game_message.face_name.empty?
      @contents_x = 0
    else
      name = $game_message.face_name
      index = $game_message.face_index
      draw_face(name, index, 0, 0)
      @contents_x = 112
    end
    @contents_y = 0
    @line_count = 0
    @show_fast = false
    @line_show_fast = false
    @pause_skip = false
    contents.font.color = text_color(0)
  end
  #--------------------------------------------------------------------------
  # * New Line
  #--------------------------------------------------------------------------
  def new_line
    if $game_message.face_name.empty?
      @contents_x = 0
    else
      @contents_x = 112
    end
    @contents_y += WLH
    @line_count += 1
    @line_show_fast = false
  end
  #--------------------------------------------------------------------------
  # * Convert Special Characters
  #--------------------------------------------------------------------------
  def convert_special_characters
    @text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    @text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    @text.gsub!(/\\N\[([0-9]+)\]/i) { $game_actors[$1.to_i].name }
    @text.gsub!(/\\C\[([0-9]+)\]/i) { "\x01[#{$1}]" }
    @text.gsub!(/\\G/)              { "\x02" }
    @text.gsub!(/\\\./)             { "\x03" }
    @text.gsub!(/\\\|/)             { "\x04" }
    @text.gsub!(/\\!/)              { "\x05" }
    @text.gsub!(/\\>/)              { "\x06" }
    @text.gsub!(/\\</)              { "\x07" }
    @text.gsub!(/\\\^/)             { "\x08" }
    @text.gsub!(/\\\\/)             { "\\" }
  end
  #--------------------------------------------------------------------------
  # * Set Window Background and Position
  #--------------------------------------------------------------------------
  def reset_window
    @background = $game_message.background
    @position = $game_message.position
    if @background == 0   # Normal window
      self.opacity = 255
    else                  # Dim Background and Make it Transparent
      self.opacity = 0
    end
    case @position
    when 0  # Top
      self.y = 0
      @gold_window.y = 360
    when 1  # Middle
      self.y = 144
      @gold_window.y = 0
    when 2  # Bottom
      self.y = 288
      @gold_window.y = 0
    end
  end
  #--------------------------------------------------------------------------
  # * End Message
  #--------------------------------------------------------------------------
  def terminate_message
    self.active = false
    self.pause = false
    self.index = -1
    @gold_window.close
    @number_input_window.active = false
    @number_input_window.visible = false
    $game_message.main_proc.call if $game_message.main_proc != nil
    $game_message.clear
  end
  #--------------------------------------------------------------------------
  # * Update Message
  #--------------------------------------------------------------------------
  def update_message
    loop do
      c = @text.slice!(/./m)            # Get next text character
      case c
      when nil                          # There is no text that must be drawn
        finish_message                  # Finish update
        break
      when "\x00"                       # New line
        new_line
        if @line_count >= MAX_LINE      # If line count is maximum
          unless @text.empty?           # If there is more
            self.pause = true           # Insert number input
            break
          end
        end
      when "\x01"                       # \C[n]  (text character color change)
        @text.sub!(/\[([0-9]+)\]/, "")
        contents.font.color = text_color($1.to_i)
        next
      when "\x02"                       # \G  (gold display)
        @gold_window.refresh
        @gold_window.open
      when "\x03"                       # \.  (wait 1/4 second)
        @wait_count = 15
        break
      when "\x04"                       # \|  (wait 1 second)
        @wait_count = 60
        break
      when "\x05"                       # \!  (Wait for input)
        self.pause = true
        break
      when "\x06"                       # \>  (Fast display ON)
        @line_show_fast = true
      when "\x07"                       # \<  (Fast display OFF)
        @line_show_fast = false
      when "\x08"                       # \^  (No wait for input)
        @pause_skip = true
      else                              # Normal text character
        contents.draw_text(@contents_x, @contents_y, 40, WLH, c)
        c_width = contents.text_size(c).width
        @contents_x += c_width
      end
      break unless @show_fast or @line_show_fast
    end
  end
  #--------------------------------------------------------------------------
  # * End Message Update
  #--------------------------------------------------------------------------
  def finish_message
    if $game_message.choice_max > 0
      start_choice
    elsif $game_message.num_input_variable_id > 0
      start_number_input
    elsif @pause_skip
      terminate_message
    else
      self.pause = true
    end
    @wait_count = 10
    @text = nil
  end
  #--------------------------------------------------------------------------
  # * Start Choices
  #--------------------------------------------------------------------------
  def start_choice
    self.active = true
    self.index = 0
  end
  #--------------------------------------------------------------------------
  # * Start Number Input
  #--------------------------------------------------------------------------
  def start_number_input
    digits_max = $game_message.num_input_digits_max
    number = $game_variables[$game_message.num_input_variable_id]
    @number_input_window.digits_max = digits_max
    @number_input_window.number = number
    if $game_message.face_name.empty?
      @number_input_window.x = x
    else
      @number_input_window.x = x + 112
    end
    @number_input_window.y = y + @contents_y
    @number_input_window.active = true
    @number_input_window.visible = true
    @number_input_window.update
  end
  #--------------------------------------------------------------------------
  # * Update cursor
  #--------------------------------------------------------------------------
  def update_cursor
    if @index >= 0
      x = $game_message.face_name.empty? ? 0 : 112
      y = ($game_message.choice_start + @index) * WLH
      self.cursor_rect.set(x, y, contents.width - x, WLH)
    else
      self.cursor_rect.empty
    end
  end
  #--------------------------------------------------------------------------
  # * Text Advancement Input
  #--------------------------------------------------------------------------
  def input_pause
    if Input.trigger?(Input::B) or Input.trigger?(Input::C)
      self.pause = false
      if @text != nil and not @text.empty?
        new_page if @line_count >= MAX_LINE
      else
        terminate_message
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Choice Input
  #--------------------------------------------------------------------------
  def input_choice
    if Input.trigger?(Input::B)
      if $game_message.choice_cancel_type > 0
        Sound.play_cancel
        $game_message.choice_proc.call($game_message.choice_cancel_type - 1)
        terminate_message
      end
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      $game_message.choice_proc.call(self.index)
      terminate_message
    end
  end
  #--------------------------------------------------------------------------
  # * Number Input Processing
  #--------------------------------------------------------------------------
  def input_number
    if Input.trigger?(Input::C)
      Sound.play_decision
      $game_variables[$game_message.num_input_variable_id] =
        @number_input_window.number
      $game_map.need_refresh = true
      terminate_message
    end
  end
end
