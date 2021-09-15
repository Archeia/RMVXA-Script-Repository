$simport.r 'iek/rgss3_ext/window', '1.0.0', 'Extends Window Class'

class Window
  def to_rect
    Rect.new(x, y, width, height)
  end

  # Returns the "right" coordinate of the Rect
  #
  # @return [Integer]
  def x2
    x + width
  end

  def x2=(x2)
    self.x = x2 - width
  end

  # Returns the "bottom" coordinate of the Rect
  #
  # @return [Integer]
  def y2
    y + height
  end

  def y2=(y2)
    self.y = y2 - height
  end
end
