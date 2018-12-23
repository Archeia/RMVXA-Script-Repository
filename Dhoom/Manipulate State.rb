#==============================================================================
# 
# • Dhoom Manipulate State v1.04
# -- Last Updated: 2014.11.02
# -- Level: Easy, Normal
# -- Requires: YEA - Ace Battle Engine v1.15+, YSA Battle System: Classical ATB
#
# Aditional Credit :
#   - joeyjoejoe (Commission requester)
#   - DoubleX (YSA Battle System: Classical ATB Bug Fix)
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["DHManipulate"] = true

#==============================================================================
# ¥ Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2015.01.18 - Fixed BattleStatus cursor not changing when manipulated enemies added
# 2014.11.23 - Add compatibility with Hime - Skill Type Groups
# 2014.11.20 - Fixed window actor command showing when selecting skills or items
# 2014.11.02 - Fixed minor bug with get_index method
# 2014.10.03 - Change control skill notetag to array
# 2014.09.29 - Add DoubleX YSA Battle System: Classical ATB Bug Fix to 
#              process_catb method.
# 2014.09.28 - Finished Script.
# 2014.09.25 - Started Script.
# 
#==============================================================================
# ¥ Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script let you manipulate enemies with states. Manipulated enemies can
# use skillset that you set in Enemy Note with notetags.
#==============================================================================
# ▼ Instructions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials and Required Scripts but above ▼ Main. 
# Place below DoubleX RMVXA Bug Fix to YSA Battle System: Classical ATB
# if installed. Remember to save.
#
# -----------------------------------------------------------------------------
# State Notetags - These notetags go in the state notebox in the database.
# -----------------------------------------------------------------------------
# <manipulate>
# Enemies that affected with this state will be manipulated.
#
# -----------------------------------------------------------------------------
# Enemy Notetags - These notetags go in the enemy notebox in the database.
# -----------------------------------------------------------------------------
# <control skill: x,x,..>
# Manipulated Enemy's skillset. Change x with skill id.
#
#==============================================================================

module Dhoom
  module REGEXP
    module Enemy
      Control_Skill = /<(?:CONTROL SKILL|control_skill|control skill):[ ]*(.*)>/i
    end
    
    module State
      Manipulate = /<(?:MANIPULATE|manipulate)>/i
    end
  end
end

class RPG::Enemy < RPG::BaseItem
  
  attr_reader :skill_types
  attr_reader :control_skill
  
  def load_notetags_dhms
    @skill_types = []
    @control_skill = []
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when Dhoom::REGEXP::Enemy::Control_Skill
        r = $1.split(",")
        r.each do |v|
          @control_skill.push($data_skills[v.to_i])
        end
      end
      }
    @control_skill.each { |skill|
      if !@skill_types.include?(skill.stype_id) and skill.stype_id != 0
        @skill_types.push(skill.stype_id)
      end
    }
    if $imported["TH_SkillTypeGroups"]
      hash = TH::Skill_Type_Groups::Stype_Table.sort_by { |index, types| types.size }
      hash.reverse!
      hash.each do |type|
        included = true
        type[1].each_with_index { |t,i| included = false if !@skill_types.include?(t) and i < 1 }
        if included
          type[1].each { |t| @skill_types.delete(t) }
          @skill_types.push(type[0])
        end
        @skill_types.compact!
      end
    end
  end  
end

class RPG::State < RPG::BaseItem
  
  attr_reader :manipulate
  
  def load_notetags_dhms
    @manipulate = false
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when Dhoom::REGEXP::State::Manipulate
        @manipulate = true
      end
    }
  end 
end
  
module DataManager
  
  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_dhms load_database; end
  def self.load_database
    load_database_dhms
    load_notetags_dhms
  end
  
  #--------------------------------------------------------------------------
  # new method: load_notetags_catb
  #--------------------------------------------------------------------------
  def self.load_notetags_dhms
    groups = [$data_enemies, $data_states]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_dhms
      end
    end
  end
  
end

