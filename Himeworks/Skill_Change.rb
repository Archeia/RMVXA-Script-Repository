=begin
#===============================================================================
 Title: Skill Change
 Author: Hime
 Date: Sep 26, 2013
--------------------------------------------------------------------------------
 ** Change log
 Sep 26, 2013
   - added support for per-target mode
   - added support for multiple skill changes for a single skill
   - added support for action targets
 May 19, 2013
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
 
 This script allows you to set a skill to execute a different skill if
 certain conditions are met, with some probability.
 
 For example, if your actor's HP is less than 50%, then there might be a chance
 that each attack will be a special "critical attack" instead.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 Tag your skills with something of the form
 
   <skill change>
     id: 3
     chance: 0.5
     condition: a.hp < a.mhp * 0.5
   </skill change>
   
 Where
   `id` is the skill ID to change it to
   `chance` is the probability that it will be changed, as a percent
   `condition` is a formula that must be satisfied
   
 The following variables are available
 
   a - attacker
   b - list of targets**
   
 Be careful about the targets. Because a skill can target multiple targets,
 it is given as a list of targets. For example if you want to check if the
 first target has state 5 applied, you would check
 
   b[0].state?(5)
   
 If per-target skill change mode is ON, then you don't need to worry about
 the indexing and can just treat b as the target.

#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_SkillChange"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Skill_Change
    
    # Per target skill change mode. Checks the skill for each enemy individually
    # This is an add-on and you probably won't need it unless your skill change
    # skills can target multiple battlers
    Per_Target_Mode = false
    
    Regex = /<skill change>(.*?)<\/skill change>/im
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  class Skill
    def skill_change_data
      load_notetag_skill_change unless @skill_change_data
      return @skill_change_data
    end
    
    def load_notetag_skill_change
      @skill_change_data = []
      res = self.note.scan(TH::Skill_Change::Regex)
      res.each do |result|
        chance = 1
        condition = "true"
        
        data = result[0].strip.split("\r\n")
        for option in data
          case option
          when /id:\s*(\d+)/i
            id = $1.to_i
          when /chance:\s*(.*)/i
            chance = $1.to_f
          when /condition:\s*(.*)/i
            condition = $1
          end
        end
        changeData = Data_SkillChange.new(id)
        changeData.chance = chance
        changeData.condition = condition
        @skill_change_data << changeData
      end
    end
  end
end

class Data_SkillChange
  
  attr_accessor :id
  attr_accessor :chance
  attr_accessor :condition
  
  def initialize(id)
    @id = id
    @chance = 1
    @condition = "false"
  end
  
  def condition_met?(a, b, v=$game_variables, s=$game_switches)
    return false if @condition.empty?
    eval(@condition)
  end
end

class Game_Battler < Game_BattlerBase
  
  def change_skill
    item = current_action.item
    return unless item.is_a?(RPG::Skill)
    targets = current_action.make_targets
    item.skill_change_data.each do |changeData|
      if changeData.condition_met?(self, targets) && rand < changeData.chance
        current_action.set_skill(changeData.id)
        return
      end
    end
  end
end

class Scene_Battle < Scene_Base
  
  alias :th_skill_change_use_item :use_item
  def use_item
    @subject.change_skill
    th_skill_change_use_item
  end
end

#-------------------------------------------------------------------------------
# Per target add-on. This is...pretty bad.
#-------------------------------------------------------------------------------
if TH::Skill_Change::Per_Target_Mode
  class Game_Battler < Game_BattlerBase
    
    def change_skill(target, item)
      return unless item.is_a?(RPG::Skill)
      item.skill_change_data.each do |changeData|
        if changeData.condition_met?(self, target) && rand < changeData.chance
          current_action.set_skill(changeData.id)
          return
        end
      end
      current_action.set_skill(item.id)
    end
  end

  class Scene_Battle < Scene_Base
    
    #---------------------------------------------------------------------------
    # Need to change how items are used
    #---------------------------------------------------------------------------
    def use_item
      orig_item = @subject.current_action.item
      @log_window.display_use_item(@subject, orig_item)
      @subject.use_item(orig_item)
      refresh_status
      targets = @subject.current_action.make_targets.compact
      
      # everything up to here is the same. This is where it gets complex
      targets.each do |target|
        @subject.change_skill(target, orig_item)
        item = @subject.current_action.item
        show_animation([target], item.animation_id)
        item.repeats.times { invoke_item(target, item) }
      end
    end
  end
end