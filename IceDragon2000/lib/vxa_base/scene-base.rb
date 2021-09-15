#encoding:UTF-8
# Scene_Base
#==============================================================================
# ** Scene_Base
#------------------------------------------------------------------------------
#  This is a super class of all scenes within the game.
#==============================================================================

class Scene_Base
  #--------------------------------------------------------------------------
  # * Main
  #--------------------------------------------------------------------------
  def main
    start
    post_start
    update until scene_changing?
    pre_terminate
    terminate
  end
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    create_main_viewport
  end
  #--------------------------------------------------------------------------
  # * Post-Start Processing
  #--------------------------------------------------------------------------
  def post_start
    perform_transition
    Input.update
  end
  #--------------------------------------------------------------------------
  # * Determine if Scene Is Changing
  #--------------------------------------------------------------------------
  def scene_changing?
    SceneManager.scene != self
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    update_basic
  end
  #--------------------------------------------------------------------------
  # * Update Frame (Basic)
  #--------------------------------------------------------------------------
  def update_basic
    Graphics.update
    Input.update
    update_all_windows
  end
  #--------------------------------------------------------------------------
  # * Pre-Termination Processing
  #--------------------------------------------------------------------------
  def pre_terminate
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    Graphics.freeze
    dispose_all_windows
    dispose_main_viewport
  end
  #--------------------------------------------------------------------------
  # * Execute Transition
  #--------------------------------------------------------------------------
  def perform_transition
    Graphics.transition(transition_speed)
  end
  #--------------------------------------------------------------------------
  # * Get Transition Speed
  #--------------------------------------------------------------------------
  def transition_speed
    return 10
  end
  #--------------------------------------------------------------------------
  # * Create Viewport
  #--------------------------------------------------------------------------
  def create_main_viewport
    @viewport = Viewport.new
    @viewport.z = 200
  end
  #--------------------------------------------------------------------------
  # * Free Viewport
  #--------------------------------------------------------------------------
  def dispose_main_viewport
    @viewport.dispose
  end
  #--------------------------------------------------------------------------
  # * Update All Windows
  #--------------------------------------------------------------------------
  def update_all_windows
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      ivar.update if ivar.is_a?(Window)
    end
  end
  #--------------------------------------------------------------------------
  # * Free All Windows
  #--------------------------------------------------------------------------
  def dispose_all_windows
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      ivar.dispose if ivar.is_a?(Window)
    end
  end
  #--------------------------------------------------------------------------
  # * Return to Calling Scene
  #--------------------------------------------------------------------------
  def return_scene
    SceneManager.return
  end
  #--------------------------------------------------------------------------
  # * Fade Out All Sounds and Graphics
  #--------------------------------------------------------------------------
  def fadeout_all(time = 1000)
    RPG::BGM.fade(time)
    RPG::BGS.fade(time)
    RPG::ME.fade(time)
    Graphics.fadeout(time * Graphics.frame_rate / 1000)
    RPG::BGM.stop
    RPG::BGS.stop
    RPG::ME.stop
  end
  #--------------------------------------------------------------------------
  # * Determine if Game Is Over
  #   Transition to the game over screen if the entire party is dead.
  #--------------------------------------------------------------------------
  def check_gameover
    SceneManager.goto(Scene_Gameover) if $game_party.all_dead?
  end
end
