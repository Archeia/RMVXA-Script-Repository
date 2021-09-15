#encoding:UTF-8
# Scene_Status
#==============================================================================
# ** Scene_Status
#------------------------------------------------------------------------------
#  This class performs the status screen processing.
#==============================================================================

class Scene_Status < Scene_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     actor_index : actor index
  #--------------------------------------------------------------------------
  def initialize(actor_index = 0)
    @actor_index = actor_index
  end
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @actor = $game_party.members[@actor_index]
    @status_window = Window_Status.new(@actor)
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @status_window.dispose
  end
  #--------------------------------------------------------------------------
  # * Return to Original Screen
  #--------------------------------------------------------------------------
  def return_scene
    $scene = Scene_Menu.new(3)
  end
  #--------------------------------------------------------------------------
  # * Switch to Next Actor Screen
  #--------------------------------------------------------------------------
  def next_actor
    @actor_index += 1
    @actor_index %= $game_party.members.size
    $scene = Scene_Status.new(@actor_index)
  end
  #--------------------------------------------------------------------------
  # * Switch to Previous Actor Screen
  #--------------------------------------------------------------------------
  def prev_actor
    @actor_index += $game_party.members.size - 1
    @actor_index %= $game_party.members.size
    $scene = Scene_Status.new(@actor_index)
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    update_menu_background
    @status_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::R)
      Sound.play_cursor
      next_actor
    elsif Input.trigger?(Input::L)
      Sound.play_cursor
      prev_actor
    end
    super
  end
end
