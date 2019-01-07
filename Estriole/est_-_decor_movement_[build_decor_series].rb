=begin
haven't got time to write the documentation. read the EST - DECOR AND BUILD
script on how to use this
=end
module ESTRIOLE
  SELF_SWITCH_DECOR = 'A'
end
class Game_Interpreter
  def decor_move(self_switch_end = true,restric_region = nil)
    $game_switches[YEA::UTILITY::STOP_PLAYER_MOVEMENT_SWITCH] = true
    wait(1)
    $game_system.menu_disabled = true
    decor_move_down if Input.press?(:DOWN)
    decor_move_left if Input.press?(:LEFT)
    decor_move_right if Input.press?(:RIGHT)
    decor_move_up if Input.press?(:UP)
    decor_move_end(self_switch_end) if Input.press?(:C) && $game_map.events[@event_id].decor_move
  end
  def decor_move_down
    Sound.play_cursor
    $game_map.events[@event_id].move_straight(2) 
    $game_map.events[@event_id].decor_move = true
  end
  def decor_move_left
    Sound.play_cursor
    $game_map.events[@event_id].move_straight(4) 
    $game_map.events[@event_id].decor_move = true
  end
  def decor_move_right
    Sound.play_cursor
    $game_map.events[@event_id].move_straight(6) 
    $game_map.events[@event_id].decor_move = true
  end
  def decor_move_up
    Sound.play_cursor
    $game_map.events[@event_id].move_straight(8) 
    $game_map.events[@event_id].decor_move = true
  end
  def decor_move_end(self_switch_end)
    wx = $game_map.events[@event_id].x
    wy = $game_map.events[@event_id].y
    px = $game_player.x
    py = $game_player.y
    return Sound.play_buzzer if px > wx-1 && px < wx+1 && py > wy-1 && py < wy+1
    return Sound.play_buzzer if wx==px && wy==py
    Sound.play_ok
    $game_self_switches[[@map_id, @event_id, ESTRIOLE::SELF_SWITCH_DECOR]] = self_switch_end
    $game_map.events[@event_id].decor_move = false
    $game_switches[YEA::UTILITY::STOP_PLAYER_MOVEMENT_SWITCH] = false
    $game_system.menu_disabled = $game_party.saving_status rescue false
    $game_map.events[@event_id].refresh
  end
end

class Game_Event < Game_Character
  attr_accessor :decor_move
end