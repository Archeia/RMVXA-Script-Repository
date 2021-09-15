#
# EDOS/src/REI/component/actions.rb
#
module REI
  module Component
    class Actions

      extend REI::Mixin::REIComponent
      include Ygg4::Component

      def initialize
        init_component
      end

      rei_register :actions

    end
  end
end