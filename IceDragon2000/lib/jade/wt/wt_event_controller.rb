$simport.r('jade/wt/event_controller', '1.0.0', 'A WT based EventController') do |d|
  d.depend!('jade/counter_event_controller', '~> 1.0.0')
end

module Jade
  class WtEventController < CounterEventController
    #
  end
end
