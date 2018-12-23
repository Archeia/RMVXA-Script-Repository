#==============================================================================
#    Lock Actor in Formation
#    Version: 1.0.0
#    Author: modern algebra (rmrk.net)
#    Date: 2 February 2013
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    
#    This script allows you to lock an actor in their position in the party
#   and prevents the player from moving the actor around. It can be useful
#   for times when you want to ensure that a particular actor is in the active
#   party, such as the main character.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials.
#
#    An icon will show up on a locked actor's status to indicate that he or
#   she is locked and cannot be moved through the Formation command. To specify
#   which icon is shown and where, go to the editable region beginning at line
#   68. If you don't want any icon shown, set the index to 0.
#
#    This script is operated through commands called through an evented Script
#   command. The two operative codes are:
#
#        lock_actor_formation(actor_id)
#        unlock_actor_formation(actor_id)
#
#   Where: actor_id is replaced with the ID of the Actor you want to lock.
#   The lock command prevents the player from manually adjusting the position
#   of the actor in the party, while the unlock command permits reverses that
#   and once again allows the player to adjust the actor's position. Neither
#   code works unless the actor is in the party.
#
#    Additionally, if you want to specify that the actor be moved to a
#   particular index before locking him or her (for instance, to ensure that
#   he or she is in the active party), you can do that by specifying the index
#   you want him or her moved to right after the ID, like so:
#
#        lock_actor_formation(actor_id, index)
#------------------------------------------------------------------------------
#    EXAMPLES:
#
#        lock_actor_formation(4)
#            # Actor 4 is locked in his or her current position in the party
#
#        lock_actor_formation(1, 0)
#            # Actor 1 is locked in as leader of the party
#
#        unlock_actor_formation(9)
#            # Actor 9 is unlocked
#==============================================================================

$imported = {} unless $imported
$imported[:MA_LockActorInFormation] = true

#==============================================================================
# *** MALAF_Window_DrawFormIcon
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This module mixes in to Window_MenuStatus to draw a formation icon. It is
# drawn this way to (hopefully) maximize compatibility with menu scripts that
# change the menu status window. It will only work if the different status
# window operates in substantially the same way, however.
#==============================================================================

module MALAF_Window_DrawFormIcon
  #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  #    BEGIN Editable Region
  #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  LOCK_ICON_INDEX = 242 # Index of icon shown when actor is locked.
  LOCK_ICON_X = 328     # Icon's X-coordinate - added to the item_rect's x
  LOCK_ICON_Y = 0       # Icon's Y-coordinate - added to the item_rect's y
  #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #    END Editable Region
  #//////////////////////////////////////////////////////////////////////////
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_accessor :malaf_formation_select # Boolean checking whether formation
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Item
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_item(index, *args)
    super(index, *args)                              # Call original method
    actor = $game_party.members[index]               # Get Actor
    rect = item_rect(index)                          # Get Position
    malaf_draw_formation_icon(actor, rect.x, rect.y) # Draw Formation Status
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Formation Icon
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def malaf_draw_formation_icon(actor, x, y)
    draw_icon(LOCK_ICON_INDEX, x + LOCK_ICON_X, y + LOCK_ICON_Y) if actor.formation_locked
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Current Item Enabled?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def current_item_enabled?(*args)
    if @malaf_formation_select
      actor = $game_party.members[index]
      return false if actor && actor.formation_locked
    end
    super(*args)
  end
end

#==============================================================================
# ** Game_Actor
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - setup
#    new attr_accessor - formation_locked
#==============================================================================

class Game_Actor
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_accessor :formation_locked # Boolean discerning whether actor locked
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias malaf_setup_4hn6 setup
  def setup(*args, &block)
    @formation_locked = false
    malaf_setup_4hn6(*args, &block) # Call Original Method
  end
end

#==============================================================================
# ** Game_Party
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new method - malaf_insert_actor
#==============================================================================

class Game_Party
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Insert Actor in Formation
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def malaf_insert_actor(actor_id, new_index)
    if @actors.include?(actor_id)
      @actors.delete(actor_id)
      new_index = @actors.size - 1 if new_index >= @actors.size
      @actors.insert(new_index, actor_id)
      $game_player.refresh
    end
  end
end

#==============================================================================
# ** Game_Interpreter
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new methods - lock_actor_formation; unlock_actor_formation
#==============================================================================

class Game_Interpreter
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Formation Lock
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def lock_actor_formation(actor_id, index = nil)
    $game_actors[actor_id].formation_locked = true
    $game_party.malaf_insert_actor(actor_id, index) if index.is_a?(Integer)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Formation Lock
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def unlock_actor_formation(actor_id, index = nil)
    $game_actors[actor_id].formation_locked = false
    $game_party.malaf_insert_actor(actor_id, index) if index.is_a?(Integer)
  end
end

#==============================================================================
# ** Scene_Menu
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - on_formation_ok
#==============================================================================

class Scene_Menu
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Status Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias malaf_creatstatswin_3mb5 create_status_window
  def create_status_window(*args)
    malaf_creatstatswin_3mb5(*args) # Call original method
    if @status_window
      @status_window.extend(MALAF_Window_DrawFormIcon) # Mix in module
      @status_window.refresh
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * [Formation] Command
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias malaf_commndformt_5vc4 command_formation
  def command_formation
    @status_window.malaf_formation_select = true if @status_window
    malaf_commndformt_5vc4
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Cancel Formation Select
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias malaf_onfrmtncanc_8zz4 on_formation_cancel
  def on_formation_cancel(*args)
    malaf_onfrmtncanc_8zz4(*args) # Call original method
    @status_window.malaf_formation_select = false if @status_window && @status_window.index == -1
  end
end