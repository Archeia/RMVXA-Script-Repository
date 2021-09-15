$simport.r 'iei/scopius', '1.0.0', 'IEI Scopius'

class RPG::UsableItem
  class Scope
    class Filter
      def initialize(code, *params)
        @code, @params = code, params
      end
      attr_accessor :code
      attr_accessor :params
    end

    module Constants
      # // Standard
      CODE_NONE     = 0
      CODE_USER     = 1
      CODE_OPPONENTS= 2
      CODE_FRIENDS  = 3
      CODE_EVERYONE = 4

      FILTER_ALIVE  = 0
      FILTER_DEAD   = 1
      FILTER_ANY    = 2

      SCOPE_SINGLE  = 0
      SCOPE_ALL     = 1
      SCOPE_RANDOM  = 2

      # // Ex
      CODE_GLOBAL   = 5  # // REI - Global System
      FILTER_STYPE  = 12 # // Target if they support n Stype (Skill)
      FILTER_WTYPE  = 13 # // Target if they support n Wtype (Weapon)
      FILTER_ATYPE  = 14 # // Target if they support n Atype (Armor)
      FILTER_STATE  = 15 # // Target if they have n state
    end

    include Constants
    include Enums::FeatureConstants

    # // Scope Conversion . x . RGSS2/3 to Scopius
    def self.quick_scope(n)
      case n
      when :everyone
        new CODE_EVERYONE, FILTER_ALIVE, SCOPE_SINGLE
      end
    end

    def self.[](code)
      case code
      when 0
        new CODE_NONE
      # // One Enemy
      when 1
        new CODE_OPPONENTS, FILTER_ALIVE, SCOPE_SINGLE
      # // All Enemies
      when 2
        new CODE_OPPONENTS, FILTER_ALIVE, SCOPE_ALL
      # // Random Enemies
      when 3, 4, 5, 6
        new CODE_OPPONENTS, FILTER_ALIVE, SCOPE_RANDOM, code - 2
      when 7
        new CODE_FRIENDS, FILTER_ALIVE, SCOPE_SINGLE
      when 8
        new CODE_FRIENDS, FILTER_ALIVE, SCOPE_ALL
      when 9
        new CODE_FRIENDS, FILTER_DEAD, SCOPE_SINGLE
      when 10
        new CODE_FRIENDS, FILTER_DEAD, SCOPE_ALL
      when 11
        new CODE_USER, FILTER_ANY, SCOPE_SINGLE
      else
        new code, 0, 0
      end
    end

    def initialize(code=CODE_NONE, filters=[FILTER_ALIVE],
                   scope=SCOPE_SINGLE, *params)
      @code    = code
      @scope   = scope
      @filters = (filters.is_a?(Enumerable) ? filters : [filters])
      @filters.map! { |f| f.is_a?(Filter) ? f : Filter.new(f) }
      @params  = params
    end

    def adjust_targets(targets, user)
      result = targets
      @filters.each do |filter|
        case filter.code
        # // Standard
        when FILTER_DEAD
          result.select!{|m|m.dead?}
        when FILTER_ALIVE
          result.select!{|m|m.alive?}
        when FILTER_ANY
          result
        # // Ex
        when FILTER_STYPE
          stype_id = filter.params[0]
          result.select!{|m|m.features_set(FEATURE_STYPE_ADD).include?(stype_id)}
        when FILTER_WTYPE
          wtype_id = filter.params[0]
          result.select!{|m|m.features_set(FEATURE_WTYPE_ADD).include?(wtype_id)}
        # // Armor Type
        when FILTER_ATYPE
          atype_id = filter.params[0]
          result.select!{|m|m.features_set(FEATURE_ATYPE_ADD).include?(atype_id)}
        # // States
        when FILTER_STATE
          state_id = filter.params[0]
          result.select!{|m|!m.states.find(){|s|s.id==state_id}.nil?()}
        # // .x . Level stuff
        when FILTER_LEVEL
          # // 1- user.level == target.level
          # // 2- target.level % n == 0
          case filter.param[0]
          when 1
            result.select!{|m|m.level == user.level}
          when 2
            mlevel = param[1]
            result.select!{|m|m.level % mlevel == 0}
          end
        # ITS TEH FORBIDDEN EVAL (:
        when FILTER_SCRIPT
          targets = result
          result = eval(filter.params[0])
        # // What the hell?
        else
          raise "Unknown scope value #{val}"
        end
      end
      result
    end

    def target_number
      @scope == SCOPE_RANDOM ? @params[0] : 0
    end

    # // State
    def dead?
      @filters.include?(FILTER_DEAD)
    end

    def alive?
      @filters.include?(FILTER_ALIVE)
    end

    def any_state?
      @filters.include?(FILTER_ANY)
    end

    # // Target Group
    def friend?
      @code == CODE_FRIENDS
    end

    def opponent?
      @code == CODE_OPPONENTS
    end

    def everyone?
      @code == CODE_EVERYONE
    end

    def none?
      @code == CODE_NONE
    end

    def user?
      @code == CODE_USER
    end

    def global?
      @code == CODE_GLOBAL
    end

    def team?
      all? && (opponent? || friend?)
    end

    # // Scope Checks
    def single?
      @scope == SCOPE_SINGLE
    end

    def random?
      @scope == SCOPE_RANDOM
    end

    def all?
      @scope == SCOPE_ALL
    end

    def need_selection?
      #[SCOPE_SINGLE].include?(@scope) # // >x< If I ever expand it
      @scope == SCOPE_SINGLE
    end

    def param(n)
      @params[n]
    end

    attr_accessor :code
    attr_accessor :scope
    attr_accessor :filters
    attr_accessor :params
  end

  def convert_scope
    @scope = Scope[@scope] unless @scope.is_a?(Scope)
    @scope
  end

  def scope
    convert_scope
  end

  # // Legacy Support
  def for_opponent?
    scope.opponent?
  end

  def for_friend?
    scope.friend?
  end

  def for_dead_friend?
    scope.dead? && scope.friend?
  end

  def for_user?
    scope.user?
  end

  def for_one?
    scope.single?
  end

  def for_random?
    scope.random?
  end

  def for_all?
    scope.all?
  end

  def need_selection?
    scope.need_selection?
  end
  def number_of_targets
    for_random? ? scope.params[0] : 0
  end

  def for_everyone?
    scope.everyone?
  end

  def for_everyone_alive?
    for_everyone? && scope.alive?
  end

  def for_everyone_dead?
    for_everyone? && scope.dead?
  end

  def for_global?
    scope.global?
  end
