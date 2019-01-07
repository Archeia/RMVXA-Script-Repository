class Game_Interpreter
  
  # returns whether the player is facing the specified event
  def is_facing?(evt_id)
    evt = evt_id ? get_character(evt_id) : get_character(@event_id)
    player_dir = $game_player.direction
    case evt.direction
    when 2
      return player_dir == 8
    when 4
      return player_dir == 6
    when 6
      return player_dir == 4
    when 8
      return player_dir == 2
    end
    return false
  end
end