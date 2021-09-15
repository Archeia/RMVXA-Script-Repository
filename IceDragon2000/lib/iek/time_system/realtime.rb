$simport.r 'iek/time_system/realtime', '1.0.0', 'Uses system clock for TimeSystem' do |h|
  h.depend 'iek/time_system'
end

module IEK
  module TimeSystem
    class RealtimeClock < Clock
      def update
        update_value
      end

      def update_value
        self.value = Time.now.to_i
      end
    end
  end
end
