###--------------------------------------------------------------------------###
#  Event Chase script                                                          #
#  Version 1.0c                                                                #
#                                                                              #
#      Credits:                                                                #
#  Original code by: Neonblack                                                 #
#  Modified by: Archeia, Yami, Diedrupo                                        #
#                                                                              #
#  This work is licensed under the Creative Commons Attribution-NonCommercial  #
#  3.0 Unported License. To view a copy of this license, visit                 #
#  http://creativecommons.org/licenses/by-nc/3.0/.                             #
#  Permissions beyond the scope of this license are available at               #
#  http://cphouseset.wordpress.com/liscense-and-terms-of-use/.                 #
#                                                                              #
#      Contact:                                                                #
#  NeonBlack - neonblack23@live.com (e-mail) or "neonblack23" on skype         #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Revision information:                                                   #
#  V1.0 - 7.23.2012                                                            #
#   Wrote and debugged main script                                             #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Compatibility:                                                          #
#  Alias       - Game_Event: setup_page_settings, update_self_movement,        #
#                            update, lock                                      #
#                Game_Map: update                                              #
#                DataManager: load_database                                    #
#  New Methods - Game_Party: average_party_level, cloak_check                  #
#                Game_Map: stealth_field, stealth_herb?                        #
#                Game_Event: get_chase_control, flee_player?,                  #
#                            level_over_flee, variable_over_flee,              #
#                            check_line_of_sight, cp_passable?, sighted?,      #
#                            do_spotted, stop_spotted, exit_region?,           #
#                            check_region_spot, check_both_ev_dir              #
#                Game_Interpreter: whistle, stop_chase, cloaker                #
#                RPG::EquipItem: check_cloak                                   #
#                DataManager: make_item_cloaks                                 #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Instructions:                                                           #
#  Place this script in the "Materials" section of the scripts above main.     #
#  This script works by adding tags to comment boxes in pages of events.       #
#  Only the tags on the current page will be used.  The following tags may be  #
#  used:                                                                       #
#                                                                              #
#   sight<x> - This is required to use any of the other tags or to cause the   #
#              event to chase the player at all.  Replace "x" with the events  #
#              range of sight.  The event uses line of sight and will not be   #
#              able to see through objects.  Note that the event will chase    #
#              followers as well as the player.                                #
#   balloon<x> - The balloon to pop up above the head of the event when it     #
#                starts to chase the player.  Replace "x" with the number of   #
#                the balloon to use.                                           #
#   chase<x> - The number of frames the event chases the player before         #
#              returning to it's default state.  Replace "x" with a number.    #
#              Remember that 60 frames = 1 second.                             #
#   speed<x> - The speed the event chases the player at.  Replace "x" with a   #
#              number.                                                         #
#   switch<x> - While chasing the player, this switch is turned on.  When the  #
#               event stops chasing the player, this switch is turned off.     #
#               Replace "x" with the switch number.                            #
#   region<x> - The player must be in a certain region for the event to chase  #
#               it.  Replace "x" with a region ID.                             #
#   flee level<x> - The average party level at which the event starts to flee  #
#                   rather than chase the player.  Replace "x" with the        #
#                   average level.  When the party's average level is higher,  #
#                   the event will flee.                                       #
#   flee variable<x:y> - Set a variable to cause the event to flee.  Set "x"   #
#                        to a variable number and "y" to a value.  While the   #
#                        variable is greater than the value, the event will    #
#                        flee from the player.                                 #
#   flee switch<x> - This switch is turned on while the event is fleeing the   #
#                    player.  Replace "x" with the switch number.              #
#   refresh chase - Normally the timer for chasing will count down while the   #
#                   event is chasing the player and will not reset until it    #
#                   has reached 0.  With this, the timer will reset as long    #
#                   as the event keeps the player in it's line of sight.       #
#                                                                              #
###-----                                                                -----###
#      Additional Uses:                                                        #
#  In addition to the event tags, there are two other options you can do with  #
#  this script.  You can create a cloaking item that will prevent events from  #
#  chasing you while it is equipped and you can whistle to attract all events  #
#  that can chase on the map.                                                  #
#                                                                              #
#   [cloak] - Place this tag exactly as it is (with the brackets) in the       #
#             notebox of an item and while the item is equipped events will    #
#             not chase you when you enter their line of sight.                #
#                                                                              #
#   whistle - Use this script call in an event to cause all events on the      #
#             current map to begin chasing you.  You can create a whistle      #
#             skill or item by placing a script call with this in a common     #
#             event and using the event outside of battle.                     #
#   stop_chase - The exact opposite of whistle.  This causes all events to     #
#                stop chasing the player.                                      #
#   cloaker(x) - Use this script call in an event to cause the player to       #
#                become invisible to events for a certain number of frames.    #
#                Replace "x" with the number of frames to be cloaked for.      #
#                Remember that 60 frames = 1 second.                           #
###--------------------------------------------------------------------------###

