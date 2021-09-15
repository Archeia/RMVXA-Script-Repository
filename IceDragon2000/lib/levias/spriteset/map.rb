#
# EDOS/src/levias/spriteset/map.rb
#   by IceDragon
#   dc 30/03/2013
#   dm 30/03/2013
# vr 1.0.0
module Levias
  module Spriteset
    class Map

      attr_reader :viewport1, :viewport2

      def initialize
        create_viewports
        @background = Sprite.new(@viewport1)
        @background.bitmap = Bitmap.new("Chapter 2/02")
      end

      def create_viewports
        @viewport1 = Viewport.new # Map, Characters
        @viewport2 = Viewport.new # Map Effects

        @viewport1.z = 0
        @viewport2.z = 50
      end

    end
  end
end
