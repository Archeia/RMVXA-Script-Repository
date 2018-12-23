#==============================================================================
#    Call Scene from Items & Skills
#    Version: 1.0
#    Author: modern algebra (rmrk.net)
#    Date: February 5, 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This script allows you to call a scene directly after using an item or 
#   skill. While it is always available simply to call a common event and call
#   the scene from that, this script allows it to happen directly without going
#   back to the map, so that when the scene is exited, it goes straight back to
#   the scene that called it.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    Paste this script into its own slot in the Script Editor, above Main but 
#   below Materials.
#
#    To have an item or skill call a scene, just place the following code into
#   its notebox:
#
#      \scene[Scene_Name]
#
#    Where Scene_Name is the name of the scene you want to call. For example, 
#   if you wanted to call the Debug scene, you would put there:
#
#     \scene[Scene_Debug]
#
#    Note that this script does not work in battle. If you want to call a scene
#   from battle, do it with a common event.
#
#    Note that if you set an item to call a scene like this, then any common
#   event assigned to the item will be prevented from running (if in the menu).
#   If in battle, on the other hand, this script is inoperative and so the 
#   common event will be run.
#==============================================================================

$imported ||= {}
$imported[:MA_CallSceneFromItemsAndSkills] = true

#==============================================================================
# ** RPG::UsableItem
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new method - csis_call_scene
#==============================================================================

class RPG::UsableItem
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Call Scene
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def csis_call_scene
    if !@csis_call_scene
      @csis_call_scene = false
      if self.note[/\\SCENE\[\s*(\w+)\s*\]/i]
        sym = $1.to_sym
        @csis_call_scene = sym if Kernel.const_defined?(sym)
      end
    end
    @csis_call_scene
  end
end

#==============================================================================
# ** Game_Actor
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - item_has_any_valid_effects?
#==============================================================================

class Game_Actor
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Item Has Any Valid Effects?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias macsis_itmvalideffects_3kc5 item_has_any_valid_effects?
  def item_has_any_valid_effects?(user, item, *args, &block)
    result = macsis_itmvalideffects_3kc5(user, item, *args, &block)
    (result || (SceneManager.scene.is_a?(Scene_ItemBase) && item.csis_call_scene))
  end
end

#==============================================================================
# ** Scene_ItemBase
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - use_item_to_actors; return_scene
#    new method - csis_call_scene
#==============================================================================

class Scene_ItemBase
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Use Item to Actors
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias macsis_useitmactors_3ej5 use_item_to_actors
  def use_item_to_actors(*args, &block)
    macsis_useitmactors_3ej5(*args, &block) # Call Original Method
    csis_call_scene if item.csis_call_scene
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Return Scene
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias macsis_retrnscene_2wj6 return_scene
  def return_scene(*args, &block)
    # Restore Menu Actor
    $game_party.menu_actor = @csis_real_menu_actor if @csis_real_menu_actor
    macsis_retrnscene_2wj6(*args, &block)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * CSM Call Scene
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def csis_call_scene
    # If item is targetted, change the menu actor in case matters for scene
    @csis_real_menu_actor = $game_party.menu_actor if !@csis_real_menu_actor
    $game_party.menu_actor = item_target_actors[0] if !item_target_actors.empty?
    $game_temp.clear_common_event # Don't call a common event.
    # Call the identified scene
    Input.update
    SceneManager.call(Kernel.const_get(item.csis_call_scene))
  end
end