#
# EDOS/lib/drawext/gauge_palette/rgby.rb
#   by IceDragon
module DrawExt
  pal = new_gauge_palette_from('red', 'default')
  pal.set_color(:bar_outline1, 248,  98,  96, 255)
  pal.set_color(:bar_outline2, 199,  52,  50, 255)
  pal.set_color(:bar_inline1,  224,  73,  71, 255)
  pal.set_color(:bar_inline2,  176,  34,  32, 255)

  pal = new_gauge_palette_from('green', 'default')
  pal.set_color(:bar_outline1, 117, 205,  85, 255)
  pal.set_color(:bar_outline2,  66, 154,  34, 255)
  pal.set_color(:bar_inline1,   91, 179,  59, 255)
  pal.set_color(:bar_inline2,   42, 130,  10, 255)

  pal = new_gauge_palette_from('blue', 'default')
  pal.set_color(:bar_outline1, 123, 176, 222, 255)
  pal.set_color(:bar_outline2,  79, 122, 166, 255)
  pal.set_color(:bar_inline1,   95, 149, 208, 255)
  pal.set_color(:bar_inline2,   58,  97, 140, 255)

  pal = new_gauge_palette_from('yellow', 'default')
  pal.set_color(:bar_outline1, 246, 187,   3, 255)
  pal.set_color(:bar_outline2, 194, 150,   3, 255)
  pal.set_color(:bar_inline1,  221, 169,   3, 255)
  pal.set_color(:bar_inline2,  168, 131,   3, 255)
end
