module DrawExt
  ## hp
  pal = new_gauge_palette_from('hp', 'default')
  base_color = Color.rgb24(0x87D367).blend.darken(0.2)
  pal.import(quick_bar_colors_abs(base_color, STYLE_SOFT))

  ## mp
  pal = new_gauge_palette_from('mp', 'default')
  base_color = Color.rgb24(0xA7E0DA).blend.darken(0.2)
  pal.import(quick_bar_colors_abs(base_color, STYLE_SOFT))

  ## ap
  pal = new_gauge_palette_from('ap', 'default')
  base_color = Color.rgb24(0xD288D7).blend.darken(0.2)
  pal.import(quick_bar_colors_abs(base_color, STYLE_SOFT))

  ## wt
  pal = new_gauge_palette_from('wt', 'default')
  base_color = Color.rgb24(0xC2C2C2).blend.darken(0.2)
  pal.import(quick_bar_colors_abs(base_color, STYLE_SOFT))

  ## exp
  pal = new_gauge_palette_from('exp', 'default')
  base_color = Color.rgb24(0xF15324).blend.darken(0.2)
  pal.import(quick_bar_colors_abs(base_color, STYLE_SOFT))
end