module CP    # Do not edit
module CHASE # these lines.

###--------------------------------------------------------------------------###
#      Config:                                                                 #
# This is the variable that stores information for the direction of the event  #
# and the player when the event is activated.  Normally it will be set to 0,   #
# however, if the player is facing the back of the event, it will be set to 1  #
# and if the event is facing the back of the player, it will be set to -1.     #
# Also, if the player approaches an event from the side a value of 2 is set    #
# while if an event approaches the player from the side a value of -2 is set.  #
VARIABLE = 31 # Default = 31                                                   #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#  The following lines are the actual core code of the script.  While you are  #
#  certainly invited to look, modifying it may result in undesirable results.  #
#  Modify at your own risk!                                                    #
###--------------------------------------------------------------------------###


end
end


$imported = {} if $imported == nil
$imported["CP_CHASE"] = 1.0

module CP
module CHASE  ## Sets up the REGEXPs.

BUBBLE = /BALLOON\<(\d+)\>/i
SWITCH = /SWITCH\<(\d+)\>/i
SIGHT = /SIGHT\<(\d+)\>/i
CHASE = /CHASE\<(\d+)\>/i
FLEE = /FLEE[ ]LEVEL\<(\d+)\>/i
FLEESW = /FLEE[ ]SWITCH\<(\d+)\>/i
FLEEVA = /FLEE[ ]VARIABLE\<(\d+):(\d+)\>/i
REFRESH = /REFRESH[ ]CHASE/i
SPEED = /SPEED\<(\d+)\>/i
REGION = /REGION\<(\d+)\>/i
SFX = /SFX\<([\w\d\s]+):(\d+):(\d+)\>/i
CLOAK = /\[CLOAK\]/i

end
end

class Game_Party < Game_Unit
  def average_party_level  ## Checks the party's average level.
    return 0 if members.size == 0
    lvls = 0
    members.each do |actor|
      lvls += actor.level
    end
    lvls = lvls.to_f / members.size.to_f 
    return lvls
  end
  
  def cloak_check  ## Checks all items for the cloak state.
    return true if members.size == 0
    cloaked = false
    members.each do |actor|
      actor.equips.each do |equ|
        next if equ.nil?
        cloaked = true if equ.cloak
      end
    end
    return cloaked
  end
end

class Game_Map
  alias cp_stealth_update update unless $@
  def update(*args)
    cp_stealth_update(*args)
    return if @stealth_herb.nil?
    @stealth_herb -= 1
  end
  
  def stealth_field(val = 300)
    @stealth_herb = val
  end
  
  def stealth_herb?
    return false if @stealth_herb.nil?
    return true if @stealth_herb > 0
    return false
  end
end

