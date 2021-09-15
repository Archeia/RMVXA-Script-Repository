$simport.r 'iek/abstract_method_error/core_ext/module', '1.0.0', 'Module Extension' do |d|
  d.depend! 'iek/abstract_method_error', '~> 1.0.0'
end

class Module
  # @param [Symbol] method_name
  def abstract(method_name)
    define_method method_name do |*|
      fail AbstractMethodError.new(method_name)
    end
    method_name
  end
end
