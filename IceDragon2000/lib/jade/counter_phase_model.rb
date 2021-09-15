$simport.r('jade/counter_phase_model', '1.0.0', 'Model for use with CounterPhaseControllers') do |d|
  d.depend!('jade/phase_model', '~> 1.0.0')
end

module Jade
  class CounterPhaseModel < PhaseModel
    attr_accessor :status
    attr_accessor :unit

    # has this battle been judged and needs to end?
    # @return [Boolean]
    def end?
      @status == :end
    end

    # is there an available unit?
    # @return [Boolean]
    def unit?
      !@unit.nil?
    end

    # can we advance to a next_unit?
    # @return [Boolean]
    def next_unit?
      !@unit.nil?
    end

    # can we advance to a next_turn?
    # @return [Boolean]
    def next_turn?
      @status != :end
    end
  end
end
