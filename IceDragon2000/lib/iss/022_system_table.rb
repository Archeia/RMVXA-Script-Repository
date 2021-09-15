#encoding:UTF-8
# ISS022 - System Table 1.0
#==============================================================================#
# ** ISS - System Table
#==============================================================================#
# ** Date Created  : 08/30/2011
# ** Date Modified : 08/31/2011
# ** Created By    : IceDragon
# ** For Game      : S.A.R.A
# ** ID            : 022
# ** Version       : 1.0
# ** Requires      : ISS000 - Core(2.3 or above), IST - MoreRubyStuff(1.9 or above)
#==============================================================================#
($imported ||= {})["ISS-SystemTable"] = true
#==============================================================================#
# ** ISS::SystemTable
#==============================================================================#
module ISS
  install_script(22, :system)
  class SystemTable

  end
end

#==============================================================================#
# ** ISS::SystemTable
#==============================================================================#
class ISS::SystemTable
#==============================================================================#
# ** Box
#==============================================================================#
  Box = Struct.new(:width, :height)
#==============================================================================#
# ** Bounds
#==============================================================================#
  Bounds = Vector4 #Struct.new(:x1, :x2, :y1, :y2)

#==============================================================================#
# ** TableObject
#==============================================================================#
  class TableObject

    attr_accessor :bounds
    attr_accessor :camera
    attr_accessor :x, :y, :z
    attr_accessor :width, :height
    attr_accessor :opacity
    attr_accessor :visible
    attr_accessor :animation_id

  #--------------------------------------------------------------------------#
  # * overwrite-method :initialize
  #--------------------------------------------------------------------------#
    def initialize()
      @bounds               = Bounds.new(0.0, 0.0, 0.0, 0.0)
      @camera               = nil
      @x, @y, @z            = 0.0, 0.0, 0.0
      @width, @height       = 64.0, 64.0
      @sc_width, @sc_height = 64.0, 64.0
      @opacity              = 255
      @visible              = true
      @animation_id         = 0
      @bounded              = true
    end

  #--------------------------------------------------------------------------#
  # * new-method :config_bounds
  #--------------------------------------------------------------------------#
    def config_bounds(x1, x2, y1, y2)
      @bounds.x1, @bounds.x2, @bounds.y1, @bounds.y2 = x1, x2, y1, y2
    end

  #--------------------------------------------------------------------------#
  # * new-method :unbound
  #--------------------------------------------------------------------------#
    def unbound()
      @bounded = false
    end

  #--------------------------------------------------------------------------#
  # * new-method :bound
  #--------------------------------------------------------------------------#
    def bound()
      @bounded = true
    end

  #--------------------------------------------------------------------------#
  # * new-method :clamp_x
  #--------------------------------------------------------------------------#
    def clamp_x(ix)
      return @bounded ? ::ISS.clamp(ix, @bounds.x1, @bounds.x2) : ix
    end

  #--------------------------------------------------------------------------#
  # * new-method :clamp_y
  #--------------------------------------------------------------------------#
    def clamp_y(iy)
      return @bounded ? ::ISS.clamp(iy, @bounds.y1, @bounds.y2) : iy
    end

  #--------------------------------------------------------------------------#
  # * new-method :clamp_xy
  #--------------------------------------------------------------------------#
    def clamp_xy(ix, iy)
      return clamp_x(ix ), clamp_y( iy)
    end

  #--------------------------------------------------------------------------#
  # * new-method :moveto
  #--------------------------------------------------------------------------#
    def moveto(x, y)
      @x, @y = *clamp_xy(x, y)
    end

  #--------------------------------------------------------------------------#
  # * new-method :adjust_wh
  #--------------------------------------------------------------------------#
    def adjust_wh(new_width, new_height)
      @width, @height       = new_width, new_height
      @sc_width, @sc_height = new_width, new_height
    end

  #--------------------------------------------------------------------------#
  # * new-method :offset_x
  #--------------------------------------------------------------------------#
    def offset_x() ; return @camera.nil?() ? 0 : @camera.screen_x ; end

  #--------------------------------------------------------------------------#
  # * new-method :offset_y
  #--------------------------------------------------------------------------#
    def offset_y() ; return @camera.nil?() ? 0 : @camera.screen_y ; end

  #--------------------------------------------------------------------------#
  # * new-method :screen_x
  #--------------------------------------------------------------------------#
    def screen_x() ; return (@x * @sc_width) - offset_x ; end

  #--------------------------------------------------------------------------#
  # * new-method :screen_y
  #--------------------------------------------------------------------------#
    def screen_y() ; return (@y * @sc_height) - offset_y ; end

  #--------------------------------------------------------------------------#
  # * new-method :screen_z
  #--------------------------------------------------------------------------#
    def screen_z() ; return @z ; end

  #--------------------------------------------------------------------------#
  # * new-method :onScreen?
  #--------------------------------------------------------------------------#
    def onScreen?()
      return self.screen_x.between?(-@sc_width, Graphics.width) &&
       self.screen_y.between?(-@sc_height, Graphics.height)
    end

  end

