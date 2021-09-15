#
# artist/drawext/core/repeat.rb
#   by IceDragon
# vr 2.00
#
module DrawExt
  ##
  # repeat_bmp(Bitmap trg_bitmap, Rect trg_rect, Bitmap src_bitmap, Rect src_rect)
  def self.repeat_bmp(trg_bitmap, trg_rect, src_bitmap, src_rect)
    vx, vy = trg_rect.x, trg_rect.y
    sx, sy, w, h = src_rect.to_a

    xloop, xrem = trg_rect.width.divmod(w)
    yloop, yrem = trg_rect.height.divmod(h)

    #src_rect = Rect.new(sx, sy, w, h)
    for dy in 0...yloop
      for dx in 0...xloop
        x, y = vx + (dx * w), vy + (dy * h)
        trg_bitmap.blt(x, y, src_bitmap, src_rect)
      end
    end

    if xrem > 0
      src_rect = Rect.new(sx, sy, xrem, h)
      for dy in 0...yloop
        x, y = vx + (xloop * w), vy + (dy * h)
        trg_bitmap.blt(x, y, src_bitmap, src_rect)
      end
    end

    if yrem > 0
      src_rect = Rect.new(sx, sy, w, yrem)
      for dx in 0...xloop
        x, y = vx + (dx * w), vy + (yloop * h)
        trg_bitmap.blt(x, y, src_bitmap, src_rect)
      end
    end

    # End Tail
    if xrem > 0 && yrem > 0
      src_rect = Rect.new(sx, sy, xrem, yrem)
      x, y = vx + (xloop * w), vy + (yloop * h)
      trg_bitmap.blt(x, y, src_bitmap, src_rect)
    end

    return true
  end

  ##
  # repeat_bitmap_multi_seg
  #   mode
  #     0 - Border Style [All src_rects used]
  #     1 - Horizontal Only [4, 5, 6 used]
  #     2 - Vertical Only [8, 5, 2 used]
  #     3 - Corners Only [1, 3, 7, 9]
  def self.repeat_bitmap_multi_seg(
    trg_bitmap, trg_rect, src_bitmap, src_rects, mode=0)

    vx, vy = trg_rect.x, trg_rect.y
    r1, r2, r3, r4, r5, r6, r7, r8, r9 = *src_rects

    dr7 = Rect.new(vx, vy, r7.width, r7.height)
    dr8 = Rect.new(
      dr7.x2, vy,
      trg_rect.width - dr7.width - r9.width, r8.height)
    dr9 = Rect.new(dr8.x2, vy, r9.width, r9.height)

    dr4 = Rect.new(
      vx, dr7.y2, r4.width, trg_rect.height - r7.height - r1.height)
    dr5 = Rect.new(
      dr4.x2, dr8.y2,
      trg_rect.width - r4.width - r6.width,
      trg_rect.height - r8.height - r2.height)
    dr6 = Rect.new(
      dr5.x2, dr9.y2,
      r6.width, trg_rect.height - r9.height - r3.height)

    dr1 = Rect.new(vx, dr4.y2, r1.width, r1.height)
    dr2 = Rect.new(
      dr1.x2, dr5.y2,
      trg_rect.width - r1.width - r3.width, r2.height)
    dr3 = Rect.new(dr2.x2, dr6.y2, r3.width, r3.height)

    rect_pairs = case mode
    when 0
      [dr1, dr2, dr3, dr4, dr5, dr6, dr7, dr8, dr9].zip(src_rects)
    when 1
      [dr4, dr5, dr6].zip(src_rects[3, 3])
    when 2
      [dr8, dr5, dr2].zip([src_rects[7], src_rects[4], src_rects[1]])
    when 3
      [dr1, dr3, dr7, dr9].zip(
        [src_rect[1], src_rect[3], src_rect[7], src_rect[9]])
    end

    rect_pairs.each do |(dr, sr)|
      # trg_bitmap.fill_rect(dr, Color.random) # debug

      if(dr.width != sr.width or dr.height != sr.height) # looped
        self.repeat_bmp(trg_bitmap, dr, src_bitmap, sr)
      else # blit
        trg_bitmap.blt(dr.x, dr.y, src_bitmap, sr)
      end
    end
  end
end

__END__
  src_rects
  Index - Rect:Operation
      1 - Bottom Left:blit
      2 - Bottom Mid:repeat
      3 - Bottom Right:blit
      4 - Mid Left:repeat
      5 - Center:repeat
      6 - Mid Right:repeat
      7 - Top Left:blit
      8 - Top Mid:repeat
      9 - Top Right:blit
