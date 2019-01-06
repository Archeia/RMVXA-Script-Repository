#MP Levels v0.1b
#Notetags:
# Skills:
#  <MP_LEVEL level> - determines level of magic from 0-3
#
# Skills and Items:
#  <MP_DAMAGE level amount> - skill or item damages mp level that much
#  <MP_HEAL level amount> - opposite of damage
#
# Actors:
#  <MP_LEVEL level 0,1,2,3> - Determines max mp for each level
#
# Equipment:
#  <MP_LEVEL level amount> - Increases max mp for level by amount

#True to display skill uses remaining, false to display skill cost
DISPLAY_SKILL_USES = true
 
class Game_BattlerBase
  def mmp_reset
    [4,3,2,1]
  end
  def mmp(lvl = -1)
    return mmp_reset if lvl == -1
    mmp_reset[lvl]
  end
  def mp(lvl = 0)
    @mp[lvl]
  end
  def mp=(mp)
  end
  def set_mp(lvl, mp)
    @mp[lvl] = mp
    @mp[lvl] = [[@mp[lvl],0].max,mmp(lvl)].min
  end
  def gain_mp(lvl, mp)
    set_mp(lvl, @mp[lvl] + mp)
  end
  def skill_mp_cost(skill)
    skill.mp_cost
  end
  def skill_mp_level(skill)
    skill.mp_level
  end
  def pay_skill_cost(skill)
    gain_mp(skill_mp_level(skill), -skill_mp_cost(skill))
    self.tp -= skill_tp_cost(skill)
  end
  def skill_cost_payable?(skill)
    return false unless tp >= skill_tp_cost(skill)
    mp(skill_mp_level(skill)) >= skill_mp_cost(skill)
  end
  def refresh
    state_resist_set.each {|state_id| erase_state(state_id) }
    @hp = [[@hp, mhp].min, 0].max
    @hp == 0 ? add_state(death_state_id) : remove_state(death_state_id)
  end
  def recover_all
    clear_states
    @hp = mhp
    @mp = mmp_reset
  end
end
 
class Game_Battler
  alias mp_level_ed execute_damage
  def execute_damage(user)
    mp_level_ed(user)
    mp_dam = @result.mp_lvl_dam
    mp_drn = @result.mp_lvl_drn
    mp_heal = @result.mp_lvl_heal
    gain_mp(mp_dam[0], -mp_dam[1])
    gain_mp(mp_drn[0], -mp_drn[1])
    #user.gain_mp(mp_drn[0], mp_drn[1])
    gain_mp(mp_heal[0], -mp_heal[1])
  end
  def item_effect_recover_mp(user, item, effect)
  end
  def regenerate_mp
  end
end
 
class Game_Actor
  def mmp_reset
    mp_level_bonus(mp_level_base)
  end
  def mp_level_base
    mp_level = []
    iter = self.level
    while mp_level.empty?
      if self.actor.note =~ /<MP_LEVEL #{iter} (\d+),(\d+),(\d+),(\d+)>/
        return mp_level = [$1.to_i,$2.to_i,$3.to_i,$4.to_i]
      end
      iter -= 1
      return mp_level = [0,0,0,0] if iter == 0
    end
  end
  def mp_level_bonus(mp_level)
    self.equips.each_with_index do |item, i|
      next unless item
      if item.note =~ /<MP_LEVEL 0 (\d+)/
        mp_level[0] += $1.to_i
      end
      if item.note =~ /<MP_LEVEL 1 (\d+)/
        mp_level[1] += $1.to_i
      end
      if item.note =~ /<MP_LEVEL 2 (\d+)/
        mp_level[2] += $1.to_i
      end
      if item.note =~ /<MP_LEVEL 3 (\d+)/
        mp_level[3] += $1.to_i
      end
    end
    mp_level
  end
end
 
