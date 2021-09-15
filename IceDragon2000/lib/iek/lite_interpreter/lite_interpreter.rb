# The Lite Interpreter is a stripped down version of the regular game interpreter
# it removes most event/character related commands and only leaves the
# party and message controls.
$simport.r 'iek/lite_interpreter', '1.0.0', 'Light weight interpreter for scripting use' do |h|
  h.depend! 'better_interpreter', '~> 1.0.0'
end

class Game_LiteInterpreter < Game_Interpreter
  attr_writer :game_temp
  attr_writer :game_system
  attr_writer :game_timer
  attr_writer :game_message
  attr_writer :game_switches
  attr_writer :game_variables
  attr_writer :game_self_switches
  attr_writer :game_actors
  attr_writer :game_party
  attr_writer :game_troop
  attr_writer :game_map
  attr_writer :game_player

  def game_temp
    @game_temp ||= $game_temp
  end

  def game_system
    @game_system ||= $game_system
  end

  def game_timer
    @game_timer ||= $game_timer
  end

  def game_message
    @game_message ||= $game_message
  end

  def game_switches
    @game_switches ||= $game_switches
  end

  def game_variables
    @game_variables ||= $game_variables
  end

  def game_self_switches
    @game_self_switches ||= $game_self_switches
  end

  def game_actors
    @game_actors ||= $game_actors
  end

  def game_party
    @game_party ||= $game_party
  end

  def game_troop
    @game_troop ||= $game_troop
  end

  def game_map
    @game_map ||= $game_map
  end

  def game_player
    @game_player ||= $game_player
  end
end
