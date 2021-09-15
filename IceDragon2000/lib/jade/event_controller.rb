$simport.r('jade/event_controller', '1.0.0', 'Base Event Controller for on_* events') do |d|
  d.depend!('jade', '~> 1.0.0')
end

module Jade
  class EventController
    def initialize
      @poll = []
    end

    def put(event)
      @poll << event
    end

    def process_poll(delta)
      #
    end

    def rotate_poll
      poll = @poll
      @poll = []
      return poll
    end

    def update(delta)
      unless @poll.empty?
        process_poll(delta)
      end
    end
  end
end
