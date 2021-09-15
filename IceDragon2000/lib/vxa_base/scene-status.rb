#encoding:UTF-8
# Scene_Status
#==============================================================================
# ** Scene_Status
#------------------------------------------------------------------------------
#  This class performs the status screen processing.
#==============================================================================

class Scene_Status < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    @status_window = Window_Status.new(@actor)
    @status_window.set_handler(:cancel,   method(:return_scene))
    @status_window.set_handler(:pagedown, method(:next_actor))
    @status_window.set_handler(:pageup,   method(:prev_actor))
  end
  #--------------------------------------------------------------------------
  # * Change Actors
  #--------------------------------------------------------------------------
  def on_actor_change
    @status_window.actor = @actor
    @status_window.activate
  end
end
