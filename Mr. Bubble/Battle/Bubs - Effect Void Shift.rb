# ╔══════════════════════════════════════════════════════╤══════╤════════════╗
# ║ Effect: Void Shift                                   │ v1.3 │ (10/08/12) ║
# ╚══════════════════════════════════════════════════════╧══════╧════════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
# Thanks:
#     Tsukihime, effect manager script
#--------------------------------------------------------------------------
# This script replicates the effect of the "Void Shift" spell usable by
# the Priest class in World of Warcraft. Void Shift swaps the HP 
# percentages of the user and the target. I've added the option of 
# swapping other resources such as MP and TP as well.
#
# There is one caveat: this effect isn't meant to be used on multiple 
# targets such as "All Allies". Please limit the scope of the Void Shift 
# skill/item to a single target.
#--------------------------------------------------------------------------
#   ++ Changelog ++
#--------------------------------------------------------------------------
# v1.3 : The default minimum swap threshhold is now 0%. (10/08/2012)
# v1.2 : Updated for Oct 7th 2012 version of Effect Manager.
#      : Void Shift now has no effect if the target is the user. (10/07/2012)
# v1.1 : Effect code changed to a symbol. (10/06/2012)
# v1.0 : Initial release. (10/06/2012)
#--------------------------------------------------------------------------
#   ++ Installation ++
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor.
#
# This script requires the core script "Effect Manager" by Tsukihime.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ++ Notetags ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Note: Some tags are given shorter tags for typing convenience. You only
#       need to use one <tag> from a given group for a notebox. 
#       Use common sense.
#
# The following Notetags are for Skills and Items:
#
# <eff: void_shift type min: n%>
# <eff: void_shift type>
#   This tag allows the user of the skill or item to swap HP/MP/TP with
#   the chosen target. 'type' is HP, MP, or TP. 'min: n%' is an
#   optional argument. It defines the minimum threshhold for the resource 
#   swap. This means that if the user or target has less than the defined
#   minimum rate, that resource will automatically be raised to that 
#   minimum rate. By default, the minimum is 0%.
#
# Here are some examples of void shift tags:
#
#   <eff: void_shift hp min: 25%>
# 
# The user and target will swap HP rates. If a battler has less than
# 25% HP after the swap, their HP rate will automatically be set to 25%
# of their maximum HP. This effect essentially copies the original Void 
# Shift skill from WoW.
#
#   <eff: void_shift mp>
#
# The user and target will swap MP rates. 'min' has been left out which 
# means the minimum swap threshhold is 0%.
#--------------------------------------------------------------------------
#   ++ Terms and Conditions ++
#--------------------------------------------------------------------------
# Please do not repost this script elsewhere without permission.
#
# Free for non-commercial and commercial use.
#
# Newest versions of this script can be found at 
#                                          http://mrbubblewand.wordpress.com/
#=============================================================================

$imported ||= {}
$imported["Effect_VoidShift"] = true


#==========================================================================
# ++ This script contains no customization module ++
#==========================================================================


#==============================================================================
# ++ Configuration
#==============================================================================
if $imported["Effect_Manager"]

module Bubs
  module VoidShift
    
  Effect_Manager.register_effect(:void_shift)
    
  end # module VoidShift
end # module Bubs

end # $imported["Effect_Manager"]

#==============================================================================
# ++ Game_Battler
#==============================================================================
class RPG::UsableItem
  #--------------------------------------------------------------------------
  # add_effect_void_shift
  #--------------------------------------------------------------------------
  def add_effect_void_shift(code, data_id, args)
    args[0].upcase!
    args[2] = args[2] =~ /(\d+)/i ? $1.to_f / 100.0 : 0.00
    @effects.push(RPG::UsableItem::Effect.new(code, data_id, args))
  end 
end

#==============================================================================
# ++ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # item_effect_void_shift
  #--------------------------------------------------------------------------
  def item_effect_void_shift(user, item, effect)
    return if self == user
    case effect.value1[0]
    when "HP"
      item_effect_void_shift_hp(user, item, effect)
    when "MP"
      item_effect_void_shift_mp(user, item, effect)
    when "TP"
      item_effect_void_shift_tp(user, item, effect)
    end
    @result.success = true
  end
  
  #--------------------------------------------------------------------------
  # item_effect_void_shift_hp
  #--------------------------------------------------------------------------
  def item_effect_void_shift_hp(user, item, effect)
    self_rate = self.hp_rate
    user_rate = user.hp_rate
    min       = effect.value1[2]
    rates     = item_effect_void_shift_rate(self_rate, user_rate, min)
    self.hp   = (self.mhp * rates[1]).ceil
    user.hp   = (user.mhp * rates[0]).ceil
  end
  
  #--------------------------------------------------------------------------
  # item_effect_void_shift_mp
  #--------------------------------------------------------------------------
  def item_effect_void_shift_mp(user, item, effect)
    self_rate = self.mp_rate
    user_rate = user.mp_rate
    min       = effect.value1[2]
    rates     = item_effect_void_shift_rate(self_rate, user_rate, min)
    self.mp   = (self.mmp * rates[1]).ceil
    user.mp   = (user.mmp * rates[0]).ceil
  end
  
  #--------------------------------------------------------------------------
  # item_effect_void_shift_tp
  #--------------------------------------------------------------------------
  def item_effect_void_shift_tp(user, item, effect)
    self_rate = self.tp_rate
    user_rate = user.tp_rate
    min       = effect.value1[2]
    rates     = item_effect_void_shift_rate(self_rate, user_rate, min)
    self.tp   = (self.max_tp * rates[1]).ceil
    user.tp   = (user.max_tp * rates[0]).ceil
  end
  
  #--------------------------------------------------------------------------
  # item_effect_void_shift_rate
  #--------------------------------------------------------------------------
  def item_effect_void_shift_rate(self_rate, user_rate, min)
    temp_self_rate = self_rate > min ? self_rate : min
    temp_user_rate = user_rate > min ? user_rate : min
    return [temp_self_rate, temp_user_rate]
  end
  
end # class Game_Battler
