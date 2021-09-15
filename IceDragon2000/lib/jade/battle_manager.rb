$simport.r('jade/battle_manager', '1.0.0', 'Jade BattleManager') do |d|
  d.depend!('jade', '~> 1.0.0')
end

module Jade
  class BattleManager
    attr_reader :phase
    attr_reader :event
    attr_reader :model
    attr_accessor :units
    attr_accessor :turns
    attr_accessor :log

    def initialize
      @log   = nil
      @units = []
      @turns = 0
      @phase = create_phase_controller
      @event = create_event_controller
      @model = create_phase_model
      @phase.event_controller = @event
      @phase.model = @model

      init
    end

    def init
      #
    end

    def debug
      yield @log if @log
    end

    def update(delta)
      @event.update(delta)
    end

    private abstract :create_phase_controller
    private abstract :create_event_controller
    private abstract :create_phase_model
  end
end