class Game_ActionResult
  alias mp_level_md make_damage
  def make_damage(value, item)
    mp_level_md(value, item)
    @mp_damage = 0
    @mp_drain = 0
    @mp_level_damage = item.mp_damage
    @mp_level_drain = item.mp_drain
    @mp_level_heal = item.mp_heal
    @success = true if @mp_level_damage[1] > 0
    @success = true if @mp_level_drain[1] > 0
    @success = true if @mp_level_heal[1] > 0
  end
  def mp_lvl_dam
    @mp_level_damage
  end
  def mp_lvl_drn
    @mp_level_drain
  end
  def mp_lvl_heal
    @mp_level_heal
  end
  def mp_dam_lvl_text
    text = @battler.name + " lost " + @mp_level_damage[1].to_s + " Level "
    text += @mp_level_damage[0].to_s + Vocab::mp_a
  end
  def mp_dam_heal_text
    text = @battler.name + " gained " + @mp_level_heal[1].to_s + " Level "
    text += @mp_level_heal[0].to_s + Vocab::mp_a
  end
end
 
class RPG::Skill < RPG::UsableItem
  def mp_level
    self.note =~ /<MP_LEVEL (\d+)>/ ? $1.to_i : 0
  end
end
 
class RPG::UsableItem
  def mp_damage
    self.note =~ /<MP_DAMAGE (\d+) (\d+)>/ ? [$1.to_i,$2.to_i] : [0,0]
  end
  def mp_drain
    self.note =~ /<MP_DRAIN (\d+) (\d+)>/ ? [$1.to_i,$2.to_i] : [0,0]
  end
  def mp_heal
    self.note =~ /<MP_HEAL (\d+) (\d+)>/ ? [$1.to_i,$2.to_i] : [0,0]
  end
end
 
class Window_Base
  def mp_color(actor, lvl = 0)
    return crisis_color if actor.mp(lvl) == 0
    return normal_color
  end
  def draw_actor_mp(actor, x, y, width = 124)
    change_color(system_color)
    draw_text(x, y, 24, line_height, Vocab::mp_a)
    4.times do |i|
      change_color(mp_color(actor, i))
      draw_text(x + 30 + i*24,y,width,line_height,actor.mp(i))
      change_color(normal_color)
      draw_text(x + 30 + i*24+12,y,width,line_height,"/") unless i == 3
    end
  end
end
 
class Window_BattleLog
  def display_mp_damage(target, item)
    return if target.dead?
    if target.result.mp_damage == 0
      Sound.play_recovery if target.result.mp_damage < 0
      add_text(target.result.mp_damage_text)
      wait
    elsif target.result.mp_lvl_dam[1] > 0
      add_text(target.result.mp_dam_lvl_text)
      wait
    elsif target.result.mp_lvl_heal[1] > 0
      add_text(target.result.mp_heal_lvl_text)
      wait
    end
  end
end
 
class Window_SkillList
  def draw_skill_cost(rect, skill)
    if @actor.skill_tp_cost(skill) > 0
      change_color(tp_cost_color, enable?(skill))
      draw_text(rect, @actor.skill_tp_cost(skill), 2)
    elsif @actor.skill_mp_cost(skill) > 0
      change_color(mp_cost_color, enable?(skill))
      if DISPLAY_SKILL_USES
	text = (@actor.mp(skill.mp_level) / @actor.skill_mp_cost(skill)).to_s
      else
        text = "Lvl " + skill.mp_level.to_s + ": " + @actor.skill_mp_cost(skill).to_s
      end
      draw_text(rect, text, 2)
    end
  end
end
 
class Game_Enemy
  alias mp_lvl_init initialize
  def initialize(index, enemy_id)
    mp_lvl_init(index, enemy_id)
    @mp = mmp_reset
  end
end
 
class Window_BattleStatus
  def draw_gauge_area_without_tp(rect, actor)
    draw_actor_hp(actor, rect.x - 30, rect.y, 130)
    draw_actor_mp(actor, rect.x + 106,  rect.y, 76)
  end
end