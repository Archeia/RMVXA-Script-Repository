=begin
#===============================================================================
 Title: Battle Manager
 Author: Hime
 Date: Mar 2, 2013
--------------------------------------------------------------------------------
 ** Change log
 Mar 2, 2013
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
 
 The Battle Manager provides a “plugin battle system” which allows your project
 to support multiple battle systems in a single game. The script uses an
 intuitive script call based approach to determining which battle system
 should be used.
 
 Under this script, your project would consist of two types of battle systems
 
 1. The primary battle system. This is the main battle system that will be used
    in your game.
    
 2. The secondary battle systems. These are custom plugins that change the
    battle system somehow, or provide a completely different type of battle.
    These are typically used in smaller-scale events such as mini-games, and
    should not be used as your main battle system.
 
--------------------------------------------------------------------------------
 ** Usage
 
 To determine the battle system to use, make the script call
 
   battle_system(TYPE)
   
 Where `TYPE` is the name of the battle system. The battle system plugins should
 tell you what the name of their battle system is.
 
 The default battle system is "BaseBattle", so if you wanted to use the
 default battle system you would write
 
   battle_system("BaseBattle")
 
--------------------------------------------------------------------------------
 ** Developers
 
 The Battle Manager is a factory interface that will set up the battle scene
 and battle manager for you based on what the current battle system is. It
 will redirect all calls to BattleManager to the correct battle manager.
 
 It is very easy to setup a battle system as a primary battle system and is
 described in the user usage section.
 
 You will typically be developing secondary battle systems for this script, as
 the primary battle system is fairly easy to implement.
  
 To add your own battle system, you will need to define a few things.
 First, begin by choosing a name for your battle system. In this example,
 I will use "HimeBattle" as my battle system's name.
 
 1: Define your battle manager and inherit it from BaseBattleManager.

      class HimeBattleManager < BaseBattleManager
      
 2: Define your battle scene and inherit it from Scene_Battle
 
      class Scene_HimeBattle < Scene_Battle
         
 3: Define your battle windows and spriteset_battle. In order for a project to
    support multiple battle systems, you CANNOT overwrite any of the default
    classes. Instead, you should inherit from them and make your changes as
    needed.
    
 4: If you must overwrite data, do an alias and check that the current scene
    is your battle scene. You should consider all built-in scripts to be
    "shared" objects, and users will likely run into compatibility issues
    between plugins if you overwrite methods however you wish.
    
 If you have an existing battle system already, you would follow the same
 procedure. I have provided two example plugins using Kread-EX's Chain Battle
 system and Fomar's Customizable ATB system.
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_BattleManager"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Battle_Manager
    
    # Default battle system to use
    Default_System = "BaseBattle"
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module SceneManager
  
  class << self
    alias :th_battle_manager_scene_is? :scene_is?
    alias :th_battle_manager_call :call
  end
  
  def self.scene_is?(scene_class)
    return true if @scene.is_a?(scene_class)
    th_battle_manager_scene_is?(scene_class)
  end
  
  def self.call(scene_class)
    if scene_class == Scene_Battle
      @stack.push(@scene)
      @scene = BattleManager.scene_class.new
    else
      th_battle_manager_call(scene_class)
    end
  end
end

class Game_System
  attr_accessor :battle_type
  
  alias :th_battle_manager_initialize :initialize
  def initialize
    th_battle_manager_initialize
    @battle_type = TH::Battle_Manager::Default_System
  end
end

class Game_Interpreter
  
  def battle_system(type)
    $game_system.battle_type = type
  end
end

class Scene_Map < Scene_Base
  
  #-----------------------------------------------------------------------------
  # Replaced. Determine the battle scene to use
  #-----------------------------------------------------------------------------
  def update_encounter
    SceneManager.call(BattleManager.scene_class) if $game_player.encounter
  end
end

class Scene_Battle < Scene_Base
  
  alias :th_battle_manager_start :start
  def start
    th_battle_manager_start
    @battle_manager = BattleManager.manager
  end
end

