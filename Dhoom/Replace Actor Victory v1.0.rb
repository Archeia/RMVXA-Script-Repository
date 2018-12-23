#==============================================================================
#
# • Replace Actor Victory v1.0
# -- Author: DrDhoom
# -- Last Updated: 2014.10.09
# -- Level: Easy
# -- Requires: None
#
#==============================================================================

module Dhoom
  module ReplaceActorVictory
    Replace_Actor = []
    #Replace this actor id with => this actor id
    Replace_Actor[1] = 4
    Replace_Actor[3] = 6
  end
end

module BattleManager
  class <<self; alias dhoom_rplcactor_btlman_process_victory process_victory; end
  def self.process_victory
    $game_party.replace_actors_victory
    dhoom_rplcactor_btlman_process_victory
  end  
end

class Game_Party < Game_Unit
  def replace_actors_victory
    @actors.each_with_index do |actor,index|
      if Dhoom::ReplaceActorVictory::Replace_Actor[actor]
        @actors[index] = Dhoom::ReplaceActorVictory::Replace_Actor[actor] 
      end
    end
    $game_player.refresh
    $game_map.need_refresh = true
  end
end