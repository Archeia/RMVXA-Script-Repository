=begin
Elementalist Class
by Fomar0153
Version 1.1
----------------------
Notes
----------------------
Requires my unique classes script
Allows you to learn new skills by using skills of the same element.
----------------------
Instructions
----------------------
To make an elementalist in the unique classes script set it up like this:
    when 4 # Elementalist
      @data[actor_id] ||= Game_Elementalist.new(actor_id)

You will need to edit module Fomar, further instructions
are located there.
----------------------
Change Log
----------------------
1.0 -> 1.1 Fixed a bug that could cause crashing.
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

class Game_Elementalist < Game_Actor
  #--------------------------------------------------------------------------
  # ● New Method setup
  #--------------------------------------------------------------------------
  def setup(actor_id)
    super(actor_id)
    @element_uses = []
  end
  #--------------------------------------------------------------------------
  # ● New Method add_element_use
  #--------------------------------------------------------------------------
  def add_element_use(id)
    return if id == -1
    if @element_uses[id].nil?
      @element_uses[id] = 0
    end
    @element_uses[id] += 1
    return if Fomar::ELEMENTS[id].nil?
    unless Fomar::ELEMENTS[id][@element_uses[id]].nil?
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
  alias uce_item_apply item_apply
  def item_apply(user, item)
    uce_item_apply(user, item)
    if user.is_a?(Game_Elementalist) and item.is_a?(RPG::Skill)
      user.add_element_use(item.damage.element_id)
    end
  end
end