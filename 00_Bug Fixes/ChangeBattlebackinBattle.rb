#==============================================================================
# 
# ▼ Change Battleback in Battle by Kal
# -- Last Updated: February 12, 2012
# 
#==============================================================================
#
# This command fixes a bug in RPG Maker VX Ace where the event command, 
# Change Battleback, is not working in battle.
#
#==============================================================================
#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
# An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================
class Game_Interpreter
  alias_method :command_283_orig_kal, :command_283
  def command_283
	command_283_orig_kal
	if SceneManager.scene.is_a?(Scene_Battle)
	  scene = SceneManager.scene
	  scene.spriteset.dispose_battleback1
	  scene.spriteset.dispose_battleback2
	  scene.spriteset.create_battleback1
	  scene.spriteset.create_battleback2
	end
  end
end

class Scene_Battle
  attr_reader :spriteset
end