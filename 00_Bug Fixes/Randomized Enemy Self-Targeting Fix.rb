#--------------------------------------------------------------------------
# Randomized Enemy Self-Targeting
# Author(s):
# Lone Wolf
#--------------------------------------------------------------------------
# By default, enemy actions set to target a member of their own group will 
# always, without exception, target the last enemy in the list, making buffs 
# and healing commands essentially worthless when given to groups of enemies. 
# This patch implements an extra step to keep enemies from skipping target 
# selection for ally actions.
#
# Note that this does not implement any enemy AI, it only restores the random 
# behavior found in earlier versions of RPG Maker.
#--------------------------------------------------------------------------
class Game_Action
  def targets_for_friends
	if item.for_user?
	  [subject]
	elsif item.for_dead_friend?
	  if item.for_one?
		[friends_unit.smooth_dead_target(@target_index)]
	  else
		friends_unit.dead_members
	  end
	elsif item.for_friend?
	  if item.for_one?
		if @target_index < 0
		  [friends_unit.random_target]
		else
		  [friends_unit.smooth_target(@target_index)]
		end
	  else
		friends_unit.alive_members
	  end
	end
  end
end