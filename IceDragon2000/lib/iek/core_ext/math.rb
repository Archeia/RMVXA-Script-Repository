module Math
  ##
  # @param [Numeric] x
  # @param [Numeric] n
  # @return [Numeric]
  def rootn(x, n)
    exp(log(x) / n)
  end unless method_defined? :rootn
end
