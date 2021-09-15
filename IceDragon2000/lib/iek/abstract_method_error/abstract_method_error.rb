$simport.r 'iek/abstract_method_error', '1.0.0', 'AbstractMethodError'

class AbstractMethodError < NoMethodError
  def initialize(method)
    super "abstract method #{method} was called"
  end
end
