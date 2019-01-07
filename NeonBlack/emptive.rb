## Snippet created by Neon Black
## 8.5.2012

## Mod of one of my other scripts.  Choose a variable not currently in use.
## When the player approaches the foe from the back, it is set to 1, from the
## side, it is set to 2.
## Conversely, when the event approaches the player from the back, it is set to
## -1, from the side, it is set to -2

module CP
module CHASE

VARIABLE = 21

end
end

module BattleManager
  def self.on_encounter
    @preemptive = ($game_variables[CP::CHASE::VARIABLE] == 1)
    @surprise = ($game_variables[CP::CHASE::VARIABLE] == -1)
    $game_variables[CP::CHASE::VARIABLE] = 0
  end
end

class Game_Interpreter
  def command_301
    return if $game_party.in_battle
    if @params[0] == 0                      # Direct designation
      troop_id = @params[1]
    elsif @params[0] == 1                   # Designation with variables
      troop_id = $game_variables[@params[1]]
    else                                    # Map-designated troop
      troop_id = $game_player.make_encounter_troop_id
    end
    if $data_troops[troop_id]
      BattleManager.setup(troop_id, @params[2], @params[3])
      BattleManager.event_proc = Proc.new {|n| @branch[@indent] = n }
      $game_player.make_encounter_count
      BattleManager.on_encounter
      SceneManager.call(Scene_Battle)
    end
    Fiber.yield
  end
end

class Game_Event < Game_Character
  alias cp_chase_locki lock unless $@
  def lock
    check_both_ev_dir
    cp_chase_locki
  end
  
  def check_both_ev_dir
    sx = distance_x_from($game_player.x)
    sy = distance_y_from($game_player.y)
    if sx.abs > sy.abs
      res = sx > 0 ? 4 : 6
      ops = sx > 0 ? 6 : 4
    elsif sy != 0
      res = sy > 0 ? 8 : 2
      ops = sy > 0 ? 2 : 8
    else
      res = 0; ops = 0
    end
    var = CP::CHASE::VARIABLE
    $game_variables[var] = 0
    $game_variables[var] = -1 if (@direction == res &&
                                  $game_player.direction == res)
    $game_variables[var] = -2 if (@direction == res &&
                                  $game_player.direction != res &&
                                  $game_player.direction != ops)
    $game_variables[var] = 1 if (@direction == ops &&
                                 $game_player.direction == ops)
    $game_variables[var] = 2 if (@direction != ops &&
                                 @direction != res &&
                                 $game_player.direction == ops)
  end
end