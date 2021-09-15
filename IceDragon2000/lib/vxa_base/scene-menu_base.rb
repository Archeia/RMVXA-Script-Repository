#encoding:UTF-8
# Scene_MenuBase
#==============================================================================
# ** Scene_MenuBase
#------------------------------------------------------------------------------
#  This class performs basic processing related to the menu screen.
#==============================================================================

class Scene_MenuBase < Scene_Base
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    create_background
    @actor = $game_party.menu_actor
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_background
  end
  #--------------------------------------------------------------------------
  # * Create Background
  #--------------------------------------------------------------------------
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.background_bitmap
    @background_sprite.color.set(16, 16, 16, 128)
  end
  #--------------------------------------------------------------------------
  # * Free Background
  #--------------------------------------------------------------------------
  def dispose_background
    @background_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Create Help Window
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new
    @help_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # * Switch to Next Actor
  #--------------------------------------------------------------------------
  def next_actor
    @actor = $game_party.menu_actor_next
    on_actor_change
  end
  #--------------------------------------------------------------------------
  # * Switch to Previous Actor
  #--------------------------------------------------------------------------
  def prev_actor
    @actor = $game_party.menu_actor_prev
    on_actor_change
  end
  #--------------------------------------------------------------------------
  # * Change Actors
  #--------------------------------------------------------------------------
  def on_actor_change
  end
end
