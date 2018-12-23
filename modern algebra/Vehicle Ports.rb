#==============================================================================
#    Vehicle Ports
#    Version: 1.0.0
#    Author: modern algebra (rmrk.net)
#    Date: 29 December 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    
#    This script allows you to set it so that boats, ships, and airships, can
#   only land in particular regions that you designate as ports for that type
#   of vehicle. This allows you to, for instance, prevent ships from landing
#   anywhere except at a dock, or boats from landing anywhere but on beaches or
#   docks. It also works for airships, if you want to restrict the places that
#   they can land.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials.
#
#    Beyond that, the only thing you need to do is go to the editable region at
#   line 36 and input the IDs of any port regions into the array for each
#   vehicle. By default, boats can land in regions 32 and 40, while ships can
#   only land in region 40. Airship landing is unrestricted by default. You can
#   change those values in the editable region.
#
#    Once that is done, all you need to do to make a port is paint that tile
#   with the port region for that vehicle.
#==============================================================================

$imported = {} unless $imported
$imported[:MA_VehiclePorts] = true

MAVP_PORT_REGIONS = {
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#    BEGIN Editable Region
#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#  For each array, input the IDs of the regions in which the vehicle can land,
# separated by commas. If left empty, then that vehicle's landing locations are
# unrestricted and they can land no matter what the region.
  boat:    [32, 40], # IDs of regions in which a boat can land
  ship:    [40],     # IDs of regions in which a ship can land
  airship: [],       # IDs of regions in which an airship can land
#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#    END Editable Region
#//////////////////////////////////////////////////////////////////////////////
}
MAVP_PORT_REGIONS.default = []

#==============================================================================
# ** Game_Vehicle
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - land_ok?
#==============================================================================

class Game_Vehicle
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Determine if Docking/Landing Is Possible
  #     d:  Direction (2,4,6,8)
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mavp_landok_1up3 land_ok?
  def land_ok?(x, y, d, *args)
    unless MAVP_PORT_REGIONS[@type].empty? # Unless no port required
      if @type == :airship
        return false unless MAVP_PORT_REGIONS[@type].include?( $game_map.region_id(x, y) )
      else
        x2 = $game_map.round_x_with_direction(x, d)
        y2 = $game_map.round_y_with_direction(y, d)
        return false unless MAVP_PORT_REGIONS[@type].include?( $game_map.region_id(x2, y2) )
      end
    end
    mavp_landok_1up3(x, y, d, *args) # Call original method
  end
end