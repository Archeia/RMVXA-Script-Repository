#encoding:UTF-8
# Window_BattleStatus
#==============================================================================
# ** Window_BattleStatus
#------------------------------------------------------------------------------
#  This window is for displaying the status of party members on the battle
# screen.
#==============================================================================

class Window_BattleStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, window_height)
    refresh
    self.openness = 0
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width - 128
  end
  #--------------------------------------------------------------------------
  # * Get Window Height
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)
  end
  #--------------------------------------------------------------------------
  # * Get Number of Lines to Show
  #--------------------------------------------------------------------------
  def visible_line_number
    return 4
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items
  #--------------------------------------------------------------------------
  def item_max
    $game_party.battle_members.size
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_all_items
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    actor = $game_party.battle_members[index]
    draw_basic_area(basic_area_rect(index), actor)
    draw_gauge_area(gauge_area_rect(index), actor)
  end
  #--------------------------------------------------------------------------
  # * Get Basic Area Retangle
  #--------------------------------------------------------------------------
  def basic_area_rect(index)
    rect = item_rect_for_text(index)
    rect.width -= gauge_area_width + 10
    rect
  end
  #--------------------------------------------------------------------------
  # * Get Gauge Area Rectangle
  #--------------------------------------------------------------------------
  def gauge_area_rect(index)
    rect = item_rect_for_text(index)
    rect.x += rect.width - gauge_area_width
    rect.width = gauge_area_width
    rect
  end
  #--------------------------------------------------------------------------
  # * Get Gauge Area Width
  #--------------------------------------------------------------------------
  def gauge_area_width
    return 220
  end
  #--------------------------------------------------------------------------
  # * Draw Basic Area
  #--------------------------------------------------------------------------
  def draw_basic_area(rect, actor)
    draw_actor_name(actor, rect.x + 0, rect.y, 100)
    draw_actor_icons(actor, rect.x + 104, rect.y, rect.width - 104)
  end
  #--------------------------------------------------------------------------
  # * Draw Gauge Area
  #--------------------------------------------------------------------------
  def draw_gauge_area(rect, actor)
    if $data_system.opt_display_tp
      draw_gauge_area_with_tp(rect, actor)
    else
      draw_gauge_area_without_tp(rect, actor)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Gauge Area (with TP)
  #--------------------------------------------------------------------------
  def draw_gauge_area_with_tp(rect, actor)
    draw_actor_hp(actor, rect.x + 0, rect.y, 72)
    draw_actor_mp(actor, rect.x + 82, rect.y, 64)
    draw_actor_tp(actor, rect.x + 156, rect.y, 64)
  end
  #--------------------------------------------------------------------------
  # * Draw Gauge Area (without TP)
  #--------------------------------------------------------------------------
  def draw_gauge_area_without_tp(rect, actor)
    draw_actor_hp(actor, rect.x + 0, rect.y, 134)
    draw_actor_mp(actor, rect.x + 144,  rect.y, 76)
  end
end
