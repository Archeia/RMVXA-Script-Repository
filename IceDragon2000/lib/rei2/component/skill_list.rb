#
# EDOS/src/REI/component/skill_list.rb
#
module REI
  module Component
    class SkillList

      extend REI::Mixin::REIComponent
      include Ygg4::Component

      def initialize
        init_component
      end

      rei_register :skill_list

    end
  end
end