class Game_Event < Game_Character
  attr_reader :sight
  
  alias cp_chase_setup_page setup_page_settings unless $@
  def setup_page_settings
    stop_spotted
    cp_chase_setup_page
    get_chase_control  ## Sets up event chasing.
  end
  
  def get_chase_control  ## Sets up all the event chasing variables.
    @bubble = nil; @switch = nil; @chase = nil; @flee = nil; @cspeed = nil
    @flee_switch = nil; @flee_variable = nil; @sfx = nil; @region_check = nil
    @refresh_chase = false
    @sight = 0 if @sight.nil?
    return if (@list.nil? || @list.empty?)
    @list.each do |line|  ## Looks for comments with the lines.
      next unless (line.code == 108 || line.code == 408)
      case line.parameters[0]
      when CP::CHASE::BUBBLE
        @bubble = $1.to_i
      when CP::CHASE::SWITCH
        @switch = $1.to_i
      when CP::CHASE::SIGHT
        @sight = $1.to_i
      when CP::CHASE::CHASE
        @chase = $1.to_i
      when CP::CHASE::FLEE
        @flee = $1.to_i
      when CP::CHASE::FLEESW
        @flee_switch = $1.to_i
      when CP::CHASE::FLEEVA
        @flee_variable = []
        @flee_variable[0] = $1.to_i
        @flee_variable[1] = $2.to_i
      when CP::CHASE::REFRESH
        @refresh_chase = true
      when CP::CHASE::REGION
        @region_check = $1.to_i
      when CP::CHASE::SPEED
        @cspeed = $1.to_i
      end
    end
  end
  
  alias cp_chase_self_movement update_self_movement unless $@
  def update_self_movement  ## Changes movement if the player has been spotted.
    @spotted = false if @spotted.nil?
    @spotted = false if @erased # Yami
    if @spotted
      if flee_player?
        move_away_from_player
      else
        move_toward_player
      end
    else
      cp_chase_self_movement
    end
  end
  
  def flee_player?  ## Checks if the event is meant to flee the player.
    return true if level_over_flee
    return true if variable_over_flee
    return false
  end
  
  def level_over_flee  ## Checks for the flee level.
    return false if @flee.nil?
    return true if $game_party.average_party_level > @flee
    return false
  end
  
  def variable_over_flee  ## Checks for the flee variable.
    return false if @flee_variable.nil?
    return false if @flee_variable.empty?
    return true if $game_variables[@flee_variables[0]] > @flee_variables[1]
    return false
  end
  
  alias cp_chase_update update unless $@
  def update  ## Updates the chase timer.
    cp_chase_update
    return stop_spotted if @erased # Yami
    @chtimer = 0 if @chtimer.nil?
    @chtimer -= 1 if (@chtimer > 0 && !@chase.nil?)
    stop_spotted if (@chtimer <= 0 && !@chase.nil?)
    check_line_of_sight  ## Also checks line of sight.
    exit_region?
  end
  
  def exit_region?
    @spotted = false if @spotted.nil?
    return unless @spotted
    stop_spotted if !check_region_spot
  end
  
  def check_line_of_sight  ## Checks the event's line of sight.
    return if (@sight.nil? || @sight == 0)
    for i in 0...@sight  ## Number of blocks to check.
      xc = @x
      yc = @y
      case @direction  ## Alters the checked block based on direction.
      when 2; yc += i
      when 4; xc -= i
      when 6; xc += i
      when 8; yc -= i
      end
      break unless cp_passable?(xc, yc, @direction)  ## Checks for obstacles.
      do_spotted if sighted?(xc, yc, @direction)  ## Finds the player.
    end
  end
  
  def cp_passable?(x, y, d)  ## Obstacle check.  Events do not count.
    x2 = $game_map.round_x_with_direction(x, d)
    y2 = $game_map.round_y_with_direction(y, d)
    return false unless $game_map.valid?(x2, y2)
    return false unless map_passable?(x, y, d)
    return false unless map_passable?(x2, y2, reverse_dir(d))
    return true
  end
  
  def sighted?(x, y, d)  ## Checks for the player.
    x2 = $game_map.round_x_with_direction(x, d)
    y2 = $game_map.round_y_with_direction(y, d)
    return check_region_spot if collide_with_characters?(x2, y2)
    return false
  end
  
  def check_region_spot
    return true if @region_check.nil?
    return true if $game_player.region_id == @region_check
    return false
  end
  
  def do_spotted(dummy = true, ovrd = false)
    unless ovrd  ## Override for whistle.
      return if (@spotted && !@refresh_chase)
      return if $game_party.cloak_check  ## Return if cloaked.
      return if $game_map.stealth_herb?
    end
    @balloon_id = @bubble unless (@bubble.nil? || @spotted)  ## Make balloon.
    @spotted = true  ## Set spotted.
    @old_speed = @move_speed if @old_speed.nil?  ## Alter the speed.
    @old_freq = @move_frequency if @old_freq.nil?  ## Alter the frequency.
    @move_speed = @cspeed unless @cspeed.nil?
    @move_frequency = 5
    @chtimer = 1
    @chtimer = @chase unless @chase.nil?  ## Set the timer.
    $game_switches[@switch] = true unless @switch.nil?  ## Set switches.
    $game_switches[@flee_switch] = true unless @flee_switch.nil?
  end
  
  def stop_spotted
    @spotted = false  ## Turn off the spotted.
    @move_speed = @old_speed unless @old_speed.nil?  ## Reset speed.
    @move_frequency = @old_freq unless @old_freq.nil?  ## Reset frequency.
    @old_speed = nil
    @old_freq = nil
    @chtimer = 0  ## Reset timer.
    $game_switches[@switch] = false unless @switch.nil?  ## Reset switches.
    $game_switches[@flee_switch] = false unless @flee_switch.nil?
  end
  
  alias cp_chase_locki lock unless $@
  def lock
    check_both_ev_dir
    cp_chase_locki
  end
  
  def check_both_ev_dir
    sx = distance_x_from($game_player.x)
    sy = distance_y_from($game_player.y)
    if sx.abs > sy.abs
      res = sx > 0 ? 4 : 6
      ops = sx > 0 ? 6 : 4
    elsif sy != 0
      res = sy > 0 ? 8 : 2
      ops = sy > 0 ? 2 : 8
    else
      res = 0; ops = 0
    end
    var = CP::CHASE::VARIABLE
    $game_variables[var] = 0
    $game_variables[var] = -1 if (@direction == res &&
                                  $game_player.direction == res)
    $game_variables[var] = -2 if (@direction == res &&
                                  $game_player.direction != res &&
                                  $game_player.direction != ops)
    $game_variables[var] = 1 if (@direction == ops &&
                                 $game_player.direction == ops)
    $game_variables[var] = 2 if (@direction != ops &&
                                 @direction != res &&
                                 $game_player.direction == ops)
  end
