#==============================================================================
#    Boat/Ship Passability for Events
#    Version: 1.0
#    Author: modern algebra (rmrk.net)
#    Date: December 29, 2011
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This script simply allows you to set it so that specified events can have
#   the passability of a boat or a ship.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    Paste this script above Main and below Materials.
#
#    To set it so that an event has boat or ship passability, just create a 
#   comment on the first line of the event page and include in it one of the 
#   following codes:
#
#      \boat
#      \ship
#
#    As you could guess, if you use the \boat code, the event will have the 
#   passability of a boat, and if you use the \ship code, the event will have
#   the passability of a ship.
#==============================================================================

$imported = {} unless $imported
$imported[:MA_BoatShipPassability] = true

#==============================================================================
# ** Game_Event
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - setup_page; map_passable?
#    new method - ma_set_boatship_passability
#==============================================================================

class Game_Event
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup Page Settings
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mabspe_stppageseting_3gs7 setup_page_settings
  def setup_page_settings(*args, &block)
    mabspe_stppageseting_3gs7(*args, &block) # Run Original Method
    ma_set_boatship_passability
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set MABSPE Passability
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def ma_set_boatship_passability
    @mabspe_passability, i = nil, 0
    # Check Initial Comments
    while !@list[i].nil? && (@list[i].code == 108 || @list[i].code == 408)
      if @list[i].parameters[0][/\\(BOAT|SHIP)/i]
        @mabspe_passability = $1.downcase.to_sym
        break
      end
      i += 1
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Map Passable?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mabspe_mppassale_5vs4 map_passable?
  def map_passable?(x, y, *args, &block)
    case @mabspe_passability
    when :boat then $game_map.boat_passable?(x, y)
    when :ship then $game_map.ship_passable?(x, y)
    else
      mabspe_mppassale_5vs4(x, y, *args, &block) # Run Original Method
    end
  end
end