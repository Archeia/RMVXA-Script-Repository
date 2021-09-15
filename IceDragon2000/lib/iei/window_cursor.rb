#-define SKPVERSION 1.1.0
#-define HDR_TYP :type=>"class"
#-define HDR_GNM :name=>"IEI - Window Cursor"
#-define HDR_GDC :dc=>"28/07/2012"
#-define HDR_GDM :dm=>"06/04/2013"
#-define HDR_GAUT :author=>"IceDragon"
#-define HDR_VER :version=>"SKPVERSION"
#-inject gen_script_header HDR_TYP,HDR_GNM,HDR_GAUT,HDR_GDC,HDR_GDM,HDR_VER
#
# CHANGELOG
#   [06/04/2013] 1.1.0
#     BUGFIX: Fixed cursor position with scrolling windows
#
$simport.r 'iei/window_cursor', '1.0.0', 'IEI Window Cursor'
#-inject gen_module_header 'IEI'
module IEI
  #-inject gen_module_header 'WindowCursor'
  module WindowCursor

    Cursor = Struct.new(:filename, :cell_count, :cell_width, :cell_height,
                        :cols, :frame_rate, :tween_func)

    ## CONFIG ##
    # Cursor WC_CURSOR
    WC_CURSOR = Cursor.new
    ## START CONFIG ##
    WC_CURSOR.filename    = 'win_cursor'
    WC_CURSOR.cell_count  = 3   # Number of frames or cells the animation has
    WC_CURSOR.cell_width  = nil # Width of 1 cell
    WC_CURSOR.cell_height = nil # Height of 1 cell
    WC_CURSOR.cols        = 3   # Number of columns in the file
    WC_CURSOR.frame_rate  = Graphics.frame_rate / 10 # 10 changes per second

    ## ADVANCE CONFIG ##
    # tween_func(Array<int>[3] src_vec, Array<int>[3] dst_vec, Integer delta)
    #   src_vec -> [x, y, z]
    #   dst_vec -> [x, y, z]
    #   delta is the time elapsed since the last change in the src_vec
    WC_CURSOR.tween_func = ->(cursor, src_vec, dst_vec, delta) do
      # no tweening, just return the dst_vec
      res = dst_vec.dup
      res[0] += 4 # apply an inset of 4 pixels
      res
    end
    ## END CONFIG ##

  end
end

#-inject gen_stop_warning

#-inject gen_intf_heading

#-inject gen_module_header 'IEI::WindowCursor'
module IEI
  module WindowCursor

    NullViewport    = Struct.new(:ox, :oy, :z, :rect)
    NULL_VIEWPORT   = NullViewport.new(0, 0, 0, Rect.new(0, 0, 0, 0))
    CURSOR_Z_OFFSET = 0x2000

    @@wcursor_spr = nil
    @@wcwindows = []

    ##
    # initialize(*args, &block)
    def initialize(*args, &block)
      super(*args, &block)
      @@wcwindows << self
    end

    ##
    # dispose(*args, &block)
    def dispose(*args, &block)
      @@wcwindows.delete(self)
      super(*args, &block)
    end

    def wcursor_check_disposed
      if self.disposed?
        @@wcwindows.delete(self)
        return true
      end
      return false
    end

    ##
    # _wcursor_active?
    def _wcursor_active?
      return false if wcursor_check_disposed
      self.active and self.open? and self.visible and self.index > -1
    end

    ##
    # cursor_rect_abs
    def cursor_rect_abs
      cursor_rect
    end

    ##
    # _wcursor_calc_a
    def _wcursor_calc_a
      r  = cursor_rect_abs.dup
      v  = (self.viewport || NULL_VIEWPORT)
      vr = v.rect
      padding_off = standard_padding
      return [self.x - self.ox + r.x - v.ox + vr.x + padding_off,
              self.y - self.oy + r.y - v.oy + vr.y + padding_off + r.height / 2,
              self.z + v.z + CURSOR_Z_OFFSET]
    end

    ##
    # ::wcursor_spr
    def self.wcursor_spr
      if !@@wcursor_spr || @@wcursor_spr.disposed?
        @@wcursor_spr = Sprite::WindowCursor.new
      end
      @@wcursor_spr
    end

    ##
    # ::wcwindows
    def self.wcwindows
      @@wcwindows
    end

    def self.update
      wcursor_spr.update
    end
  end
end

#-inject gen_module_header 'Graphics'
module Graphics
  class << self

    ##
    # ::update
    alias wc_update update
    def update
      wc_update
      IEI::WindowCursor.update
    end

  end
end

#-inject gen_class_header 'Rect'
class Rect

  ##
  # empty?
  def empty?
    width == 0 || height == 0
  end unless method_defined?(:empty?)

end

#-inject gen_class_header 'Sprite::WindowCursor'
class Sprite::WindowCursor < Sprite

  ### instance_attributes
  attr_accessor :window
  attr_reader :cursor

  ##
  # initialize(Viewport viewport)
  def initialize(viewport=nil)
    super(viewport)
    setup_cursor(IEI::WindowCursor::WC_CURSOR)
  end

  ##
  # dispose
  def dispose
    self.bitmap.dispose unless self.bitmap or !self.bitmap.disposed?
    super
  end

  ##
  # setup_cursor(IEI::WindowCursor::Cursor cursor)
  def setup_cursor(cursor)
    @cursor = cursor
    refresh
  end

  ##
  # refresh
  def refresh
    self.bitmap = Cache.system(@cursor.filename)
    @cursor.cell_width ||= self.bitmap.width / @cursor.cols
    @cursor.cell_height||= self.bitmap.height / (@cursor.cell_count / @cursor.cols)
    self.ox = @cursor.cell_width
    self.oy = @cursor.cell_height / 2
    set_cell_index(0)
    @ticks = 0
    self
  end

  ##
  # set_cell_index(int index)
  def set_cell_index(index)
    @index = index
    xindex = (index % @cursor.cols)
    yindex = (index / @cursor.cols)
    self.src_rect.set(@cursor.cell_width * xindex, @cursor.cell_height * yindex,
                      @cursor.cell_width, @cursor.cell_height)
  end

  ##
  # update
  def update
    if !@window || !@window._wcursor_active?
      @window = IEI::WindowCursor.wcwindows.find(&:_wcursor_active?)
    end
    super
    self.visible = !!@window
    return unless visible
    @ticks += 1
    if @dst_vec != (a = @window._wcursor_calc_a) || !@src_vec
      @src_vec = [self.x, self.y, self.z]
      @dst_vec = a
      @last_ticks = @ticks
    end
    self.x, self.y, self.z = @cursor.tween_func.(@cursor, @src_vec, @dst_vec,
                                                 @ticks - @last_ticks)
    if @ticks % @cursor.frame_rate == 0
      @index = (@index + 1) % @cursor.cell_count
      set_cell_index(@index)
    end
  end

end

#-inject gen_imp_heading

#-inject gen_class_header 'Window_Selectable'
class Window_Selectable

  include IEI::WindowCursor

end

#-inject gen_class_header 'Window_SaveFile'
class Window_SaveFile

  include IEI::WindowCursor

  def _wcursor_active?
    return false if wcursor_check_disposed
    self.active and self.open? and self.visible and !self.cursor_rect.empty?
  end

end

#-inject gen_scr_imported 'IEI::WindowCursor', %Q('SKPVERSION'.freeze)

#-inject gen_script_footer
