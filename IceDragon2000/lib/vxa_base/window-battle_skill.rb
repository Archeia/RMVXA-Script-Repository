#encoding:UTF-8
# Window_BattleSkill
#==============================================================================
# ** Window_BattleSkill
#------------------------------------------------------------------------------
#  This window is for selecting skills to use in the battle window.
#==============================================================================

class Window_BattleSkill < Window_SkillList
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     info_viewport : Viewport for displaying information
  #--------------------------------------------------------------------------
  def initialize(help_window, info_viewport)
    y = help_window.height
    super(0, y, Graphics.width, info_viewport.rect.y - y)
    self.visible = false
    @help_window = help_window
    @info_viewport = info_viewport
  end
  #--------------------------------------------------------------------------
  # * Show Window
  #--------------------------------------------------------------------------
  def show
    select_last
    @help_window.show
    super
  end
  #--------------------------------------------------------------------------
  # * Hide Window
  #--------------------------------------------------------------------------
  def hide
    @help_window.hide
    super
  end
end