module BattleManager
  def self.enemy_active(enemy=true)
    @enemy_active = enemy
  end
  
  def self.enemy_active?
    @enemy_active
  end
   
  def self.check_manipulated_enemies
    @action_battlers.each { |battler|
      if battler.enemy?
        @action_enemies.push(battler) if !@action_enemies.include?(battler) && !battler.manipulated?
        @action_enemies.delete(battler) if battler.manipulated?
        @action_actors.push(battler) if !@action_actors.include?(battler) && battler.manipulated?
        @action_actors.delete(battler) if !battler.manipulated?
      end
    }
    for i in 0...@action_actors.size
      @action_actors.delete_at(i) if !@action_battlers.include?(@action_actors[i])
    end
  end
    
  def self.actor
    ($game_party.members+$game_troop.manipulates)[@actor_index] if @actor_index >= 0
  end
end

class Game_Action
  alias dhoom_manipulate_gmaction_friends_unit friends_unit
  def friends_unit
    return subject.opponents_unit if subject.enemy? && subject.manipulated?
    dhoom_manipulate_gmaction_friends_unit
  end

  alias dhoom_manipulate_gmaction_opponents_unit opponents_unit
  def opponents_unit
    return subject.friends_unit if subject.enemy? && subject.manipulated?
    dhoom_manipulate_gmaction_opponents_unit
  end
end

class Game_BattlerBase
  def continuous_autobattle?
    return false unless actor? || (enemy? && manipulated?)    
    return $game_temp.continous_autobattle
  end
  
  def secondary_auto_battle?
    return false unless actor? || (enemy? && manipulated?)
    return false if index == 0
    return YEA::AUTOBATTLE::ENABLE_SECONDARY_AUTOBATTLE
  end
  
  alias dhoom_manipulate_battlerbase_skill_gold_cost skill_gold_cost if $imported["YEA-SkillCostManager"]
  def skill_gold_cost(skill)
    return 0 if !self.actor?
    dhoom_manipulate_battlerbase_skill_gold_cost(skill)
  end
end

class Game_Battler < Game_BattlerBase
  if $imported[:ve_materia_system]
  def apply_guard(damage)
    result = apply_guard_ve_materia_system(damage)
    return if !result
    @materia_user.actor? ? materia_damage(@materia_user, result) : result
  end
  end
  
  alias dhoom_manipulate_gmbattler_make_ct_catb_update make_ct_catb_update
  def make_ct_catb_update
    return if self.enemy? && self.manipulated? && !self.current_action.nil? && !self.current_action.confirm
    dhoom_manipulate_gmbattler_make_ct_catb_update
  end
  
  if $imported[:ve_toggle_target]
  alias dhoom_manipulate_gmbattler_set_target_size set_target_size
  def set_target_size(item)
    return opponents_unit.alive_members.size if item.for_friend? && enemy? && manipulated?
    return opponents_unit.dead_members.size    if item.for_dead_friend? && enemy? && manipulated?
    return friends_unit.alive_members.size   if item.for_opponent? && enemy? && manipulated?
    dhoom_manipulate_gmbattler_set_target_size(item)
  end
end
end

class Game_Enemy < Game_Battler
  attr_accessor :last_skill
  if $imported["TH_CursorMemory"]
    attr_accessor :last_battle_command_index
    attr_accessor :last_battle_target_actor    # last targeted actor in battle
    attr_accessor :last_battle_target_enemy    # last targeted enemy in battle
  end

  alias dhoom_manipulate_gmenemy_initialize initialize
  def initialize(index, enemy_id)
    dhoom_manipulate_gmenemy_initialize(index, enemy_id)
    @last_skill = Game_BaseItem.new
  end
  
  def manipulated?
    @states.each { |id|    
      return true if $data_states[id].manipulate
    }
    return false
  end
    
  def clear_actions
    super
    @action_input_index = 0
  end

  def input
    @actions[@action_input_index]
  end
  
  def skills
    $data_enemies[@enemy_id].control_skill
  end
  
  def skill_types
    $data_enemies[@enemy_id].skill_types
  end
  
  def for_all?(item)
    return false
  end
  
  def make_auto_battle_actions
    @actions.size.times do |i|
      @actions[i] = make_action_list.max_by {|action| action.value }
    end
  end
  
  alias dhoom_manipulate_gmenemy_make_actions make_actions
  def make_actions
    if manipulated?
      super  
    else
      dhoom_manipulate_gmenemy_make_actions
    end
  end
  
  def make_action_list
    list = []
    list.push(Game_Action.new(self).set_attack.evaluate)
    usable_skills.each do |skill|
      list.push(Game_Action.new(self).set_skill(skill.id).evaluate)
    end
    list
  end
  
  def usable_skills
    skills.select {|skill| usable?(skill) }
  end
