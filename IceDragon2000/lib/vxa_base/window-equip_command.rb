#encoding:UTF-8
# Window_EquipCommand
#==============================================================================
# ** Window_EquipCommand
#------------------------------------------------------------------------------
#  This window is for selecting commands (change equipment/ultimate equipment
# etc.) on the skill screen.
#==============================================================================

class Window_EquipCommand < Window_HorzCommand
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width)
    @window_width = width
    super(x, y)
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    @window_width
  end
  #--------------------------------------------------------------------------
  # * Get Digit Count
  #--------------------------------------------------------------------------
  def col_max
    return 3
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::equip2,   :equip)
    add_command(Vocab::optimize, :optimize)
    add_command(Vocab::clear,    :clear)
  end
end
