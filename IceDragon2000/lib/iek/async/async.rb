$simport.r 'iek/async', '1.0.0', 'Utitlity class for creating AsyncTasks'

# Based on http://msdn.microsoft.com/en-us/library/vstudio/hh191443.aspx
class AsyncTask
  # @return [Object]
  attr_accessor :object

  def initialize(*args, &block)
    @object = nil
    @thread = Thread.new do
      @object = block.call(*args)
    end
  end

  # Joins the internal Thread with the caller Thread to wait for its
  # execution, the object returned is the return of the block evaluated
  #
  # @return [Object]
  def await
    @thread.join
    @object
  end

  # Checks if the internal Thread is #dead?
  #
  # @return [Boolean]
  def dead?
    @thread.dead?
  end
end

class Module
  # Converts the given method by method_name into a async method by
  # wrapping its execution in a AsyncTask
  # The original method can be acessed by calling (method_name)_no_async
  #
  # @param [Symbol] method_name
  # @return [Symbol] The original method_name
  def async(method_name)
    # alias the original method as (method_name)_no_async
    #method_name_async    = "#{method_name}_async" # optional
    method_name_no_async = "#{method_name}_no_async"
    alias_method(method_name_no_async, method_name)
    # re-define the original (method_name) as an async method
    define_method(method_name) do |*args, &block|
      AsyncTask.new { send(method_name_no_async, *args, &block) }
    end
    #alias_method(method_name_async, method_name) # optional
    ### allow further method chaining
    method_name
  end
end

module Kernel
  # @return [AsyncTask]
  def atask(*args, &block)
    AsyncTask.new(*args, &block)
  end
end
