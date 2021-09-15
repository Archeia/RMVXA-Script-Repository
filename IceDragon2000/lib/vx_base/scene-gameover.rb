#encoding:UTF-8
# Scene_Gameover
#==============================================================================
# ** Scene_Gameover
#------------------------------------------------------------------------------
#  This class performs game over screen processing.
#==============================================================================

class Scene_Gameover < Scene_Base
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  def start
    super
    RPG::BGM.stop
    RPG::BGS.stop
    $data_system.gameover_me.play
    Graphics.transition(120)
    Graphics.freeze
    create_gameover_graphic
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_gameover_graphic
    $scene = nil if $BTEST
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if Input.trigger?(Input::C)
      $scene = Scene_Title.new
      Graphics.fadeout(120)
    end
  end
  #--------------------------------------------------------------------------
  # * Execute Transition
  #--------------------------------------------------------------------------
  def perform_transition
    Graphics.transition(180)
  end
  #--------------------------------------------------------------------------
  # * Create Game Over Graphic
  #--------------------------------------------------------------------------
  def create_gameover_graphic
    @sprite = Sprite.new
    @sprite.bitmap = Cache.system("GameOver")
  end
  #--------------------------------------------------------------------------
  # * Dispose of Game Over Graphic
  #--------------------------------------------------------------------------
  def dispose_gameover_graphic
    @sprite.bitmap.dispose
    @sprite.dispose
  end
end