end

class Game::Action
  def get_scope_targets_basic(scope)
    #consts = RPG::UsableItem::Scope::Constants
    result = []
    if scope.none?
      result = []
    elsif scope.user?
      result = [@subject]
    elsif scope.friend?
      result = friends_unit.members
    elsif scope.opponent?
      result = opponents_unit.members
    elsif scope.everyone?
      result = friends_unit.members + opponents_unit.members
    elsif scope.global?
      result = [_map.global]
    end
    result.uniq
  end

  def adjust_scope_targets(scope, targets)
    # // Filtering
    result = scope.adjust_targets(effect_select_targets(targets),@subject)
    if scope.single?
      result = select_single_targets(result)
      result *= 1 + (attack? ? subject.atk_times_add.to_i : 0)
    elsif scope.random?
      result = (0...scope.target_number).map{result.sample}
    elsif scope.all?
      result = Array.new(result)
    end
    result
  end

  def get_scope_targets(scope)
    adjust_scope_targets(scope, get_scope_targets_basic(scope))
  end

  def effect_select_targets(targets)
    targets
  end unless method_defined? :effect_select_targets

  def select_single_targets(targets)
    [targets[@target_index]]
  end unless method_defined? :select_single_targets

  def make_targets()
    if !forcing && subject.confusion?
      [confusion_target]
    else
      get_scope_targets(item.scope)
    end
  end
end
