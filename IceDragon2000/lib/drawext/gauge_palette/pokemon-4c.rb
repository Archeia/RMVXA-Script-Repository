module DrawExt
  pals = []
  pals << pal = new_gauge_palette_from('pkmn-normal', 'default')
  pal.set_color(:bar_outline1, Palette['pkmn-normal1'])
  pal.set_color(:bar_outline2, Palette['pkmn-normal2'])
  pal.set_color(:bar_inline1, Palette['pkmn-normal3'])
  pal.set_color(:bar_inline2, Palette['pkmn-normal4'])

  pals << pal = new_gauge_palette_from('pkmn-grass', 'default')
  pal.set_color(:bar_outline1, Palette['pkmn-grass1'])
  pal.set_color(:bar_outline2, Palette['pkmn-grass2'])
  pal.set_color(:bar_inline1, Palette['pkmn-grass3'])
  pal.set_color(:bar_inline2, Palette['pkmn-grass4'])

  pals << pal = new_gauge_palette_from('pkmn-water', 'default')
  pal.set_color(:bar_outline1, Palette['pkmn-water1'])
  pal.set_color(:bar_outline2, Palette['pkmn-water2'])
  pal.set_color(:bar_inline1, Palette['pkmn-water3'])
  pal.set_color(:bar_inline2, Palette['pkmn-water4'])

  pals << pal = new_gauge_palette_from('pkmn-fire', 'default')
  pal.set_color(:bar_outline1, Palette['pkmn-fire1'])
  pal.set_color(:bar_outline2, Palette['pkmn-fire2'])
  pal.set_color(:bar_inline1, Palette['pkmn-fire3'])
  pal.set_color(:bar_inline2, Palette['pkmn-fire4'])

  pals << pal = new_gauge_palette_from('pkmn-bug', 'default')
  pal.set_color(:bar_outline1, Palette['pkmn-bug1'])
  pal.set_color(:bar_outline2, Palette['pkmn-bug2'])
  pal.set_color(:bar_inline1, Palette['pkmn-bug3'])
  pal.set_color(:bar_inline2, Palette['pkmn-bug4'])

  pals << pal = new_gauge_palette_from('pkmn-rock', 'default')
  pal.set_color(:bar_outline1, Palette['pkmn-rock1'])
  pal.set_color(:bar_outline2, Palette['pkmn-rock2'])
  pal.set_color(:bar_inline1, Palette['pkmn-rock3'])
  pal.set_color(:bar_inline2, Palette['pkmn-rock4'])

  pals << pal = new_gauge_palette_from('pkmn-ground', 'default')
  pal.set_color(:bar_outline1, Palette['pkmn-ground1'])
  pal.set_color(:bar_outline2, Palette['pkmn-ground2'])
  pal.set_color(:bar_inline1, Palette['pkmn-ground3'])
  pal.set_color(:bar_inline2, Palette['pkmn-ground4'])

  pals << pal = new_gauge_palette_from('pkmn-electric', 'default')
  pal.set_color(:bar_outline1, Palette['pkmn-electric1'])
  pal.set_color(:bar_outline2, Palette['pkmn-electric2'])
  pal.set_color(:bar_inline1, Palette['pkmn-electric3'])
  pal.set_color(:bar_inline2, Palette['pkmn-electric4'])

  pals << pal = new_gauge_palette_from('pkmn-flying', 'default')
  pal.set_color(:bar_outline1, Palette['pkmn-flying1'])
  pal.set_color(:bar_outline2, Palette['pkmn-flying2'])
  pal.set_color(:bar_inline1, Palette['pkmn-flying3'])
  pal.set_color(:bar_inline2, Palette['pkmn-flying4'])

  pals << pal = new_gauge_palette_from('pkmn-poison', 'default')
  pal.set_color(:bar_outline1, Palette['pkmn-poison1'])
  pal.set_color(:bar_outline2, Palette['pkmn-poison2'])
  pal.set_color(:bar_inline1, Palette['pkmn-poison3'])
  pal.set_color(:bar_inline2, Palette['pkmn-poison4'])

  pals << pal = new_gauge_palette_from('pkmn-psychic', 'default')
  pal.set_color(:bar_outline1, Palette['pkmn-psychic1'])
  pal.set_color(:bar_outline2, Palette['pkmn-psychic2'])
  pal.set_color(:bar_inline1, Palette['pkmn-psychic3'])
  pal.set_color(:bar_inline2, Palette['pkmn-psychic4'])

  pals << pal = new_gauge_palette_from('pkmn-fight', 'default')
  pal.set_color(:bar_outline1, Palette['pkmn-fight1'])
  pal.set_color(:bar_outline2, Palette['pkmn-fight2'])
  pal.set_color(:bar_inline1, Palette['pkmn-fight3'])
  pal.set_color(:bar_inline2, Palette['pkmn-fight4'])

  pals << pal = new_gauge_palette_from('pkmn-ghost', 'default')
  pal.set_color(:bar_outline1, Palette['pkmn-ghost1'])
  pal.set_color(:bar_outline2, Palette['pkmn-ghost2'])
  pal.set_color(:bar_inline1, Palette['pkmn-ghost3'])
  pal.set_color(:bar_inline2, Palette['pkmn-ghost4'])

  pals << pal = new_gauge_palette_from('pkmn-ice', 'default')
  pal.set_color(:bar_outline1, Palette['pkmn-ice1'])
  pal.set_color(:bar_outline2, Palette['pkmn-ice2'])
  pal.set_color(:bar_inline1, Palette['pkmn-ice3'])
  pal.set_color(:bar_inline2, Palette['pkmn-ice4'])

  pals << pal = new_gauge_palette_from('pkmn-steel', 'default')
  pal.set_color(:bar_outline1, Palette['pkmn-steel1'])
  pal.set_color(:bar_outline2, Palette['pkmn-steel2'])
  pal.set_color(:bar_inline1, Palette['pkmn-steel3'])
  pal.set_color(:bar_inline2, Palette['pkmn-steel4'])

  pals << pal = new_gauge_palette_from('pkmn-dark', 'default')
  pal.set_color(:bar_outline1, Palette['pkmn-dark1'])
  pal.set_color(:bar_outline2, Palette['pkmn-dark2'])
  pal.set_color(:bar_inline1, Palette['pkmn-dark3'])
  pal.set_color(:bar_inline2, Palette['pkmn-dark4'])

  pals << pal = new_gauge_palette_from('pkmn-dragon', 'default')
  pal.set_color(:bar_outline1, Palette['pkmn-dragon1'])
  pal.set_color(:bar_outline2, Palette['pkmn-dragon2'])
  pal.set_color(:bar_inline1, Palette['pkmn-dragon3'])
  pal.set_color(:bar_inline2, Palette['pkmn-dragon4'])

  # since the gauge style is generated differently than how the colors where
  # assigned here
  pals.each do |pkpal|
    bo1 = pkpal[:bar_outline1]
    bo2 = pkpal[:bar_outline2]
    bi1 = pkpal[:bar_inline1]
    bi2 = pkpal[:bar_inline2]
    ###
    # pkmn-*4 colors are a bit too bright, so its 3rd is used instead with
    # a #blend.self_add
    bi2 = bi1.blend.self_add(0.2)
    # pkmn-*1 colors are a tad bit too dark, so I've amped it up a bit
    bo1 = bo2.blend.self_subtract(0.2)
    ###
    pkpal.set_color(:bar_outline1, bi2)
    pkpal.set_color(:bar_outline2, bo2)
    pkpal.set_color(:bar_inline1, bi1)
    pkpal.set_color(:bar_inline2, bo1)
  end
end
