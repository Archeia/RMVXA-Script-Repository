#===============================================================================
# More Self-Switches (VX Ace Edition)
# Version 1.0
# Author game_guy
#-------------------------------------------------------------------------------
# Intro:
# Ever need more than 4 self switches? With this small script, you can now
# have as many self switches you want. You aren't just limited to letters
# either. You can have names for them.
#
# Features:
# -More Self Switches
# -Name them whatever
#
# Instructions:
# -First, lets create a self switch for our event. Anywhere in the event, add
# a comment and type this,
# Switch:switch_name.
# switch_name can be whatever you want to name the switch. Thats all you have
# to do to create a self switch for that page.
# There cannot be any spaces between the colon and the switch name.
# e.g. Switch: switch - Does not work.
# e.g. Switch:switch - Does work.
#
# -Now to turn this switch of or on, call this in a script call.
# self_switch("switch", true/false)
# switch is the switch name, this must be in double " " or single ' ' quotes.
# true/false tells the script whether to turn it off or on. true = on, 
# false = off.
#
# -If you want to see if a self switch is on/off, use this script in a
# condtional branch.
# self_switch_state("switch") == true/false
# switch is the switch name, this must be in double " " or single ' ' quotes.
# true = on, false = off
#
# Compatibility:
# Should work with anything.
#
# Credits:
# game_guy ~ For creating it.
#===============================================================================

class Game_Event < Game_Character
  alias gg_init_more_switches_lat initialize
  def initialize(map_id, event)
    gg_init_more_switches_lat(map_id, event)
    @event.pages.each {|page| page.list.each {|command|
      if [108, 408].include?(command.code)
        command.parameters.each {|p| check_custom_switch(page, p) }
      end}}
    refresh
  end
  def check_custom_switch(page, code)
    a = code.split(':')
    if !a[0].nil? && a[0].downcase == "switch" && a[1] != nil
      page.condition.self_switch_ch = a[1]  
      page.condition.self_switch_valid = true
    end
  end
end

class Game_Interpreter
  def self_switch(switch, state)
    if @event_id > 0
      key = [$game_map.map_id, @event_id, switch]
      $game_self_switches[key] = state
    end
    $game_map.need_refresh = true
  end
  def self_switch_state(switch)
    key = [$game_map.map_id, @event_id, switch]
    return $game_self_switches[key]
  end
end