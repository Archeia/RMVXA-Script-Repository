#
# EDOS/src/REI/component/inventory.rb
#
module REI
  module Component
    class Inventory

      extend REI::Mixin::REIComponent
      include Ygg4::Component

      def initialize
        init_component
      end

      rei_register :inventory

    end
  end
end