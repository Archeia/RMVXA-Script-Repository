=begin
#===============================================================================
 Title: Idle Party Conditions
 Author: Hime
 Date: Oct 11, 2013
--------------------------------------------------------------------------------
 ** Change log
 Oct 11, 2013
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
 
 This script provides a set of methods for conditional branch checking
 involving parties.

--------------------------------------------------------------------------------
 ** Required 

 Idle Party Events
 (http://himeworks.com/2013/10/11/idle-party-events/)
 
--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Party Manager and above Main

--------------------------------------------------------------------------------
 ** Usage 
  
 The following methods are available:
 
   party_here?(party_id, x, y)
   
     *returns true if the specified party is at (x,y)
   
   parties_here?(party_ids, x, y)
     
     *same as above, except it takes an array of party IDs. If none is 
      specified, then it checks if any party is at (x,y)
   
 If you don't specify an (x, y) position, then it is assumed to be the current
 event's position. This is useful if you want the check to be relative to
 an event's position rather than absolute map position.
 
--------------------------------------------------------------------------------
 ** Example
 
 To check if party 2 is at (3, 5), you would use the script call
 
   party_here?(2, 3, 5)
   
 Assuming an event at (3, 3) wants to know if party 2 is standing on it, have
 that event use the script call
 
   party_here?(2)
   
 To check if either party 1 or party 2 is at (5,6),
 
   parties_here?([1,2], 5, 6)
    
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_IdlePartyConditions"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Idle_Party_Conditions
    Regex = /<idle[-_ ]party[-_ ]id:\s*(\d+)\s*>/i
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
class Game_Interpreter
  
  #-----------------------------------------------------------------------------
  # Returns true if the specified party at the given (x,y) position. If no
  # position is specified, then it assumes the calling event's position
  #-----------------------------------------------------------------------------
  def party_here?(party_id, x=$game_map.events[@event_id].x, y=$game_map.events[@event_id].y)
    return unless $game_parties[party_id] 
    loc = $game_parties[party_id].location
    return loc.x == x && loc.y == y
  end
  
  #-----------------------------------------------------------------------------
  # Returns true if there are any parties at the given (x,y) position. If no
  # position is specified, then it assumes the calling event's position
  #-----------------------------------------------------------------------------
  def parties_here?(party_ids=[], x=$game_map.events[@event_id].x, y=$game_map.events[@event_id].y)
    if party_ids.empty?
      parties = $game_parties
    else
      parties = party_ids.collect {|id| $game_parties[id] }
    end
    parties.any? {|party|
      loc = party.location
      loc.x == x && loc.y == y
    }
  end
end