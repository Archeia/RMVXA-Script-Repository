#
# EDOS/src/levias/spriteset/ui.rb
#   by IceDragon
#   dc 30/03/2013
#   dm 30/03/2013
# vr 1.0.0
module Levias
  module Spriteset
    class UI

      attr_reader :viewport1

      def initialize
        @viewport1 = Viewport.new
        @viewport1.z = 100

        @minimap = Panel::Minimap.new(112, 48)
        @lp_panel = Panel::LP.new(112, 48)

        @state = Sprite.new
        @state.bitmap = Bitmap.new(Graphics.width / 3, 40)
        @state.align_to!(anchor: 3)
        @state.vec.y -= 24

        @flash_help = Sprite.new
        @flash_help.bitmap = Bitmap.new(@state.bitmap.width, 20)
        @flash_help.x = @state.x
        @flash_help.y = @state.y2
        @flash_help.opacity = 0

        @frames = 0

        refresh
      end

      def dispose

      end

      def update
        @flash_help.opacity = (@frames % 120).wall(60) / 60.0 * 255
        @frames += 1
      end

      def refresh
        state_s = MapManager.state == :move ? "MOVE" : "LOOK"
        help_s = MapManager.state == :move ? "A Button to look" : "A Button to move"

        bitmap = @state.bitmap
          bitmap.clear
          font = bitmap.font
            font.size = 40
            font.outline = true
          bitmap.draw_text(@state.bitmap.rect, state_s, 2)

        bitmap = @flash_help.bitmap
          bitmap.clear
          font = bitmap.font
            font.size = 20
            font.outline = true
          bitmap.draw_text(@flash_help.bitmap.rect, help_s, 1)

        if MapManager.state == :move
          @lp_panel.hide
          @minimap.show
        else
          @lp_panel.show
          @minimap.hide
        end
      end

    end
  end
end
