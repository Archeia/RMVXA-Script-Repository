#encoding:UTF-8
# Window_SaveFile
#==============================================================================
# ** Window_SaveFile
#------------------------------------------------------------------------------
#  This window displays save files on the save and load screens.
#==============================================================================

class Window_SaveFile < Window_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :selected                 # selected
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     index : index of save files
  #--------------------------------------------------------------------------
  def initialize(height, index)
    super(0, index * height, Graphics.width, height)
    @file_index = index
    refresh
    @selected = false
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    change_color(normal_color)
    name = Vocab::File + " #{@file_index + 1}"
    draw_text(4, 0, 200, line_height, name)
    @name_width = text_size(name).width
    draw_party_characters(152, 58)
    draw_playtime(0, contents.height - line_height, contents.width - 4, 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Party Characters
  #--------------------------------------------------------------------------
  def draw_party_characters(x, y)
    header = DataManager.load_header(@file_index)
    return unless header
    header[:characters].each_with_index do |data, i|
      draw_character(data[0], data[1], x + i * 48, y)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Play Time
  #--------------------------------------------------------------------------
  def draw_playtime(x, y, width, align)
    header = DataManager.load_header(@file_index)
    return unless header
    draw_text(x, y, width, line_height, header[:playtime_s], 2)
  end
  #--------------------------------------------------------------------------
  # * Set Selected
  #--------------------------------------------------------------------------
  def selected=(selected)
    @selected = selected
    update_cursor
  end
  #--------------------------------------------------------------------------
  # * Update Cursor
  #--------------------------------------------------------------------------
  def update_cursor
    if @selected
      cursor_rect.set(0, 0, @name_width + 8, line_height)
    else
      cursor_rect.empty
    end
  end
end
