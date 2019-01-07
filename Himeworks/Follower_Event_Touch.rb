=begin
#===============================================================================
 Title: Follower Event Touch
 Author: Hime
 Date: Jan 9, 2014
 URL: http://himeworks.com/2013/08/24/follower-event-touch/
--------------------------------------------------------------------------------
 ** Change log
 Jan 9, 2014
   - added support for "Event Followers"
 Aug 24, 2013
   - initial release
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
 
 This script makes it so that if an "event touch" event comes into contact
 with a follower in your party, the event will be executed.

--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 If you are using Event Followers, place this script below it
 
--------------------------------------------------------------------------------
 ** Usage
 
 Plug and play.
 
 To disable this functionality, simply turn on the switch that you specify
 in the configuration.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_FollowerEventTouch"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Follower_Event_Touch
    
    # Turn this ON to disable follower event touch
    Disable_Switch = 0
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
class Game_System
  
  def follower_event_touch_disabled?
    $game_switches[TH::Follower_Event_Touch::Disable_Switch]
  end
end

class Game_Player < Game_Character
  
  alias :th_follower_event_touch_pos? :pos?
  def pos?(x, y)
    th_follower_event_touch_pos?(x, y) || follower_pos?(x, y)
  end
  
  def follower_pos?(x, y)
    return false if $game_system.follower_event_touch_disabled?
    @followers.visible_folloers.any? {|follower| follower.pos?(x, y)}
  end
end
#===============================================================================
# Apply to event followers as well
#===============================================================================
if $imported["TH_EventFollowers"]
  
  class Game_Player < Game_Character
    alias :th_event_followers_touch_follower_pos? :follower_pos?
    def follower_pos?(x, y)
      return true if th_event_followers_touch_follower_pos?(x, y)
      @event_followers.any? {|follower| follower.pos?(x, y)}
    end
  end
end