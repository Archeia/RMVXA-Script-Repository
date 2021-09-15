class REI::BattlerUnit::Trap < REI::BattlerUnit
  def initialize( trap_id )
    @original_id = trap_id
    super()
  end
  def pre_init_members
    super
    @trap_id = 0
    #@original_id = trap_id
    @priority_type = 0
  end
  def init_members
    super
    setup( @original_id )
  end
  def post_init_members
    super
    reset_trap
    @party_id = 4
  end
  def battler_symbol
    return :trap
  end
  def save_original_trap
    @or_direction     = @direction
    @or_transparent   = @transparent
    @or_direction_fix = @direction_fix
    @or_trigger_count = @trigger_count
  end
  def restore_original_trap
    setup( @original_id )
    @direction     = @or_direction
    @transparent   = @or_transparent
    @direction_fix = @or_direction_fix
    @trigger_count = @or_trigger_count
  end
  def reset_trap
    @direction     = 2
    @transparent   = true
    @direction_fix = true
    @trigger_count = 0
    clear_param_plus
    recover_all
  end
  def setup( trap_id )
    @trap_id  = trap_id
    @name     = trap.name
    @class_id = trap.class_id
    init_graphics
    @level    = trap.level
    @exp      = {}
    @equips   = []
    init_exp
    init_skills
    init_equips([0,0,0,0,0])
    reset_trap
  end
  def init_graphics
    @character_name  = battler.character_name
    @character_index = battler.character_index
    @character_hue   = 0
    @face_name       = ""
    @face_index      = ""
  end
  def original_trap
    return $data_traps[@original_id]
  end
  def trap
    return $data_traps[@trap_id]
  end
  def battler
    return trap
  end
  def trigger_trap( targets )
    #@targets = targets
    if can_trigger?
      @trigger_count += 1
      if @trigger_count > 0
        set_sprite_effect_type( :appear ) if @transparent
        @transparent = false
      end
      on_start_trigger( targets )
      recover_all if trap.recover_on_trigger
      set_trap_action( targets )
    end
    #@targets = nil
  end
  def can_trigger?
    return true if trap.trigger_limit == -1
    return (trap.trigger_limit > @trigger_count)
  end
  def triggered?
    return @trigger_count > 0
  end
  def set_trap_action( targets )
    act = Game::Action.new( self ).set_item( trap.item_id ).set_targets( targets ) if trap.item_id > 0
    act = Game::Action.new( self ).set_skill( trap.skill_id ).set_targets( targets ) if trap.skill_id > 0
    self.actions << act
    #ready_action
    act
  end
  def animating?
    @move_route_forcing
  end
  def on_start_trigger( targets=[] )
    force_move_route( trap.trigger_move_route )
  end
  def on_finish_trigger( targets=[] )
    fmr = trap.finish_move_route
    if trap != original_trap
      mvrt = fmr.clone
      mvrt.list = mvrt.list.clone
      mvrt.list.pop
      mvrt.list += original_trap.finish_move_route.list
      fmr = mvrt
    end
    force_move_route( fmr )
  end
  def restore_trap
    return if original_trap == true
    restore_original_trap
    set_sprite_effect_type( :appear )
  end
  def _trap_ids
    return _map.trap_ids || $data_traps.map { |t| t.id }
  end
  def set_random_trap( targets=@targets, trap_ids=_trap_ids )
    trap_ids = trap_ids-[self.id, 0]
    return false if trap_ids.empty?
    save_original_trap
    setup(trap_ids[rand(trap_ids.size)])
    set_sprite_effect_type( :appear )
    trigger_trap( targets )
  end
  def party
    _map.party(@party_id)
  end
  #--------------------------------------------------------------------------
  # ● 味方ユニットを取得
  #--------------------------------------------------------------------------
  def friends_unit
    _map.party(3)
  end
  #--------------------------------------------------------------------------
  # ● 敵ユニットを取得
  #--------------------------------------------------------------------------
  def opponents_unit
    _map.party(3)
  end
end
