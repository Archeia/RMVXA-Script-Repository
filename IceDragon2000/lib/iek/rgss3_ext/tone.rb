$simport.r 'iek/rgss3_ext/tone', '1.0.0', 'Extends Tone Class'

class Tone
  alias :initialize_0o4 :initialize
  # @overload initialize()
  # @overload initialize(tone)
  #   @param [Tone] tone
  # @overload initialize(red, green, blue, gray)
  #   @param [Integer] red
  #   @param [Integer] green
  #   @param [Integer] blue
  #   @param [Integer] gray
  def initialize(*args)
    # patch to allow initializing with a Tone
    if args.size == 1
      initialize_0o4()
      set(args.first)
    else
      initialize_0o4(*args)
    end
  end

  alias :set_0o1o4 :set
  # @overload set(tone)
  #   @param [Tone] tone
  # @overload set(red, green, blue, gray)
  #   @param [Integer] red
  #   @param [Integer] green
  #   @param [Integer] blue
  #   @param [Integer] gray
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
    when 3, 'gray',  'a' then gray
    else
      raise ArgumentError, 'expected (0, 1, 2, or 3) or (:red, :green, :blue, :gray)'
    end
  end

  # @param [String, Symbol, Integer] channel
  # @param [Integer] value
  def []=(channel, value)
    case ((Symbol === channel) ? channel.to_s : channel)
    when 0, 'red',   'r' then self.red = value
    when 1, 'green', 'g' then self.green = value
    when 2, 'blue',  'b' then self.blue = value
    when 3, 'gray',  'a' then self.gray = value
    else
      raise ArgumentError, 'expected (0, 1, 2, or 3) or (:red, :green, :blue, :gray)'
    end
  end

  # @return [Array<Integer>[4]]
  def to_a
    [red, green, blue, gray]
  end unless method_defined?(:to_a)

  # @param [Tone] other
  # @param [Float] rate
  # @return [self]
  def lerp!(tone, rate)
    s, t, r = self.to_a, tone.to_a, [0, 0, 0, 0] # // Self, Target, Result
    for i in 0...s.size
      r[i] = (s[i] - ((s[i] - t[i]) * rate)).clamp(s[i].min(t[i]), s[i].max(t[i]))
    end
    self.red   = r[0]
    self.green = r[1]
    self.blue  = r[2]
    self.gray  = r[3]
    self
  end

  # @param [Tone] other
  # @param [Float] rate
  # @return [Tone]
  def lerp(other, rate)
    dup.lerp!(other, rate)
  end
end
