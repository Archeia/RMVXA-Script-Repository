$simport.r 'iek/time_system', '1.0.0', 'Basic TimeSystem'

module IEK
  module TimeSystem
    class Clock
      attr_reader :value

      def initialize
        @value = 0
        init
      end

      def init
        #
      end

      def value=(value)
        @value = value
      end

      def to_h
        {
          time: @value
        }
      end

      def import(hash)
        #
      end

      def update
        #
      end

      def sec_abs
        @value
      end

      def min_abs
        @value / 60
      end

      def hour_abs
        @value / 3600
      end

      def day_abs
        @value / 86400
      end

      def week_abs
        @value / 604800
      end

      def month_abs
        @value / 2592000
      end

      def year_abs
        @value / 31536000
      end

      def sec
        sec_abs % 60
      end

      def min
        min_abs % 60
      end

      def hour
        hour_abs % 24
      end

      def day
        day_abs % 30
      end

      def week
        week_abs % 4
      end

      def month
        month_abs % 12
      end

      def year
        year_abs
      end

      private :init
    end
  end
end
