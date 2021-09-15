module DrawExt
  def self.crop(bitmap, rect)
    b = Bitmap.new(rect.width, rect.height)
    b.blt(0, 0, bitmap, rect)

    return b
  end

  def self.clear_round!(bitmap, rect)
    temp = Bitmap.new(rect.width, rect.height)
    temp.blt(0, 0, bitmap, rect)

    bitmap.clear
    bitmap.blt(rect.x, rect.y, temp, temp.rect)

    temp.dispose

    return self;
  end

  def self.alpha_mask!(bitmap, *args)
    case args.size
    when 2
      rect, alp = *args

      Rect.assert_type(rect)
      Numeric.assert_type(alp)

      for y in rect.y...rect.y2
        for x in rect.x...rect.x2
          col = bitmap.get_pixel(x,y)
          col.alpha = a

          bitmap.set_pixel(x, y, col)
        end
      end
    when 4
      x, y, bmp, src_rect = *args

      Numeric.assert_type(x, y)
      Bitmap.assert_type(bmp)
      Rect.assert_type(src_rect)

      for sy in src_rect.y...src_rect.y2
        for sx in src_rect.x...src_rect.x2
          tx = x + sx - src_rect.width;
          ty = y + sy - src_rect.height;

          trg_color = bitmap.get_pixel(tx, ty)
          src_color = bmp.get_pixel(sx, sy)

          res_color = trg_color.dup
          res_color.alpha = src_color.alpha

          bitmap.set_pixel(px, py, res_color)
        end
      end
    else
      raise(ArgumentError, "expected 2 but recieved #{args.size}")
    end

    return self;
  end
end
