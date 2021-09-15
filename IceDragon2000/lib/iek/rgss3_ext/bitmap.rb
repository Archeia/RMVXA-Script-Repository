$simport.r 'iek/rgss3_ext/bitmap', '1.0.0', 'Extends Bitmap Class'

class Bitmap
  alias :org_initialize :initialize
  def initialize(*args)
    org_initialize(*args)
    yield self if block_given?
  end

  ##
  # @return [Rect]
  def to_rect
    Rect.new(0, 0, width, height)
  end

  ##
  # @param [Color] color
  def fill(color)
    fill_rect(0, 0, width, height, color)
  end

  ##
  # @overload draw_crosseye(rect, color)
  #   @param [Rect] rect
  #   @param [Color] color
  # @overload draw_crosseye(x, y, w, h, color)
  #   @param [Integer] x
  #   @param [Integer] y
  #   @param [Integer] w
  #   @param [Integer] h
  #   @param [Color] color
  # @return [Rect] filled_rect
  def draw_crosseye(*args)
    case args.size
    when 2
      rect, color = *args
      x, y, w, h = *rect
    when 5
      x, y, w, h, color = *args
    else
      raise ArgumentError, "wrong argument count #{args.size} (expected 2, or 5)"
    end

    fill_rect x + w / 2, y, 1, h, color
    fill_rect x, y + h / 2, w, 1, color

    Rect.new x, y, w, h
  end

  ##
  # @overload draw_outline_rect(rect, color)
  #   @param [Rect] rect
  #   @param [Color] color
  # @overload draw_outline_rect(x, y, w, h, color)
  #   @param [Integer] x
  #   @param [Integer] y
  #   @param [Integer] w
  #   @param [Integer] h
  #   @param [Color] color
  # @return [Rect] filled_rect
  def draw_outline_rect(*args)
    case args.size
    when 2
      rect, color = *args
      x, y, w, h = *rect
    when 5
      x, y, w, h, color = *args
    else
      raise ArgumentError, "wrong argument count #{args.size} (expected 2, or 5)"
    end

    fill_rect x, y, w, 1, color
    fill_rect x, y+h-1, w, 1, color
    fill_rect x, y+1, 1, h-2, color
    fill_rect x+w-1, y+1, 1, h-2, color

    Rect.new x, y, w, h
  end

  ##
  # Use (bitmap) to fill target (dest_rect)
  # @param [Rect] dest_rect
  # @param [Bitmap] bitmap
  # @param [Rect] src_rect
  # @return [Rect] filled_rect
  def blt_fill(dest_rect, bitmap, src_rect)
    x = dest_rect.x
    y = dest_rect.y
    dw = dest_rect.width
    dh = dest_rect.height

    sx = src_rect.x
    sy = src_rect.y
    sw = src_rect.width
    sh = src_rect.height

    w_segs, w_rem = *dw.divmod(sw)
    h_segs, h_rem = *dh.divmod(sh)

    w_segs.times do |xi|
      dx = x + xi * sw
      h_segs.times do |yi|
        dy = y + yi * sh
        blt dx, dy, bitmap, src_rect
      end
      dy = y + h_segs * sh
      r = src_rect.dup
      r.height = h_rem
      blt dx, dy, bitmap, r
    end
    dx = x + w_segs * sw
    r = src_rect.dup
    r.width = w_rem
    h_segs.times do |yi|
      dy = y + yi * sh
      blt dx, dy, bitmap, r
    end
    dy = y + h_segs * sh
    r = src_rect.dup
    r.width = w_rem
    r.height = h_rem
    blt dx, dy, bitmap, r

    Rect.new dest_rect.x, dest_rect.y, dest_rect.width, dest_rect.height
  end
end
