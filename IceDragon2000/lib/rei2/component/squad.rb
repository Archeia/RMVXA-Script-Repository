#
# EDOS/src/REI/component/squad.rb
#
module REI
  module Component
    class Squad

      extend REI::Mixin::REIComponent
      include Ygg4::Component

      def initialize
        init_component
      end

      rei_register :squad

    end
  end
end