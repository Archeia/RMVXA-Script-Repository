module DrawExt
  class DivError < Exception
  end

  def self.blit_wrap(bitmap, dest_rect, x, y, src_bitmap, src_rect, opcity=255)
    p1 = Point2.new(dest_rect.x + x, dest_rect.y + y)
    p2 = Point2.new(dest_rect.x, dest_rect.y + y)
    p3 = Point2.new(dest_rect.x + x, dest_rect.y)
    p4 = Point2.new(dest_rect.x, dest_rect.y)

    src_rect1 = src_rect.dup
    src_rect1.width -= x
    src_rect1.height -= y

    src_rect2 = src_rect.dup
    src_rect2.x += dest_rect.x2 - x
    src_rect2.width = x
    src_rect2.height -= y

    src_rect3 = src_rect.dup
    src_rect3.y += dest_rect.y2 - y
    src_rect3.width -= x
    src_rect3.height = y

    src_rect4 = src_rect.dup
    src_rect4.x += dest_rect.x2 - x
    src_rect4.y += dest_rect.y2 - y
    src_rect4.width = x
    src_rect4.height = y

    bitmap.blt(p1.x, p1.y, src_bitmap, src_rect1, opcity)
    bitmap.blt(p2.x, p2.y, src_bitmap, src_rect2, opcity)
    bitmap.blt(p3.x, p3.y, src_bitmap, src_rect3, opcity)
    bitmap.blt(p4.x, p4.y, src_bitmap, src_rect4, opcity)

    return self
  end

  def self.calc_div(i, div_keys)
    div_keys.each do |k|
      d = i % k
      return k if d == 0
    end
    return nil
  end

  def self.draw_ruler(bitmap, rect, divs, vertical=false, align=0)
    div_keys = divs.keys.sort.reverse

    raise(DivError, "Division keys cannot include 0") if div_keys.include?(0)

    enum = Enumerator.new do |yielder|
      if vertical
        orr = Rect.new(rect.x, rect.y, 0, 1)
        cap = rect.height
        getter_l = :width
        setter_l = :width=

        getter_x = :y
        setter_x = :y=
        getter_y = :x
        setter_y = :x=
      else
        orr = Rect.new(rect.x, rect.y, 1, 0)
        cap = rect.width
        getter_l = :height
        setter_l = :height=

        getter_x = :x
        setter_x = :x=
        getter_y = :y
        setter_y = :y=
      end

      rr = orr.dup

      0.upto(cap) do |i|
        dv = calc_div(i, div_keys)
        divh = divs[dv]
        if divh
          if divh[:r] && !divh[:l]
            rr.send(setter_l, rect.send(getter_l) * divh[:r])
          else
            rr.send(setter_l, divh[:l])
          end

          org_y = rect.send(getter_y)
          org_l = rect.send(getter_l)
          cur_l = rr.send(getter_l)

          case divh[:a] || align
          when 0
            rr.send(setter_y, org_y)
          when 1
            rr.send(setter_y, org_y + ((org_l - cur_l) / 2))
          when 2
            rr.send(setter_y, org_y + (org_l - cur_l))
          end

          yielder.yield rr, divh[:c]
        end
        rr.send(setter_x, rr.send(getter_x) + 1)
      end
    end

    enum.each do |rct, col|
      bitmap.blend_fill_rect(rct, col)
    end
  end
end
