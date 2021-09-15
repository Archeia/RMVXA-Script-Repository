#encoding:UTF-8
# Game_Enemy
#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  This class handles enemies. It used within the Game_Troop class 
# ($game_troop).
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :index                    # index in troop
  attr_reader   :enemy_id                 # enemy ID
  attr_reader   :original_name            # original name
  attr_accessor :letter                   # letters to be attached to the name
  attr_accessor :plural                   # multiple appearance flag
  attr_accessor :screen_x                 # battle screen X coordinate
  attr_accessor :screen_y                 # battle screen Y coordinate
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(index, enemy_id)
    super()
    @index = index
    @enemy_id = enemy_id
    enemy = $data_enemies[@enemy_id]
    @original_name = enemy.name
    @letter = ""
    @plural = false
    @screen_x = 0
    @screen_y = 0
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    @hp = mhp
    @mp = mmp
  end
  #--------------------------------------------------------------------------
  # * Determine if Enemy
  #--------------------------------------------------------------------------
  def enemy?
    return true
  end
  #--------------------------------------------------------------------------
  # * Get Allied Units
  #--------------------------------------------------------------------------
  def friends_unit
    $game_troop
  end
  #--------------------------------------------------------------------------
  # * Get Enemy Units
  #--------------------------------------------------------------------------
  def opponents_unit
    $game_party
  end
  #--------------------------------------------------------------------------
  # * Get Enemy Object
  #--------------------------------------------------------------------------
  def enemy
    $data_enemies[@enemy_id]
  end
  #--------------------------------------------------------------------------
  # * Get Array of All Objects Retaining Features
  #--------------------------------------------------------------------------
  def feature_objects
    super + [enemy]
  end
  #--------------------------------------------------------------------------
  # * Get Display Name
  #--------------------------------------------------------------------------
  def name
    @original_name + (@plural ? letter : "")
  end
  #--------------------------------------------------------------------------
  # * Get Base Value of Parameter
  #--------------------------------------------------------------------------
  def param_base(param_id)
    enemy.params[param_id]
  end
  #--------------------------------------------------------------------------
  # * Get Experience
  #--------------------------------------------------------------------------
  def exp
    enemy.exp
  end
  #--------------------------------------------------------------------------
  # * Get Gold
  #--------------------------------------------------------------------------
  def gold
    enemy.gold
  end
  #--------------------------------------------------------------------------
  # * Create Array of Dropped Items
  #--------------------------------------------------------------------------
  def make_drop_items
    enemy.drop_items.inject([]) do |r, di|
      if di.kind > 0 && rand * di.denominator < drop_item_rate
        r.push(item_object(di.kind, di.data_id))
      else
        r
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Get Multiplier for Dropped Item Acquisition Probability
  #--------------------------------------------------------------------------
  def drop_item_rate
    $game_party.drop_item_double? ? 2 : 1
  end
  #--------------------------------------------------------------------------
  # * Get Item Object
  #--------------------------------------------------------------------------
  def item_object(kind, data_id)
    return $data_items  [data_id] if kind == 1
    return $data_weapons[data_id] if kind == 2
    return $data_armors [data_id] if kind == 3
    return nil
  end
  #--------------------------------------------------------------------------
  # * Use Sprites?
  #--------------------------------------------------------------------------
  def use_sprite?
    return true
  end
  #--------------------------------------------------------------------------
  # * Get Battle Screen Z-Coordinate
  #--------------------------------------------------------------------------
  def screen_z
    return 100
  end
  #--------------------------------------------------------------------------
  # * Execute Damage Effect
  #--------------------------------------------------------------------------
  def perform_damage_effect
    @sprite_effect_type = :blink
    Sound.play_enemy_damage
  end
  #--------------------------------------------------------------------------
  # * Execute Collapse Effect
  #--------------------------------------------------------------------------
  def perform_collapse_effect
    case collapse_type
    when 0
      @sprite_effect_type = :collapse
      Sound.play_enemy_collapse
    when 1
      @sprite_effect_type = :boss_collapse
      Sound.play_boss_collapse1
    when 2
      @sprite_effect_type = :instant_collapse
    end
  end
  #--------------------------------------------------------------------------
  # * Transform
  #--------------------------------------------------------------------------
  def transform(enemy_id)
    @enemy_id = enemy_id
    if enemy.name != @original_name
      @original_name = enemy.name
      @letter = ""
      @plural = false
    end
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    refresh
    make_actions unless @actions.empty?
  end
  #--------------------------------------------------------------------------
  # * Determine if Action Conditions Are Met
  #     action : RPG::Enemy::Action
  #--------------------------------------------------------------------------
  def conditions_met?(action)
    method_table = {
      1 => :conditions_met_turns?,
      2 => :conditions_met_hp?,
      3 => :conditions_met_mp?,
      4 => :conditions_met_state?,
      5 => :conditions_met_party_level?,
      6 => :conditions_met_switch?,
    }
    method_name = method_table[action.condition_type]
    if method_name
      send(method_name, action.condition_param1, action.condition_param2)
    else
      true
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Action Conditions Are Met [Turns]
  #--------------------------------------------------------------------------
  def conditions_met_turns?(param1, param2)
    n = $game_troop.turn_count
    if param2 == 0
      n == param1
    else
      n > 0 && n >= param1 && n % param2 == param1 % param2
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Action Conditions Are Met [HP]
  #--------------------------------------------------------------------------
  def conditions_met_hp?(param1, param2)
    hp_rate >= param1 && hp_rate <= param2
  end
  #--------------------------------------------------------------------------
  # * Determine if Action Conditions Are Met [MP]
  #--------------------------------------------------------------------------
  def conditions_met_mp?(param1, param2)
    mp_rate >= param1 && mp_rate <= param2
  end
  #--------------------------------------------------------------------------
  # * Determine if Action Conditions Are Met [State]
  #--------------------------------------------------------------------------
  def conditions_met_state?(param1, param2)
    state?(param1)
  end
  #--------------------------------------------------------------------------
  # * Determine if Action Conditions Are Met [Party Level]
  #--------------------------------------------------------------------------
  def conditions_met_party_level?(param1, param2)
    $game_party.highest_level >= param1
  end
  #--------------------------------------------------------------------------
  # * Determine if Action Conditions Are Met [Switch]
  #--------------------------------------------------------------------------
  def conditions_met_switch?(param1, param2)
    $game_switches[param1]
  end
  #--------------------------------------------------------------------------
  # * Determine if Action Is Valid in Current State
  #     action : RPG::Enemy::Action
  #--------------------------------------------------------------------------
  def action_valid?(action)
    conditions_met?(action) && usable?($data_skills[action.skill_id])
  end
  #--------------------------------------------------------------------------
  # * Randomly Select Action
  #     action_list:  RPG::Enemy::Action array
  #     rating_zero:  Rating value to consider as zero
  #--------------------------------------------------------------------------
  def select_enemy_action(action_list, rating_zero)
    sum = action_list.inject(0) {|r, a| r += a.rating - rating_zero }
    return nil if sum <= 0
    value = rand(sum)
    action_list.each do |action|
      return action if value < action.rating - rating_zero
      value -= action.rating - rating_zero
    end
  end
  #--------------------------------------------------------------------------
  # * Create Battle Action
  #--------------------------------------------------------------------------
  def make_actions
    super
    return if @actions.empty?
    action_list = enemy.actions.select {|a| action_valid?(a) }
    return if action_list.empty?
    rating_max = action_list.collect {|a| a.rating }.max
    rating_zero = rating_max - 3
    action_list.reject! {|a| a.rating <= rating_zero }
    @actions.each do |action|
      action.set_enemy_action(select_enemy_action(action_list, rating_zero))
    end
  end
end
