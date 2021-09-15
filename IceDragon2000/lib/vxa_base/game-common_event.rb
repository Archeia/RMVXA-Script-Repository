#encoding:UTF-8
# Game_CommonEvent
#==============================================================================
# ** Game_CommonEvent
#------------------------------------------------------------------------------
#  This class handles common events. It includes functionality for execution of
# parallel process events. It's used within the Game_Map class ($game_map).
#==============================================================================

class Game_CommonEvent
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(common_event_id)
    @event = $data_common_events[common_event_id]
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    if active?
      @interpreter ||= Game_Interpreter.new
    else
      @interpreter = nil
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Active State
  #--------------------------------------------------------------------------
  def active?
    @event.parallel? && $game_switches[@event.switch_id]
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    if @interpreter
      @interpreter.setup(@event.list) unless @interpreter.running?
      @interpreter.update
    end
  end
end