end

class Game_Troop < Game_Unit
  attr_reader :manipulates
  attr_accessor :last_battle_command_index if $imported["TH_CursorMemory"]
  alias dhoom_manipulate_gmtroop_initialize initialize
  def initialize
    dhoom_manipulate_gmtroop_initialize
    @manipulates = []
  end
  
  def check_manipulated_battler
    @enemies.each do |enemy|
      @manipulates.delete(enemy) if !enemy.manipulated? && @manipulates.include?(enemy)
      @manipulates.push(enemy) if enemy.manipulated? && !@manipulates.include?(enemy)
    end
  end  
end

class Window_BattleStatus < Window_Selectable
  attr_accessor :disable_enemy
  alias dhoom_manipulate_wndbatstat_initialize initialize
  def initialize
    dhoom_manipulate_wndbatstat_initialize
    @manipulated = $game_troop.manipulates.clone
    @disable_enemy = false
  end
  
  def item_rect(index)
    rect = Rect.new
    rect.width = [contents.width / ($game_party.battle_members.size+$game_troop.manipulates.size), contents.width / $game_party.max_battle_members].min
    rect.height = contents.height
    rect.x = index * rect.width
    if YEA::BATTLE::BATTLESTATUS_CENTER_FACES
      rect.x += (contents.width - $game_party.members.size * rect.width) / 2
    end
    rect.y = 0
    return rect
  end
  
  def update
    super    
    if @party != $game_party.battle_members or (!@disable_enemy && @manipulated != $game_troop.manipulates) or (@disable_enemy && @manipulated != [])
      @party = $game_party.battle_members.clone
      @manipulated = @disable_enemy ? [] : $game_troop.manipulates.clone
      refresh
      update_cursor
    end
  end
  
  alias dhoom_manipulate_windbatstat_draw_actor_catb draw_actor_catb
  def draw_actor_catb(actor, dx, dy, width = 124)
    return if actor.nil?
    dhoom_manipulate_windbatstat_draw_actor_catb(actor, dx, dy, width)
  end
  
  def item_max
    if @disable_enemy
      $game_party.battle_members.size
    else
      $game_party.battle_members.size+$game_troop.manipulates.size
    end
  end

  def col_max
    return $game_party.max_battle_members+$game_troop.members.size
  end
  
  def battle_members
    return ($game_party.battle_members+$game_troop.manipulates)
  end
  
  def draw_actor_face(actor, x, y, enabled = true)
    if actor.actor?
      draw_face(actor.face_name, actor.face_index, x, y, enabled)
    elsif actor.enemy?
      draw_battler(actor.enemy.battler_name, actor.enemy.battler_hue, x, y, enabled)
    end
  end
  
  def draw_battler(battler_name, battler_hue, x, y, enabled = true)
    bitmap = Cache.battler(battler_name,battler_hue)
    rect = Rect.new(0, 0, 96, 96)
    contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
    bitmap.dispose
  end  
end

class Window_ActorCommand < Window_Command
  alias dhoom_manipulate_wndactcom_add_item_command add_item_command
  def add_item_command
    return if @actor.enemy?
    dhoom_manipulate_wndactcom_add_item_command
  end
  
  alias dhoom_manipulate_wndactcom_add_skill_commands add_skill_commands
  def add_skill_commands
    if @actor.enemy?
      @actor.skill_types.sort.each do |stype_id|
        name = $data_system.skill_types[stype_id]
        add_command(name, :skill, true, stype_id)
      end
    else
      dhoom_manipulate_wndactcom_add_skill_commands
    end    
  end
