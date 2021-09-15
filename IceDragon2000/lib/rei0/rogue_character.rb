# Mixin::RogueCharacter
# // 01/20/2012
# // 01/20/2012
module REI
  module Mixin
    module RogueCharacter
      def character_hue
        0
      end

      def sprite_effect_type
        nil
      end

      def set_sprite_effect_type(n)
        #
      end

      def alive?
        return true
      end

      def dead?
        return false
      end

      def hidden?
        return false
      end
    end
  end
end
