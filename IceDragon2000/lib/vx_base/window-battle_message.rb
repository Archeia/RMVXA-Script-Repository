#encoding:UTF-8
# Window_BattleMessage
#==============================================================================
# ** Window_BattleMessage
#------------------------------------------------------------------------------
#  Message window displayed during battle. In addition to the normal message
# window functions, it also has a battle progress narration function.
#==============================================================================

class Window_BattleMessage < Window_Message
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super
    self.openness = 255
    @lines = []
    refresh
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    super
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
  end
  #--------------------------------------------------------------------------
  # * Open Window (disabled)
  #--------------------------------------------------------------------------
  def open
  end
  #--------------------------------------------------------------------------
  # * Close Window (disabled)
  #--------------------------------------------------------------------------
  def close
  end
  #--------------------------------------------------------------------------
  # * Set Window Background and Position (disabled)
  #--------------------------------------------------------------------------
  def reset_window
  end
  #--------------------------------------------------------------------------
  # * Clear
  #--------------------------------------------------------------------------
  def clear
    @lines.clear
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Row Count
  #--------------------------------------------------------------------------
  def line_number
    return @lines.size
  end
  #--------------------------------------------------------------------------
  # * Go Back One Line
  #--------------------------------------------------------------------------
  def back_one
    @lines.pop
    refresh
  end
  #--------------------------------------------------------------------------
  # * Return to Designated Line
  #     line_number : Line number
  #--------------------------------------------------------------------------
  def back_to(line_number)
    while @lines.size > line_number
      @lines.pop
    end
    refresh
  end
  #--------------------------------------------------------------------------
  # * Add Text
  #     text : Text to be added
  #--------------------------------------------------------------------------
  def add_instant_text(text)
    @lines.push(text)
    refresh
  end
  #--------------------------------------------------------------------------
  # * Replace Text
  #     text : Text to be replaced
  #    Replaces the last line with different text.
  #--------------------------------------------------------------------------
  def replace_instant_text(text)
    @lines.pop
    @lines.push(text)
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Text From Last Line
  #--------------------------------------------------------------------------
  def last_instant_text
    return @lines[-1]
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    for i in 0...@lines.size
      draw_line(i)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Line
  #     index : Line number
  #--------------------------------------------------------------------------
  def draw_line(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.x += 4
    rect.y += index * WLH
    rect.width = contents.width - 8
    rect.height = WLH
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    self.contents.draw_text(rect, @lines[index])
  end
end
