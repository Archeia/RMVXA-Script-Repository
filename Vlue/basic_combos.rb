#Basic Combos v1.2f.01
#----------#
#Features: Allows heroes to combine their attacks to use greater skills.
#           Currently allows a chance for two heroes to cast a stronger
#           skill for greater damage if both heroes cast the same spell
#           on the same target, and the skill has a combo skill.
#
#Usage:    Set up notetags and let the skills fly
#           Skill notetags:
#             id1 is the skill to combo with, and id2 is the new skill to use
#            <COMBO id1, id2>  
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#- Free to use in any project with credit given, donations always welcome!
module COMBO
  #Default values below can be overridden by placing the note tags:
 
  #This one goes in the original skill:
  #<COMBO_CHANCE #>  for a #% chance of combo occuring
  #These ones are used in the combo skill:
  #<COMBO_DAMAGE #>  for #% more damage
  #<COMBO_FINISHER>  for combo abilities that are in addition to other attacks
 
  #Extra damage a combo ability does
  EXTRA_DAMAGE = 1.5
  #Chance for a combo attack to occur under right conditions out of 100
  COMBO_CHANCE = 65
end
 
class Scene_Battle < Scene_Base
  def process_action
    return if scene_changing?
    if !@subject || !@subject.current_action
      @subject = BattleManager.next_subject
    end
    return turn_end unless @subject
    if @subject.current_action
      item = @subject.current_action.item
      @subject.pay_skill_cost(item) if item.is_a?(RPG::Skill)
      check_for_combo
      if @subject.current_action.combo
        $game_troop.screen.start_tone_change(Tone.new(-25,-25,-25), 15)
        15.times do
          $game_troop.screen.update
          @spriteset.update
          Graphics.update
        end
      end
      @subject.current_action.prepare
      @status_window.open
      execute_action
      $game_troop.screen.start_tone_change(Tone.new(0,0,0), 15)
        15.times do
        $game_troop.screen.update
        @spriteset.update
        Graphics.update
      end
      @subject.remove_current_action
    end
    process_action_end unless @subject.current_action
  end
  def check_for_combo
    @extra_damage = 0
    next_battlers = BattleManager.active_battlers
    combo_battler = nil
    return unless @subject.current_action.item.is_a?(RPG::Skill)
    return unless rand(100) < @subject.current_action.item.combo_chance
    combo_skills = @subject.current_action.item.combo
    next_battlers.each do |battler|
      begin
        next unless battler
        next if battler.is_a?(Game_Enemy)
        next unless battler.current_action.target_index == @subject.current_action.target_index
        next unless combo_skills.include?(battler.current_action.item.id)
        combo_battler = battler
      rescue
        next
      end
    end
    return unless combo_battler
    new_skill = combo_skills[combo_battler.current_action.item.id]
    if $data_skills[new_skill].combo_finisher
      combo = Game_Action.new(combo_battler)
      combo.set_skill(new_skill)
      combo.target_index = @subject.current_action.target_index
      combo.combo = true
      combo_battler.actions.push(combo)
      targets = combo.make_targets.compact
      combo.extra_damage = combo.item.damage.eval(combo_battler, targets[0], $game_variables)
      combo_battler.casting_name = @subject.name + " and " + combo_battler.name
    else
      @subject.current_action.set_skill(new_skill)
      @subject.current_action.combo = true
      combo_battler.pay_skill_cost($data_skills[new_skill])
      targets = @subject.current_action.make_targets.compact
      @subject.current_action.extra_damage = combo_battler.current_action.item.damage.eval(combo_battler, targets[0], $game_variables)
      combo_battler.remove_current_action
      @subject.casting_name = @subject.name + " and " + combo_battler.name
    end
  end
end
 
class RPG::Skill
  def combo
    cnote = self.note.clone
    combo = {}
    cnote =~ /<COMBO (\d+), (\d+)/
    while $1
      cnote =~ /<COMBO (\d+), (\d+)/
      combo[$1.to_i] = $2.to_i if $1
      cnote[cnote.index("<COMBO")] = "&" unless cnote.index("<COMBO").nil?
    end
    combo
  end
  def combo_chance
    self.note =~ /<COMBO_CHANCE (\d+)>/
    return $1.to_i if $1
    return COMBO::COMBO_CHANCE
  end
  def combo_damage
    self.note =~ /<COMBO_DAMAGE (\d+)>/
    return $1.to_i / 100 if $1
    return COMBO::EXTRA_DAMAGE
  end
  def combo_finisher
    self.note =~ /<COMBO_FINISHER>/
    return true if $~
    return false
  end
end
 
module BattleManager
  def self.active_battlers
    @action_battlers
  end
end
 
class Game_Battler
  attr_accessor   :casting_name
  def use_item(item)
    return unless item
    consume_item(item)   if item.is_a?(RPG::Item)
    item.effects.each {|effect| item_global_effect_apply(effect) }
  end
  def make_damage_value(user, item)
    value = item.damage.eval(user, self, $game_variables)
    if SceneManager.scene.is_a?(Scene_Battle) and user.current_action.combo
      value += user.current_action.extra_damage
      value *= item.combo_damage if item.is_a?(RPG::Skill)
    end
    value *= item_element_rate(user, item)
    value *= pdr if item.physical?
    value *= mdr if item.magical?
    value *= rec if item.damage.recover?
    value = apply_critical(value) if @result.critical
    value = apply_variance(value, item.damage.variance)
    value = apply_guard(value)
    @result.make_damage(value.to_i, item)
  end
end
 
class Game_Actor
  alias combo_init initialize
  def initialize(*args)
    combo_init(*args)
    @casting_name = actor.name
  end
end
 
class Game_Enemy
  alias combo_init initialize
  def initialize(*args)
    combo_init(*args)
    @casting_name = enemy.name
  end
end
   
class Window_BattleLog
  def display_use_item(subject, item)
    if item.is_a?(RPG::Skill)
      if subject.current_action.combo
        add_text(subject.casting_name + item.message1)
        subject.casting_name = subject.name
      else
        add_text(subject.name + item.message1)
      end
      unless item.message2.empty?
        wait
        add_text(item.message2)
      end
    elsif item.is_a?(RPG::Item)
      add_text(sprintf(Vocab::UseItem, subject.name, item.name))
    end
  end
end
 
class Game_Action
  attr_accessor :combo
  attr_accessor :extra_damage
  alias combo_initialize initialize
  def initialize(*args)
    combo_initialize(*args)
    @combo = false
    @extra_damage = 0
  end
end