##-----------------------------------------------------------------------------
#  Event Chase v2.0
#  Created by Neon Black
#  v2.0 - 2.11.2014 - Script updated for public release
#  v1.0 - 7.23.2012 - Main script completed
#  For both commercial and non-commercial use as long as credit is given to
#  Neon Black and any additional authors.  Licensed under Creative Commons
#  CC BY 4.0 - http://creativecommons.org/licenses/by/4.0/
##-----------------------------------------------------------------------------

##-----------------------------------------------------------------------------
#      Instructions:
#  Place this script in the "Materials" section of the scripts above main.
#  This script works by adding tags to comment boxes in pages of events.  Only
#  the tags on the current page will be used.  The following tags may be used:
#
#  sight<5>
#   - This tag is required to use any of the other tags because without it the
#     event will not chase the player at all.  Select a range for the line of
#     sight.  The event will the "see" the player as  long as the player is
#     no more than that many tiles away from the event.  It is worth noting
#     that events cannot see through objects that are not passable.
#  balloon<1>
#   - This balloon will pop up above the event's head when the player is
#     spotted.  0 defines the first balloon in the sheet.
#  chase<300>
#   - The number of frames the event will chase the player before returning to
#     an inactive state.  Remember that 60 frames = 1 second by default.
#  speed<3>
#   - The speed at which the event will chase the player.  This will only take
#     effect while the event is giving chase and will not directly override the
#     default speed.
#  switch<40>
#   - Activates a switch while the event is chasing the player.  When the event
#     returns to an inactive state the switch is turned off.
#  region<10>
#   - The region the player must be in for the event to give chase.  This tag
#     may appear more than once.
#  flee level<5>
#   - The average party level at which the event will flee from the player
#     rather than chasing them.  When the party's average level is greater than
#     this value, the event will flee.
#  flee variable<20:5>
#   - Causes the event to flee from the player while a variable is greater than
#     a specific value.  The first number is the variable to check while the
#     second number is the required value.
#  flee switch<6>
#   - This switch activates while the event is currently fleeing from the
#     player.
#  refresh chase
#   - This tag is a little different.  By default, an event's timer will count
#     down even while the event is chasing the player.  While this tag is
#     present, the event will continue to check if the player is in the line
#     of sight even while chasing the player, causing the timer to reset.
#
##------
#      Additional Uses:
#  In addition to the event tags, there are two other options you can do with
#  this script.  You can create a cloaking item that will prevent events from
#  chasing you while it is equipped and you can whistle to attract all events
#  that can chase on the map.
#
#  [cloak]
#   - When this tag is in the notebox of an item, the item will cause the
#     player to become invisible to events while the item is equipped to any
#     party member.
#  whistle
#   - This command is a SCRIPT CALL.  Use this from an event to cause all
#     events on the map to chase the player.
#  stop_chase
#   - This command is a SCRIPT CALL.  This is the opposite of "whistle" in
#     that it causes all events on the map to stop chasing the player.
#  cloaker(600)
#   - This command is a SCRIPT CALL.  This command causes the player to become
#     invisible to events with a line of sight for a certain number of frames.
#     Remember that 60 frames = 1 second by default.
###--------------------------------------------------------------------------###

module CP    # Do not edit
module CHASE # these lines.

##-----------------------------------------------------------------------------
#      Config:
#  This is the variable that stores information for the direction of the event
#  and the player when the event is activated.  Normally it will be set to 0,
#  however, if the player is facing the back of the event, it will be set to 1
#  and if the event is facing the back of the player, it will be set to -1.
#  Also, if the player approaches an event from the side a value of 2 is set
#  while if an event approaches the player from the side a value of -2 is set.
VARIABLE = 31
##-----------------------------------------------------------------------------

##-----------------------------------------------------------------------------
#  The following lines are the actual core code of the script.  While you are
#  certainly invited to look, modifying it may result in undesirable results.
#  Modify at your own risk!
##-----------------------------------------------------------------------------


end
end


$imported = {} if $imported == nil
$imported["CP_CHASE"] = 2.0

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
SFX = /SFX\<(.+):(\d+):(\d+)\>/i
CLOAK = /\[CLOAK\]/i

end
end

class Game_Party < Game_Unit
  def average_party_level  ## Checks the party's average level.
    return 0 if members.empty?
    value = members.inject(0) { |r, m| r += m.level }
    (value.to_f / members.size).ceil
  end
  
  def cloak_check  ## Checks all items for the cloak state.
    return true if members.empty?
    members.each do |actor|
      actor.equips.each do |equ|
        next if equ.nil? || !equ.cloak
        return true
      end
    end
    return false
  end
end