end

class Window_BattleHelp < Window_Help
  def update_battler_name
    return unless @actor_window.active || @enemy_window.active
    if @actor_window.active
      battler = ($game_party.battle_members+$game_troop.manipulates)[@actor_window.index]
    elsif @enemy_window.active
      battler = @enemy_window.enemy
    end
    if special_display?
      refresh_special_case(battler)
    else
      refresh_battler_name(battler) if battler_name(battler) != @text
    end
  end
end

class Scene_Battle < Scene_Base
  
  def process_catb
    if @status_window.index >= 0 && (!($game_party.members+$game_troop.manipulates)[@status_window.index] || ($game_party.members+$game_troop.manipulates)[@status_window.index].dead? || !BattleManager.action_list(:actor).include?(($game_party.members+$game_troop.manipulates)[@status_window.index]))    
      ($game_party.members+$game_troop.manipulates)[@status_window.index].clear_catb if ($game_party.members+$game_troop.manipulates)[@status_window.index]
      if @skill_window.visible || @item_window.visible
        @status_window.open
        @status_window.show
        @status_aid_window.hide
      end
      @actor_window.hide.deactivate
      @enemy_window.hide.deactivate
      @actor_command_window.deactivate
      @actor_command_window.close
      @skill_window.hide.deactivate
      @item_window.hide.deactivate
      @status_window.unselect
    end
    if BattleManager.action_list(:actor).size <= 0
      @party_command_window.deactivate
      @party_command_window.close
    end
    return unless SceneManager.scene_is?(Scene_Battle)
    return if scene_changing?
    return unless BattleManager.btype?(:catb)
    return if catb_pause?
    battler_hash = $game_party.members + $game_troop.members
    battler_hash.each { |a|
      a.clear_actions if $imported["DoubleX RMVXA Bug Fixes to YSA-CATB"] and a.catb_value == 0
      a.make_catb_update
      a.make_catb_action
      a.make_ct_catb_update
    }    
    #--- Update Tick Turn
    if $game_system.catb_turn_type == :tick
      @tick_clock = 0 if !@tick_clock
      @tick_clock += 1
      if @tick_clock >= $game_system.catb_tick_count
        @tick_clock = 0
        all_battle_members.each { |battler|
          battler.on_turn_end
          battler.perform_collapse_effect if battler.enemy? && battler.can_collapse?
        }
        @status_window.refresh
        $game_troop.increase_turn
      end
    end
    #--- Fix make action
    BattleManager.action_list(:actor).each { |battler|
      battler.make_actions if battler.enemy? && battler.manipulated? && !battler.input
      battler.make_auto_battle_actions if battler.auto_battle?
    }
    if @temp_manipulates != $game_troop.manipulates
      @status_window.refresh
      @temp_manipulates = $game_troop.manipulates.clone
    end
    #---
    @status_window.refresh_catb
    #--- Setup Actor
    @f_actor_index = 0 if !@f_actor_index || @f_actor_index < 0 || @f_actor_index + 1 > BattleManager.action_list(:actor).size
    f_actor = BattleManager.action_list(:actor)[@f_actor_index]    
    if $imported["DoubleX RMVXA Bug Fixes to YSA-CATB"]
      f_actor_count = 0
      while f_actor_count < BattleManager.action_list(:actor).size && f_actor && (f_actor.input && f_actor.input.item && f_actor.input.confirm || f_actor.auto_battle? || f_actor.confusion? || !f_actor.max_catb_value? || f_actor.ct_catb_value > 0)
        f_actor_count += 1
        @f_actor_index + 1 < BattleManager.action_list(:actor).size ? @f_actor_index += 1 : @f_actor_index = 0
        f_actor = BattleManager.action_list(:actor)[@f_actor_index]
      end
    else
      @f_actor_index += 1 if (@f_actor_index + 1) < BattleManager.action_list(:actor).size && f_actor && f_actor.input && f_actor.input.item && f_actor.input.confirm
      f_actor = BattleManager.action_list(:actor)[@f_actor_index]
    end
    @enemy_active = f_actor.enemy? if f_actor
    index = get_index(f_actor)
    if f_actor && f_actor.input && !f_actor.input.confirm && (!BattleManager.actor || @status_window.index != index) && !@party_command_window.active && !@actor_command_window.active && !@skill_window.active && !@item_window.active
      BattleManager.set_actor(index)
      @status_window.select(index)
      @actor_command_window.setup(BattleManager.actor)
      @actor_command_window.show
      @temp_enemy = @enemy_active
    end
    BattleManager.action_list.each { |battler|
      if $imported["DoubleX RMVXA Bug Fixes to YSA-CATB"]
        battler.make_actions if (battler.enemy? || battler.input.confirm) && battler.max_catb_value? && battler.ct_catb_value <= 0
      else
        battler.make_actions if battler.enemy? && !battler.manipulated?
      end
      perform_catb_action(battler) if !@subject
    }
  end
    
  def prior_f_actor
    if @f_actor_index && BattleManager.action_list(:actor).size > 0
      @f_actor_index -= 1
      @f_actor_index = BattleManager.action_list(:actor).size-1 if @f_actor_index < 0
      f_actor = BattleManager.action_list(:actor)[@f_actor_index] 
      index = get_index(f_actor)
      if f_actor
        @enemy_active = f_actor.enemy?
        @temp_enemy = @enemy_active
        BattleManager.set_actor(index)
        @status_window.select(index)
        @actor_command_window.setup(BattleManager.actor)
      end
    end
  end  
  
  def next_f_actor
    if @f_actor_index && BattleManager.action_list(:actor).size > 0
      @f_actor_index += 1
      @f_actor_index = 0 if (@f_actor_index + 1) > BattleManager.action_list(:actor).size
      f_actor = BattleManager.action_list(:actor)[@f_actor_index]
      index = get_index(f_actor)
      if f_actor
        @enemy_active = f_actor.enemy?
        @temp_enemy = @enemy_active
        BattleManager.set_actor(index)
        @status_window.select(index)
        @actor_command_window.setup(BattleManager.actor)
      end
    end
  end  
  
  def get_index(actor)
    return unless actor
    index = actor.index if actor.actor?     
    index = $game_troop.manipulates.index(actor) + $game_party.members.size if actor.enemy? and $game_troop.manipulates.include?(actor)
    return index
  end
  
  alias dhoom_manipulate_scbattle_select_actor_selection select_actor_selection
  def select_actor_selection
    @actor_window.disable_enemy = BattleManager.actor.nil? ? false : BattleManager.actor.actor?
    dhoom_manipulate_scbattle_select_actor_selection
  end
  
  alias dhoom_manipulate_scbattle_perform_catb_action perform_catb_action
  def perform_catb_action(subject, forced = false)
    dhoom_manipulate_scbattle_perform_catb_action(subject, forced)
    BattleManager.check_manipulated_enemies
    $game_troop.check_manipulated_battler
  end   
  
  alias dhoom_manipulate_scbattle_catb_on_enemy_ok catb_on_enemy_ok
  def catb_on_enemy_ok
    return if !BattleManager.actor
    dhoom_manipulate_scbattle_catb_on_enemy_ok
  end
  
  alias dhoom_manipulate_scbattle_command_pautobattle command_pautobattle if $imported["YEA-CommandAutobattle"]
  def command_pautobattle
    for member in $game_troop.manipulates
      next unless member.inputable?      
      member.make_auto_battle_actions
    end
    dhoom_manipulate_scbattle_command_pautobattle
  end
  
  def command_aautobattle
    BattleManager.actor.make_auto_battle_actions
    BattleManager.actor.input.confirm = true
    next_command
  end
  
  alias dhoom_manipulate_scbattle_terminate terminate
  def terminate
    dhoom_manipulate_scbattle_terminate
    $game_troop.manipulates.clear
  end
end