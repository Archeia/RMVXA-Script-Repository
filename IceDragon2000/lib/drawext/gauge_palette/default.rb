#
# EDOS/lib/drawext/gauge_palette/default.rb
#   by IceDragon
module DrawExt
  pal = new_gauge_palette('default')
  pal.set_color(:base_outline1, Palette['droid_dark_ui_enb'])
  pal.set_color(:base_outline2, Palette['droid_dark_ui_enb'])
  pal.set_color(:base_inline1,  Palette['droid_dark_ui_dis'])
  pal.set_color(:base_inline2,  Palette['droid_dark_ui_dis'])
  pal.set_color(:bar_outline1,  117, 117, 117, 255)
  pal.set_color(:bar_outline2,   66,  66,  66, 255)
  pal.set_color(:bar_inline1,    91,  91,  91, 255)
  pal.set_color(:bar_inline2,    42,  42,  42, 255)
  pal.set_color(:bar_highlight, 255, 255, 255,  51)

  pal = new_gauge_palette_from('transparent', 'default')
  pal.set_color(:base_inline1, Palette['black'].hset(alpha: 25))
  pal.set_color(:base_inline2, Palette['black'].hset(alpha: 25))
  pal.set_color(:bar_outline1, Palette['gray15'].hset(alpha: 128))
  pal.set_color(:bar_outline2, Palette['gray18'].hset(alpha: 128))
  pal.set_color(:bar_inline1,  Palette['gray12'].hset(alpha: 96))
  pal.set_color(:bar_inline2,  Palette['gray15'].hset(alpha: 128))
end
