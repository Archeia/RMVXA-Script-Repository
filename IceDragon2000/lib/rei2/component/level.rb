#
# EDOS/src/REI/component/exp.rb
#
module REI
  module Component
    class Exp

      extend REI::Mixin::REIComponent
      include Ygg4::Component

      attr_reader :level
      attr_reader :exp

      def initialize
        init_component
        @level = 1
        @exp = 0
      end

      def next_level_exp
        0
      end

      def current_level_exp
        0
      end

      rei_register :level

    end
  end
end