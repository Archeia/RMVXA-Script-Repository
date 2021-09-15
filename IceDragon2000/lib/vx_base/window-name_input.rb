#encoding:UTF-8
# Window_NameInput
#==============================================================================
# ** Window_NameInput
#------------------------------------------------------------------------------
#  This window is used to select text characters on the name input screen.
#==============================================================================

class Window_NameInput < Window_Base
  #--------------------------------------------------------------------------
  # * Text Character Table
  #--------------------------------------------------------------------------
  ENGLISH = [ 'A','B','C','D','E',  'a','b','c','d','e',
              'F','G','H','I','J',  'f','g','h','i','j',
              'K','L','M','N','O',  'k','l','m','n','o',
              'P','Q','R','S','T',  'p','q','r','s','t',
              'U','V','W','X','Y',  'u','v','w','x','y',
              'Z',' ',' ',' ',' ',  'z',' ',' ',' ',' ',
              ' ',' ',' ',' ',' ',  ' ',' ',' ',' ',' ',
              '1','2','3','4','5',  ' ',' ',' ',' ',' ',
              '6','7','8','9','0',  ' ',' ',' ',' ','OK']
  TABLE = [ENGLISH]
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     mode : Defeault input mode (always 0 in English version)
  #--------------------------------------------------------------------------
  def initialize(mode = 0)
    super(88, 148, 368, 248)
    @mode = mode
    @index = 0
    refresh
    update_cursor
  end
  #--------------------------------------------------------------------------
  # * Text Character Acquisition
  #--------------------------------------------------------------------------
  def character
    if @index < 88
      return TABLE[@mode][@index]
    else
      return ""
    end
  end
  #--------------------------------------------------------------------------
  # * Determine Cursor Position: Mode Switch
  #--------------------------------------------------------------------------
  def is_mode_change
    return (@index == 88)
  end
  #--------------------------------------------------------------------------
  # * Determine Cursor Location: Confirmation
  #--------------------------------------------------------------------------
  def is_decision
    return (@index == 89)
  end
  #--------------------------------------------------------------------------
  # * Get rectangle for displaying items
  #     index : item number
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.x = index % 10 * 32 + index % 10 / 5 * 16
    rect.y = index / 10 * WLH
    rect.width = 32
    rect.height = WLH
    return rect
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    for i in 0..89
      rect = item_rect(i)
      rect.x += 2
      rect.width -= 4
      self.contents.draw_text(rect, TABLE[@mode][i], 1)
    end
  end
  #--------------------------------------------------------------------------
  # * Update cursor
  #--------------------------------------------------------------------------
  def update_cursor
    self.cursor_rect = item_rect(@index)
  end
  #--------------------------------------------------------------------------
  # * Move cursor down
  #     wrap : Wraparound allowed
  #--------------------------------------------------------------------------
  def cursor_down(wrap)
    if @index < 80
      @index += 10
    elsif wrap
      @index -= 80
    end
  end
  #--------------------------------------------------------------------------
  # * Move cursor up
  #     wrap : Wraparound allowed
  #--------------------------------------------------------------------------
  def cursor_up(wrap)
    if @index >= 10
      @index -= 10
    elsif wrap
      @index += 80
    end
  end
  #--------------------------------------------------------------------------
  # * Move cursor right
  #     wrap : Wraparound allowed
  #--------------------------------------------------------------------------
  def cursor_right(wrap)
    if @index % 10 < 9
      @index += 1
    elsif wrap
      @index -= 9
    end
  end
  #--------------------------------------------------------------------------
  # * Move cursor left
  #     wrap : Wraparound allowed
  #--------------------------------------------------------------------------
  def cursor_left(wrap)
    if @index % 10 > 0
      @index -= 1
    elsif wrap
      @index += 9
    end
  end
  #--------------------------------------------------------------------------
  # * Move Cursor to [OK]
  #--------------------------------------------------------------------------
  def cursor_to_decision
    @index = 89
  end
  #--------------------------------------------------------------------------
  # * Move to Next Page
  #--------------------------------------------------------------------------
  def cursor_pagedown
    @mode = (@mode + 1) % TABLE.size
    refresh
  end
  #--------------------------------------------------------------------------
  # * Move to Previous Page
  #--------------------------------------------------------------------------
  def cursor_pageup
    @mode = (@mode + TABLE.size - 1) % TABLE.size
    refresh
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    last_mode = @mode
    last_index = @index
    if Input.repeat?(Input::DOWN)
      cursor_down(Input.trigger?(Input::DOWN))
    end
    if Input.repeat?(Input::UP)
      cursor_up(Input.trigger?(Input::UP))
    end
    if Input.repeat?(Input::RIGHT)
      cursor_right(Input.trigger?(Input::RIGHT))
    end
    if Input.repeat?(Input::LEFT)
      cursor_left(Input.trigger?(Input::LEFT))
    end
    if Input.trigger?(Input::A)
      cursor_to_decision
    end
    if Input.trigger?(Input::R)
      cursor_pagedown
    end
    if Input.trigger?(Input::L)
      cursor_pageup
    end
    if Input.trigger?(Input::C) and is_mode_change
      cursor_pagedown
    end
    if @index != last_index or @mode != last_mode
      Sound.play_cursor
    end
    update_cursor
  end
end
