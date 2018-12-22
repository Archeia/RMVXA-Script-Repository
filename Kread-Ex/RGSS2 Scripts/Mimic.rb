#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
# Mimic
# Author: Kread-EX
# Version 1.0
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

#-------------------------------------------------------------------------------------------------
#  TERMS OF USAGE
#-------------------------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work for commercial purposes if you like it.
# #  Credit is appreciated.
#-------------------------------------------------------------------------------------------------

=begin

INTRODUCTION

This little script allows you to replicate the Mime's job from Final Fantasy V,
and Tactics in a lesser extent. Simply put, it replaces the 'Attack' command
with the 'Mimic' command.

INSTRUCTIONS

You'll find two constants in the config module.
Mimic_Class = [1] Inside this, put all the IDs of the classes acting like mimes.
Mimic_Command = 'Mimic' The name of the mimic command.

If mimic is impossible, no matter the reason, the actor will simply do nothing.

COMPATIBILITY

Fully compatible with Battle Engine Melody.

=end

#==============================================================================
# ** Config Module
#==============================================================================
  
module KreadCFG
    
  Mimic_Class = [1]
  Mimic_Command = 'Mimic'
  
end

#==============================================================================
# ** Window_ActorCommand
#==============================================================================

class Window_ActorCommand < Window_Command
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  def setup(actor)
  # Default
  if !defined?(YEM::BATTLE_ENGINE)
    if KreadCFG::Mimic_Class.include?(actor.class.id)
      s1 = KreadCFG::Mimic_Command
    else
      s1 = Vocab::attack
    end
    s2 = Vocab::skill
    s3 = Vocab::guard
    s4 = Vocab::item
    if actor.class.skill_name_valid
      s2 = actor.class.skill_name
    end
    @commands = [s1, s2, s3, s4]
    @item_max = 4
    refresh
    self.index = 0
  # Melody version
  else
    @actor = actor
    @data = []; @commands = []; @skills = {}
    data_set = actor.class.id
    data_set = 0 if !YEM::BATTLE_ENGINE::CLASS_COMMANDS.include?(actor.class.id)
    #---
    for item in YEM::BATTLE_ENGINE::CLASS_COMMANDS[data_set]
      case item
      when :attack
        if KreadCFG::Mimic_Class.include?(actor.class.id)
          @commands.push(KreadCFG::Mimic_Command)
        else
          @commands.push(actor.attack_vocab)
        end
      when :skill;  @commands.push(actor.skill_vocab)
      when :guard;  @commands.push(actor.guard_vocab)
      when :item;   @commands.push(Vocab.item)
      when :equip;  @commands.push(YEM::BATTLE_ENGINE::EQUIP_VOCAB)
      when :escape
        next unless $game_troop.can_escape
        @commands.push(Vocab.escape)
      else
        valid = false
        if YEM::BATTLE_ENGINE::SKILL_COMMANDS.include?(item)
          @skills[item] = YEM::BATTLE_ENGINE::SKILL_COMMANDS[item][0]
          @commands.push(YEM::BATTLE_ENGINE::SKILL_COMMANDS[item][1])
          valid = true
        end
        next unless valid
      end
      @data.push(item)
    end
    #---
    @item_max = @commands.size
    refresh
    self.index = 0
  end
  end
  #--------------------------------------------------------------------------
end

#==============================================================================
# ** Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base
  if !defined?(YEM::BATTLE_ENGINE)
  #--------------------------------------------------------------------------
  # * Update Actor Command Selection (Default system)
  #--------------------------------------------------------------------------
  def update_actor_command_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      prior_actor
    elsif Input.trigger?(Input::C)
      case @actor_command_window.index
      when 0  # Attack/Mimic
        Sound.play_decision
        if KreadCFG::Mimic_Class.include?(@active_battler.class.id)
          if @last_action == nil
            @active_battler.action.clear
          else
            @active_battler.action = @last_action
          end
          next_actor
        else
          @active_battler.action.set_attack
          start_target_enemy_selection
        end
      when 1  # Skill
        Sound.play_decision
        start_skill_selection
      when 2  # Guard
        Sound.play_decision
        @active_battler.action.set_guard
        next_actor
      when 3  # Item
        Sound.play_decision
        start_item_selection
      end
    end
  end
  else
  #--------------------------------------------------------------------------
  # new method: actor_command_case (Melody)
  #--------------------------------------------------------------------------
  def actor_command_case
    if !@actor_command_window.enabled?(@actor_command_window.item)
      if @selected_battler.inputable? and !@selected_battler.auto_battle
        Sound.play_buzzer
      else
        Sound.play_cursor
        if !dtb? and (@actor_index == $game_party.members.size - 1)
          @actor_index = -1
        end
        next_actor
      end
      return
    end
    #---
    case @actor_command_window.item
    when :attack
      Sound.play_decision
      if KreadCFG::Mimic_Class.include?(@selected_battler.class.id)
        if @last_action == nil
          @selected_battler.action.clear
        else
          @selected_battler.action = @last_action
        end
        confirm_action
      else
        @selected_battler.action.set_attack
        start_target_enemy_selection
      end
    when :skill
      Sound.play_decision
      start_skill_selection
    when :guard
      Sound.play_decision
      @selected_battler.action.set_guard
      confirm_action
    when :item
      Sound.play_decision
      start_item_selection
    when :equip
      Sound.play_decision
      call_equip_menu
    when :escape
      Sound.play_decision
      @selected_battler.action.set_escape
      confirm_action
    else
      Sound.play_decision
      @command_action = true
      @skill = @actor_command_window.skill
      determine_skill
    end
  end
  end
  #--------------------------------------------------------------------------
  # * Execute Battle Actions
  #--------------------------------------------------------------------------
  alias_method(:krx_mimic_sb_execact, :execute_action) unless $@
  def execute_action
    if @active_battler.is_a?(Game_Actor)
      @last_action = @active_battler.action.clone
    end
    krx_mimic_sb_execact
  end
  #--------------------------------------------------------------------------
end

#==============================================================================
# ** Game_Battler
#==============================================================================

class Game_Battler
  attr_accessor :action
end