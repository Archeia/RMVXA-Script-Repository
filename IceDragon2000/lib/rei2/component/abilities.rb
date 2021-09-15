#
# EDOS/src/REI/component/abilities.rb
#
module REI
  module Component
    class Abilities

      extend REI::Mixin::REIComponent
      include Ygg4::Component

      def initialize
        init_component
      end

      rei_register :abilities

    end
  end
end