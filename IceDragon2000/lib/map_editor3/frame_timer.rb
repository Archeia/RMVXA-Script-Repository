module MapEditor3
  class FrameTimer
    attr_accessor :duration
    attr_reader :reset

    def initialize(t)
      setup(t)
    end

    def setup(t)
      @duration = t
      reset
    end

    def done?
      @time <= 0
    end

    def rate
      @time / @duration.to_f
    end

    def rate_inv
      1.0 - rate
    end

    def reset
      @time = @duration
    end

    def update
      if @time > 0
        @time -= 1
      end
    end
  end
end
