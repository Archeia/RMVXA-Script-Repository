#encoding:UTF-8
# Window_NameEdit
#==============================================================================
# ** Window_NameEdit
#------------------------------------------------------------------------------
#  This window is used to edit an actor's name on the name input screen.
#==============================================================================

class Window_NameEdit < Window_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :name                     # name
  attr_reader   :index                    # cursor position
  attr_reader   :max_char                 # maximum number of characters
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(actor, max_char)
    x = (Graphics.width - 360) / 2
    y = (Graphics.height - (fitting_height(4) + fitting_height(9) + 8)) / 2
    super(x, y, 360, fitting_height(4))
    @actor = actor
    @max_char = max_char
    @default_name = @name = actor.name[0, @max_char]
    @index = @name.size
    deactivate
    refresh
  end
  #--------------------------------------------------------------------------
  # * Revert to Default Name
  #--------------------------------------------------------------------------
  def restore_default
    @name = @default_name
    @index = @name.size
    refresh
    return !@name.empty?
  end
  #--------------------------------------------------------------------------
  # * Add Text Character
  #     ch : character to add
  #--------------------------------------------------------------------------
  def add(ch)
    return false if @index >= @max_char
    @name += ch
    @index += 1
    refresh
    return true
  end
  #--------------------------------------------------------------------------
  # * Go Back One Character
  #--------------------------------------------------------------------------
  def back
    return false if @index == 0
    @index -= 1
    @name = @name[0, @index]
    refresh
    return true
  end
  #--------------------------------------------------------------------------
  # * Get Width of Face Graphic
  #--------------------------------------------------------------------------
  def face_width
    return 96
  end
  #--------------------------------------------------------------------------
  # * Get Character Width
  #--------------------------------------------------------------------------
  def char_width
    text_size($game_system.japanese? ? "あ" : "A").width 
  end
  #--------------------------------------------------------------------------
  # * Get Coordinates of Left Side for Drawing Name
  #--------------------------------------------------------------------------
  def left
    name_center = (contents_width + face_width) / 2
    name_width = (@max_char + 1) * char_width
    return [name_center - name_width / 2, contents_width - name_width].min
  end
  #--------------------------------------------------------------------------
  # * Get Rectangle for Displaying Item
  #--------------------------------------------------------------------------
  def item_rect(index)
    Rect.new(left + index * char_width, 36, char_width, line_height)
  end
  #--------------------------------------------------------------------------
  # * Get Underline Rectangle
  #--------------------------------------------------------------------------
  def underline_rect(index)
    rect = item_rect(index)
    rect.x += 1
    rect.y += rect.height - 4
    rect.width -= 2
    rect.height = 2
    rect
  end
  #--------------------------------------------------------------------------
  # * Get Underline Color
  #--------------------------------------------------------------------------
  def underline_color
    color = normal_color
    color.alpha = 48
    color
  end
  #--------------------------------------------------------------------------
  # * Draw Underline
  #--------------------------------------------------------------------------
  def draw_underline(index)
    contents.fill_rect(underline_rect(index), underline_color)
  end
  #--------------------------------------------------------------------------
  # * Draw Text
  #--------------------------------------------------------------------------
  def draw_char(index)
    rect = item_rect(index)
    rect.x -= 1
    rect.width += 4
    change_color(normal_color)
    draw_text(rect, @name[index] || "")
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_actor_face(@actor, 0, 0)
    @max_char.times {|i| draw_underline(i) }
    @name.size.times {|i| draw_char(i) }
    cursor_rect.set(item_rect(@index))
  end
end
