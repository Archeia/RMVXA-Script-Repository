#==============================================================================
#    Visible Injuries
#    Version: 1.0.0
#    Author: modern algebra (rmrk.net)
#    Date: July 18, 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    
#    This script allows you to set it so that an enemy's battler will change
#   when the enemy falls below any percentage of HP you choose. This can be 
#   used to make it so that the battler looks like it gets progressively 
#   more injured throughout the battle.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials.
#
#    To set which battlers should be used to reflect injury and at what
#   percentage of health, you use the following code in the enemy's note field:
#
#        \injured_battler[p, "b", h]
#
#    where:  p - an integer between 1 and 100; this is the percentage of HP 
#           the enemy must fall below before the battler is changed.
#            b - the filename of the battler
#            h - the hue of the battler. If not included, defaults to 0.
#
#  EXAMPLE:
#
#    If the following is in an Slime's note field:
#
#        \injured_battler[50, "Slime", 128]
#
#    Then when the Slime falls below 50% HP, it will change hue to 128.
#
#    If the following is in a Bandit's note field:
#
#        \injured_battler[70, "Injured Bandit"]
#        \injured_battler[25, "Wounded Bandit"]
#
#    Then when the Bandit falls below 70% HP, the battler graphic will change
#   to "Injured Bandit". When the Bandit falls below 25% HP, the battler 
#   graphic will change to "Wounded Bandit".
#==============================================================================

$imported ||= {}
$imported[:"VisibleInjuries 1.0.0"] = true

#==============================================================================
# ** RPG::Enemy
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new methods - vi_injured_battlers
#==============================================================================

class RPG::Enemy
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Injured Battlers
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def vi_injured_battlers
    if !@vi_injured_battlers
      @vi_injured_battlers = []
      self.note.scan(/\\INJURED_BATTLER\[\s*(\d+)[,;:\s]*\"(.+?)\"[,;:\s]*(\d*)\s*\]/i) { |ary|
        @vi_injured_battlers.push([(ary[0].to_f / 100.0), ary[1], ary[2].to_i])
      }
      @vi_injured_battlers.push([100, battler_name, battler_hue])
      @vi_injured_battlers.sort! {|a, b| a[0] <=> b[0] }
    end
    @vi_injured_battlers
  end
end

#==============================================================================
# ** Game_Enemy
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - hp=; refresh; recover_all
#    new method - vi_update_injuries
#==============================================================================

class Game_Enemy
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Change HP
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_vi_chnghp_2kh5 hp=
  def hp=(*args, &block)
    ma_vi_chnghp_2kh5(*args, &block) # Call Original Method
    vi_update_injuries
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Refresh
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_vi_refr_6jz3 refresh
  def refresh(*args, &block)
    ma_vi_refr_6jz3(*args, &block) # Call Original Method
    vi_update_injuries
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Recover All
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_vi_recovall_3hk9 recover_all
  def recover_all(*args, &block)
    ma_vi_recovall_3hk9(*args, &block) # Call Original Method
    vi_update_injuries
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Injuries
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def vi_update_injuries
    enemy.vi_injured_battlers.each { |ary|
      if hp_rate <= ary[0]
        @battler_name = ary[1]
        @battler_hue = ary[2]
        break
      end
    }
  end
end