#==============================================================================#
# ** Camera
#==============================================================================#
  class Camera < TableObject

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
    def initialize()
      super()
      @camera = nil
    end

  #--------------------------------------------------------------------------#
  # * overwrite-method :offset_x
  #--------------------------------------------------------------------------#
    def offset_x() ; return 0 ; end

  #--------------------------------------------------------------------------#
  # * overwrite-method :offset_y
  #--------------------------------------------------------------------------#
    def offset_y() ; return 0 ; end

  #--------------------------------------------------------------------------#
  # * new-method :sync_with
  #--------------------------------------------------------------------------#
    def sync_with(sync_object)
      scrnsqWidth  = (Graphics.width / @sc_width)
      scrnsqHeight = (Graphics.height / @sc_height)
      halfwidth  = scrnsqWidth / 2 ; halfheight = scrnsqHeight / 2
      @x = ::ISS.clamp(
        (sync_object.x - halfwidth),
        @bounds.x1,
        (@bounds.x2 - ::ISS.min(@bounds.x2, scrnsqWidth-1 ) ))
      @y = ::ISS.clamp(
        (sync_object.y - halfheight),
        @bounds.y1,
        (@bounds.y2 - ::ISS.min(@bounds.y2, scrnsqHeight-1 ) ))
    end

  end

#==============================================================================#
# ** TableBlock
#==============================================================================#
  class TableBlock < TableObject

    attr_reader :marked

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
    def initialize()
      super()
      @index      = 0
      @mark_index = 0
      @marked     = false
    end

  #--------------------------------------------------------------------------#
  # * new-method :index
  #--------------------------------------------------------------------------#
    def index()
      return @marked ? @mark_index : @index
    end

  #--------------------------------------------------------------------------#
  # * new-method :set_indexes
  #--------------------------------------------------------------------------#
    def set_indexes(n, markedn)
      @index, @mark_index = n, markedn
    end

  #--------------------------------------------------------------------------#
  # * new-method :mark
  #--------------------------------------------------------------------------#
    def mark()
      @marked = true
    end

  #--------------------------------------------------------------------------#
  # * new-method :unmark
  #--------------------------------------------------------------------------#
    def unmark()
      @marked = false
    end

  end

