#encoding:UTF-8
# Window_NumberInput
#==============================================================================
# ** Window_NumberInput
#------------------------------------------------------------------------------
#  This window is for inputting numbers, and is used within the message
# window.
#==============================================================================

class Window_NumberInput < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     digits_max : digit count
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, 544, 64)
    @number = 0
    @digits_max = 6
    @index = 0
    self.opacity = 0
    self.active = false
    self.z += 9999
    refresh
    update_cursor
  end
  #--------------------------------------------------------------------------
  # * Get Number
  #--------------------------------------------------------------------------
  def number
    return @number
  end
  #--------------------------------------------------------------------------
  # * Set Number
  #     number : new number
  #--------------------------------------------------------------------------
  def number=(number)
    @number = [[number, 0].max, 10 ** @digits_max - 1].min
    @index = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Digit Count
  #--------------------------------------------------------------------------
  def digits_max
    return @digits_max
  end
  #--------------------------------------------------------------------------
  # * Set Digit Count
  #     digits_max : New digit count
  #--------------------------------------------------------------------------
  def digits_max=(digits_max)
    @digits_max = digits_max
    refresh
  end
  #--------------------------------------------------------------------------
  # * Move cursor right
  #     wrap : Wraparound allowed
  #--------------------------------------------------------------------------
  def cursor_right(wrap)
    if @index < @digits_max - 1 or wrap
      @index = (@index + 1) % @digits_max
    end
  end
  #--------------------------------------------------------------------------
  # * Move cursor left
  #     wrap : Wraparound allowed
  #--------------------------------------------------------------------------
  def cursor_left(wrap)
    if @index > 0 or wrap
      @index = (@index + @digits_max - 1) % @digits_max
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if self.active
      if Input.repeat?(Input::UP) or Input.repeat?(Input::DOWN)
        Sound.play_cursor
        place = 10 ** (@digits_max - 1 - @index)
        n = @number / place % 10
        @number -= n * place
        n = (n + 1) % 10 if Input.repeat?(Input::UP)
        n = (n + 9) % 10 if Input.repeat?(Input::DOWN)
        @number += n * place
        refresh
      end
      last_index = @index
      if Input.repeat?(Input::RIGHT)
        cursor_right(Input.trigger?(Input::RIGHT))
      end
      if Input.repeat?(Input::LEFT)
        cursor_left(Input.trigger?(Input::LEFT))
      end
      if @index != last_index
        Sound.play_cursor
      end
      update_cursor
    end
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = normal_color
    s = sprintf("%0*d", @digits_max, @number)
    for i in 0...@digits_max
      self.contents.draw_text(24 + i * 16, 0, 16, WLH, s[i,1], 1)
    end
  end
  #--------------------------------------------------------------------------
  # * Update cursor
  #--------------------------------------------------------------------------
  def update_cursor
    self.cursor_rect.set(24 + @index * 16, 0, 16, WLH)
  end
end
