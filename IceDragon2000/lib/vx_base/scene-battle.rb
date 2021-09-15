#encoding:UTF-8
# Scene_Battle
#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  def start
    super
    $game_temp.in_battle = true
    @spriteset = Spriteset_Battle.new
    @message_window = Window_BattleMessage.new
    @action_battlers = []
    create_info_viewport
  end
  #--------------------------------------------------------------------------
  # * Post-Start Processing
  #--------------------------------------------------------------------------
  def post_start
    super
    process_battle_start
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_info_viewport
    @message_window.dispose
    @spriteset.dispose
    unless $scene.is_a?(Scene_Gameover)
      $scene = nil if $BTEST
    end
  end
  #--------------------------------------------------------------------------
  # * Basic Update Processing
  #     main : Call from main update method
  #--------------------------------------------------------------------------
  def update_basic(main = false)
    Graphics.update unless main     # Update game screen
    Input.update unless main        # Update input information
    $game_system.update             # Update timer
    $game_troop.update              # Update enemy group
    @spriteset.update               # Update sprite set
    @message_window.update          # Update message window
  end
  #--------------------------------------------------------------------------
  # * Wait a set amount of time
  #     duration : Wait time (number of frames)
  #     no_fast  : Fast forward disabled
  #    A method for inserting a wait during scene class update processing.
  #    As a rule, update is called once for each frame, but during battle it
  #    can be difficult to grasp the processing flow, so this method is used#
  #    as an exception.
  #--------------------------------------------------------------------------
  def wait(duration, no_fast = false)
    for i in 0...duration
      update_basic
      break if not no_fast and i >= duration / 2 and show_fast?
    end
  end
  #--------------------------------------------------------------------------
  # * Wait Until Message Display has Finished
  #--------------------------------------------------------------------------
  def wait_for_message
    @message_window.update
    while $game_message.visible
      update_basic
    end
  end
  #--------------------------------------------------------------------------
  # * Wait Until Animation Display has Finished
  #--------------------------------------------------------------------------
  def wait_for_animation
    while @spriteset.animation?
      update_basic
    end
  end
  #--------------------------------------------------------------------------
  # * Determine Fast Forward
  #--------------------------------------------------------------------------
  def show_fast?
    return (Input.press?(Input::A) or Input.press?(Input::C))
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    update_basic(true)
    update_info_viewport                  # Update information viewport
    if $game_message.visible
      @info_viewport.visible = false
      @message_window.visible = true
    end
    unless $game_message.visible          # Unless displaying a message
      return if judge_win_loss            # Determine win/loss results
      update_scene_change
      if @target_enemy_window != nil
        update_target_enemy_selection     # Select target enemy
      elsif @target_actor_window != nil
        update_target_actor_selection     # Select target actor
      elsif @skill_window != nil
        update_skill_selection            # Select skill
      elsif @item_window != nil
        update_item_selection             # Select item
      elsif @party_command_window.active
        update_party_command_selection    # Select party command
      elsif @actor_command_window.active
        update_actor_command_selection    # Select actor command
      else
        process_battle_event              # Battle event processing
        process_action                    # Battle action
        process_battle_event              # Battle event processing
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Create Information Display Viewport
  #--------------------------------------------------------------------------
  def create_info_viewport
    @info_viewport = Viewport.new(0, 288, 544, 128)
    @info_viewport.z = 100
    @status_window = Window_BattleStatus.new
    @party_command_window = Window_PartyCommand.new
    @actor_command_window = Window_ActorCommand.new
    @status_window.viewport = @info_viewport
    @party_command_window.viewport = @info_viewport
    @actor_command_window.viewport = @info_viewport
    @status_window.x = 128
    @actor_command_window.x = 544
    @info_viewport.visible = false
  end
  #--------------------------------------------------------------------------
  # * Dispose of Information Display Viewport
  #--------------------------------------------------------------------------
  def dispose_info_viewport
    @status_window.dispose
    @party_command_window.dispose
    @actor_command_window.dispose
    @info_viewport.dispose
  end
  #--------------------------------------------------------------------------
  # * Update Information Display Viewport
  #--------------------------------------------------------------------------
  def update_info_viewport
    @party_command_window.update
    @actor_command_window.update
    @status_window.update
    if @party_command_window.active and @info_viewport.ox > 0
      @info_viewport.ox -= 16
    elsif @actor_command_window.active and @info_viewport.ox < 128
      @info_viewport.ox += 16
    end
  end
  #--------------------------------------------------------------------------
  # * Battle Event Processing
  #--------------------------------------------------------------------------
  def process_battle_event
    loop do
      return if judge_win_loss
      return if $game_temp.next_scene != nil
      $game_troop.interpreter.update
      $game_troop.setup_battle_event
      wait_for_message
      process_action if $game_troop.forcing_battler != nil
      return unless $game_troop.interpreter.running?
      update_basic
    end
  end
  #--------------------------------------------------------------------------
  # * Determine Win/Loss Results
  #--------------------------------------------------------------------------
  def judge_win_loss
    if $game_temp.in_battle
      if $game_party.all_dead?
        process_defeat
        return true
      elsif $game_troop.all_dead?
        process_victory
        return true
      else
        return false
      end
    else
      return true
    end
  end
  #--------------------------------------------------------------------------
  # * End Battle
  #     result : Results (0: win, 1: escape, 2:lose)
  #--------------------------------------------------------------------------
  def battle_end(result)
    if result == 2 and not $game_troop.can_lose
      call_gameover
    else
      $game_party.clear_actions
      $game_party.remove_states_battle
      $game_troop.clear
      if $game_temp.battle_proc != nil
        $game_temp.battle_proc.call(result)
        $game_temp.battle_proc = nil
      end
      unless $BTEST
        $game_temp.map_bgm.play
        $game_temp.map_bgs.play
      end
      $scene = Scene_Map.new
      @message_window.clear
      Graphics.fadeout(30)
    end
    $game_temp.in_battle = false
  end
  #--------------------------------------------------------------------------
  # * Go to Command Input for Next Actor
  #--------------------------------------------------------------------------
  def next_actor
    loop do
      if @actor_index == $game_party.members.size-1
        start_main
        return
      end
      @status_window.index = @actor_index += 1
      @active_battler = $game_party.members[@actor_index]
      if @active_battler.auto_battle
        @active_battler.make_action
        next
      end
      break if @active_battler.inputable?
    end
    start_actor_command_selection
  end
  #--------------------------------------------------------------------------
  # * Go to Command Input of Previous Actor
  #--------------------------------------------------------------------------
  def prior_actor
    loop do
      if @actor_index == 0
        start_party_command_selection
        return
      end
      @status_window.index = @actor_index -= 1
      @active_battler = $game_party.members[@actor_index]
      next if @active_battler.auto_battle
      break if @active_battler.inputable?
    end
    start_actor_command_selection
  end
  #--------------------------------------------------------------------------
  # * Start party command selection
  #--------------------------------------------------------------------------
  def start_party_command_selection
    if $game_temp.in_battle
      @status_window.refresh
      @status_window.index = @actor_index = -1
      @active_battler = nil
      @info_viewport.visible = true
      @message_window.visible = false
      @party_command_window.active = true
      @party_command_window.index = 0
      @actor_command_window.active = false
      $game_party.clear_actions
      if $game_troop.surprise or not $game_party.inputable?
        start_main
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Update Party Command Selection
  #--------------------------------------------------------------------------
  def update_party_command_selection
    if Input.trigger?(Input::C)
      case @party_command_window.index
      when 0  # Fight
        Sound.play_decision
        @status_window.index = @actor_index = -1
        next_actor
      when 1  # Escape
        if $game_troop.can_escape == false
          Sound.play_buzzer
          return
        end
        Sound.play_decision
        process_escape
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Start Actor Command Selection
  #--------------------------------------------------------------------------
  def start_actor_command_selection
    @party_command_window.active = false
    @actor_command_window.setup(@active_battler)
    @actor_command_window.active = true
    @actor_command_window.index = 0
  end
  #--------------------------------------------------------------------------
  # * Update Actor Command Selection
  #--------------------------------------------------------------------------
  def update_actor_command_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      prior_actor
    elsif Input.trigger?(Input::C)
      case @actor_command_window.index
      when 0  # Attack
        Sound.play_decision
        @active_battler.action.set_attack
        start_target_enemy_selection
      when 1  # Skill
        Sound.play_decision
        start_skill_selection
      when 2  # Guard
        Sound.play_decision
        @active_battler.action.set_guard
        next_actor
      when 3  # Item
        Sound.play_decision
        start_item_selection
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Start Target Enemy Selection
  #--------------------------------------------------------------------------
  def start_target_enemy_selection
    @target_enemy_window = Window_TargetEnemy.new
    @target_enemy_window.y = @info_viewport.rect.y
    @info_viewport.rect.x += @target_enemy_window.width
    @info_viewport.ox += @target_enemy_window.width
    @actor_command_window.active = false
  end
  #--------------------------------------------------------------------------
  # * End Target Enemy Selection
  #--------------------------------------------------------------------------
  def end_target_enemy_selection
    @info_viewport.rect.x -= @target_enemy_window.width
    @info_viewport.ox -= @target_enemy_window.width
    @target_enemy_window.dispose
    @target_enemy_window = nil
    if @actor_command_window.index == 0
      @actor_command_window.active = true
    end
  end
  #--------------------------------------------------------------------------
  # * Update Target Enemy Selection
  #--------------------------------------------------------------------------
  def update_target_enemy_selection
    @target_enemy_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_target_enemy_selection
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      @active_battler.action.target_index = @target_enemy_window.enemy.index
      end_target_enemy_selection
      end_skill_selection
      end_item_selection
      next_actor
    end
  end
  #--------------------------------------------------------------------------
  # * Start Target Actor Selection
  #--------------------------------------------------------------------------
  def start_target_actor_selection
    @target_actor_window = Window_BattleStatus.new
    @target_actor_window.index = 0
    @target_actor_window.active = true
    @target_actor_window.y = @info_viewport.rect.y
    @info_viewport.rect.x += @target_actor_window.width
    @info_viewport.ox += @target_actor_window.width
    @actor_command_window.active = false
  end
  #--------------------------------------------------------------------------
  # * End Target Actor Selection
  #--------------------------------------------------------------------------
  def end_target_actor_selection
    @info_viewport.rect.x -= @target_actor_window.width
    @info_viewport.ox -= @target_actor_window.width
    @target_actor_window.dispose
    @target_actor_window = nil
  end
  #--------------------------------------------------------------------------
  # * Update Target Actor Selection
  #--------------------------------------------------------------------------
  def update_target_actor_selection
    @target_actor_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_target_actor_selection
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      @active_battler.action.target_index = @target_actor_window.index
      end_target_actor_selection
      end_skill_selection
      end_item_selection
      next_actor
    end
  end
  #--------------------------------------------------------------------------
  # * Start Skill Selection
  #--------------------------------------------------------------------------
  def start_skill_selection
    @help_window = Window_Help.new
    @skill_window = Window_Skill.new(0, 56, 544, 232, @active_battler)
    @skill_window.help_window = @help_window
    @actor_command_window.active = false
  end
  #--------------------------------------------------------------------------
  # * End Skill Selection
  #--------------------------------------------------------------------------
  def end_skill_selection
    if @skill_window != nil
      @skill_window.dispose
      @skill_window = nil
      @help_window.dispose
      @help_window = nil
    end
    @actor_command_window.active = true
  end
  #--------------------------------------------------------------------------
  # * Update Skill Selection
  #--------------------------------------------------------------------------
  def update_skill_selection
    @skill_window.active = true
    @skill_window.update
    @help_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_skill_selection
    elsif Input.trigger?(Input::C)
      @skill = @skill_window.skill
      if @skill != nil
        @active_battler.last_skill_id = @skill.id
      end
      if @active_battler.skill_can_use?(@skill)
        Sound.play_decision
        determine_skill
      else
        Sound.play_buzzer
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Confirm Skill
  #--------------------------------------------------------------------------
  def determine_skill
    @active_battler.action.set_skill(@skill.id)
    @skill_window.active = false
    if @skill.need_selection?
      if @skill.for_opponent?
        start_target_enemy_selection
      else
        start_target_actor_selection
      end
    else
      end_skill_selection
      next_actor
    end
  end
  #--------------------------------------------------------------------------
  # * Start Item Selection
  #--------------------------------------------------------------------------
  def start_item_selection
    @help_window = Window_Help.new
    @item_window = Window_Item.new(0, 56, 544, 232)
    @item_window.help_window = @help_window
    @actor_command_window.active = false
  end
  #--------------------------------------------------------------------------
  # * End Item Selection
  #--------------------------------------------------------------------------
  def end_item_selection
    if @item_window != nil
      @item_window.dispose
      @item_window = nil
      @help_window.dispose
      @help_window = nil
    end
    @actor_command_window.active = true
  end
  #--------------------------------------------------------------------------
  # * Update Item Selection
  #--------------------------------------------------------------------------
  def update_item_selection
    @item_window.active = true
    @item_window.update
    @help_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_item_selection
    elsif Input.trigger?(Input::C)
      @item = @item_window.item
      if @item != nil
        $game_party.last_item_id = @item.id
      end
      if $game_party.item_can_use?(@item)
        Sound.play_decision
        determine_item
      else
        Sound.play_buzzer
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Confirm Item
  #--------------------------------------------------------------------------
  def determine_item
    @active_battler.action.set_item(@item.id)
    @item_window.active = false
    if @item.need_selection?
      if @item.for_opponent?
        start_target_enemy_selection
      else
        start_target_actor_selection
      end
    else
      end_item_selection
      next_actor
    end
  end
  #--------------------------------------------------------------------------
  # * Battle Start Processing
  #--------------------------------------------------------------------------
  def process_battle_start
    @message_window.clear
    wait(10)
    for name in $game_troop.enemy_names
      text = sprintf(Vocab::Emerge, name)
      $game_message.texts.push(text)
    end
    if $game_troop.preemptive
      text = sprintf(Vocab::Preemptive, $game_party.name)
      $game_message.texts.push(text)
    elsif $game_troop.surprise
      text = sprintf(Vocab::Surprise, $game_party.name)
      $game_message.texts.push(text)
    end
    wait_for_message
    @message_window.clear
    make_escape_ratio
    process_battle_event
    start_party_command_selection
  end
  #--------------------------------------------------------------------------
  # * Create Escape Ratio
  #--------------------------------------------------------------------------
  def make_escape_ratio
    actors_agi = $game_party.average_agi
    enemies_agi = $game_troop.average_agi
    @escape_ratio = 150 - 100 * enemies_agi / actors_agi
  end
  #--------------------------------------------------------------------------
  # * Escape Processing
  #--------------------------------------------------------------------------
  def process_escape
    @info_viewport.visible = false
    @message_window.visible = true
    text = sprintf(Vocab::EscapeStart, $game_party.name)
    $game_message.texts.push(text)
    if $game_troop.preemptive
      success = true
    else
      success = (rand(100) < @escape_ratio)
    end
    Sound.play_escape
    if success
      wait_for_message
      battle_end(1)
    else
      @escape_ratio += 10
      $game_message.texts.push('\.' + Vocab::EscapeFailure)
      wait_for_message
      $game_party.clear_actions
      start_main
    end
  end
  #--------------------------------------------------------------------------
  # * Victory Processing
  #--------------------------------------------------------------------------
  def process_victory
    @info_viewport.visible = false
    @message_window.visible = true
    RPG::BGM.stop
    $game_system.battle_end_me.play
    unless $BTEST
      $game_temp.map_bgm.play
      $game_temp.map_bgs.play
    end
    display_exp_and_gold
    display_drop_items
    display_level_up
    battle_end(0)
  end
  #--------------------------------------------------------------------------
  # * Display Gained Experience and Gold
  #--------------------------------------------------------------------------
  def display_exp_and_gold
    exp = $game_troop.exp_total
    gold = $game_troop.gold_total
    $game_party.gain_gold(gold)
    text = sprintf(Vocab::Victory, $game_party.name)
    $game_message.texts.push('\|' + text)
    if exp > 0
      text = sprintf(Vocab::ObtainExp, exp)
      $game_message.texts.push('\.' + text)
    end
    if gold > 0
      text = sprintf(Vocab::ObtainGold, gold, Vocab::gold)
      $game_message.texts.push('\.' + text)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # * Display Gained Drop Items
  #--------------------------------------------------------------------------
  def display_drop_items
    drop_items = $game_troop.make_drop_items
    for item in drop_items
      $game_party.gain_item(item, 1)
      text = sprintf(Vocab::ObtainItem, item.name)
      $game_message.texts.push(text)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # * Display Level Up
  #--------------------------------------------------------------------------
  def display_level_up
    exp = $game_troop.exp_total
    for actor in $game_party.existing_members
      last_level = actor.level
      last_skills = actor.skills
      actor.gain_exp(exp, true)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # * Defeat Processing
  #--------------------------------------------------------------------------
  def process_defeat
    @info_viewport.visible = false
    @message_window.visible = true
    text = sprintf(Vocab::Defeat, $game_party.name)
    $game_message.texts.push(text)
    wait_for_message
    battle_end(2)
  end
  #--------------------------------------------------------------------------
  # * Execute Screen Switch
  #--------------------------------------------------------------------------
  def update_scene_change
    case $game_temp.next_scene
    when "map"
      call_map
    when "gameover"
      call_gameover
    when "title"
      call_title
    else
      $game_temp.next_scene = nil
    end
  end
  #--------------------------------------------------------------------------
  # * Switch to Map Screen
  #--------------------------------------------------------------------------
  def call_map
    $game_temp.next_scene = nil
    battle_end(1)
  end
  #--------------------------------------------------------------------------
  # * Switch to Game Over Screen
  #--------------------------------------------------------------------------
  def call_gameover
    $game_temp.next_scene = nil
    $scene = Scene_Gameover.new
    @message_window.clear
  end
  #--------------------------------------------------------------------------
  # * Switch to Title Screen
  #--------------------------------------------------------------------------
  def call_title
    $game_temp.next_scene = nil
    $scene = Scene_Title.new
    @message_window.clear
    Graphics.fadeout(60)
  end
  #--------------------------------------------------------------------------
  # * Start Execution of Battle Processing
  #--------------------------------------------------------------------------
  def start_main
    $game_troop.increase_turn
    @info_viewport.visible = false
    @info_viewport.ox = 0
    @message_window.visible = true
    @party_command_window.active = false
    @actor_command_window.active = false
    @status_window.index = @actor_index = -1
    @active_battler = nil
    @message_window.clear
    $game_troop.make_actions
    make_action_orders
    wait(20)
  end
  #--------------------------------------------------------------------------
  # * Create Action Orders
  #--------------------------------------------------------------------------
  def make_action_orders
    @action_battlers = []
    unless $game_troop.surprise
      @action_battlers += $game_party.members
    end
    unless $game_troop.preemptive
      @action_battlers += $game_troop.members
    end
    for battler in @action_battlers
      battler.action.make_speed
    end
    @action_battlers.sort! do |a,b|
      b.action.speed - a.action.speed
    end
  end
  #--------------------------------------------------------------------------
  # * Battle Action Processing
  #--------------------------------------------------------------------------
  def process_action
    return if judge_win_loss
    return if $game_temp.next_scene != nil
    set_next_active_battler
    if @active_battler == nil
      turn_end
      return
    end
    @message_window.clear
    wait(5)
    @active_battler.white_flash = true
    unless @active_battler.action.forcing
      @active_battler.action.prepare
    end
    if @active_battler.action.valid?
      execute_action
    end
    unless @active_battler.action.forcing
      @message_window.clear
      remove_states_auto
      display_current_state
    end
    @active_battler.white_flash = false
    @message_window.clear
  end
  #--------------------------------------------------------------------------
  # * Execute Battle Actions
  #--------------------------------------------------------------------------
  def execute_action
    case @active_battler.action.kind
    when 0  # Basic
      case @active_battler.action.basic
      when 0  # Attack
        execute_action_attack
      when 1  # Guard
        execute_action_guard
      when 2  # Escape
        execute_action_escape
      when 3  # Wait
        execute_action_wait
      end
    when 1  # Skill
      execute_action_skill
    when 2  # Item
      execute_action_item
    end
  end
  #--------------------------------------------------------------------------
  # * End Turn
  #--------------------------------------------------------------------------
  def turn_end
    $game_troop.turn_ending = true
    $game_party.slip_damage_effect
    $game_troop.slip_damage_effect
    $game_party.do_auto_recovery
    $game_troop.preemptive = false
    $game_troop.surprise = false
    process_battle_event
    $game_troop.turn_ending = false
    start_party_command_selection
  end
  #--------------------------------------------------------------------------
  # * Set Next Battler to Act
  #    When the [Force Battle Action] event command is being performed, set
  #    that battler and remove him from the list. Otherwise, get from top of
  #    list. If an actor that is not currently in the party is obtained (may
  #    occur if the index is nil, just after leaving via a battle event, etc.)
  #    it is skipped.
  #--------------------------------------------------------------------------
  def set_next_active_battler
    loop do
      if $game_troop.forcing_battler != nil
        @active_battler = $game_troop.forcing_battler
        @action_battlers.delete(@active_battler)
        $game_troop.forcing_battler = nil
      else
        @active_battler = @action_battlers.shift
      end
      return if @active_battler == nil
      return if @active_battler.index != nil
    end
  end
  #--------------------------------------------------------------------------
  # * Natural Removal of States
  #--------------------------------------------------------------------------
  def remove_states_auto
    last_st = @active_battler.states
    @active_battler.remove_states_auto
    if @active_battler.states != last_st
      wait(5)
      display_state_changes(@active_battler)
      wait(30)
      @message_window.clear
    end
  end
  #--------------------------------------------------------------------------
  # * Show Current State
  #--------------------------------------------------------------------------
  def display_current_state
    state_text = @active_battler.most_important_state_text
    unless state_text.empty?
      wait(5)
      text = @active_battler.name + state_text
      @message_window.add_instant_text(text)
      wait(45)
      @message_window.clear
    end
  end
  #--------------------------------------------------------------------------
  # * Execute Battle Action: Attack
  #--------------------------------------------------------------------------
  def execute_action_attack
    text = sprintf(Vocab::DoAttack, @active_battler.name)
    @message_window.add_instant_text(text)
    targets = @active_battler.action.make_targets
    display_attack_animation(targets)
    wait(20)
    for target in targets
      target.attack_effect(@active_battler)
      display_action_effects(target)
    end
  end
  #--------------------------------------------------------------------------
  # * Execute Battle Action: Guard
  #--------------------------------------------------------------------------
  def execute_action_guard
    text = sprintf(Vocab::DoGuard, @active_battler.name)
    @message_window.add_instant_text(text)
    wait(45)
  end
  #--------------------------------------------------------------------------
  # * Execute Battle Action: Escape
  #--------------------------------------------------------------------------
  def execute_action_escape
    text = sprintf(Vocab::DoEscape, @active_battler.name)
    @message_window.add_instant_text(text)
    @active_battler.escape
    Sound.play_escape
    wait(45)
  end
  #--------------------------------------------------------------------------
  # * Execute Battle Action: Wait
  #--------------------------------------------------------------------------
  def execute_action_wait
    text = sprintf(Vocab::DoWait, @active_battler.name)
    @message_window.add_instant_text(text)
    wait(45)
  end
  #--------------------------------------------------------------------------
  # * Execute Battle Action: Skill
  #--------------------------------------------------------------------------
  def execute_action_skill
    skill = @active_battler.action.skill
    text = @active_battler.name + skill.message1
    @message_window.add_instant_text(text)
    unless skill.message2.empty?
      wait(10)
      @message_window.add_instant_text(skill.message2)
    end
    targets = @active_battler.action.make_targets
    display_animation(targets, skill.animation_id)
    @active_battler.mp -= @active_battler.calc_mp_cost(skill)
    $game_temp.common_event_id = skill.common_event_id
    for target in targets
      target.skill_effect(@active_battler, skill)
      display_action_effects(target, skill)
    end
  end
  #--------------------------------------------------------------------------
  # * Execute Battle Action: Item
  #--------------------------------------------------------------------------
  def execute_action_item
    item = @active_battler.action.item
    text = sprintf(Vocab::UseItem, @active_battler.name, item.name)
    @message_window.add_instant_text(text)
    targets = @active_battler.action.make_targets
    display_animation(targets, item.animation_id)
    $game_party.consume_item(item)
    $game_temp.common_event_id = item.common_event_id
    for target in targets
      target.item_effect(@active_battler, item)
      display_action_effects(target, item)
    end
  end
  #--------------------------------------------------------------------------
  # * Show Animation
  #     targets      : Target array
  #     animation_id : Animation ID (-1: same as normal attack)
  #--------------------------------------------------------------------------
  def display_animation(targets, animation_id)
    if animation_id < 0
      display_attack_animation(targets)
    else
      display_normal_animation(targets, animation_id)
    end
    wait(20)
    wait_for_animation
  end
  #--------------------------------------------------------------------------
  # * Show Attack Animation
  #     targets : Target array
  #    If enemy, play the [Enemy normal attack] sound effect and wait 
  #    a moment. If actor, take dual wielding into account (display left hand
  #    weapon reversed)
  #--------------------------------------------------------------------------
  def display_attack_animation(targets)
    if @active_battler.is_a?(Game_Enemy)
      Sound.play_enemy_attack
      wait(15, true)
    else
      aid1 = @active_battler.atk_animation_id
      aid2 = @active_battler.atk_animation_id2
      display_normal_animation(targets, aid1, false)
      display_normal_animation(targets, aid2, true)
    end
    wait_for_animation
  end
  #--------------------------------------------------------------------------
  # * Show Normal Animation
  #     targets      : Target array
  #     animation_id : Animation ID
  #     mirror       : Flip horizontal
  #--------------------------------------------------------------------------
  def display_normal_animation(targets, animation_id, mirror = false)
    animation = $data_animations[animation_id]
    if animation != nil
      to_screen = (animation.position == 3)       # Is the positon "screen"?
      for target in targets.uniq
        target.animation_id = animation_id
        target.animation_mirror = mirror
        wait(20, true) unless to_screen           # If for one, wait
      end
      wait(20, true) if to_screen                 # If for all, wait
    end
  end
  #--------------------------------------------------------------------------
  # * Show Action Results
  #     target : Target
  #     obj    : Skill or item
  #--------------------------------------------------------------------------
  def display_action_effects(target, obj = nil)
    unless target.skipped
      line_number = @message_window.line_number
      wait(5)
      display_critical(target, obj)
      display_damage(target, obj)
      display_state_changes(target, obj)
      if line_number == @message_window.line_number
        display_failure(target, obj) unless target.states_active?
      end
      if line_number != @message_window.line_number
        wait(30)
      end
      @message_window.back_to(line_number)
    end
  end
  #--------------------------------------------------------------------------
  # * Show Critical Hit
  #     target : Target
  #     obj    : Skill or item
  #--------------------------------------------------------------------------
  def display_critical(target, obj = nil)
    if target.critical
      if target.actor?
        text = Vocab::CriticalToActor
      else
        text = Vocab::CriticalToEnemy
      end
      @message_window.add_instant_text(text)
      wait(20)
    end
  end
  #--------------------------------------------------------------------------
  # * Show Damage
  #     target : Target
  #     obj    : Skill or item
  #--------------------------------------------------------------------------
  def display_damage(target, obj = nil)
    if target.missed
      display_miss(target, obj)
    elsif target.evaded
      display_evasion(target, obj)
    else
      display_hp_damage(target, obj)
      display_mp_damage(target, obj)
    end
  end
  #--------------------------------------------------------------------------
  # * Show Miss
  #     target : Target
  #     obj    : Skill or item
  #--------------------------------------------------------------------------
  def display_miss(target, obj = nil)
    if obj == nil or obj.physical_attack
      if target.actor?
        text = sprintf(Vocab::ActorNoHit, target.name)
      else
        text = sprintf(Vocab::EnemyNoHit, target.name)
      end
      Sound.play_miss
    else
      text = sprintf(Vocab::ActionFailure, target.name)
    end
    @message_window.add_instant_text(text)
    wait(30)
  end
  #--------------------------------------------------------------------------
  # * Show Escape
  #     target : Target
  #     obj    : Skill or item
  #--------------------------------------------------------------------------
  def display_evasion(target, obj = nil)
    if target.actor?
      text = sprintf(Vocab::ActorEvasion, target.name)
    else
      text = sprintf(Vocab::EnemyEvasion, target.name)
    end
    Sound.play_evasion
    @message_window.add_instant_text(text)
    wait(30)
  end
  #--------------------------------------------------------------------------
  # * Show HP Damage
  #     target : Target
  #     obj    : Skill or item
  #--------------------------------------------------------------------------
  def display_hp_damage(target, obj = nil)
    if target.hp_damage == 0                # No damage
      return if obj != nil and obj.damage_to_mp
      return if obj != nil and obj.base_damage == 0
      fmt = target.actor? ? Vocab::ActorNoDamage : Vocab::EnemyNoDamage
      text = sprintf(fmt, target.name)
    elsif target.absorbed                   # Absorb
      fmt = target.actor? ? Vocab::ActorDrain : Vocab::EnemyDrain
      text = sprintf(fmt, target.name, Vocab::hp, target.hp_damage)
    elsif target.hp_damage > 0              # Damage
      if target.actor?
        text = sprintf(Vocab::ActorDamage, target.name, target.hp_damage)
        Sound.play_actor_damage
        $game_troop.screen.start_shake(5, 5, 10)
      else
        text = sprintf(Vocab::EnemyDamage, target.name, target.hp_damage)
        Sound.play_enemy_damage
        target.blink = true
      end
    else                                    # Recovery
      fmt = target.actor? ? Vocab::ActorRecovery : Vocab::EnemyRecovery
      text = sprintf(fmt, target.name, Vocab::hp, -target.hp_damage)
      Sound.play_recovery
    end
    @message_window.add_instant_text(text)
    wait(30)
  end
  #--------------------------------------------------------------------------
  # * Show MP Damage
  #     target : Target
  #     obj    : Skill or item
  #--------------------------------------------------------------------------
  def display_mp_damage(target, obj = nil)
    return if target.dead?
    return if target.mp_damage == 0
    if target.absorbed                      # Absorb
      fmt = target.actor? ? Vocab::ActorDrain : Vocab::EnemyDrain
      text = sprintf(fmt, target.name, Vocab::mp, target.mp_damage)
    elsif target.mp_damage > 0              # Damage
      fmt = target.actor? ? Vocab::ActorLoss : Vocab::EnemyLoss
      text = sprintf(fmt, target.name, Vocab::mp, target.mp_damage)
    else                                    # Recovery
      fmt = target.actor? ? Vocab::ActorRecovery : Vocab::EnemyRecovery
      text = sprintf(fmt, target.name, Vocab::mp, -target.mp_damage)
      Sound.play_recovery
    end
    @message_window.add_instant_text(text)
    wait(30)
  end
  #--------------------------------------------------------------------------
  # * Show State Change
  #     target : Target
  #     obj    : Skill or item
  #--------------------------------------------------------------------------
  def display_state_changes(target, obj = nil)
    return if target.missed or target.evaded
    return unless target.states_active?
    if @message_window.line_number < 4
      @message_window.add_instant_text("")
    end
    display_added_states(target, obj)
    display_removed_states(target, obj)
    display_remained_states(target, obj)
    if @message_window.last_instant_text.empty?
      @message_window.back_one
    else
      wait(10)
    end
  end
  #--------------------------------------------------------------------------
  # * Show Added State
  #     target : Target
  #     obj    : Skill or item
  #--------------------------------------------------------------------------
  def display_added_states(target, obj = nil)
    for state in target.added_states
      if target.actor?
        next if state.message1.empty?
        text = target.name + state.message1
      else
        next if state.message2.empty?
        text = target.name + state.message2
      end
      if state.id == 1                      # Incapacitated
        target.perform_collapse
      end
      @message_window.replace_instant_text(text)
      wait(20)
    end
  end
  #--------------------------------------------------------------------------
  # * Show Removed State
  #     target : Target
  #     obj    : Skill or item
  #--------------------------------------------------------------------------
  def display_removed_states(target, obj = nil)
    for state in target.removed_states
      next if state.message4.empty?
      text = target.name + state.message4
      @message_window.replace_instant_text(text)
      wait(20)
    end
  end
  #--------------------------------------------------------------------------
  # * Show Unchanged State
  #     target : Target
  #     obj    : Skill or item
  #    Used when trying to put someone to sleep who is already asleep, etc.
  #--------------------------------------------------------------------------
  def display_remained_states(target, obj = nil)
    for state in target.remained_states
      next if state.message3.empty?
      text = target.name + state.message3
      @message_window.replace_instant_text(text)
      wait(20)
    end
  end
  #--------------------------------------------------------------------------
  # * Show Failure
  #     target : Target (actor)
  #     obj    : Skill or item
  #--------------------------------------------------------------------------
  def display_failure(target, obj)
    text = sprintf(Vocab::ActionFailure, target.name)
    @message_window.add_instant_text(text)
    wait(20)
  end
end
