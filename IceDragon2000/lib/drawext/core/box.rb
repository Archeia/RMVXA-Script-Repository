module DrawExt
  def self.draw_box1(bitmap, rect, (border_color, base_color), padding = 1)
    draw_padded_rect_flat(bitmap, rect,
                          [border_color, base_color],
                          Hazel::Padding.new(*([padding] * 4)))
    return self
  end

  ##
  #
  # Bitmap bitmap
  # Rect rect
  # Color border_colors[]
  # Color base_color
  # int paddings[4] { left, top, right, bottom }
  def self.draw_box2(bitmap, rect, (border_colors, base_color), paddings=[1, 1, 1, 1])
    padding = Hazel::Padding.new(*paddings)
    padding.bottom = 0
    draw_padded_rect_flat_multi(bitmap, rect, [border_colors, base_color],
                                padding)
    return self
  end
end
