=begin
#===============================================================================
 Title: Learn Condition Formulas
 Author: Hime
 Date: Nov 3, 2013
--------------------------------------------------------------------------------
 ** Change log
 Nov 3, 2013
   - implemented "forget condition" formula
 Sep 15, 2013
   - implemented "required condition" formula
 Aug 25, 2013
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
 
 This script allows you to specify custom conditions that must be met in order
 to learn a skill or forget a skill
 
 There are two types of conditions
 
 1. Required conditions
 2. Learn conditions
 3. Forget conditions
 
 Required conditions are conditions that must be met before you can
 potentially learn the skill. By default, level is a required condition. This
 script allows you to specify additional required conditions 
 
 Learn conditions are conditions that must be met in order to learn the skill.
 The learn condition is only checked when all required conditions are met. It
 is only checked once: if you did not meet the learn conditions when all
 required conditions are met, then that learning object expires and you won't
 be able to learn from that object again. Learn conditions are used only if
 you want to create "miss-able" learnings.
 
 However, you can have multiple copies of a learning object with different
 required conditions so that the actor has different chances learning the
 skill.
 
 Forget conditions are conditions that must be met in order to forget the skill.
 Once this condition has been met, the actor will forget the skill.
 
 A single skill can have all three types of conditions, for example if you learn
 a skill at level 5, but then forget it once you reach level 10.
 
--------------------------------------------------------------------------------
 ** Required
 
 Core - Learning
 (http://himeworks.com/2012/10/14/core-learning/)
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Core - Learning and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 To specify a required condition, use this note-tag in the Class Learning
 object. Note the slash before the end of the tag.
 
   <req condition: FORMULA />
   
 To specify a learn condition, use the note-tag
 
   <learn condition: FORMULA />
   
 Where the FORMULA is any valid ruby statement that returns true or false.
 There are some special variables for your formula:
 
   a - the actor
   p - game party
   s - game switches
   v - game variables
   
 In the configuration, you can determine whether skill-learned messages will
 be displayed.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_LearnConditionFormulas"] = true
#-------------------------------------------------------------------------------
# ** Requirements
#-------------------------------------------------------------------------------
unless $imported["TH_CoreLearning"]
  msgbox('"Core: Learning" is required to use "Learn Condition Formulas"') 
  exit
end
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Learn_Condition_Formulas
    
    # Display message when new skill has been learned
    Show_Messages = true
    
    # Message to display when an actor learns a skill.
    # It takes an actor's name and a skill name
    Learn_Message = "%s learned %s!"
    Forget_Message = "%s forgot %s!"
    
    Req_Regex = /<req[-_ ]condition:\s*(.*?)\s*\/>/i
    Learn_Regex = /<learn[-_ ]condition:\s*(.*?)\s*\/>/i
    Forget_Regex = /<forget[-_ ]condition:\s*(.*?)\s*\/>/i
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================

module RPG
  class Class::Learning
    
    #---------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------
    def require_condition_formula
      load_notetag_learn_condition_formula if @require_condition_formula.nil?
      return @require_condition_formula
    end
    
    #---------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------
    def learn_condition_formula
      load_notetag_learn_condition_formula if @learn_condition_formula.nil?
      return @learn_condition_formula
    end
    
    def forget_condition_formula
      load_notetag_learn_condition_formula if @forget_condition_formula.nil?
      return @forget_condition_formula
    end
    
    #---------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------
    def load_notetag_learn_condition_formula
      res = self.note.match(TH::Learn_Condition_Formulas::Learn_Regex)
      @learn_condition_formula = res ? res[1] : "true"
      
      res = self.note.match(TH::Learn_Condition_Formulas::Req_Regex)
      @require_condition_formula = res ? res[1] : "true"
      
      res = self.note.match(TH::Learn_Condition_Formulas::Forget_Regex)
      @forget_condition_formula = res ? res[1] : "false"
    end
    
    def learn_condition_met?(a, p=$game_party, s=$game_switches, v=$game_variables)
      eval(self.learn_condition_formula)
    end
    
    def req_condition_met?(a, p=$game_party, s=$game_switches, v=$game_variables)
      eval(self.require_condition_formula)
    end
    
    def forget_condition_met?(a, p=$game_party, s=$game_switches, v=$game_variables)
      eval(self.forget_condition_formula)
    end
  end
end

class Game_Actor < Game_Battler

  alias :th_learn_condition_formulas_refresh :refresh
  def refresh
    check_learnings
    th_learn_condition_formulas_refresh
  end
  
  #-----------------------------------------------------------------------------
  # Check if we can learn anything new.
  # Might need to be optimized since we're checking this every second or so
  #-----------------------------------------------------------------------------
  def check_learnings(show=TH::Learn_Condition_Formulas::Show_Messages)
    last_skills = skills
    self.class.learnings.each do |learning|
      learn_skill(learning.skill_id)  if can_learn?(learning)
      forget_skill(learning.skill_id) if can_forget?(learning)
    end
    learned_skills = skills - last_skills
    forget_skills = last_skills - skills
    display_learning_messages(learned_skills, forget_skills) if show
  end
  
  #-----------------------------------------------------------------------------
  # Skill-learned messages to be displayed
  #-----------------------------------------------------------------------------
  def display_learning_messages(learned_skills, forget_skills)
    learned_skills.each do |skill|
      $game_message.add(sprintf(TH::Learn_Condition_Formulas::Learn_Message, self.name, skill.name))
    end
    forget_skills.each do |skill|
      $game_message.add(sprintf(TH::Learn_Condition_Formulas::Forget_Message, self.name, skill.name))
    end
  end
  
  alias :th_learn_condition_formulas_can_learn? :can_learn?
  def can_learn?(learning)
    return false if learning_expired?(learning)
    return false unless learning.req_condition_met?(self)
    res = th_learn_condition_formulas_can_learn?(learning)
    
    # all required conditions have been met, so check if learning condition
    # has been met. 
    if res
      if !learning.learn_condition_met?(self)
        expire_learning(learning) 
        return false
      end
    end
    return res
  end
  
  alias :th_learn_condition_formulas_can_forget? :can_forget?
  def can_forget?(learning)
    return true if learning.forget_condition_met?(self)
    th_learn_condition_formulas_can_forget?(learning)
  end
end

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class Game_Map
  
  alias :th_learn_condition_formulas_refresh :refresh
  def refresh
    $game_party.members.each {|actor| actor.check_learnings }
    th_learn_condition_formulas_refresh
  end
end