class Hazel::Onyx::Sprite_Panel < Hazel::Onyx::Sprite_ComponentBase

  def dispose
    self.bitmap.dispose if self.bitmap && !self.bitmap.disposed?
    super
  end

  def refresh_bitmap
    super
    bmp = self.bitmap
    bmp.font.set_style('simple_black')

    color1, color2 = Palette['gray17'], Palette['gray5']
    DrawExt.draw_padded_rect_flat(bmp, bmp.rect, [color1, color2])

    if @component.properties[:use_header]
      rect = bmp.rect.dup
      rect.height = @component.properties[:header_height]

      color2 = Color.rgb24(0x418BD4)
      DrawExt.draw_padded_rect_flat(
        bmp, rect, [color1, color2], Hazel::Padding.new(1, 1, 1, 0))

      rect.contract!(anchor: MACL::Surface::ANCHOR_CENTER, amount: 8)
      bmp.draw_text(rect, @component.label)
    end
  end

end