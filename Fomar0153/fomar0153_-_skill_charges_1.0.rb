=begin
Skill Charges
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
This script can implement two new features.
The first is skill charges, each time you learn a skill
you gain a charge in it and you're allowed to use that skill
only as many times as you have charges per battle.
The second feature is that each time you learn a skill after 
initially learning it the skill gets more powerful.
Using both features together allows for your skills to get
weaker each time you use a charge.
----------------------
Instructions
----------------------
Change the variables in the Fomar module to suit your needs.
----------------------
Known bugs
----------------------
None
=end
module Fomar
  
  # With this set to true you can only use each skill as
  # many times as you have skill charges
  SKILL_CHARGES = true
  # 50% increase in skill power per additional charge
  # set to 0.0 if you don't want this feature
  SKILL_CHARGES_POWER_INC = 0.5
  # Set to true to display a message when you gain a skill charge
  SKILL_CHARGES_MSG = true
  # %s will be replaced with the actor's name and skill's name
  SKILL_CHARGES_VOCAB = "%s gained a skill charge of %s."
  
end

class Game_Actor < Game_Battler
  
  attr_accessor :skill_charges
  attr_accessor :used_skill_charges
  
  alias sc_setup setup
  def setup(actor_id)
    @skill_charges = []
    @used_skill_charges = []
    sc_setup(actor_id)
  end
  
  alias sc_learn_skill learn_skill
  def learn_skill(skill_id)
    if skill_learn?($data_skills[skill_id])
      @skill_charges[skill_id] += 1
      if $game_party.in_battle and Fomar::SKILL_CHARGES_MSG
        $game_message.add(sprintf(Fomar::SKILL_CHARGES_VOCAB, @name, $data_skills[skill_id].name))
      end
    else
      sc_learn_skill(skill_id)
      @skill_charges[skill_id] = 1
    end
  end
  
  def usable?(item)
    return super unless $game_party.in_battle
    return super if item.is_a?(RPG::Skill) && (item.id == attack_skill_id || item.id == guard_skill_id)
    return false if item.is_a?(RPG::Skill) && 
      (@skill_charges[item.id] - @used_skill_charges[item.id] == 0 && Fomar::SKILL_CHARGES)
    return super(item)
  end
  
  def reset_skill_charges
    for skill in @skills + [attack_skill_id,guard_skill_id]
      @used_skill_charges[skill] = 0
    end
  end
  
  alias sc_use_item use_item
  def use_item(item)
    sc_use_item(item)
    return unless $game_party.in_battle
    @used_skill_charges[item.id] += 1 if item.is_a?(RPG::Skill)
  end
  
  def skill_damage_mult(item)
    return 1.0 if item.id == attack_skill_id or item.id == guard_skill_id
    if @used_skill_charges[item.id].nil?
      @used_skill_charges[item.id] = 0
    end
    return 1.0 + (@skill_charges[item.id] - @used_skill_charges[item.id]).to_f * Fomar::SKILL_CHARGES_POWER_INC
  end
  
end

class Game_Battler < Game_BattlerBase
  
  alias sc_item_element_rate item_element_rate
  def item_element_rate(user, item)
    if user.actor? and item.is_a?(RPG::Skill)
      sc_item_element_rate(user, item) * user.skill_damage_mult(item)
    else
      sc_item_element_rate(user, item)
    end
  end
  
end

module BattleManager
  
  class << self
    alias sc_setup setup
  end
  
  def self.setup(troop_id, can_escape = true, can_lose = false)
    sc_setup(troop_id, can_escape, can_lose)
    for actor in $game_party.members
      actor.reset_skill_charges
    end
  end
  
end

class Window_BattleSkill < Window_SkillList
  
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    change_color(normal_color, enabled)
    draw_text(x + 24, y, width, line_height, item.name + " (" + (@actor.skill_charges[item.id] - @actor.used_skill_charges[item.id]).to_s + ")")
  end
  
end