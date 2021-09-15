module ColorTool
  LUM_RED   = 9830  # 0x8000 * 0.3
  LUM_GREEN = 19333 # 0x8000 * 0.59
  LUM_BLUE  = 3605  # 0x8000 * 0.11

  UnclipColor = Struct.new(:red, :green, :blue, :alpha)

  def self.calc_lum(color)
    (LUM_RED * color.red +
     LUM_GREEN * color.green +
     LUM_BLUE * color.blue) / 0x8000
  end

  def self.calc_lumf(colorf)
    (0.3 * colorf.red + 0.59 * colorf.green + 0.11 * colorf.blue) / 255.0
  end

  def self.calc_satf(colorf)
    return Palila::Util.max(colorf.red, colorf.green, colorf.blue) -
           Palila::Util.min(colorf.red, colorf.green, colorf.blue)
  end

  def self.calc_sat(color)
    calc_satf(color_to_colorf(color)) * 256
  end

  def self.sort_color_h(color)
    h = color.to_h
    h.delete(:alpha)
    h.sort_by { |(k, v)| v }
  end

  def self.get_max(color)
    return sort_color_h(color).last
  end

  def self.get_mid(color)
    return sort_color_h(color)[1]
  end

  def self.get_min(color)
    return sort_color_h(color).first
  end

  def self.get_max_v(color)
    get_max(color)[1]
  end

  def self.get_mid_v(color)
    get_mid(color)[1]
  end

  def self.get_min_v(color)
    get_min(color)[1]
  end

  def self.set_color_sym(color, symbol, n)
    color.send(symbol.to_s + "=", n)
  end

  def self.set_max(color, n)
    set_color_sym(color, get_max(color)[0], n)
  end

  def self.set_min(color, n)
    set_color_sym(color, get_min(color)[0], n)
  end

  def self.set_mid(color, n)
    set_color_sym(color, get_mid(color)[0], n)
  end

  def self.new_lumf(src_colorf, l)
    colorf = UnclipColor.new(*src_colorf.to_a)
    d = l - calc_lumf(colorf)
    colorf.red   = src_colorf.red + d
    colorf.green = src_colorf.green + d
    colorf.blue  = src_colorf.blue + d
    return clip_colorf(colorf)
  end

  def self.new_lum(src_color, l)
    colorf = obj_to_colorf(src_color)
    return colorf_to_color(new_lumf(colorf, l))
  end

  def self.new_satf(src_colorf, s)
    colorf = src_colorf.dup
    if (mx = get_max(colorf)) > (mn = get_min(colorf))
      set_mid(colorf, (((get_mid(colorf) - mn) * s) / (mx - mn)))
      set_max(colorf, s)
    else
      # ???
      set_mid(colorf, get_max(colorf))
      set_max(colorf, 0.0)
      #set_mid(colorf, 0.0)
    end
    set_min(colorf, 0.0)
    return colorf
  end

  def self.clip_colorf(src_colorf)
    c = src_colorf.dup
    l = calc_lumf(src_colorf)
    n = Palila::Util.min(src_colorf.red, src_colorf.green, src_colorf.blue)
    x = Palila::Util.max(src_colorf.red, src_colorf.green, src_colorf.blue)
    if n < 0.0
      c.red   = l + (((c.red   - l) * l) / (l - n))
      c.green = l + (((c.green - l) * l) / (l - n))
      c.blue  = l + (((c.blue  - l) * l) / (l - n))
    end
    if x > 1.0
      c.red   = l + (((c.red   - l) * (1 - l)) / (x - l))
      c.green = l + (((c.green - l) * (1 - l)) / (x - l))
      c.blue  = l + (((c.blue  - l) * (1 - l)) / (x - l))
    end
    return c
  end

  def self.num_to_color(num, alpha=255)
    Color.new(num, num, num, alpha)
  end

  def self.num_to_colorf(num, alpha=255)
    ColorF.new(num / 255.0, num / 255.0, num / 255.0, alpha)
  end

  def self.numf_to_colorf(numf, alpha=1.0)
    ColorF.new(numf, numf, numf, alpha)
  end

  def self.num_to_unclip_color(num, alpha=255)
    UnclipColor.new(num, alpha)
  end

  def self.numf_to_unclip_color(numf, alpha=1.0)
    UnclipColor.new(numf, alpha)
  end

  def self.colorf_to_color(colorf)
    return Color.new(
      colorf.red * 255, colorf.green * 255, colorf.blue * 255,
      colorf.alpha * 255)
  end

  def self.color_to_colorf(color)
    return ColorF.new(
      color.red / 255.0, color.green / 255.0, color.blue / 255.0,
      color.alpha / 255.0)
  end

  def self.color_to_unclip_color(color)
    UnclipColor.new(color.red, color.green, color.blue, color.alpha)
  end

  def self.obj_to_colorf(obj)
    case obj
    when Float       then numf_to_colorf(obj)
    when Integer     then num_to_colorf(obj)
    when Color       then color_to_colorf(obj)
    when ColorF then obj.dup
    else             raise(TypeError,
                           "expected Float, Integer, Color, ColorF but received #{obj}")
    end
  end

  def self.obj_to_color(obj)
    obj_to_colorf(obj).to_color
  end

  ##
  # ::color_rating(Color color, Boolean calc_alpha)
  def self.color_rating(color, calc_alpha=false)
    n = ((get_max_v(color) + get_min_v(color)) / 2.0) / 255.0
    n *= color.alpha if calc_alpha
    return n
    # Diversity Rating
    #return (color.red / 255.0) *
    #  (color.green / 255.0) *
    #  (color.blue / 255.0) *
    #  (calc_alpha ? (color.alpha / 255.0) : 1.0)
  end

  def self.invert(color1, calc_alpha=1)
    result = Color.new
    result.red   = 255 - color1.red
    result.green = 255 - color1.green
    result.blue  = 255 - color1.blue
    result.alpha = color1.alpha

    return result
  end
end
