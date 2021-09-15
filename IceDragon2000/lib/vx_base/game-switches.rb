#encoding:UTF-8
# Game_Switches
#==============================================================================
# ** Game_Switches
#------------------------------------------------------------------------------
#  This class handles switches. It's a wrapper for the built-in class "Array."
# The instance of this class is referenced by $game_switches.
#==============================================================================

class Game_Switches
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @data = []
  end
  #--------------------------------------------------------------------------
  # * Get Switch
  #     switch_id : switch ID
  #--------------------------------------------------------------------------
  def [](switch_id)
    if @data[switch_id] == nil
      return false
    else
      return @data[switch_id]
    end
  end
  #--------------------------------------------------------------------------
  # * Set Switch
  #     switch_id : switch ID
  #     value     : ON (true) / OFF (false)
  #--------------------------------------------------------------------------
  def []=(switch_id, value)
    if switch_id <= 5000
      @data[switch_id] = value
    end
  end
end
