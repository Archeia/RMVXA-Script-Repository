class REI::BattlerUnit::Actor < REI::BattlerUnit

  attr_accessor :nickname

  def initialize( battler_id )
    @original_id = battler_id
    super()
  end
  def pre_init_members
    super
    @alignment = 0
    @controlled_by = :player
    @_ai = Game::AI.create_ai( 1,
      [:smart, :party, :party_protect, :heal, :move_in_line, :item_collect]
    ).set_subject( self )
  end
  def init_members
    super
    setup @original_id
  end
  def post_init_members
    super
    reset_add_xy
    @inventory = nil # // Discard Internal
    #@inventory.resize( 50 )
    #self.inventory.gain_item( $data_items[1], 1 )
    #self.inventory.gain_item( $data_items[2], 1 )
    #5.times { |i|
    #  self.inventory.gain_item( Ex_Database.to_ex($data_weapons[1+i]), 1 )
    #  self.inventory.gain_item( $data_weapons[11+i], 1 )
    #  self.inventory.gain_item( $data_weapons[21+i], 1 )
    #  self.inventory.gain_item( $data_weapons[31+i], 1 )
    #}
    #self.inventory.active_objs.sort_by! { |a| i = self.inventory.make_item(a); i ? i.db_id : 9999 }

    hash = @_hot_keys.key_hash
    hash[:A].set_key_as( Game::HotKey::MINIMAP_TOGGLE_CODE )
    hash[:B].set_key_as( Game::HotKey::CURSOR_MODE_CODE )
    hash[:C].set_key_as( Game::HotKey::MENU_OPEN_CODE )
    hash[:X].set_key_as( Game::HotKey::ATTACK_CODE )
    hash[:Y].set_key_as( Game::HotKey::SKIP_CODE )
    hash[:Z].set_key_as( Game::HotKey::GUARD_CODE )
  end
  def inventory
    $game.party#.inventory
  end
  def battler_symbol
    return :actor
  end
  def setup( battler_id )
    @battler_id = battler_id
    @name = actor.name
    @nickname = actor.nickname
    init_graphics
    @class_id = actor.class_id
    @level = actor.initial_level
    @exp = {}
    @equips = []
    init_exp
    init_skills
    init_equips(actor.equips)
    clear_param_plus
    recover_all
    @element_id = actor.element_id
  end
  def actor
    return battler
  end
  def battler
    return $data_actors[@battler_id]
  end
  def actor?
    return true
  end
end