#==============================================================================#
# ** Cursor
#==============================================================================#
  class Cursor < TableObject

    attr_accessor :tx, :ty
    attr_accessor :fade_rate

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
    def initialize()
      super()
      @tx, @ty              = 0, 0
      @fade_phase           = 0
      @fade_rate            = 20.0
      @move_rate            = 0.1
    end

  #--------------------------------------------------------------------------#
  # * new-method :moving?
  #--------------------------------------------------------------------------#
    def moving?() ; return (@tx != @x || @ty != @y) ; end

  #--------------------------------------------------------------------------#
  # * overwrite-method :moveto
  #--------------------------------------------------------------------------#
    def moveto(x, y, quick=false)
      @tx, @ty = *clamp_xy(x, y)
      @x, @y = @tx, @ty if quick
    end

  #--------------------------------------------------------------------------#
  # * new-method :move_left
  #--------------------------------------------------------------------------#
    def move_left(amt=-1 ) ; move_right( amt) ; end

  #--------------------------------------------------------------------------#
  # * new-method :move_right
  #--------------------------------------------------------------------------#
    def move_right(amt=1)
      @tx += amt
      @tx = clamp_x(@tx)
    end

  #--------------------------------------------------------------------------#
  # * new-method :move_up
  #--------------------------------------------------------------------------#
    def move_up(amt=-1 )   ; move_down( amt)  ; end

  #--------------------------------------------------------------------------#
  # * new-method :move_down
  #--------------------------------------------------------------------------#
    def move_down(amt=1)
      @ty += amt
      @ty = clamp_y(@ty)
    end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
    def update()
      update_fade()
      update_position()
    end

  #--------------------------------------------------------------------------#
  # * new-method :update_fade
  #--------------------------------------------------------------------------#
    def update_fade()
      if @fade_phase == 0
        @opacity = @opacity - (255 / @fade_rate) ; @fade_phase = 1 if @opacity <= 0
      elsif @fade_phase == 1
        @opacity = @opacity + (255 / @fade_rate) ; @fade_phase = 0 if @opacity >= 255
      end
      @opacity = [[@opacity, 255].min, 0].max
    end

  #--------------------------------------------------------------------------#
  # * new-method :update_position
  #--------------------------------------------------------------------------#
    def update_position()
      if @x > @tx   ; @x = [@x-@move_rate, @tx].max
      elsif @x < @tx ; @x = [@x+@move_rate, @tx].min
      end
      if @y > @ty   ; @y = [@y-@move_rate, @ty].max
      elsif @y < @ty ; @y = [@y+@move_rate, @ty].min
      end
    end

  end

#==============================================================================#
# ** Sprite_TableBlock
#==============================================================================#
  class Sprite_TableBlock < ::Sprite_Base

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
    def initialize(parent, viewport=nil)
      super(viewport)
      self.bitmap  = Cache.system("SystemTableSqs")
      @rbox        = Box.new(64, 64)
      @last_index  = -1
      @parent      = parent
      update_bitmap()
    end

  #--------------------------------------------------------------------------#
  # * super-method :update
  #--------------------------------------------------------------------------#
    def update()
      super()
      self.visible = @parent.onScreen?() && @parent.visible
      return unless self.visible
      update_bitmap()
      self.zoom_x = (1.0 / @rbox.width) * @parent.width
      self.zoom_y = (1.0 / @rbox.height) * @parent.height
      self.x = @parent.screen_x
      self.y = @parent.screen_y
      self.z = @parent.screen_z
      self.opacity = @parent.opacity
      if @parent.animation_id > 0
        start_animation($data_animations[@parent.animation_id])
        @parent.animation_id = 0
      end
    end

  #--------------------------------------------------------------------------#
  # * new-method :update_bitmap
  #--------------------------------------------------------------------------#
    def update_bitmap()
      if @parent.index != @last_index
        @last_index = @parent.index
        self.src_rect.set(
          @rbox.width * (@last_index % (self.bitmap.width / @rbox.width)),
          @rbox.height * (@last_index / (self.bitmap.width / @rbox.width)),
          @rbox.width, @rbox.height
        )
      end
    end

  end