#-------------------------------------------------------------------------------
# All Battle Manager methods are re-directed to the contained battle manager.
# This is only for compatibility with existing scripts. All battle scenes
# should refer to their own instance of the battle manager
#-------------------------------------------------------------------------------
module BattleManager
  
  #-----------------------------------------------------------------------------
  # For compatibility.
  #-----------------------------------------------------------------------------
  def self.method_missing(*args)
    @battle_manager.send(*args)
  end
  
  #-----------------------------------------------------------------------------
  # Return the scene to use
  #-----------------------------------------------------------------------------
  def self.scene_class
    return Scene_Battle if $game_system.battle_type.to_s == "BaseBattle"
    battle_scene = "Scene_" + $game_system.battle_type.to_s
    return Object.const_get(battle_scene.to_sym)
  end
  
  #-----------------------------------------------------------------------------
  # Return the battle manager to use
  #-----------------------------------------------------------------------------
  def self.manager_class
    return BaseBattleManager if $game_system.battle_type.to_s == "BaseBattle"
    battle_manager = $game_system.battle_type.to_s + "Manager"
    return Object.const_get(battle_manager.to_sym)
  end
  
  def self.manager
    return @battle_manager
  end
  
  def self.setup_manager
    @battle_manager = manager_class
  end
  
  def self.setup(troop_id, can_escape = true, can_lose = false)
    setup_manager
    @battle_manager.setup(troop_id, can_escape, can_lose)
  end
  
  def self.actor
    @battle_manager.actor
  end
  
  def self.init_members
    @battle_manager.init_members
  end
  #--------------------------------------------------------------------------
  # * Processing at Encounter Time
  #--------------------------------------------------------------------------
  def self.on_encounter
    @battle_manager.on_encounter
  end
  #--------------------------------------------------------------------------
  # * Get Probability of Preemptive Attack
  #--------------------------------------------------------------------------
  def self.rate_preemptive
    @battle_manager.rate_preemptive
  end
  #--------------------------------------------------------------------------
  # * Get Probability of Surprise
  #--------------------------------------------------------------------------
  def self.rate_surprise
    @battle_manager.rate_surprise
  end
  #--------------------------------------------------------------------------
  # * Save BGM and BGS
  #--------------------------------------------------------------------------
  def self.save_bgm_and_bgs
    @battle_manager.save_bgm_and_bgs
  end
  #--------------------------------------------------------------------------
  # * Play Battle BGM
  #--------------------------------------------------------------------------
  def self.play_battle_bgm
    @battle_manager.play_battle_bgm
  end
  #--------------------------------------------------------------------------
  # * Play Battle End ME
  #--------------------------------------------------------------------------
  def self.play_battle_end_me
    @battle_manager.play_battle_end_me
  end
  #--------------------------------------------------------------------------
  # * Resume BGM and BGS
  #--------------------------------------------------------------------------
  def self.replay_bgm_and_bgs
    @battle_manager.replay_bgm_and_bgs
  end
  #--------------------------------------------------------------------------
  # * Create Escape Success Probability
  #--------------------------------------------------------------------------
  def self.make_escape_ratio
    @battle_manager.make_escape_ratio
  end
  #--------------------------------------------------------------------------
  # * Determine if Turn Is Executing
  #--------------------------------------------------------------------------
  def self.in_turn?
    @battle_manager.in_turn?
  end
  #--------------------------------------------------------------------------
  # * Determine if Turn Is Ending
  #--------------------------------------------------------------------------
  def self.turn_end?
    @battle_manager.turn_end?
  end
  #--------------------------------------------------------------------------
  # * Determine if Battle Is Aborting
  #--------------------------------------------------------------------------
  def self.aborting?
    @battle_manager.aborting?
  end
  #--------------------------------------------------------------------------
  # * Get Whether Escape Is Possible
  #--------------------------------------------------------------------------
  def self.can_escape?
    @battle_manager.can_escape?
  end
  #--------------------------------------------------------------------------
  # * Get Actor for Which Command Is Being Entered
  #--------------------------------------------------------------------------
  def self.actor
    @battle_manager.actor
  end
  #--------------------------------------------------------------------------
  # * Clear Actor for Which Command Is Being Entered
  #--------------------------------------------------------------------------
  def self.clear_actor
    @battle_manager.clear_actor
  end
  #--------------------------------------------------------------------------
  # * To Next Command Input
  #--------------------------------------------------------------------------
  def self.next_command
    @battle_manager.next_command
  end
  #--------------------------------------------------------------------------
  # * To Previous Command Input
  #--------------------------------------------------------------------------
  def self.prior_command
    @battle_manager.prior_command
  end
  #--------------------------------------------------------------------------
  # * Set Proc for Callback to Event
  #--------------------------------------------------------------------------
  def self.event_proc=(proc)
    @battle_manager.event_proc = proc
  end
  #--------------------------------------------------------------------------
  # * Set Wait Method
  #--------------------------------------------------------------------------
  def self.method_wait_for_message=(method)
    @battle_manager.method_wait_for_message = method
  end
  #--------------------------------------------------------------------------
  # * Wait Until Message Display has Finished
  #--------------------------------------------------------------------------
  def self.wait_for_message
    @battle_manager.wait_for_message
  end
  #--------------------------------------------------------------------------
  # * Battle Start
  #--------------------------------------------------------------------------
  def self.battle_start
    @battle_manager.battle_start
  end
  #--------------------------------------------------------------------------
  # * Battle Abort
  #--------------------------------------------------------------------------
  def self.abort
    @battle_manager.abort
  end
  #--------------------------------------------------------------------------
  # * Determine Win/Loss Results
  #--------------------------------------------------------------------------
  def self.judge_win_loss
    @battle_manager.judge_win_loss
  end
  #--------------------------------------------------------------------------
  # * Victory Processing
  #--------------------------------------------------------------------------
  def self.process_victory
    @battle_manager.process_victory
  end
  #--------------------------------------------------------------------------
  # * Escape Processing
  #--------------------------------------------------------------------------
  def self.process_escape
    @battle_manager.process_escape
  end
  #--------------------------------------------------------------------------
  # * Abort Processing
  #--------------------------------------------------------------------------
  def self.process_abort
    @battle_manager.process_abort
  end
  #--------------------------------------------------------------------------
  # * Defeat Processing
  #--------------------------------------------------------------------------
  def self.process_defeat
    @battle_manager.process_defeat
  end
  #--------------------------------------------------------------------------
  # * Revive Battle Members (When Defeated)
  #--------------------------------------------------------------------------
  def self.revive_battle_members
    @battle_manager.revive_battle_members
  end
  #--------------------------------------------------------------------------
  # * End Battle
  #     result : Result (0: Win 1: Escape 2: Lose)
  #--------------------------------------------------------------------------
  def self.battle_end(result)
    @battle_manager.battle_end(result)
  end
  #--------------------------------------------------------------------------
  # * Start Command Input
  #--------------------------------------------------------------------------
  def self.input_start
    @battle_manager.input_start
  end
  #--------------------------------------------------------------------------
  # * Start Turn
  #--------------------------------------------------------------------------
  def self.turn_start
    @battle_manager.turn_start
  end
  #--------------------------------------------------------------------------
  # * End Turn
  #--------------------------------------------------------------------------
  def self.turn_end
    @battle_manager.turn_end
  end
  #--------------------------------------------------------------------------
  # * Display EXP Earned
  #--------------------------------------------------------------------------
  def self.display_exp
    @battle_manager.display_exp
  end
  #--------------------------------------------------------------------------
  # * Gold Acquisition and Display
  #--------------------------------------------------------------------------
  def self.gain_gold
    @battle_manager.gain_gold
  end
  #--------------------------------------------------------------------------
  # * Dropped Item Acquisition and Display
  #--------------------------------------------------------------------------
  def self.gain_drop_items
    @battle_manager.gain_drop_items
  end
  #--------------------------------------------------------------------------
  # * EXP Acquisition and Level Up Display
  #--------------------------------------------------------------------------
  def self.gain_exp
    @battle_manager.gain_exp
  end
  #--------------------------------------------------------------------------
  # * Create Action Order
  #--------------------------------------------------------------------------
  def self.make_action_orders
    @battle_manager.make_action_orders
  end
  #--------------------------------------------------------------------------
  # * Force Action
  #--------------------------------------------------------------------------
  def self.force_action(battler)
    @battle_manager.force_action(battler)
  end
  #--------------------------------------------------------------------------
  # * Get Forced State of Battle Action
  #--------------------------------------------------------------------------
  def self.action_forced?
    @battle_manager.action_forced?
  end
  #--------------------------------------------------------------------------
  # * Get Battler Subjected to Forced Action
  #--------------------------------------------------------------------------
  def self.action_forced_battler
    @battle_manager.action_forced_battler
  end
  #--------------------------------------------------------------------------
  # * Clear Forcing of Battle Action
  #--------------------------------------------------------------------------
  def self.clear_action_force
    @battle_manager.clear_action_force
  end
  #--------------------------------------------------------------------------
  # * Get Next Action Subject
  #    Get the battler from the beginning of the action order list.
  #    If an actor not currently in the party is obtained (occurs when index
  #    is nil, immediately after escaping in battle events etc.), skip them.
  #--------------------------------------------------------------------------
  def self.next_subject
    @battle_manager.next_subject
  end
