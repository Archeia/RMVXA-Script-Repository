# ╔═══════════════════════════════════════════════════════╤══════╤═══════════╗
# ║ Homunculus Item                                       │ v1.0 │ (7/13/12) ║
# ╚═══════════════════════════════════════════════════════╧══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
# Thanks:
#     Mithran, regexp lessons
#--------------------------------------------------------------------------
# Instant death attacks are a staple in the repertoire of skills featured 
# in the SMT series of games by Atlus. Combined with the rule that it is
# game over when the main character dies, players can lose a battle
# instantly they are not wary of these types of skills.
#
# This script provides a protection against instant death attacks by
# implementing the effect of the "Homunculus" item. Homunculus items
# prevent the effects of successful instant death attacks by simply
# being in the party's inventory. This effect is limited to Actors.
#--------------------------------------------------------------------------
#   ++ Changelog ++
#--------------------------------------------------------------------------
# v1.0 : Initial release. (7/13/2012)
#--------------------------------------------------------------------------
#   ++ Installation ++
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ++ Notetags ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Note: Some tags are given shorter tags for typing convenience. You only
#       need to use one <tag> from a given group for a notebox.
#
# The following Notetags are for Actors only:
#
# <homunculus item: id>
# <homun item: id>
#   This tag assigns to an actor a "homunculus item" where id is an item ID
#   number from the database. Homunculus items protect the actor from 
#   instant death effects (i.e. attempts to directly apply State ID 1,
#   "Death"). This will not affect damaging attacks that would
#   cause death. When a homunculus item successfully protects the actor,
#   one unit of the item is removed from the party's inventory. Each actor
#   can have a different homunculus item or even share the same one. This 
#   effect will only work if there is at least one homunculus item for the 
#   actor in the party's inventory.
#--------------------------------------------------------------------------
#   ++ Compatibility ++
#--------------------------------------------------------------------------
# This script aliases the following default VXA methods:
#
#     Game_ActionResult#clear
#     Window_BattleLog#display_critical
#     Game_Actor#setup
#     Game_Actor#add_state
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

#==========================================================================
# ++ START OF USER CUSTOMIZATION MODULE ++
#==========================================================================
module Bubs
  #==========================================================================
  # ++ Homunculus Item Settings
  #==========================================================================
  module HomunculusItem
  #--------------------------------------------------------------------------
  #   Disable Homunculus Item Switch ID Setting     !! IMPORTANT SETTING !!
  #--------------------------------------------------------------------------
  # This setting defines the switch ID number used to determine if 
  # homunculus items are allowed in battle. This is useful for evented 
  # battles and such. If the ID is set to 0, no game switch will be used.
  #
  # If the switch is ON, homunculus items are disabled.
  # If the switch is OFF, homunculus items are enabled.
  DISABLE_HOMUNCULUS_SWITCH_ID = 0
  #--------------------------------------------------------------------------
  #   Homunculus Battle Log Text
  #--------------------------------------------------------------------------
  # This setting determines how long HOMUNCULUS_TEXT stays seen
  # in the battle log. Higher values increase the time.
  #
  # %s is automatically replaced by the item's name.
  HOMUNCULUS_TEXT = "The %s sacrificed itself!"
  #--------------------------------------------------------------------------
  #   Homunculus Text Wait
  #--------------------------------------------------------------------------
  # This setting determines how long HOMUNCULUS_TEXT stays seen
  # in the battle log. Higher values increase the time.
  HOMUNCULUS_TEXT_WAIT = 3
  
  #--------------------------------------------------------------------------
  #   Homunculus Item Sound Effect
  #--------------------------------------------------------------------------
  # This setting defines the sound effect used when HOMUNCULUS_TEXT
  # is displayed in-battle.
  #                      "filename", Volume, Pitch
  HOMUNCULUS_TEXT_SE = ["Collapse3",     80,   120]
  
  end # module HomunculusItem
end # module Bubs

#==========================================================================
# ++ END OF USER CUSTOMIZATION MODULE ++
#==========================================================================



