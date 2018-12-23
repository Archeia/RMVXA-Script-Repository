#==============================================================================
# ** NAMKCOR's Random Battle Transition
#------------------------------------------------------------------------------
#  Override to the standard Scene_Map to allow for random selection of
#  multiple battle transition graphics.
#
#  Configuration:
#  > Ensure that all of your BattleStart graphics are named as follows:
#    BattleStart_X.png, where X is the number.
#
#  > Example: if we had 3 BattleStart graphics, I would name them:
#    BattleStart_1.png, BattleStart_2.png, and BattleStart_3.png
#
#  > At Configuration Point A, set the 'return' value to the number
#    of BattleStart graphics in your System folder.
#==============================================================================

module NAMKCOR
  
  #============================================================================
  # Configuration Point A
  #============================================================================
  def self.battle_transition_count
    return 10
  end
  
#==============================================================================
# DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING!
# YOU HAVE BEEN WARNED!
#==============================================================================
  
  def self.battle_transition_graphic
    return "Graphics/System/BattleStart_" + 
           (rand(battle_transition_count) + 1).to_s
  end

end

class Scene_Map < Scene_Base
  def perform_battle_transition
    Graphics.transition(60, NAMKCOR.battle_transition_graphic, 100)
    Graphics.freeze
  end
end