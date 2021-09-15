#
# EDOS/lib/drawext/core/gauge.rb
#   by IceDragon (mistdragon100@gmail.com)
#   dc 06/07/2013
#   dm 06/07/2013
# vr 1.0.0
module DrawExt
  def self.draw_highlight_flat(bitmap, rect, (color), vertical=false)
    return rect if rect.empty?

    if vertical
      bmp = Bitmap.new(rect.width / 2, rect.height)
      bmp.fill_rect(bmp.rect, color)
    else
      bmp = Bitmap.new(rect.width, rect.height / 2)
      bmp.fill_rect(bmp.rect, color)
    end

    bitmap.blt(rect.x, rect.y, bmp, bmp.rect)
    bmp.dispose

    return rect;
  end

  ##
  #
  # bool hvertical // Highlight Vertical?
  # bool gvertical // Gradient Vertical?
  def self.draw_highlight_gradient(bitmap, rect, (color1, color2),
                                   hvertical=false, gvertical=false)
    return rect if rect.empty?
    if hvertical
      bmp = Bitmap.new(rect.width / 2, rect.height)
      bmp.gradient_fill_rect(bmp.rect, color1, color2, gvertical)
    else
      bmp = Bitmap.new(rect.width, rect.height / 2)
      bmp.gradient_fill_rect(bmp.rect, color1, color2, gvertical)
    end

    bitmap.blt(rect.x, rect.y, bmp, bmp.rect)
    bmp.dispose

    return rect;
  end

  ##
  # Bitmap bitmap
  # Rect rect
  # Color color
  # float rate
  # bool vertical
  # int align
  #
  def self.draw_gauge_flat(bitmap, rect, rate, (color), vertical=false, align=0)
    nrect = calc_gauge_rect(rect, rate, vertical, align)

    return nrect if nrect.empty?

    bitmap.fill_rect(nrect, color)

    return nrect;
  end

  def self.draw_gauge_flat_highlight(bitmap, rect, rate,
                                     (color, hightlight_color),
                                     vertical=false, align=0)
    nrect = calc_gauge_rect(rect, rate, vertical, align)

    return nrect if nrect.empty?

    bitmap.fill_rect(nrect, color)

    draw_highlight_flat(bitmap, nrect, hightlight_color, vertical)

    return nrect;
  end

  def self.draw_gauge_padded_flat(bitmap, rect, rate,
                                  (border_color, content_color),
                                  vertical=false, align=0,
                                  padding=default_padding)

    nrect = calc_gauge_rect(rect, rate, vertical, align)
    draw_padded_rect_flat(bitmap, nrect, [border_color, content_color], padding)
    return nrect;
  end

  def self.draw_gauge_padded_flat_highlight(bitmap, rect, rate,
                                            (border_color, content_color,
                                            hightlight_color),
                                            vertical=false, align=0,
                                            padding=default_padding)

    nrect = calc_gauge_rect(rect, rate, vertical, align)

    return nrect if nrect.empty?

    draw_padded_rect_flat(bitmap, nrect, border_color, content_color, padding)

    draw_highlight_flat(bitmap, nrect, hightlight_color, vertical)

    return nrect;
  end

  def self.draw_gauge_specia1(bitmap, rect, rate,
                              (padding_color1, padding_color2,
                              content_color1, content_color2,
                              highlight_color),
                              vertical=false, align=0, padding=default_padding)
    nrect = calc_gauge_rect(rect, rate, vertical, align)

    return nrect if nrect.empty?

    bmp = Bitmap.new(nrect.width, nrect.height)

    rect_content = padding.calc_surface(bmp.rect)
    highlight_rect = bmp.rect.dup

    bmp.gradient_fill_rect(
      bmp.rect, padding_color1, padding_color2, !vertical)

    bmp.clear_rect(rect_content)

    bmp.gradient_fill_rect(
      rect_content, content_color1, content_color2, !vertical)

    draw_highlight_flat(bmp, highlight_rect, highlight_color, vertical)

    bitmap.blt(nrect.x, nrect.y, bmp, bmp.rect)

    bmp.dispose

    return nrect;
  end

  def self.draw_gauge_specia2(bitmap, rect, rate,
                              (padding_color1, padding_color2,
                              content_color1, content_color2,
                              highlight_color),
                              vertical=false, align=0, padding=default_padding)

    nrect = calc_gauge_rect(rect, rate, vertical, align)

    return nrect if nrect.empty?

    bmp = Bitmap.new(nrect.width, nrect.height)

    rect_content = padding.calc_surface(bmp.rect)

    if vertical
      padding_rect1 = Rect.new(0, 0, nrect.width / 2, nrect.height)
      padding_rect2 = padding_rect1.dup
      padding_rect2.x += padding_rect2.width

      content_rect1 = rect_content.dup
      content_rect1.width = content_rect1.width / 2
      content_rect2 = content_rect1.dup
      content_rect2.x += content_rect2.width
    else
      padding_rect1 = Rect.new(0, 0, nrect.width, nrect.height / 2)
      padding_rect2 = padding_rect1.dup
      padding_rect2.y += padding_rect2.height

      content_rect1 = rect_content.dup
      content_rect1.height = content_rect1.height / 2
      content_rect2 = content_rect1.dup
      content_rect2.y += content_rect2.height
    end
    highlight_rect = bmp.rect.dup

    bmp.gradient_fill_rect(padding_rect1, padding_color1, padding_color2,
                           !vertical)
    bmp.gradient_fill_rect(padding_rect2, padding_color2, padding_color1,
                           !vertical)
    bmp.clear_rect(rect_content)
    bmp.gradient_fill_rect(content_rect1, content_color1, content_color2,
                           !vertical)
    bmp.gradient_fill_rect(content_rect2, content_color2, content_color1,
                           !vertical)
    draw_highlight_flat(bmp, highlight_rect, highlight_color, vertical)

    bitmap.blt(nrect.x, nrect.y, bmp, bmp.rect)

    bmp.dispose

    return nrect;
  end

  def self.draw_gauge_specia3(bitmap, rect, rate,
                              colors,
                              vertical=false, align=0, padding=default_padding)
    nrect = calc_gauge_rect(rect, rate, vertical, align)

    return nrect if nrect.empty?

    bmp = Bitmap.new(nrect.width, nrect.height)

    sz = colors.size
    if vertical
      enum = Enumerator.new do |yielder|
        sz.times { |i| wd = bmp.width / sz
          yielder.yield Rect.new(wd * i, 0, wd, bmp.height) }
      end
    else
      enum = Enumerator.new do |yielder|
        sz.times { |i| hg = bmp.height / sz
          yielder.yield Rect.new(0, hg * i, bmp.width, hg) }
      end
    end

    colors.each do |c|
      rect = enum.next
      bmp.fill_rect(rect, c)
    end

    bitmap.blt(nrect.x, nrect.y, bmp, bmp.rect)
    bmp.dispose

    return nrect;
  end
end
