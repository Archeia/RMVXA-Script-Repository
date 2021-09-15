#
# EDOS/src/levias/panel/lp.rb
#   by IceDragon
#   dc 30/03/2013
#   dm 30/03/2013
# vr 1.0.0
module Levias
  class Panel
    class LP < Panel

      def refresh_background
        rect = background_rect
        bitmap = @background.bitmap
          bitmap.clear
          bitmap.fill_rect(rect, Palette['black-half'])
      end

      def refresh_content
        rect             = content_rect
        text_rect        = rect.dup
          text_rect.height = 12
        num_rect         = text_rect.dup
          num_rect.y2      = content_rect.y2
        gauge_rect       = text_rect.dup
          gauge_rect.y     = text_rect.y2

        div_color = Palette['black']
        gauge_colors = DrawExt.quick_bar_colors(Palette['droid_light_ui_enb'])

        rule_divs = { (gauge_rect.width/16) => {a: 1, r: 1.0, c: div_color} }

        bitmap = @content.bitmap
          bitmap.clear
          font = bitmap.font
            font.size = Metric.ui_font_size(:small)
          bitmap.draw_text(text_rect, Vocab::LP, 0)
          bitmap.draw_text(num_rect, "8", 2)
          bitmap.draw_gauge_ext(gauge_rect, 0.5, gauge_colors)
          DrawExt.draw_ruler(bitmap, gauge_rect, rule_divs, false, 0)
      end

    end
  end
end
