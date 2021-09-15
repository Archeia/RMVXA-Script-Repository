module DrawExt
  def self.repeat_bmp_vert_old( info )
    length        = info[:length] || 0
    return if length == 0
    bitmap        = info[:bitmap]
    dbmp          = info[:draw_bmp]
    rect          = info[:rect]
    x, y          = info[:x] || 0, info[:y] || 0
    opacity       = info[:opacity] || 255
    reps, tail = *length.divmod(rect.height.to_i)
    reps.times do |i| bitmap.blt(x,y+(rect.height*i),dbmp,rect,opacity) ; end
    r = rect.dup ; r.height = tail
    bitmap.blt( x, y+(reps*rect.height), dbmp, r )
  end

  def self.repeat_bmp_horz_old( info )
    length        = info[:length] || 0
    return if length == 0
    bitmap        = info[:bitmap]
    dbmp          = info[:draw_bmp]
    rect          = info[:rect]
    x, y          = info[:x] || 0, info[:y] || 0
    opacity       = info[:opacity] || 255
    reps, tail = *length.divmod(rect.width.to_i)
    reps.times do |i| bitmap.blt( x+(rect.width*i), y, dbmp, rect,opacity ) ; end
    r = rect.dup ; r.width = tail
    bitmap.blt( x+(reps*rect.width), y, dbmp, r )
  end

  def self.repeat_bmp_old( info )
    bitmap        = info[:bitmap]
    dbmp          = info[:draw_bmp]
    rect          = info[:rect]
    x, y          = info[:x] || 0, info[:y] || 0
    width         = info[:width] || bitmap.width
    height        = info[:height] || bitmap.height
    opacity       = info[:opacity] || 255
    repsx, tailx = *width.divmod(rect.width.to_i)
    repsy, taily = *height.divmod(rect.height.to_i)
    r = Rect.new(0,0,0,0)
    return if [repsx, repsy, tailx, taily].all? { |n| n.zero? }
    if repsx.zero? && repsy.zero? # // Only Tails
      r.set(rect.x,rect.y,tailx,taily)
      bitmap.blt(x,y,dbmp,r,opacity)
    elsif repsx.zero? && repsy > 0 # // No x repeat but y and tails
      for dy in 0...repsy
        r.set(rect) ; r.width = tailx
        bitmap.blt(x,y+(dy*rect.height),dbmp,r,opacity) # (: Yay
      end if tailx > 0
      if taily > 0
        r.set(rect) ; r.height = taily
        bitmap.blt(x,y+(repsy*rect.height),dbmp,r,opacity) # (: Yay
      end
    elsif repsx > 0 && repsy.zero? # // No y repeat but x and tails
      for dx in 0...repsx
        r.set(rect) ; r.height = taily
        bitmap.blt(x+(dx*rect.width),y,dbmp,r,opacity) # (: Yay
      end if taily > 0
      if tailx > 0
        r.set(rect) ; r.width = tailx
        bitmap.blt(x+(repsx*rect.width),y,dbmp,r,opacity) # (: Yay
      end
    else # // Full Repeat
      for dy in 0...repsy
        if tailx > 0
          r.set(rect) ; r.width = tailx
          bitmap.blt(x+(repsx*rect.width),y+(dy*rect.height),dbmp,r,opacity) # (: Yay
        end
        for dx in 0...repsx
          bitmap.blt(x+(dx*rect.width),y+(dy*rect.height),dbmp,rect,opacity) # (: Yay
          if taily > 0
            r.set(rect) ; r.height = taily
            bitmap.blt(x+(dx*rect.width),y+(repsy*rect.height),dbmp,r,opacity) # (: Yay
          end
        end
      end
      # // End Tail
      bitmap.blt(x+(repsx*rect.width),y+(repsy*rect.height),dbmp,r,opacity) if tailx > 0 && taily > 0
    end
  end
end
