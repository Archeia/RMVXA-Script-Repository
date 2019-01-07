=begin
#===============================================================================
 ** Core - Learning
 Author: Hime
 Date: Oct 6, 2012
--------------------------------------------------------------------------------
 ** Change log
 Oct 6
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
 
 This script introduces ID's for each learning object within a class. The ID
 is based on the index of the object in the learnings array.
 
 The concept of "expired" learnings is also included for each actor.
 
 This script also makes skill learning conditions more flexible.
 You can alias `can_learn_skill?` to add more conditions if needed.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script above "Materials" and below Scene_Gameover
--------------------------------------------------------------------------------
 ** Usage
 
 Plug and play.
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_CoreLearning"] = 1.1
#===============================================================================
# ** Rest of the script
#===============================================================================
module RPG
  class Class
    
    alias :th_core_learning_learnings :learnings
    def learnings
      setup_learning_ids unless @learning_ids_setup
      th_core_learning_learnings
    end
    
    def setup_learning_ids
      @learning_ids_setup = true
      @learnings.each_with_index do |learning, i|
        learning.id = i+1
      end
    end
  end
  
  class Class::Learning
    attr_accessor :id
  end
end
class Game_Actor < Game_Battler
  
  alias :th_learn_condition_formulas_setup :setup
  def setup(actor_id)
    @expired_learnings = []
    th_learn_condition_formulas_setup(actor_id)
  end
  
  def expire_learning(learning)
    @expired_learnings[learning.id] = true
  end
  
  def learning_expired?(learning)
    @expired_learnings[learning.id]
  end
  
  #-----------------------------------------------------------------------------
  # Move the condition into its own method
  #-----------------------------------------------------------------------------
  def level_up
    @level += 1
    self.class.learnings.each do |learning|
      learn_skill(learning.skill_id) if can_learn?(learning)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Move the condition into its own method
  #-----------------------------------------------------------------------------
  def init_skills
    @skills = []
    self.class.learnings.each do |learning|
      learn_skill(learning.skill_id) if can_learn?(learning)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Returns true if the learning object can be learned
  #-----------------------------------------------------------------------------
  def can_learn?(learning)
    return false if @level < learning.level
    return true
  end
  
  #-----------------------------------------------------------------------------
  # Returns true if the learning object can be forgotten
  #-----------------------------------------------------------------------------
  def can_forget?(learning)
    return false
  end
end