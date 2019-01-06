#Field Abilities v1.1
#----------#
#Features: I have no idea what to call this. But this script adds jumping,
#           throwing, and grabbing options. Now you can drag things around,
#           throw pots and jump over gorges! The possibilities!
#
#Usage:    Plug and play, customize as needed.
#           Jumping:
#            Pressing the jump button causes the hero to jump forward two
#            spaces. Will not jump onto unpassable tiles, or on and through
#            tiles with the NO_JUMP_REGION. Can be disabled with a switch.
#      
#           Throwing:
#            Script call: pickup
#            Events that call pickup will be picked up by the hero. Upon pressing
#            the confirm button the event will be thrown 2 spaces ahead unless
#            it's an unpassable tile or on and through tiles with the
#            NO_JUMP_REGION. Thrown events have their D self switch activated
#            to allow for an event page to run after being thrown.
#            (Events can pick up other events with the script call:
#             pick_up(event_id) - but only during a set move route.
#             and can be thrown with:
#             throw - again only during a set move route.)
#
#           Grabbing:
#            Script call: grab
#            Events that call grab will be grabbed by the hero. The hero can
#            only move forward or backward, and stops grabbing once the confirm
#            button is released.
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#- Free to use in any project with credit given, donations always welcome!
 
#The button to be used for jumping:
JUMP_KEY = :SHIFT
#The region that you can use to define no jump areas
NO_JUMP_REGIONS = [10,11]
#The Toggle Jump Switch, jumping is not allowed when this switch is on
TOGGLE_JUMP_SWITCH = 100
#Events containing this string in their name will allow player to jump over them
JUMP_EVENT_STRING = "BG"
 
class Game_Character < Game_CharacterBase
  attr_accessor :carried
  attr_accessor :through
  attr_accessor :priority_type
  attr_accessor :x
  attr_accessor :y
  attr_accessor :direction
  attr_accessor :direction_fix
  attr_accessor :move_succeed
  alias env_screen_y screen_y
  alias env_screen_x screen_x
  def pick_up(event_id)
    @carrying = event_id
    @carrying = $game_map.events[event_id] if $game_map.events[event_id]
    @carrying.through = true
    @carrying.carried = self
    @carrying.priority_type = 2
  end
  def throw
    @carrying.moveto(@x,@y)
    @carrying.direction = @direction
    return unless @carrying.jump_forward_field
    @carrying.thrown
    @carrying.through = false
    @carrying.priority_type = 1
    @carrying.carried = nil
    @carrying = nil
  end
  def screen_y
    @carried ? @carried.screen_y - 24 : env_screen_y
  end
  def screen_x
    @carried ? @carried.screen_x : env_screen_x
  end
  def can_jump?(x,y)
    return false if NO_JUMP_REGIONS.include?($game_map.region_id(@x+x/2,@y+y/2))
    return false if NO_JUMP_REGIONS.include?($game_map.region_id(@x+x,@y+y))
    map_passable?(@x+x,@y+y,@direction) && !collide_with_characters?(@x+x,@y+y) &&
      !sp_cwc(@x+x/2,@y+y/2)
  end
  def sp_cwc(x, y)
    $game_map.events_xy_nt(x, y).any? do |event|
      next if event.name.include?(JUMP_EVENT_STRING)
      event.normal_priority? || self.is_a?(Game_Event)
    end
  end
  def jump_forward_field
    return jump_straight(0,2)  if @direction == 2
    return jump_straight(-2,0) if @direction == 4
    return jump_straight(2,0)  if @direction == 6
    return jump_straight(0,-2) if @direction == 8
  end
  def jump_straight(x,y)
    return false if jumping?
    if can_jump?(x,y)
      jump(x,y)
      return true
    else
      jump(0,0)
      return false
    end
  end
  def thrown
  end
end
 
class Game_Player < Game_Character
  alias throw_cae check_action_event
  alias throw_ms move_straight
  alias throw_update update
  def update
    throw_update
    if !Input.press?(:C) && @grabbed
      @grabbed = nil
      @direction_fix = false
      @move_speed += 1
    @move_frequency += 1
    end
  end
  def move_by_input
    allow = !$game_switches[TOGGLE_JUMP_SWITCH]
    return jump_forward_field if Input.trigger?(JUMP_KEY) && !@grabbed && allow
    return if !movable? || $game_map.interpreter.running?
    return if jumping?
    move_straight(Input.dir4) if Input.dir4 > 0
  end
  def check_action_event
    if @carrying
      throw
      return true
    end
    throw_cae
  end
  def grab(event_id)
    @grabbed = $game_map.events[event_id]
    @move_speed -= 1
    @move_frequency -= 1
    @grabbed.move_speed = @move_speed
    @grabbed.move_frequency = @move_frequency
    @direction_fix = true
  end
  def move_straight(d, tok = true)
    return throw_ms(d, tok) if @grabbed.nil?
    return unless @direction == d || @direction == (d-10).abs
    if @direction == d
      @grabbed.move_straight(d,tok)
      throw_ms(d, tok) if @grabbed.move_succeed
    elsif @direction == (d-10).abs
      throw_ms(d,tok)
      @grabbed.move_straight(d,tok) if @move_succeed
    end
  end
end
 
class Game_Event < Game_Character
  attr_accessor  :move_speed    
  attr_accessor  :move_frequency
  def thrown
    super
    $game_self_switches[[@map_id, @id, "D"]] = true
  end
  def update
    super
    check_event_trigger_auto
    return unless @interpreter
    @interpreter.setup(@list, @event.id) unless @interpreter.running?
    @interpreter.update unless jumping?
  end
  def name
    @event.name
  end
end
 
class Game_Interpreter
  def pickup
    $game_player.pick_up(@event_id)
  end
  def grab
    $game_player.grab(@event_id)
  end
end