#encoding:UTF-8
# Window_BattleLog
#==============================================================================
# ** Window_BattleLog
#------------------------------------------------------------------------------
#  This window is for displaying battle progress. No frame is displayed, but it
# is handled as a window for convenience.
#==============================================================================

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, window_height)
    self.z = 200
    self.opacity = 0
    @lines = []
    @num_wait = 0
    create_back_bitmap
    create_back_sprite
    refresh
  end
  #--------------------------------------------------------------------------
  # * Free
  #--------------------------------------------------------------------------
  def dispose
    super
    dispose_back_bitmap
    dispose_back_sprite
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  #--------------------------------------------------------------------------
  # * Get Window Height
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(max_line_number)
  end
  #--------------------------------------------------------------------------
  # * Get Maximum Number of Lines
  #--------------------------------------------------------------------------
  def max_line_number
    return 6
  end
  #--------------------------------------------------------------------------
  # * Create Background Bitmap
  #--------------------------------------------------------------------------
  def create_back_bitmap
    @back_bitmap = Bitmap.new(width, height)
  end
  #--------------------------------------------------------------------------
  # * Create Background Sprite
  #--------------------------------------------------------------------------
  def create_back_sprite
    @back_sprite = Sprite.new
    @back_sprite.bitmap = @back_bitmap
    @back_sprite.y = y
    @back_sprite.z = z - 1
  end
  #--------------------------------------------------------------------------
  # * Free Background Bitmap
  #--------------------------------------------------------------------------
  def dispose_back_bitmap
    @back_bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # * Free Background Sprite
  #--------------------------------------------------------------------------
  def dispose_back_sprite
    @back_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Clear
  #--------------------------------------------------------------------------
  def clear
    @num_wait = 0
    @lines.clear
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Number of Data Lines
  #--------------------------------------------------------------------------
  def line_number
    @lines.size
  end
  #--------------------------------------------------------------------------
  # * Go Back One Line
  #--------------------------------------------------------------------------
  def back_one
    @lines.pop
    refresh
  end
  #--------------------------------------------------------------------------
  # * Return to Designated Line
  #--------------------------------------------------------------------------
  def back_to(line_number)
    @lines.pop while @lines.size > line_number
    refresh
  end
  #--------------------------------------------------------------------------
  # * Add Text
  #--------------------------------------------------------------------------
  def add_text(text)
    @lines.push(text)
    refresh
  end
  #--------------------------------------------------------------------------
  # * Replace Text
  #    Replaces the last line with different text.
  #--------------------------------------------------------------------------
  def replace_text(text)
    @lines.pop
    @lines.push(text)
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Text From Last Line
  #--------------------------------------------------------------------------
  def last_text
    @lines[-1]
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    draw_background
    contents.clear
    @lines.size.times {|i| draw_line(i) }
  end
  #--------------------------------------------------------------------------
  # * Draw Background
  #--------------------------------------------------------------------------
  def draw_background
    @back_bitmap.clear
    @back_bitmap.fill_rect(back_rect, back_color)
  end
  #--------------------------------------------------------------------------
  # * Get Background Rectangle
  #--------------------------------------------------------------------------
  def back_rect
    Rect.new(0, padding, width, line_number * line_height)
  end
  #--------------------------------------------------------------------------
  # * Get Background Color
  #--------------------------------------------------------------------------
  def back_color
    Color.new(0, 0, 0, back_opacity)
  end
  #--------------------------------------------------------------------------
  # * Get Background Opacity
  #--------------------------------------------------------------------------
  def back_opacity
    return 64
  end
  #--------------------------------------------------------------------------
  # * Draw Line
  #--------------------------------------------------------------------------
  def draw_line(line_number)
    rect = item_rect_for_text(line_number)
    contents.clear_rect(rect)
    draw_text_ex(rect.x, rect.y, @lines[line_number])
  end
  #--------------------------------------------------------------------------
  # * Set Wait Method
  #--------------------------------------------------------------------------
  def method_wait=(method)
    @method_wait = method
  end
  #--------------------------------------------------------------------------
  # * Set Wait Method for Effect Execution
  #--------------------------------------------------------------------------
  def method_wait_for_effect=(method)
    @method_wait_for_effect = method
  end
  #--------------------------------------------------------------------------
  # * Wait
  #--------------------------------------------------------------------------
  def wait
    @num_wait += 1
    @method_wait.call(message_speed) if @method_wait
  end
  #--------------------------------------------------------------------------
  # * Wait Until Effect Execution Ends
  #--------------------------------------------------------------------------
  def wait_for_effect
    @method_wait_for_effect.call if @method_wait_for_effect
  end
  #--------------------------------------------------------------------------
  # * Get Message Speed
  #--------------------------------------------------------------------------
  def message_speed
    return 20
  end
  #--------------------------------------------------------------------------
  # * Wait and Clear
  #    Clear after inputing minimum necessary wait for the message to be read.
  #--------------------------------------------------------------------------
  def wait_and_clear
    wait while @num_wait < 2 if line_number > 0
    clear
  end
  #--------------------------------------------------------------------------
  # * Display Current State
  #--------------------------------------------------------------------------
  def display_current_state(subject)
    unless subject.most_important_state_text.empty?
      add_text(subject.name + subject.most_important_state_text)
      wait
    end
  end
  #--------------------------------------------------------------------------
  # * Display Skill/Item Use
  #--------------------------------------------------------------------------
  def display_use_item(subject, item)
    if item.is_a?(RPG::Skill)
      add_text(subject.name + item.message1)
      unless item.message2.empty?
        wait
        add_text(item.message2)
      end
    else
      add_text(sprintf(Vocab::UseItem, subject.name, item.name))
    end
  end
  #--------------------------------------------------------------------------
  # * Display Counterattack
  #--------------------------------------------------------------------------
  def display_counter(target, item)
    Sound.play_evasion
    add_text(sprintf(Vocab::CounterAttack, target.name))
    wait
    back_one
  end
  #--------------------------------------------------------------------------
  # * Display Reflection
  #--------------------------------------------------------------------------
  def display_reflection(target, item)
    Sound.play_reflection
    add_text(sprintf(Vocab::MagicReflection, target.name))
    wait
    back_one
  end
  #--------------------------------------------------------------------------
  # * Display Substitute
  #--------------------------------------------------------------------------
  def display_substitute(substitute, target)
    add_text(sprintf(Vocab::Substitute, substitute.name, target.name))
    wait
    back_one
  end
  #--------------------------------------------------------------------------
  # * Display Action Results
  #--------------------------------------------------------------------------
  def display_action_results(target, item)
    if target.result.used
      last_line_number = line_number
      display_critical(target, item)
      display_damage(target, item)
      display_affected_status(target, item)
      display_failure(target, item)
      wait if line_number > last_line_number
      back_to(last_line_number)
    end
  end
  #--------------------------------------------------------------------------
  # * Display Failure
  #--------------------------------------------------------------------------
  def display_failure(target, item)
    if target.result.hit? && !target.result.success
      add_text(sprintf(Vocab::ActionFailure, target.name))
      wait
    end
  end
  #--------------------------------------------------------------------------
  # * Display Critical Hit
  #--------------------------------------------------------------------------
  def display_critical(target, item)
    if target.result.critical
      text = target.actor? ? Vocab::CriticalToActor : Vocab::CriticalToEnemy
      add_text(text)
      wait
    end
  end
  #--------------------------------------------------------------------------
  # * Display Damage
  #--------------------------------------------------------------------------
  def display_damage(target, item)
    if target.result.missed
      display_miss(target, item)
    elsif target.result.evaded
      display_evasion(target, item)
    else
      display_hp_damage(target, item)
      display_mp_damage(target, item)
      display_tp_damage(target, item)
    end
  end
  #--------------------------------------------------------------------------
  # * Display Miss
  #--------------------------------------------------------------------------
  def display_miss(target, item)
    if !item || item.physical?
      fmt = target.actor? ? Vocab::ActorNoHit : Vocab::EnemyNoHit
      Sound.play_miss
    else
      fmt = Vocab::ActionFailure
    end
    add_text(sprintf(fmt, target.name))
    wait
  end
  #--------------------------------------------------------------------------
  # * Display Evasion
  #--------------------------------------------------------------------------
  def display_evasion(target, item)
    if !item || item.physical?
      fmt = Vocab::Evasion
      Sound.play_evasion
    else
      fmt = Vocab::MagicEvasion
      Sound.play_magic_evasion
    end
    add_text(sprintf(fmt, target.name))
    wait
  end
  #--------------------------------------------------------------------------
  # * Display HP Damage
  #--------------------------------------------------------------------------
  def display_hp_damage(target, item)
    return if target.result.hp_damage == 0 && item && !item.damage.to_hp?
    if target.result.hp_damage > 0 && target.result.hp_drain == 0
      target.perform_damage_effect
    end
    Sound.play_recovery if target.result.hp_damage < 0
    add_text(target.result.hp_damage_text)
    wait
  end
  #--------------------------------------------------------------------------
  # * Display MP Damage
  #--------------------------------------------------------------------------
  def display_mp_damage(target, item)
    return if target.dead? || target.result.mp_damage == 0
    Sound.play_recovery if target.result.mp_damage < 0
    add_text(target.result.mp_damage_text)
    wait
  end
  #--------------------------------------------------------------------------
  # * Display TP Damage
  #--------------------------------------------------------------------------
  def display_tp_damage(target, item)
    return if target.dead? || target.result.tp_damage == 0
    Sound.play_recovery if target.result.tp_damage < 0
    add_text(target.result.tp_damage_text)
    wait
  end
  #--------------------------------------------------------------------------
  # * Display Affected Status
  #--------------------------------------------------------------------------
  def display_affected_status(target, item)
    if target.result.status_affected?
      add_text("") if line_number < max_line_number
      display_changed_states(target)
      display_changed_buffs(target)
      back_one if last_text.empty?
    end
  end
  #--------------------------------------------------------------------------
  # * Display Automatically Affected Status
  #--------------------------------------------------------------------------
  def display_auto_affected_status(target)
    if target.result.status_affected?
      display_affected_status(target, nil)
      wait if line_number > 0
    end
  end
  #--------------------------------------------------------------------------
  # * Display Added/Removed State
  #--------------------------------------------------------------------------
  def display_changed_states(target)
    display_added_states(target)
    display_removed_states(target)
  end
  #--------------------------------------------------------------------------
  # * Display Added State
  #--------------------------------------------------------------------------
  def display_added_states(target)
    target.result.added_state_objects.each do |state|
      state_msg = target.actor? ? state.message1 : state.message2
      target.perform_collapse_effect if state.id == target.death_state_id
      next if state_msg.empty?
      replace_text(target.name + state_msg)
      wait
      wait_for_effect
    end
  end
  #--------------------------------------------------------------------------
  # * Display Removed State
  #--------------------------------------------------------------------------
  def display_removed_states(target)
    target.result.removed_state_objects.each do |state|
      next if state.message4.empty?
      replace_text(target.name + state.message4)
      wait
    end
  end
  #--------------------------------------------------------------------------
  # * Display Buff/Debuff
  #--------------------------------------------------------------------------
  def display_changed_buffs(target)
    display_buffs(target, target.result.added_buffs, Vocab::BuffAdd)
    display_buffs(target, target.result.added_debuffs, Vocab::DebuffAdd)
    display_buffs(target, target.result.removed_buffs, Vocab::BuffRemove)
  end
  #--------------------------------------------------------------------------
  # * Display Buff/Debuff (Individual)
  #--------------------------------------------------------------------------
  def display_buffs(target, buffs, fmt)
    buffs.each do |param_id|
      replace_text(sprintf(fmt, target.name, Vocab::param(param_id)))
      wait
    end
  end
end
