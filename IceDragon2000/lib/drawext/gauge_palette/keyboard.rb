#
# EDOS/lib/drawext/gauge_palette/keyboard.rb
#   by IceDragon
module DrawExt
  pal = new_gauge_palette_from('keyboard', 'default')
  pal.import(quick_bar_colors(Color.new(174, 167, 159), STYLE_SOFT))
  pal.import(quick_base_colors_abs(Palette['gray15'], STYLE_SOFT))
end
