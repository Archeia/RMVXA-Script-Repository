#encoding:UTF-8
# Window_MenuCommand
#==============================================================================
# ** Window_MenuCommand
#------------------------------------------------------------------------------
#  This command window appears on the menu screen.
#==============================================================================

class Window_MenuCommand < Window_Command
  #--------------------------------------------------------------------------
  # * Initialize Command Selection Position (Class Method)
  #--------------------------------------------------------------------------
  def self.init_command_position
    @@last_command_symbol = nil
  end
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0)
    select_last
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return 160
  end
  #--------------------------------------------------------------------------
  # * Get Number of Lines to Show
  #--------------------------------------------------------------------------
  def visible_line_number
    item_max
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_main_commands
    add_formation_command
    add_original_commands
    add_save_command
    add_game_end_command
  end
  #--------------------------------------------------------------------------
  # * Add Main Commands to List
  #--------------------------------------------------------------------------
  def add_main_commands
    add_command(Vocab::item,   :item,   main_commands_enabled)
    add_command(Vocab::skill,  :skill,  main_commands_enabled)
    add_command(Vocab::equip,  :equip,  main_commands_enabled)
    add_command(Vocab::status, :status, main_commands_enabled)
  end
  #--------------------------------------------------------------------------
  # * Add Formation to Command List
  #--------------------------------------------------------------------------
  def add_formation_command
    add_command(Vocab::formation, :formation, formation_enabled)
  end
  #--------------------------------------------------------------------------
  # * For Adding Original Commands
  #--------------------------------------------------------------------------
  def add_original_commands
  end
  #--------------------------------------------------------------------------
  # * Add Save to Command List
  #--------------------------------------------------------------------------
  def add_save_command
    add_command(Vocab::save, :save, save_enabled)
  end
  #--------------------------------------------------------------------------
  # * Add Exit Game to Command List
  #--------------------------------------------------------------------------
  def add_game_end_command
    add_command(Vocab::game_end, :game_end)
  end
  #--------------------------------------------------------------------------
  # * Get Activation State of Main Commands
  #--------------------------------------------------------------------------
  def main_commands_enabled
    $game_party.exists
  end
  #--------------------------------------------------------------------------
  # * Get Activation State of Formation
  #--------------------------------------------------------------------------
  def formation_enabled
    $game_party.members.size >= 2 && !$game_system.formation_disabled
  end
  #--------------------------------------------------------------------------
  # * Get Activation State of Save
  #--------------------------------------------------------------------------
  def save_enabled
    !$game_system.save_disabled
  end
  #--------------------------------------------------------------------------
  # * Processing When OK Button Is Pressed
  #--------------------------------------------------------------------------
  def process_ok
    @@last_command_symbol = current_symbol
    super
  end
  #--------------------------------------------------------------------------
  # * Restore Previous Selection Position
  #--------------------------------------------------------------------------
  def select_last
    select_symbol(@@last_command_symbol)
  end
end
