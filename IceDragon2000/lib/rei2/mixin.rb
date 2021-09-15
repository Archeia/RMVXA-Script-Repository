#
# EDOS/src/REI/mixin.rb
#   by IceDragon
#   dc 19/05/2013
#   dm 19/05/2013
# vr 1.0.0
module REI
  module Mixin
    module REIComponent

      @@component = {}

      def rei_register(name)
        if klass = @@component[name]
          raise ArgumentError, "#{self} cannot be registered. #{name} was registered as #{klass}"
        end
        @@component[name] = self
        type name # Ygg4::Component
      end

      def self.[](name)
        @@component.fetch(name)
      end

    end
    ##
    # Allows the Component to register for event sends
    module EventClient

      def listen(type)
        evs = comp(:event_server)
        evs.add_listener(self, type)
      end

      def recieve(event)
        raise RuntimeError, "abstract method #recieve called for #{self}"
      end

    end
    ##
    # REI::Mixin::UnitHost
    #   Used for windows, shells, and any other class which can have a unit
    #   as an attribute
    module UnitHost

      def unit
        @unit
      end

      def entity
        @unit.entity
      end

      def set_unit(new_unit)
        if @unit != new_unit
          @unit = new_unit
          on_unit_change
        end
        self
      end

      def unit=(new_unit)
        @unit = new_unit
      end

      def on_unit_change
        # overwrite in subclass
      end

    end
  end
end
