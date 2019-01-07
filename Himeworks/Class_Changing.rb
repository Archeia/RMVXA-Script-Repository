=begin
#===============================================================================
 Title: Class Changing
 Author: Hime
 Date: Sep 16, 2013
--------------------------------------------------------------------------------
 ** Change log
 Sep 16, 2013
   - fixed bug where new skills were not added when "keep skills" was false
 Aug 7, 2013
   - added "keep skill" option
   - bug fix: level restriction not considered when adding new class skills
 Aug 6, 2013
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
 
 This script addresses the issue where the actor changes classes, but the
 old class skills are still learned and the new class skills are not
 automatically learned.
 
 Some convenience methods for class changing is also provided as script calls
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage

 Use the script call to change classes
 
   change_class(actor_id, class_id)
   change_class(actor_id, class_id, keep_exp)
   change_class(actor_id, class_id, keep_exp, keep_skills)
   
 Where
   `actor_id` is the ID of the actor you wish to change classes
   `class_id` is the ID of the class to change to
   `keep_exp` is true or false, whether you want to transfer the current exp
   `keep_skills` is true or false, whether you want to keep the learned skills

 For example,
 
   change_class(4, 10, true, false)
  
 Will change actor 4's class to class 10 while preserving the actor's exp, but
 any learned skills (from the old class) are not preserved.
 
 You can set some default values for keeping EXP and transferring skills.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_ClassChanging"] = true
#===============================================================================
# ** Configuration
#=============================================================================== 
module TH
  module Class_Changing
  
    # Some default values if you don't specify them in script calls
    Keep_Exp = false
    Keep_Skills = false
  end
end
#===============================================================================
# ** Rest of Script
#=============================================================================== 
class Game_Actor < Game_Battler
  
  attr_accessor :class_change_keep_skills
  
  #-----------------------------------------------------------------------------
  # Remove old skills, add new skills
  #-----------------------------------------------------------------------------
  def update_class_skills(old_class_id)
    new_class = $data_classes[@class_id]
    new_skills = new_class.learnings.select {|learning| learning.level <= @level}.collect {|learning| learning.skill_id}
    unless @class_change_keep_skills
      old_class = $data_classes[old_class_id]
      old_skills = old_class.learnings.collect {|learning| learning.skill_id }
      @skills -= old_skills 
    end
    @skills |= new_skills
  end
  
  alias :th_class_changing_change_class :change_class
  def change_class(class_id, keep_exp = false)
    old_class_id = @class_id
    th_class_changing_change_class(class_id, keep_exp)
    update_class_skills(old_class_id)
    @class_change_keep_skills = false
  end
end

class Game_Interpreter
  
  def change_class(actor_id, class_id, keep_exp=TH::Class_Changing::Keep_Exp, keep_skills=TH::Class_Changing::Keep_Skills)
    actor = $game_actors[actor_id]
    actor.class_change_keep_skills = keep_skills
    actor.change_class(class_id, keep_exp)
  end
end