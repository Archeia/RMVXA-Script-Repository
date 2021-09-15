#encoding:UTF-8
# ISS033 - Key Cursor
module ISS
  class KeyCursor
  end
end

class ISS::KeyCursor

  attr_accessor :x, :y, :z
  attr_accessor :range
  attr_accessor :speed

  def initialize()
    @bounds = Vector4.new(0, Graphics.width, 0, Graphics.height )
    @range = Vector4.new(0, 0, 0, 0 )
    @speed = 5
    @x, @y, @z = 0, 0, 0
    release_clicks()
  end

  def get_check_range()
    return Vector4.new( self.x+self.range.x1, self.x+self.range.x2,
      self.y+self.range.y1, self.y+self.range.y2 )
  end

  def clamp_x()
    @x = [@x, @bounds.x1, @bounds.x2].clamp
  end

  def clamp_y()
    @y = [@y, @bounds.y1, @bounds.y2].clamp
  end

  def moveto(x, y )
    @x, @y = x, y
  end

  def move_up(n=@speed )
    @y -= n ; clamp_y()
  end

  def move_down(n=@speed )
    @y += n ; clamp_y()
  end

  def move_left(n=@speed )
    @x -= n ; clamp_x()
  end

  def move_right(n=@speed )
    @x += n ; clamp_x()
  end

  def screen_x() ; return self.x ; end

  def screen_y() ; return self.y ; end

  def screen_z() ; return self.z ; end

  def update()
    release_clicks()
    check_clicks()
    @x, @y = *(::ISS::Mouse.pos())
  end

  attr_accessor :left_state, :right_state, :middle_state

  def check_clicks()
    @left_state[0]   = ISS::Mouse.left_click?()
    @left_state[1]   = ISS::Mouse.left_press?()
    @right_state[0]  = ISS::Mouse.right_click?()
    @right_state[1]  = ISS::Mouse.right_press?()
    @middle_state[0] = ISS::Mouse.middle_click?()
    @middle_state[1] = ISS::Mouse.middle_press?()
  end

  def release_clicks()
    @left_state   ||= [] ; @left_state.clear()
    @right_state  ||= [] ; @right_state.clear()
    @middle_state ||= [] ; @middle_state.clear()
  end

  def left_click?()
    return @left_state[0]
  end

  def right_click?()
    return @right_state[0]
  end

  def middle_click?()
    return @middle_state[0]
  end

  def left_press?()
    return @left_state[1]
  end

  def right_press?()
    return @right_state[1]
  end

  def middle_press?()
    return @middle_state[1]
  end

end

class ISS::KeyCursor::ResponseChecker

  attr_accessor :x, :y, :z
  attr_accessor :ox, :oy
  attr_accessor :range

  def initialize(rng=Vector4.new( 0, 0, 0, 0 ) )
    @range = rng
    @x, @y, @z = 0, 0, 0
    @ox, @oy = 0, 0
    @check_vector = Vector4.new()
  end

  def full_x
    return self.x + self.ox
  end

  def full_y
    return self.y + self.oy
  end

  def get_check_range()
    @check_vector.set( self.full_x+self.range.x1, self.full_x+self.range.x2,
      self.full_y+self.range.y1, self.full_y+self.range.y2 )
    return @check_vector
  end

  def cursor_relative_pos(cursor )
    return -1, -1 unless cursor_over?(cursor )
    rng = get_check_range()
    return cursor.x - rng.x1, cursor.y - rng.y1
  end

  def cursor_over?(cursor )
    return get_check_range().in_range?( cursor.get_check_range() )
  end

  def on_cursor_over(cursor )
  end

  def on_left_click(cursor )
  end

  def on_right_click(cursor )
  end

  def on_middle_click(cursor )
  end

  def on_left_press(cursor )
  end

  def on_right_press(cursor )
  end

  def on_middle_press(cursor )
  end

  def on_cursor_not_over(cursor )
  end

  def update(cursor )
    cursor_over = cursor_over?(cursor )
    cursor_over ? on_cursor_over(cursor ) : on_cursor_not_over( cursor )
    return unless cursor_over
    on_left_click(cursor ) if cursor.left_click?()
    on_right_click(cursor ) if cursor.right_click?()
    on_middle_click(cursor ) if cursor.middle_click?()
    on_left_press(cursor ) if cursor.left_press?()
    on_right_press(cursor ) if cursor.right_press?()
    on_middle_press(cursor ) if cursor.middle_press?()
  end

end


class TestResponse < ISS::KeyCursor::ResponseChecker

  TESTSFX = RPG::SE.new("XINFX-Hit01", 100, 100 )

  def initialize(sprite, rng=Vector4.new( 0, 0, 0, 0 ) )
    super(rng )
    @sprite = sprite
  end

  def on_cursor_not_over(cursor )
    @sprite.opacity = 255
  end

  def on_cursor_over(cursor )
    @sprite.opacity = 128
  end

  def on_left_click(cursor )
    TESTSFX.play()
    @sprite.flash(Color.new(32, 32, 198), 30 )
  end

  def on_right_click(cursor )
    TESTSFX.play()
    @sprite.flash(Color.new(198, 32, 32), 30 )
  end

  def on_middle_click(cursor )
    TESTSFX.play()
    @sprite.flash(Color.new(32, 198, 32), 30 )
  end

  def on_left_press(cursor )
    @sprite.flash(Color.new(32, 32, 198), 60 )
  end

  def on_right_press(cursor )
    @sprite.flash(Color.new(198, 32, 32), 60 )
  end

  def on_middle_press(cursor )
    @sprite.flash(Color.new(32, 198, 32), 60 )
  end

end

class ISS::KeyCursor

  def self.run_diagnose
    cursor = ISS::KeyCursor.new()
    csprite = Sprite.new()
    csprite.bitmap = Cache.system("KeyCursor" )

    sq = Rect.new(0,0,64,64)
    w = Graphics.width / sq.width
    h = Graphics.height / sq.height
    testcursors = []
    testsprites = []
    testbitmap = Bitmap.new(sq.width, sq.height )
    testbitmap.fill_rect(2, 2, sq.width-4, sq.height-4, Color.new( 255, 255, 255 ) )
    for x in 0...w
      for y in 0...h
        testsprites << Sprite.new()
        testsprites[-1].bitmap = testbitmap
        testsprites[-1].x = x * sq.width
        testsprites[-1].y = y * sq.height
        sq2 = sq.clone ; sq2.width -= 1 ; sq2.height -= 1
        testcursors << TestResponse.new(testsprites[-1], sq2.to_vector4 )
        testcursors[-1].x = x * sq.width
        testcursors[-1].y = y * sq.height
      end
    end

    loop do

      cursor.release_clicks()
      cursor.check_clicks()
      cursor.x, cursor.y = *ISS::Mouse.pos

      csprite.x = cursor.screen_x
      csprite.y = cursor.screen_y
      csprite.z = cursor.screen_z

      for i in 0...testcursors.size
        testcursors[i].update(cursor )
        testsprites[i].update()
      end

      Graphics.update()
      Input.update()

    end

  end

end

#ISS::KeyCursor.run_diagnose()
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
