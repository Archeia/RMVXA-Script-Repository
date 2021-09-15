__END__
module REI
module Mixin
module Movement

  def init
    super
    @jump_count = 0
    @stop_count = 0
    @jump_peak = 0
  end

  def set_direction d
    @direction = d
  end

  def move_straight d
    x = REI.x_with_direction @x, d
    y = REI.y_with_direction @y, d
    set_direction d
    @x, @y = x, y
  end

  def move_down
    move_straight 2
  end

  def move_up
    move_straight 8
  end

  def move_right
    move_straight 6
  end

  def move_left
    move_straight 4
  end

  def jump x_plus=0, y_plus=0
    if x_plus.abs > y_plus.abs
      set_direction(x_plus < 0 ? 4 : 6) if x_plus != 0
    else
      set_direction(y_plus < 0 ? 8 : 2) if y_plus != 0
    end
    @x += x_plus
    @y += y_plus
    distance = Math.sqrt(x_plus * x_plus + y_plus * y_plus).round
    @jump_peak = 10 + distance - move_speed
    @jump_count = @jump_peak * 2
    @stop_count = 0
    straighten
  end

  def update_jump
    @jump_count -= 1
    @real_x = (@real_x * @jump_count + @x) / (@jump_count + 1.0)
    @real_y = (@real_y * @jump_count + @y) / (@jump_count + 1.0)
    update_bush_depth
    if @jump_count == 0
      @real_x = @x = _map.round_x(@x)
      @real_y = @y = _map.round_y(@y)
    end
  end

  def moving?
    @real_x != @x or @real_y != @y
  end

  def jumping?
    @jump_count > 0
  end

  def jump_height
    (@jump_peak * @jump_peak - (@jump_count - @jump_peak).abs ** 2) / 2
  end

  def update_bush_depth
  end

end
end
end

class REI::Container::Visual < YGG::Handler::Pos_Screen

  extend MACL::Mixin::Archijust
  include YGG::Constants::Gauge
  include REI::Constants
  include REI::Mixin::Movement

  attr_accessor :character

  def initialize character
    @character = character
    super()
  end

  attr_accessor :face_name, :face_index,
   :character_name, :character_index, :character_hue, :index,
   :iconset_name, :iconset_index,
   :transparent, :bush_depth,
   :zoom_x, :zoom_y, :src_rect, :angle, :ox, :oy, :real_x, :real_y,
   :tone, :color, :direction, :gauges

  memoize_as opacity: 255, bush_opacity: 255
  define_clamp_writer opacity: [0,255], bush_opacity: [0,255]

  def _map
    TestMap
  end

  def init
    super
    @face_name       = ''
    @character_name  = ''
    @iconset_name    = ''

    @face_index      = 0
    @character_index = 0
    @iconset_index   = 0

    @face_hue        = 0
    @character_hue   = 0

    @character_props = {}

    @index           = 0

    @opacity         = 255
    @bush_depth      = 0
    @bush_opacity    = 0
    @angle           = 0
    @ox = @oy        = 0
    @real_x = @real_y= 0
    @zoom_x = @zoom_y= 1.0

    @transparent     = false

    @direction = 2
    @original_direction = 2

    @color           = Color.new 0,0,0,0
    @tone            = Tone.new 0,0,0,0
    @src_rect        = Rect.new 0,0,0,0
    @character_grid  = MACL::Grid.new 0,0,0,0

    @gauges    = {}
    @gauges[GAUGE_HP] = YGG::Handler::Gauge_HP.new self
    @gauges[GAUGE_WT] = REI::Handler::Gauge_WT.new self

    @refresh         = {
      bitmap: true,
      grid: true,
      pos: true,
      gauges: true
    }
  end

  def battler
    @character.battler
  end

  def bmp_face
    Cache.face @face_name
  end

  def bmp_character
    Cache.character @character_name, @character_hue
  end

  def bmp_iconset
    Cache.system @iconset_name
  end

  #def _map
  #  $game.system._map
  #end
  def change_character name,index
    @character_name,@character_index = name,index
    refresh :grid
  end

  def change_face name,index
    @face_name,@face_index = name,index
  end

  def refresh sym
    result = @refresh[sym]
    if block_given?
      result = yield !!@refresh[sym], self
    else
      _refresh sym
      result = false
    end
    @refresh[sym] = result
  end

  def _refresh sym
    case sym
    when :character
      @character_props = REI.parse_char_name @character_name
      _refresh :grid
    when :grid
      bmp = bmp_character
      if @character_props[:single]
        w,h = bmp.width/3,bmp.height/4
      else
        w,h = bmp.width/12,bmp.height/8
      end
      @character_grid.columns = 3
      @character_grid.rows    = 4
      @character_grid.cell_width  = w
      @character_grid.cell_height = h
      @ox, @oy = w/2,h
    when :pos
      straighten
    when :gauges

    end
  end

  def straighten
    @real_x, @real_y = @x, @y
  end

  def refresh? sym=:any
    if sym==:any
      @refresh.any? do |(k,v)| !!v end
    else
      !!@refresh[sym]
    end
  end

  def update
    update_logic
    update_visual
    @gauges.values.each &:update
  end

  def update_logic

  end

  DIRECTION2ROW = {2 => 0, 4 => 1, 6 => 2, 8 => 3}

  def update_visual
    if Graphics.frame_count % 6 == 0
      @index = @index.succ % 4
    end
    cols = 4
    off = DIRECTION2ROW[@direction]*@character_grid.columns
    a = @character_grid.cell_a @index.divmod(3).inject(&:+)+off
    sx, sy = @character_index % cols, @character_index / cols
    a[0] += sx
    a[1] += sy
    @src_rect.set *a
    if jumping?
      update_jump
    elsif moving?
      update_move
    end
  end

  def update_move
    n = distance_per_frame
    @real_x = (@real_x + n).min(@x) if @real_x < @x
    @real_x = (@real_x - n).max(@x) if @real_x > @x
    @real_y = (@real_y + n).min(@y) if @real_y < @y
    @real_y = (@real_y - n).max(@y) if @real_y > @y
  end

  def move_speed
    4
  end

  def real_move_speed
    move_speed
  end

  def distance_per_frame
    2 ** real_move_speed / 256.0
  end

  # //
  memoize_as add_x: 0, add_y: 0, add_z: 0

  attr_writer :add_x, :add_y, :add_z

  def obj_off
    @character_props[:object] ? 0 : 4
  end

  def screen_x
    @real_x * 32 + 16 + add_x
  end

  def screen_y
    @real_y * 32 + 32 - jump_height + add_y + obj_off
  end

  def screen_z
    0 + add_z
  end

