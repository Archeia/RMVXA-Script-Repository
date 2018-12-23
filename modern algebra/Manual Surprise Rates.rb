#==============================================================================
#    Manual Surprise Rates
#    Version: 1.0.0
#    Author: modern algebra (rmrk.net)
#    Date: 29 December 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    
#    This script allows you to manually set the pre-emptive attack and surprise
#   attack rates. It can be especially useful for story battles where you want
#   the party or the enemy to have the upper hand in line with the story event.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials.
#
#    To set the preemptive and surprise rates manually, all you need to do is
#   use either of the following codes in a Script event command:
#
#      $game_party.manual_preemptive_rate = x
#      $game_party.manual_surprise_rate = x
#
#   where x is the percentage you seek. It can be a float between 0.01 (1%) and 
#   1.0 (100%). You can also use integer percentile between 2 (2%) and 100 
#   (100%).
#
#    When you set the rate manually, then it overrides any effects from the 
#   "Cancel Surprise" and "Raise Preemptive" features. As such, they will be 
#   ineffective and they do not interact with the rate that is manually set.
#
#    Finally, you can also set it so that the manual rates apply only for one,
#   battle, after which they are reset and the calculation returns to normal. 
#   For more details, see the Editable Region beginning at line 41.
#==============================================================================

$imported = {} unless $imported
$imported[:MA_ManualSurpriseRates] = true

#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
# BEGIN Editable Region
#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#  MAMSR_RESET_RATES_AFTER_BATTLE
#    If this option is true, then the manual surprise and preemptive rates that
#   you have set will be reset after a battle, meaning that they will only
#   apply to the first battle after they are set. If set to false, the rate 
#   will remain what it is until manually set to something else. You can also 
#   set this value to an integer, in which case its value will be dependent on
#   the value of the switch with that ID. For example, if you set it to 4, then
#   the rates will be reset after battle when Switch 4 is ON, and will not be
#   reset when Switch 4 is OFF.
MAMSR_RESET_RATES_AFTER_BATTLE = false
#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# END Editable Region
#//////////////////////////////////////////////////////////////////////////////

#==============================================================================
# *** Battle Manager
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - self.setup
#==============================================================================

module BattleManager
  class << self
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Initialize Members
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    alias mamsr_setp_2hn5 setup
    def setup(*args)
      mamsr_setp_2hn5(*args) # Call Original Method
      # Calculate here since manual settings should apply to evented battles too
      @preemptive = (rand < rate_preemptive) if $game_party.manual_preemptive_rate
      @surprise = (rand < rate_surprise && !@preemptive) if $game_party.manual_surprise_rate
    end
  end
end

#==============================================================================
# ** Game_Party
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new attr_accessors - manual_preemptive_rate; manual_surprise_rate
#    aliased methods - rate_preemptive; rate_surprise; on_battle_end
#    new method - mamsr_reset_surprise_rates
#==============================================================================

class Game_Party
  [:preemptive, :surprise].each { |type|
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Public Instance Variables
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    attr_accessor :"manual_#{type}_rate"
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Calculate Probability of Surprise
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    alias_method(:"mamsr_#{type}rate_2rm6", :"rate_#{type}")
    define_method(:"rate_#{type}") do |*args|
      rate = instance_variable_get(:"@manual_#{type}_rate")
      return (rate.is_a?(Float) || rate < 1) ? [[0, rate].max, 1.0].min : rate / 100.0 if rate
      send(:"mamsr_#{type}rate_2rm6", *args)
    end
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Processing at End of Battle
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # if on_battle_end already defined in Game_Party, then alias
  if instance_methods(false).include?(:on_battle_end)
    alias mamsr_onbatlend_6hc2 on_battle_end
    def on_battle_end(*args)
      mamsr_reset_surprise_rates
      mamsr_onbatlend_6hc2(*args) # Call Original Method
    end
  else # if on_battle_end not yet defined in Game_Party, call super
    def on_battle_end(*args)
      mamsr_reset_surprise_rates
      super(*args) # Call Super Method
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Reset Surprise Rates
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def mamsr_reset_surprise_rates
    resetter = MAMSR_RESET_RATES_AFTER_BATTLE
    if (resetter.is_a?(Integer) ? $game_switches[resetter] : resetter)
      @manual_preemptive_rate = nil
      @manual_surprise_rate = nil
    end
  end
end