$simport.r 'iek/time_system/save', '1.0.0', 'Uses step counter clock for TimeSystem' do |h|
  h.depend 'iek/time_system', '>= 1.0.0'
  h.depend! 'iek/savable', '>= 1.0.0'
end

module IEK
  module TimeSystem
    class Clock
      include Mixin::Savable

      def write_save_contents(contents)
        contents[:time] = to_h
      end

      def read_save_contents(contents)
        import contents[:time] if contents.key?(:time)
      end
    end
  end
end
