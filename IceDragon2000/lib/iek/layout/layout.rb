class LayoutRect
  attr_reader :rect

  def initialize(rect)
    @rect = rect.dup.freeze
  end

  def to_rect
    @rect.dup
  end

  def x
    @rect.x
  end

  def y
    @rect.y
  end

  def width
    @rect.width
  end

  def height
    @rect.height
  end

  def cx
    @rect.cx
  end

  def cy
    @rect.cy
  end

  def x2
    @rect.x2
  end

  def y2
    @rect.y2
  end

  def cent_width(f=1.0)
    (f * width).to_i
  end

  def cent_height(f=1.0)
    (f * height).to_i
  end

  def cent_x(f=0.0)
    (x + cent_width(f)).to_i
  end

  def cent_y(f=0.0)
    (y + cent_height(f)).to_i
  end

  def cent_rect(x, y, w, h)
    Rect.new(cent_x(x), cent_y(y), cent_w(w), cent_h(h))
  end

  def col(n, m)
    cent_x(n / m.to_f)
  end

  def row(n, m)
    cent_y(n / m.to_f)
  end

  def cell_width(n, m)
    n * width / m
  end

  def cell_height(n, m)
    n * height / m
  end

  def cell(x, y, cols, rows)
    w = cell_width(1, cols)
    h = cell_height(1, rows)
    Rect.new(x * w, y * h, w, h)
  end
end

class Rect
  def to_layout
    LayoutRect.new(self)
  end
end
