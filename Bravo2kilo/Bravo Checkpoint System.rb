#==============================================================================
# Bravo Checkpoint System
#------------------------------------------------------------------------------
# Author: Bravo2Kilo
# Version: 1.0a
#
# Version History:
#   v1.0 = Initial Release
#   v1.0a = Fixed a bug
#==============================================================================
# To set a checkpoint use this in an event script call
#   set_checkpoint
#
# To add/remove lives use this in an event script call
#   add_life(amount)    amount = the amount of lives to want to add/remove
#==============================================================================
module BRAVO_CHECKPOINT
  # Switch to activate/deactivate the checkpoint respawning on death.
  CHECKPOINT_SWITCH = 1
  # Switch to activate/deactivate the life system. When activated the player
  # must have a life to respawn.
  LIFE_SWITCH = 2
  # Method for restoring health upon respawning. Values are 1, 2, or 3
  # When 1 the actors hp will be set to 1, When 2 the actors hp will be set to max
  # When 3 the actors hp will be restored by a percentage(percent set below)
  HP_RESTORE = 3
  # If the above is set to 3 this will be the percent restored
  HP_PERCENT = 25
  # This is the percent of exp points loss upon respawning
  EXP_LOSS = 10
  # This is the percent of gold loss upon respawning.
  GOLD_LOSS = 5
#==============================================================================
# END OF CONFIGURATION
#==============================================================================
end
$imported ||= {}
$imported[:Bravo_Checkpoint] = true

#==============================================================================
# ** BattleManager
#==============================================================================

module BattleManager
  #--------------------------------------------------------------------------
  # * Defeat Processing
  #--------------------------------------------------------------------------
  def self.process_defeat
    $game_message.add(sprintf(Vocab::Defeat, $game_party.name))
    wait_for_message
    if @can_lose
      revive_battle_members
      replay_bgm_and_bgs
      SceneManager.return
    else
      replay_bgm_and_bgs
      SceneManager.scene.check_gameover
    end
    battle_end(2)
    return true
  end
end

#==============================================================================
# ** Scene_Base
#==============================================================================

class Scene_Base
  #--------------------------------------------------------------------------
  # * Determine if Game Is Over
  #--------------------------------------------------------------------------
  alias bravo_checkpoint_check_gameover check_gameover
  def check_gameover
    if $game_party.all_dead?
      if $game_switches[BRAVO_CHECKPOINT::CHECKPOINT_SWITCH] == true
        if $game_switches[BRAVO_CHECKPOINT::LIFE_SWITCH] == true
          if $game_party.checkpoint_life == 0
            bravo_checkpoint_check_gameover
          else
            process_respawn
            $game_party.checkpoint_life -= 1
          end
        else
          process_respawn
        end
      else
        bravo_checkpoint_check_gameover
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Process Respawn
  #--------------------------------------------------------------------------
  def process_respawn
    $game_party.battle_members.each do |actor|
      if BRAVO_CHECKPOINT::HP_RESTORE == 1
        actor.hp = 1 if actor.dead?
      elsif BRAVO_CHECKPOINT::HP_RESTORE == 2
        actor.hp = actor.mhp if actor.dead?
      elsif BRAVO_CHECKPOINT::HP_RESTORE == 3
        amount = (BRAVO_CHECKPOINT::HP_PERCENT * 0.01) * actor.mhp
        actor.hp = amount.to_i if actor.dead?
      end
      current_exp = actor.exp - actor.current_level_exp
      exp_loss = (BRAVO_CHECKPOINT::GOLD_LOSS * 0.01) * current_exp
      actor.change_exp(actor.exp - exp_loss.to_i, false)
    end
    gold_loss = (BRAVO_CHECKPOINT::GOLD_LOSS * 0.01) * $game_party.gold
    $game_party.lose_gold(gold_loss.to_i)
    $game_map.setup($game_party.checkpoint_mapid)
    SceneManager.goto(Scene_Map)
    $game_player.moveto($game_party.checkpoint_x, $game_party.checkpoint_y)
    $game_player.set_direction($game_party.checkpoint_dir)
  end
end

#==============================================================================
# ** Game_Party
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :checkpoint_life
  attr_reader   :checkpoint_mapid
  attr_reader   :checkpoint_x
  attr_reader   :checkpoint_y
  attr_reader   :checkpoint_dir
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias bravo_checkpoint_initialize initialize
  def initialize
    bravo_checkpoint_initialize
    @checkpoint_life ||= 0
  end
  #--------------------------------------------------------------------------
  # * Set Checkpoint
  #--------------------------------------------------------------------------
  def set_checkpoint
    @checkpoint_mapid = $game_map.map_id
    @checkpoint_x = $game_player.x
    @checkpoint_y = $game_player.y
    @checkpoint_dir = $game_player.direction
  end
end

#==============================================================================
# ** Game_Interpreter
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Set Checkpoint
  #--------------------------------------------------------------------------
  def set_checkpoint
    $game_party.set_checkpoint
  end
  #--------------------------------------------------------------------------
  # * Add Life
  #--------------------------------------------------------------------------
  def add_life(amount)
    $game_party.checkpoint_life += amount
  end
end