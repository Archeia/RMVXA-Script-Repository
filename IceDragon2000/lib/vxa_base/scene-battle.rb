#encoding:UTF-8
# Scene_Battle
#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    create_spriteset
    create_all_windows
    BattleManager.method_wait_for_message = method(:wait_for_message)
  end
  #--------------------------------------------------------------------------
  # * Post-Start Processing
  #--------------------------------------------------------------------------
  def post_start
    super
    battle_start
  end
  #--------------------------------------------------------------------------
  # * Pre-Termination Processing
  #--------------------------------------------------------------------------
  def pre_terminate
    super
    Graphics.fadeout(30) if SceneManager.scene_is?(Scene_Map)
    Graphics.fadeout(60) if SceneManager.scene_is?(Scene_Title)
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_spriteset
    @info_viewport.dispose
    RPG::ME.stop
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if BattleManager.in_turn?
      process_event
      process_action
    end
    BattleManager.judge_win_loss
  end
  #--------------------------------------------------------------------------
  # * Update Frame (Basic)
  #--------------------------------------------------------------------------
  def update_basic
    super
    $game_timer.update
    $game_troop.update
    @spriteset.update
    update_info_viewport
    update_message_open
  end
  #--------------------------------------------------------------------------
  # * Update Frame (for Wait)
  #--------------------------------------------------------------------------
  def update_for_wait
    update_basic
  end
  #--------------------------------------------------------------------------
  # * Wait
  #--------------------------------------------------------------------------
  def wait(duration)
    duration.times {|i| update_for_wait if i < duration / 2 || !show_fast? }
  end
  #--------------------------------------------------------------------------
  # * Determine if Fast Forward
  #--------------------------------------------------------------------------
  def show_fast?
    Input.press?(:A) || Input.press?(:C)
  end
  #--------------------------------------------------------------------------
  # * Wait (No Fast Forward)
  #--------------------------------------------------------------------------
  def abs_wait(duration)
    duration.times {|i| update_for_wait }
  end
  #--------------------------------------------------------------------------
  # * Short Wait (No Fast Forward)
  #--------------------------------------------------------------------------
  def abs_wait_short
    abs_wait(15)
  end
  #--------------------------------------------------------------------------
  # * Wait Until Message Display has Finished
  #--------------------------------------------------------------------------
  def wait_for_message
    @message_window.update
    update_for_wait while $game_message.visible
  end
  #--------------------------------------------------------------------------
  # * Wait Until Animation Display has Finished
  #--------------------------------------------------------------------------
  def wait_for_animation
    update_for_wait
    update_for_wait while @spriteset.animation?
  end
  #--------------------------------------------------------------------------
  # * Wait Until Effect Execution Ends
  #--------------------------------------------------------------------------
  def wait_for_effect
    update_for_wait
    update_for_wait while @spriteset.effect?
  end
  #--------------------------------------------------------------------------
  # * Update Information Display Viewport
  #--------------------------------------------------------------------------
  def update_info_viewport
    move_info_viewport(0)   if @party_command_window.active
    move_info_viewport(128) if @actor_command_window.active
    move_info_viewport(64)  if BattleManager.in_turn?
  end
  #--------------------------------------------------------------------------
  # * Move Information Display Viewport
  #--------------------------------------------------------------------------
  def move_info_viewport(ox)
    current_ox = @info_viewport.ox
    @info_viewport.ox = [ox, current_ox + 16].min if current_ox < ox
    @info_viewport.ox = [ox, current_ox - 16].max if current_ox > ox
  end
  #--------------------------------------------------------------------------
  # * Update Processing for Opening Message Window
  #    Set openness to 0 until the status window and so on are finished closing.
  #--------------------------------------------------------------------------
  def update_message_open
    if $game_message.busy? && !@status_window.close?
      @message_window.openness = 0
      @status_window.close
      @party_command_window.close
      @actor_command_window.close
    end
  end
  #--------------------------------------------------------------------------
  # * Create Sprite Set
  #--------------------------------------------------------------------------
  def create_spriteset
    @spriteset = Spriteset_Battle.new
  end
  #--------------------------------------------------------------------------
  # * Free Sprite Set
  #--------------------------------------------------------------------------
  def dispose_spriteset
    @spriteset.dispose
  end
  #--------------------------------------------------------------------------
  # * Create All Windows
  #--------------------------------------------------------------------------
  def create_all_windows
    create_message_window
    create_scroll_text_window
    create_log_window
    create_status_window
    create_info_viewport
    create_party_command_window
    create_actor_command_window
    create_help_window
    create_skill_window
    create_item_window
    create_actor_window
    create_enemy_window
  end
  #--------------------------------------------------------------------------
  # * Create Message Window
  #--------------------------------------------------------------------------
  def create_message_window
    @message_window = Window_Message.new
  end
  #--------------------------------------------------------------------------
  # * Create Scrolling Text Window
  #--------------------------------------------------------------------------
  def create_scroll_text_window
    @scroll_text_window = Window_ScrollText.new
  end
  #--------------------------------------------------------------------------
  # * Create Log Window
  #--------------------------------------------------------------------------
  def create_log_window
    @log_window = Window_BattleLog.new
    @log_window.method_wait = method(:wait)
    @log_window.method_wait_for_effect = method(:wait_for_effect)
  end
  #--------------------------------------------------------------------------
  # * Create Status Window
  #--------------------------------------------------------------------------
  def create_status_window
    @status_window = Window_BattleStatus.new
    @status_window.x = 128
  end
  #--------------------------------------------------------------------------
  # * Create Information Display Viewport
  #--------------------------------------------------------------------------
  def create_info_viewport
    @info_viewport = Viewport.new
    @info_viewport.rect.y = Graphics.height - @status_window.height
    @info_viewport.rect.height = @status_window.height
    @info_viewport.z = 100
    @info_viewport.ox = 64
    @status_window.viewport = @info_viewport
  end
  #--------------------------------------------------------------------------
  # * Create Party Commands Window
  #--------------------------------------------------------------------------
  def create_party_command_window
    @party_command_window = Window_PartyCommand.new
    @party_command_window.viewport = @info_viewport
    @party_command_window.set_handler(:fight,  method(:command_fight))
    @party_command_window.set_handler(:escape, method(:command_escape))
    @party_command_window.unselect
  end
  #--------------------------------------------------------------------------
  # * Create Actor Commands Window
  #--------------------------------------------------------------------------
  def create_actor_command_window
    @actor_command_window = Window_ActorCommand.new
    @actor_command_window.viewport = @info_viewport
    @actor_command_window.set_handler(:attack, method(:command_attack))
    @actor_command_window.set_handler(:skill,  method(:command_skill))
    @actor_command_window.set_handler(:guard,  method(:command_guard))
    @actor_command_window.set_handler(:item,   method(:command_item))
    @actor_command_window.set_handler(:cancel, method(:prior_command))
    @actor_command_window.x = Graphics.width
  end
  #--------------------------------------------------------------------------
  # * Create Help Window
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new
    @help_window.visible = false
  end
  #--------------------------------------------------------------------------
  # * Create Skill Window
  #--------------------------------------------------------------------------
  def create_skill_window
    @skill_window = Window_BattleSkill.new(@help_window, @info_viewport)
    @skill_window.set_handler(:ok,     method(:on_skill_ok))
    @skill_window.set_handler(:cancel, method(:on_skill_cancel))
  end
  #--------------------------------------------------------------------------
  # * Create Item Window
  #--------------------------------------------------------------------------
  def create_item_window
    @item_window = Window_BattleItem.new(@help_window, @info_viewport)
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
  end
  #--------------------------------------------------------------------------
  # * Create Actor Window
  #--------------------------------------------------------------------------
  def create_actor_window
    @actor_window = Window_BattleActor.new(@info_viewport)
    @actor_window.set_handler(:ok,     method(:on_actor_ok))
    @actor_window.set_handler(:cancel, method(:on_actor_cancel))
  end
  #--------------------------------------------------------------------------
  # * Create Enemy Window
  #--------------------------------------------------------------------------
  def create_enemy_window
    @enemy_window = Window_BattleEnemy.new(@info_viewport)
    @enemy_window.set_handler(:ok,     method(:on_enemy_ok))
    @enemy_window.set_handler(:cancel, method(:on_enemy_cancel))
  end
  #--------------------------------------------------------------------------
  # * Update Status Window Information
  #--------------------------------------------------------------------------
  def refresh_status
    @status_window.refresh
  end
  #--------------------------------------------------------------------------
  # * To Next Command Input
  #--------------------------------------------------------------------------
  def next_command
    if BattleManager.next_command
      start_actor_command_selection
    else
      turn_start
    end
  end
  #--------------------------------------------------------------------------
  # * To Previous Command Input
  #--------------------------------------------------------------------------
  def prior_command
    if BattleManager.prior_command
      start_actor_command_selection
    else
      start_party_command_selection
    end
  end
  #--------------------------------------------------------------------------
  # * Start Party Command Selection
  #--------------------------------------------------------------------------
  def start_party_command_selection
    unless scene_changing?
      refresh_status
      @status_window.unselect
      @status_window.open
      if BattleManager.input_start
        @actor_command_window.close
        @party_command_window.setup
      else
        @party_command_window.deactivate
        turn_start
      end
    end
  end
  #--------------------------------------------------------------------------
  # * [Fight] Command
  #--------------------------------------------------------------------------
  def command_fight
    next_command
  end
  #--------------------------------------------------------------------------
  # * [Escape] Command
  #--------------------------------------------------------------------------
  def command_escape
    turn_start unless BattleManager.process_escape
  end
  #--------------------------------------------------------------------------
  # * Start Actor Command Selection
  #--------------------------------------------------------------------------
  def start_actor_command_selection
    @status_window.select(BattleManager.actor.index)
    @party_command_window.close
    @actor_command_window.setup(BattleManager.actor)
  end
  #--------------------------------------------------------------------------
  # * [Attack] Command
  #--------------------------------------------------------------------------
  def command_attack
    BattleManager.actor.input.set_attack
    select_enemy_selection
  end
  #--------------------------------------------------------------------------
  # * [Skill] Command
  #--------------------------------------------------------------------------
  def command_skill
    @skill_window.actor = BattleManager.actor
    @skill_window.stype_id = @actor_command_window.current_ext
    @skill_window.refresh
    @skill_window.show.activate
  end
  #--------------------------------------------------------------------------
  # * [Guard] Command
  #--------------------------------------------------------------------------
  def command_guard
    BattleManager.actor.input.set_guard
    next_command
  end
  #--------------------------------------------------------------------------
  # * [Item] Command
  #--------------------------------------------------------------------------
  def command_item
    @item_window.refresh
    @item_window.show.activate
  end
  #--------------------------------------------------------------------------
  # * Start Actor Selection
  #--------------------------------------------------------------------------
  def select_actor_selection
    @actor_window.refresh
    @actor_window.show.activate
  end
  #--------------------------------------------------------------------------
  # * Actor [OK]
  #--------------------------------------------------------------------------
  def on_actor_ok
    BattleManager.actor.input.target_index = @actor_window.index
    @actor_window.hide
    @skill_window.hide
    @item_window.hide
    next_command
  end
  #--------------------------------------------------------------------------
  # * Actor [Cancel]
  #--------------------------------------------------------------------------
  def on_actor_cancel
    @actor_window.hide
    case @actor_command_window.current_symbol
    when :skill
      @skill_window.activate
    when :item
      @item_window.activate
    end
  end
  #--------------------------------------------------------------------------
  # * Start Enemy Selection
  #--------------------------------------------------------------------------
  def select_enemy_selection
    @enemy_window.refresh
    @enemy_window.show.activate
  end
  #--------------------------------------------------------------------------
  # * Enemy [OK]
  #--------------------------------------------------------------------------
  def on_enemy_ok
    BattleManager.actor.input.target_index = @enemy_window.enemy.index
    @enemy_window.hide
    @skill_window.hide
    @item_window.hide
    next_command
  end
  #--------------------------------------------------------------------------
  # * Enemy [Cancel]
  #--------------------------------------------------------------------------
  def on_enemy_cancel
    @enemy_window.hide
    case @actor_command_window.current_symbol
    when :attack
      @actor_command_window.activate
    when :skill
      @skill_window.activate
    when :item
      @item_window.activate
    end
  end
  #--------------------------------------------------------------------------
  # * Skill [OK]
  #--------------------------------------------------------------------------
  def on_skill_ok
    @skill = @skill_window.item
    BattleManager.actor.input.set_skill(@skill.id)
    BattleManager.actor.last_skill.object = @skill
    if !@skill.need_selection?
      @skill_window.hide
      next_command
    elsif @skill.for_opponent?
      select_enemy_selection
    else
      select_actor_selection
    end
  end
  #--------------------------------------------------------------------------
  # * Skill [Cancel]
  #--------------------------------------------------------------------------
  def on_skill_cancel
    @skill_window.hide
    @actor_command_window.activate
  end
  #--------------------------------------------------------------------------
  # * Item [OK]
  #--------------------------------------------------------------------------
  def on_item_ok
    @item = @item_window.item
    BattleManager.actor.input.set_item(@item.id)
    if !@item.need_selection?
      @item_window.hide
      next_command
    elsif @item.for_opponent?
      select_enemy_selection
    else
      select_actor_selection
    end
    $game_party.last_item.object = @item
  end
  #--------------------------------------------------------------------------
  # * Item [Cancel]
  #--------------------------------------------------------------------------
  def on_item_cancel
    @item_window.hide
    @actor_command_window.activate
  end
  #--------------------------------------------------------------------------
  # * Battle Start
  #--------------------------------------------------------------------------
  def battle_start
    BattleManager.battle_start
    process_event
    start_party_command_selection
  end
  #--------------------------------------------------------------------------
  # * Start Turn
  #--------------------------------------------------------------------------
  def turn_start
    @party_command_window.close
    @actor_command_window.close
    @status_window.unselect
    @subject =  nil
    BattleManager.turn_start
    @log_window.wait
    @log_window.clear
  end
  #--------------------------------------------------------------------------
  # * End Turn
  #--------------------------------------------------------------------------
  def turn_end
    all_battle_members.each do |battler|
      battler.on_turn_end
      refresh_status
      @log_window.display_auto_affected_status(battler)
      @log_window.wait_and_clear
    end
    BattleManager.turn_end
    process_event
    start_party_command_selection
  end
  #--------------------------------------------------------------------------
  # * Get All Battle Members Including Enemies and Allies
  #--------------------------------------------------------------------------
  def all_battle_members
    $game_party.members + $game_troop.members
  end
  #--------------------------------------------------------------------------
  # * Event Processing
  #--------------------------------------------------------------------------
  def process_event
    while !scene_changing?
      $game_troop.interpreter.update
      $game_troop.setup_battle_event
      wait_for_message
      wait_for_effect if $game_troop.all_dead?
      process_forced_action
      BattleManager.judge_win_loss
      break unless $game_troop.interpreter.running?
      update_for_wait
    end
  end
  #--------------------------------------------------------------------------
  # * Forced Action Processing
  #--------------------------------------------------------------------------
  def process_forced_action
    if BattleManager.action_forced?
      last_subject = @subject
      @subject = BattleManager.action_forced_battler
      BattleManager.clear_action_force
      process_action
      @subject = last_subject
    end
  end
  #--------------------------------------------------------------------------
  # * Battle Action Processing
  #--------------------------------------------------------------------------
  def process_action
    return if scene_changing?
    if !@subject || !@subject.current_action
      @subject = BattleManager.next_subject
    end
    return turn_end unless @subject
    if @subject.current_action
      @subject.current_action.prepare
      if @subject.current_action.valid?
        @status_window.open
        execute_action
      end
      @subject.remove_current_action
    end
    process_action_end unless @subject.current_action
  end
  #--------------------------------------------------------------------------
  # * Processing at End of Action
  #--------------------------------------------------------------------------
  def process_action_end
    @subject.on_action_end
    refresh_status
    @log_window.display_auto_affected_status(@subject)
    @log_window.wait_and_clear
    @log_window.display_current_state(@subject)
    @log_window.wait_and_clear
    BattleManager.judge_win_loss
  end
  #--------------------------------------------------------------------------
  # * Execute Battle Actions
  #--------------------------------------------------------------------------
  def execute_action
    @subject.sprite_effect_type = :whiten
    use_item
    @log_window.wait_and_clear
  end
  #--------------------------------------------------------------------------
  # * Use Skill/Item
  #--------------------------------------------------------------------------
  def use_item
    item = @subject.current_action.item
    @log_window.display_use_item(@subject, item)
    @subject.use_item(item)
    refresh_status
    targets = @subject.current_action.make_targets.compact
    show_animation(targets, item.animation_id)
    targets.each {|target| item.repeats.times { invoke_item(target, item) } }
  end
  #--------------------------------------------------------------------------
  # * Invoke Skill/Item
  #--------------------------------------------------------------------------
  def invoke_item(target, item)
    if rand < target.item_cnt(@subject, item)
      invoke_counter_attack(target, item)
    elsif rand < target.item_mrf(@subject, item)
      invoke_magic_reflection(target, item)
    else
      apply_item_effects(apply_substitute(target, item), item)
    end
    @subject.last_target_index = target.index
  end
  #--------------------------------------------------------------------------
  # * Apply Skill/Item Effect
  #--------------------------------------------------------------------------
  def apply_item_effects(target, item)
    target.item_apply(@subject, item)
    refresh_status
    @log_window.display_action_results(target, item)
  end
  #--------------------------------------------------------------------------
  # * Invoke Counterattack
  #--------------------------------------------------------------------------
  def invoke_counter_attack(target, item)
    @log_window.display_counter(target, item)
    attack_skill = $data_skills[target.attack_skill_id]
    @subject.item_apply(target, attack_skill)
    refresh_status
    @log_window.display_action_results(@subject, attack_skill)
  end
  #--------------------------------------------------------------------------
  # * Invoke Magic Reflection
  #--------------------------------------------------------------------------
  def invoke_magic_reflection(target, item)
    @subject.magic_reflection = true
    @log_window.display_reflection(target, item)
    apply_item_effects(@subject, item)
    @subject.magic_reflection = false
  end
  #--------------------------------------------------------------------------
  # * Apply Substitute
  #--------------------------------------------------------------------------
  def apply_substitute(target, item)
    if check_substitute(target, item)
      substitute = target.friends_unit.substitute_battler
      if substitute && target != substitute
        @log_window.display_substitute(substitute, target)
        return substitute
      end
    end
    target
  end
  #--------------------------------------------------------------------------
  # * Check Substitute Condition
  #--------------------------------------------------------------------------
  def check_substitute(target, item)
    target.hp < target.mhp / 4 && (!item || !item.certain?)
  end
  #--------------------------------------------------------------------------
  # * Show Animation
  #     targets      : Target array
  #     animation_id : Animation ID (-1:  Same as normal attack)
  #--------------------------------------------------------------------------
  def show_animation(targets, animation_id)
    if animation_id < 0
      show_attack_animation(targets)
    else
      show_normal_animation(targets, animation_id)
    end
    @log_window.wait
    wait_for_animation
  end
  #--------------------------------------------------------------------------
  # * Show Attack Animation
  #     targets : Target array
  #    Account for dual wield in the case of an actor (flip left hand weapon
  #    display). If enemy, play the [Enemy Attack] SE and wait briefly.
  #--------------------------------------------------------------------------
  def show_attack_animation(targets)
    if @subject.actor?
      show_normal_animation(targets, @subject.atk_animation_id1, false)
      show_normal_animation(targets, @subject.atk_animation_id2, true)
    else
      Sound.play_enemy_attack
      abs_wait_short
    end
  end
  #--------------------------------------------------------------------------
  # * Show Normal Animation
  #     targets      : Target array
  #     animation_id : Animation ID
  #     mirror       : Flip horizontal
  #--------------------------------------------------------------------------
  def show_normal_animation(targets, animation_id, mirror = false)
    animation = $data_animations[animation_id]
    if animation
      targets.each do |target|
        target.animation_id = animation_id
        target.animation_mirror = mirror
        abs_wait_short unless animation.to_screen?
      end
      abs_wait_short if animation.to_screen?
    end
  end
end
