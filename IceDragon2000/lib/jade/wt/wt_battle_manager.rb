$simport.r('jade/wt/battle_manager', '1.0.0', 'WT BattleManager') do |d|
  d.depend('jade/counter_battle_manager', '~> 1.0.0')
  d.depend('jade/wt/phase_controller', '~> 1.0.0')
  d.depend('jade/wt/event_controller', '~> 1.0.0')
  d.depend('jade/wt/phase_model', '~> 1.0.0')
end

module Jade
  class WtBattleManager < CounterBattleManager
    def create_phase_controller
      WtPhaseController.new
    end

    def create_event_controller
      WtEventController.new
    end

    def create_phase_model
      WtPhaseModel.new
    end

    def on_unit_counter_step(unit)
      unit.wt -= 1
    end

    def to_next_turn_counter_max
      512 * 8
    end
  end
end
