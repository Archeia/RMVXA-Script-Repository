=begin
#===============================================================================
 Title: Attack Skill Command
 Author: Hime
 Date: Mar 12, 2014
--------------------------------------------------------------------------------
 ** Change log
 Mar 12, 2014
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script changes your attack command depending on a variety of conditions.
 The attack command can be based on what states are applied, what your actor
 has currently equipped, or what their class is.
 
 By default, the attack command uses the guard skill, which is the first skill.
 However, by adding a few simple tags and some priorities, you can customize
 what the attack command is.

--------------------------------------------------------------------------------
 ** Required
 
 Command Manager
 (http://himeworks.com/2013/02/19/command-manager/)
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Command Manager and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 Note-tag actors, classes, weapons, armors, or states with
 
   <attack skill: ID PRIORITY>
   
 For some skill ID.
 
 The priority is used if you have multiple states or equips with a
 attack skill ID. the highest priority is taken in this case, and if multiple
 attack skill ID's have equal priority, then whichever appears first is taken.
 
 If you would like to use a formula for the ID, you will need to use the
 extended note-tag:
 
   <attack skill>
     id: FORMULA
     priority: x
   </attack skill>
   
 You can use any valid formula that returns a number. The following formula
 variables are available:
 
   a - the current battler you are inputting commands for
   t - game troop
   p - game party
   v - game variables
   s - game switches
 
 If your actor does not have a custom attack skill ID, then it defaults to
 the actor's attack skill. If the actor does not have a custom attack skill,
 then it defaults to the class attack skill. Finally, it will default to skill
 1 if no custom attack skills are defined.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_AttackSkillCommand] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Attack_Skill_Command
    Regex = /<attack[-_ ]skill:\s*(\d+)\s*(\d+)?\s*>/i
    Ext_Regex = /<attack[-_ ]skill>(.*?)<\/attack[-_ ]skill>/im
  end
end

module RPG
  
  class BaseItem
    
    def attack_skill
      load_notetag_change_attack unless @attack_skill
      return @attack_skill
    end
    
    def load_notetag_change_attack
      attack_skill_id = 0
      priority = 1
      attack_skill_formula = ""
      if self.note =~ TH::Attack_Skill_Command::Regex
        attack_skill_id = $1.to_i
        priority = $2.to_i if $2
      elsif self.note =~ TH::Attack_Skill_Command::Ext_Regex
        results = $1.strip.split("\r\n")
        results.each do |data|
          case data
          when /.*id:\s*(.*)\s*/i
            attack_skill_formula = $1
          when /.*priority:\s*(\d+)\s*/i
            priority = $1.to_i
          end
        end
      end
      if attack_skill_id > 0
        @attack_skill = Data_AttackSkill.new(attack_skill_id, priority, attack_skill_formula)
      end
    end
  end
end

class Data_AttackSkill

  attr_reader :priority
  attr_reader :attack_skill_formula
  
  def initialize(attack_skill_id, priority, attack_skill_formula)
    @attack_skill_id = attack_skill_id
    @priority = priority
    @attack_skill_formula = attack_skill_formula
  end
  
  def attack_skill_id(battler)
    return eval_attack_skill(battler) unless @attack_skill_formula.empty?
    return @attack_skill_id
  end
  
  def eval_attack_skill(a, p=$game_party, t=$game_troop, v=$game_variables, s=$game_switches)
    eval(@attack_skill_formula)
  end
end

class Game_Actor < Game_Battler
  
  alias :th_attack_skill_cmd_attack_skill_id :attack_skill_id
  def attack_skill_id
    id = 0
    
    data = []
    # check equips and states for attack skill
    (equips + states).each do |obj|
      next unless obj
      data << obj.attack_skill if obj.attack_skill
    end
    
    # Choose the one with highest priority
    data.sort_by {|obj| -obj.priority }
    id = data[0].attack_skill_id(self) if data[0]
    return id if id > 0
    
    # check actor for attack skill
    if actor.attack_skill
      id = actor.attack_skill.attack_skill_id(self)
      return id if id > 0
    end
    
    # check class for attack skill
    if self.class.attack_skill
      id = self.class.attack_skill.attack_skill_id(self)
      return id if id > 0
    end
    # default attack skill
    return th_attack_skill_cmd_attack_skill_id
  end
end

class Command_Attack < Game_BattlerCommand
  
  alias :th_attack_skill_cmd_initialize :initialize
  def initialize(*args)
    th_attack_skill_cmd_initialize(*args)
    @ext = 1
  end
  
  def name
    $data_skills[self.ext].name
  end
  
  def ext
    @battler.attack_skill_id
  end
end

class Scene_Battle < Scene_Base
  
  #-----------------------------------------------------------------------------
  # Attack command now functions the same way as use_skill, except the attack
  # command uses the special API
  #-----------------------------------------------------------------------------
  def command_attack
    command_use_skill
  end
  
  alias :th_attack_skill_cmd_on_enemy_cancel :on_enemy_cancel
  def on_enemy_cancel
    th_attack_skill_cmd_on_enemy_cancel
    @actor_command_window.activate if @actor_command_window.current_symbol == :attack
  end
  
  alias :th_attack_skill_cmd_on_actor_cancel :on_actor_cancel
  def on_actor_cancel
    th_attack_skill_cmd_on_actor_cancel
    @actor_command_window.activate if @actor_command_window.current_symbol == :attack
  end
end