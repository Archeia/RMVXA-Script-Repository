#encoding:UTF-8
# Scene_End
#==============================================================================
# ** Scene_End
#------------------------------------------------------------------------------
#  This class performs game end screen processing.
#==============================================================================

class Scene_End < Scene_Base
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    create_command_window
  end
  #--------------------------------------------------------------------------
  # * Post-Start Processing
  #--------------------------------------------------------------------------
  def post_start
    super
    open_command_window
  end
  #--------------------------------------------------------------------------
  # * Pre-termination Processing
  #--------------------------------------------------------------------------
  def pre_terminate
    super
    close_command_window
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_command_window
    dispose_menu_background
  end
  #--------------------------------------------------------------------------
  # * Return to Original Screen
  #--------------------------------------------------------------------------
  def return_scene
    $scene = Scene_Menu.new(5)
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @command_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::C)
      case @command_window.index
      when 0  # to title
        command_to_title
      when 1  # shutdown
        command_shutdown
      when 2  # quit
        command_cancel
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Update Background for Menu Screen
  #--------------------------------------------------------------------------
  def update_menu_background
    super
    @menuback_sprite.tone.set(0, 0, 0, 128)
  end
  #--------------------------------------------------------------------------
  # * Create Command Window
  #--------------------------------------------------------------------------
  def create_command_window
    s1 = Vocab::to_title
    s2 = Vocab::shutdown
    s3 = Vocab::cancel
    @command_window = Window_Command.new(172, [s1, s2, s3])
    @command_window.x = (544 - @command_window.width) / 2
    @command_window.y = (416 - @command_window.height) / 2
    @command_window.openness = 0
  end
  #--------------------------------------------------------------------------
  # * Dispose of Command Window
  #--------------------------------------------------------------------------
  def dispose_command_window
    @command_window.dispose
  end
  #--------------------------------------------------------------------------
  # * Open Command Window
  #--------------------------------------------------------------------------
  def open_command_window
    @command_window.open
    begin
      @command_window.update
      Graphics.update
    end until @command_window.openness == 255
  end
  #--------------------------------------------------------------------------
  # * Close Command Window
  #--------------------------------------------------------------------------
  def close_command_window
    @command_window.close
    begin
      @command_window.update
      Graphics.update
    end until @command_window.openness == 0
  end
  #--------------------------------------------------------------------------
  # * Process When Choosing [To Title] Command
  #--------------------------------------------------------------------------
  def command_to_title
    Sound.play_decision
    RPG::BGM.fade(800)
    RPG::BGS.fade(800)
    RPG::ME.fade(800)
    $scene = Scene_Title.new
    close_command_window
    Graphics.fadeout(60)
  end
  #--------------------------------------------------------------------------
  # * Process When Choosing [Shutdown] Command
  #--------------------------------------------------------------------------
  def command_shutdown
    Sound.play_decision
    RPG::BGM.fade(800)
    RPG::BGS.fade(800)
    RPG::ME.fade(800)
    $scene = nil
  end
  #--------------------------------------------------------------------------
  # *  Process When Choosing [Cancel] Command
  #--------------------------------------------------------------------------
  def command_cancel
    Sound.play_decision
    return_scene
  end
end
