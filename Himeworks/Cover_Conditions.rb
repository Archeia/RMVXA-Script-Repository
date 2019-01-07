=begin
#===============================================================================
 Title: Cover Conditions
 Author: Hime
 Date: Jan 28, 2014
 URL: http://himeworks.com/2013/11/22/cover-conditions/
--------------------------------------------------------------------------------
 ** Change log
 Jan 28, 2014
   - added support for state cover conditions
 Nov 22, 2013
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
 
 This script allows you to specify custom cover conditions. 
 
 The cover condition determines whether a battler is eligible to be covered.
 By default, this means that the battler must have under 25% of its max HP
 and the current action being performed by an attacker is not a "certain hit"
 item.
 
 You can change the "global cover condition", which is the condition that is
 checked for all battlers if no other cover conditions exist.
 
 You can also specify custom conditions for actors, classes, or enemies.
 
--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 In the configuration, you can set the global cover condition if you don't
 want the default.
 
 To specify specific cover conditions for each database object, note-tag them
 with
 
   <cover condition>
     FORMULA
   </cover condition>
   
 Where the FORMULA determines whether a battler is eligible for substitution. 
 
 The following formula variables are available
 
   a - the battler that is currently executing its action
   b - the target of the action. This is who you are trying to cover
   i - the skill or item being used in the action
   p - game party
   t - game troop
   v - game variables
   s - game switches
 
 This condition only determines whether a target can be covered or not.
 Note that `a` is NOT the battler that will be covering you.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_CoverConditions"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Cover_Conditions
    
    # The global condition to check. 
    Global_Condition = "
       b.hp < b.mhp / 4 && (!i || !i.certain?)
    "
    
    Regex = /<cover[-_ ]condition>(.*?)<\/cover[-_ ]condition>/im
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  class BaseItem
    
    def cover_condition
      load_notetag_cover_condition unless @cover_condition
      return @cover_condition
    end
    
    def load_notetag_cover_condition
      @cover_condition = ""
      if self.note =~ TH::Cover_Conditions::Regex
        @cover_condition = $1
      end
    end
  end
end

class Game_Battler < Game_BattlerBase
  
  def cover_condition
    TH::Cover_Conditions::Global_Condition
  end
end

class Game_Enemy < Game_Battler
  
  alias :th_cover_conditions_cover_condition :cover_condition
  def cover_condition
    state = states.find {|state| !state.cover_condition.empty? }
    return state.cover_condition if state
    return enemy.cover_condition unless enemy.cover_condition.empty?
    th_cover_conditions_cover_condition
  end
end

class Game_Actor < Game_Battler
  
  alias :th_cover_conditions_cover_condition :cover_condition
  def cover_condition
    state = states.find {|state| !state.cover_condition.empty? }
    return state.cover_condition if state
    return actor.cover_condition unless actor.cover_condition.empty?
    return self.class.cover_condition unless self.class.cover_condition.empty?
    th_cover_conditions_cover_condition
  end
end

class Scene_Battle < Scene_Base
  
  def check_substitute(target, item)
    eval_cover_condition(target.cover_condition, @subject, target, item)
  end
  
  def eval_cover_condition(formula, a, b, i, p=$game_party, t=$game_troop, s=$game_switches, v=$game_variables)
    eval(formula)
  end
end