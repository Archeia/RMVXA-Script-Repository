#
# EDOS/lib/drawext/core/padded_rect.rb
#   by IceDragon
module DrawExt
  @@default_padding = nil

  def self.default_padding
    return @@default_padding ||= Hazel::Padding.new(1, 1, 1, 1).freeze
  end

  FILL_TYPE = :flat

  ##
  #
  # Bitmap bitmap
  # Rect rect
  # Color color1 // Padding
  # Color color2 // Content
  # Hazel::Padding padding
  def self.draw_padded_rect_flat(bitmap, rect, (color1, color2),
                                 padding=default_padding)
    rect2 = padding.calc_surface(rect)
    bitmap.merio.draw_fill_rect(rect, color1, FILL_TYPE)
    bitmap.merio.draw_fill_rect(rect2, color2, FILL_TYPE)
    return self;
  end

  def self.draw_padded_rect_flat_multi(bitmap, rect,
                                      ((bcol_left, bcol_top, bcol_right, bcol_bottom),
                                      color2), padding=default_padding)
    rect2 = padding.calc_surface(rect)

    bcol_tl = calc_normalize_colors(bcol_left, bcol_top)
    bcol_tr = calc_normalize_colors(bcol_right, bcol_top)
    bcol_bl = calc_normalize_colors(bcol_left, bcol_bottom)
    bcol_br = calc_normalize_colors(bcol_right, bcol_bottom)

    br1 = Rect.new(rect.x, rect.y, padding.left, padding.top)
    br2 = Rect.new(rect.x2 - padding.right, rect.y, padding.right, padding.top)
    br3 = Rect.new(rect.x, rect.y2 - padding.bottom, padding.left, padding.bottom)
    br4 = Rect.new(rect.x2 - padding.right, rect.y2 - padding.bottom,
                   padding.right, padding.bottom)

    bitmap.fill_rect(br1, bcol_tl)
    bitmap.fill_rect(br2, bcol_tr)
    bitmap.fill_rect(br3, bcol_bl)
    bitmap.fill_rect(br4, bcol_br)

    br_top = br1.dup
    br_top.x = br1.x2
    br_top.width = rect.width - br1.width - br2.width

    br_left = br1.dup
    br_left.y = br1.y2
    br_left.height = rect.height - br1.height - br3.height

    br_right = br2.dup
    br_right.y = br2.y2
    br_right.height = rect.height - br2.height - br4.height

    br_bottom = br3.dup
    br_bottom.x = br3.x2
    br_bottom.width = rect.width - br3.width - br4.width

    bitmap.fill_rect(br_left, bcol_left)
    bitmap.fill_rect(br_top, bcol_top)
    bitmap.fill_rect(br_right, bcol_right)
    bitmap.fill_rect(br_bottom, bcol_bottom)

    bitmap.fill_rect(rect2, color2)

    return self;
  end

  ##
  #
  # Color padding_color1, padding_color2 // Padding
  # Color content_color1, content_color2 // Content
  # Hazel::Padding padding
  def self.draw_padded_rect_gradient(bitmap, rect,
                                    (padding_color1, padding_color2,
                                    content_color1, content_color2),
                                    vertical=false, padding=default_padding)
    rect2 = padding.calc_surface(rect)

    bitmap.gradient_fill_rect(rect, padding_color1, padding_color2, vertical)
    bitmap.clear_rect(rect2)
    bitmap.gradient_fill_rect(rect2, content_color1, content_color2, vertical)

    return self;
  end
end
