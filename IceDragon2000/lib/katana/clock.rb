module Katana
  class Clock
    def initialize
      reset
    end

    def now
      Time.now
    end

    def reset
      @time_then = now
    end

    def delta
      now - @time_then
    end

    def restart
      d = delta
      reset
      d
    end
  end
end
