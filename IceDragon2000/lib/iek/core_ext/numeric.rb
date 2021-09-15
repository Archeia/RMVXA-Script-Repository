class Numeric
  ##
  # min(Numeric n)
  def min(n)
    n < self ? n : self
  end unless method_defined?(:min)

  ##
  # max(Numeric n)
  def max(n)
    n > self ? n : self
  end unless method_defined?(:max)

  ##
  # clamp(Numeric flr, Numeric cil)
  def clamp(flr, cil)
    (self < flr) ? flr : ((self > cil) ? cil : self)
  end unless method_defined?(:clamp)

  ##
  # wall(Numeric other)
  #   Bounces self back from other if greater than
  def wall(other)
    self > other ? other - self % other : self
  end unless method_defined?(:wall)
end
