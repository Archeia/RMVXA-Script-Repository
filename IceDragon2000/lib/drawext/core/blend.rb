#
# src/modules/drawext/blend.rb
# vr 1.00
module DrawExt
  def self.blend_with_color(bitmap, trg_rect, color, &blend)
    for y in trg_rect.y...trg_rect.y2
      for x in trg_rect.x...trg_rect.x2
        src_color = bitmap.get_pixel(x, y)
        trg_color = blend.(src_color, color)
        bitmap.set_pixel(x, y, trg_color)
      end
    end

    return self
  end

  def self.blend_with_bitmap(bitmap, tx, ty, src_rect, src_bitmap, &blend)
    for y in src_rect.y...src_rect.y2
      for x in src_rect.x...src_rect.x2
        dx, dy = tx + (x - src_rect.x) , ty + (y - src_rect.y)
        src_color = bitmap.get_pixel(dx, dy)
        trg_color = src_bitmap.get_pixel(x, y)
        res_color = blend.(src_color, trg_color)
        bitmap.set_pixel(dx, dy, res_color)
      end
    end

    return self
  end
end
