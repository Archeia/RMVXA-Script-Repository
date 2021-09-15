#encoding:UTF-8
# Scene_File
#==============================================================================
# ** Scene_File
#------------------------------------------------------------------------------
#  This class performs common processing for the save screen and load screen.
#==============================================================================

class Scene_File < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_savefile_viewport
    create_savefile_windows
    init_selection
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    @savefile_viewport.dispose
    @savefile_windows.each {|window| window.dispose }
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    @savefile_windows.each {|window| window.update }
    update_savefile_selection
  end
  #--------------------------------------------------------------------------
  # * Create Help Window
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new(1)
    @help_window.set_text(help_window_text)
  end
  #--------------------------------------------------------------------------
  # * Get Help Window Text
  #--------------------------------------------------------------------------
  def help_window_text
    return ""
  end
  #--------------------------------------------------------------------------
  # * Create Save File Viewport
  #--------------------------------------------------------------------------
  def create_savefile_viewport
    @savefile_viewport = Viewport.new
    @savefile_viewport.rect.y = @help_window.height
    @savefile_viewport.rect.height -= @help_window.height
  end
  #--------------------------------------------------------------------------
  # * Create Save File Window
  #--------------------------------------------------------------------------
  def create_savefile_windows
    @savefile_windows = Array.new(item_max) do |i|
      Window_SaveFile.new(savefile_height, i)
    end
    @savefile_windows.each {|window| window.viewport = @savefile_viewport }
  end
  #--------------------------------------------------------------------------
  # * Initialize Selection State
  #--------------------------------------------------------------------------
  def init_selection
    @index = first_savefile_index
    @savefile_windows[@index].selected = true
    self.top_index = @index - visible_max / 2
    ensure_cursor_visible
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items
  #--------------------------------------------------------------------------
  def item_max
    DataManager.savefile_max
  end
  #--------------------------------------------------------------------------
  # * Get Number of Save Files to Show on Screen
  #--------------------------------------------------------------------------
  def visible_max
    return 4
  end
  #--------------------------------------------------------------------------
  # * Get Height of Save File Window
  #--------------------------------------------------------------------------
  def savefile_height
    @savefile_viewport.rect.height / visible_max
  end
  #--------------------------------------------------------------------------
  # * Get File Index to Select First
  #--------------------------------------------------------------------------
  def first_savefile_index
    return 0
  end
  #--------------------------------------------------------------------------
  # * Get Current Index
  #--------------------------------------------------------------------------
  def index
    @index
  end
  #--------------------------------------------------------------------------
  # * Get Top Index
  #--------------------------------------------------------------------------
  def top_index
    @savefile_viewport.oy / savefile_height
  end
  #--------------------------------------------------------------------------
  # * Set Top Index
  #--------------------------------------------------------------------------
  def top_index=(index)
    index = 0 if index < 0
    index = item_max - visible_max if index > item_max - visible_max
    @savefile_viewport.oy = index * savefile_height
  end
  #--------------------------------------------------------------------------
  # * Get Bottom Index
  #--------------------------------------------------------------------------
  def bottom_index
    top_index + visible_max - 1
  end
  #--------------------------------------------------------------------------
  # * Set Bottom Index
  #--------------------------------------------------------------------------
  def bottom_index=(index)
    self.top_index = index - (visible_max - 1)
  end
  #--------------------------------------------------------------------------
  # * Update Save File Selection
  #--------------------------------------------------------------------------
  def update_savefile_selection
    return on_savefile_ok     if Input.trigger?(:C)
    return on_savefile_cancel if Input.trigger?(:B)
    update_cursor
  end
  #--------------------------------------------------------------------------
  # * Save File [OK]
  #--------------------------------------------------------------------------
  def on_savefile_ok
  end
  #--------------------------------------------------------------------------
  # * Save File [Cancel]
  #--------------------------------------------------------------------------
  def on_savefile_cancel
    Sound.play_cancel
    return_scene
  end
  #--------------------------------------------------------------------------
  # * Update Cursor
  #--------------------------------------------------------------------------
  def update_cursor
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_pagedown   if Input.trigger?(:R)
    cursor_pageup     if Input.trigger?(:L)
    if @index != last_index
      Sound.play_cursor
      @savefile_windows[last_index].selected = false
      @savefile_windows[@index].selected = true
    end
  end
  #--------------------------------------------------------------------------
  # * Move Cursor Down
  #--------------------------------------------------------------------------
  def cursor_down(wrap)
    @index = (@index + 1) % item_max if @index < item_max - 1 || wrap
    ensure_cursor_visible
  end
  #--------------------------------------------------------------------------
  # * Move Cursor Up
  #--------------------------------------------------------------------------
  def cursor_up(wrap)
    @index = (@index - 1 + item_max) % item_max if @index > 0 || wrap
    ensure_cursor_visible
  end
  #--------------------------------------------------------------------------
  # * Move Cursor One Page Down
  #--------------------------------------------------------------------------
  def cursor_pagedown
    if top_index + visible_max < item_max
      self.top_index += visible_max
      @index = [@index + visible_max, item_max - 1].min
    end
  end
  #--------------------------------------------------------------------------
  # * Move Cursor One Page Up
  #--------------------------------------------------------------------------
  def cursor_pageup
    if top_index > 0
      self.top_index -= visible_max
      @index = [@index - visible_max, 0].max
    end
  end
  #--------------------------------------------------------------------------
  # * Scroll Cursor to Position Within Screen
  #--------------------------------------------------------------------------
  def ensure_cursor_visible
    self.top_index = index if index < top_index
    self.bottom_index = index if index > bottom_index
  end
end
