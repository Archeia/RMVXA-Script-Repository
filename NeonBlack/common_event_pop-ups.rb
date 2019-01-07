##----------------------------------------------------------------------------##
## Common Event Pop-ups
## Created by Neon Black
##
## For both commercial and non-commercial use as long as credit is given to
## Neon Black and any additional authors.  Licensed under Creative Commons
## CC BY 3.0 - http://creativecommons.org/licenses/by/3.0/.
##----------------------------------------------------------------------------##
                                                                              ##
##----------------------------------------------------------------------------##
##    Revision Info:
## v1.0 - 3.13.2013
##  Wrote and debugged main script
##----------------------------------------------------------------------------##
                                                                              ##
$imported ||= {}                                                              ##
$imported["CP_EVENT_POP"] = 1.0                                               ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Instructions:
## Place this script in the script editor below "Materials" and above "Main".
## This script allows a common event to be called whenever an item or gold is
## obtained or lost from an event.  The value/amount and name of the item are
## stored in variables so they can be referenced by a message.  The script can
## also be enabled/disabled with a switch.
##----------------------------------------------------------------------------##
                                                                              ##
module CP  # Do not touch                                                     ##
module CEP #  these lines.                                                    ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Config:
## The config options are below.  You can set these depending on the flavour of
## your game.  Each option is explained in a bit more detail above it.
##
##------
# These are the variables used to store the icon/name of an item as well as the
# amount of the item/gold gained or lost.  These values cannot be nil.
Item = 1
Value = 2

# These are the common events to play when an item/gold is gained or lost.  You
# can set these to nil if you do not want one to be played.  You can also have
# multiple with the same value, for example, having the same event for items,
# weapons, and armour.
GoldCE = 1
ItemCE = 2
WeaponCE = 2
ArmorCE = 2

# This is the switch to enable/disable the script.  While the switch is on, the
# events will play.  While it is off the events will not play.
Switch = 1
##----------------------------------------------------------------------------##
                                                                              ##
                                                                              ##
##----------------------------------------------------------------------------##
## The following lines are the actual core code of the script.  While you are
## certainly invited to look, modifying it may result in undesirable results.
## Modify at your own risk!
###----------------------------------------------------------------------------


end
end

class Game_Interpreter
  alias :cp_42313_125 :command_125
  alias :cp_42313_126 :command_126
  alias :cp_42313_127 :command_127
  alias :cp_42313_128 :command_128
  
  def command_125
    cp_42313_125
    value = operate_value(@params[0], @params[1], @params[2])
    $game_variables[CP::CEP::Value] = value
    common_event_pop(CP::CEP::GoldCE)
  end
  
  def command_126
    cp_42313_126
    value = operate_value(@params[1], @params[2], @params[3])
    item = $data_items[@params[0]]
    $game_variables[CP::CEP::Item] = "\eI[#{item.icon_index}]#{item.name}"
    $game_variables[CP::CEP::Value] = value
    common_event_pop(CP::CEP::ItemCE)
  end
  
  def command_127
    cp_42313_127
    value = operate_value(@params[1], @params[2], @params[3])
    item = $data_weapons[@params[0]]
    $game_variables[CP::CEP::Item] = "\eI[#{item.icon_index}]#{item.name}"
    $game_variables[CP::CEP::Value] = value
    common_event_pop(CP::CEP::WeaponCE)
  end
  
  def command_128
    cp_42313_128
    value = operate_value(@params[1], @params[2], @params[3])
    item = $data_armors[@params[0]]
    $game_variables[CP::CEP::Item] = "\eI[#{item.icon_index}]#{item.name}"
    $game_variables[CP::CEP::Value] = value
    common_event_pop(CP::CEP::ArmorCE)
  end
  
  def common_event_pop(ce)
    return unless ce && $game_switches[CP::CEP::Switch]
    @params[0] = ce
    command_117
  end
end


###----------------------------------------------------------------------------
#  End of script.
###----------------------------------------------------------------------------