#encoding:UTF-8
# Window_BattleActor
#==============================================================================
# ** Window_BattleActor
#------------------------------------------------------------------------------
#  This window is for selecting an actor's action target on the battle screen.
#==============================================================================

class Window_BattleActor < Window_BattleStatus
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     info_viewport : Viewport for displaying information
  #--------------------------------------------------------------------------
  def initialize(info_viewport)
    super()
    self.y = info_viewport.rect.y
    self.visible = false
    self.openness = 255
    @info_viewport = info_viewport
  end
  #--------------------------------------------------------------------------
  # * Show Window
  #--------------------------------------------------------------------------
  def show
    if @info_viewport
      width_remain = Graphics.width - width
      self.x = width_remain
      @info_viewport.rect.width = width_remain
      select(0)
    end
    super
  end
  #--------------------------------------------------------------------------
  # * Hide Window
  #--------------------------------------------------------------------------
  def hide
    @info_viewport.rect.width = Graphics.width if @info_viewport
    super
  end
end
