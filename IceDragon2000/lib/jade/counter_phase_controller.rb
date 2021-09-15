$simport.r('jade/counter_phase_controller', '1.0.0', 'An attribute locked PhaseController') do |d|
  d.depend!('jade/phase_controller', '~> 1.0.0')
end

module Jade
  class CounterPhaseController < PhaseController
    def judge
      push(:judge)
    end

    def idle
      push(:idle)
    end

    def start
      change(:start)
    end

    def battle_start
      change(:battle_start)
    end

    def first_turn
      change(:first_turn)
    end

    def start_turn
      change(:start_turn)
    end

    def first_unit
      change(:first_unit)
    end

    def unit_start_turn
      change(:unit_start_turn)
    end

    def unit_start
      change(:unit_start)
    end

    def unit_make_action
      change(:unit_make_action)
    end

    def unit_start_action
      change(:unit_start_action)
    end

    def unit_execute_action
      change(:unit_execute_action)
    end

    def unit_end_action
      change(:unit_end_action)
    end

    def unit_check_next_action
      change(:unit_check_next_action)
    end

    def unit_next_action
      change(:unit_next_action)
    end

    def unit_end
      change(:unit_end)
    end

    def unit_end_turn
      change(:unit_end_turn)
    end

    def check_next_unit
      change(:check_next_unit)
    end

    def next_unit
      change(:next_unit)
    end

    def end_turn
      change(:end_turn)
    end

    def check_next_turn
      change(:check_next_turn)
    end

    def next_turn
      change(:next_turn)
    end

    def battle_end
      change(:battle_end)
    end

    def terminate
      change(:terminate)
    end

    def process
      debug { |io| io.puts "process: #{phase}" }
      case phase
      when :idle
        pop
      when :judge
        if model.end?
          clear
          battle_end
        else
          pop
        end
      when :start
        battle_start
      when :battle_start
        first_turn
      when :first_turn
        start_turn
      when :start_turn
        first_unit
      when :first_unit
        if model.unit?
          unit_start_turn
        else
          end_turn
        end
      when :unit_start_turn
        unit_start
      when :unit_start
        unit_make_action
      when :unit_make_action
        if model.unit.action?
          unit_start_action
        else
          unit_end
        end
      when :unit_start_action
        unit_execute_action
      when :unit_execute_action
        unit_end_action
      when :unit_end_action
        unit_check_next_action
      when :unit_check_next_action
        if model.unit.can_make_next_action?
          unit_make_action
        else
          unit_end
        end
      when :unit_end
        unit_end_turn
      when :unit_end_turn
        check_next_unit
      when :check_next_unit
        if model.next_unit?
          next_unit
        else
          end_turn
        end
      when :next_unit
        unit_start_turn
      when :end_turn
        check_next_turn
      when :check_next_turn
        if model.next_turn?
          next_turn
        else
          battle_end
        end
      when :next_turn
        start_turn
      when :battle_end
        terminate
      end
    end
  end
end
