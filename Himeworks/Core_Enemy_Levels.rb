=begin
#===============================================================================
 Title: Enemy Levels
 Author: Hime
 Date: Nov 23, 2013
 URL: http://himeworks.com/2013/11/16/enemy-levels/
--------------------------------------------------------------------------------
 ** Change log
 Nov 23, 2013
   - fixed bug with extended note-tag not recognizing multi-lines
 Nov 16, 2013
   - fixed variable names in formulas
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
 
 This script allows you to assign levels to enemies. The level of an enemy
 is evaluated when you encounter the enemy.
 
 The level is specified as a formula, which means you can define two types of
 levels:
 
 1. Static level. This means the enemy's level never changes throughout the
 game. For example, a slime might always be level 1 no matter what.
 
 2. Dynamic level. This means the enemy's level relies on data that may change
 throughout the game. For example, you can bind an enemy's level to a game
 variable so that its level changes whenever you change the variable.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 To set an enemy's level, note-tag it with
 
   <enemy level: FORMULA>
   
 You can use the extended note-tag if you need to write your formula on
 multiple lines
 
   <enemy level>
     FORMULA
   </enemy level>

 The formula can be any valid ruby formula that evaluates to a number.
 The following formula variables are available:
 
   e - the enemy itself (Game_Enemy object)
   p - game party
   t - game troop
   s - game switches
   v - game variables
   
 By default, if no level is specified, then the enemy is assumed to be level 1.
 
 -- Level Limits --
 
 You can set maximum and minimum levels for enemies using note-tags.
 
   <max enemy level: FORMULA>
   <min enemy level: FORMULA>
   
 By default, the min level is 1 and max level is 99.
 
 -- Adjusting levels --
 
 If you want to adjust levels during battle, you can use script calls.
 This call sets the level of the specified enemy.
 
   set_enemy_level(index, level)
   
 This call changes the level of the specified enemy. A positive number will
 increase its level, while a negative number will decrease its level. The
 change cannot go past the limits.
 
   change_enemy_level(index, level)
 
 The index is the index of the enemy in the troop.
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_EnemyLevels"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Enemy_Levels
    
    # Display the level in the enemy's name?
    Display_Level = true
    
    # How the name should be displayed. Takes the name and the level
    Display_Format = "%s LV %d"
    
    Regex = /<enemy[-_ ]level:\s*(.*)\s*>/i
    Ext_Regex = /<enemy[-_ ]level>(.*?)<\/enemy[-_ ]level>/im
    
    Max_Regex = /<max[-_ ]enemy[-_ ]level:\s*(.*)\s*>/i
    Min_Regex = /<min[-_ ]enemy[-_ ]level:\s*(.*)\s*>/i

#===============================================================================
# ** Rest of script
#===============================================================================
  end
end

module RPG
  class Enemy < BaseItem
    
    def level(enemy)
      [eval_level_formula(enemy), self.min_level(enemy)].max
    end
    
    def level_formula
      load_notetag_enemy_levels unless @level_formula
      return @level_formula
    end
    
    def eval_level_formula(e, p=$game_party, t=$game_troop, s=$game_switches, v=$game_variables)
      eval(self.level_formula)
    end
    
    def min_level(enemy)
      eval_min_level(enemy)
    end
    
    def min_level_formula
      load_notetag_enemy_levels unless @min_level_formula
      return @min_level_formula
    end
    
    def eval_min_level(e, p=$game_party, t=$game_troop, s=$game_switches, v=$game_variables)
      eval(self.min_level_formula)
    end
    
    def max_level(enemy)
      eval_max_level(enemy)
    end
    
    def max_level_formula
      load_notetag_enemy_levels unless @max_level_formula
      return @max_level_formula
    end
    
    def eval_max_level(e, p=$game_party, t=$game_troop, s=$game_switches, v=$game_variables)
      eval(self.max_level_formula)
    end
    
    def load_notetag_enemy_levels
      @level_formula = "1"
      @max_level_formula = "99"
      @min_level_formula = "1"
      
      if self.note =~ TH::Enemy_Levels::Regex
        @level_formula = $1
      end
      
      if self.note =~ TH::Enemy_Levels::Ext_Regex
        @level_formula = $1
      end
      
      # get max and min level formulas
      if self.note =~ TH::Enemy_Levels::Max_Regex
        @max_level_formula = $1
      end
      
      if self.note =~ TH::Enemy_Levels::Min_Regex
        @min_level_formula = $1
      end
    end
  end
end

class Game_Enemy < Game_Battler
  
  attr_reader :level
  
  alias :th_enemy_levels_initialize :initialize
  def initialize(index, enemy_id)
    @enemy_id = enemy_id
    setup_level(enemy_id)
    th_enemy_levels_initialize(index, enemy_id)
  end
  
  def setup_level(enemy_id)
    set_level(enemy.level(self))
  end
  
  alias :th_enemy_levels_name :name
  def name
    name = th_enemy_levels_name
    if TH::Enemy_Levels::Display_Level
      return sprintf(TH::Enemy_Levels::Display_Format, name, @level)
    else
      return name
    end
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def max_level
    enemy.max_level(self)
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def min_level
    enemy.min_level(self)
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def change_level(amount)
    @level = [[@level + amount, max_level].min, min_level].max
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def set_level(amount)
    @level = [[amount, max_level].min, min_level].max
  end
end

class Game_Interpreter
  
  def get_enemy(index)
    $game_troop.members[index-1]
  end
  
  def set_enemy_level(index, level)
    enemy = get_enemy(index)
    return unless enemy
    enemy.set_level(level)
  end
  
  def change_enemy_level(index, level)
    enemy = get_enemy(index)
    return unless enemy
    enemy.change_level(level)
  end
end