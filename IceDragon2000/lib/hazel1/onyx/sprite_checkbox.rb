class Hazel::Onyx::Sprite_Checkbox < Hazel::Onyx::Sprite_ButtonBase

  def refresh_bitmap
    super
    bmp = self.bitmap

    bmp.font.set_style('simple_black')

    color1, color2 = Palette['gray5'], Palette['gray17']
    DrawExt.draw_padded_rect_flat(bmp, bmp.rect, [color1, color2])

    state = @component.state
    case state
    when Hazel::Widget::Button::ON
      rect_check = bmp.rect.contract(anchor: 5, amount: 2)
      DrawExt.draw_gauge_ext_sp4(bmp, rect_check, 1.0, DrawExt::GREEN_BAR_COLORS)
    when Hazel::Widget::Button::OFF

    end
  end

end