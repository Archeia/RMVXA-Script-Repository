#encoding:UTF-8
# Window_BattleEnemy
#==============================================================================
# ** Window_BattleEnemy
#------------------------------------------------------------------------------
#  Window for selecting the enemy who is the action target on the battle
# screen.
#==============================================================================

class Window_BattleEnemy < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     info_viewport : Viewport for displaying information
  #--------------------------------------------------------------------------
  def initialize(info_viewport)
    super(0, info_viewport.rect.y, window_width, fitting_height(4))
    refresh
    self.visible = false
    @info_viewport = info_viewport
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width - 128
  end
  #--------------------------------------------------------------------------
  # * Get Digit Count
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items
  #--------------------------------------------------------------------------
  def item_max
    $game_troop.alive_members.size
  end
  #--------------------------------------------------------------------------
  # * Get Enemy Object
  #--------------------------------------------------------------------------
  def enemy
    $game_troop.alive_members[@index]
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    change_color(normal_color)
    name = $game_troop.alive_members[index].name
    draw_text(item_rect_for_text(index), name)
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
