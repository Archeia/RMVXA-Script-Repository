module DrawExt
  def self.noise(bitmap, rect = bitmap.rect, rate = 0.1, bipolar = false)
    for y in rect.y...rect.y2
      for x in rect.x...rect.x2
        col = bitmap.get_pixel(x, y)

        r = col.red * rate
        g = col.green * rate
        b = col.blue * rate

        r, g, b = *[r, g, b].map do |p|
          n = rand(p)
          bipolar ? (rand(2) == 0 ? n : -n) : n
        end

        bitmap.set_pixel(x, y,
          Color.new(col.red + r, col.green + g, col.blue + b, col.alpha))
      end
    end

    return self;
  end

  def self.reduce(bitmap, rect = nil, px_size = 2)
    rect ||= bitmap.rect
    yrng = 0...(rect.height / px_size)
    xrng = 0...(rect.width / px_size)
    for sy in yrng
      for sx in xrng
        x, y = rect.x + sx * px_size, rect.y + sy * px_size
        col = bitmap.get_pixel(x, y)

        bitmap.fill_rect(x, y, px_size, px_size, col)
      end
    end

    return self;
  end

  def self.reduce_avg(bitmap, rect, px_size)
    yrng = 0...(rect.height / px_size)
    xrng = 0...(rect.width / px_size)
    ayrng = 0...px_size
    axrng = 0...px_size
    for sy in yrng
      for sx in xrng
        x, y = rect.x + sx * px_size, rect.y + sy * px_size

        last_col = bitmap.get_pixel(x, y)
        for ay in ayrng
          for ax in axrng
            last_col = calc_normalize_colors(last_col, bitmap.get_pixel(x + ax, y + ay))
          end
        end

        bitmap.fill_rect(x, y, px_size, px_size, last_col)
      end
    end

    return self;
  end
end
