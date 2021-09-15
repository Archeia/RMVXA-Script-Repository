#encoding:UTF-8
# Scene_Debug
#==============================================================================
# ** Scene_Debug
#------------------------------------------------------------------------------
#  This class performs debug screen processing.
#==============================================================================

class Scene_Debug < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    create_left_window
    create_right_window
    create_debug_help_window
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    #$game_map.refresh
  end
  #--------------------------------------------------------------------------
  # * Create Left Window
  #--------------------------------------------------------------------------
  def create_left_window
    @left_window = Window_DebugLeft.new(0, 0)
    @left_window.set_handler(:ok,     method(:on_left_ok))
    @left_window.set_handler(:cancel, method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # * Create Right Window
  #--------------------------------------------------------------------------
  def create_right_window
    wx = @left_window.width
    ww = Graphics.width - wx
    @right_window = Window_DebugRight.new(wx, 0, ww)
    @right_window.set_handler(:cancel, method(:on_right_cancel))
    @left_window.right_window = @right_window
  end
  #--------------------------------------------------------------------------
  # * Create Help Window
  #--------------------------------------------------------------------------
  def create_debug_help_window
    wx = @right_window.x
    wy = @right_window.height
    ww = @right_window.width
    wh = Graphics.height - wy
    @debug_help_window = Window_Base.new(wx, wy, ww, wh)
  end
  #--------------------------------------------------------------------------
  # * Left [OK]
  #--------------------------------------------------------------------------
  def on_left_ok
    refresh_help_window
    @right_window.activate
    @right_window.select(0)
  end
  #--------------------------------------------------------------------------
  # * Right [Cancel]
  #--------------------------------------------------------------------------
  def on_right_cancel
    @left_window.activate
    @right_window.unselect
    @debug_help_window.contents.clear
  end
  #--------------------------------------------------------------------------
  # * Refresh Help Window
  #--------------------------------------------------------------------------
  def refresh_help_window
    @debug_help_window.draw_text_ex(4, 0, help_text)
  end
  #--------------------------------------------------------------------------
  # * Get Help Text
  #--------------------------------------------------------------------------
  def help_text
    if @left_window.mode == :switch
      "C (Enter) : ON / OFF"
    else
      "← (Left)    :  -1\n" +
      "→ (Right)   :  +1\n" +
      "L (Pageup)   : -10\n" +
      "R (Pagedown) : +10"
    end
  end
end
