#encoding:UTF-8
# Window_SkillStatus
#==============================================================================
# ** Window_SkillStatus
#------------------------------------------------------------------------------
#  This window displays the skill user's status on the skill screen.
#==============================================================================

class Window_SkillStatus < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x     : window X coordinate
  #     y     : window Y corrdinate
  #     actor : actor
  #--------------------------------------------------------------------------
  def initialize(x, y, actor)
    super(x, y, 544, WLH + 32)
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    draw_actor_name(@actor, 4, 0)
    draw_actor_level(@actor, 140, 0)
    draw_actor_hp(@actor, 240, 0)
    draw_actor_mp(@actor, 392, 0)
  end
end
