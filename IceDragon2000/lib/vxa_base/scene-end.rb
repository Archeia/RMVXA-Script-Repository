#encoding:UTF-8
# Scene_End
#==============================================================================
# ** Scene_End
#------------------------------------------------------------------------------
#  This class performs game over screen processing.
#==============================================================================

class Scene_End < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    create_command_window
  end
  #--------------------------------------------------------------------------
  # * Pre-Termination Processing
  #--------------------------------------------------------------------------
  def pre_terminate
    super
    close_command_window
  end
  #--------------------------------------------------------------------------
  # * Create Background
  #--------------------------------------------------------------------------
  def create_background
    super
    @background_sprite.tone.set(0, 0, 0, 128)
  end
  #--------------------------------------------------------------------------
  # * Create Command Window
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_GameEnd.new
    @command_window.set_handler(:to_title, method(:command_to_title))
    @command_window.set_handler(:shutdown, method(:command_shutdown))
    @command_window.set_handler(:cancel,   method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # * Close Command Window
  #--------------------------------------------------------------------------
  def close_command_window
    @command_window.close
    update until @command_window.close?
  end
  #--------------------------------------------------------------------------
  # * [Go to Title] Command
  #--------------------------------------------------------------------------
  def command_to_title
    close_command_window
    fadeout_all
    SceneManager.goto(Scene_Title)
  end
  #--------------------------------------------------------------------------
  # * [Shut Down] Command
  #--------------------------------------------------------------------------
  def command_shutdown
    close_command_window
    fadeout_all
    SceneManager.exit
  end
end
