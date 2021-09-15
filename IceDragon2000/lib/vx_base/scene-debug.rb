#encoding:UTF-8
# Scene_Debug
#==============================================================================
# ** Scene_Debug
#------------------------------------------------------------------------------
#  This class performs debug screen processing.
#==============================================================================

class Scene_Debug < Scene_Base
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @left_window = Window_DebugLeft.new(0, 0)
    @right_window = Window_DebugRight.new(176, 0)
    @help_window = Window_Base.new(176, 272, 368, 144)
    @left_window.top_row = $game_temp.debug_top_row
    @left_window.index = $game_temp.debug_index
    @right_window.mode = @left_window.mode
    @right_window.top_id = @left_window.top_id
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    $game_map.refresh
    @left_window.dispose
    @right_window.dispose
    @help_window.dispose
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @right_window.mode = @left_window.mode
    @right_window.top_id = @left_window.top_id
    @left_window.update
    @right_window.update
    $game_temp.debug_top_row = @left_window.top_row
    $game_temp.debug_index = @left_window.index
    if @left_window.active
      update_left_input
    elsif @right_window.active
      update_right_input
    end
  end
  #--------------------------------------------------------------------------
  # * Update Left Window Input
  #--------------------------------------------------------------------------
  def update_left_input
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = Scene_Map.new
      return
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      wlh = 24
      if @left_window.mode == 0
        text1 = "C (Enter) : ON / OFF"
        @help_window.contents.draw_text(4, 0, 336, wlh, text1)
      else
        text1 = "< (Left)    :  -1"
        text2 = "> (Right)   :  +1"
        text3 = "L (Pageup)   : -10"
        text4 = "R (Pagedown) : +10"
        @help_window.contents.draw_text(4, wlh * 0, 336, wlh, text1)
        @help_window.contents.draw_text(4, wlh * 1, 336, wlh, text2)
        @help_window.contents.draw_text(4, wlh * 2, 336, wlh, text3)
        @help_window.contents.draw_text(4, wlh * 3, 336, wlh, text4)
      end
      @left_window.active = false
      @right_window.active = true
      @right_window.index = 0
    end
  end
  #--------------------------------------------------------------------------
  # * Update Right Window Input
  #--------------------------------------------------------------------------
  def update_right_input
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @left_window.active = true
      @right_window.active = false
      @right_window.index = -1
      @help_window.contents.clear
    else
      current_id = @right_window.top_id + @right_window.index
      if @right_window.mode == 0
        if Input.trigger?(Input::C)
          Sound.play_decision
          $game_switches[current_id] = (not $game_switches[current_id])
          @right_window.refresh
        end
      elsif @right_window.mode == 1
        last_value = $game_variables[current_id]
        if Input.repeat?(Input::RIGHT)
          $game_variables[current_id] += 1
        elsif Input.repeat?(Input::LEFT)
          $game_variables[current_id] -= 1
        elsif Input.repeat?(Input::R)
          $game_variables[current_id] += 10
        elsif Input.repeat?(Input::L)
          $game_variables[current_id] -= 10
        end
        if $game_variables[current_id] > 99999999
          $game_variables[current_id] = 99999999
        elsif $game_variables[current_id] < -99999999
          $game_variables[current_id] = -99999999
        end
        if $game_variables[current_id] != last_value
          Sound.play_cursor
          @right_window.draw_item(@right_window.index)
        end
      end
    end
  end
end
