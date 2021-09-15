#encoding:UTF-8
# Game_Message
#==============================================================================
# ** Game_Message
#------------------------------------------------------------------------------
#  This class handles the state of the message window that displays text or
# selections, etc. The instance of this class is referenced by $game_message.
#==============================================================================

class Game_Message
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :texts                    # text array (in rows)
  attr_reader   :choices                  # choice array
  attr_accessor :face_name                # face graphic filename
  attr_accessor :face_index               # face graphic index
  attr_accessor :background               # background type
  attr_accessor :position                 # display position
  attr_accessor :choice_proc              # show choices: call back (Proc)
  attr_accessor :choice_cancel_type       # show choices: cancel
  attr_accessor :num_input_variable_id    # input number: variable ID
  attr_accessor :num_input_digits_max     # input number: digit count
  attr_accessor :item_choice_variable_id  # item selection: variable ID
  attr_accessor :scroll_mode              # scroll text flag
  attr_accessor :scroll_speed             # scroll text: speed
  attr_accessor :scroll_no_fast           # scroll text: disable fast forward
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
    @choices = []
    @face_name = ""
    @face_index = 0
    @background = 0
    @position = 2
    @choice_cancel_type = 0
    @choice_proc = nil
    @num_input_variable_id = 0
    @num_input_digits_max = 0
    @item_choice_variable_id = 0
    @scroll_mode = false
    @scroll_speed = 2
    @scroll_no_fast = false
  end
  #--------------------------------------------------------------------------
  # * Add Text
  #--------------------------------------------------------------------------
  def add(text)
    @texts.push(text)
  end
  #--------------------------------------------------------------------------
  # * Determine Existence of Text
  #--------------------------------------------------------------------------
  def has_text?
    @texts.size > 0
  end
  #--------------------------------------------------------------------------
  # * Determine if Choices Mode
  #--------------------------------------------------------------------------
  def choice?
    @choices.size > 0
  end
  #--------------------------------------------------------------------------
  # * Determine if Number Input Mode
  #--------------------------------------------------------------------------
  def num_input?
    @num_input_variable_id > 0
  end
  #--------------------------------------------------------------------------
  # * Determine if Item Selection Mode
  #--------------------------------------------------------------------------
  def item_choice?
    @item_choice_variable_id > 0
  end
  #--------------------------------------------------------------------------
  # * Determine if Busy
  #--------------------------------------------------------------------------
  def busy?
    has_text? || choice? || num_input? || item_choice?
  end
  #--------------------------------------------------------------------------
  # * New Page
  #--------------------------------------------------------------------------
  def new_page
    @texts[-1] += "\f" if @texts.size > 0
  end
  #--------------------------------------------------------------------------
  # * Get All Text Including New Lines
  #--------------------------------------------------------------------------
  def all_text
    @texts.inject("") {|r, text| r += text + "\n" }
  end
end
