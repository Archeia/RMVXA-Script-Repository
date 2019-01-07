=begin
#===============================================================================
 Title: Level Difference Exp
 Author: Hime
 Date: Nov 18, 2013
 URL: http://himeworks.com/2013/11/18/level-difference-exp/
--------------------------------------------------------------------------------
 ** Change log
 Nov 18, 2013
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
 
 This script allows you to specify a "level difference" exp modifier. It
 introduces a "level difference" exp formula which takes the level difference
 between an actor and an enemy and determines how the exp will be adjusted.
 
 This means that the amount of exp that an actor gains from an enemy is
 dependent on the difference between the actor's level and the enemy's level.
 
 For example, if the actor's level is higher than the enemy level, then the
 actor may receive less exp than if the levels were about the same. On the
 other hand, if the actor's level is lower than the enemy level, then the
 actor may receive more exp than usual.

--------------------------------------------------------------------------------
 ** Required
 
 Core - Enemy Levels
 (http://himeworks.com/2013/11/16/enemy-levels/)
 
 Actor Victory Exp
 (http://himeworks.com/2013/11/18/actor-victory-exp/)
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Core - Enemy Levels and Actor Victory Exp,
 and above Main

--------------------------------------------------------------------------------
 ** Usage
 
 Each enemy will have their own level difference exp formula, which you define
 using the notetag
 
   <level diff exp>
     FORMULA
   </level diff exp>
   
 The formula takes two variables and returns a new number:
 
   exp - the amount of exp that the actor could obtain from this enemy
   diff - the level difference between the actor and the enemy
   
 The level difference is from the perspective of the actor. For example, if
 your actor is level 1 and it defeats a level 10 enemy, then the difference
 is +9 (that is, the enemy is 9 levels higher than the actor)
 
 If no formula is defined for the enemy, then this modifier does nothing.
 
--------------------------------------------------------------------------------
 ** Examples
 
 Suppose a level 10 slime gives 100 EXP
 If your actor's level is lower, then you want to give a bonus 10 EXP for each
 level that you're lower. However, if your actor's level is higher, then you
 want to give a 10 EXP penalty for each level. Your formula would look like this
 
   exp + (diff * 10)
   
 This works because if your actor is level 1, then the difference between the
 actor and the slime is 9, so you will receive a total of (exp + 90). However,
 if your actor was level 20, then the difference is -10, and so you will receive
 a total of (exp - 100)
 
 Suppose instead that we wanted to reward players for taking on challenges,
 but didn't want to penalize them for killing easy enemies. We can use
 conditional branches in our formula like this
 
   if diff > 0
     exp + (diff * 10)
   else
     exp
   end
   
 This means that if the level difference is greater than 0, that is, the actor's
 level is lower than the enemy, then the actor receives bonus EXP for each
 level of difference. However, if the actor's level isn't lower, then the
 exp rewarded is just the usual exp.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_LevelDifferenceExp"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Level_Difference_Exp
    
    Ext_Regex = /<level[-_ ]diff[-_ ]exp>(.*?)<\/level[-_ ]diff[-_ ]exp>/im
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  class Enemy < BaseItem
    def level_diff_exp_formula
      load_notetag_level_difference_exp unless @level_diff_exp_formula
      return @level_diff_exp_formula
    end
    
    def load_notetag_level_difference_exp
      @level_diff_exp_formula = "exp"
      if self.note =~ TH::Level_Difference_Exp::Ext_Regex
        @level_diff_exp_formula = $1
      end
    end
    
    def eval_level_diff_exp(diff, exp)
      eval(self.level_diff_exp_formula)
    end
  end
end

class Game_Actor < Game_Battler
  
  alias :th_level_diff_exp_exp_from_enemy :exp_from_enemy
  def exp_from_enemy(enemy)
    exp_subtotal = th_level_diff_exp_exp_from_enemy(enemy)
    level_diff = enemy.level - self.level
    return [enemy.eval_level_diff_exp(level_diff, exp_subtotal), 0].max
  end
end

class Game_Enemy < Game_Battler
  
  def eval_level_diff_exp(diff, exp)
    enemy.eval_level_diff_exp(diff, exp)
  end
end