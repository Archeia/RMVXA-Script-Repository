#encoding:UTF-8
# Window_SkillCommand
#==============================================================================
# ** Window_SkillCommand
#------------------------------------------------------------------------------
#  This window is for selecting commands (special attacks, magic, etc.) on the
# skill screen.
#==============================================================================

class Window_SkillCommand < Window_Command
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :skill_window
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y)
    @actor = nil
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return 160
  end
  #--------------------------------------------------------------------------
  # * Set Actor
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
    select_last
  end
  #--------------------------------------------------------------------------
  # * Get Number of Lines to Show
  #--------------------------------------------------------------------------
  def visible_line_number
    return 4
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    return unless @actor
    @actor.added_skill_types.sort.each do |stype_id|
      name = $data_system.skill_types[stype_id]
      add_command(name, :skill, true, stype_id)
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    @skill_window.stype_id = current_ext if @skill_window
  end
  #--------------------------------------------------------------------------
  # * Set Skill Window
  #--------------------------------------------------------------------------
  def skill_window=(skill_window)
    @skill_window = skill_window
    update
  end
  #--------------------------------------------------------------------------
  # * Restore Previous Selection Position
  #--------------------------------------------------------------------------
  def select_last
    skill = @actor.last_skill.object
    if skill
      select_ext(skill.stype_id)
    else
      select(0)
    end
  end
end
