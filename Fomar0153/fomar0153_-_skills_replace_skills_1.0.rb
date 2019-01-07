=begin
Skills Replace Skills
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
This script allows you to have a skill replace another skill
----------------------
Instructions
----------------------
Notetag the skills like so:
<replaces x>
and when that skill is learned it will replace x and stop it 
from being re-learnt.
----------------------
Known bugs
----------------------
None
=end
class Game_Actor < Game_Battler
  
  attr_reader   :skills_replaced
  
  alias fsr_setup setup
  def setup(actor_id)
    @skills_replaced = []
    fsr_setup(actor_id)
  end
  
  alias fsr_learn_skill learn_skill
  def learn_skill(skill_id)
    unless skill_learn?($data_skills[skill_id])
      fsr_learn_skill(skill_id)
      if $data_skills[skill_id].note =~ /<replaces (.*)>/i
        forget_skill($1.to_i)
        @skills_replaced.push($1.to_i)
      end
    end
  end
  
  alias fsr_skill_learn? skill_learn?
  def skill_learn?(skill)
    return true if fsr_skill_learn?(skill)
    return  (skill.is_a?(RPG::Skill) && @skills_replaced.include?(skill.id))
  end
  
end