#==============================================================================#
# ** Sprite_TableBlocks
#==============================================================================#
  class Sprite_TableBlocks < ::Sprite

    attr_accessor :twidth, :theight

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
    def initialize(table, viewport=nil)
      super(viewport)
      @twidth, @theight = 64, 64
      @rbox  = Box.new(64, 64)
      @table = table
      refresh()
    end

  #--------------------------------------------------------------------------#
  # * new-method :refresh
  #--------------------------------------------------------------------------#
    def refresh()
      self.bitmap.dispose() unless self.bitmap.nil?()
      self.bitmap = Bitmap.new(@table.width*64, @table.height*64)
      @table.each { |e| draw_cell(e) }
    end

  #--------------------------------------------------------------------------#
  # * new-method :draw_cell
  #--------------------------------------------------------------------------#
    def draw_cell(e)
      dbit = Cache.system("SystemTableSqs")
      rect = Rect.new(
       @rbox.width * (e.index % (dbit.width / @rbox.width)),
       @rbox.height * (e.index / (dbit.width / @rbox.width)),
       @rbox.width, @rbox.height )
      self.bitmap.clear_rect( e.x*@rbox.width, e.y*@rbox.height,
       @rbox.width, @rbox.height)
      self.bitmap.blt(e.x*@rbox.width, e.y*@rbox.height, dbit, rect, e.marked ? 255 : 128)
    end

  #--------------------------------------------------------------------------#
  # * super-method :dispose
  #--------------------------------------------------------------------------#
    def dispose()
      self.bitmap.dispose()
      super()
    end

  #--------------------------------------------------------------------------#
  # * super-method :update
  #--------------------------------------------------------------------------#
    def update()
      super()
      self.zoom_x = (1.0 / @rbox.width) * @twidth
      self.zoom_y = (1.0 / @rbox.height) * @theight
    end

  end

#==============================================================================#
# ** Sprite_CursorRect
#==============================================================================#
  class Sprite_CursorRect < ::Sprite

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
    def initialize(parent, viewport=nil)
      super(viewport)
      @parent = parent
      self.bitmap = Cache.system("Cursor")
      @rbox = Box.new(self.bitmap.width, self.bitmap.height)
    end

  #--------------------------------------------------------------------------#
  # * super-method :update
  #--------------------------------------------------------------------------#
    def update()
      super()
      self.visible = @parent.visible
      self.zoom_x = (1.0 / @rbox.width) * @parent.width
      self.zoom_y = (1.0 / @rbox.height) * @parent.height
      self.x = @parent.screen_x
      self.y = @parent.screen_y
      self.z = @parent.screen_z
      self.opacity = @parent.opacity
    end

  end

#==============================================================================#
# ** Sprite_Animation
#==============================================================================#
  class Sprite_Animation < ::Sprite_Base

    attr_reader :parent

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
    def initialize(viewport=nil)
      super(viewport)
      self.bitmap = Bitmap.new(64, 64)
      @parent = nil
      @rbox = Box.new(64, 64)
    end

  #--------------------------------------------------------------------------#
  # * new-method :parent=
  #--------------------------------------------------------------------------#
    def parent=(new_parent)
      @parent = new_parent
      update_basic() unless @parent.nil?()
    end

  #--------------------------------------------------------------------------#
  # * super-method :dispose
  #--------------------------------------------------------------------------#
    def dispose()
      self.bitmap.dispose()
      super()
    end

  #--------------------------------------------------------------------------#
  # * new-method :play_animation
  #--------------------------------------------------------------------------#
    def play_animation(id)
      start_animation($data_animations[id])
    end

  #--------------------------------------------------------------------------#
  # * super-method :update
  #--------------------------------------------------------------------------#
    def update()
      super()
      update_basic() unless @parent.nil?()
    end

  #--------------------------------------------------------------------------#
  # * new-method :update_basic
  #--------------------------------------------------------------------------#
    def update_basic()
      self.zoom_x = (1.0 / @rbox.width) * @parent.width
      self.zoom_y = (1.0 / @rbox.height) * @parent.height
      self.x = @parent.screen_x
      self.y = @parent.screen_y
      self.z = @parent.screen_z
      self.x -= ((self.zoom_x)*(@rbox.width/2)) if self.zoom_x != 1
      self.y -= ((self.zoom_y)*(@rbox.height/2)) if self.zoom_y != 1
      self.opacity = @parent.opacity
    end

  end

end

