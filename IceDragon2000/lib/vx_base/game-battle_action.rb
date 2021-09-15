#encoding:UTF-8
# Game_BattleAction
#==============================================================================
# ** Game_BattleAction
#------------------------------------------------------------------------------
#  This class handles battle actions. This class is used within the
# Game_Battler class.
#==============================================================================

class Game_BattleAction
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :battler                  # battler
  attr_accessor :speed                    # speed
  attr_accessor :kind                     # kind (basic/skill/item)
  attr_accessor :basic                    # basic (attack/guard/escape/wait)
  attr_accessor :skill_id                 # skill ID
  attr_accessor :item_id                  # item ID
  attr_accessor :target_index             # target index
  attr_accessor :forcing                  # forced flag
  attr_accessor :value                    # automatic battle evaluation value
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     battler : Battler
  #--------------------------------------------------------------------------
  def initialize(battler)
    @battler = battler
    clear
  end
  #--------------------------------------------------------------------------
  # * Clear
  #--------------------------------------------------------------------------
  def clear
    @speed = 0
    @kind = 0
    @basic = -1
    @skill_id = 0
    @item_id = 0
    @target_index = -1
    @forcing = false
    @value = 0
  end
  #--------------------------------------------------------------------------
  # * Get Allied Units
  #--------------------------------------------------------------------------
  def friends_unit
    if battler.actor?
      return $game_party
    else
      return $game_troop
    end
  end
  #--------------------------------------------------------------------------
  # * Get Enemy Units
  #--------------------------------------------------------------------------
  def opponents_unit
    if battler.actor?
      return $game_troop
    else
      return $game_party
    end
  end
  #--------------------------------------------------------------------------
  # * Set Normal Attack
  #--------------------------------------------------------------------------
  def set_attack
    @kind = 0
    @basic = 0
  end
  #--------------------------------------------------------------------------
  # * Set Guard
  #--------------------------------------------------------------------------
  def set_guard
    @kind = 0
    @basic = 1
  end
  #--------------------------------------------------------------------------
  # * Set Skill
  #     skill_id : skill ID
  #--------------------------------------------------------------------------
  def set_skill(skill_id)
    @kind = 1
    @skill_id = skill_id
  end
  #--------------------------------------------------------------------------
  # * Set Item
  #     item_id : item ID
  #--------------------------------------------------------------------------
  def set_item(item_id)
    @kind = 2
    @item_id = item_id
  end
  #--------------------------------------------------------------------------
  # * Normal Attack Determination
  #--------------------------------------------------------------------------
  def attack?
    return (@kind == 0 and @basic == 0)
  end
  #--------------------------------------------------------------------------
  # * Guard Determination
  #--------------------------------------------------------------------------
  def guard?
    return (@kind == 0 and @basic == 1)
  end
  #--------------------------------------------------------------------------
  # * No Action Determination
  #--------------------------------------------------------------------------
  def nothing?
    return (@kind == 0 and @basic < 0)
  end
  #--------------------------------------------------------------------------
  # * Skill Determination
  #--------------------------------------------------------------------------
  def skill?
    return @kind == 1
  end
  #--------------------------------------------------------------------------
  # * Get Skill Object
  #--------------------------------------------------------------------------
  def skill
    return skill? ? $data_skills[@skill_id] : nil
  end
  #--------------------------------------------------------------------------
  # * Item Determination
  #--------------------------------------------------------------------------
  def item?
    return @kind == 2
  end
  #--------------------------------------------------------------------------
  # * Get Item Object
  #--------------------------------------------------------------------------
  def item
    return item? ? $data_items[@item_id] : nil
  end
  #--------------------------------------------------------------------------
  # * Determine if for One Ally
  #--------------------------------------------------------------------------
  def for_friend?
    return true if skill? and skill.for_friend?
    return true if item? and item.for_friend?
    return false
  end
  #--------------------------------------------------------------------------
  # * Determination for Single Incapacitated Ally
  #--------------------------------------------------------------------------
  def for_dead_friend?
    return true if skill? and skill.for_dead_friend?
    return true if item? and item.for_dead_friend?
    return false
  end
  #--------------------------------------------------------------------------
  # * Random Target
  #--------------------------------------------------------------------------
  def decide_random_target
    if for_friend?
      target = friends_unit.random_target
    elsif for_dead_friend?
      target = friends_unit.random_dead_target
    else
      target = opponents_unit.random_target
    end
    if target == nil
      clear
    else
      @target_index = target.index
    end
  end
  #--------------------------------------------------------------------------
  # * Last Target
  #--------------------------------------------------------------------------
  def decide_last_target
    if @target_index == -1
      target = nil
    elsif for_friend?
      target = friends_unit.members[@target_index]
    else
      target = opponents_unit.members[@target_index]
    end
    if target == nil or not target.exist?
      clear
    end
  end
  #--------------------------------------------------------------------------
  # * Action Preparation
  #--------------------------------------------------------------------------
  def prepare
    if battler.berserker? or battler.confusion?   # If berserk or confused
      set_attack                                  # Change to normal attack
    end
  end
  #--------------------------------------------------------------------------
  # * Determination if Action is Valid or Not
  #    Assuming that an event command does not cause [Force Battle Action],
  #    if state limitations or lack of items, etc. make the planned action
  #    impossible, return false.
  #--------------------------------------------------------------------------
  def valid?
    return false if nothing?                      # Do nothing
    return true if @forcing                       # Force to act
    return false unless battler.movable?          # Cannot act
    if skill?                                     # Skill
      return false unless battler.skill_can_use?(skill)
    elsif item?                                   # Item
      return false unless friends_unit.item_can_use?(item)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Confirm Action Speed
  #--------------------------------------------------------------------------
  def make_speed
    @speed = battler.agi + rand(5 + battler.agi / 4)
    @speed += skill.speed if skill?
    @speed += item.speed if item?
    @speed += 2000 if guard?
    @speed += 1000 if attack? and battler.fast_attack
  end
  #--------------------------------------------------------------------------
  # * Create Target Array
  #--------------------------------------------------------------------------
  def make_targets
    if attack?
      return make_attack_targets
    elsif skill?
      return make_obj_targets(skill)
    elsif item?
      return make_obj_targets(item)
    end
  end
  #--------------------------------------------------------------------------
  # * Create Normal Attack Targets
  #--------------------------------------------------------------------------
  def make_attack_targets
    targets = []
    if battler.confusion?
      targets.push(friends_unit.random_target)
    elsif battler.berserker?
      targets.push(opponents_unit.random_target)
    else
      targets.push(opponents_unit.smooth_target(@target_index))
    end
    if battler.dual_attack      # Chain attack
      targets += targets
    end
    return targets.compact
  end
  #--------------------------------------------------------------------------
  # * Create Skill or Item Targets
  #     obj : Skill or item
  #--------------------------------------------------------------------------
  def make_obj_targets(obj)
    targets = []
    if obj.for_opponent?
      if obj.for_random?
        if obj.for_one?         # One random enemy
          number_of_targets = 1
        elsif obj.for_two?      # Two random enemies
          number_of_targets = 2
        else                    # Three random enemies
          number_of_targets = 3
        end
        number_of_targets.times do
          targets.push(opponents_unit.random_target)
        end
      elsif obj.dual?           # One enemy, dual
        targets.push(opponents_unit.smooth_target(@target_index))
        targets += targets
      elsif obj.for_one?        # One enemy
        targets.push(opponents_unit.smooth_target(@target_index))
      else                      # All enemies
        targets += opponents_unit.existing_members
      end
    elsif obj.for_user?         # User
      targets.push(battler)
    elsif obj.for_dead_friend?
      if obj.for_one?           # One ally (incapacitated)
        targets.push(friends_unit.smooth_dead_target(@target_index))
      else                      # All allies (incapacitated)
        targets += friends_unit.dead_members
      end
    elsif obj.for_friend?
      if obj.for_one?           # One ally
        targets.push(friends_unit.smooth_target(@target_index))
      else                      # All allies
        targets += friends_unit.existing_members
      end
    end
    return targets.compact
  end
  #--------------------------------------------------------------------------
  # * Action Value Evaluation (for automatic battle)
  #    @value and @target_index are automatically set.
  #--------------------------------------------------------------------------
  def evaluate
    if attack?
      evaluate_attack
    elsif skill?
      evaluate_skill
    else
      @value = 0
    end
    if @value > 0
      @value + rand(nil)
    end
  end
  #--------------------------------------------------------------------------
  # * Normal Attack Evaluation
  #--------------------------------------------------------------------------
  def evaluate_attack
    @value = 0
    for target in opponents_unit.existing_members
      value = evaluate_attack_with_target(target)
      if value > @value
        @value = value
        @target_index = target.index
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Normal Attack Evaluation (target designation)
  #     target : Target battler
  #--------------------------------------------------------------------------
  def evaluate_attack_with_target(target)
    target.clear_action_results
    target.make_attack_damage_value(battler)
    return target.hp_damage.to_f / [target.hp, 1].max
  end
  #--------------------------------------------------------------------------
  # * Skill Evaluation
  #--------------------------------------------------------------------------
  def evaluate_skill
    @value = 0
    unless battler.skill_can_use?(skill)
      return
    end
    if skill.for_opponent?
      targets = opponents_unit.existing_members
    elsif skill.for_user?
      targets = [battler]
    elsif skill.for_dead_friend?
      targets = friends_unit.dead_members
    else
      targets = friends_unit.existing_members
    end
    for target in targets
      value = evaluate_skill_with_target(target)
      if skill.for_all?
        @value += value
      elsif value > @value
        @value = value
        @target_index = target.index
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Skill Evaluation (target designation)
  #     target : Target battler
  #--------------------------------------------------------------------------
  def evaluate_skill_with_target(target)
    target.clear_action_results
    target.make_obj_damage_value(battler, skill)
    if skill.for_opponent?
      return target.hp_damage.to_f / [target.hp, 1].max
    else
      recovery = [-target.hp_damage, target.maxhp - target.hp].min
      return recovery.to_f / target.maxhp
    end
  end
end
