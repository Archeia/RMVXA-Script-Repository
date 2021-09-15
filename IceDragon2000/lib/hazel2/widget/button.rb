#
# EDOS/lib/hazel2/widget/button.rb
#   by IceDragon
module Hazel
  module Widget
    class Button < Base
      def type
        :button
      end

      def init
        #
        super
      end

      def update
        #
        super
      end

      def handle_event(event)
        return unless event.type == :mouse
        case event.subtype
        when :l_click
          call_handler(:l_click)
        when :m_click
          call_handler(:m_click)
        when :r_click
          call_handler(:r_click)
        when :move
          call_handler(:move)
        end
        super(event)
      end
    end
  end
end
