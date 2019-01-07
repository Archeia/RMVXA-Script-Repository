=begin
#===============================================================================
 Title: Message Skip
 Author: Hime
 Date: Jul 21, 2013
--------------------------------------------------------------------------------
 ** Change log
 Jul 21, 2013
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
 
 This script allows you to skip messages (fast-forward) by holding down the
 CTRL key.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 You can choose which key will be used as the skip key.
 
 You can enable or disable message skipping by assigning a disable switch.
 When the disable switch is ON, players cannot skip messages.
--------------------------------------------------------------------------------
 ** Compatibility
 
 This script overwrites the following methods
 
   Window_Message
     input_pause
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_MessageSkip"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Message_Skip
    
    # Switch to use to prevent message skipping
    Disable_Switch = 0
    
    # Key to hold to skip messages
    Skip_Key = :CTRL
    
    # Use "auto skip" mode. When the skip mode is OFF, you need to hold the
    # skip key to fast-forward messages. When the skip mode is ON, you just
    # need to press it once to begin skipping, and press it again to stop
    # skipping
    Auto_Skip = false
    
    # Ignore delays when skipping.
    Skip_Delays = false
    # Ignore pauses when skipping
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
class Window_Message < Window_Base
    
  def skip_key
    TH::Message_Skip::Skip_Key
  end
  
  def skip_key_pressed?
    !$game_switches[TH::Message_Skip::Disable_Switch] && Input.press?(skip_key)
  end
  
  #-----------------------------------------------------------------------------
  # Overwrite. Actually all you really need is that extra line of code to tell
  # the fiber to resume
  #-----------------------------------------------------------------------------
  def input_pause
    self.pause = true
    wait(10)
    Fiber.yield until Input.trigger?(:B) || Input.trigger?(:C) || skip_key_pressed?
    Input.update
    self.pause = false
  end
  
  alias :th_skip_message_wait :wait
  def wait(duration)
    return if TH::Message_Skip::Skip_Delays && skip_key_pressed?
    th_skip_message_wait(duration)
  end
end