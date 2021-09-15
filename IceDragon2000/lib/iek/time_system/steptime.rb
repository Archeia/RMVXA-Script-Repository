$simport.r 'iek/time_system/steptime', '1.0.0', 'Uses a steps counter clock for TimeSystem' do |h|
  h.depend 'iek/time_system'
end

module IEK
  module TimeSystem
    class SteptimeClock < Clock
      attr_accessor :steps

      def init
        super
        @steps = 0
      end

      def to_h
        super.merge(steps: @steps)
      end

      ##
      # @return [Numeric]
      def steps_per_second
        1
      end

      def update
        @steps += 1
        update_value
      end

      def update_value
        self.value = (@steps / steps_per_second).to_i
      end
    end
  end
end
