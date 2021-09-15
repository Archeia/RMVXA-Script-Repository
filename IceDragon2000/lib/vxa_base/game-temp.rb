#encoding:UTF-8
# Game_Temp
#==============================================================================
# ** Game_Temp
#------------------------------------------------------------------------------
#  This class handles temporary data that is not included with save data.
# The instance of this class is referenced by $game_temp.
#==============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :common_event_id          # Common Event ID
  attr_accessor :fade_type                # Fade Type at Player Transfer
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @common_event_id = 0
    @fade_type = 0
  end
  #--------------------------------------------------------------------------
  # * Reserve Common Event Call
  #--------------------------------------------------------------------------
  def reserve_common_event(common_event_id)
    @common_event_id = common_event_id
  end
  #--------------------------------------------------------------------------
  # * Clear Common Event Call Reservation
  #--------------------------------------------------------------------------
  def clear_common_event
    @common_event_id = 0
  end
  #--------------------------------------------------------------------------
  # * Determine Reservation of Common Event Call
  #--------------------------------------------------------------------------
  def common_event_reserved?
    @common_event_id > 0
  end
  #--------------------------------------------------------------------------
  # * Get Reserved Common Event
  #--------------------------------------------------------------------------
  def reserved_common_event
    $data_common_events[@common_event_id]
  end
end
