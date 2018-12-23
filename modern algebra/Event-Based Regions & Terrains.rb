#==============================================================================
#    Event-Based Regions & Terrains
#    Version: 1.0.0
#    Author: modern algebra (rmrk.net)
#    Date: 23 April 2014
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This script allows you to assign a region ID and/or terrain tag to any
#   event. When this is done, any tile upon which that event steps will inherit
#   that region ID and/or terrain tag for as long as the event is present on
#   it. If more than one event with this feature is on the same tile, then it
#   will have the region ID or terrain tag which is highest.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    Insert this script into its own slot in the Script Editor, below Materials
#   but still above Main.
#
#    In order to assign a region ID to an event, create a comment in the first
#   event command of the page and use the following code:
#
#      \region[x]
#
#   Replace x with any integer from 1-63.
#
#    In order to assign a terrain tag to an event, make a comment the first
#   event command of the page and use the following code:
#
#      \terrain[x]
#
#   Replace x with any integer from 0-7, or higher if using a script that
#   permits that.
#
#    The region ID and terrain tag will apply only for the page in which they
#   are created. Once a new page is active, they will revert.
#==============================================================================

$imported = {} unless $imported
$imported[:MA_EventBasedRegions] = true

#==============================================================================
# ** Game_Map
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - terrain_tag; region_id
#    new method - get_event_region
#==============================================================================

class Game_Map
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Terrain Tag
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maebr_terntag_7uj2 terrain_tag
  def terrain_tag(x, y, *args, &block)
    event_tt = maebr_event_var(x, y, :maebr_terrain_tag)
    return event_tt if event_tt > 0
    maebr_terntag_7uj2(x, y, *args, &block) # Call Original Method
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Region ID
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maebr_reginid_5sr9 region_id
  def region_id(x, y, *args, &block)
    event_rid = maebr_event_var(x, y, :maebr_region_id)
    return event_rid if event_rid > 0
    maebr_reginid_5sr9(x, y, *args, &block) # Call Original Method
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get Event-Based Variable for Region ID or Terrain Tag
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maebr_event_var(x, y, var)
    ([0] + events_xy(x,y).collect { |event| event.send(var) }).max
  end
end

#==============================================================================
# ** Game_Event
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new public instance variables - maebr_region_id; maebr_terrain_tag
#    aliased methods - init_public_members; setup_page_settings; 
#      clear_page_settings
#==============================================================================

class Game_Event
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_accessor(:maebr_region_id, :maebr_terrain_tag)
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Initialize Public Members
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maebr_inizpublcmems_8bn3 init_public_members
  def init_public_members(*args, &block)
    maebr_inizpublcmems_8bn3(*args, &block) # Call Original Method
    @maebr_region_id = 0
    @maebr_terrain_tag = 0
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Clear Event Page Settings
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maebr_clrpagesets_3vw4 clear_page_settings
  def clear_page_settings(*args, &block)
    maebr_clrpagesets_3vw4(*args, &block) # Call Original Method
    @maebr_region_id = 0
    @maebr_terrain_tag = 0
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Up Event Page Settings
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maebr_setppagttings_4cu6 setup_page_settings
  def setup_page_settings(*args, &block) # Call Original Method
    maebr_setppagttings_4cu6(*args, &block)
    # Collect first Comment
    first_comment, i = "", 0
    while !@list[i].nil? && (@list[i].code == 108 || @list[i].code == 408)
      first_comment += @list[i].parameters[0] + "\n"
      i += 1
    end
    @maebr_region_id = first_comment[/\\REGION\s*\[\s*(\d+)\s*\]/im] ? $1.to_i : 0
    @maebr_terrain_tag = first_comment[/\\TERRAIN\s*\[\s*(\d+)\s*\]/im] ? $1.to_i : 0
  end
end