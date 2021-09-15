$simport.r('jade/counter_event_controller', '1.0.0', 'An attribute locked EventController') do |d|
  d.depend!('iek/eventable', '~> 1.0.0')
  d.depend!('jade/event_controller', '~> 1.0.0')
end

module Jade
  class CounterEventController < EventController
    include IEK::Eventable

    def initialize
      super
      init_eventable
    end

    def call_event(event)
      trigger(event)
    end

    def process_poll(delta)
      rotate_poll.each do |event|
        call_event(event)
      end
    end

    private :call_event
  end
end
