#encoding:UTF-8
# Game_Actors
#==============================================================================
# ** Game_Actors
#------------------------------------------------------------------------------
#  This class handles the actor array. The instance of this class is
# referenced by $game_actors.
#==============================================================================

class Game_Actors
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @data = []
  end
  #--------------------------------------------------------------------------
  # * Get Actor
  #     actor_id : actor ID
  #--------------------------------------------------------------------------
  def [](actor_id)
    if @data[actor_id] == nil and $data_actors[actor_id] != nil
      @data[actor_id] = Game_Actor.new(actor_id)
    end
    return @data[actor_id]
  end
end
