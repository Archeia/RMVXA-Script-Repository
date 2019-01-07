module CP
module CHAOS

STATES =[5]

end
end

class Game_Player
  def move_by_input
    return if !movable? || $game_map.interpreter.running?
    return unless Input.dir4 > 0
    i = chaos_state? ? (rand(4) + 1) * 2 : Input.dir4
    move_straight(i)
  end
  
  def chaos_state?
    return false if $game_party.members.empty?
    return true if $game_party.members[0].has_chaos?
    return false
  end
end

class Game_BattlerBase
  def has_chaos?
    @states.any? {|i| CP::CHAOS::STATES.include?(i)}
  end
end