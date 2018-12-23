#==============================================================================
#    Stopped Actor Stepping Animation
#    Version: 1.0
#    Author: modern algebra (rmrk.net)
#    Date: April 26, 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    
#    This script allows you to set actors who will have a stepping animation 
#   when controlled as the player or on the map as a follower. It is useful for
#   characters like flying actors who need to have a stepping animation even
#   when stopped.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials.
#
#    All that you need to do is specify which actors should have a stepping
#   animation by placing the following code in an actor's notebox:
#
#        \Step
#==============================================================================

$imported ||= {}
$imported[:"MA_ActorStepping_1.0"] = true

#==============================================================================
# ** Game_Actor
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new attr_writer - maas_step_anime=
#    new method - maas_step_anime
#==============================================================================

class Game_Actor
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_writer :maas_step_anime
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Step Animation?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maas_step_anime
    @maas_step_anime = !actor.note[/\\STEP/i].nil? if !@maas_step_anime
    @maas_step_anime
  end
end

#==============================================================================
# ** Game_Player
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - refresh
#==============================================================================

class Game_Player
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Refresh
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maas_refresh_3jv8 refresh
  def refresh(*args, &block)
    maas_refresh_3jv8(*args, &block) # Call Original Method
    @step_anime = actor ? actor.maas_step_anime : false
  end
end

#==============================================================================
# ** Game_Follower
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - update_anime_count
#==============================================================================

class Game_Follower
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Animation Count
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maas_updatanimcnt_4vx9 update_anime_count
  def update_anime_count(*args, &block)
    @step_anime = actor ? actor.maas_step_anime : false
    maas_updatanimcnt_4vx9(*args, &block) # Call Original Method
  end
end