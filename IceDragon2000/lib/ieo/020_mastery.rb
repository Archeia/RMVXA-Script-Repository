#encoding:UTF-8
# IEO-020(Mastery)
class Game_ActorMastery
  attr_reader :max
  attr_reader :value
  attr_reader :type

  def initialize(type, value, max)
  end

  def max=(mval)
    @max = mval
    @val = [@val, self.max].min
  end

  def val=(val)
    @val = [val, self.max].min
  end
end

class Game_Actor < Game_Battler
  alias :ieo020_setup :setup unless $@
  def setup(actor_id)
    @masterys = {}
    ieo020_setup(actor_id)
    @masterys = {}
  end

  def mastery(type)
    case type
    when :attack
    when :defense
    when :magic
    when :item
    end
  end

  def increase_mastery(type, n = 0)
    @masterys[type].val += n
  end

  def decrease_mastery(type, n = 0)
    increase_mastery(type, n)
  end
end
