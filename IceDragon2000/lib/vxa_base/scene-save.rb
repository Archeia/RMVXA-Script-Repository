#encoding:UTF-8
# Scene_Save
#==============================================================================
# ** Scene_Save
#------------------------------------------------------------------------------
#  This class performs save screen processing. 
#==============================================================================

class Scene_Save < Scene_File
  #--------------------------------------------------------------------------
  # * Get Help Window Text
  #--------------------------------------------------------------------------
  def help_window_text
    Vocab::SaveMessage
  end
  #--------------------------------------------------------------------------
  # * Get File Index to Select First
  #--------------------------------------------------------------------------
  def first_savefile_index
    DataManager.last_savefile_index
  end
  #--------------------------------------------------------------------------
  # * Confirm Save File
  #--------------------------------------------------------------------------
  def on_savefile_ok
    super
    if DataManager.save_game(@index)
      on_save_success
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # * Processing When Save Is Successful
  #--------------------------------------------------------------------------
  def on_save_success
    Sound.play_save
    return_scene
  end
end
