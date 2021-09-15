module DrawExt
  ##
  # ::trapeze(Bitmap dst_bitmap, Vector2 vec1, Vector2 vec2, Bitmap src_bitmap, Rect src_rect)
  def self.trapeze(dst_bitmap, vec1, vec2, src_bitmap, src_rect)
    src_vec = Convert.Point2(vec1)
    dst_vec = Convert.Point2(vec2)
    rect = Convert.Rect(src_rect)
    ch = dst_vec - src_vec
    x, y = *src_vec
    if ch.x != 0 && ch.y != 0
      # trapeze horizontally and vertically
      sx, sy = src_rect.x, src_rect.y
      for ay in 0...src_rect.height
        adx = (ch.x * ay / src_rect.height.to_f).to_i
        for ax in 0...src_rect.width
          ady = (ch.y * ax / src_rect.width.to_f).to_i
          dst_bitmap.set_pixel(x + ax + adx, y + ay + ady,
                               src_bitmap.get_pixel(sx + ax, sy + ay))
        end
      end
    elsif ch.x != 0
      # trapeze horizontally
      for ay in 0...src_rect.height
        ax = (ch.x * ay / src_rect.height.to_f).to_i
        r = src_rect.dup
        r.y += ay
        r.height = 1
        dst_bitmap.blt(x + ax, y + ay, src_bitmap, r)
      end
    elsif ch.y != 0
      # trapeze vertically
      for ax in 0...src_rect.width
        ay = (ch.y * ax / src_rect.width.to_f).to_i
        r = src_rect.dup
        r.x += ax
        r.width = 1
        dst_bitmap.blt(x + ax, y + ay, src_bitmap, r)
      end
    else
      dst_bitmap.blt(x, y, src_bitmap, src_rect)
    end
  end

  def self.slant_bitmap(bitmap, src_rect,
                        vertical=false, slant_amount=nil, align=0, wrap=true)
    warn "DrawExt::slant_bitmap is deprecated, use DrawExt::trapeze instead"
    slant_amount ||= (vertical ? src_rect.width : src_rect.height)

    return if slant_amount <= 0

    if vertical
      tmp_bitmap = Bitmap.new(1, src_rect.height)
      m = src_rect.width
      for n in 0...m
        n2 = slant_amount * (n / m.to_f)
        case align
        #when 0 ;
        when 1 ; n2 = 0
        when 2 ; n2 = slant_amount - n2
        end

        sre = Rect.new(src_rect.x + n, src_rect.y, 1, src_rect.height)
        tmp_bitmap.blt(0, 0, bitmap, sre)
        bitmap.clear_rect(sre)

        if wrap
          blit_wrap(
            bitmap, sre, 0, n2, tmp_bitmap, tmp_bitmap.rect)
        else
          bitmap.blt(sre.x, sre.y + n2, tmp_bitmap, tmp_bitmap.rect)
        end

        tmp_bitmap.clear
      end
    else
      tmp_bitmap = Bitmap.new(src_rect.width, 1)
      m = src_rect.height

      for n in 0...m
        n2 = slant_amount * (n / m.to_f)
        case align
        #when 0 ;
        when 1 ; n2 = 0
        when 2 ; n2 = slant_amount - n2
        end

        sre = Rect.new(src_rect.x, src_rect.y + n, src_rect.width, 1)
        tmp_bitmap.blt(0, 0, bitmap, sre)
        bitmap.clear_rect(sre)

        if wrap
          blit_wrap(
            bitmap, sre, n2, 0, tmp_bitmap, tmp_bitmap.rect)
        else
          bitmap.blt(sre.x + n2, sre.y, tmp_bitmap, tmp_bitmap.rect)
        end

        tmp_bitmap.clear
      end
    end

    tmp_bitmap.dispose

    return nil
  end
end
