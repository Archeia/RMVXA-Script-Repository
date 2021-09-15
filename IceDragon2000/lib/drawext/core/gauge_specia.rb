#
# EDOS/lib/drawext/core/gauge_specia.rb
#   by IceDragon
#   dc ??/??/????
#   dm 16/06/2013
# vr 1.0.0
module DrawExt
  def self.draw_gauge_base?
    return !flag?(:draw_gauge_base) || flag(:draw_gauge_base)
  end

  def self.draw_gauge_bar?
    return !flag?(:draw_gauge_bar) || flag(:draw_gauge_bar)
  end

  # draw_gauge_base_sp*
  ##
  # All draw_gauge functions start with (rect), (rate) as their arguments
  # base* functions disregard the (rate), the rate is kept so draw_gauge_base
  # and draw_gauge_bars can be easily interchanged
  def self.draw_gauge_base_sp0(bitmap, *args)
    rect, rate, colors, vertical, align = DrawExt.gauge_params(bitmap, *args)
    DrawExt.validate_gauge_colors(colors, [:base])
    rect2 = rect.dup
    if draw_gauge_base?
      bitmap.fill_rect(rect2, colors[:base_inline1])
    end
    return rect2
  end

  ##
  # draw_gauge_base_sp1
  def self.draw_gauge_base_sp1(bitmap, *args)
    rect, rate, colors, vertical, align = DrawExt.gauge_params(bitmap, *args)
    DrawExt.validate_gauge_colors(colors, [:base])
    rect2 = rect.dup
    if draw_gauge_base?
      DrawExt.draw_padded_rect_flat(bitmap, rect2,
                                    [colors[:base_outline1], colors[:base_inline1]])
    end
    return rect2.contract(anchor: 5, amount: 1)
  end

  def self.draw_gauge_base_sp2(bitmap, *args)
    rect, rte, colors, vertical, align = DrawExt.gauge_params(bitmap, *args)
    return draw_gauge_base_sp1(bitmap, rect, rte, colors,
                               vertical, align).contract(anchor: 5, amount: 1)
  end

  def self.draw_gauge_base_sp3(bitmap, *args)
    rect, _, colors, vertical, align = DrawExt.gauge_params(bitmap, *args)
    DrawExt.validate_gauge_colors(colors, [:base])
    rect2 = rect.dup
    if draw_gauge_base?
      DrawExt.draw_padded_rect_flat(bitmap, rect2,
                                    [colors[:base_outline1], colors[:base_inline1]])
    end
    # padded style
    rect2.contract!(anchor: 5, amount: 2)
    if draw_gauge_base?
      DrawExt.draw_padded_rect_flat(bitmap, rect2,
                                    [colors[:base_outline2], colors[:base_inline2]])
    end

    return rect2.contract(anchor: 5, amount: 1)
  end

  def self.draw_gauge_bar_sp0(bitmap, *args)
    rect, rate, colors, vertical, align = DrawExt.gauge_params(bitmap, *args)
    DrawExt.validate_gauge_colors(colors)
    grect = calc_gauge_rect(rect, rate, vertical, align)
    if draw_gauge_bar?
      bitmap.fill_rect(grect, colors[:bar_inline1])
    end
    return rect, grect
  end

  def self.draw_gauge_bar_sp1(bitmap, *args)
    rect, rate, colors, vertical, align = DrawExt.gauge_params(bitmap, *args)
    DrawExt.validate_gauge_colors(colors)
    if draw_gauge_bar?
      grect = DrawExt.draw_gauge_specia1(
        bitmap, rect, rate,
        [colors[:bar_outline1], colors[:bar_outline2],
         colors[:bar_inline1], colors[:bar_inline2],
         colors[:bar_highlight]],
         vertical, align
      )
    else
      grect = calc_gauge_rect(rect, rate, vertical, align)
    end
    return rect, grect
  end

  def self.draw_gauge_bar_sp2(bitmap, *args)
    rect, rate, colors, vertical, align = DrawExt.gauge_params(bitmap, *args)
    DrawExt.validate_gauge_colors(colors)
    if draw_gauge_bar?
      grect = DrawExt.draw_gauge_specia2(
        bitmap, rect, rate,
        [colors[:bar_outline1], colors[:bar_outline2],
        colors[:bar_inline1], colors[:bar_inline2],
        colors[:bar_highlight]],
        vertical, align
      )
    else
      grect = calc_gauge_rect(rect, rate, vertical, align)
    end
    return rect, grect
  end

  def self.draw_gauge_bar_sp3(bitmap, *args)
    rect, rate, colors, vertical, align = DrawExt.gauge_params(bitmap, *args)
    DrawExt.validate_gauge_colors(colors)
    if draw_gauge_bar?
      grect = DrawExt.draw_gauge_specia3(
        bitmap, rect, rate,
        [colors[:bar_outline1], colors[:bar_inline1],
         colors[:bar_outline2], colors[:bar_inline2]],
         vertical, align
      ) unless rect.empty?
    else
      grect = calc_gauge_rect(rect, rate, vertical, align)
    end
    return rect, grect
  end

  def self.draw_gauge_bar_sp4(bitmap, *args)
    rect, rate, colors, vertical, align = DrawExt.gauge_params(bitmap, *args)
    DrawExt.validate_gauge_colors(colors)
    nrect = DrawExt.calc_gauge_rect(rect, rate, vertical, align)
    if draw_gauge_bar?
      unless nrect.empty?
        DrawExt.draw_padded_rect_flat(bitmap, nrect,
                                      [colors[:bar_outline1],
                                      colors[:bar_inline1]])
      end
    end
    return rect, nrect
  end

  def self.draw_gauge_bar_sp5(bitmap, *args)
    rect, rate, colors, vertical, align = DrawExt.gauge_params(bitmap, *args)
    DrawExt.validate_gauge_colors(colors)

    nrect = DrawExt.calc_gauge_rect(rect, rate, vertical, align)

    nrect1, nrect2 = if vertical
      MACL::Surface::Tool.slice_surface(nrect, [nrect.width / 2], [])
    else
      MACL::Surface::Tool.slice_surface(nrect, [], [nrect.height / 2])
    end

    padding1, padding2 =
      [Hazel::Padding.new(1, 1, 1, 1),
       Hazel::Padding.new(1, 1, 1, 1)]
    if draw_gauge_bar?
      unless nrect.empty?
        DrawExt.draw_padded_rect_flat(bitmap, nrect1,
                                      [colors[:bar_outline1], colors[:bar_inline1]],
                                      padding1)
        DrawExt.draw_padded_rect_flat(bitmap, nrect2,
                                      [colors[:bar_outline2], colors[:bar_inline2]],
                                      padding2)
      end
    end

    return rect, nrect
  end

  def self.draw_gauge_bar_sp6(bitmap, *args)
    rect, rate, colors, vertical, align = DrawExt.gauge_params(bitmap, *args)
    DrawExt.validate_gauge_colors(colors)

    nrect = DrawExt.calc_gauge_rect(rect, rate, vertical, align)
    if draw_gauge_bar?
      [[colors[:bar_outline2], colors[:bar_inline2]],
       [colors[:bar_outline1], colors[:bar_inline1]]].each do |cols|
        DrawExt.draw_padded_rect_flat(bitmap, nrect, cols)
        nrect.contract!(anchor: 5, amount: 1)
      end
    end

    return rect, nrect
  end

  def self.draw_gauge_base(*args)
    send(gauge_base_name, *args)
  end

  def self.draw_gauge_bar(*args)
    send(gauge_bar_name, *args)
  end

  def self.draw_gauge_ext(bitmap, *args)
    rect, rate, colors, vertical, align = DrawExt.gauge_params(bitmap, *args)
    DrawExt.validate_gauge_colors(colors)
    rect2 = draw_gauge_base(bitmap, rect, rate, colors, vertical, align)
    return draw_gauge_bar(bitmap, rect2, rate, colors, vertical, align);
  end

  7.times do |i|
    meth = "draw_gauge_bar_sp#{i}"
    nm = "draw_gauge_ext_sp#{i}"
    define_method(nm) do |bitmap, *args|
      rect, rate, colors, vertical, align = DrawExt.gauge_params(bitmap, *args)
      DrawExt.validate_gauge_colors(colors)
      rect2 = draw_gauge_base(bitmap, rect, rate, colors, vertical, align)
      send(meth, bitmap, rect2, rate, colors, vertical, align);
    end
    module_function(nm)
  end

  def self.draw_gauge_ext_wtxt(bitmap, rect, (val, max),
                               colors=DrawExt::DEF_BAR_COLORS, use_text=true)
    rect = Convert.Rect(rect)
    r, nr = draw_gauge_ext(bitmap, rect, val / max.max(1).to_f, colors)

    bitmap.merio.snapshot do |mer|
      mer.font_config(:light, :micro, :enb)
      use_text = use_text && bitmap.text_size("W").height < rect.height
      return rect unless use_text

      txr1 = rect.dup
      font = bitmap.font
      #pal = Convert.Palette(colors)
      #font.shadow = true
      #font.shadow_color = pal[:bar_outline2].blend.darken(0.2)
      #font.shadow_conf = [9, 1]
      font.snapshot do
        txr1.x += 4
        txr1.width -= 8
        # -%03d" % [val, max]
        txr2 = mer.draw_fmt_num(txr1, max, "%03d")
        bitmap.draw_text(txr2, "/", 2)
        txr2.width -= bitmap.text_size("/").width
        txr3 = mer.draw_fmt_num(txr2, val, "%03d")
        #draw_text(txr1, sprintf("%s/%s", val, max), 2)
      end
    end
    return rect
  end

  class << self
    attr_accessor :gauge_base_name
    attr_accessor :gauge_bar_name
  end

  self.gauge_base_name = :draw_gauge_base_sp1
  self.gauge_bar_name  = :draw_gauge_bar_sp4
end
