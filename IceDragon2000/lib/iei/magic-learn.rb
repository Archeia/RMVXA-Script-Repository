# // 02/22/2012
# // 02/23/2012
# // Icy Engine Iliks
$simport.r 'iei/magic_learn', '1.0.0', 'IEI Magic Learn'

module IEI
  module MagicLearn
    module Mixins ; end
  end
end

module IEI::MagicLearn::Mixins::Battler
  def pre_init_iei
    super
    @magiclearn = {}
  end

  def init_iei
    super
    #init_magiclearn
  end

  def post_init_iei
    super
    # // Something else .x .
    init_magiclearn
  end

  # //
  def init_magiclearn
    @magiclearn = {}
    @skills.each { |id| @magiclearn[id] = 100 }
  end

  # // 02/23/2012
  attr_reader :magiclearn

  def get_magiclearn(id)
    @magiclearn[id] || 0
  end

  def get_magiclearn_r(id)
    get_magiclearn(id) / 100.0
  end

  def change_magiclearn(id, n)
    @magiclearn[id] = n.clamp(0, 100)
    #puts "#{$data_skills[id].name} - #{@magiclearn[id]} / 100"
    magiclearn_learn_skill(id)
  end

  def inc_magiclearn(id, n)
    change_magiclearn(id, 0) unless @magiclearn.has_key?(id)
    change_magiclearn(id, @magiclearn[id] + n)
  end

  def dec_magiclearn(id, n)
    inc_magiclearn(id, -n)
  end

  def magiclearn_run_checks
    @magiclearn.keys.each{ |k| magiclearn_learn_skill(k) }
  end

  def magiclearn_learn_skill(skill_id)
    magiclearn_learn_skill!(skill_id) if magiclearn?(skill_id)
  end

  def magiclearn_learn_skill!(skill_id)
    @magiclearn[skill_id] = 100 ; learn_skill(skill_id)
  end

  def magiclearn?(id)
    return false if skill_learn?($data_skills[id]) # // . x . Might replace this
    return false unless @magiclearn.has_key?(id)
    return @magiclearn[id] >= 100
  end

  # // 02/25/2012
  def magiclearn_rate(item)
    1
  end

  def can_magiclearn?(item)
    return false if item.id < 20
    return true
  end

  def use_item(item)
    super(item)
    if ExDatabase.skill?(item) && can_magiclearn?(item)
      inc_magiclearn(item.id,magiclearn_rate(item))
    end
  end
end
