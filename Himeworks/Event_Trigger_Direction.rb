=begin
#===============================================================================
 Title: Event Trigger Direction
 Author: Hime
 Date: Oct 2, 2013
--------------------------------------------------------------------------------
 ** Change log
 Oct 2, 2013
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
 
 This script provides some script calls that you can use in your conditional
 branches to check which direction an event is being triggered from. For example
 you can check whether an event is triggered from the front or from behind, and
 set up each branch to behave appropriately.

--------------------------------------------------------------------------------
 ** Installation
 
 1. Open the script editor
 2. Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 The following methods are available.
 Assuming two characters A and B
 
   from_front?    - returns true if B faces towards A
   from_behind?   - returns true if B faces away from A
   from_left?     - returns true if A approaches B from the left
   from_right?    - returns true if A approaches B from the right
   from_side?     - returns true if A approaches B from behind
   
 Note that "left" and "right" depends on the character's direction
 
 Currently, this assumes A is the player and B is an event, so the "left" and
 "right" conditions are wrong if an event touches a player.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_EventTriggerDirection"] = true
#===============================================================================
# ** Rest of Script
#===============================================================================
class Game_CharacterBase
  attr_reader :prelock_direction
end

class Game_Interpreter
  
  #-----------------------------------------------------------------------------
  # Approach from behind. Both characters face the same direction
  #-----------------------------------------------------------------------------
  def from_behind?
    dir1 = get_character(-1).direction
    dir2 = get_character(@event_id).prelock_direction
    return dir1 == dir2
  end
  
  #-----------------------------------------------------------------------------
  # Approach from the front. Both characters face each other
  #-----------------------------------------------------------------------------
  def from_front?
    dir1 = get_character(-1).direction
    dir2 = get_character(@event_id).prelock_direction
    return dir1 == 10 - dir2
  end
  
  #-----------------------------------------------------------------------------
  # Approach from left or right
  #-----------------------------------------------------------------------------
  def from_side?
    dir1 = get_character(-1).direction
    dir2 = get_character(@event_id).prelock_direction
    diff = (dir1 - dir2).abs
    return diff == 2 || diff == 4
  end
  
  #-----------------------------------------------------------------------------
  # Approach from the left
  #-----------------------------------------------------------------------------
  def from_left?
    dir1 = get_character(-1).direction
    dir2 = get_character(@event_id).prelock_direction
    return ((10 - dir1) * 2) % 10 == dir2
  end
  
  #-----------------------------------------------------------------------------
  # Approach from the right
  #-----------------------------------------------------------------------------
  def from_right?
    dir1 = get_character(-1).direction
    dir2 = get_character(@event_id).prelock_direction
    return (dir1 * 2) % 10 == dir2
  end
end