#encoding:UTF-8
# Game_Enemy
#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  This class handles enemy characters. It's used within the Game_Troop class
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
  #     index    : index in troop
  #     enemy_id : enemy ID
  #--------------------------------------------------------------------------
  def initialize(index, enemy_id)
    super()
    @index = index
    @enemy_id = enemy_id
    enemy = $data_enemies[@enemy_id]
    @original_name = enemy.name
    @letter = ''
    @plural = false
    @screen_x = 0
    @screen_y = 0
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    @hp = maxhp
    @mp = maxmp
  end
  #--------------------------------------------------------------------------
  # * Determine if Actor or Not
  #--------------------------------------------------------------------------
  def actor?
    return false
  end
  #--------------------------------------------------------------------------
  # * Get Enemy Object
  #--------------------------------------------------------------------------
  def enemy
    return $data_enemies[@enemy_id]
  end
  #--------------------------------------------------------------------------
  # * Get Display Name
  #--------------------------------------------------------------------------
  def name
    if @plural
      return @original_name + letter
    else
      return @original_name
    end
  end
  #--------------------------------------------------------------------------
  # * Get Basic Maximum HP
  #--------------------------------------------------------------------------
  def base_maxhp
    return enemy.maxhp
  end
  #--------------------------------------------------------------------------
  # * Get basic Maximum MP
  #--------------------------------------------------------------------------
  def base_maxmp
    return enemy.maxmp
  end
  #--------------------------------------------------------------------------
  # * Get Basic Attack
  #--------------------------------------------------------------------------
  def base_atk
    return enemy.atk
  end
  #--------------------------------------------------------------------------
  # * Get Basic Defense
  #--------------------------------------------------------------------------
  def base_def
    return enemy.def
  end
  #--------------------------------------------------------------------------
  # * Get Basic Spirit
  #--------------------------------------------------------------------------
  def base_spi
    return enemy.spi
  end
  #--------------------------------------------------------------------------
  # * Get Basic Agility
  #--------------------------------------------------------------------------
  def base_agi
    return enemy.agi
  end
  #--------------------------------------------------------------------------
  # * Get Hit Rate
  #--------------------------------------------------------------------------
  def hit
    return enemy.hit
  end
  #--------------------------------------------------------------------------
  # * Get Evasion Rate
  #--------------------------------------------------------------------------
  def eva
    return enemy.eva
  end
  #--------------------------------------------------------------------------
  # * Get Critical Ratio
  #--------------------------------------------------------------------------
  def cri
    return enemy.has_critical ? 10 : 0
  end
  #--------------------------------------------------------------------------
  # * Get Ease of Hitting
  #--------------------------------------------------------------------------
  def odds
    return 1
  end
  #--------------------------------------------------------------------------
  # * Get Element Change Value
  #     element_id : element ID
  #--------------------------------------------------------------------------
  def element_rate(element_id)
    rank = enemy.element_ranks[element_id]
    result = [0,200,150,100,50,0,-100][rank]
    for state in states
      result /= 2 if state.element_set.include?(element_id)
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Get Added State Success Rate
  #     state_id : state ID
  #--------------------------------------------------------------------------
  def state_probability(state_id)
    if $data_states[state_id].nonresistance
      return 100
    else
      rank = enemy.state_ranks[state_id]
      return [0,100,80,60,40,20,0][rank]
    end
  end
  #--------------------------------------------------------------------------
  # * Get Experience
  #--------------------------------------------------------------------------
  def exp
    return enemy.exp
  end
  #--------------------------------------------------------------------------
  # * Get Gold
  #--------------------------------------------------------------------------
  def gold
    return enemy.gold
  end
  #--------------------------------------------------------------------------
  # * Get Drop Item 1
  #--------------------------------------------------------------------------
  def drop_item1
    return enemy.drop_item1
  end
  #--------------------------------------------------------------------------
  # * Get Drop Item 2
  #--------------------------------------------------------------------------
  def drop_item2
    return enemy.drop_item2
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
  # * Perform Collapse
  #--------------------------------------------------------------------------
  def perform_collapse
    if $game_temp.in_battle and dead?
      @collapse = true
      Sound.play_enemy_collapse
    end
  end
  #--------------------------------------------------------------------------
  # * Escape
  #--------------------------------------------------------------------------
  def escape
    @hidden = true
    @action.clear
  end
  #--------------------------------------------------------------------------
  # * Transform
  #     enemy_id : enemy ID to be transformed into
  #--------------------------------------------------------------------------
  def transform(enemy_id)
    @enemy_id = enemy_id
    if enemy.name != @original_name
      @original_name = enemy.name
      @letter = ''
      @plural = false
    end
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    make_action
  end
  #--------------------------------------------------------------------------
  # * Determine if Action Conditions are Met
  #     action : battle action
  #--------------------------------------------------------------------------
  def conditions_met?(action)
    case action.condition_type
    when 1  # Number of turns
      n = $game_troop.turn_count
      a = action.condition_param1
      b = action.condition_param2
      return false if (b == 0 and n != a)
      return false if (b > 0 and (n < 1 or n < a or n % b != a % b))
    when 2  # HP
      hp_rate = hp * 100.0 / maxhp
      return false if hp_rate < action.condition_param1
      return false if hp_rate > action.condition_param2
    when 3  # MP
      mp_rate = mp * 100.0 / maxmp
      return false if mp_rate < action.condition_param1
      return false if mp_rate > action.condition_param2
    when 4  # State
      return false unless state?(action.condition_param1)
    when 5  # Party level
      return false if $game_party.max_level < action.condition_param1
    when 6  # Switch
      switch_id = action.condition_param1
      return false if $game_switches[switch_id] == false
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Create Battle Action
  #--------------------------------------------------------------------------
  def make_action
    @action.clear
    return unless movable?
    available_actions = []
    rating_max = 0
    for action in enemy.actions
      next unless conditions_met?(action)
      if action.kind == 1
        next unless skill_can_use?($data_skills[action.skill_id])
      end
      available_actions.push(action)
      rating_max = [rating_max, action.rating].max
    end
    ratings_total = 0
    rating_zero = rating_max - 3
    for action in available_actions
      next if action.rating <= rating_zero
      ratings_total += action.rating - rating_zero
    end
    return if ratings_total == 0
    value = rand(ratings_total)
    for action in available_actions
      next if action.rating <= rating_zero
      if value < action.rating - rating_zero
        @action.kind = action.kind
        @action.basic = action.basic
        @action.skill_id = action.skill_id
        @action.decide_random_target
        return
      else
        value -= action.rating - rating_zero
      end
    end
  end
end