class Game_Map
  alias cp_stealth_update update
  def update(*args)
    cp_stealth_update(*args)
    @stealth_herb -= 1 if @stealth_herb
  end
  
  def events_start_chase  ## Makes all valid events chase.
    @events.each do |i, evnt|
      next unless evnt.is_a?(Game_Event)
      next if evnt.sight.nil? || evnt.sight <= 0
      evnt.do_spotted(false, true)
    end
  end
  
  def events_stop_chase
    @events.each do |i, evnt|
      next unless evnt.is_a?(Game_Event)
      next if evnt.sight.nil? || evnt.sight <= 0
      evnt.stop_spotted
    end
  end
  
  def stealth_field(val = 300)
    @stealth_herb = val
  end
  
  def stealth_herb?
    @stealth_herb = 0 unless @stealth_herb
    return @stealth_herb > 0
  end
end

class Game_Event < Game_Character
  attr_reader :sight
  
  alias cp_chase_setup_page setup_page_settings
  def setup_page_settings
    stop_spotted
    cp_chase_setup_page
    get_chase_control  ## Sets up event chasing.
  end
  
  def get_chase_control  ## Sets up all the event chasing variables.
    @bubble = nil; @switch = nil; @chase = nil; @flee = 999999; @cspeed = nil
    @flee_switch = nil; @flee_variable = nil; @csfx = nil; @region_check = []
    @refresh_chase = false
    @sight = 0 if @sight.nil?
    return if @list.nil? || @list.empty?
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
        @region_check.push($1.to_i)
      when CP::CHASE::SPEED
        @cspeed = $1.to_i
      when CP::CHASE::SFX
        @csfx = RPG::SE.new($1.to_s, $2.to_i, $3.to_i)
      end
    end
  end
  
  alias cp_chase_self_movement update_self_movement
  def update_self_movement  ## Changes movement if the player has been spotted.
    @spotted = false if @spotted.nil? || @erased
    if @spotted
      flee_player? ? move_away_from_player : move_toward_player
    else
      cp_chase_self_movement
    end
  end
  
  def flee_player?  ## Checks if the event is meant to flee the player.
    return level_over_flee || variable_over_flee
  end
  
  def level_over_flee  ## Checks for the flee level.
    return $game_party.average_party_level > @flee
  end
  
  def variable_over_flee  ## Checks for the flee variable.
    return false if @flee_variable.nil? || @flee_variable.empty?
    return $game_variables[@flee_variables[0]] > @flee_variables[1]
  end
  
  alias cp_chase_update update
  def update  ## Updates the chase timer.
    cp_chase_update
    return stop_spotted if @erased
    @chtimer = 0 if @chtimer.nil?
    @chtimer -= 1 if @chtimer > 0 && !@chase.nil?
    stop_spotted if @chtimer <= 0 && !@chase.nil?
    check_line_of_sight  ## Also checks line of sight.
    exit_region?
  end
  
  def exit_region?
    @spotted = false if @spotted.nil?
    return unless @spotted
    stop_spotted if !check_region_spot
  end
  
  def check_line_of_sight  ## Checks the event's line of sight.
    return if @sight.nil? || @sight <= 0
    @sight.times do |i|  ## Number of blocks to check.
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
    return true if @region_check.empty?
    return @region_check.include?($game_player.region_id)
  end
  
  def do_spotted(dummy = true, ovrd = false)
    unless ovrd  ## Override for whistle.
      return if @spotted && !@refresh_chase
      return if $game_party.cloak_check || $game_map.stealth_herb?
    end
    @balloon_id = @bubble unless @bubble.nil? || @spotted  ## Make balloon.
    @spotted = true  ## Set spotted.
    @old_speed = @move_speed if @old_speed.nil?  ## Alter the speed.
    @old_freq = @move_frequency if @old_freq.nil?  ## Alter the frequency.
    @move_speed = @cspeed if @cspeed
    @move_frequency = 5
    @chtimer = 1
    @chtimer = @chase if @chase  ## Set the timer.
    @csfx.play if @csfx
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
  
  alias cp_chase_locki lock
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
    $game_variables[var] = -1 if @direction == res &&
                                 $game_player.direction == res
    $game_variables[var] = -2 if @direction == res &&
                                 $game_player.direction != res &&
                                 $game_player.direction != ops
    $game_variables[var] = 1 if @direction == ops &&
                                $game_player.direction == ops
    $game_variables[var] = 2 if @direction != ops &&
                                @direction != res &&
                                $game_player.direction == ops
  end
end

class Game_Interpreter
  def whistle  ## Makes all valid events chase.
    $game_map.events_start_chase
  end
  
  def stop_chase
    $game_map.events_stop_chase
  end
  
  def cloaker(val = 300)
    $game_map.stealth_field(val)
  end
end

class RPG::EquipItem < RPG::BaseItem
  def cloak
    check_cloak if @cloak.nil?
    return @cloak
  end
  
  def check_cloak  ## Checks if an item is a cloaking device.
    @cloak = false
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when CP::CHASE::CLOAK
        @cloak = true
      end
    end
  end
end


##-----------------------------------------------------------------------------
#  End of script.
##-----------------------------------------------------------------------------