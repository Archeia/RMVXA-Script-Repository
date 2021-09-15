#encoding:UTF-8
# Game_Action
#==============================================================================
# ** Game_Action
#------------------------------------------------------------------------------
#  This class handles battle actions. This class is used within the
# Game_Battler class.
#==============================================================================

class Game_Action
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :subject                  # action subject
  attr_reader   :forcing                  # forcing flag for battle action
  attr_reader   :item                     # skill/item
  attr_accessor :target_index             # target index
  attr_reader   :value                    # evaluation value for auto battle
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(subject, forcing = false)
    @subject = subject
    @forcing = forcing
    clear
  end
  #--------------------------------------------------------------------------
  # * Clear
  #--------------------------------------------------------------------------
  def clear
    @item = Game_BaseItem.new
    @target_index = -1
    @value = 0
  end
  #--------------------------------------------------------------------------
  # * Get Allied Units
  #--------------------------------------------------------------------------
  def friends_unit
    subject.friends_unit
  end
  #--------------------------------------------------------------------------
  # * Get Enemy Units
  #--------------------------------------------------------------------------
  def opponents_unit
    subject.opponents_unit
  end
  #--------------------------------------------------------------------------
  # * Set Battle Action of Enemy Character
  #     action : RPG::Enemy::Action
  #--------------------------------------------------------------------------
  def set_enemy_action(action)
    if action
      set_skill(action.skill_id)
    else
      clear
    end
  end
  #--------------------------------------------------------------------------
  # * Set Normal Attack
  #--------------------------------------------------------------------------
  def set_attack
    set_skill(subject.attack_skill_id)
    self
  end
  #--------------------------------------------------------------------------
  # * Set Guard
  #--------------------------------------------------------------------------
  def set_guard
    set_skill(subject.guard_skill_id)
    self
  end
  #--------------------------------------------------------------------------
  # * Set Skill
  #--------------------------------------------------------------------------
  def set_skill(skill_id)
    @item.object = $data_skills[skill_id]
    self
  end
  #--------------------------------------------------------------------------
  # * Set Item
  #--------------------------------------------------------------------------
  def set_item(item_id)
    @item.object = $data_items[item_id]
    self
  end
  #--------------------------------------------------------------------------
  # * Get Item Object
  #--------------------------------------------------------------------------
  def item
    @item.object
  end
  #--------------------------------------------------------------------------
  # * Normal Attack Determination
  #--------------------------------------------------------------------------
  def attack?
    item == $data_skills[subject.attack_skill_id]
  end
  #--------------------------------------------------------------------------
  # * Random Target
  #--------------------------------------------------------------------------
  def decide_random_target
    if item.for_dead_friend?
      target = friends_unit.random_dead_target
    elsif item.for_friend?
      target = friends_unit.random_target
    else
      target = opponents_unit.random_target
    end
    if target
      @target_index = target.index
    else
      clear
    end
  end
  #--------------------------------------------------------------------------
  # * Set Confusion Action
  #--------------------------------------------------------------------------
  def set_confusion
    set_attack
  end
  #--------------------------------------------------------------------------
  # * Action Preparation
  #--------------------------------------------------------------------------
  def prepare
    set_confusion if subject.confusion? && !forcing
  end
  #--------------------------------------------------------------------------
  # * Determination if Action is Valid or Not
  #    Assuming that an event command does not cause [Force Battle Action],
  #    if state limitations or lack of items, etc. make the planned action
  #    impossible, return false.
  #--------------------------------------------------------------------------
  def valid?
    (forcing && item) || subject.usable?(item)
  end
  #--------------------------------------------------------------------------
  # * Calculate Action Speed
  #--------------------------------------------------------------------------
  def speed
    speed = subject.agi + rand(5 + subject.agi / 4)
    speed += item.speed if item
    speed += subject.atk_speed if attack?
    speed
  end
  #--------------------------------------------------------------------------
  # * Create Target Array
  #--------------------------------------------------------------------------
  def make_targets
    if !forcing && subject.confusion?
      [confusion_target]
    elsif item.for_opponent?
      targets_for_opponents
    elsif item.for_friend?
      targets_for_friends
    else
      []
    end
  end
  #--------------------------------------------------------------------------
  # * Target When Confused
  #--------------------------------------------------------------------------
  def confusion_target
    case subject.confusion_level
    when 1
      opponents_unit.random_target
    when 2
      if rand(2) == 0
        opponents_unit.random_target
      else
        friends_unit.random_target
      end
    else
      friends_unit.random_target
    end
  end
  #--------------------------------------------------------------------------
  # * Targets for Opponents
  #--------------------------------------------------------------------------
  def targets_for_opponents
    if item.for_random?
      Array.new(item.number_of_targets) { opponents_unit.random_target }
    elsif item.for_one?
      num = 1 + (attack? ? subject.atk_times_add.to_i : 0)
      if @target_index < 0
        [opponents_unit.random_target] * num
      else
        [opponents_unit.smooth_target(@target_index)] * num
      end
    else
      opponents_unit.alive_members
    end
  end
  #--------------------------------------------------------------------------
  # * Targets for Allies
  #--------------------------------------------------------------------------
  def targets_for_friends
    if item.for_user?
      [subject]
    elsif item.for_dead_friend?
      if item.for_one?
        [friends_unit.smooth_dead_target(@target_index)]
      else
        friends_unit.dead_members
      end
    elsif item.for_friend?
      if item.for_one?
        [friends_unit.smooth_target(@target_index)]
      else
        friends_unit.alive_members
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Evaluate Value of Action (for Auto Battle)
  #    @value and @target_index are automatically set.
  #--------------------------------------------------------------------------
  def evaluate
    @value = 0
    evaluate_item if valid?
    @value += rand if @value > 0
    self
  end
  #--------------------------------------------------------------------------
  # * Evaluate Skill/Item
  #--------------------------------------------------------------------------
  def evaluate_item
    item_target_candidates.each do |target|
      value = evaluate_item_with_target(target)
      if item.for_all?
        @value += value
      elsif value > @value
        @value = value
        @target_index = target.index
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Get Use Target Candidates for Skills/Items
  #--------------------------------------------------------------------------
  def item_target_candidates
    if item.for_opponent?
      opponents_unit.alive_members
    elsif item.for_user?
      [subject]
    elsif item.for_dead_friend?
      friends_unit.dead_members
    else
      friends_unit.alive_members
    end
  end
  #--------------------------------------------------------------------------
  # * Evaluate Skill/Item (Target Specification)
  #--------------------------------------------------------------------------
  def evaluate_item_with_target(target)
    target.result.clear
    target.make_damage_value(subject, item)
    if item.for_opponent?
      return target.result.hp_damage.to_f / [target.hp, 1].max
    else
      recovery = [-target.result.hp_damage, target.mhp - target.hp].min
      return recovery.to_f / target.mhp
    end
  end
end
