#
# EDOS/lib/hazel2/widget/base.rb
#   by IceDragon
module Hazel
  module Widget
    class Base
      include MACL::Mixin::Callback
      include MACL::Mixin::Surface2
      include Hazel::Widget::MHandler
      include Mixin::IDisposable
      include Mixin::SpaceBoxBody      # May not function correctly

      attr_reader :parent
      attr_accessor :rel
      attr_accessor :size
      attr_accessor :need_refresh
      attr_accessor :x
      attr_accessor :y
      attr_accessor :z

      def initialize(parent)
        @parent = parent
        @rel    = Vector3(0, 0, 0)
        @size   = Size3(1, 1, 1)
        @need_refresh = false
        init_handler
        init
        refresh_position
      end

      def type
        :base
      end

      def label
        ""
      end

      def tooltip
        ""
      end

      def rel_x
        @rel.x
      end

      def rel_y
        @rel.y
      end

      def rel_z
        @rel.z
      end

      def rel_x=(n)
        @rel.x = n
      end

      def rel_y=(n)
        @rel.y = n
      end

      def rel_z=(n)
        @rel.z = n
      end

      def width
        @size.width
      end

      def height
        @size.height
      end

      def depth
        @size.depth
      end

      def width=(n)
        @size.width = n
      end

      def height=(n)
        @size.height = n
      end

      def depth=(n)
        @size.depth = n
      end

      def init
        #
      end

      def disposed?
        return !!@disposed
      end

      def dispose
        @disposed = true
      end

      def refresh_position(*syms)
        syms = [:x, :y, :z] if syms.empty?
        syms.each do |sym|
          case sym
          when :x then self.x = (@parent ? @parent.widget_x : 0) + rel_x
          when :y then self.y = (@parent ? @parent.widget_y : 0) + rel_y
          when :z then self.z = (@parent ? @parent.widget_z : 0) + rel_z
          end
        end
        self
      end

      def update
        #
      end

      def refresh
        @need_refresh = true
      end

      def handle_event(event)
        if event.type == :mouse
          mx, my = *event.params[0]
          if contains?(mx, my)
            EDOS.server.send_data(EDOS::CHANNEL_EDOS_TOOL, tooltip)
          end
        end
      end
    end
  end
end
