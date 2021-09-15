$simport.r 'iek/rgss3_ext/sprite', '1.0.0', 'Extends Sprite Class'

class Sprite
  # @return [Rect]
  def to_rect
    Rect.new(x, y, width, height)
  end

  # @param [Integer] new_width
  def width=(new_width)
    self.src_rect.width = new_width
  end unless method_defined?(:width=)

  # @param [Integer] new_height
  def height=(new_height)
    self.src_rect.height = new_height
  end unless method_defined?(:height=)

  # Returns the "right" coordinate of the Rect
  # @return [Integer]
  def x2
    x + width
  end

  # @param [Integer]
  def x2=(x2)
    self.x = x2 - width
  end

  # Returns the "bottom" coordinate of the Rect
  # @return [Integer]
  def y2
    y + height
  end

  # @param [Integer]
  def y2=(y2)
    self.y = y2 - height
  end

  # @return [Void]
  def dispose_bitmap
    bitmap.dispose
  end

  # @return [Void]
  def dispose_bitmap_safe
    dispose_bitmap if bitmap && !bitmap.disposed?
  end

  # @return [Void]
  def dispose_all
    dispose_bitmap_safe
    dispose
  end

  alias :unclamped_bush_opacity= :bush_opacity=
  # Bugfix for bush_opacity not being clamped between 0 and 255
  def bush_opacity=(opacity)
    self.unclamped_bush_opacity = [[0, opacity].max, 255].min
  end
end
