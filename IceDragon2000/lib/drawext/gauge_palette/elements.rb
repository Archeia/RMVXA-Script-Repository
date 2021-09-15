module DrawExt
  for i in 0..9
    pal = new_gauge_palette_from("element#{i}", 'default')
    pal.import(quick_bar_colors_abs(Palette["element#{i}"], STYLE_SOFT)) # * (1.4)))
  end
end
