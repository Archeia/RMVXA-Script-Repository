#encoding:UTF-8
# Window_GameEnd
#==============================================================================
# ** Window_GameEnd
#------------------------------------------------------------------------------
#  This window is for selecting Go to Title/Shut Down on the game over screen.
#==============================================================================

class Window_GameEnd < Window_Command
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0)
    update_placement
    self.openness = 0
    open
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return 160
  end
  #--------------------------------------------------------------------------
  # * Update Window Position
  #--------------------------------------------------------------------------
  def update_placement
    self.x = (Graphics.width - width) / 2
    self.y = (Graphics.height - height) / 2
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::to_title, :to_title)
    add_command(Vocab::shutdown, :shutdown)
    add_command(Vocab::cancel,   :cancel)
  end
end
