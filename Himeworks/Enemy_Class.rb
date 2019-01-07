=begin
#===============================================================================
 Title: Enemy Class
 Author: Hime
 Date: Sep 9, 2014
--------------------------------------------------------------------------------
 ** Change log
 Sep 9, 2014
   - added support for "add base params", which was not added for some reason
 Apr 30, 2014
   - fixed bug where enemy may not have a class
 Mar 17, 2014
   - added class features to the list of feature objects
 Nov 24, 2013
   - compatible with Yanfly's enemy levels
 Nov 16, 2013
   - fixed missing argument to original param_base
   - initial release
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
 
 This script allows you to set up enemies the same way actors are set up using
 classes.  
 
 An enemy's parameters are determined by their level, which is determined by
 the class parameter curves. You can set up your enemies strengths and
 weaknesses using its assigned class.
 
 An enemy's available actions are also determined by their class. In order to
 be able to use an action, they must have met the learning requirements for
 the class.
 
--------------------------------------------------------------------------------
 ** Required
 
 An enemy level script, such as
 
 Core - Enemy Levels
 (http://himeworks.com/2013/11/16/enemy-levels/)
 
 Yanfly Enemy Levels
 (http://yanflychannel.wordpress.com/rmvxa/gameplay-scripts/enemy-levels/)
 
 Or any other script that provides enemy levels.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Core - Enemy Levels and above Main

--------------------------------------------------------------------------------
 ** Usage
 
 To assign a class to an enemy, note-tag the enemy with

    <enemy class: x>
    
 Where x is the ID of the class.
 
 If no class is assigned, then the enemy will simply use its own parameters
 and actions: none of the class-related functionality will be applied.
 
 -- Changing classes --
 
 You can change an enemy's class using script calls.
 
   change_enemy_class(index, class_id)
   
 Where the index is the index of the enemy in the current troop, and the
 class_id is the ID of the class you want to change it to.
 
 -- Enemy Base Parameters --
 
 By default, enemy parameters are only used if no class is assigned.
 If a class is assigned, then parameters are pulled from the class only.
 
 However, if you would like to treat the class parameters in addition to the
 enemy's parameters, you can note-tag an enemy with
 
   <add enemy params>
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_EnemyClass"] = true
#==============================================================================
# ** Configuration
#==============================================================================
module TH
  module Enemy_Class
    
    Regex = /<enemy[-_ ]class:\s*(\d+)\s*>/i
    Add_Regex = /<add[-_ ]enemy[-_ ]params>/i
  end
end
#==============================================================================
# ** Rest of Script
#==============================================================================
module RPG
  class Enemy < BaseItem
    
    def class_id
      load_notetag_enemy_class unless @class_id
      return @class_id
    end
    
    def load_notetag_enemy_class
      @class_id = 0
      if self.note =~ TH::Enemy_Class::Regex
        @class_id = $1.to_i
      end
      
      @add_base_params = false
      if self.note =~ TH::Enemy_Class::Add_Regex
        @add_base_params = true
      end
    end
    
    def add_base_params?
      load_notetag_enemy_class if @add_base_params.nil?
      return @add_base_params
    end
  end
end

class Game_Enemy < Game_Battler
  
  alias :th_enemy_class_initialize :initialize
  def initialize(index, enemy_id)
    @enemy_id = enemy_id
    setup_class(enemy_id)
    th_enemy_class_initialize(index, enemy_id)
    @hp = mhp
    @mp = mmp
  end
  
  #-----------------------------------------------------------------------------
  # Add the class to the list of feature objects
  #-----------------------------------------------------------------------------
  alias :th_enemy_class_features_objects :feature_objects
  def feature_objects
    res = th_enemy_class_features_objects
    res << self.class if self.class
    res
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def setup_class(enemy_id)
    @class_id = enemy.class_id
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def class
    $data_classes[@class_id]
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def change_class(class_id)
    @class_id = class_id
  end
  
  alias :th_enemy_class_param_base :param_base
  def param_base(param_id)
    cls = self.class
    
    if cls
      if enemy.add_base_params?
        return th_enemy_class_param_base(param_id) + self.class.params[param_id, self.level] 
      else
        return self.class.params[param_id, self.level]
      end
    else
      return th_enemy_class_param_base(param_id)
    end
  end
  
  alias :th_enemy_class_action_valid? :action_valid?
  def action_valid?(action)
    class_condition_met?(action) && th_enemy_class_action_valid?(action)
  end
  
  #-----------------------------------------------------------------------------
  # New. If an enemy has a class assigned, then we check if there is a learning
  # requirement for the specified action. If no class or learning is available,
  # then assume it is valid.
  #-----------------------------------------------------------------------------
  def class_condition_met?(action)
    cls = self.class
    return true unless cls
    learning = cls.learnings.detect {|learning| learning.skill_id == action.skill_id }
    return true unless learning
    return false if self.level < learning.level
    return true
  end
end

class Game_Interpreter
  
  def get_enemy(index)
    $game_troop.members[index-1]
  end
  
  def change_enemy_class(index, class_id)
    enemy = get_enemy(index)
    enemy.change_class(class_id)
  end
end