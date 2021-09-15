$simport.r('jade/phase_controller', '1.0.0', 'Base Controller for invoking phase changes') do |d|
  d.depend!('jade', '~> 1.0.0')
end

module Jade
  class PhaseController
    attr_accessor :log
    attr_accessor :model
    attr_accessor :event_controller

    def initialize
      @model = nil
      @phases = [:null]
      @event_controller = nil
    end

    def debug
      yield @log if @log
    end

    abstract :process

    def put_event(event_name)
      @event_controller.put(event_name)
    end

    def phase
      @phases.last
    end

    def push(phase)
      @phases << phase
      on_phase_push(phase)
    end

    def change(phase)
      old_phase, @phases[-1] = @phases[-1], phase
      on_phase_change(phase, old_phase)
    end

    def pop
      @phases.pop
    end

    def clear
      @phases.clear
    end

    def replace(phases)
      @phases.replace(phases)
    end

    def on_phase_change(new_phase, old_phase)
      debug { |io| io.puts "change: #{old_phase} > #{new_phase}" }
      put_event(new_phase)
    end

    def on_phase_push(phase)
      debug { |io| io.puts "push: #{old_phase} > #{new_phase}" }
      put_event(phase)
    end

    private :put_event
    private :on_phase_push
    private :on_phase_change
  end
end
