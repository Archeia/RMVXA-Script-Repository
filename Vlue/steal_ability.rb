#--# Steal Ability v 1.1
#
# Allows to create abilities that steal items or gold from enemies. 
#  Or abilities! Which last until the end of the battle.
#
# Usage: Plug and play, customize and set up note tags as needed.
#
#   Enemy Notetags:
#    Id is the id of the item and chance is the percentage of success
#     <STEAL ITEM id chance>
#     <STEAL WEAPON id chance>
#     <STEAL ARMOR id chance>
#     <STEAL ABILITY id>
#     <STEAL GOLD amount>
#
#   Skill/Class/Actor/Equips notetags:
#     <STEAL>      - Skill only, allows skill to steal items
#     <PICKPOCKET> - Skill only, allows skill to steal gold
#     <STEAL_ABILITY> - Skill only, allows skill to steal ability
#     <STEAL CHANCE bonus> - provides a percentage bonus to steal chance
#
#------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
#--Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)

ABILITY_STEAL_CHANCE = 100
PICKPOCKET_STEAL_CHANCE = 60

class RPG::Enemy
  def steal_array
    steal = {}
    notes = self.note.clone
    while notes =~ /<STEAL ITEM (\d+) (\d+)>/
      steal[[0,$1.to_i]] = $2.to_i
      notes[notes.index("<STEAL")] = "N"
    end
    while notes =~ /<STEAL WEAPON (\d+) (\d+)>/
      steal[[1,$1.to_i]] = $2.to_i
      notes[notes.index("<STEAL")] = "N"
    end
    while notes =~ /<STEAL ARMOR (\d+) (\d+)>/
      steal[[2,$1.to_i]] = $2.to_i
      notes[notes.index("<STEAL")] = "N"
    end
    steal
  end
  def gold_amount
    self.note =~ /<STEAL GOLD (\d+)>/ ? $1 : 0
  end
  def ability_steal
    self.note =~ /<STEAL ABILITY (\d+)>/ ? $1 : 0 
  end
end

class RPG::UsableItem
  def steal?
    self.note.include?("<STEAL>")
  end
  def pickpocket?
    self.note.include?("<PICKPOCKET>")
  end
  def steal_ability?
    self.note.include?("<STEAL_ABILITY>")
  end
end

class RPG::BaseItem
  def steal_chance
    self.note =~ /<STEAL CHANCE (\d+)>/ ? $1.to_i : 0
  end
end

class Game_Enemy
  alias steal_init initialize
  def initialize(*args)
    steal_init(*args)
    @steal = enemy.steal_array.clone
    @gold = enemy.gold_amount.to_i
    @ability = enemy.ability_steal.to_i
  end
  def steal_array
    @steal
  end
  def steal(user,skill)
    steal_array.each do |id,chance|
      if rand(100) < chance + user.steal_bonus(skill)
        if Module.const_defined?(:AFFIXES)
          item = $game_party.add_item(id[1],1) if id[0] == 0
          item = $game_party.add_weapon(id[1],1) if id[0] == 1
          item = $game_party.add_armor(id[1],1) if id[0] == 2
        else
          item = $data_items[id[1]] if id[0] == 0
          item = $data_weapons[id[1]] if id[0] == 1
          item = $data_armors[id[1]] if id[0] == 2
          $game_party.gain_item(item,1)
        end
        @steal[id] = -1000
        return item
      end
    end
    return nil
  end
  def pickpocket(user,skill)
    return nil if @gold == 0
    if rand(100) < PICKPOCKET_STEAL_CHANCE + user.steal_bonus(skill)
      amount = rand(enemy.gold_amount.to_i) / 5 * (user.steal_bonus(skill) / 100.to_f + 1)
      if amount > @gold
        amount = @gold
      end
      @gold -= amount
      $game_party.gain_gold(amount.to_i)
      return amount.to_i
    end
    return nil
  end
  def steal_ability(user,skill)
    return nil if @ability == 0
    if rand(100) < ABILITY_STEAL_CHANCE + user.steal_bonus(skill)
      user.add_stolen_ability(@ability)
      return @ability
    end
    return nil
  end
end

class Game_Actor
  def steal_bonus(item)
    bonus = item.steal_chance
    bonus += self.actor.steal_chance
    bonus += self.class.steal_chance
    @equips.each do |item|
      next if item.is_nil?
      bonus += item.object.steal_chance
    end
    bonus
  end
  def add_stolen_ability(skill_id)
    @stolen_ability = [] if @stolen_ability.nil?
    @stolen_ability.push(skill_id)
    learn_skill(skill_id)
  end
  def clear_stolen_ability
    return unless @stolen_ability
    @stolen_ability.each do |skill_id|
      forget_skill(skill_id)
    end
    @stolen_ability = []
  end
  def on_battle_end
    super
    clear_stolen_ability
  end
end

class Scene_Battle
  def apply_item_effects(target, item)
    target.item_apply(@subject, item)
    refresh_status
    if item.steal?
      stolen_item = target.steal(@subject,item)
      target.result.success = true
    end
    if item.pickpocket?
      stolen_gold = target.pickpocket(@subject,item)
      target.result.success = true
    end
    if item.steal_ability?
      stolen_ability = target.steal_ability(@subject,item)
      target.result.success = true
    end
    @log_window.display_action_results(target, item)
    if item.steal? || item.pickpocket? || item.steal_ability?
      if stolen_item
        @log_window.display_theft(@subject,stolen_item)
      end
      if stolen_gold
        @log_window.display_pickpocket(@subject,stolen_gold)
      end
      if stolen_ability
        @log_window.display_ability_steal(@subject,target,stolen_ability)
      end
      @log_window.display_theft_fail(@subject) if !stolen_item && !stolen_gold && !stolen_ability
    end
  end
end

class Window_BattleLog
  def display_theft(user,item)
    add_text(user.name + " stole a " + item.name)
    wait
  end
  def display_theft_fail(user)
    add_text(user.name + " failed to steal anything")
    wait
  end
  def display_pickpocket(user,gold)
    add_text(user.name + " pickpocketed " + gold.to_s + " " + Vocab::currency_unit)
    wait
  end
  def display_ability_steal(user,target,ability)
    add_text(user.name + " stole " + target.name + "'s " + $data_skills[ability].name + " ability!")
    wait
  end
end