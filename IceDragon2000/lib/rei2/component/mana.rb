#
# EDOS/src/REI/component/mana.rb
#
module REI
  module Component
    class Mana

      extend REI::Mixin::REIComponent
      include Ygg4::Component
      include Ygg4::Gaugable

      def initialize
        init_component
        init_gauge
      end

      def update
        update_gauge
        super
      end

      opt :event_server
      rei_register :mana

    end
  end
end