#
# EDOS/lib/module/color_tool/blend.rb
#   by IceDragon
#   dc ??/03/2013
#   dm 27/03/2013
# vr 1.1.0
module ColorTool
  ### ::blend_*
  ##
  #
  def self._blend_color_custom(klass, colorf1, colorf2, calc_alpha=1, &blend)
    result = klass.new
    result.red   = blend.(colorf1.red, colorf2.red)
    result.green = blend.(colorf1.green, colorf2.green)
    result.blue  = blend.(colorf1.blue, colorf2.blue)

    case calc_alpha
    when 0 then result.alpha = blend.(colorf1.alpha, colorf2.alpha)
    when 1 then result.alpha = colorf1.alpha
    when 2 then result.alpha = colorf2.alpha
    end

    return result
  end

  def self._blend_color(color1, color2, calc_alpha=1, &blend)
    _blend_color_custom(Color, color1, color2, calc_alpha, &blend)
  end

  def self._blend_colorf(colorf1, colorf2, calc_alpha=1, &blend)
    result = _blend_color_custom(ColorF,
                                 colorf1, colorf2, calc_alpha, &blend)
    return colorf_to_color(result)
  end

  # blending
  def self.blend_alpha(src_color1, src_color2, calc_alpha=1)
    color1 = obj_to_color(src_color1)
    color2 = obj_to_color(src_color2)

    a = color1.alpha
    blend = ->(n1, n2) do
      ((n1 << 8) - n1 + (n2 - n1) * a) / 255
    end
    return _blend_color(color1, color2, calc_alpha, &blend)
  end

  def self.blend_add(color1, color2, calc_alpha=1)
    colorf1 = obj_to_colorf(color1)
    colorf2 = obj_to_colorf(color2)

    blend = ->(n, n2) do
      [(n + n2), 1.0].min
    end

    return _blend_colorf(colorf1, colorf2, calc_alpha, &blend)
  end

  def self.blend_subtract(color1, color2, calc_alpha=1)
    colorf1 = obj_to_colorf(color1)
    colorf2 = obj_to_colorf(color2)

    blend = ->(n, n2) do
      [(n - n2), 0.0].max
    end

    return _blend_colorf(colorf1, colorf2, calc_alpha, &blend)
  end

  def self.blend_screen(color1, color2, calc_alpha=1)
    colorf1 = obj_to_colorf(color1)
    colorf2 = obj_to_colorf(color2)

    blend = ->(n, n2) do
      1.0 - (1.0 - n) * (1.0 - n2)
    end

    return _blend_colorf(colorf1, colorf2, calc_alpha, &blend)
  end

  def self.blend_multiply(color1, color2, calc_alpha=1)
    colorf1 = obj_to_colorf(color1)
    colorf2 = obj_to_colorf(color2)

    blend = ->(n, n2) do
      (n * n2)
    end

    return _blend_colorf(colorf1, colorf2, calc_alpha, &blend)
  end

  def self.blend_divide(color1, color2, calc_alpha=1)
    colorf1 = obj_to_colorf(color1)
    colorf2 = obj_to_colorf(color2)

    blend = ->(n, n2) do
      n2 != 0 ? n / n2 : 1.0
    end

    return _blend_colorf(colorf1, colorf2, calc_alpha, &blend)
  end

  def self.blend_overlay(color1, color2, calc_alpha=1)
    colorf1 = obj_to_colorf(color1)
    colorf2 = obj_to_colorf(color2)

    blend = ->(n, n2) do
      if n < 0.5
        2 * (n * n2)
      else
        1 - 2 * (1 - n) * (1 - n2)
      end
    end

    return _blend_colorf(colorf1, colorf2, calc_alpha, &blend)
  end

  def self.blend_softlight(color1, color2, calc_alpha=1)
    colorf1 = obj_to_colorf(color1)
    colorf2 = obj_to_colorf(color2)

    blend = ->(n, n2) do
      if n2 < 0.5
        2 * n * n2 + n ** 2 * (1 - 2 * n2)
      else
        2 * n * (1 - n2) + Math.sqrt(n * (2 * n2 - 1))
      end
    end

    return _blend_colorf(colorf1, colorf2, calc_alpha, &blend)
  end

  def self.blend_dodge(src_color1, src_color2, calc_alpha=1)
    color1 = obj_to_color(src_color1)
    color2 = obj_to_color(src_color2)

    blend = ->(n1, n2) do
      (n1 == 255) ? n1 : [255, ((n2 << 8) / (255 - n1))].min
    end

    return _blend_color(color1, color2, calc_alpha, &blend)
  end

  def self.blend_burn(src_color1, src_color2, calc_alpha=1)
    color1 = obj_to_color(src_color1)
    color2 = obj_to_color(src_color2)

    blend = ->(n1, n2) do
      return (n1 == 0) ? n1 : [0, (255 - ((255 - n2) << 8 ) / n1)].max;
    end

    return _blend_color(color1, color2, calc_alpha, &blend)
  end

  def self._calc_alpha(src, dst, a)
    (((dst) << 8) - (dst) + ((src) - (dst)) * (a)) / 255
  end

  def self.blend_alpha(src, dst, calc_alpha=1)
    alpha = 255
    result = dst.clone
    beta = alpha * src.alpha / 255
    return if (beta <= 0)
    if beta == 255 || dst.alpha == 0
      result.set(src)
      result.alpha = beta
    elsif (beta > 0)
      if result.alpha < beta
        result.alpha = beta
      end
      result.red   = _calc_alpha(src.red,   dst.red,   beta);
      result.green = _calc_alpha(src.green, dst.green, beta);
      result.blue  = _calc_alpha(src.blue,  dst.blue,  beta);
    end
    return result
  end
end
