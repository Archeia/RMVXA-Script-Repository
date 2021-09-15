#
# EDOS/lib/artist/drawext/helpers/color_bars.rb
#   by IceDragon (mistdragon100@gmail.com)
#   dc 27/03/2013
#   dm 27/03/2013
# vr 1.0.1
module DrawExt
  def self.validate_gauge_colors_abs(colors, request=[:base, :bar, :highlight])
    check = []
    check.concat([:base_outline1, :base_outline2,
                  :base_inline1, :base_inline2]) if request.include?(:base)
    check.concat([:bar_outline1, :bar_outline2,
                  :bar_inline1, :bar_inline2]) if request.include?(:bar)
    check.concat([:bar_highlight]) if request.include?(:highlight)
    check.reject { |key| colors.key?(key) && colors[key].is_a?(Color) }
  end

  def self.validate_gauge_colors(*args)
    missing = validate_gauge_colors_abs(*args)
    if missing.size > 0
      missing_s = missing.join(", ")
      raise(TypeError,
            "Gauge Color#{missing.size > 1 ? "s" : ""} missing: #{missing_s}")
    end
    return true
  end

  def self.quick_color_style(color, style_id=STYLE_DEFAULT, *args)
    c = color.dup
    styler = style_id.is_a?(Styler) ? style_id : Styler.styler(style_id)
    if styler
      return styler.apply(color, *args)
    else
      raise(TypeError, "Invalid Styler #{style}")
    end
  end

  def self.quick_bar_colors_abs(color, style_id=STYLE_DEFAULT, *args)
    boc1, boc2, bic1, bic2 = quick_color_style(color, style_id, *args)
    return {
      bar_outline1: boc1,
      bar_outline2: boc2,
      bar_inline1:  bic1,
      bar_inline2:  bic2
    }
  end

  def self.quick_bar_colors(color, style_id=STYLE_DEFAULT, *args)
    return DEF_BAR_COLORS.merge(quick_bar_colors_abs(color, style_id, *args))
  end

  def self.quick_base_colors_abs(color, style_id=STYLE_DEFAULT, *args)
    boc1, boc2, bic1, bic2 = quick_color_style(color, style_id, *args)
    return {
      base_outline1: boc1,
      base_outline2: boc2,
      base_inline1:  bic1,
      base_inline2:  bic2
    }
  end

  def self.quick_gauge_colors(c1, c2,
                              style1=STYLE_DEFAULT, style2=style1,
                              args1=[], args2=args1)
    quick_base_colors_abs(c2, style2, *args2).merge(
      quick_bar_colors_abs(c1, style1, *args1))
  end

  def self.half_mix_gauge_colors(colors1, colors2)
    keys1 = colors1.keys.select { |sym| sym.to_s.end_with?("1") }
    keys2 = colors2.keys.select { |sym| sym.to_s.end_with?("2") }
    result = {}
    result.merge!(colors1.select_key_pair(*keys1))
    result.merge!(colors2.select_key_pair(*keys2))
    result.merge!({ bar_highlight: colors1[:bar_highlight] ||
                                   colors2[:bar_highlight] ||
                                   DEF_BAR_COLORS[:bar_highlight] })
    return result
  end

  def self.patch_gauge_colors(colors, patch_colors=DEF_BAR_COLORS)
    validate_gauge_colors(patch_colors)
    result = {}
    patch_colors.each_pair do |k, v|
      result[k] = colors[k] || v
    end
    return result
  end

  def self.merio_to_gauge_colors(palette=DrawExt::Merio.main_palette)
    ### bar color
    broc1 = palette[:light_ui_dis]
    broc2 = palette[:light_ui_dis]
    bric1 = palette[:light_ui_enb]
    bric2 = palette[:light_ui_enb]
    ### base color
    bsoc1 = palette[:dark_ui_dis]
    bsoc2 = palette[:dark_ui_dis]
    bsic1 = palette[:dark_ui_enb]
    bsic2 = palette[:dark_ui_enb]
    ###
    {
      bar_outline1: broc1,
      bar_outline2: broc2,
      bar_inline1:  bric1,
      bar_inline2:  bric2,

      base_outline1: bsoc1,
      base_outline2: bsoc2,
      base_inline1:  bsic1,
      base_inline2:  bsic2,
    }
  end
end
