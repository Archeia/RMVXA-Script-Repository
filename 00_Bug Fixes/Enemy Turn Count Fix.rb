#--------------------------------------------------------------------------
# Enemy Turn Count Fix
# Author(s):
# Lone Wolf
#--------------------------------------------------------------------------
# By default, enemy actions are determined at the start of the round but 
# before the turn counter is increased. This means that any monster's 
# turn-specific actions actually execute one turn late, so actions set to 
# happen on round 1 won't happen until round 2.
#
# A side effect of this script is that actions set to happen on turn 0 + 0 
# will not happen at all (though 0 + X actions will happen normally). 
# According to the tooltip, this is the intended behavior in VX Ace.
#
#--------------------------------------------------------------------------
module BattleManager
  def self.input_start
	if @phase != :input
	  @phase = :input
	  $game_troop.increase_turn
	  $game_party.make_actions
	  $game_troop.make_actions
	  clear_actor
	end
	return !@surprise && $game_party.inputable?
  end
  def self.turn_start
	@phase = :turn
	clear_actor
	make_action_orders
  end
end