=begin
#===============================================================================
 Title: Event Followers
 Author: Hime
 Date: Feb 19, 2015
--------------------------------------------------------------------------------
 ** Change log
 Fev 19, 2015
   - event followers also move diagonally
 Mar 31, 2014
   - moving behind leader had the y-positions mixed up
 Jan 9, 2014
   - fixed bug where adding a follower to a leader was following the last
     follower of the leader, not the leader itself
 Jul 31, 2013
   - added new following logic for more accurate following
 Jul 25, 2013
   - fixed bug where event follower speed wasn't updated to leader's speed
 Mar 29, 2013
   - Events following the player will now follow the last follower
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script allows events to designate a "leader" that another character will
 follow. This could be the player, the current event, or any other event.
 
 Any characters following a leader will follow that leader.
--------------------------------------------------------------------------------
 ** Installation
 
 Place this below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 The following method calls are available to Game_Character objects.
 
    follow(event_id)
    stop_follow
    
 This can be called by any character object such as players or events.
 If you make a script call and say
 
    follow(event_id)
    
 Then the event specified by the move route will follow that character.
 You can also say things like
 
    $game_player.follow(event_id)
    $game_map.events[3].follow(event_id)

 If the event_id is -1, then the character will follow the player.
 otherwise, it will follow the specified event on the current map.
 
 To stop following a character, make the script call
 
    stop_follow
    
 Again, remember from whose perspective the script call is being made from. 
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_EventFollowers"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Event_Followers
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
class Game_Character < Game_CharacterBase
  
  attr_reader :event_followers
  
  alias :th_event_followers_init_public_members :init_public_members
  def init_public_members
    th_event_followers_init_public_members
    @event_followers = Game_EventFollowers.new(self)
    @leader = nil
  end
  
  alias :th_event_followers_move_straight :move_straight
  def move_straight(d, turn_ok = true)
    @event_followers.move if passable?(@x, @y, d)
    th_event_followers_move_straight(d, turn_ok)
  end
  
  alias :th_event_followers_update :update
  def update
    th_event_followers_update
    update_following if following?
  end

  #-----------------------------------------------------------------------------
  # New
  #-----------------------------------------------------------------------------
  def update_following
    @move_speed = @leader.real_move_speed
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def following?
    !@leader.nil?
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def last_follower
    return @event_followers[-1] if @event_followers.size > 0
    return self
  end
  
  #-----------------------------------------------------------------------------
  # New. Backup this character's original settings
  #-----------------------------------------------------------------------------
  def store_original_settings
    @old_through = @through
    @old_move_speed = @move_speed
    @old_real_move_speed = @real_move_speed
    @old_transparent = @transparent
    @old_walk_anime = @walk_anime
    @old_step_anime = @step_anime
    @old_direction_fix = @direction_fix
    @old_opacity = @opacity
    @old_blend_type = @blend_type
  end
  
  #-----------------------------------------------------------------------------
  # New. Once we stop following another character, revert all original settings
  #-----------------------------------------------------------------------------
  def revert_original_settings
    @through = @old_through
    @move_speed = @old_move_speed
    @real_move_speed = @old_real_move_speed
    @transparent = @old_transparent
    @walk_anime = @old_walk_anime
    @step_anime = @old_step_anime
    @direction_fix = @old_direction_fix
    @opacity = @old_opacity
    @blend_type = @old_blend_type
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def get_follow_leader(event_id)
    # -1 is assumed to be the player
    if event_id < 0
      $game_player
    else
      $game_map.events[event_id]
    end
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def chase_preceding_character
    unless moving?
      sx = distance_x_from(@preceding_character.x)
      sy = distance_y_from(@preceding_character.y)      
      if sx != 0 && sy != 0
        move_diagonal(sx > 0 ? 4 : 6, sy > 0 ? 8 : 2)
      elsif sx != 0
        move_straight(sx > 0 ? 4 : 6)
      elsif sy != 0
        move_straight(sy > 0 ? 8 : 2)
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def move_behind_leader
    x = @leader.x
    y = @leader.y
    
    case @leader.direction
    when 2
      y += 1
    when 4
      x += 1
    when 6
      x -= 1
    when 8
      y -= 1
    end
    x = [[1, x].max, $game_map.width-1].min
    y = [[1, y].max, $game_map.height-1].min
    moveto(x, y)
  end
  
  #-----------------------------------------------------------------------------
  # New. Begin following the specified event.
  #-----------------------------------------------------------------------------
  def follow(event_id)
    return if following?
    @leader = get_follow_leader(event_id)
    @preceding_character = @leader.last_follower
    @leader.add_event_follower(self)
    move_behind_leader
    store_original_settings
    @move_speed     = @leader.move_speed
    @transparent    = @leader.transparent
    @walk_anime     = @leader.walk_anime
    @step_anime     = @leader.step_anime
    @direction_fix  = @leader.direction_fix
    @opacity        = @leader.opacity
    @blend_type     = @leader.blend_type
    @through = true
  end
  
  #-----------------------------------------------------------------------------
  # New. Stop following a leader
  #-----------------------------------------------------------------------------
  def stop_follow
    @through = false
    @leader.remove_event_follower(self)
    @preceding_character = nil
    @leader = nil
    revert_original_settings
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def add_event_follower(char)
    @event_followers.add(char)
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def remove_event_follower(char)
    @event_followers.remove(char)
  end
  
  alias :th_event_followers_move_diagonal :move_diagonal
  def move_diagonal(horz, vert)
    @event_followers.move if diagonal_passable?(@x, @y, horz, vert)
    th_event_followers_move_diagonal(horz, vert)
  end
end

class Game_Event < Game_Character
  
  #-----------------------------------------------------------------------------
  # Ignore autonomous movement if following leader
  #-----------------------------------------------------------------------------
  alias :th_event_followers_update_self_movement :update_self_movement 
  def update_self_movement
    return if following?
    th_event_followers_update_self_movement
  end
end

class Game_Player < Game_Character
  
  #-----------------------------------------------------------------------------
  # New. Since player happens to have different types of followers we have to
  # check
  #-----------------------------------------------------------------------------
  def last_follower
    return super if @event_followers.size > 0
    follower_size = $game_player.followers.visible_folloers.size
    return @followers[follower_size - 1] if follower_size > 0
    return self
  end
  
  #-----------------------------------------------------------------------------
  # Ignore player movement input if following leader
  #-----------------------------------------------------------------------------
  alias :th_event_followers_movable? :movable?
  def movable?
    return false if following?
    th_event_followers_movable?
  end
  
  alias :th_event_followers_dash? :dash?
  def dash?
    return false if following?
    th_event_followers_dash?
  end
end

#-------------------------------------------------------------------------------
# Similar to player followers, except instead of pulling data from the party
# members it simply holds references to existing events
#-------------------------------------------------------------------------------
class Game_EventFollowers < Game_Followers
  include Enumerable
  
  def initialize(leader)
    @data = []
  end
  
  def size
    @data.size
  end
  
  def index(char)
    @data.index(char)
  end
  
  def add(character)
    @data.push(character)
  end
  
  def remove(character)
    @data.delete(character)
  end  
end