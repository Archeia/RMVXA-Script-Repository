#encoding:UTF-8
# Game_Battler
#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  This class deals with battlers. It's used as a superclass of the Game_Actor
# and Game_Enemy classes.
#==============================================================================

class Game_Battler
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :battler_name             # battle graphic filename
  attr_reader   :battler_hue              # battle graphic hue
  attr_reader   :hp                       # HP
  attr_reader   :mp                       # MP
  attr_reader   :action                   # battle action
  attr_accessor :hidden                   # hidden flag
  attr_accessor :immortal                 # immortal flag
  attr_accessor :animation_id             # animation ID
  attr_accessor :animation_mirror         # animation flip horizontal flag
  attr_accessor :white_flash              # white flash flag
  attr_accessor :blink                    # blink flag
  attr_accessor :collapse                 # collapse flag
  attr_reader   :skipped                  # action results: skipped flag
  attr_reader   :missed                   # action results: missed flag
  attr_reader   :evaded                   # action results: evaded flag
  attr_reader   :critical                 # action results: critical flag
  attr_reader   :absorbed                 # action results: absorbed flag
  attr_reader   :hp_damage                # action results: HP damage
  attr_reader   :mp_damage                # action results: MP damage
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @battler_name = ""
    @battler_hue = 0
    @hp = 0
    @mp = 0
    @action = Game_BattleAction.new(self)
    @states = []                    # States (ID array)
    @state_turns = {}               # Remaining turns for states (Hash)
    @hidden = false   
    @immortal = false
    clear_extra_values
    clear_sprite_effects
    clear_action_results
  end
  #--------------------------------------------------------------------------
  # * Clear Values Added to Parameter
  #--------------------------------------------------------------------------
  def clear_extra_values
    @maxhp_plus = 0
    @maxmp_plus = 0
    @atk_plus = 0
    @def_plus = 0
    @spi_plus = 0
    @agi_plus = 0
  end
  #--------------------------------------------------------------------------
  # * Clear Variable Used for Sprite Communication
  #--------------------------------------------------------------------------
  def clear_sprite_effects
    @animation_id = 0
    @animation_mirror = false
    @white_flash = false
    @blink = false
    @collapse = false
  end
  #--------------------------------------------------------------------------
  # * Clear Variable for Storing Action Results
  #--------------------------------------------------------------------------
  def clear_action_results
    @skipped = false
    @missed = false
    @evaded = false
    @critical = false
    @absorbed = false
    @hp_damage = 0
    @mp_damage = 0
    @added_states = []              # Added states (ID array)
    @removed_states = []            # Removed states (ID array)
    @remained_states = []           # Unchanged states (ID array)
  end
  #--------------------------------------------------------------------------
  # * Get Current States as an Object Array
  #--------------------------------------------------------------------------
  def states
    result = []
    for i in @states
      result.push($data_states[i])
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Get the states that were added due to the previous action
  #--------------------------------------------------------------------------
  def added_states
    result = []
    for i in @added_states
      result.push($data_states[i])
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Get the states that were removed due to the previous action
  #--------------------------------------------------------------------------
  def removed_states
    result = []
    for i in @removed_states
      result.push($data_states[i])
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Get the states that remained the same after the previous action
  #    Used, for example, when someone tries to put to sleep a character
  #    who is already sleeping.
  #--------------------------------------------------------------------------
  def remained_states
    result = []
    for i in @remained_states
      result.push($data_states[i])
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Determine whether or not there was some effect on states by the
  #   previous action
  #--------------------------------------------------------------------------
  def states_active?
    return true unless @added_states.empty?
    return true unless @removed_states.empty?
    return true unless @remained_states.empty?
    return false
  end
  #--------------------------------------------------------------------------
  # * Get Maximum HP Limit
  #--------------------------------------------------------------------------
  def maxhp_limit
    return 999999
  end
  #--------------------------------------------------------------------------
  # * Get Maximum HP
  #--------------------------------------------------------------------------
  def maxhp
    return [[base_maxhp + @maxhp_plus, 1].max, maxhp_limit].min
  end
  #--------------------------------------------------------------------------
  # * Get Maximum MP
  #--------------------------------------------------------------------------
  def maxmp
    return [[base_maxmp + @maxmp_plus, 0].max, 9999].min
  end
  #--------------------------------------------------------------------------
  # * Get Attack
  #--------------------------------------------------------------------------
  def atk
    n = [[base_atk + @atk_plus, 1].max, 999].min
    for state in states do n *= state.atk_rate / 100.0 end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
  #--------------------------------------------------------------------------
  # * Get Defense
  #--------------------------------------------------------------------------
  def def
    n = [[base_def + @def_plus, 1].max, 999].min
    for state in states do n *= state.def_rate / 100.0 end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
  #--------------------------------------------------------------------------
  # * Get Spirit
  #--------------------------------------------------------------------------
  def spi
    n = [[base_spi + @spi_plus, 1].max, 999].min
    for state in states do n *= state.spi_rate / 100.0 end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
  #--------------------------------------------------------------------------
  # * Get Agility
  #--------------------------------------------------------------------------
  def agi
    n = [[base_agi + @agi_plus, 1].max, 999].min
    for state in states do n *= state.agi_rate / 100.0 end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
  #--------------------------------------------------------------------------
  # * Get [Super Guard] Option
  #--------------------------------------------------------------------------
  def super_guard
    return false
  end
  #--------------------------------------------------------------------------
  # * Get [Fast Attack] weapon option
  #--------------------------------------------------------------------------
  def fast_attack
    return false
  end
  #--------------------------------------------------------------------------
  # * Get [Dual Attack] weapon option
  #--------------------------------------------------------------------------
  def dual_attack
    return false
  end
  #--------------------------------------------------------------------------
  # * Get [Prevent Critical] armor option
  #--------------------------------------------------------------------------
  def prevent_critical
    return false
  end
  #--------------------------------------------------------------------------
  # * Get [Half MP Cost] armor option
  #--------------------------------------------------------------------------
  def half_mp_cost
    return false
  end
  #--------------------------------------------------------------------------
  # * Set Maximum HP
  #     new_maxhp : new maximum HP
  #--------------------------------------------------------------------------
  def maxhp=(new_maxhp)
    @maxhp_plus += new_maxhp - self.maxhp
    @maxhp_plus = [[@maxhp_plus, -9999].max, 9999].min
    @hp = [@hp, self.maxhp].min
  end
  #--------------------------------------------------------------------------
  # * Set Maximum MP
  #     new_maxmp : new maximum MP
  #--------------------------------------------------------------------------
  def maxmp=(new_maxmp)
    @maxmp_plus += new_maxmp - self.maxmp
    @maxmp_plus = [[@maxmp_plus, -9999].max, 9999].min
    @mp = [@mp, self.maxmp].min
  end
  #--------------------------------------------------------------------------
  # * Set Attack
  #     new_atk : new attack
  #--------------------------------------------------------------------------
  def atk=(new_atk)
    @atk_plus += new_atk - self.atk
    @atk_plus = [[@atk_plus, -999].max, 999].min
  end
  #--------------------------------------------------------------------------
  # * Set Defense
  #     new_def : new defense
  #--------------------------------------------------------------------------
  def def=(new_def)
    @def_plus += new_def - self.def
    @def_plus = [[@def_plus, -999].max, 999].min
  end
  #--------------------------------------------------------------------------
  # * Set Spirit
  #     new_spi : new spirit
  #--------------------------------------------------------------------------
  def spi=(new_spi)
    @spi_plus += new_spi - self.spi
    @spi_plus = [[@spi_plus, -999].max, 999].min
  end
  #--------------------------------------------------------------------------
  # * Set Agility
  #     new_agi : new agility
  #--------------------------------------------------------------------------
  def agi=(new_agi)
    @agi_plus += new_agi - self.agi
    @agi_plus = [[@agi_plus, -999].max, 999].min
  end
  #--------------------------------------------------------------------------
  # * Change HP
  #     hp : new HP
  #--------------------------------------------------------------------------
  def hp=(hp)
    @hp = [[hp, maxhp].min, 0].max
    if @hp == 0 and not state?(1) and not @immortal
      add_state(1)                # Add incapacitated (state #1)
      @added_states.push(1)
    elsif @hp > 0 and state?(1)
      remove_state(1)             # Remove incapacitated (state #1)
      @removed_states.push(1)
    end
  end
  #--------------------------------------------------------------------------
  # * Change MP
  #     mp : new MP
  #--------------------------------------------------------------------------
  def mp=(mp)
    @mp = [[mp, maxmp].min, 0].max
  end
  #--------------------------------------------------------------------------
  # * Recover All
  #--------------------------------------------------------------------------
  def recover_all
    @hp = maxhp
    @mp = maxmp
    for i in @states.clone do remove_state(i) end
  end
  #--------------------------------------------------------------------------
  # * Determine Incapacitation
  #--------------------------------------------------------------------------
  def dead?
    return (not @hidden and @hp == 0 and not @immortal)
  end
  #--------------------------------------------------------------------------
  # * Determine Existence
  #--------------------------------------------------------------------------
  def exist?
    return (not @hidden and not dead?)
  end
  #--------------------------------------------------------------------------
  # * Determine if Command is Inputable
  #--------------------------------------------------------------------------
  def inputable?
    return (not @hidden and restriction <= 1)
  end
  #--------------------------------------------------------------------------
  # * Determine if Action is Possible
  #--------------------------------------------------------------------------
  def movable?
    return (not @hidden and restriction < 4)
  end
  #--------------------------------------------------------------------------
  # * Determine if Attack is Parriable
  #--------------------------------------------------------------------------
  def parriable?
    return (not @hidden and restriction < 5)
  end
  #--------------------------------------------------------------------------
  # * Determine if Character is Silenced
  #--------------------------------------------------------------------------
  def silent?
    return (not @hidden and restriction == 1)
  end
  #--------------------------------------------------------------------------
  # * Determine if Character is in Berserker State
  #--------------------------------------------------------------------------
  def berserker?
    return (not @hidden and restriction == 2)
  end
  #--------------------------------------------------------------------------
  # * Determine if Character is Confused
  #--------------------------------------------------------------------------
  def confusion?
    return (not @hidden and restriction == 3)
  end
  #--------------------------------------------------------------------------
  # * Determine if Guarding
  #--------------------------------------------------------------------------
  def guarding?
    return @action.guard?
  end
  #--------------------------------------------------------------------------
  # * Get Element Change Value
  #     element_id : element ID
  #--------------------------------------------------------------------------
  def element_rate(element_id)
    return 100
  end
  #--------------------------------------------------------------------------
  # * Get Added State Success Rate
  #--------------------------------------------------------------------------
  def state_probability(state_id)
    return 0
  end
  #--------------------------------------------------------------------------
  # * Determine if State is Resisted
  #     state_id : state ID
  #--------------------------------------------------------------------------
  def state_resist?(state_id)
    return false
  end
  #--------------------------------------------------------------------------
  # * Get Normal Attack Element
  #--------------------------------------------------------------------------
  def element_set
    return []
  end
  #--------------------------------------------------------------------------
  # * Get Normal Attack State Change (+)
  #--------------------------------------------------------------------------
  def plus_state_set
    return []
  end
  #--------------------------------------------------------------------------
  # * Get Normal Attack State Change (-)
  #--------------------------------------------------------------------------
  def minus_state_set
    return []
  end
  #--------------------------------------------------------------------------
  # * Check State
  #     state_id : state ID
  #    Return true if the applicable state is added.
  #--------------------------------------------------------------------------
  def state?(state_id)
    return @states.include?(state_id)
  end
  #--------------------------------------------------------------------------
  # * Determine if a State is Full or Not
  #     state_id : state ID
  #    Return true if the number of turns the state is to be sustained
  #    equals the minimum number of turns after which the state will
  #    naturally be removed.
  #--------------------------------------------------------------------------
  def state_full?(state_id)
    return false unless state?(state_id)
    return @state_turns[state_id] == $data_states[state_id].hold_turn
  end
  #--------------------------------------------------------------------------
  # * Determine if a State Should be Ignored
  #     state_id : state ID
  #    Returns true when the following conditions are fulfilled.
  #     * If State A which is to be added, is included in State B's
  #       [States to Cancel] list.
  #     * If State B is not included in the [States to Cancel] list for 
  #       the new State A.
  #    These conditions would apply when, for example, trying to poison a
  #    character that is already incapacitated. It does not apply in cases
  #    such as applying ATK up while ATK down is already in effect.
  #--------------------------------------------------------------------------
  def state_ignore?(state_id)
    for state in states
      if state.state_set.include?(state_id) and
         not $data_states[state_id].state_set.include?(state.id)
        return true
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Determine if it is a state that should be offset
  #     state_id : state ID
  #    Returns true when the following conditions are fulfilled.
  #     * The [Offset by Opp.] option is enabled for the new state.
  #     * The [States to Cancel] list of the new state to be added
  #       contains at least one of the current states.
  #    This would apply when, for example, ATK up is applied while ATK down
  #    is already in effect.
  #--------------------------------------------------------------------------
  def state_offset?(state_id)
    return false unless $data_states[state_id].offset_by_opposite
    for i in @states
      return true if $data_states[state_id].state_set.include?(i)
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Sorting States
  #    Sort the content of the @states array, with higher priority states
  #    coming first.
  #--------------------------------------------------------------------------
  def sort_states
    @states.sort! do |a, b|
      state_a = $data_states[a]
      state_b = $data_states[b]
      if state_a.priority != state_b.priority
        state_b.priority <=> state_a.priority
      else
        a <=> b
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Add State
  #     state_id : state ID
  #--------------------------------------------------------------------------
  def add_state(state_id)
    state = $data_states[state_id]        # Get state data
    return if state == nil                # Is data invalid?
    return if state_ignore?(state_id)     # Is it a state should be ignored?
    unless state?(state_id)               # Is this state not added?
      unless state_offset?(state_id)      # Is it a state should be offset?
        @states.push(state_id)            # Add the ID to the @states array
      end
      if state_id == 1                    # If it is incapacitated (state 1)
        @hp = 0                           # Change HP to 0
      end
      unless inputable?                   # If the character cannot act
        @action.clear                     # Clear battle actions
      end
      for i in state.state_set            # Take the [States to Cancel]
        remove_state(i)                   # And actually remove them
        @removed_states.delete(i)         # It will not be displayed
      end
      sort_states                         # Sort states with priority
    end
    @state_turns[state_id] = state.hold_turn    # Set the number of turns
  end
  #--------------------------------------------------------------------------
  # * Remove State
  #     state_id : state ID
  #--------------------------------------------------------------------------
  def remove_state(state_id)
    return unless state?(state_id)        # Is this state not added?
    if state_id == 1 and @hp == 0         # If it is incapacitated (state 1)
      @hp = 1                             # Change HP to 1
    end
    @states.delete(state_id)              # Remove the ID from the @states
    @state_turns.delete(state_id)         # Remove from the @state_turns
  end
  #--------------------------------------------------------------------------
  # * Get Restriction
  #    Get the largest restriction from the currently added states.
  #--------------------------------------------------------------------------
  def restriction
    restriction_max = 0
    for state in states
      if state.restriction >= restriction_max
        restriction_max = state.restriction
      end
    end
    return restriction_max
  end
  #--------------------------------------------------------------------------
  # * Determine [Slip Damage] States
  #--------------------------------------------------------------------------
  def slip_damage?
    for state in states
      return true if state.slip_damage
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Determine if the state is [Reduced hit ratio]
  #--------------------------------------------------------------------------
  def reduce_hit_ratio?
    for state in states
      return true if state.reduce_hit_ratio
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Get Most Important State Continuation Message
  #--------------------------------------------------------------------------
  def most_important_state_text
    for state in states
      return state.message3 unless state.message3.empty?
    end
    return ""
  end
  #--------------------------------------------------------------------------
  # * Remove Battle States (called when battle ends)
  #--------------------------------------------------------------------------
  def remove_states_battle
    for state in states
      remove_state(state.id) if state.battle_only
    end
  end
  #--------------------------------------------------------------------------
  # * Natural Removal of States (called up each turn)
  #--------------------------------------------------------------------------
  def remove_states_auto
    clear_action_results
    for i in @state_turns.keys.clone
      if @state_turns[i] > 0
        @state_turns[i] -= 1
      elsif rand(100) < $data_states[i].auto_release_prob
        remove_state(i)
        @removed_states.push(i)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * State Removal due to Damage (called each time damage is caused)
  #--------------------------------------------------------------------------
  def remove_states_shock
    for state in states
      if state.release_by_damage
        remove_state(state.id)
        @removed_states.push(state.id)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Calculation of MP Consumed for Skills
  #     skill : skill
  #--------------------------------------------------------------------------
  def calc_mp_cost(skill)
    if half_mp_cost
      return skill.mp_cost / 2
    else
      return skill.mp_cost
    end
  end
  #--------------------------------------------------------------------------
  # * Determine Usable Skills
  #     skill : skill
  #--------------------------------------------------------------------------
  def skill_can_use?(skill)
    return false unless skill.is_a?(RPG::Skill)
    return false unless movable?
    return false if silent? and skill.spi_f > 0
    return false if calc_mp_cost(skill) > mp
    if $game_temp.in_battle
      return skill.battle_ok?
    else
      return skill.menu_ok?
    end
  end
  #--------------------------------------------------------------------------
  # * Calculation of Final Hit Ratio
  #     user : Attacker, or user of skill or item
  #     obj  : Skill or item (for normal attacks, this is nil)
  #--------------------------------------------------------------------------
  def calc_hit(user, obj = nil)
    if obj == nil                           # for a normal attack
      hit = user.hit                        # get hit ratio
      physical = true
    elsif obj.is_a?(RPG::Skill)             # for a skill
      hit = obj.hit                         # get success rate
      physical = obj.physical_attack
    else                                    # for an item
      hit = 100                             # the hit ratio is made 100%
      physical = obj.physical_attack
    end
    if physical                             # for a physical attack
      hit /= 4 if user.reduce_hit_ratio?    # when the user is blinded
    end
    return hit
  end
  #--------------------------------------------------------------------------
  # * Calculate Final Evasion Rate
  #     user : Attacker, or user of skill or item
  #     obj  : Skill or item (for normal attacks, this is nil)
  #--------------------------------------------------------------------------
  def calc_eva(user, obj = nil)
    eva = self.eva
    unless obj == nil                       # if it is a skill or an item
      eva = 0 unless obj.physical_attack    # 0% if not a physical attack
    end
    unless parriable?                       # If not parriable
      eva = 0                               # 0%
    end
    return eva
  end
  #--------------------------------------------------------------------------
  # * Calculation of Damage From Normal Attack
  #     attacker : Attacker
  #    The results are substituted for @hp_damage
  #--------------------------------------------------------------------------
  def make_attack_damage_value(attacker)
    damage = attacker.atk * 4 - self.def * 2        # base calculation
    damage = 0 if damage < 0                        # if negative, make 0
    damage *= elements_max_rate(attacker.element_set)   # elemental adjustment
    damage /= 100
    if damage == 0                                  # if damage is 0,
      damage = rand(2)                              # half of the time, 1 dmg
    elsif damage > 0                                # a positive number?
      @critical = (rand(100) < attacker.cri)        # critical hit?
      @critical = false if prevent_critical         # criticals prevented?
      damage *= 3 if @critical                      # critical adjustment
    end
    damage = apply_variance(damage, 20)             # variance
    damage = apply_guard(damage)                    # guard adjustment
    @hp_damage = damage                             # damage HP
  end
  #--------------------------------------------------------------------------
  # * Calculation of Damage Caused by Skills or Items
  #     user : User of skill or item
  #     obj  : Skill or item (for normal attacks, this is nil)
  #    The results are substituted for @hp_damage or @mp_damage.
  #--------------------------------------------------------------------------
  def make_obj_damage_value(user, obj)
    damage = obj.base_damage                        # get base damage
    if damage > 0                                   # a positive number?
      damage += user.atk * 4 * obj.atk_f / 100      # Attack F of the user
      damage += user.spi * 2 * obj.spi_f / 100      # Spirit F of the user
      unless obj.ignore_defense                     # Except for ignore defense
        damage -= self.def * 2 * obj.atk_f / 100    # Attack F of the target
        damage -= self.spi * 1 * obj.spi_f / 100    # Spirit F of the target
      end
      damage = 0 if damage < 0                      # If negative, make 0
    elsif damage < 0                                # a negative number?
      damage -= user.atk * 4 * obj.atk_f / 100      # Attack F of the user
      damage -= user.spi * 2 * obj.spi_f / 100      # Spirit F of the user
    end
    damage *= elements_max_rate(obj.element_set)    # elemental adjustment
    damage /= 100
    damage = apply_variance(damage, obj.variance)   # variance
    damage = apply_guard(damage)                    # guard adjustment
    if obj.damage_to_mp  
      @mp_damage = damage                           # damage MP
    else
      @hp_damage = damage                           # damage HP
    end
  end
  #--------------------------------------------------------------------------
  # * Calculation of Absorb Effect
  #     user : User of skill or item
  #     obj  : Skill or item (for normal attacks, this is nil)
  #    @hp_damage and  @mp_damage must be calculated before this is called.
  #--------------------------------------------------------------------------
  def make_obj_absorb_effect(user, obj)
    if obj.absorb_damage                        # if absorbing damage
      @hp_damage = [self.hp, @hp_damage].min    # HP damage range adjustment
      @mp_damage = [self.mp, @mp_damage].min    # MP damage range adjustment
      if @hp_damage > 0 or @mp_damage > 0       # a positive number?
        @absorbed = true                        # turn the absorb flag ON
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Calculating HP Recovery Amount From an Item
  #--------------------------------------------------------------------------
  def calc_hp_recovery(user, item)
    result = maxhp * item.hp_recovery_rate / 100 + item.hp_recovery
    result *= 2 if user.pharmacology    # Pharmacology doubles the effect
    return result
  end
  #--------------------------------------------------------------------------
  # * Calculating MP Recovery Amount From an Item
  #--------------------------------------------------------------------------
  def calc_mp_recovery(user, item)
    result = maxmp * item.mp_recovery_rate / 100 + item.mp_recovery
    result *= 2 if user.pharmacology    # Pharmacology doubles the effect
    return result
  end
  #--------------------------------------------------------------------------
  # * Get Maximum Elemental Adjustment Amount
  #     element_set : Elemental alignment
  #    Returns the most effective adjustment of all elemental alignments.
  #--------------------------------------------------------------------------
  def elements_max_rate(element_set)
    return 100 if element_set.empty?                # If there is no element
    rate_list = []
    for i in element_set
      rate_list.push(element_rate(i))
    end
    return rate_list.max
  end
  #--------------------------------------------------------------------------
  # * Applying Variance
  #     damage   : Damage
  #     variance : Degree of variance
  #--------------------------------------------------------------------------
  def apply_variance(damage, variance)
    if damage != 0                                  # If damage is not 0
      amp = [damage.abs * variance / 100, 0].max    # Calculate range
      damage += rand(amp+1) + rand(amp+1) - amp     # Execute variance
    end
    return damage
  end
  #--------------------------------------------------------------------------
  # * Applying Guard Adjustment
  #     damage : Damage
  #--------------------------------------------------------------------------
  def apply_guard(damage)
    if damage > 0 and guarding?                     # Determine if guarding
      damage /= super_guard ? 4 : 2                 # Reduce damage
    end
    return damage
  end
  #--------------------------------------------------------------------------
  # * Damage Reflection
  #     user : User of skill or item
  #    @hp_damage, @mp_damage, or @absorbed must be calculated before this
  #    method is called.
  #--------------------------------------------------------------------------
  def execute_damage(user)
    if @hp_damage > 0           # Damage is a positive number
      remove_states_shock       # Remove state due to attack
    end
    self.hp -= @hp_damage
    self.mp -= @mp_damage
    if @absorbed                # If absorbing
      user.hp += @hp_damage
      user.mp += @mp_damage
    end
  end
  #--------------------------------------------------------------------------
  # * Apply State Changes
  #     obj : Skill, item, or attacker
  #--------------------------------------------------------------------------
  def apply_state_changes(obj)
    plus = obj.plus_state_set             # get state change (+)
    minus = obj.minus_state_set           # get state change (-)
    for i in plus                         # state change (+)
      next if state_resist?(i)            # is it resisted?
      next if dead?                       # are they incapacitated?
      next if i == 1 and @immortal        # are they immortal?
      if state?(i)                        # is it already applied?
        @remained_states.push(i)          # record unchanged states
        next
      end
      if rand(100) < state_probability(i) # determine probability
        add_state(i)                      # add state
        @added_states.push(i)             # record added states
      end
    end
    for i in minus                        # state change (-)
      next unless state?(i)               # is the state not applied?
      remove_state(i)                     # remove state
      @removed_states.push(i)             # record removed states
    end
    for i in @added_states & @removed_states  # if there are any states in 
      @added_states.delete(i)                 # both added and removed
      @removed_states.delete(i)               # sections, delete them both
    end
  end
  #--------------------------------------------------------------------------
  # * Determine Whether to Apply a Normal Attack
  #     attacker : Attacker
  #--------------------------------------------------------------------------
  def attack_effective?(attacker)
    if dead?
      return false
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Apply Normal Attack Effects
  #     attacker : Attacker
  #--------------------------------------------------------------------------
  def attack_effect(attacker)
    clear_action_results
    unless attack_effective?(attacker)
      @skipped = true
      return
    end
    if rand(100) >= calc_hit(attacker)            # determine hit ratio
      @missed = true
      return
    end
    if rand(100) < calc_eva(attacker)             # determine evasion rate
      @evaded = true
      return
    end
    make_attack_damage_value(attacker)            # damage calculation
    execute_damage(attacker)                      # damage reflection
    if @hp_damage == 0                            # physical no damage?
      return                                    
    end
    apply_state_changes(attacker)                 # state change
  end
  #--------------------------------------------------------------------------
  # * Determine if a Skill can be Applied
  #     user  : Skill user
  #     skill : Skill
  #--------------------------------------------------------------------------
  def skill_effective?(user, skill)
    if skill.for_dead_friend? != dead?
      return false
    end
    if not $game_temp.in_battle and skill.for_friend?
      return skill_test(user, skill)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Skill Application Test
  #     user  : Skill user
  #     skill : Skill
  #    Used to determine, for example, if a character is already fully healed
  #    and so cannot recover anymore.
  #--------------------------------------------------------------------------
  def skill_test(user, skill)
    tester = self.clone
    tester.make_obj_damage_value(user, skill)
    tester.apply_state_changes(skill)
    if tester.hp_damage < 0
      return true if tester.hp < tester.maxhp
    end
    if tester.mp_damage < 0
      return true if tester.mp < tester.maxmp
    end
    return true unless tester.added_states.empty?
    return true unless tester.removed_states.empty?
    return false
  end
  #--------------------------------------------------------------------------
  # * Apply Skill Effects
  #     user  : Skill user
  #     skill : skill
  #--------------------------------------------------------------------------
  def skill_effect(user, skill)
    clear_action_results
    unless skill_effective?(user, skill)
      @skipped = true
      return
    end
    if rand(100) >= calc_hit(user, skill)         # determine hit ratio
      @missed = true
      return
    end
    if rand(100) < calc_eva(user, skill)          # determine evasion rate
      @evaded = true
      return
    end
    make_obj_damage_value(user, skill)            # calculate damage
    make_obj_absorb_effect(user, skill)           # calculate absorption effect
    execute_damage(user)                          # damage reflection
    if skill.physical_attack and @hp_damage == 0  # physical no damage?
      return                                    
    end
    apply_state_changes(skill)                    # state change
  end
  #--------------------------------------------------------------------------
  # * Determine if an Item can be Used
  #     user : Item user
  #     item : item
  #--------------------------------------------------------------------------
  def item_effective?(user, item)
    if item.for_dead_friend? != dead?
      return false
    end
    if not $game_temp.in_battle and item.for_friend?
      return item_test(user, item)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Item Application Test
  #     user : Item user
  #     item : item
  #    Used to determine, for example, if a character is already fully healed
  #    and so cannot recover anymore.
  #--------------------------------------------------------------------------
  def item_test(user, item)
    tester = self.clone
    tester.make_obj_damage_value(user, item)
    tester.apply_state_changes(item)
    if tester.hp_damage < 0 or tester.calc_hp_recovery(user, item) > 0
      return true if tester.hp < tester.maxhp
    end
    if tester.mp_damage < 0 or tester.calc_mp_recovery(user, item) > 0
      return true if tester.mp < tester.maxmp
    end
    return true unless tester.added_states.empty?
    return true unless tester.removed_states.empty?
    return true if item.parameter_type > 0
    return false
  end
  #--------------------------------------------------------------------------
  # * Apply Item Effects
  #     user : Item user
  #     item : item
  #--------------------------------------------------------------------------
  def item_effect(user, item)
    clear_action_results
    unless item_effective?(user, item)
      @skipped = true
      return
    end
    if rand(100) >= calc_hit(user, item)          # determine hit ratio
      @missed = true
      return
    end
    if rand(100) < calc_eva(user, item)           # determine evasion rate
      @evaded = true
      return
    end
    hp_recovery = calc_hp_recovery(user, item)    # calc HP recovery amount
    mp_recovery = calc_mp_recovery(user, item)    # calc MP recovery amount
    make_obj_damage_value(user, item)             # damage calculation
    @hp_damage -= hp_recovery                     # subtract HP recovery amount
    @mp_damage -= mp_recovery                     # subtract MP recovery amount
    make_obj_absorb_effect(user, item)            # calculate absorption effect
    execute_damage(user)                          # damage reflection
    item_growth_effect(user, item)                # apply growth effect
    if item.physical_attack and @hp_damage == 0   # physical no damage?
      return                                    
    end
    apply_state_changes(item)                     # state change
  end
  #--------------------------------------------------------------------------
  # * Item Growth Effect Application
  #     user : Item user
  #     item : item
  #--------------------------------------------------------------------------
  def item_growth_effect(user, item)
    if item.parameter_type > 0 and item.parameter_points != 0
      case item.parameter_type
      when 1  # Maximum HP
        @maxhp_plus += item.parameter_points
      when 2  # Maximum MP
        @maxmp_plus += item.parameter_points
      when 3  # Attack
        @atk_plus += item.parameter_points
      when 4  # Defense
        @def_plus += item.parameter_points
      when 5  # Spirit
        @spi_plus += item.parameter_points
      when 6  # Agility
        @agi_plus += item.parameter_points
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Application of Slip Damage Effects
  #--------------------------------------------------------------------------
  def slip_damage_effect
    if slip_damage? and @hp > 0
      @hp_damage = apply_variance(maxhp / 10, 10)
      @hp_damage = @hp - 1 if @hp_damage >= @hp
      self.hp -= @hp_damage
    end
  end
end
