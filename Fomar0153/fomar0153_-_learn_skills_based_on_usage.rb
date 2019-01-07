=begin
Skills Level Up Based on Usage Script
by Fomar0153
Version 1.1
----------------------
Notes
----------------------
No requirements
Allows you to learn new skills by using your existing skills.
----------------------
Instructions
----------------------
You will need to edit module Skill_Uses, further instructions
are located there.
----------------------
Changelog
----------------------
1.0 -> 1.1: Fixed a bug where script would crash outside of battles.
----------------------
Known bugs
----------------------
None
=end
module Skill_Uses

  SKILLS = []
  # Add/Edit lines like the one below
  # SKILLS[ORIGINAL] = [NEW, USES, REPLACE] REPLACE should be true or false
  SKILLS[3] = [4, 50, true]
  # Reads as: When using skill 3 for it's 50th time replace it with skill 4

end

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● Aliases setup
  #--------------------------------------------------------------------------
  alias fomar0003_setup setup
  def setup(actor_id)
    fomar0003_setup(actor_id)
    @skill_uses = []
  end
  #--------------------------------------------------------------------------
  # ● New Method add_skill_use
  #--------------------------------------------------------------------------
  def add_skill_use(id)
    if @skill_uses[id] == nil
      @skill_uses[id] = 0
    end
    @skill_uses[id] += 1
    unless Skill_Uses::SKILLS[id] == nil
      if @skill_uses[id] == Skill_Uses::SKILLS[id][1]
        learn_skill(Skill_Uses::SKILLS[id][0])
        forget_skill(id) if Skill_Uses::SKILLS[id][2]
        $game_message.add(@name + " learns " + $data_skills[Skill_Uses::SKILLS[id][0]].name + ".")
      end
    end
  end
end

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● Aliases item_apply
  #--------------------------------------------------------------------------
  alias fomar0004_item_apply item_apply
  def item_apply(user, item)
    if user.is_a?(Game_Actor) and item.is_a?(RPG::Skill)
      user.add_skill_use(item.id)
    end
    fomar0004_item_apply(user, item)
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