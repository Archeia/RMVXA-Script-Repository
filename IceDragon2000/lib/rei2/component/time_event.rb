#
# EDOS/src/REI/component/time_event.rb
#
module REI
  module Component
    class TimeEvent

      extend REI::Mixin::REIComponent
      include Ygg4::Component

      def initialize
        init_component
      end

      dep :wt
      rei_register :time_event

    end
  end
end