#
# EDOS/src/REI/component/effect.rb
#
module REI
  module Component
    class Effect

      extend REI::Mixin::REIComponent
      include Ygg4::Component

      def initialize
        init_component
      end

      rei_register :effect

    end
  end
end