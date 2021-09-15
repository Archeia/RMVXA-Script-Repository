#encoding:UTF-8
# Window_BattleItem
#==============================================================================
# ** Window_BattleItem
#------------------------------------------------------------------------------
#  This window is for selecting items to use in the battle window.
#==============================================================================

class Window_BattleItem < Window_ItemList
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
  # * Include in Item List?
  #--------------------------------------------------------------------------
  def include?(item)
    $game_party.usable?(item)
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
