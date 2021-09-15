#encoding:UTF-8
# Game_Variables
#==============================================================================
# ** Game_Variables
#------------------------------------------------------------------------------
#  This class handles variables. It's a wrapper for the built-in class "Array."
# The instance of this class is referenced by $game_variables.
#==============================================================================

class Game_Variables
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @data = []
  end
  #--------------------------------------------------------------------------
  # * Get Variable
  #     variable_id : variable ID
  #--------------------------------------------------------------------------
  def [](variable_id)
    if @data[variable_id] == nil
      return 0
    else
      return @data[variable_id]
    end
  end
  #--------------------------------------------------------------------------
  # * Set Variable
  #     variable_id : variable ID
  #     value       : the variable's value
  #--------------------------------------------------------------------------
  def []=(variable_id, value)
    if variable_id <= 5000
      @data[variable_id] = value
    end
  end
end
