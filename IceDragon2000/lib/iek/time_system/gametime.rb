$simport.r 'iek/time_system/gametime', '1.0.0', 'Uses ingame clock for TimeSystem' do |h|
  h.depend 'iek/time_system'
end

module IEK
  module TimeSystem
    class GametimeClock < Clock
      attr_accessor :ticks

      def init
        super
        @ticks = 0
      end

      def ticks_per_second
        20
      end

      def update
        @ticks += 1
        update_value
      end

      def update_value
        self.value = @ticks / ticks_per_second
      end
    end
  end
end
