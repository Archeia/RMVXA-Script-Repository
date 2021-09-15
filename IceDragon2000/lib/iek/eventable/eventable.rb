$simport.r 'iek/eventable', '1.0.0', 'Basic callbacks mixin'

module IEK
  module Eventable
    def init_eventable
      @__any_events__ = []
      @__events__ = {}
    end

    def on_any(&block)
      @__any_events__ << block
    end

    def on(symbol, &block)
      (@__events__[symbol] ||= []).push(block)
    end

    def trigger(symbol, *args)
      @__any_events__.each_with_object(symbol, *args, &:call)
      @__events__[symbol].try(:each, *args, &:call)
    end
  end
end
