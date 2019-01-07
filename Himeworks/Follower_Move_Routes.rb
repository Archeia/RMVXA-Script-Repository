=begin
#===============================================================================
 Title: Follower Move Routes
 Author: Tsukihime
 Date: Dec 29, 2014
 URL: http://himeworks.com/2013/12/07/follower-move-routes/
--------------------------------------------------------------------------------
 ** Change log
 Dec 29, 2014
   - improved compatibility with scripts that manipulate event command lists
 Feb 26, 2014
   - fixed bug where follower move routes weren't working if leader chase is off
 Feb 22, 2014
   - added support for enabling/disabling leader chasing
 Feb 13, 2014
   - added support for common events
 Jan 9, 2014
   - added a "sync_leader" method that allows you to sync or un-sync 
     follower properties from the leader.
 Dec 23, 2013
   - Does not affect the default "player" designation
 Dec 7, 2013
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Tsukihime in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to set move routes for your followers using events.
 The intention was to make it easier for your to create your cut-scenes,
 designating a move route for a particular follower in your party.
 
 In addition to simple move routes, you can also change the "follower sync"
 settings. By default, followers have the same properties as the leader, such
 as move speed or blend type. You can unsync followers from the leader so that
 they can move at their own speeds and determine their own properties.
 
--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 

 To set the move route for a follower, first create a comment with the line
 
   <move character: x>
   
 Where x is a negative number representing a member of the party.
 -1 is the leader, -2 is the follower behind the leader, etc.
 
 Then create a "set move route" command as usual. The move route will
 automatically be applied to the specified follower.
 
   -- Follower Sync Settings --
   
 To turn on leader sync'ing, in a follower move route, make the script call
 
   sync_to_leader
   
 To turn it off, make the script call in a follower move route

   unsync_from_leader
   
  -- Leader Chasing --
  
 By default, followers will chase after the person they are following.
 If you would like to disable this, make the script call
 
   chase_leader(true)  - enable leader chasing
   chase_leader(false) - disable leader chasing
   
 So for example if you want your followers to stop following the leader,
 you would create a follower move route for the second member and disable
 leader chasing. 
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_FollowerMoveRoutes] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Follower_Move_Routes
    
    Regex = /<move[-_ ]character:\s*(-?\d+)\s*>/i
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  class Event::Page
    
    alias :th_follower_move_routes_list :list
    def list
      parse_follower_move_routes
      th_follower_move_routes_list
    end
    
    def parse_follower_move_routes
      @list.size.times do |i|
        cmd = @list[i]
        if cmd.code == 108 && cmd.parameters[0] =~ TH::Follower_Move_Routes::Regex
          next_cmd = @list[i+1]
          next_cmd.parameters[0] = $1.to_i if next_cmd && next_cmd.code == 205
        end
      end
    end
  end
  
  class CommonEvent
    
    alias :th_follower_move_routes_list :list
    def list
      parse_follower_move_routes unless @follower_move_routes_parsed
      th_follower_move_routes_list
    end
    
    def parse_follower_move_routes
      @follower_move_routes_parsed = true
      @list.size.times do |i|
        cmd = @list[i]
        if cmd.code == 108 && cmd.parameters[0] =~ TH::Follower_Move_Routes::Regex
          next_cmd = @list[i+1]
          next_cmd.parameters[0] = $1.to_i if next_cmd && next_cmd.code == 205
        end
      end
    end
  end
end

class Game_Character < Game_CharacterBase
  
  attr_reader :sync_leader
  
  alias :th_follower_move_routes_init_private_members :init_private_members
  def init_private_members
    th_follower_move_routes_init_private_members
    @sync_leader = true
    @chase_leader = true
  end
  
  def chase_leader(bool)
    @chase_leader = bool
  end
  
  def chase_leader?
    @chase_leader
  end
  
  def sync_to_leader
    @sync_leader = true
  end
  
  def unsync_from_leader
    @sync_leader = false
  end
end

class Game_Follower < Game_Character
  
  alias :th_follower_move_routes_update :update
  def update
    if @sync_leader
      th_follower_move_routes_update
    else
      super
    end
  end
  
  alias :th_follower_move_routes_chase_preceding_character :chase_preceding_character
  def chase_preceding_character
    if !@chase_leader
      return
    end
    th_follower_move_routes_chase_preceding_character
  end
end

class Game_Interpreter
  
  alias :th_follower_move_routes_get_character :get_character
  def get_character(param)
    if !$game_party.in_battle && param < -1
      return $game_player.followers[param.abs-2]
    end
    th_follower_move_routes_get_character(param)
  end
end