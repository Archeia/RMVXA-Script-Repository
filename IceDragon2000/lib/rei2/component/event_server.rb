#
# EDOS/src/REI/component/event_server.rb
#
module REI
  module Component
    class EventServer

      extend REI::Mixin::REIComponent
      include Ygg4::Component

      class Event

        @@event_id = 0

        attr_accessor :type
        attr_accessor :subtype
        attr_accessor :params

        def initialize(type, subtype, params)
          @type, @subtype, @params = type, subtype, params
          @id = @@event_id += 1
        end

      end

      attr_reader :events

      def initialize
        init_component
        @events = []
        @listeners = {}
      end

      def events?
        !@events.empty?
      end

      def add(type, sub, *params)
        @events << Event.new(type, sub, params)
      end

      def add_listener(client, type)
        (@listeners[type] ||= []) << client
      end

      def pull
        @events.shift
      end

      def dispatch
        @events.each do |ev|
          if list = @listeners[ev.type]
            list.each do |client|
              client.recieve(ev)
            end
          end
        end
        @events.clear
      end

      def update
        dispatch if events?
      end

      rei_register :event_server

    end
  end
end