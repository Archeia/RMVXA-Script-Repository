class REI::BattlerUnit::Enemy < REI::BattlerUnit
  attr_accessor :nickname                 
  def initialize( battler_id )
    @original_id = battler_id
    super()
  end 
  def pre_init_members 
    super
    @alignment = 1 #rand(100) > 90 ? :actor : :enemy
    @_ai = Game::AI.create_ai( 1, 
      [:territory_guard, :move_in_line] 
    ).set_subject( self )
    @controlled_by = :ai
  end  
  def init_members
    super
    setup( @original_id )
  end  
  def post_init_members
    super
    self.inventory.gain_item( $data_items[1], 1 )
    self.inventory.gain_item( $data_items[2], 1 )
    #self.inventory.gain_item( $data_weapons[1], 1 )
    refresh_alignment
  end  
  def battler_symbol
    return :enemy
  end  
  def refresh_alignment
    @character_hue = friend? ? 128 : 0 
  end  
  def setup( battler_id )
    @battler_id = battler_id
    @name = enemy.name
    @nickname = enemy.nickname
    init_graphics
    @class_id = enemy.class_id
    @level = enemy.initial_level
    @exp = {}
    @equips = []
    init_exp
    init_skills
    init_equips(enemy.equips)
    clear_param_plus
    recover_all
    @element_id = enemy.element_id
  end  
  def enemy
    return battler
  end  
  def battler 
    return $data_enemies[@battler_id]
  end  
  def enemy?
    return true
  end 
end