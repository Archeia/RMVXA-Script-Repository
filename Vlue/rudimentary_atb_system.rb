#Rudimentary ATB System v1.0d
#----------#
#
#Features: Active Time Battles! Roughly and quickly written. Mostly works.
#
#~ #----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
 
class Scene_Battle < Scene_Base
  #Default action time for the quickest battler. (Minimum)
  ACTION_TIMER = 180
  #Max action time (for super duper low agility battlers)
  MAX_TIMER = 540
  def start_party_command_selection
    @status_window.open
  end
  def update_basic
    super
    $game_timer.update
    $game_troop.update
    @spriteset.update
    update_info_viewport
    update_message_open
   
    update_battler_time if update_time_allowed
  end
  def update_battler_time
    unless @speed_timer
      highest_agility = 0
      $game_troop.members.each do |enemy|
        highest_agility = [highest_agility,enemy.agi].max
      end
      $game_party.members.each do |actor|
        highest_agility = [highest_agility,actor.agi].max
      end
      @speed_timer = ACTION_TIMER * highest_agility
    end
    $game_troop.alive_members.each do |enemy|
      break unless update_time_allowed
      enemy.timer += enemy.agi
      if enemy.timer > @speed_timer || enemy.timer / enemy.agi > MAX_TIMER
        enemy.timer = 0
        if enemy.movable?
          enemy.make_actions
          BattleManager.force_action(enemy)
          process_forced_action
        else
          enemy.on_action_end
          enemy.on_turn_end
        end
      end
    end
    $game_party.alive_members.each do |actor|
      break unless update_time_allowed
      actor.timer += actor.agi
      if actor.timer > @speed_timer || actor.timer / actor.agi > MAX_TIMER
        actor.timer = 0
        if actor.confusion? || actor.auto_battle?
          BattleManager.set_actor(actor.index)
          BattleManager.force_action(actor)
          BattleManager.clear_actor
          process_forced_action
        elsif !actor.movable?
          actor.on_action_end
          actor.on_turn_end
        else
          BattleManager.set_actor(actor.index)
          start_actor_command_selection
        end
      end
    end
    @status_window.refresh
  end
  def speed_timer
    @speed_timer ? @speed_timer : 1
  end
  def update_time_allowed
    return false if BattleManager.action_forced?
    return false if BattleManager.actor
    return false if $game_message.busy?
    return false if @actor_command_window.open?
    return true
  end
  def process_forced_action
    if BattleManager.action_forced?
      last_subject = @subject
      @subject = BattleManager.action_forced_battler
      process_action
      @subject = last_subject
    end
  end
  def process_action_end
    @subject.on_action_end
    @subject.on_turn_end
    refresh_status
    @log_window.display_auto_affected_status(@subject)
    @log_window.wait_and_clear
    @log_window.display_current_state(@subject)
    @log_window.wait_and_clear
    BattleManager.clear_action_force
    BattleManager.judge_win_loss
  end
  def command_guard
    close_all
    BattleManager.actor.input.set_guard
    BattleManager.force_action(BattleManager.actor)
    BattleManager.clear_actor
    process_forced_action
  end
  def on_enemy_ok
    BattleManager.actor.input.target_index = @enemy_window.enemy.index
    @enemy_window.hide
    @skill_window.hide
    @item_window.hide
    close_all
    BattleManager.force_action(BattleManager.actor)
    BattleManager.clear_actor
    process_forced_action
  end
  def on_actor_ok
    BattleManager.actor.input.target_index = @actor_window.index
    @actor_window.hide
    @skill_window.hide
    @item_window.hide
    close_all
    BattleManager.force_action(BattleManager.actor)
    BattleManager.clear_actor
    process_forced_action
  end
  def on_skill_ok
    @skill = @skill_window.item
    BattleManager.actor.input.set_skill(@skill.id)
    BattleManager.actor.last_skill.object = @skill
    if !@skill.need_selection?
      @skill_window.hide
      close_all
      BattleManager.force_action(BattleManager.actor)
      BattleManager.clear_actor
      process_forced_action
    elsif @skill.for_opponent?
      select_enemy_selection
    else
      select_actor_selection
    end
  end
  def close_all
    @party_command_window.close
    @actor_command_window.close
    @status_window.unselect
    @log_window.wait
    @log_window.clear
  end
end
 
class Window_ActorCommand
  def cancel_enabled?
    false
  end
end

class Game_BattlerBase
  attr_accessor  :timer
  alias atb_init initialize
  def initialize(*args)
    atb_init(*args)
    @timer = 0
  end
  def ap_rate
    [@timer.to_f / SceneManager.scene.speed_timer, 1.0].min
  end
end

class Window_Base < Window
  def draw_actor_ap(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.ap_rate, text_color(0), text_color(8))
    change_color(system_color)
    draw_text(x, y, 30, line_height, "AT")
    change_color(tp_color(actor))
    draw_text(x + width - 42, y, 42, line_height, (actor.ap_rate * 100).to_i, 2)
  end
end

class Window_BattleStatus < Window_Selectable
  def draw_gauge_area_with_tp(rect, actor)
    draw_actor_hp(actor, rect.x - 74, rect.y, 72)
    draw_actor_mp(actor, rect.x + 8, rect.y, 64)
    draw_actor_tp(actor, rect.x + 82, rect.y, 64)
    draw_actor_ap(actor, rect.x + 156, rect.y, 64)
  end
  def draw_gauge_area_without_tp(rect, actor)
    draw_actor_hp(actor, rect.x + 0, rect.y, 72)
    draw_actor_mp(actor, rect.x + 82, rect.y, 64)
    draw_actor_ap(actor, rect.x + 156, rect.y, 64)
  end
end
 
module BattleManager
  def self.set_actor(index)
    @actor_index = index
    self.actor.clear_actions
    self.actor.make_actions
  end
end

class Scene_Base
  def speed_timer; 0; end
end