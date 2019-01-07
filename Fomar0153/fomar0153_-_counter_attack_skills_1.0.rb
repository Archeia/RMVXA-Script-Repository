=begin
Counter Attack Skills
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
Allows you to counter attack using skills.
----------------------
Instructions
----------------------
Notetag the actor, class, enemy or state:
<counterskill x>
where x is the skill id
----------------------
Known bugs
----------------------
None
=end
module Vocab
  CounterAttack   = "%s counter attacked with %s!"
end

class Window_BattleLog < Window_Selectable
  def display_counter(target, item)
    Sound.play_evasion
    add_text(sprintf(Vocab::CounterAttack, target.name, $data_skills[target.counterskill].name))
    wait
  end
end

class RPG::BaseItem
  def counterskill
    if @counterskill.nil?
      if @note =~ /<counterskill (.*)>/i
        @counterskill = $1.to_i
      else
        @counterskill = 1
      end
    end
    @counterskill
  end
end

class Game_Actor < Game_Battler
  
  def counterskill
    for state in states
      return state.counterskill if state.counterskill > 1
    end
    return actor.counterskill
  end
  
end

class Game_Enemy < Game_Battler
  
  def counterskill
    for state in states
      return state.counterskill if state.counterskill > 1
    end
    return enemy.counterskill
  end
end

class Scene_Battle
  def invoke_counter_attack(target, item)
    @log_window.display_counter(target, item)
    attack_skill = $data_skills[target.counterskill]
    if attack_skill.for_opponent?
      if attack_skill.for_all?
        show_animation(target.opponents_unit.alive_members, attack_skill.animation_id)
        for t in target.opponents_unit.alive_members
          t.item_apply(target, attack_skill)
          refresh_status
          @log_window.display_action_results(t, attack_skill)
        end
      else
        show_animation([@subject], attack_skill.animation_id)
        @subject.item_apply(target, attack_skill)
        refresh_status
        @log_window.display_action_results(@subject, attack_skill)
      end
    else
      if attack_skill.for_all?
        if attack_skill.for_dead_friend?
          show_animation(target.friends_unit.dead_members, attack_skill.animation_id)
          for t in target.friends_unit.dead_members
            t.item_apply(target, attack_skill)
            refresh_status
            @log_window.display_action_results(t, attack_skill)
          end
        else
          show_animation(target.friends_unit.alive_members, attack_skill.animation_id)
          for t in target.friends_unit.alive_members
            t.item_apply(target, attack_skill)
            refresh_status
            @log_window.display_action_results(t, attack_skill)
          end
        end
      else
        show_animation([target], attack_skill.animation_id)
        target.item_apply(target, attack_skill)
        refresh_status
        @log_window.display_action_results(target, attack_skill)
      end
    end
  end
end