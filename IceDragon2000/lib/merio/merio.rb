require 'merio/functions'
require 'merio/color_mixer'
require 'merio/palette_cache'
require 'merio/context'

module DrawExt
  module Merio
    class MerioPalette < DrawExt::DrawExtPalette
      attr_accessor :content_pref
      attr_accessor :text_palette_suggestion

      def dark_main?
        self[:light_ui_enb].shade_dark?
      end

      def dark_sub?
        self[:dark_ui_enb].shade_dark?
      end

      def light_main?
        self[:light_ui_enb].shade_light?
      end

      def light_sub?
        self[:dark_ui_enb].shade_light?
      end

      def gen_content_pref
        reg = /([A-Za-z0-9]+)(_i)?(_on_)?(?:([A-Za-z0-9]+)(_i)?)?/
        name.scan(reg) do |nm1, is_i1, is_on, nm2, is_i2|
          @content_pref = {
            main: nm1,
            main_invert: !!is_i1,
            dual: !!is_on,
            sub: nm2,
            sub_invert: !!is_i2
          }
        end
      end
    end

    extend MACL::Mixin::Log

    ### class_variables
    @@palettes = {}

    def self.init
      #filename = DataManager.make_path_with_filename('merio_palette.rbd')
      #@@palettes = load_data_cin(filename) do
      #  rebuild_palette_cache
      #end
      @@palettes = rebuild_palette_cache(true)
      default = @@palettes['default']
      txt_default = @@palettes['txt_default']
      DrawExt::Merio.glob_main_palette  = default
      DrawExt::Merio.glob_txt_palette   = txt_default
      DrawExt::Merio.glob_gauge_palette = default
      palette_log!(true)
    end

    def self.palette_log!(lite=true)
      try_log do |l|
        sz   = @@palettes.size
        unless lite
          sn_c = @@palettes.count { |(k, pal)| !pal.content_pref[:dual] }
          dl_c = sz - sn_c
          minv_c = @@palettes.count { |(k, pal)| pal.content_pref[:main_invert] }
          sinv_c = @@palettes.count { |(k, pal)| pal.content_pref[:sub_invert] }
          ainv_c = @@palettes.count { |(k, pal)| pal.content_pref[:main_invert] ||
                                                pal.content_pref[:sub_invert] }
          finv_c = @@palettes.count { |(k, pal)| pal.content_pref[:main_invert] &&
                                                pal.content_pref[:sub_invert] }
          mcolors = @@palettes.map { |(_, pal)| pal.content_pref[:main] }.uniq.compact
          scolors = @@palettes.map { |(_, pal)| pal.content_pref[:sub] }.uniq.compact
          colors = (mcolors | scolors).uniq
        end
        l.puts("Merio Palette Size: #{sz}")
        unless lite
          l.puts("  Single Count: #{sn_c}")
          l.puts("  Dual Count: #{dl_c}")
          l.puts("  Main Inverted Count: #{minv_c}")
          l.puts("  Sub Inverted Count: #{sinv_c}")
          l.puts("  Any Inverted Count: #{ainv_c}")
          l.puts("  Full Inverted Count: #{finv_c}")
          l.puts("  Color Count: #{colors.size}")
          l.puts("  Colors: #{colors.inspect}")
          l.puts("  Main Color Count: #{mcolors.size}")
          l.puts("  Main Colors: #{mcolors.inspect}")
          l.puts("  Sub Color Count: #{scolors.size}")
          l.puts("  Sub Colors: #{scolors.inspect}")
        end
      end
    end

    ##
    # ::calc_text_palette_suggestion(MACL::Palette pal)
    def self.calc_text_palette_suggestion(pal)
      cpf = pal.content_pref
      nm1, nm2 = cpf[:main], cpf[:sub]
      sug = 'default'
      is_i1 = pal.light_main?
      is_i2 = pal.light_sub?
      #
      sug = (is_i2 ? 'default_i' : 'default')
      sug.concat("_on_")
      sug.concat(is_i1 ? 'default_i' : 'default')
      pal.text_palette_suggestion = sug
    end

    ##
    # ::palettes
    def self.palettes
      @@palettes
    end
  end
end
