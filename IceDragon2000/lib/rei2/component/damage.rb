#
# EDOS/src/REI/component/damage.rb
#
module REI
  module Component
    class Damage

      extend REI::Mixin::REIComponent
      include Ygg4::Component

      def initialize
        init_component
      end

      opt :health
      opt :mana
      rei_register :damage

    end
  end
end