#==============================================================================#
# ** ISS::SystemTable
#==============================================================================#
class ISS::SystemTable

  attr_reader :width, :height

  #--------------------------------------------------------------------------#
  # * overwrite-method :initialize
  #--------------------------------------------------------------------------#
  def initialize(nwidth, nheight)
    resize(nwidth, nheight)
  end

  #--------------------------------------------------------------------------#
  # * new-method :resize
  #--------------------------------------------------------------------------#
  def resize(nwidth, nheight)
    @width, @height = nwidth, nheight
    @data.clear() unless @data.nil?()
    @data = Array.new(@width ).map! { Array.new( @height) }
    @mark = Array.new(@width ).map! { Array.new( @height, false) }
  end

  #--------------------------------------------------------------------------#
  # * new-method :inRange?
  #--------------------------------------------------------------------------#
  def inRange?(x, y)
    return (x.between?(0, @width-1 ) && y.between?( 0, @height-1))
  end

  #--------------------------------------------------------------------------#
  # * new-method :can_mark?
  #--------------------------------------------------------------------------#
  def can_mark?(x, y)
    return false unless inRange?(x, y)
    return false if get_cell(x, y).marked
    return true
  end

  #--------------------------------------------------------------------------#
  # * new-method :get_cell
  #--------------------------------------------------------------------------#
  def get_cell(x, y) ; return @data[x][y] ; end

  #--------------------------------------------------------------------------#
  # * new-method :set_cell
  #--------------------------------------------------------------------------#
  def set_cell(x, y, value) ; @data[x][y] = value ; end

  #--------------------------------------------------------------------------#
  # * new-method :set_from
  #--------------------------------------------------------------------------#
  def set_from(ref_array)
    ref_array.each_with_index() { |e, i|
      v = yield e, i
      set_cell(i % @width, i / @width, v)
    }
  end

  #--------------------------------------------------------------------------#
  # * new-method :mark_cell
  #--------------------------------------------------------------------------#
  def mark_cell(x, y)
    @mark[x][y] = true
  end

  #--------------------------------------------------------------------------#
  # * new-method :unmark_cell
  #--------------------------------------------------------------------------#
  def unmark_cell(x, y)
    @mark[x][y] = false
  end

  #--------------------------------------------------------------------------#
  # * new-method :each
  #--------------------------------------------------------------------------#
  def each()
    for x in 0...@width
      for y in 0...@height
        yield get_cell(x, y)
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :each_with_xy
  #--------------------------------------------------------------------------#
  def each_with_xy()
    for x in 0...@width
      for y in 0...@height
        yield get_cell(x, y), x, y
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :elements
  #--------------------------------------------------------------------------#
  def elements()
    result = [] ; each { |e| result << e } ; return result
  end

end

