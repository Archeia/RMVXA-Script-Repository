#encoding:UTF-8
class REI::BattlerUnit

  attr_reader :turn_phase
  attr_reader :made_action
  attr_reader :controlled_by
  attr_accessor :last_command
  attr_accessor :party_id

  def init_public_members
    super
    @turn_phase = nil
    @waiting_for_input = false
    @waiting_for_action = false
    @controlled_by = :ai
    @party_id = 0
  end
  def init_private_members
    super
    @made_action = false
  end
  def set_control( control )
    @controlled_by = control
    return self
  end
  def ready_action
    @made_action = true
  end
  def suspend_action
    @made_action = false
  end
  def party_index
    party.index(self)
  end
  def set_attack_action
    act = Game::Action.new( self ).set_attack
    self.actions << act
    ready_action
    act
  end
  def set_guard_action
    act = Game::Action.new( self ).set_guard
    self.actions << act
    ready_action
    act
  end
  def set_move_action
    act = Game::Action.new( self ).set_move
    act.parameter_code.set(11, 1)
    self.actions << act
    ready_action
    act
  end
  def set_xy_trigger_action
    act = Game::Action.new( self ).set_move
    self.actions << act
    ready_action
    act
  end
  def set_skip_action
    act = Game::Action.new( self ).set_skip
    self.actions << act
    ready_action
    act
  end
  attr_accessor :request_warp
  def set_rwarp_action
    #self.center_on!# if camera_focus? && self.actor?
    @request_warp = _map.rand_room_floor_pos
  end
  def set_nudge_action
    set_skill_action( $data_skills[nudge_skill_id] )
  end
  def set_tame_action
    set_skill_action( $data_skills[tame_skill_id] )
  end
  def set_skill_action( skill )
    act = Game::Action.new( self ).set_skill( skill.id )
    self.actions << act
    ready_action
    act
  end
  def set_item_action( item )
    act = Game::Action.new( self ).set_item( item.id )
    self.actions << act
    ready_action
    act
  end
  def set_obj_action( obj )
    case Ex_Database.obj_symbol(obj)
    when :item
      return set_item_action(obj)
    when :skill
      return set_skill_action(obj)
    end
  end
  def set_item_action_self( item )
    raise "Obsolete action called by #{caller(1)}"
    set_item_action( item ).parameter_code.set( 1, 11 )
  end
  def end_action
    @made_action = false
  end
  def update_turn_phase
    case @turn_phase
    when :start
      @made_action = false
    when :make_action
      if @controlled_by == :ai
        _map.static_character_table
        ai_make_action
        _map.release_character_table
      end
    when :action
    when :finalize
      @made_action = false
    when :end
      # // DO NOT ADD ANYTHING HERE
    end
  end
  def set_turn_phase( phase )
    @turn_phase = phase
    update_turn_phase
  end
  def on_turn_start
    set_turn_phase( :start )
  end
  def on_turn_end
    super
    reset_wt # // 02/13/2012 - WT System . x .
  end
  def on_global_turn_start
  end
  def on_global_turn_end
  end
  def waiting_for_input?
    return turn_phase == :make_action && @controlled_by == :player
  end
  def on_miss( user, obj )
    jump( 0, 0 )
  end
  def on_evade( user, obj )
    d = [(user.direction + 4) % 8, 2].max
    add_tweener(
      0, 0,
      _map.x_with_direction(0, d) * 24,
      _map.y_with_direction(0, d) * 24,
      10, :linear
    )
  end
  def on_hit( user, obj )
    @balloon_id = @result.hp_damage > 0 ?
      (friendly_character?(user) ? 7 : 5) : (@result.hp_damage < 0 ? (foe_character?(user) ? 4 : 3) : 0)
  end
  def on_attack( user, obj )
  end
  def on_death( user, obj )
    if self.enemy?
      _map.scatter_items( self.x, self.y, self.inventory.all_items.compact, [self], 2 ) ; self.inventory.clear
    end
  end
  def on_target_miss( target, obj )
    @balloon_id = 6
  end
  def on_target_evade( target, obj )
    @balloon_id = 7
  end
  def on_target_hit( target, obj )
  end
  def on_target_attack( target, obj )
  end
  def on_item_repeat( obj, i )
    if obj.id == 1
      d = @direction
      tx, ty = _map.x_with_direction(0, d) * 18, _map.y_with_direction(0, d) * 18
      clear_tweener_stack
      add_tweener( 0, 0, tx, ty, 15, :back_out )
      add_tweener( tx, ty, 0, 0, 20, :linear )
    end
  end
  def on_target_death( target, obj )
    gain_exp( target.ko_exp )
  end
  def on_trap_step( trap )
    @balloon_id = 1
  end
  def on_trap_trigger( trap )
    @balloon_id = 7
  end
  def on_trap_fail( trap )
    @balloon_id = 6
  end
end