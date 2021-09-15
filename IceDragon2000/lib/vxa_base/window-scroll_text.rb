#encoding:UTF-8
# Window_ScrollText
#==============================================================================
# ** Window_ScrollText
#------------------------------------------------------------------------------
#  This window is for displaying scrolling text. No frame is displayed, but it
# is handled as a window for convenience.
#==============================================================================

class Window_ScrollText < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, Graphics.width, Graphics.height)
    self.opacity = 0
    self.arrows_visible = false
    hide
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if $game_message.scroll_mode
      update_message if @text
      start_message if !@text && $game_message.has_text?
    end
  end
  #--------------------------------------------------------------------------
  # * Start Message
  #--------------------------------------------------------------------------
  def start_message
    @text = $game_message.all_text
    refresh
    show
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    reset_font_settings
    update_all_text_height
    create_contents
    draw_text_ex(4, 0, @text)
    self.oy = @scroll_pos = -height
  end
  #--------------------------------------------------------------------------
  # * Update Height Needed to Draw All Text
  #--------------------------------------------------------------------------
  def update_all_text_height
    @all_text_height = 1
    convert_escape_characters(@text).each_line do |line|
      @all_text_height += calc_line_height(line, false)
    end
    reset_font_settings
  end
  #--------------------------------------------------------------------------
  # * Calculate Height of Window Contents
  #--------------------------------------------------------------------------
  def contents_height
    @all_text_height ? @all_text_height : super
  end
  #--------------------------------------------------------------------------
  # * Update Message
  #--------------------------------------------------------------------------
  def update_message
    @scroll_pos += scroll_speed
    self.oy = @scroll_pos
    terminate_message if @scroll_pos >= contents.height
  end
  #--------------------------------------------------------------------------
  # * Get Scroll Speed
  #--------------------------------------------------------------------------
  def scroll_speed
    $game_message.scroll_speed * (show_fast? ? 1.0 : 0.5)
  end
  #--------------------------------------------------------------------------
  # * Determine if Fast Forward
  #--------------------------------------------------------------------------
  def show_fast?
    !$game_message.scroll_no_fast && (Input.press?(:A) || Input.press?(:C))
  end
  #--------------------------------------------------------------------------
  # * End Message
  #--------------------------------------------------------------------------
  def terminate_message
    @text = nil
    $game_message.clear
    hide
  end
end
