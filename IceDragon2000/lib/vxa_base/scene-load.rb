#encoding:UTF-8
# Scene_Load
#==============================================================================
# ** Scene_Load
#------------------------------------------------------------------------------
#  This class performs load screen processing. 
#==============================================================================

class Scene_Load < Scene_File
  #--------------------------------------------------------------------------
  # * Get Help Window Text
  #--------------------------------------------------------------------------
  def help_window_text
    Vocab::LoadMessage
  end
  #--------------------------------------------------------------------------
  # * Get File Index to Select First
  #--------------------------------------------------------------------------
  def first_savefile_index
    DataManager.latest_savefile_index
  end
  #--------------------------------------------------------------------------
  # * Confirm Save File
  #--------------------------------------------------------------------------
  def on_savefile_ok
    super
    if DataManager.load_game(@index)
      on_load_success
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # * Processing When Load Is Successful
  #--------------------------------------------------------------------------
  def on_load_success
    Sound.play_load
    fadeout_all
    $game_system.on_after_load
    SceneManager.goto(Scene_Map)
  end
end