end

module REI

  def self.x_with_direction x, d
    x + (d == 6 ? 1 : d == 4 ? -1 : 0)
  end

  def self.y_with_direction y, d
    y + (d == 2 ? 1 : d == 8 ? -1 : 0)
  end
  #def round_x_with_direction(x, d)
  #  round_x(x + (d == 6 ? 1 : d == 4 ? -1 : 0))
  #end
  #def round_y_with_direction(y, d)
  #  round_y(y + (d == 2 ? 1 : d == 8 ? -1 : 0))
  #end
end

class TestBattler < Game::Battler

  def initialize
    super
    recover_all
  end

  def mhp
    120
  end

end
class REI::Container::Character

  (REI::Mixin::Movement.instance_methods - Module.instance_methods).each do |sym|
    str = %Q{
      def #{sym} *args,&block
        @visual.#{sym} *args,&block
      end
    }
    module_eval str
  end

  attr_reader :visual

  def initialize
    @visual  = REI::Container::Visual.new self
    @index   = 0
    @battler = nil
    init
    self.battler = $game.actors[1]
  end

  def init

  end

  attr_reader :battler

  def battler= n
    @battler = n
    @visual.character_name  = @battler.character_name
    @visual.character_index = @battler.character_index
    @visual.face_name       = @battler.face_name
    @visual.face_index      = @battler.face_index
    @visual.refresh :character
  end

  def pos? x,y
    @visual.pos2? x,y
  end

  def moving?
    @visual.moving?
  end

  [:x,:y,:z,:direction,:gauges].each do |sym|
    module_eval %Q(
      def #{sym}
        @visual.#{sym}
      end
      def #{sym}= n
        @visual.#{sym} = n
      end
    )
  end
  def update
    update_logic
    update_visual
  end
  def update_logic
  end
  def update_visual
    @visual.update
  end
  def update_turn
  end
end
