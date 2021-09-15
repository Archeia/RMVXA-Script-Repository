#encoding:UTF-8
# Game_Message
#==============================================================================
# ** Game_Message
#------------------------------------------------------------------------------
#  This class handles the state of the message window that display text or
# selections, etc. The instance of this class is referenced by $game_message.
#==============================================================================

class Game_Message
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  MAX_LINE = 4                            # Maximum number of lines
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :texts                    # arrange text (by line)
  attr_accessor :face_name                # face graphic filename
  attr_accessor :face_index               # face graphic index
  attr_accessor :background               # background type
  attr_accessor :position                 # display position
  attr_accessor :main_proc                # main callback (Proc)
  attr_accessor :choice_proc              # show choices: callback (Proc)
  attr_accessor :choice_start             # show choices: opening line
  attr_accessor :choice_max               # show choices: number of items
  attr_accessor :choice_cancel_type       # show choices: cancel
  attr_accessor :num_input_variable_id    # input number: variable ID
  attr_accessor :num_input_digits_max     # input number: digit count
  attr_accessor :visible                  # displaying a message
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    clear
    @visible = false
  end
  #--------------------------------------------------------------------------
  # * Clear
  #--------------------------------------------------------------------------
  def clear
    @texts = []
    @face_name = ""
    @face_index = 0
    @background = 0
    @position = 2
    @main_proc = nil
    @choice_start = 99
    @choice_max = 0
    @choice_cancel_type = 0
    @choice_proc = nil
    @num_input_variable_id = 0
    @num_input_digits_max = 0
  end
  #--------------------------------------------------------------------------
  # * Busy Status Determination
  #--------------------------------------------------------------------------
  def busy
    return @texts.size > 0
  end
  #--------------------------------------------------------------------------
  # * New Page
  #--------------------------------------------------------------------------
  def new_page
    while @texts.size % MAX_LINE > 0
      @texts.push("")
    end
  end
end
