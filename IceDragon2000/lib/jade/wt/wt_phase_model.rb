$simport.r('jade/wt/phase_model', '1.0.0', 'A WT based PhaseModel') do |d|
  d.depend!('jade/counter_phase_model', '~> 1.0.0')
end

module Jade
  class WtPhaseModel < CounterPhaseModel

  end
end