end

class Game_Interpreter
  def whistle  ## Makes all valid events chase.
    $game_map.events.each do |i, evnt|
      next unless evnt.is_a?(Game_Event)
      next if evnt.sight.nil?
      next if evnt.sight == 0
      evnt.do_spotted(false, true)
    end
  end
  
  def stop_chase
    $game_map.events.each do |i, evnt|
      next unless evnt.is_a?(Game_Event)
      next if evnt.sight.nil?
      next if evnt.sight == 0
      evnt.stop_spotted
    end
  end
  
  def cloaker(val = 300)
    $game_map.stealth_field(val)
  end
end

class RPG::EquipItem < RPG::BaseItem
  attr_reader :cloak
  
  def check_cloak  ## Checks if an item is a cloaking device.
    return if @cloaker; @cloaker = true
    @cloak = false
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when CP::CHASE::CLOAK
        @cloak = true
      end
    end
  end
end

module DataManager
  class << self
    
  alias cp_chase_load_database load_database unless $@
  def load_database
    cp_chase_load_database
    make_item_cloaks
  end

  def make_item_cloaks
    groups = [$data_weapons, $data_armors]
    for group in groups
      for obj in group
        next if obj == nil
        obj.check_cloak if obj.is_a?(RPG::EquipItem)
      end
    end
  end
  
  end
end


###--------------------------------------------------------------------------###
#  End of script.                                                              #
###--------------------------------------------------------------------------###