#==============================================================================
# ++ Sound
#==============================================================================
module Sound
  #--------------------------------------------------------------------------
  # new method : play_homunculus_item_break
  #--------------------------------------------------------------------------
  def self.play_homunculus_item_break
    filename = Bubs::HomunculusItem::HOMUNCULUS_TEXT_SE[0]
    volume = Bubs::HomunculusItem::HOMUNCULUS_TEXT_SE[1]
    pitch = Bubs::HomunculusItem::HOMUNCULUS_TEXT_SE[2]
    Audio.se_play("/Audio/SE/" + filename, volume, pitch) 
  end
end # module Sound


#==============================================================================
# ++ Window_BattleLog
#==============================================================================
class Game_ActionResult
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :homunculus_item_used        # homun used flag
  #--------------------------------------------------------------------------
  # alias : clear
  #--------------------------------------------------------------------------
  alias clear_bubs_homunculus_item clear
  def clear
    clear_bubs_homunculus_item # alias
    
    @homunculus_item_used = false
  end # def clear

end # class Game_ActionResult


#==============================================================================
# ++ Window_BattleLog
#==============================================================================
class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # alias : display_critical
  #--------------------------------------------------------------------------
  alias display_critical_bubs_homunculus_item display_critical
  def display_critical(target, item)
    display_homunculus_sacrifice(target, item) if target.result.used

    display_critical_bubs_homunculus_item(target, item) # alias    
  end # def display_critical

  #--------------------------------------------------------------------------
  # new method : display_homunculus_sacrifice
  #--------------------------------------------------------------------------
  def display_homunculus_sacrifice(target, item)
    if target.result.homunculus_item_used
      id = target.homunculus_item_id
      text = sprintf(Bubs::HomunculusItem::HOMUNCULUS_TEXT, $data_items[id].name)
      add_text(text)
      Sound.play_homunculus_item_break
      Bubs::HomunculusItem::HOMUNCULUS_TEXT_WAIT.times do; wait; end
      wait_for_effect
      back_one
    end
  end # def display_homunculus_sacrifice
end # class Window_BattleLog


#==============================================================================
# ++ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # new method : homunculus_item_conditions_met?
  #--------------------------------------------------------------------------
  def homunculus_item_conditions_met?(state_id)
    return false
  end
end # class Game_Battler


#==============================================================================
# ++ Game_Actor
#==============================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :homunculus_item_id   # item id
  #--------------------------------------------------------------------------
  # alias : setup
  #--------------------------------------------------------------------------
  alias setup_bubs_homunculus_item setup
  def setup(actor_id)
    setup_bubs_homunculus_item(actor_id) # alias
    
    @homunculus_item_id ||= homunculus_item_noteread
  end # def setup
  
  #--------------------------------------------------------------------------
  # new method : homunculus_item_noteread
  #--------------------------------------------------------------------------
  def homunculus_item_noteread
    actor.note =~ /<(?:HOMUNCULUS|HOMUN)[\s_]?ITEM:\s*(\d+)>/i ? $1.to_i : 0
  end # def homunculus_item_noteread
  
  #--------------------------------------------------------------------------
  # alias : add_state
  #--------------------------------------------------------------------------
  alias add_state_bubs_homunculus_item add_state
  def add_state(state_id)
    if homunculus_item_conditions_met?(state_id)
      use_homunculus_item
    else
      add_state_bubs_homunculus_item(state_id) # alias
    end
  end # def add_state
  
  #--------------------------------------------------------------------------
  # new method : homunculus_item_conditions_met?
  #--------------------------------------------------------------------------
  def homunculus_item_conditions_met?(state_id)
    return false if $game_switches[Bubs::HomunculusItem::DISABLE_HOMUNCULUS_SWITCH_ID]
    return false unless actor?
    return false unless state_id == death_state_id
    return false unless @hp > 0
    return false unless state_addable?(state_id)
    return false unless @homunculus_item_id > 0
    return false unless $game_party.has_item?($data_items[@homunculus_item_id])
    return true
  end # def homunculus_item_conditions_met?
  
  #--------------------------------------------------------------------------
  # new method : use_homunculus_item
  #--------------------------------------------------------------------------
  def use_homunculus_item
    $game_party.lose_item($data_items[@homunculus_item_id], 1)
    @result.homunculus_item_used = true
  end # def use_homunculus_item
  
end # class Game_Actor