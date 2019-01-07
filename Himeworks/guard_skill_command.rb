=begin
#===============================================================================
 Title: Guard Skill Command
 Author: Hime
 Date: Nov 19, 2013
--------------------------------------------------------------------------------
 ** Change log
 Nov 19, 2013
   - added support for formulas
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
 
 This script changes your guard command depending on a variety of conditions.
 The guard command can be based on what states are applied, what your actor
 has currently equipped, or what their class is.
 
 By default, the guard command uses the guard skill, which is the second skill.
 However, by adding a few simple tags and some priorities, you can customize
 what the guard command is.

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
 
   <guard skill: ID PRIORITY>
   
 For some skill ID.
 
 The priority is used if you have multiple states or equips with a
 guard skill ID. the highest priority is taken in this case, and if multiple
 guard skill ID's have equal priority, then whichever appears first is taken.
 
 If you would like to use a formula for the ID, you will need to use the
 extended note-tag:
 
   <guard skill>
     id: FORMULA
     priority: x
   </guard skill>
   
 You can use any valid formula that returns a number. The following formula
 variables are available:
 
   a - the current battler you are inputting commands for
   t - game troop
   p - game party
   v - game variables
   s - game switches
 
 If your actor does not have a custom guard skill ID, then it defaults to
 the actor's guard skill. If the actor does not have a custom guard skill, then
 it defaults to the class guard skill. Finally, it will default to skill 2 if
 no custom guard skills are defined.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_GuardSkillCommand"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Guard_Skill_Command
    Regex = /<guard[-_ ]skill:\s*(\d+)\s*(\d+)?\s*>/i
    Ext_Regex = /<guard[-_ ]skill>(.*?)<\/guard[-_ ]skill>/im
  end
end

module RPG
  
  class BaseItem
    
    def guard_skill
      load_notetag_change_guard unless @guard_skill
      return @guard_skill
    end
    
    def load_notetag_change_guard
      guard_skill_id = 0
      priority = 1
      guard_skill_formula = ""
      if self.note =~ TH::Guard_Skill_Command::Regex
        guard_skill_id = $1.to_i
        priority = $2.to_i if $2
      elsif self.note =~ TH::Guard_Skill_Command::Ext_Regex
        results = $1.strip.split("\r\n")
        results.each do |data|
          case data
          when /.*id:\s*(.*)\s*/i
            guard_skill_formula = $1
          when /.*priority:\s*(\d+)\s*/i
            priority = $1.to_i
          end
        end
      end
      @guard_skill = Data_GuardSkill.new(guard_skill_id, priority, guard_skill_formula)
    end
  end
end

class Data_GuardSkill

  attr_reader :priority
  attr_reader :guard_skill_formula
  
  def initialize(guard_skill_id, priority, guard_skill_formula)
    @guard_skill_id = guard_skill_id
    @priority = priority
    @guard_skill_formula = guard_skill_formula
  end
  
  def guard_skill_id(battler)
    return eval_guard_skill(battler) unless @guard_skill_formula.empty?
    return @guard_skill_id
  end
  
  def eval_guard_skill(a, p=$game_party, t=$game_troop, v=$game_variables, s=$game_switches)
    eval(@guard_skill_formula)
  end
end

class Game_Actor < Game_Battler
  
  alias :th_guard_skill_cmd_guard_skill_id :guard_skill_id
  def guard_skill_id
    id = 0
    
    data = []
    # check equips and states for guard skill
    (equips + states).each do |obj|
      next unless obj
      data << obj.guard_skill if obj.guard_skill && obj.guard_skill.guard_skill_id(self) > 0
    end

    # Choose the one with highest priority
    data.sort_by {|obj| -obj.priority }
    id = data[0].guard_skill_id(self) if data[0]
    return id if id > 0
    
    # check actor for guard skill
    id = actor.guard_skill.guard_skill_id(self)
    return id if id > 0
    
    # check class for guard skill
    id = self.class.guard_skill.guard_skill_id(self)
    return id if id > 0
    
    # default guard skill
    return th_guard_skill_cmd_guard_skill_id
  end
end

class Command_Guard < Game_BattlerCommand
  
  alias :th_guard_skill_cmd_initialize :initialize
  def initialize(*args)
    th_guard_skill_cmd_initialize(*args)
    @ext = 2
  end
  
  def name
    $data_skills[self.ext].name
  end
  
  def ext
    @battler.guard_skill_id
  end
end

class Scene_Battle < Scene_Base
  
  #-----------------------------------------------------------------------------
  # Guard command now functions the same way as use_skill, except the guard
  # command uses the special API
  #-----------------------------------------------------------------------------
  def command_guard
    command_use_skill
  end
  
  alias :th_guard_skill_cmd_on_enemy_cancel :on_enemy_cancel
  def on_enemy_cancel
    th_guard_skill_cmd_on_enemy_cancel
    @actor_command_window.activate if @actor_command_window.current_symbol == :guard
  end
  
  alias :th_guard_skill_cmd_on_actor_cancel :on_actor_cancel
  def on_actor_cancel
    th_guard_skill_cmd_on_actor_cancel
    @actor_command_window.activate if @actor_command_window.current_symbol == :guard
  end
end