=begin
#===============================================================================
 Title: Count-up Clock
 Author: Hime
 Date: Sep 11, 2013
--------------------------------------------------------------------------------
 ** Change log
 Sep 11, 2013
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
 
 This script allows you to set the timer to count up instead of count down.

--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 Make the script call before you start the timer

   $game_timer.count_up
   
 To have it count up from 0 to the time you have set. 
 When you want to count down, make the script call
 
   $game_timer.count_down
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_CountUpClock"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Count_Up_Clock
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
class Game_Timer
  
  alias :th_countup_timer_initialize :initialize
  def initialize
    th_countup_timer_initialize
    @count_mode = :down
    @end_count = 0
  end
  
  alias :th_countup_timer_start :start
  def start(count)
    if @count_mode == :up
      @end_count = count
      @working = true
    else
      th_countup_timer_start
    end
  end
  
  alias :th_countup_timer_update :update
  def update
    if @count_mode == :up
      if @working && @count < @end_count
        @count += 1
      else
        on_expire
      end
    else
      th_countup_timer_update
    end
  end
  
  #-----------------------------------------------------------------------------
  # Changes the count mode for this clock
  #-----------------------------------------------------------------------------
  def set_count_mode(mode)
    @count_mode = mode.to_sym
  end
  
  def count_up
    @count_mode = :up
  end
  
  def count_down
    @count_mode = :down
  end
end