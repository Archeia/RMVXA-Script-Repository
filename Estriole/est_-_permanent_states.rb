=begin
this is whole rewrite of my EST - PERMANENT STATE v1.0.

This not completed yet but already works. so i release it temporary
as snippet to use with non ya request.
future plan:
ability to remove / add permanent states
example: you want at certain time. that states not permanent anymore.

after it finished i will released it again as update to
my EST - PERMANENT STATE as v.2.0

=end
module ESTRIOLE

  START_PERMANENT_STATES = [44,45,46,47]
  
end

class Game_Temp
  attr_accessor :permanent_states
  alias est_game_temp_permanent_states_initialize initialize
  def initialize
    est_game_temp_permanent_states_initialize
    @permanent_states = ESTRIOLE::START_PERMANENT_STATES
  end
end

class Game_Battler < Game_BattlerBase
  alias est_game_battler_permanent_state_clear_states clear_states
  def clear_states
    permanent_states = []
    permanent_state_turns = {}
    permanent_state_steps = {}
    if @states
      for state in @states
        if $game_temp.permanent_states.include?(state)
          permanent_states.push(state)
          permanent_state_turns[state] = @state_turns[state]
          permanent_state_steps[state] = @state_steps[state]
        end
      end
    end
    est_game_battler_permanent_state_clear_states
    @states = permanent_states
    @state_turns = permanent_state_turns
    @state_steps = permanent_state_steps    
    @result.add_permanent_states_status_effects(permanent_states)
  end
end


class Game_ActionResult
  def add_permanent_states_status_effects(array)
    for state in array
    @added_states.push(state)
    end
  end
end