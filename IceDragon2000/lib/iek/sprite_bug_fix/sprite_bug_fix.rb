class Sprite
  alias :no_bugfix_initialize :initialize

  def initialize(*args, &block)
    no_bugfix_initialize(*args, &block)
    self.tone  = Tone.new(0, 0, 0, 0)
    self.color = Color.new(0, 0, 0, 0)
  end
end
