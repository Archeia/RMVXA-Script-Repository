=begin
Learn Skills by Element use
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
No requirements
Allows you to learn new skills by using skills of the same element.
----------------------
Instructions
----------------------
You will need to edit module Fomar, further instructions
are located there.
----------------------
Known bugs
----------------------
None
=end
module Fomar

  ELEMENTS = []
  # Add/Edit lines like the ones below
  ELEMENTS[3] = {}
  # ELEMENTS[id][uses] = [NEW_SKILL_ID, NEW_SKILL_ID...]
  ELEMENTS[3][50]  = [52,53]
  ELEMENTS[3][100] = [54]

end

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● Aliases setup
  #--------------------------------------------------------------------------
  alias seu_setup setup
  def setup(actor_id)
    seu_setup(actor_id)
    @element_uses = []
  end
  #--------------------------------------------------------------------------
  # ● New Method add_element_use
  #--------------------------------------------------------------------------
  def add_element_use(id)
    if @element_uses[id] == nil
      @element_uses[id] = 0
    end
    @element_uses[id] += 1
    unless Fomar::ELEMENTS[id][@element_uses[id]] == nil
      for skill in Fomar::ELEMENTS[id][@element_uses[id]]
        learn_skill(skill)
        $game_message.add(@name + ' learns ' + $data_skills[skill].name)
      end
    end
  end
end

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● Aliases item_apply
  #--------------------------------------------------------------------------
  alias seu_item_apply item_apply
  def item_apply(user, item)
    seu_item_apply(user, item)
    if user.is_a?(Game_Actor) and item.is_a?(RPG::Skill)
      user.add_element_use(item.damage.element_id)
    end
  end
end