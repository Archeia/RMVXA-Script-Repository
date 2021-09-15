#encoding:UTF-8
# Window_MapName
#==============================================================================
# ** Window_MapName
#------------------------------------------------------------------------------
#  This window displays the map name.
#==============================================================================

class Window_MapName < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, fitting_height(1))
    self.opacity = 0
    self.contents_opacity = 0
    @show_count = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return 240
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if @show_count > 0 && $game_map.name_display
      update_fadein
      @show_count -= 1
    else
      update_fadeout
    end
  end
  #--------------------------------------------------------------------------
  # * Update Fadein
  #--------------------------------------------------------------------------
  def update_fadein
    self.contents_opacity += 16
  end
  #--------------------------------------------------------------------------
  # * Update Fadeout
  #--------------------------------------------------------------------------
  def update_fadeout
    self.contents_opacity -= 16
  end
  #--------------------------------------------------------------------------
  # * Open Window
  #--------------------------------------------------------------------------
  def open
    refresh
    @show_count = 150
    self.contents_opacity = 0
    self
  end
  #--------------------------------------------------------------------------
  # * Close Window
  #--------------------------------------------------------------------------
  def close
    @show_count = 0
    self
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    unless $game_map.display_name.empty?
      draw_background(contents.rect)
      draw_text(contents.rect, $game_map.display_name, 1)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Background
  #--------------------------------------------------------------------------
  def draw_background(rect)
    temp_rect = rect.clone
    temp_rect.width /= 2
    contents.gradient_fill_rect(temp_rect, back_color2, back_color1)
    temp_rect.x = temp_rect.width
    contents.gradient_fill_rect(temp_rect, back_color1, back_color2)
  end
  #--------------------------------------------------------------------------
  # * Get Background Color 1
  #--------------------------------------------------------------------------
  def back_color1
    Color.new(0, 0, 0, 192)
  end
  #--------------------------------------------------------------------------
  # * Get Background Color 2
  #--------------------------------------------------------------------------
  def back_color2
    Color.new(0, 0, 0, 0)
  end
end
