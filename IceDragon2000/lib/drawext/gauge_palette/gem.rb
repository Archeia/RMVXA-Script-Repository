#
# EDOS/lib/drawext/gauge_palette/gem.rb
#   by IceDragon
module DrawExt
  # red | ruby
  pal = new_gauge_palette_from('ruby', 'default')
  pal.set_color(:bar_outline1, 253, 131, 113, 255).blend.self_subtract!(0.2)
  pal.set_color(:bar_outline2, 202,  62,  70, 255).blend.self_subtract!(0.1)
  pal.set_color(:bar_inline1,  194,  55,  65, 255)
  pal.set_color(:bar_inline2,  107,  19,  43, 255)

  # green | emerald
  pal = new_gauge_palette_from('emerald', 'default')
  emerald = Color.new(80, 200, 120)
  pal.import(quick_bar_colors_abs(emerald, STYLE_SOFT))

  # blue | sapphire
  pal = new_gauge_palette_from('sapphire', 'default')
  sapphire = Color.new(15, 82, 186)
  pal.import(quick_bar_colors_abs(sapphire, STYLE_SOFT))

  # yellow | heliodor
  pal = new_gauge_palette_from('heliodor', 'default')
  heliodor = Color.new(236, 233, 162)
  pal.import(quick_bar_colors_abs(heliodor, STYLE_SOFT))
end
