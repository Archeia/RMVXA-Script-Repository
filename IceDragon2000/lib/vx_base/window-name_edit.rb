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
  #     actor    : actor
  #     max_char : maximum number of characters
  #--------------------------------------------------------------------------
  def initialize(actor, max_char)
    super(88, 20, 368, 128)
    @actor = actor
    @name = actor.name
    @max_char = max_char
    name_array = @name.split(//)[0...@max_char]   # Fit within max length
    @name = ""
    for i in 0...name_array.size
      @name += name_array[i]
    end
    @default_name = @name
    @index = name_array.size
    self.active = false
    refresh
    update_cursor
  end
  #--------------------------------------------------------------------------
  # * Return to Default Name
  #--------------------------------------------------------------------------
  def restore_default
    @name = @default_name
    @index = @name.split(//).size
    refresh
    update_cursor
  end
  #--------------------------------------------------------------------------
  # * Add Text Character
  #     character : text character to be added
  #--------------------------------------------------------------------------
  def add(character)
    if @index < @max_char and character != ""
      @name += character
      @index += 1
      refresh
      update_cursor
    end
  end
  #--------------------------------------------------------------------------
  # * Delete Text Character
  #--------------------------------------------------------------------------
  def back
    if @index > 0
      name_array = @name.split(//)          # Delete one character
      @name = ""
      for i in 0...name_array.size-1
        @name += name_array[i]
      end
      @index -= 1
      refresh
      update_cursor
    end
  end
  #--------------------------------------------------------------------------
  # * Get rectangle for displaying items
  #     index : item number
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.x = 220 - (@max_char + 1) * 12 + index * 24
    rect.y = 36
    rect.width = 24
    rect.height = WLH
    return rect
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    draw_actor_face(@actor, 0, 0)
    name_array = @name.split(//)
    for i in 0...@max_char
      c = name_array[i]
      c = '_' if c == nil
      self.contents.draw_text(item_rect(i), c, 1)
    end
  end
  #--------------------------------------------------------------------------
  # * Update cursor
  #--------------------------------------------------------------------------
  def update_cursor
    self.cursor_rect = item_rect(@index)
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    update_cursor
  end
end
