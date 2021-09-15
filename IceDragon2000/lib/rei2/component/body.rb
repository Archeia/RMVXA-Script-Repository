#
# EDOS/src/REI/component/body.rb
#
module REI
  module Component
    class Body

      extend REI::Mixin::REIComponent
      include Ygg4::Component

      def initialize
        init_component
      end

      rei_register :body

    end
  end
end