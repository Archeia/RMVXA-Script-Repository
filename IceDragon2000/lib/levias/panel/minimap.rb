#
# EDOS/src/levias/panel/minimap.rb
#   by IceDragon
#   dc 30/03/2013
#   dm 30/03/2013
# vr 1.0.0
module Levias
  class Panel
    class Minimap < Panel

      def refresh_background
        rect = background_rect
        bitmap = @background.bitmap
          bitmap.clear
          bitmap.fill_rect(rect, Palette['black-half'])
      end

      def refresh_content
        bitmap    = @content.bitmap
        font      = bitmap.font
        back_rect = bitmap.rect
        text_rect = back_rect.contract(anchor: 5, amount: Metric.contract)
          text_rect.height = 16
        font.size = Metric.ui_font_size(:small)
        bitmap.draw_text(text_rect, "Map")
      end

    end
  end
end
