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
  attr_reader   :filename                 # filename
  attr_reader   :file_exist               # file existence flag
  attr_reader   :time_stamp               # timestamp
  attr_reader   :selected                 # selected
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     file_index : save file index (0-3)
  #     filename   : filename
  #--------------------------------------------------------------------------
  def initialize(file_index, filename)
    super(0, 56 + file_index % 4 * 90, 544, 90)
    @file_index = file_index
    @filename = filename
    load_gamedata
    refresh
    @selected = false
  end
  #--------------------------------------------------------------------------
  # * Load Partial Game Data
  #    By default, switches and variables are not used (for expansion use,
  #    such as displaying place names)
  #--------------------------------------------------------------------------
  def load_gamedata
    @time_stamp = Time.at(0)
    @file_exist = FileTest.exist?(@filename)
    if @file_exist
      file = File.open(@filename, "r")
      @time_stamp = file.mtime
      begin
        @characters     = Marshal.load(file)
        @frame_count    = Marshal.load(file)
        @last_bgm       = Marshal.load(file)
        @last_bgs       = Marshal.load(file)
        @game_system    = Marshal.load(file)
        @game_message   = Marshal.load(file)
        @game_switches  = Marshal.load(file)
        @game_variables = Marshal.load(file)
        @total_sec = @frame_count / Graphics.frame_rate
      rescue
        @file_exist = false
      ensure
        file.close
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = normal_color
    name = Vocab::File + " #{@file_index + 1}"
    self.contents.draw_text(4, 0, 200, WLH, name)
    @name_width = contents.text_size(name).width
    if @file_exist
      draw_party_characters(152, 58)
      draw_playtime(0, 34, contents.width - 4, 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Party Characters
  #     x : Draw spot X coordinate
  #     y : Draw spot Y coordinate
  #--------------------------------------------------------------------------
  def draw_party_characters(x, y)
    for i in 0...@characters.size
      name = @characters[i][0]
      index = @characters[i][1]
      draw_character(name, index, x + i * 48, y)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Play Time
  #     x : Draw spot X coordinate
  #     y : Draw spot Y coordinate
  #     width : Width
  #     align : Alignment
  #--------------------------------------------------------------------------
  def draw_playtime(x, y, width, align)
    hour = @total_sec / 60 / 60
    min = @total_sec / 60 % 60
    sec = @total_sec % 60
    time_string = sprintf("%02d:%02d:%02d", hour, min, sec)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, width, WLH, time_string, 2)
  end
  #--------------------------------------------------------------------------
  # * Set Selected
  #     selected : new selected (true = selected, false = unselected)
  #--------------------------------------------------------------------------
  def selected=(selected)
    @selected = selected
    update_cursor
  end
  #--------------------------------------------------------------------------
  # * Update cursor
  #--------------------------------------------------------------------------
  def update_cursor
    if @selected
      self.cursor_rect.set(0, 0, @name_width + 8, WLH)
    else
      self.cursor_rect.empty
    end
  end
end
