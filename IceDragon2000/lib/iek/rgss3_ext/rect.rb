$simport.r 'iek/rgss3_ext/rect', '1.0.0', 'Extends Rect Class'

class Rect
  alias :w :width
  alias :h :height
  alias :w= :width=
  alias :h= :height=

  alias :initialize_0o4 :initialize
  # @overload initialize()
  # @overload initialize(rect)
  #   @param [Rect] rect
  # @overload initialize(x, y, width, height)
  #   @param [Integer] x
  #   @param [Integer] y
  #   @param [Integer] width
  #   @param [Integer] height
  def initialize(*args)
    # patch to allow initializing with a Rect
    if args.size == 1
      initialize_0o4()
      set(args.first)
    else
      initialize_0o4(*args)
    end
  end

  alias :set_0o1o4 :set
  # @overload set(rect)
  #   @param [Rect] rect
  # @overload set(x, y, width, height)
  #   @param [Integer] x
  #   @param [Integer] y
  #   @param [Integer] width
  #   @param [Integer] height
  def set(*args)
    if args.empty?
      raise ArgumentError, 'expected 1 or 4 arguments but received none'
    else
      set_0o1o4(*args)
    end
  end

  # @return [Array<Integer>]
  def to_a
    return x, y, width, height
  end unless method_defined? :to_a

  # Returns the "right" coordinate of the Rect
  # @return [Integer]
  def x2
    x + width
  end

  # Moves the Rect using its right side
  # @param [Integer]
  def x2=(x2)
    self.x = x2 - width
  end

  # Returns the "bottom" coordinate of the Rect
  # @return [Integer]
  def y2
    y + height
  end

  # Moves the Rect using its bottom side
  # @param [Integer]
  def y2=(y2)
    self.y = y2 - height
  end

  # @return [Boolean]
  def empty?
    return width == 0 || height == 0
  end

  # @param [Integer] dir  based on the NUMPAD directions
  # @param [Integer] n    step count
  # @return [self]
  def step!(dir, n = 1)
    case dir
    when 1 then step!(2, n).step!(4, n) # down-left
    when 3 then step!(2, n).step!(6, n) # down-right
    when 7 then step!(8, n).step!(4, n) # up-left
    when 9 then step!(8, n).step!(6, n) # up-right
    when 2 then self.y += self.height * n # down
    when 4 then self.x -= self.width  * n # left
    when 6 then self.x += self.width  * n # right
    when 8 then self.y -= self.height * n # up
    end
    self
  end

  # @param [Integer] dir  based on the NUMPAD directions
  # @param [Integer] n    step count
  # @return [Rect]
  def step(dir, n = 1)
    dup.step!(dir, n)
  end
end
