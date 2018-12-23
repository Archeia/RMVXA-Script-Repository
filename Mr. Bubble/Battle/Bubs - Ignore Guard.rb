# ╔═══════════════════════════════════════════════════════╤══════╤═══════════╗
# ║ Ignore Guard                                          │ v1.0 │ (8/13/12) ║
# ╚═══════════════════════════════════════════════════════╧══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
#--------------------------------------------------------------------------
# Apparently, there's no default way in the project edtior to disregard 
# the target's Guard state when calculating skill/item formulae.
#
# This script allows skills and items to ignore the target's Guard state 
# which will allow developers to create damage formulae that truly ignores 
# defense such as "b.hp - 1".
#--------------------------------------------------------------------------
#   ++ Changelog ++
#--------------------------------------------------------------------------
# v1.0 : Initial release. (8/13/2012)
#--------------------------------------------------------------------------
#   ++ Installation ++
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ++ Notetags ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Note: Some tags are given shorter tags for typing convenience. You only
#       need to use one <tag> from a given group for a notebox. 
#       Use common sense.
#
# The following Notetag is for Actors, Classes, Skills, Items, Weapons,
# Armors, Enemies and States:
#
# <ignore guard>
#   This tag will grant the the ability to ignore the target's Guard state 
#   when calculating damage.
#
#--------------------------------------------------------------------------
#   ++ Compatibility ++
#--------------------------------------------------------------------------
# This script aliases the following default VXA methods:
#
#     Game_ActionResult#clear
#     Game_Battler#guard?
#     Game_Battler#make_damage_value
#
# There are no default method overwrites.
#
# Requests for compatibility with other scripts are welcome.
#--------------------------------------------------------------------------
#   ++ Terms and Conditions ++
#--------------------------------------------------------------------------
# Please do not repost this script elsewhere without permission. 
# Free for non-commercial use. For commercial use, contact me first.
#
# Newest versions of this script can be found at 
#                                           http://mrbubblewand.wordpress.com/
#==============================================================================

$imported ||= {}
$imported["BubsIgnoreGuard"] = true

#==========================================================================
# ++ This script contains no customization module ++
#==========================================================================


#==========================================================================
# ++ Bubs::Regexp
#==========================================================================
module Bubs
  module Regexp
    IGNORE_GUARD_TAG = /<IGNORE[_\s]?GUARD>/i
  end # module Regexp
end # module Bubs


#==========================================================================
# ++ RPG::BaseItem
#==========================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :ignore_guard
  #--------------------------------------------------------------------------
  # common cache : ignore_guard?
  #--------------------------------------------------------------------------
  def ignore_guard?
    @ignore_guard ||= note =~ Bubs::Regexp::IGNORE_GUARD_TAG ? true : false
  end

end # class RPG::BaseItem


#==============================================================================
# ++ Game_ActionResult
#==============================================================================
class Game_ActionResult
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :ignored_guard            # ignore guard flag
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  alias clear_bubs_ignore_guard clear
  def clear
    clear_bubs_ignore_guard # alias
    
    @ignored_guard = false
  end
  
end # class Game_ActionResult


#==============================================================================
# ++ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # alias : guard?
  #--------------------------------------------------------------------------
  alias guard_bubs_ignore_guard guard?
  def guard?
    return false if @result.ignored_guard
    return guard_bubs_ignore_guard # alias
  end
  
  #--------------------------------------------------------------------------
  # alias : make_damage_value
  #--------------------------------------------------------------------------
  alias make_damage_value_bubs_ignore_guard make_damage_value
  def make_damage_value(user, item)
    determine_ignore_guard(user, item)

    make_damage_value_bubs_ignore_guard(user, item) # alias
  end
  
  #--------------------------------------------------------------------------
  # new method : determine_ignore_guard
  #--------------------------------------------------------------------------
  def determine_ignore_guard(user, item)
    @result.ignored_guard = (item.ignore_guard? || user.ignore_guard?)
  end
  
  #--------------------------------------------------------------------------
  # new method : ignore_guard?
  #--------------------------------------------------------------------------
  def ignore_guard?
    if actor?
      return true if self.actor.ignore_guard?
      return true if self.class.ignore_guard?
      for equip in equips
        next if equip.nil?
        return true if equip.ignore_guard?
      end
    else # enemy
      return true if self.enemy.ignore_guard?
    end
    for state in states
      next if state.nil?
      return true if state.ignore_guard?
    end
    return false
  end
  
end # class Game_Battler