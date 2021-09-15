$simport.r 'iek/rgss3_ext/color', '1.0.0', 'Extends Color Class'

class Color
  alias :initialize_0o4 :initialize
  # @overload initialize()
  # @overload initialize(color)
  #   @param [Color] color
  # @overload initialize(red, green, blue, alpha)
  #   @param [Integer] red
  #   @param [Integer] green
  #   @param [Integer] blue
  #   @param [Integer] alpha
  def initialize(*args)
    # patch to allow initializing with a Color
    if args.size == 1
      initialize_0o4()
      set(args.first)
    else
      initialize_0o4(*args)
    end
  end

  alias :set_0o1o4 :set
  # @overload set(color)
  #   @param [Color] color
  # @overload set(red, green, blue, alpha)
  #   @param [Integer] red
  #   @param [Integer] green
  #   @param [Integer] blue
  #   @param [Integer] alpha
  def set(*args)
    if args.empty?
      raise ArgumentError, 'expected 1 or 4 arguments but received none'
    else
      set_0o1o4(*args)
    end
  end

  # @param [String, Symbol, Integer] channel
  # @return [Integer]
  def [](channel)
    case ((Symbol === channel) ? channel.to_s : channel)
    when 0, 'red',   'r' then red
    when 1, 'green', 'g' then green
    when 2, 'blue',  'b' then blue
    when 3, 'alpha', 'a' then alpha
    else
      raise ArgumentError, 'expected (0, 1, 2, or 3) or (:red, :green, :blue, :alpha)'
    end
  end

  # @param [String, Symbol, Integer] channel
  # @param [Integer] value
  def []=(channel, value)
    case ((Symbol === channel) ? channel.to_s : channel)
    when 0, 'red',   'r' then self.red = value
    when 1, 'green', 'g' then self.green = value
    when 2, 'blue',  'b' then self.blue = value
    when 3, 'alpha', 'a' then self.alpha = value
    else
      raise ArgumentError, 'expected (0, 1, 2, or 3) or (:red, :green, :blue, :alpha)'
    end
  end

  # @return [Array<Integer>[4]]
  def to_a
    return red, green, blue, alpha
  end unless method_defined?(:to_a)

  # @param [Color] other
  # @param [Float] rate
  # @return [self]
  def lerp!(other, rate)
    s, t, r = self.to_a, other.to_a, self.to_a # // Self, Target, Result
    for i in 0...s.size
      r[i] = (s[i] - ((s[i] - t[i]) * rate)).clamp(s[i].min(t[i]), s[i].max(t[i]))
    end
    self.red   = r[0]
    self.green = r[1]
    self.blue  = r[2]
    self.alpha = r[3]
    self
  end

  # @param [Color] other
  # @param [Float] rate
  # @return [Color]
  def lerp(other, rate)
    dup.lerp!(other, rate)
  end

  # @return [Color]
  def self.random
    new rand(0x100), rand(0x100), rand(0x100), 0xFF
  end
end
