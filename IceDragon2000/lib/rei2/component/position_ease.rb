#
# EDOS/src/REI/component/position_ease.rb
#
module REI
  module Component
    class PositionEase < StarRuby::Vector3F

      include Ygg4::Component
      extend REI::Mixin::REIComponent
      include REI::Mixin::EventClient

      attr_accessor :timemax
      attr_reader :time

      def initialize(*args)
        super(*args)
        init_component
        @src  = Vector3(0, 0, 0)
        @dst  = Vector3(0, 0, 0)
        @time = 0
        @timemax = 15
      end

      def init_post_setup
        listen(:motion)
      end

      def reset
        @time = @timemax
      end

      def recieve(event)
        new_pos, old_pos = event.params
        @src = old_pos
        @dst = new_pos
        reset
      end

      def update
        if @time >= 0
          set!(*Palila::Util.lerp(@src, @dst, 1.0 - @time / @timemax.to_f))
          @time -= 1
        end
        super
      end

      def busy?
        @time >= 0
      end

      dep :motion
      dep :event_server
      rei_register :position_ease

    end
  end
end