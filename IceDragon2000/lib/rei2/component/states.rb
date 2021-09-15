#
# EDOS/src/REI/component/states.rb
#
module REI
  module Component
    class States

      extend REI::Mixin::REIComponent
      include Ygg4::Component

      def initialize
        init_component
      end

      rei_register :states

    end
  end
end