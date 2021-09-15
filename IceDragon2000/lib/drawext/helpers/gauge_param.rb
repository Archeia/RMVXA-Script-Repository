#
# EDOS/lib/drawext/helper/gauge_param.rb
#   by IceDragon
#   dc 03/06/2013
#   dm 03/06/2013
# vr 1.0.0
module DrawExt
  ##
  # gauge_params(parent, *args) -> rect, rate, colors, vertical align
  def self.gauge_params(parent, *args)
    arg, = args
    if arg.is_a?(Hash)
      rect, rate, colors, vertical, align = arg[:rect], arg[:rate],
                                            arg[:colors], arg[:vertical],
                                            arg[:align]
    else
      rect, rate, colors, vertical, align = *args
    end
    rect     ||= parent.rect
    rate     ||= 1.0
    colors   ||= DrawExt.gauge_palettes['default']
    vertical   = false if vertical.nil?
    align    ||= 0
    colors = DrawExt.gauge_palettes[colors] if colors.is_a?(String) || colors.is_a?(Symbol)
    return Convert.Rect(rect), rate, colors, vertical, align
  end

  ##
  # gauge_params_h(*args) -> Hash
  def self.gauge_params_h(parent, *args)
    r, rr, c, v, a = gauge_params(parent, *args)
    return {rect: r, rate: rr, colors: c, vertical: v, align: a}
  end

  ##
  # calc_gauge_rect(Rect rect, float rate, bool vertical, int align)
  def self.calc_gauge_rect(rect, rate, vertical=false, align=0)
    rate = [[rate, 0.0].max, 1.0].min

    result_rect = rect.dup
    if vertical
      result_rect.height *= rate
    else
      result_rect.width *= rate
    end

    case align
    when 0 ; # default
    when 1 ; # center
      if vertical
        result_rect.y += (rect.height - result_rect.height) / 2
      else
        result_rect.x += (rect.width - result_rect.width) / 2
      end
    when 2 ; # right / bottom
      if vertical
        result_rect.y += rect.height - result_rect.height
      else
        result_rect.x += rect.width - result_rect.width
      end
    end

    return result_rect;
  end
end
