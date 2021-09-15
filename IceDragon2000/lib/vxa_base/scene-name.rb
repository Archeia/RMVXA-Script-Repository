#encoding:UTF-8
# Scene_Name
#==============================================================================
# ** Scene_Name
#------------------------------------------------------------------------------
#  This class performs name input screen processing.
#==============================================================================

class Scene_Name < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Prepare
  #--------------------------------------------------------------------------
  def prepare(actor_id, max_char)
    @actor_id = actor_id
    @max_char = max_char
  end
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    @actor = $game_actors[@actor_id]
    @edit_window = Window_NameEdit.new(@actor, @max_char)
    @input_window = Window_NameInput.new(@edit_window)
    @input_window.set_handler(:ok, method(:on_input_ok))
  end
  #--------------------------------------------------------------------------
  # * Input [OK]
  #--------------------------------------------------------------------------
  def on_input_ok
    @actor.name = @edit_window.name
    return_scene
  end
end
