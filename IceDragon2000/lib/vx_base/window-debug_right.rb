#encoding:UTF-8
# Window_DebugRight
#==============================================================================
# ** Window_DebugRight
#------------------------------------------------------------------------------
#  This window displays switches and variables separately on the debug screen.
#==============================================================================

class Window_DebugRight < Window_Selectable
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :mode                     # mode (0: switch, 1: variable)
  attr_reader   :top_id                   # ID shown on top
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x : window X coordinate
  #     y : window Y coordinate
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, 368, 10 * WLH + 32)
    self.index = -1
    self.active = false
    @item_max = 10
    @mode = 0
    @top_id = 1
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    for i in 0...@item_max
      draw_item(i)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #     index : Item number
  #--------------------------------------------------------------------------
  def draw_item(index)
    current_id = @top_id + index
    id_text = sprintf("%04d:", current_id)
    id_width = self.contents.text_size(id_text).width
    if @mode == 0
      name = $data_system.switches[current_id]
      status = $game_switches[current_id] ? "[ON]" : "[OFF]"
    else
      name = $data_system.variables[current_id]
      status = $game_variables[current_id]
    end
    if name == nil
      name = ""
    end
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    self.contents.draw_text(rect, id_text)
    rect.x += id_width
    rect.width -= id_width + 60
    self.contents.draw_text(rect, name)
    rect.width += 60
    self.contents.draw_text(rect, status, 2)
  end
  #--------------------------------------------------------------------------
  # * Set Mode
  #     id : new mode
  #--------------------------------------------------------------------------
  def mode=(mode)
    if @mode != mode
      @mode = mode
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Set ID Shown on Top
  #     id : new ID
  #--------------------------------------------------------------------------
  def top_id=(id)
    if @top_id != id
      @top_id = id
      refresh
    end
  end
end
