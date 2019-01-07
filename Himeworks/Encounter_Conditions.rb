=begin
#===============================================================================
 Title: Encounter Conditions
 Author: Hime
 Date: Oct 23, 2013
--------------------------------------------------------------------------------
 ** Change log
 Oct 23, 2013
   - added support for negated conditional branches
 May 18, 2013
   - troop member encounter condition applies to evented battles as well 
   - supports multiple conditional branches
   - No encounter if troop is empty
 May 17, 2013
   - changed input format
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
 
 This script allows you to set conditions on whether a troop can be encountered,
 or whether specific members in a troop will appear.
 
 If a troop encounter condition is not met, then the troop will not appear.
 Similarly, if a troop member encounter condition is not met, then the member
 will not appear in battle when you encounter the troop.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 If you are using the "negated conditional branches" script, this script must
 be placed under it.
 
--------------------------------------------------------------------------------
 ** Usage

 Encounter conditions are simply conditional branch commands, with a comment
 before them specifying that it is an encounter condition. They can be created
 anywhere in a troop event page, in any page.
 
 To specify a troop encounter condition, first create a comment:
   
   <encounter condition>
   
 Then create a conditional branch command. That will be treated as the troop
 encounter condition. 
 
 Troop member encounter conditions apply to the specific members in the troop.
 The comment is similar to the troop condition, except you specify an index
 
   <encounter condition: index>
   
 Where `index` is the 1-based position of the enemy in the troop, so 1 would
 be the first enemy, 2 would be the second, and so on. Then you create a
 conditional branch as usual.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_EncounterConditions"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Encounter_Conditions
    
    Enemy_Regex = /<encounter[-_ ]condition: (\d+)>/i
    Troop_Regex = /<encounter[-_ ]condition>/i
    
    def self.eval_encounter_condition(cmd)
      params = cmd.parameters
      result = false
      case params[0]
      when 0  # Switch
        result = ($game_switches[params[1]] == (params[2] == 0))
      when 1  # Variable
        value1 = $game_variables[params[1]]
        if params[2] == 0
          value2 = params[3]
        else
          value2 = $game_variables[params[3]]
        end
        case params[4]
        when 0  # value1 is equal to value2
          result = (value1 == value2)
        when 1  # value1 is greater than or equal to value2
          result = (value1 >= value2)
        when 2  # value1 is less than or equal to value2
          result = (value1 <= value2)
        when 3  # value1 is greater than value2
          result = (value1 > value2)
        when 4  # value1 is less than value2
          result = (value1 < value2)
        when 5  # value1 is not equal to value2
          result = (value1 != value2)
        end
      #when 2  # Self switch
      #  if @event_id > 0
      #    key = [@map_id, @event_id, params[1]]
      #    result = ($game_self_switches[key] == (params[2] == 0))
      #  end
      when 3  # Timer
        if $game_timer.working?
          if params[2] == 0
            result = ($game_timer.sec >= params[1])
          else
            result = ($game_timer.sec <= params[1])
          end
        end
      when 4  # Actor
        actor = $game_actors[params[1]]
        if actor
          case params[2]
          when 0  # in party
            result = ($game_party.members.include?(actor))
          when 1  # name
            result = (actor.name == params[3])
          when 2  # Class
            result = (actor.class_id == params[3])
          when 3  # Skills
            result = (actor.skill_learn?($data_skills[params[3]]))
          when 4  # Weapons
            result = (actor.weapons.include?($data_weapons[params[3]]))
          when 5  # Armors
            result = (actor.armors.include?($data_armors[params[3]]))
          when 6  # States
            result = (actor.state?(params[3]))
          end
        end
      when 5  # Enemy
        enemy = $game_troop.members[params[1]]
        if enemy
          case params[2]
          when 0  # appear
            result = (enemy.alive?)
          when 1  # state
            result = (enemy.state?(params[3]))
          end
        end
      #when 6  # Character
      #  character = get_character(params[1])
      #  if character
      #    result = (character.direction == params[2])
      #  end
      when 7  # Gold
        case params[2]
        when 0  # Greater than or equal to
          result = ($game_party.gold >= params[1])
        when 1  # Less than or equal to
          result = ($game_party.gold <= params[1])
        when 2  # Less than
          result = ($game_party.gold < params[1])
        end
      when 8  # Item
        result = $game_party.has_item?($data_items[params[1]])
      when 9  # Weapon
        result = $game_party.has_item?($data_weapons[params[1]], params[2])
      when 10  # Armor
        result = $game_party.has_item?($data_armors[params[1]], params[2])
      when 11  # Button
        result = Input.press?(params[1])
      when 12  # Script
        result = eval(params[1])
      when 13  # Vehicle
        result = ($game_player.vehicle == $game_map.vehicles[params[1]])
      end
      return result
    end
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  
  # Conditions for the entire troop
  class Troop
    attr_accessor :encounter_conditions
    
    #---------------------------------------------------------------------------
    # Simple way to filter troop members that can be encountered
    #---------------------------------------------------------------------------
    alias :th_encounter_conditions_members :members
    def members
      parse_encounter_condition unless @encounter_condition_checked
      th_encounter_conditions_members.select {|member|
        member.encounter_condition_met?
      }
    end
    
    def encounter_conditions
      return @encounter_conditions unless @encounter_conditions.nil?
      parse_encounter_condition
      return @encounter_conditions
    end
    
    def parse_encounter_condition
      @encounter_condition_checked = true
      @encounter_conditions = []
      
      member_id = nil
      troop_flag = false
      enemy_flag = false
      @pages.each do |page|
        i = 0
        while i < page.list.size
          cmd = page.list[i]
          if cmd.code == 108 && page.list[i+1].code == 111
            next_cmd = page.list[i+1]
            if cmd.parameters[0] =~ TH::Encounter_Conditions::Troop_Regex 
              troop_flag = true
              @encounter_conditions = [next_cmd]
            elsif cmd.parameters[0] =~ TH::Encounter_Conditions::Enemy_Regex
              enemy_flag = true
              member_id = $1.to_i - 1
              @members[member_id].encounter_conditions = [next_cmd]
            end
            i += 1 
          elsif cmd.code == 111 && cmd.indent > 0
            if troop_flag
              @encounter_conditions << cmd
            elsif enemy_flag
              @members[member_id].encounter_conditions << cmd
            end
          elsif cmd.code == 412
          elsif cmd.code == 413
          elsif cmd.code == 0
          else
            troop_flag = false
            enemy_flag = false
          end
          i += 1
        end
      end
    end
    
    #---------------------------------------------------------------------------
    # Determines whether troop will appear
    #---------------------------------------------------------------------------
    def encounter_condition_met?
      self.encounter_conditions.all? {|cond|
        TH::Encounter_Conditions.eval_encounter_condition(cond)
      }
    end
  end
  
  #-----------------------------------------------------------------------------
  # Conditions for specific members in the troop
  #-----------------------------------------------------------------------------
  class Troop::Member
    attr_accessor :encounter_conditions
    
    def encounter_conditions
      return @encounter_conditions ||= []
    end
    
    #---------------------------------------------------------------------------
    # Determines whether the enemy will appear
    #---------------------------------------------------------------------------
    def encounter_condition_met?
      self.encounter_conditions.all? {|cond|
        TH::Encounter_Conditions.eval_encounter_condition(cond)
      }
    end
  end
  
  #-----------------------------------------------------------------------------
  # Checks whether the troop can be encountered
  #-----------------------------------------------------------------------------
  class Map::Encounter
    def encounter_condition_met?
      return $data_troops[@troop_id].encounter_condition_met? && !$data_troops[@troop_id].members.empty?
    end
  end
end

#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
class Game_Player < Game_Character
  
  alias :th_encounter_conditions_encounter_ok? :encounter_ok?
  def encounter_ok?(encounter)
    return false unless encounter.encounter_condition_met?
    th_encounter_conditions_encounter_ok?(encounter)
  end
end

#===============================================================================
# Using negated conditional branches. This script must be placed under the
# negated conditional branches script.
#===============================================================================
if $imported["TH_NegateConditionalBranch"]
  module TH
    module Encounter_Conditions
      class << self
        alias :th_negated_conditional_branch_eval_encounter_condition :eval_encounter_condition
      end
      
      def self.eval_encounter_condition(cmd)
        result = th_negated_conditional_branch_eval_encounter_condition(cmd)
        if cmd.negate_condition
          return !result
        else
          return result
        end
      end
    end
  end
end