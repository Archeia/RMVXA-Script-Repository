#
# EDOS/lib/hazel2/widget.rb
#   by IceDragon
#
module Hazel
  module Widget
    module MHandler
      def init_handler
        @handler = {}
      end

      def set_handler(key, meth = nil, &func)
        @handler[key] = meth || func
        return self
      end

      def remove_handler(key)
        return @handler.delete(key)
      end

      def handle?(key)
        return @handler.has_key?(key)
      end

      def call_handler(key, *args)
        @handler[key].call(*args) if handle?(key)
      end
    end
  end

  class Event
    ##
    # instance attributes
    attr_accessor :type
    attr_accessor :subtype
    attr_accessor :params

    def initialize(type, subtype, *params)
      @type = type
      @subtype = subtype
      @params = params
    end
  end

  class EventHandler
    include Widget::MHandler

    def initialize
      init_handler
    end

    def handle_event(event)
      call_handler([event.type, event.subtype], event)
      call_handler(event.type, event)
    end
  end

  module Widget
    module HostBase
      attr_reader :widgets

      ##
      # init_widgets
      def init_widgets
        @widgets = []
        @widget_spriteset = Hazel::Spriteset::Widget.new(viewport, @widgets)
        @shell_callback.add(:x=) do
          @widgets.each { |widget| widget.refresh_position(:x) }
        end
        @shell_callback.add(:y=) do
          @widgets.each { |widget| widget.refresh_position(:y) }
        end
        @shell_callback.add(:z=) do
          @widgets.each { |widget| widget.refresh_position(:z) }
        end
      end

      ##
      # dispose_widgets
      def dispose_widgets
        for obj in @widgets
          obj.dispose
        end
        @widgets = nil
        @widget_spriteset.dispose
      end

      def refresh_widgets
        @widget_spriteset.refresh
      end

      ##
      # update_widgets
      def update_widgets
        for obj in @widgets
          obj.update
        end
        @widget_spriteset.update
      end

      ##
      # add_widget(Class* obj)
      def add_widget(klass)
        obj = klass.new(self)
        @widgets.push(obj)
        @widget_spriteset.add_widget(obj)
        return obj
      end

      ##
      # remove_widget(Object* obj)
      def remove_widget(obj)
        @widget_spriteset.remove_widget(obj)
        @widgets.delete(obj)
        return obj
      end

      def widgets_handle_event(event)
        @widgets.each_with_object(event, &:handle_event)
      end

      def widget_x
        self.x
      end

      def widget_y
        self.y
      end

      def widget_z
        self.z + 2
      end
    end
  end
end

require 'hazel2/widget/base'
require 'hazel2/widget/button'
