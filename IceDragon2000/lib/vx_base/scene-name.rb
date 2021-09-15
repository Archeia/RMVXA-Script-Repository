#encoding:UTF-8
# Scene_Name
#==============================================================================
# ** Scene_Name
#------------------------------------------------------------------------------
#  This class performs name input screen processing.
#==============================================================================

class Scene_Name < Scene_Base
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @actor = $game_actors[$game_temp.name_actor_id]
    @edit_window = Window_NameEdit.new(@actor, $game_temp.name_max_char)
    @input_window = Window_NameInput.new
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @edit_window.dispose
    @input_window.dispose
  end
  #--------------------------------------------------------------------------
  # * Return to Original Screen
  #--------------------------------------------------------------------------
  def return_scene
    $scene = Scene_Map.new
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @edit_window.update
    @input_window.update
    if Input.repeat?(Input::B)
      if @edit_window.index > 0             # Not at the left edge
        Sound.play_cancel
        @edit_window.back
      end
    elsif Input.trigger?(Input::C)
      if @input_window.is_decision          # If cursor is positioned on [OK]
        if @edit_window.name == ""          # If name is empty
          @edit_window.restore_default      # Return to default name
          if @edit_window.name == ""
            Sound.play_buzzer
          else
            Sound.play_decision
          end
        else
          Sound.play_decision
          @actor.name = @edit_window.name   # Change actor name
          return_scene
        end
      elsif @input_window.character != ""   # If text characters are not empty
        if @edit_window.index == @edit_window.max_char    # at the right edge
          Sound.play_buzzer
        else
          Sound.play_decision
          @edit_window.add(@input_window.character)       # Add text character
        end
      end
    end
  end
end
