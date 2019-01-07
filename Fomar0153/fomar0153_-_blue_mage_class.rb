=begin
Blue Mage Class Script
by Fomar0153
Version 1.1
----------------------
Notes
----------------------
Requires the "Unique Classes Script"
Allows party members to learn skills by being hit by them.
Commonly described as Blue Magic or Enemy Skills
----------------------
Instructions
----------------------
Set "BlueMagic" to include all the id's of Blue Magic skills
Follow the instructions in the Unique Classes Script

----------------------
Changle Log
----------------------
1.0 -> 1.1 : Added notification when learning a new Skill
----------------------
Known bugs
----------------------
None
=end
class Game_BlueMage < Game_Actor

  # Edit to include all the skill ids of the skills you want your
  # blue mages to learn
  BlueMagic = [3, 4]

  #--------------------------------------------------------------------------
  # ● Aliased make_damage_value
  #--------------------------------------------------------------------------
  alias bluemagic_make_damage_value make_damage_value
  def make_damage_value(user, item)
    bluemagic_make_damage_value(user, item)
    if @result.hit? and item.class == RPG::Skill
      if BlueMagic.include?(item.id)
        i = @skills.size
        learn_skill(item.id)
        if !(i == @skills.size)
          SceneManager.scene.add_text(actor.name + " learns " + item.name + ".")
        end
      end
    end
  end
end

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● New method add_text
  #--------------------------------------------------------------------------
  def add_text(text)
    @log_window.add_text(text)
  end
end