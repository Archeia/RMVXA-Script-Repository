#
# EDOS/src/REI/component/equipment.rb
#
module REI
  module Component
    class Equipment

      extend REI::Mixin::REIComponent
      include Ygg4::Component

      def initialize
        init_component
      end

      rei_register :equipment

    end
  end
end