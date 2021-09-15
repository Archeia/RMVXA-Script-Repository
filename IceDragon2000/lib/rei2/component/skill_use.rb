#
# EDOS/src/REI/component/skill_use.rb
#
module REI
  module Component
    class SkillUse

      extend REI::Mixin::REIComponent
      include Ygg4::Component

      def initialize
        init_component
      end

      rei_register :skill_use

    end
  end
end