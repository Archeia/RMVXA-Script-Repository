class Hazel::Onyx::Sprite_Button < Hazel::Onyx::Sprite_ButtonBase

  def refresh_bitmap
    super
    bmp = self.bitmap

    bmp.font.set_style('simple_black')

    state = @component.state
    case state
    when Hazel::Widget::Button::ON
      color1, color2 = Palette['gray5'], Palette['gray17']
      bmp.font.color = Palette['gray10']
      bmp.font.out_color = Palette['gray17']
    when Hazel::Widget::Button::OFF
      color1, color2 = Palette['gray17'], Palette['gray5']
      bmp.font.color = Palette['gray17']
      bmp.font.out_color = Palette['gray1']
    end

    DrawExt.draw_padded_rect_flat(bmp, bmp.rect, [color1, color2])
    rect = bmp.rect
    str = @component.label
    if icon = @component.icon
      y = (self.height - icon.height) / 2
      x = str.empty? ? (self.width - icon.width) / 2 : 0
      DrawExt.draw_onyx_icon(bmp, icon, x, y)
      rect.x += icon.width
    end
    if (!str.empty?)
      bmp.draw_text(bmp.rect, str, MACL::Surface::ALIGN_CENTER)
    end
  end

end