#==============================================================================
#    Map Transfer Common Event
#    Version: 1.0.0
#    Author: modern algebra (rmrk.net)
#    Date: 9 October 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    
#    This script lets you instantly run a specified common event when exiting
#   or entering a map. This is useful, for instance, for when you want to
#   instantly change the tone when transferring to a different map, or really
#   for any other change that you want to take place instantly. The event will
#   only be run once.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials.
#
#    All you need to do to set this script up is place one or both of the
#   following codes into the note box of a map:
#
#      \EXIT_CE[0]
#      \ENTER_CE[0]
#
#    Obviously, the EXIT_CE will run when leaving the map, while the ENTER_CE 
#   will run when entering the map. Replace the 0 with the ID of the common 
#   event which you want to run in that circumstance.
#
#    Please note that this ignores any switch condition on the common event, so 
#   it should not be used to call parallel process or autorun common events
#   directly. Also, the player will not be able to move while the event is
#   running, so you should not put many wait frames in the event. If you need
#   wait frames, then the recommended option would be to make a parallel
#   process event or common event, and if necessary you can turn on the switch
#   with a common event called by this script.
#==============================================================================

$imported = {} unless $imported
$imported[:MA_MapTransferCommonEvent] = true

#==============================================================================
# ** Game_Map
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - setup
#==============================================================================

class Game_Map
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mamtce_setup_9qg8 setup
  def setup(map_id, *args)
    if @map_id != map_id
      old_ce_id = $game_temp.common_event_id
      mamtce_run_instant_common_event(mamtce_out_common_event_id)
      mamtce_setup_9qg8(map_id, *args) # Call original method
      mamtce_run_instant_common_event(mamtce_in_common_event_id)
      $game_temp.reserve_common_event(old_ce_id) if old_ce_id > 0
    else
      mamtce_setup_9qg8(map_id, *args) # Call original method
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Transfer Common Event IDs
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def mamtce_in_common_event_id
    @map ? @map.note[/(?<=\\ENTER[_ ]CE\[)\s*\d+\s*(?=\])/i].to_i : 0
  end
  def mamtce_out_common_event_id
    @map ? @map.note[/(?<=\\EXIT[_ ]CE\[)\s*\d+\s*(?=\])/i].to_i : 0
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Instant Run Common Event
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def mamtce_run_instant_common_event(ce_id)
    return unless ce_id > 0
    $game_temp.reserve_common_event(ce_id)
    @interpreter.setup_reserved_common_event
    @interpreter.update
  end
end