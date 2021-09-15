#
# EDOS/src/REI/component/item_use.rb
#
module REI
  module Component
    class ItemUse

      extend REI::Mixin::REIComponent
      include Ygg4::Component

      def initialize
        init_component
      end

      rei_register :item_use

    end
  end
end