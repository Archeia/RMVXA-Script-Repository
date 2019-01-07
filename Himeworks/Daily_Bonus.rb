=begin
#===============================================================================
 Title: Daily Bonus
 Author: Hime
 Date: Feb 17, 2016
 URL: http://www.himeworks.com/2014/03/17/daily-bonus/
--------------------------------------------------------------------------------
 ** Change log
 Feb 17, 2016
   - added support for "next" reward time
 Mar 17, 2014
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
 
 This script provides a simple "daily bonus" mechanic, allowing players to
 receive bonus rewards once a day. It assumes that you can get a bonus on a
 new day, but you can write your conditions to use different periods if you
 want.
 
 It is intended for offline games and uses the player's system time to reward
 bonuses and to determine whether rewards can be rewarded.
 
 In order to provide developers with more control over the rewards, script calls
 are provided. It is up to the developer to determine how to set it up for
 their game.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 The following script calls are provided.
 
    daily_bonus_available?
    
 This checks whether you are eligible for login bonuses, based on the current
 day.
 
 When a bonus has been redeemed, you may want to update when the next bonus
 can be drawn using this script call:
 
    update_bonus_time(seconds)
    
 Keep in mind that these are specified in seconds.  If no time is
 specified, it is assumed to be one day, which is 86400 seconds
 
 If "daily bonus" is not suitable, you can get the last reward time or the
 next reward time directly
    
   last_reward_time
   next_reward_time
   
 Which returns a Time object. You can then use this to check against the current
 time.
 
--------------------------------------------------------------------------------
 ** Example
 
 Suppose you decided to create an event that serves as the reward NPC.
 Use a variable to determine how many times you have received rewards.
 
 You would have a conditional branch that checks whether login bonuses are
 available. If so, you would then go through a series of variable checks to
 determine which reward to give them.
 
 Finally, you would call `update_bonus_time` to log the actual reward.
 
--------------------------------------------------------------------------------
 ** Notes
 
 A simple day-difference computation is used to determine the difference
 between the last reward claim day and the current day.
 
 This does not correctly account for daylight savings.
 
 Players can simply change their system time forward if they want to get rewards
 faster if they wanted to.
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_DailyBonus] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Daily_Bonus

  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
class Game_System
  
  attr_reader :last_reward_time
  attr_reader :next_reward_time
  
  alias :th_daily_bonus_initialize :initialize
  def initialize
    th_daily_bonus_initialize
    @last_reward_time = Time.at(0)
    @next_reward_time = Time.at(0)
  end
  
  #-----------------------------------------------------------------------------
  # Simple checks
  #-----------------------------------------------------------------------------
  def daily_bonus_available?
    current_time = Time.now
    return current_time > @next_reward_time    
  end

  def update_bonus_time(seconds)
    @last_reward_time = Time.now
    @next_reward_time = Time.now + seconds
  end
end

class Game_Interpreter
  
  def daily_bonus_available?
    $game_system.daily_bonus_available?
  end
  
  # add bonus time in seconds (default one day 60 x 60 x 24)
  def update_bonus_time(seconds=86400)
    $game_system.update_bonus_time(seconds)
  end
  
  def last_reward_time
    $game_system.last_reward_time
  end
  
  def next_reward_time
    $game_system.next_reward_time
  end
end