end

#-------------------------------------------------------------------------------
# The base battle manager that provides default battle logic. All other battle
# systems should inherit from this base battle manager if they need to overwrite
# logic
#-------------------------------------------------------------------------------
class BaseBattleManager
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  def self.setup(troop_id, can_escape = true, can_lose = false)
    init_members
    $game_troop.setup(troop_id)
    @can_escape = can_escape
    @can_lose = can_lose
    make_escape_ratio
  end
  #--------------------------------------------------------------------------
  # * Initialize Member Variables
  #--------------------------------------------------------------------------
  def self.init_members
    @phase = :init              # Battle Progress Phase
    @can_escape = false         # Can Escape Flag
    @can_lose = false           # Can Lose Flag
    @event_proc = nil           # Event Callback
    @preemptive = false         # Preemptive Attack Flag
    @surprise = false           # Surprise Flag
    @actor_index = -1           # Actor for Which Command Is Being Entered
    @action_forced = nil        # Force Action
    @map_bgm = nil              # For Memorizing Pre-Battle BGM
    @map_bgs = nil              # For Memorizing Pre-Battle BGS
    @action_battlers = []       # Action Order List
  end
  #--------------------------------------------------------------------------
  # * Processing at Encounter Time
  #--------------------------------------------------------------------------
  def self.on_encounter
    @preemptive = (rand < rate_preemptive)
    @surprise = (rand < rate_surprise && !@preemptive)
  end
  #--------------------------------------------------------------------------
  # * Get Probability of Preemptive Attack
  #--------------------------------------------------------------------------
  def self.rate_preemptive
    $game_party.rate_preemptive($game_troop.agi)
  end
  #--------------------------------------------------------------------------
  # * Get Probability of Surprise
  #--------------------------------------------------------------------------
  def self.rate_surprise
    $game_party.rate_surprise($game_troop.agi)
  end
  #--------------------------------------------------------------------------
  # * Save BGM and BGS
  #--------------------------------------------------------------------------
  def self.save_bgm_and_bgs
    @map_bgm = RPG::BGM.last
    @map_bgs = RPG::BGS.last
  end
  #--------------------------------------------------------------------------
  # * Play Battle BGM
  #--------------------------------------------------------------------------
  def self.play_battle_bgm
    $game_system.battle_bgm.play
    RPG::BGS.stop
  end
  #--------------------------------------------------------------------------
  # * Play Battle End ME
  #--------------------------------------------------------------------------
  def self.play_battle_end_me
    $game_system.battle_end_me.play
  end
  #--------------------------------------------------------------------------
  # * Resume BGM and BGS
  #--------------------------------------------------------------------------
  def self.replay_bgm_and_bgs
    @map_bgm.replay unless $BTEST
    @map_bgs.replay unless $BTEST
  end
  #--------------------------------------------------------------------------
  # * Create Escape Success Probability
  #--------------------------------------------------------------------------
  def self.make_escape_ratio
    @escape_ratio = 1.5 - 1.0 * $game_troop.agi / $game_party.agi
  end
  #--------------------------------------------------------------------------
  # * Determine if Turn Is Executing
  #--------------------------------------------------------------------------
  def self.in_turn?
    @phase == :turn
  end
  #--------------------------------------------------------------------------
  # * Determine if Turn Is Ending
  #--------------------------------------------------------------------------
  def self.turn_end?
    @phase == :turn_end
  end
  #--------------------------------------------------------------------------
  # * Determine if Battle Is Aborting
  #--------------------------------------------------------------------------
  def self.aborting?
    @phase == :aborting
  end
  #--------------------------------------------------------------------------
  # * Get Whether Escape Is Possible
  #--------------------------------------------------------------------------
  def self.can_escape?
    @can_escape
  end
  #--------------------------------------------------------------------------
  # * Get Actor for Which Command Is Being Entered
  #--------------------------------------------------------------------------
  def self.actor
    @actor_index >= 0 ? $game_party.members[@actor_index] : nil
  end
  #--------------------------------------------------------------------------
  # * Clear Actor for Which Command Is Being Entered
  #--------------------------------------------------------------------------
  def self.clear_actor
    @actor_index = -1
  end
  #--------------------------------------------------------------------------
  # * To Next Command Input
  #--------------------------------------------------------------------------
  def self.next_command
    begin
      if !actor || !actor.next_command
        @actor_index += 1
        return false if @actor_index >= $game_party.members.size
      end
    end until actor.inputable?
    return true
  end
  #--------------------------------------------------------------------------
  # * To Previous Command Input
  #--------------------------------------------------------------------------
  def self.prior_command
    begin
      if !actor || !actor.prior_command
        @actor_index -= 1
        return false if @actor_index < 0
      end
    end until actor.inputable?
    return true
  end
  #--------------------------------------------------------------------------
  # * Set Proc for Callback to Event
  #--------------------------------------------------------------------------
  def self.event_proc=(proc)
    @event_proc = proc
  end
  #--------------------------------------------------------------------------
  # * Set Wait Method
  #--------------------------------------------------------------------------
  def self.method_wait_for_message=(method)
    @method_wait_for_message = method
  end
  #--------------------------------------------------------------------------
  # * Wait Until Message Display has Finished
  #--------------------------------------------------------------------------
  def self.wait_for_message
    @method_wait_for_message.call if @method_wait_for_message
  end
  #--------------------------------------------------------------------------
  # * Battle Start
  #--------------------------------------------------------------------------
  def self.battle_start
    $game_system.battle_count += 1
    $game_party.on_battle_start
    $game_troop.on_battle_start
    $game_troop.enemy_names.each do |name|
      $game_message.add(sprintf(Vocab::Emerge, name))
    end
    if @preemptive
      $game_message.add(sprintf(Vocab::Preemptive, $game_party.name))
    elsif @surprise
      $game_message.add(sprintf(Vocab::Surprise, $game_party.name))
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # * Battle Abort
  #--------------------------------------------------------------------------
  def self.abort
    @phase = :aborting
  end
  #--------------------------------------------------------------------------
  # * Determine Win/Loss Results
  #--------------------------------------------------------------------------
  def self.judge_win_loss
    if @phase
      return process_abort   if $game_party.members.empty?
      return process_defeat  if $game_party.all_dead?
      return process_victory if $game_troop.all_dead?
      return process_abort   if aborting?
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Victory Processing
  #--------------------------------------------------------------------------
  def self.process_victory
    play_battle_end_me
    replay_bgm_and_bgs
    $game_message.add(sprintf(Vocab::Victory, $game_party.name))
    display_exp
    gain_gold
    gain_drop_items
    gain_exp
    SceneManager.return
    battle_end(0)
    return true
  end
  #--------------------------------------------------------------------------
  # * Escape Processing
  #--------------------------------------------------------------------------
  def self.process_escape
    $game_message.add(sprintf(Vocab::EscapeStart, $game_party.name))
    success = @preemptive ? true : (rand < @escape_ratio)
    Sound.play_escape
    if success
      process_abort
    else
      @escape_ratio += 0.1
      $game_message.add('\.' + Vocab::EscapeFailure)
      $game_party.clear_actions
    end
    wait_for_message
    return success
  end
  #--------------------------------------------------------------------------
  # * Abort Processing
  #--------------------------------------------------------------------------
  def self.process_abort
    replay_bgm_and_bgs
    SceneManager.return
    battle_end(1)
    return true
  end
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
      SceneManager.goto(Scene_Gameover)
    end
    battle_end(2)
    return true
  end
  #--------------------------------------------------------------------------
  # * Revive Battle Members (When Defeated)
  #--------------------------------------------------------------------------
  def self.revive_battle_members
    $game_party.battle_members.each do |actor|
      actor.hp = 1 if actor.dead?
    end
  end
  #--------------------------------------------------------------------------
  # * End Battle
  #     result : Result (0: Win 1: Escape 2: Lose)
  #--------------------------------------------------------------------------
  def self.battle_end(result)
    @phase = nil
    @event_proc.call(result) if @event_proc
    $game_party.on_battle_end
    $game_troop.on_battle_end
    SceneManager.exit if $BTEST
  end
  #--------------------------------------------------------------------------
  # * Start Command Input
  #--------------------------------------------------------------------------
  def self.input_start
    if @phase != :input
      @phase = :input
      $game_party.make_actions
      $game_troop.make_actions
      clear_actor
    end
    return !@surprise && $game_party.inputable?
  end
  #--------------------------------------------------------------------------
  # * Start Turn
  #--------------------------------------------------------------------------
  def self.turn_start
    @phase = :turn
    clear_actor
    $game_troop.increase_turn
    make_action_orders
  end
  #--------------------------------------------------------------------------
  # * End Turn
  #--------------------------------------------------------------------------
  def self.turn_end
    @phase = :turn_end
    @preemptive = false
    @surprise = false
  end
  #--------------------------------------------------------------------------
  # * Display EXP Earned
  #--------------------------------------------------------------------------
  def self.display_exp
    if $game_troop.exp_total > 0
      text = sprintf(Vocab::ObtainExp, $game_troop.exp_total)
      $game_message.add('\.' + text)
    end
  end
  #--------------------------------------------------------------------------
  # * Gold Acquisition and Display
  #--------------------------------------------------------------------------
  def self.gain_gold
    if $game_troop.gold_total > 0
      text = sprintf(Vocab::ObtainGold, $game_troop.gold_total)
      $game_message.add('\.' + text)
      $game_party.gain_gold($game_troop.gold_total)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # * Dropped Item Acquisition and Display
  #--------------------------------------------------------------------------
  def self.gain_drop_items
    $game_troop.make_drop_items.each do |item|
      $game_party.gain_item(item, 1)
      $game_message.add(sprintf(Vocab::ObtainItem, item.name))
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # * EXP Acquisition and Level Up Display
  #--------------------------------------------------------------------------
  def self.gain_exp
    $game_party.all_members.each do |actor|
      actor.gain_exp($game_troop.exp_total)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # * Create Action Order
  #--------------------------------------------------------------------------
  def self.make_action_orders
    @action_battlers = []
    @action_battlers += $game_party.members unless @surprise
    @action_battlers += $game_troop.members unless @preemptive
    @action_battlers.each {|battler| battler.make_speed }
    @action_battlers.sort! {|a,b| b.speed - a.speed }
  end
  #--------------------------------------------------------------------------
  # * Force Action
  #--------------------------------------------------------------------------
  def self.force_action(battler)
    @action_forced = battler
    @action_battlers.delete(battler)
  end
  #--------------------------------------------------------------------------
  # * Get Forced State of Battle Action
  #--------------------------------------------------------------------------
  def self.action_forced?
    @action_forced != nil
  end
  #--------------------------------------------------------------------------
  # * Get Battler Subjected to Forced Action
  #--------------------------------------------------------------------------
  def self.action_forced_battler
    @action_forced
  end
  #--------------------------------------------------------------------------
  # * Clear Forcing of Battle Action
  #--------------------------------------------------------------------------
  def self.clear_action_force
    @action_forced = nil
  end
  #--------------------------------------------------------------------------
  # * Get Next Action Subject
  #    Get the battler from the beginning of the action order list.
  #    If an actor not currently in the party is obtained (occurs when index
  #    is nil, immediately after escaping in battle events etc.), skip them.
  #--------------------------------------------------------------------------
  def self.next_subject
    loop do
      battler = @action_battlers.shift
      return nil unless battler
      next unless battler.index && battler.alive?
      return battler
    end
  end
end