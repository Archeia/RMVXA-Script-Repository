#
# EDOS/src/REI/mixin.rb
#   by IceDragon
#   dc 19/05/2013
#   dm 19/05/2013
# vr 1.0.0
module REI
  module Mixin
    ##
    # Mixin::UnitHost
    #   Used for windows, shells, and any other class which can have a unit
    #   as an attribute
    module UnitHost

      def unit
        @unit
      end

      def entity
        @unit.entity
      end

      def character
        @unit.character
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
