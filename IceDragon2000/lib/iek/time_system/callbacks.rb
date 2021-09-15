$simport.r 'iek/time_system/save', '1.0.0', 'Provides a callback API for the TimeSystem::Clock' do |h|
  h.depend 'iek/time_system', '>= 1.0.0'
  h.depend! 'iek/callbacks', '>= 1.0.0'
end

module IEK
  module TimeSystem
    class Clock
      include Mixin::Callback

      def value=(value)
        @value = value
        try_callback(:value_changed, self)
      end
    end
  end
end
