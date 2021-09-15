#
# EDOS/src/REI/component/position.rb
#
module REI
  module Component
    class Position < StarRuby::Vector3F #Point

      extend REI::Mixin::REIComponent
      include Ygg4::Component

      def initialize(*args)
        super(*args)
        init_component
      end

      rei_register :position

    end
  end
end