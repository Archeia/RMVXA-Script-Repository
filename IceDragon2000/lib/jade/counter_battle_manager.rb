$simport.r('jade/counter_battle_manager', '1.0.0', 'An attribute locked BattleManager') do |d|
  d.depend!('jade/battle_manager', '~> 1.0.0')
end

module Jade
  class CounterBattleManager < BattleManager
    attr_accessor :on_phase_change
    attr_accessor :counter

    def init
      @counter = 0
      @on_phase_change = nil
      @phases = []
      reset_to_next_turn_counter
      event.on_any do |phase|
        @phases << phase
      end
    end

    def run_phase_change(phase)
      debug { |io| io.puts "BattleManager.run_phase_change #{phase}" }
      @on_phase_change.call(phase) if @on_phase_change
    end

    def rotate_phases
      phases = @phases
      @phases = []
      phases
    end

    def start
      phase.start
    end

    def on_unit_counter_step(unit)
      #
    end

    def on_counter_step
      @units.each { |unit| on_unit_counter_step(unit) }
    end

    def counter_step
      on_counter_step
      @counter += 1
      @to_next_turn -= 1
    end

    def to_next_turn_counter_max
      256
    end

    def counter_per_frame
      -1 #7
    end

    def reset_to_next_turn_counter
      @to_next_turn = to_next_turn_counter_max
    end

    def need_to_change_turns?
      @to_next_turn < 0
    end

    def available_units_to_act
      @units.select(&:can_act?)
    end

    def available_unit_to_act
      available_units_to_act.sort_by(&:wt).first
    end

    def find_next_unit_fiberize(phase)
      @model.unit = nil
      @fiber = Fiber.new do
        @model.unit = nil
        c = 0
        0.step do |i|
          break if @units.empty?
          if c <= 0 && counter_per_frame != -1
            Fiber.yield
            c = counter_per_frame
          end
          counter_step
          if need_to_change_turns?
            @model.unit = nil
            break
          elsif unit = available_unit_to_act
            @model.unit = unit
            break
          end
          c -= counter_step
        end
        @fiber = nil
        run_phase_change(phase)
      end
    end

    def process(phase)
      debug { |io| io.puts "BattleManager.process #{phase}"}

      case phase
      when :battle_start
        @units.each(&:on_battle_start)
        run_phase_change(phase)
      when :start_turn
        @turns += 1
        reset_to_next_turn_counter
        @units.each(&:on_start_turn)
        run_phase_change(phase)
      when :first_unit, :next_unit, :check_next_unit
        find_next_unit_fiberize(phase)
      when :unit_start_turn
        @units.each_with_object(@model.unit, &:on_unit_start_turn)
        run_phase_change(phase)
      when :unit_make_action
        run_phase_change(phase)
      when :unit_end_turn
        @units.each_with_object(@model.unit, &:on_unit_end_turn)
        run_phase_change(phase)
      when :end_turn
        @units.each(&:on_end_turn)
        run_phase_change(phase)
      else
        run_phase_change(phase)
      end
    end

    def next
      @phase.process
    end

    def process_phases(delta)
      rotate_phases.each do |phase|
        process(phase)
      end
    end

    def update(delta)
      super
      process_phases(delta) unless @phases.empty?
      @fiber.resume(delta) if @fiber
    end
  end
end
