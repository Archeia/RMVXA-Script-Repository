#
# EDOS/src/REI/component/character.rb
#
module REI
  module Component
    class Character

      ##
      attr_accessor :face_name
      attr_accessor :face_index
      attr_accessor :face_hue
      ##
      attr_accessor :character_name
      attr_accessor :character_index
      attr_accessor :character_hue
      ##
      attr_accessor :portrait_name
      attr_accessor :portrait_hue

      extend REI::Mixin::REIComponent
      include Ygg4::Component

      def initialize
        init_component
        @face_name       = ''
        @face_index      = 0
        @face_hue        = 0
        @character_name  = ''
        @character_index = 0
        @character_hue   = 0
        @portrait_name   = ''
        @portrait_hue    = 0
      end

      def screen_x
        comp(:position_ease).x * 32
      end

      def screen_y
        comp(:position_ease).y * 32
      end

      def screen_z
        comp(:position_ease).z
      end

      dep :position_ease
      dep :size
      #dep :screen_position

      rei_register :character

    end
  end
end