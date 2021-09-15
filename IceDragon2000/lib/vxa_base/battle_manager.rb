#encoding:UTF-8
# BattleManager
#==============================================================================
# ** BattleManager
#------------------------------------------------------------------------------
#  This module manages battle progress.
#==============================================================================

module BattleManager
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
