$simport.r('jade/wt/phase_controller', '1.0.0', 'A WT based PhaseController') do |d|
  d.depend!('jade/counter_phase_controller', '~> 1.0.0')
end

module Jade
  class WtPhaseController < CounterPhaseController
  end
end
