#encoding:UTF-8
# Window_TargetEnemy
#==============================================================================
# ** Window_TargetEnemy
#------------------------------------------------------------------------------
#  Window for selecting the enemy who is the action target on the battle
# screen.
#==============================================================================

class Window_TargetEnemy < Window_Command
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    commands = []
    @enemies = []
    for enemy in $game_troop.members
      next unless enemy.exist?
      commands.push(enemy.name)
      @enemies.push(enemy)
    end
    super(416, commands, 2, 4)
  end
  #--------------------------------------------------------------------------
  # * Get Enemy Object
  #--------------------------------------------------------------------------
  def enemy
    return @enemies[@index]
  end
end
