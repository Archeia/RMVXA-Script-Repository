#
# EDOS/src/REI/component/size.rb
#
module REI
  module Component
    class Size < ::Size

      extend REI::Mixin::REIComponent
      include Ygg4::Component

      def initialize(*args)
        super(*args)
        init_component
      end

      rei_register :size

    end
  end
end