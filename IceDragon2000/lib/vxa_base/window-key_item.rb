#encoding:UTF-8
# Window_KeyItem
#==============================================================================
# ** Window_KeyItem
#------------------------------------------------------------------------------
#  This window is used for the event command [Select Item].
#==============================================================================

class Window_KeyItem < Window_ItemList
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(message_window)
    @message_window = message_window
    super(0, 0, Graphics.width, fitting_height(4))
    self.openness = 0
    deactivate
    set_handler(:ok,     method(:on_ok))
    set_handler(:cancel, method(:on_cancel))
  end
  #--------------------------------------------------------------------------
  # * Start Input Processing
  #--------------------------------------------------------------------------
  def start
    self.category = :key_item
    update_placement
    refresh
    select(0)
    open
    activate
  end
  #--------------------------------------------------------------------------
  # * Update Window Position
  #--------------------------------------------------------------------------
  def update_placement
    if @message_window.y >= Graphics.height / 2
      self.y = 0
    else
      self.y = Graphics.height - height
    end
  end
  #--------------------------------------------------------------------------
  # * Processing at OK
  #--------------------------------------------------------------------------
  def on_ok
    result = item ? item.id : 0
    $game_variables[$game_message.item_choice_variable_id] = result
    close
  end
  #--------------------------------------------------------------------------
  # * Processing at Cancel
  #--------------------------------------------------------------------------
  def on_cancel
    $game_variables[$game_message.item_choice_variable_id] = 0
    close
  end
end
