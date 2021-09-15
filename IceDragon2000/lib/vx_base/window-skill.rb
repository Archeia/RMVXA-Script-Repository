#encoding:UTF-8
# Window_Skill
#==============================================================================
# ** Window_Skill
#------------------------------------------------------------------------------
#  This window displays a list of usable skills on the skill screen, etc.
#==============================================================================

class Window_Skill < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x      : window x-coordinate
  #     y      : window y-coordinate
  #     width  : window width
  #     height : window height
  #     actor  : actor
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, actor)
    super(x, y, width, height)
    @actor = actor
    @column_max = 2
    self.index = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Skill
  #--------------------------------------------------------------------------
  def skill
    return @data[self.index]
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    @data = []
    for skill in @actor.skills
      @data.push(skill)
      if skill.id == @actor.last_skill_id
        self.index = @data.size - 1
      end
    end
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #     index : item number
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    skill = @data[index]
    if skill != nil
      rect.width -= 4
      enabled = @actor.skill_can_use?(skill)
      draw_item_name(skill, rect.x, rect.y, enabled)
      self.contents.draw_text(rect, @actor.calc_mp_cost(skill), 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(skill == nil ? "" : skill.description)
  end
end
