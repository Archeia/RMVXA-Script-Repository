#
# EDOS/lib/drawext/merio/palette_cache.rb
#   by IceDragon (mistdragon100@gmail.com)
#   dc 03/06/2013
#   dm 18/06/2013
# vr 1.2.0
#   CHANGELOG
#     vr 1.2.0
#       Added new solid colors prefixed with oq (opaque)
module DrawExt
  module Merio
    def self.rebuild_palette_cache(with_alpha = true)
      m = ColorMixer.new
      alpha_light_enb   = with_alpha ? 0.8 : 1.0
      alpha_light_dis   = with_alpha ? 0.3 : 1.0
      alpha_dark_enb    = with_alpha ? 0.6 : 1.0
      alpha_dark_dis    = with_alpha ? 0.3 : 1.0
      alpha_oqlight_enb = with_alpha ? 1.0 : 1.0
      alpha_oqlight_dis = with_alpha ? 0.8 : 1.0
      alpha_oqdark_enb  = with_alpha ? 0.8 : 1.0
      alpha_oqdark_dis  = with_alpha ? 0.6 : 1.0

      blend_light_enb = blend_light_dis = 0.1 # 0.2
      blend_dark_enb = blend_dark_dis = 0.1   # 0.4

      palette = {}
      invert = false

      div255 = ->(n) do
        n / 255
      end

      new_palette = ->(&blk) do
        mcr = Merio::MerioPalette.new
        mcr.can_replace_color = true
        if blk
          blk.(mcr)
          mcr.can_replace_color = false
        end
        return mcr
      end

      map_pallete = ->(inverted, c_dark_dis, c_dark_enb,
                       c_light_dis, c_light_enb,
                       c_oqdark_dis, c_oqdark_enb,
                       c_oqlight_dis, c_oqlight_enb) do
        if invert
          c_light_enb, c_dark_enb = c_dark_enb, c_light_enb
          c_light_dis, c_dark_dis = c_dark_dis, c_light_dis

          c_oqlight_enb, c_oqdark_enb = c_oqdark_enb, c_oqlight_enb
          c_oqlight_dis, c_oqdark_dis = c_oqdark_dis, c_oqlight_dis
        end

        new_palette.() do |pal|
          pal.set_color(:dark_ui_dis,    c_dark_dis)
          pal.set_color(:dark_ui_enb,    c_dark_enb)
          pal.set_color(:light_ui_dis,   c_light_dis)
          pal.set_color(:light_ui_enb,   c_light_enb)

          pal.set_color(:oqdark_ui_dis,  c_oqdark_dis)
          pal.set_color(:oqdark_ui_enb,  c_oqdark_enb)
          pal.set_color(:oqlight_ui_dis, c_oqlight_dis)
          pal.set_color(:oqlight_ui_enb, c_oqlight_enb)

          pal.each { |k, v| v.blend.alpha!(Palette['droid_light_ui_enb']).opaque! }
        end
      end

      quick_palette_colors = ->(color) do
        color = color.is_a?(String) ? Palette[color] : Convert.Color(color)
        color = color.dup

        dark_color = Palette['black']
        light_color = Palette['white']

        dark_enb  = alpha_dark_enb
        dark_dis  = alpha_dark_dis
        light_enb = alpha_light_enb
        light_dis = alpha_light_dis

        oqdark_enb  = alpha_oqdark_enb
        oqdark_dis  = alpha_oqdark_dis
        oqlight_enb = alpha_oqlight_enb
        oqlight_dis = alpha_oqlight_dis

        c_dark_dis    = m.fset_a(m.lerpa(color, dark_color, blend_dark_dis), dark_dis)
        c_dark_enb    = m.fset_a(m.lerpa(color, dark_color, blend_dark_enb), dark_enb)
        c_light_dis   = m.fset_a(m.lerpa(color, light_color, blend_light_dis), light_dis)
        c_light_enb   = m.fset_a(m.lerpa(color, light_color, blend_light_enb), light_enb)
        c_oqdark_dis  = m.fset_a(m.lerpa(color, dark_color, blend_dark_dis), oqdark_dis)
        c_oqdark_enb  = m.fset_a(m.lerpa(color, dark_color, blend_dark_enb), oqdark_enb)
        c_oqlight_dis = m.fset_a(m.lerpa(color, light_color, blend_light_dis), oqlight_dis)
        c_oqlight_enb = m.fset_a(m.lerpa(color, light_color, blend_light_enb), oqlight_enb)

        map_pallete.(invert, c_dark_dis, c_dark_enb,
                     c_light_dis, c_light_enb,
                     c_oqdark_dis, c_oqdark_enb,
                     c_oqlight_dis, c_oqlight_enb)
      end

      ##
      # use the light from first palette and the darks from the second
      # to create a new palette
      cross_palette = ->(pal1, pal2) do
        c_light_dis = pal1[:light_ui_dis]
        c_light_enb = pal1[:light_ui_enb]
        c_dark_dis  = pal2[:light_ui_dis]
        c_dark_enb  = pal2[:light_ui_enb]
        c_oqlight_dis = pal1[:oqlight_ui_dis]
        c_oqlight_enb = pal1[:oqlight_ui_enb]
        c_oqdark_dis  = pal2[:oqlight_ui_dis]
        c_oqdark_enb  = pal2[:oqlight_ui_enb]
        new_palette.() do |mcr|
          mcr.set_color(:dark_ui_dis,  c_dark_dis)
          mcr.set_color(:dark_ui_enb,  c_dark_enb)
          mcr.set_color(:light_ui_dis, c_light_dis)
          mcr.set_color(:light_ui_enb, c_light_enb)
          mcr.set_color(:oqdark_ui_dis,  c_oqdark_dis)
          mcr.set_color(:oqdark_ui_enb,  c_oqdark_enb)
          mcr.set_color(:oqlight_ui_dis, c_oqlight_dis)
          mcr.set_color(:oqlight_ui_enb, c_oqlight_enb)
        end
      end

      ##
      # use this to convert a gauge_palette to a merio_palette
      from_gauge_palette = lambda do |palette|
        pal = Convert.Palette(palette)

        map_pallete.(false, pal[:bar_inline2], pal[:bar_outline2], # regular
                            pal[:bar_inline1], pal[:bar_outline1],
                            pal[:bar_inline2], pal[:bar_outline2], # oq
                            pal[:bar_inline1], pal[:bar_outline1],)
      end

      [false, true].each do |b|
        invert = b
        ebr = 0.25 # element_blend_rate
        ebr_enb = 4.0 #8.0 #1.0 - ebr #+ 0.1
        ebr_enb_pls = 148
        ebr_col_enb = Palette['white']
        hsh = {
          ### default palette
          'default' => begin
            c_light_enb = Palette['droid_light_ui_enb'].dup
            c_light_dis = Palette['droid_light_ui_dis'].dup
            c_dark_enb  = Palette['droid_dark_ui_enb'].dup
            c_dark_dis  = Palette['droid_dark_ui_dis'].dup
            # solid
            c_oqlight_enb = Palette['droid_light_ui_enb'].dup.hset(alpha: 255 * alpha_oqlight_enb)
            c_oqlight_dis = Palette['droid_light_ui_dis'].dup.hset(alpha: 255 * alpha_oqlight_dis)
            c_oqdark_enb  = Palette['droid_dark_ui_enb'].dup.hset(alpha: 255 * alpha_oqdark_enb)
            c_oqdark_dis  = Palette['droid_dark_ui_dis'].dup.hset(alpha: 255 * alpha_oqdark_dis)

            map_pallete.(invert, c_dark_dis, c_dark_enb,
                         c_light_dis, c_light_enb,
                         c_oqdark_dis, c_oqdark_enb,
                         c_oqlight_dis, c_oqlight_enb)
          end,
          'txt_default' => begin
            c_light_enb = Palette['_droid_light_ui_enb'].blend.alpha(Palette['droid_dark_ui_enb']).blend.self_subtract(0.1).opaque
            c_light_dis = Palette['_droid_light_ui_dis'].blend.alpha(Palette['droid_dark_ui_dis']).blend.self_subtract(0.1).opaque
            c_dark_enb  = Palette['_droid_dark_ui_enb'].blend.alpha(Palette['droid_light_ui_enb']).blend.self_subtract(0.1).opaque
            c_dark_dis  = Palette['_droid_dark_ui_dis'].blend.alpha(Palette['droid_light_ui_dis']).blend.self_subtract(0.1).opaque
            # solid
            c_oqlight_enb = Palette['droid_light_ui_enb'].dup.hset(alpha: 255 * alpha_oqlight_enb)
            c_oqlight_dis = Palette['droid_light_ui_dis'].dup.hset(alpha: 255 * alpha_oqlight_dis)
            c_oqdark_enb  = Palette['droid_dark_ui_enb'].dup.hset(alpha: 255 * alpha_oqdark_enb)
            c_oqdark_dis  = Palette['droid_dark_ui_dis'].dup.hset(alpha: 255 * alpha_oqdark_dis)
            [c_dark_dis, c_dark_enb,
             c_light_dis, c_light_enb,
             c_oqdark_dis, c_oqdark_enb,
             c_oqlight_dis, c_oqlight_enb].each do |c|
              c.alpha += 128
            end
            map_pallete.(invert, c_dark_dis, c_dark_enb,
                         c_light_dis, c_light_enb,
                         c_oqdark_dis, c_oqdark_enb,
                         c_oqlight_dis, c_oqlight_enb)
          end,
          ### mono palettes
          'black'    => quick_palette_colors.('black'),
          'white'    => quick_palette_colors.('white'),
          'clay'     => quick_palette_colors.('clay'),
          ### element palettes
          'element0' => quick_palette_colors.('element0'),
          'element1' => quick_palette_colors.('element1'),
          'element2' => quick_palette_colors.('element2'),
          'element3' => quick_palette_colors.('element3'),
          'element4' => quick_palette_colors.('element4'),
          'element5' => quick_palette_colors.('element5'),
          'element6' => quick_palette_colors.('element6'),
          'element7' => quick_palette_colors.('element7'),
          'element8' => quick_palette_colors.('element8'),
          'element9' => quick_palette_colors.('element9'),
          ### extended-elmenet palettes
          'element0_dis' => quick_palette_colors.(Palette['element0'] * ebr),
          'element1_dis' => quick_palette_colors.(Palette['element1'] * ebr),
          'element2_dis' => quick_palette_colors.(Palette['element2'] * ebr),
          'element3_dis' => quick_palette_colors.(Palette['element3'] * ebr),
          'element4_dis' => quick_palette_colors.(Palette['element4'] * ebr),
          'element5_dis' => quick_palette_colors.(Palette['element5'] * ebr),
          'element6_dis' => quick_palette_colors.(Palette['element6'] * ebr),
          'element7_dis' => quick_palette_colors.(Palette['element7'] * ebr),
          'element8_dis' => quick_palette_colors.(Palette['element8'] * ebr),
          'element9_dis' => quick_palette_colors.(Palette['element9'] * ebr),

          'element0_enb' => quick_palette_colors.(Palette['element0']),
          'element1_enb' => quick_palette_colors.(Palette['element1']),
          'element2_enb' => quick_palette_colors.(Palette['element2']),
          'element3_enb' => quick_palette_colors.(Palette['element3']),
          'element4_enb' => quick_palette_colors.(Palette['element4']),
          'element5_enb' => quick_palette_colors.(Palette['element5']),
          'element6_enb' => quick_palette_colors.(Palette['element6']),
          'element7_enb' => quick_palette_colors.(Palette['element7']),
          'element8_enb' => quick_palette_colors.(Palette['element8']),
          'element9_enb' => quick_palette_colors.(Palette['element9']),
          ### merio palettes
          'red'      => quick_palette_colors.('merio_red'),
          'pink'     => quick_palette_colors.('merio_pink'),
          'green'    => quick_palette_colors.('merio_green'),
          'teal'     => quick_palette_colors.('merio_teal'),
          'lime'     => quick_palette_colors.('merio_lime'),
          'brown'    => quick_palette_colors.('merio_brown'),
          'blue'     => quick_palette_colors.('merio_blue'),
          'yellow'   => quick_palette_colors.('droid_yellow'),
          'orange'   => quick_palette_colors.('merio_orange'),
          'purple'   => quick_palette_colors.('merio_purple'),
          'magenta'  => quick_palette_colors.('merio_magenta'),
          ### pokemon - quick_palette
          #'pkmn-normal'   => quick_palette_colors.('pkmn-normal3'),
          #'pkmn-grass'    => quick_palette_colors.('pkmn-grass3'),
          #'pkmn-water'    => quick_palette_colors.('pkmn-water3'),
          #'pkmn-fire'     => quick_palette_colors.('pkmn-fire3'),
          #'pkmn-bug'      => quick_palette_colors.('pkmn-bug3'),
          #'pkmn-rock'     => quick_palette_colors.('pkmn-rock3'),
          #'pkmn-ground'   => quick_palette_colors.('pkmn-ground3'),
          #'pkmn-electric' => quick_palette_colors.('pkmn-electric3'),
          #'pkmn-flying'   => quick_palette_colors.('pkmn-flying3'),
          #'pkmn-poison'   => quick_palette_colors.('pkmn-poison3'),
          #'pkmn-psychic'  => quick_palette_colors.('pkmn-psychic3'),
          #'pkmn-fight'    => quick_palette_colors.('pkmn-fight3'),
          #'pkmn-ghost'    => quick_palette_colors.('pkmn-ghost3'),
          #'pkmn-ice'      => quick_palette_colors.('pkmn-ice3'),
          #'pkmn-steel'    => quick_palette_colors.('pkmn-steel3'),
          #'pkmn-dark'     => quick_palette_colors.('pkmn-dark3'),
          #'pkmn-dragon'   => quick_palette_colors.('pkmn-dragon3'),
          ### pokemon - convert_palette
          'pkmn-normal'   => from_gauge_palette.('pkmn-normal'),
          'pkmn-grass'    => from_gauge_palette.('pkmn-grass'),
          'pkmn-water'    => from_gauge_palette.('pkmn-water'),
          'pkmn-fire'     => from_gauge_palette.('pkmn-fire'),
          'pkmn-bug'      => from_gauge_palette.('pkmn-bug'),
          'pkmn-rock'     => from_gauge_palette.('pkmn-rock'),
          'pkmn-ground'   => from_gauge_palette.('pkmn-ground'),
          'pkmn-electric' => from_gauge_palette.('pkmn-electric'),
          'pkmn-flying'   => from_gauge_palette.('pkmn-flying'),
          'pkmn-poison'   => from_gauge_palette.('pkmn-poison'),
          'pkmn-psychic'  => from_gauge_palette.('pkmn-psychic'),
          'pkmn-fight'    => from_gauge_palette.('pkmn-fight'),
          'pkmn-ghost'    => from_gauge_palette.('pkmn-ghost'),
          'pkmn-ice'      => from_gauge_palette.('pkmn-ice'),
          'pkmn-steel'    => from_gauge_palette.('pkmn-steel'),
          'pkmn-dark'     => from_gauge_palette.('pkmn-dark'),
          'pkmn-dragon'   => from_gauge_palette.('pkmn-dragon'),
        }

        hsh = Hash[hsh.map { |(s, pal)| [s + "_i", pal] }] if invert

        palette.merge!(hsh)
      end

      cross_hsh = {} # cross palettes
      keys = []
      #keys|= palette.keys
      #keys|= palette.keys.select { |k| !k.end_with?('_i') }
      keys|= ['default', 'default_i', #'txt_default', 'txt_default_i',
              'white', 'white_i', 'black', 'black_i', 'clay', 'clay_i']
      keys.each do |k1| p1 = palette[k1]
        palette.each do |(k2, p2)|
          #next if k1 == k2
          cross_hsh[k1 + "_on_" + k2] = cross_palette.(p1, p2)
        end
      end

      palette.merge!(cross_hsh) # merge single with cross palettes
      palette.each do |(pal_nm, pal)|
        pal.name = pal_nm
        pal.gen_content_pref
        pal.refresh_keys
        calc_text_palette_suggestion(pal)
      end
      #palette.default = palette['default']
      palette
    end
  end
end
