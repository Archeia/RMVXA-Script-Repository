$simport.r 'iek/callbacks', '1.0.0', 'A simple mixin module for adding Callbacks to an object'

module Mixin
  module Callback
    attr_accessor :callback_log

    ## ~new-method
    # init_callbacks
    def init_callbacks
      @callbacks = {}
    end

    ## ~new-method
    # add_callback(Symbol symbol) { |*args, &block|  }
    def add_callback(symbol, &block)
      init_callbacks unless @callbacks
      (@callbacks[symbol] ||= []).push(block)
      @callback_log.puts "[#{self.class} add_callback] : #{symbol}" if @callback_log
    end

    ## ~new-method
    # callback?(Symbol symbol)
    def callback?(symbol)
      init_callbacks unless @callbacks
      @callbacks.has_key?(symbol)
    end

    ## ~new-method
    # call_callback(Symbol symbol, *args, &block)
    def call_callback(symbol, *args, &block)
      init_callbacks unless @callbacks
      @callbacks[symbol].each { |func| func.call(*args, &block) }
      @callback_log.puts "[#{self.class} call_callback] : #{symbol}" if @callback_log
    end

    ## ~new-method
    # try_callback(Symbol symbol, *args, &block)
    def try_callback(symbol, *args, &block)
      call_callback(symbol, *args, &block) if callback?(symbol)
    end
  end
end
