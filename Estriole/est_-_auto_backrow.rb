$imported = {} if $imported.nil?
$imported["EST - AUTO BACKROW"] = true
=begin
 ** EST - AUTO BACKROW v 1.0 
 author : estriole
 licences:
 Free to use in all project (except the one containing pornography)
 as long as i credited (ESTRIOLE).
  
 this script made the back row state auto added at start of battle
 
=end

if $imported["EST-ENEMY POSITION"] == true

module ESTRIOLE
  AUTO_BACK_ROW_STATE = BACK_ROW_STATE[0] # DEFAULT BACK_ROW_STATE[0] 
                                          # MEANS FIRST STATE IN BACK ROW STATE ARRAY
  #JUST MAKE SURE THE AUTO_BACK_ROW_STATE HAVE REMOVED AFTER BATTLE FEATURE IN EDITOR                                        
end

module BattleManager
  
  class << self; alias battle_start_add_rows_state battle_start; end

  def self.battle_start
    battle_start_add_rows_state
    for i in 3..5
      next if $game_party.battle_members_array[i] == 0
      id = $game_party.battle_members_array[i]
      j = getformpos(id)
      $game_party.battle_members[j].add_state(ESTRIOLE::AUTO_BACK_ROW_STATE)
    end
  end

  def self.getformpos(actorid)
    for i in 0..$game_party.battle_members.size-1
      if $game_party.battle_members[i].id == actorid
      return i
      end
    end
  end  

end #end module battle manager

end #end imported enemy position