#==============================================================================#
# ** Scene_SystemTable
#==============================================================================#
class Scene_SystemTable < ::Scene_Base

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize(called=:map, return_index=0)
    super()
    # ---------------------------------------------------- #
    @calledfrom = called
    @return_index = return_index
    set_blocks()
    @last_x, @last_y = 0, 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :set_blocks
  #--------------------------------------------------------------------------#
  def set_blocks() ; @blocks = ISS::SystemTable.new() ; end

  #--------------------------------------------------------------------------#
  # * super-method :start
  #--------------------------------------------------------------------------#
  def start()
    super()
    create_menu_background()
    @block_sprites = ::ISS::SystemTable::Sprite_TableBlocks.new(@blocks, nil)

    @camera = ISS::SystemTable::Camera.new()
    @cursor = ISS::SystemTable::Cursor.new() ; @cursor.z = 3
    @cursor_sprite = ISS::SystemTable::Sprite_CursorRect.new(@cursor, nil)
    ([@camera, @cursor] + @blocks.elements).each { |e|
      e.camera = @camera unless e == @camera
      e.config_bounds(0, @blocks.width-1, 0, @blocks.height-1)
    }
    @animation_sprite = ISS::SystemTable::Sprite_Animation.new(nil)

    @adjust_zoom = 64
    @tadjust_zoom = 64
  end

  #--------------------------------------------------------------------------#
  # * super-method :terminate
  #--------------------------------------------------------------------------#
  def terminate()
    super()
    dispose_menu_background()
    @animation_sprite.dispose() unless @animation_sprite.nil?()
    @cursor_sprite.dispose() unless @cursor_sprite.nil?()
    @block_sprites.dispose() unless @block_sprites.nil?()
    @animation_sprite = nil
    @cursor_sprite    = nil
    @block_sprites    = nil
  end


  #--------------------------------------------------------------------------#
  # * new-method :return_scene
  #--------------------------------------------------------------------------#
  def return_scene()
    case @calledfrom
    when :map
      $scene = Scene_Map.new()
    when :menu
      $scene = Scene_Menu.new(@return_index)
    end
  end

  #--------------------------------------------------------------------------#
  # * super-method :update
  #--------------------------------------------------------------------------#
  def update()
    super()
    update_menu_background()
    update_mark_input()
    if Input.trigger?(Input::B)
      Sound.play_cancel()
      return_scene()
    end
    update_cursor_input()
    if Input.press?(Input::X)    ; @tadjust_zoom -= 1
    elsif Input.press?(Input::Y) ; @tadjust_zoom += 1
    end
    update_zoom()
    object_updates()
    sprite_updates()
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_mark_input
  #--------------------------------------------------------------------------#
  def update_mark_input()
    if Input.trigger?(Input::C)
      if can_mark?(@cursor.tx, @cursor.ty)
        Sound.play_decision()
        mark_cell(@cursor.tx, @cursor.ty)
      else
        Sound.play_buzzer()
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_cursor_input
  #--------------------------------------------------------------------------#
  def update_cursor_input()
    unless @cursor.moving?()
      if Input.press?(Input::LEFT)
        @cursor.move_left()
      elsif Input.press?(Input::RIGHT)
        @cursor.move_right()
      end
      if Input.press?(Input::UP)
        @cursor.move_up()
      elsif Input.press?(Input::DOWN)
        @cursor.move_down()
      end
    end
    Sound.play_cursor() if @last_x != @cursor.tx || @last_y != @cursor.ty
    @last_x, @last_y = @cursor.tx, @cursor.ty
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_zoom
  #--------------------------------------------------------------------------#
  def update_zoom()
    @tadjust_zoom = [[@tadjust_zoom, 32].max, 64].min
    if @adjust_zoom > @tadjust_zoom
      @adjust_zoom = [@adjust_zoom - 1, @tadjust_zoom].max
    elsif @adjust_zoom < @tadjust_zoom
      @adjust_zoom = [@adjust_zoom + 1, @tadjust_zoom].min
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :object_updates
  #--------------------------------------------------------------------------#
  def object_updates()
    @camera.sync_with(@cursor)
    @camera.adjust_wh(@adjust_zoom, @adjust_zoom)
    @cursor.update()
    @cursor.adjust_wh(@adjust_zoom, @adjust_zoom)
    @blocks.each { |b|
      b.adjust_wh(@adjust_zoom, @adjust_zoom)
      if b.animation_id > 0
        @animation_sprite.parent = b
        @animation_sprite.play_animation(b.animation_id)
        b.animation_id = 0
      end
    }
  end

  #--------------------------------------------------------------------------#
  # * new-method :sprite_updates
  #--------------------------------------------------------------------------#
  def sprite_updates()
    @block_sprites.twidth, @block_sprites.theight = @adjust_zoom, @adjust_zoom
    @block_sprites.x = -@camera.x * @tadjust_zoom
    @block_sprites.y = -@camera.y * @tadjust_zoom
    @block_sprites.update()
    @cursor_sprite.update()
    @animation_sprite.update()
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_basic
  #--------------------------------------------------------------------------#
  def update_basic()
    Graphics.update()
    Input.update()
  end

  #--------------------------------------------------------------------------#
  # * new-method :wait_for_animation
  #--------------------------------------------------------------------------#
  def wait_for_animation()
    loop do
      update_basic()
      object_updates()
      sprite_updates()
      break unless @animation_sprite.animation?()
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :can_mark?
  #--------------------------------------------------------------------------#
  def can_mark?(x, y)
    @blocks.can_mark?(x, y)
  end

  #--------------------------------------------------------------------------#
  # * new-method :mark_cell
  #--------------------------------------------------------------------------#
  def mark_cell(x, y)
    cell = @blocks.get_cell(x, y)
    unless cell.marked
      cell.mark()
      cell.animation_id = 20
      wait_for_animation()
      @block_sprites.draw_cell(cell)
    end
  end

end
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
