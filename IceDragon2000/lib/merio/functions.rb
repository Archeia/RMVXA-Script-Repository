#
# EDOS/lib/drawext/merio/merio.rb
#   by IceDragon
# vr 1.3.0
#   CHANGELOG
#     vr 1.3.0
#       A DrawExt::Merio::DrawContext must be created in order to use the
#       merio functions, the Singleton behaviour has been removed.
#
#     vr 1.2.0
#       added #align_label
#       added #align_gauge
#         Both new settings for the default alignment of objects
#
#     vr 1.1.1
#       added #copy_settings
#         This method allows you to copy the settings from one Merio object
#         to the current one
###
module DrawExt
  module Merio
    class SnapshotError < RuntimeError ; end
    class BitmapError < RuntimeError ; end
    module Functions
      ### instance_attributes
      attr_reader :bitmap
      attr_writer :merio_settings

      @@setting_symbols = [:font_scale, :font_size, :font_name,
                           :main_palette, :txt_palette, :gauge_palette,
                           :active_shade, :active_state,
                           :border_anchor, :border_size,
                           :fill_type, :align_label, :align_gauge]

      @@setting_symbols.each do |sym|
        globname = "glob_#{sym}".to_sym
        define_method(sym.to_s) do
          merio_settings[sym] || DrawExt::Merio.send(globname)
        end
        define_method(sym.to_s + "=") do |other|
          merio_settings[sym] = other
        end
      end

      ##
      # ::setting_symbols
      def self.setting_symbols
        @@setting_symbols
      end

      ##
      # font -> Font
      def font
        @bitmap.font
      end

      ##
      # change_bitmap(Bitmap new_bitmap)
      #   When a block is provided, the bitmap will be swapped and the context
      #   will be yielded
      #   once the block execution is complete, the bitmap is restored to its
      #   original bitmap
      def change_bitmap(new_bitmap)
        old_bitmap = @bitmap
        @bitmap = new_bitmap
        if block_given?
          yield self
          @bitmap = old_bitmap
        end
        return self
      end

      ##
      # change_main_palette(Object new_palette)
      #   Change the current main palette, this function will also change
      #   the txt_palette using the #text_palette_suggestion from the
      #   #main_palette.
      #   To change only the main_palette, use #main_palette=
      def change_main_palette(new_palette)
        self.main_palette = new_palette
        self.txt_palette  = self.main_palette.text_palette_suggestion
        return self
      end

      ##
      # check_bitmap
      def check_bitmap
        raise BitmapError, "invalid bitmap" unless @bitmap && !@bitmap.disposed?
        true
      end

      ##
      # solve_palette(Object* obj)
      def solve_palette(obj)
        case obj
        when nil            then return nil
        when String, Symbol then obj = DrawExt::Merio.palettes[obj.to_s]
        end
        MACL::Palette.assert_type(obj)
        return obj
      end

      def merio_settings
        @merio_settings ||= {}
      end

      ##
      # main_palette=(MACL::Palette new_palette)
      def main_palette=(new_palette)
        merio_settings[:main_palette] = solve_palette(new_palette)
      end

      ##
      # txt_palette=(MACL::Palette new_palette)
      def txt_palette=(new_palette)
        merio_settings[:txt_palette] = solve_palette(new_palette)
      end

      ##
      # gauge_palette=(MACL::Palette new_palette)
      def gauge_palette=(new_palette)
        merio_settings[:gauge_palette] = solve_palette(new_palette)
      end

      ##
      # active_state=(Symbol new_state)
      def active_state=(new_state)
        merio_settings[:active_state] = new_state == true ? :enb :
                       (new_state == false ? :dis : new_state)
      end

      ### merio helper functions
      ##
      # calc_half_rects(Rect rect)
      def calc_half_rects(rect)
        r = Convert.Rect(rect)
        r1 = r.dup
          r1.width /= 2
        r2 = r.dup
          r2.width -= r1.width
          r2.x += r1.width
        return r, r1, r2
      end

      ##
      # calc_tile_rect
      def calc_tile_rect(rect, cols=1, rows=1)
        tile_rect = rect.dup
        tile_rect.width  *= cols
        tile_rect.height *= rows
        return tile_rect
      end

      ##
      # ui_font_size(Symbol sym)
      def ui_font_size(sym)
        sz = 0
        Metric.snap_scale do |m|
          m.scale = font_scale
          sz = m.ui_font_size(sym)
        end
        return Integer(sz)
      end

      ##
      # state_stack -> Array<*>
      def state_stack
        @state_stack ||= []
      end

      ##
      # copy_settings(other)
      def copy_settings(other)
        self.merio_settings = other.merio_settings.dup
      end

      ##
      # clear_settings
      def clear_settings
        merio_settings.clear
      end

      ##
      # restore
      def restore
        old_state = state_stack.pop
        raise SnapshotError, "no snapshot to restore from" unless old_state
        @@setting_symbols.each do |sym|
          merio_settings[sym] = old_state[sym]
        end
      end

      ##
      # snapshot
      def snapshot
        state = merio_settings.dup
        state_stack.push(state)
        if block_given?
          yield self
          restore
        end
      end

      ##
      # global_expand
      #   Snapshots the current and global context, copies the settings from
      #   self into the Global context and yields control to the caller
      def global_expand
        DrawExt::Merio.snapshot do
          snapshot do
            DrawExt::Merio.copy_settings(self)
            yield self
          end
        end
      end

      ##
      # font_config_abs(Symbol shade, Symbol size_sym, Symbol state)
      def font_config_abs(font, shade, size_sym, state)
        ### state fix
        state = state == true ? :enb : (state == false ? :dis : state)
        state||= active_state
        self.active_state = state
        # size
        self.font_size = size_sym || font_size
        size = ui_font_size(font_size)
        # shade
        shade ||= active_shade
        self.active_shade = shade
        # color
        color_str = "%<shade>s_ui_%<state>s" % { shade: shade, state: state }
        color = shade ? txt_palette[color_str] : Font.default_color
        #
        #font.default!
        font.name         = font_name
        font.size         = size
        font.color        = color
        #font.antialias = false
        return font
      end

      def font_config(shade, size_sym, state)
        font = self.font
        font_config_abs(font, shade, size_sym, state)
      end

      ##
      # met_font_config(Symbol shade, Symbol state)
      def met_font_config(shade, state)
        return font_config(shade, font_size, state)
      end

      ##
      # new_font(Symbol shade, Symbol size_sym, Symbol state)
      def new_font(*args)
        font = Font.new
        return font_config_abs(font, *args)
      end

      ##
      # color_state_mod(Color color_pnt, bool enabled, int alpha)
      def color_state_mod(color_pnt, enabled=active_state, alpha=255)
        case enabled
        when :enb, true  then color_pnt.alpha = alpha * 0.8
        when :dis, false then color_pnt.alpha = alpha * 0.3
        end
      end

      ### draw_*
      ##
      # draw_fill_rect(Rect rect, Color color)
      def draw_fill_rect(rect, color, _fill_type = fill_type)
        bmp = self.bitmap
        rect = Convert.Rect(rect) unless rect.is_a?(Rect) # Rect#try_cast
        return if rect.empty?
        case _fill_type
        ## default style
        when :null
        when :flat, :default
          bmp.fill_rect(rect, color)
        when :round
          bmp.round_fill_rect(rect, color)
        when :blend
          bmp.blend_fill_rect(rect, color)
        when :blend_round
          bmp.round_blend_fill_rect(rect, color)
        when :smooth, :smooth_round
          ## smooth style
          color2 = color.blend.darken(0.08) # kinda heavy
          r1 = rect.dup
          r2 = r1.contract(anchor: border_anchor, amount: border_size)
          if _fill_type == :smooth
            ## block
            bmp.blend_fill_rect(r1, color2)
            bmp.blend_fill_rect(r2, color)
          elsif _fill_type == :smooth_round
            ## rounded
            bmp.round_blend_fill_rect(r1, color2)
            bmp.round_blend_fill_rect(r2, color)
          end
        else
          raise ArgumentError, "invalid fill_type #{_fill_type}"
        end
        return rect
      end

      ##
      # draw_shade_rect(Rect rect, Symbol shade)
      def draw_shade_rect(rect, shade=active_shade, state=active_state)
        draw_fill_rect(rect, main_palette["#{shade}_ui_#{state}"])
      end

      ##
      # draw_dark_rect(Rect rect, [Symbol state])
      def draw_dark_rect(rect, state=active_state)
        draw_shade_rect(rect, :dark, state)
      end

      ##
      # draw_light_rect(Rect rect, [Symbol state])
      def draw_light_rect(rect, state=active_state)
        draw_shade_rect(rect, :light, state)
      end

      ##
      # draw_fmt_num(Rect rect, String int, FormatString fmt)
      def draw_fmt_num(rect, int, fmt="%03d", align=align_label)
        bmp = self.bitmap
        met_font_config(:light, :enb)
        # calculate the largest rect from numbers
        num = (0...9).max_by do |i| bmp.text_size(i.to_s).width end
        maxrect = bmp.text_size(num.to_s)
        sz = int.to_s.size
        rs = rect.contract(anchor: MACL::Surface::ANCHOR_CENTER,
                           amount: Metric.contract)
        (fmt % int).split('').reverse.each_with_index do |c, ci|
          bmp.font.color = txt_palette[:light_ui_enb]
          bmp.font.color = txt_palette[:light_ui_dis] if ci >= sz
          bmp.draw_text(rs, c, 2)
          rs.width -= maxrect.width
        end
        return rs
      end

      ##
      # draw_checkbox(Rect rect, Boolean state)
      def draw_checkbox(rect, state)
        r1 = MACL::Surface::Tool.squarify(rect)
        r2 = r1.contract(anchor: 5, amount: 1)
        draw_dark_rect(r1)
        draw_light_rect(r2) if state
        return rect
      end

      ##
      # draw_switch(Rect rect, Boolean state)
      def draw_switch(rect, state)
        r, r1, r2 = calc_half_rects(rect)
        rs = (state ? r2 : r1).contract(anchor: 5, amount: 1)
        draw_dark_rect(r)
        draw_light_rect(rs)
        return r, r1, r2
      end

      ##
      # draw_switch_w_label(Rect rect, Boolean state,
      #                     String label_off, String label_on)
      #   Draws both labels
      def draw_switch_w_label(rect, state, label_off, label_on)
        bmp = self.bitmap
        r, r1, r2 = draw_switch(rect, state)
        font.snapshot do
          met_font_config(state ? :light : :dark, :enb)
          bmp.draw_text(r1, label_off, align_label)
          met_font_config(!state ? :light : :dark, :enb)
          bmp.draw_text(r2, label_on, align_label)
        end
      end

      ##
      # draw_switch_w_label1(Rect rect, Boolean state
      #                      String label_off, String label_on)
      #   Draws only the opposite label
      def draw_switch_w_label1(rect, state, label_off, label_on)
        bmp = self.bitmap
        r, r1, r2 = draw_switch(rect, state)
        bmp.font.snapshot do
          met_font_config(:light, :enb)
          bmp.draw_text(state ? r1 : r2, state ? label_off : label_on, align_label)
        end
      end

      ##
      # draw_switch_w_label2(Rect rect, Boolean state
      #                      String label_off, String label_on)
      #   Draws only the state label
      def draw_switch_w_label2(rect, state, label_off, label_on)
        bmp = self.bitmap
        r, r1, r2 = draw_switch(rect, state)
        bmp.font.snapshot do
          met_font_config(:dark, :enb)
          bmp.draw_text(!state ? r1 : r2, !state ? label_off : label_on, align_label)
        end
      end

      ##
      # draw_pair_back(Rect rect)
      def draw_pair_back(rect)
        r, r1, r2 = calc_half_rects(rect)
        draw_light_rect(r1)
        draw_dark_rect(r2)
        return r, r1, r2
      end

      ##
      # draw_dark_label(Rect rect, String label_s)
      # draw_dark_label(Rect rect, String label_s, ALIGN align)
      def draw_dark_label(rect, label_s, align=align_label)
        bmp = self.bitmap
        draw_dark_rect(rect)
        font.snapshot do
          met_font_config(:light, :enb)
          bmp.draw_text(rect.contract(anchor: MACL::Surface::ANCHOR_CENTER,
                                      amount: Metric.contract), label_s, align)
        end
      end

      ##
      # draw_light_label(Rect rect, String label_s)
      # draw_light_label(Rect rect, String label_s, ALIGN align)
      def draw_light_label(rect, label_s, align=align_label)
        bmp = self.bitmap
        draw_light_rect(rect)
        bmp.font.snapshot do
          met_font_config(:dark, :enb)
          bmp.draw_text(rect.contract(anchor: MACL::Surface::ANCHOR_CENTER,
                                      amount: Metric.contract), label_s, align)
        end
      end

      ##
      # draw_pair(Rect rect, String label_s, String value_s)
      def draw_pair(rect, label_s, value_s)
        bmp = self.bitmap
        r, r1, r2 = draw_pair_back(rect)
        font.snapshot do
          met_font_config(:dark, :enb)
          bmp.draw_text(r1.contract(anchor: MACL::Surface::ANCHOR_CENTER,
                                    amount: Metric.contract), label_s, align_label)
          met_font_config(:light, :enb)
          bmp.draw_text(r2.contract(anchor: MACL::Surface::ANCHOR_CENTER,
                                    amount: Metric.contract), value_s, align_label)
        end
        return r, r1, r2
      end

      ##
      # draw_pair_fmt(Rect rect, String label_s,
      #               String int, FormatString fmt)
      def draw_pair_fmt(rect, label_s, int, fmt="%03d")
        bmp = self.bitmap
        r, r1, r2 = draw_pair_back(rect)
        # draw the label
        font.snapshot do
          met_font_config(:dark, :enb)
          bmp.draw_text(r1.contract(anchor: MACL::Surface::ANCHOR_CENTER,
                                    amount: Metric.contract), label_s, align_label)
          draw_fmt_num(r2, int, fmt)
        end
        return r, r1, r2
      end

      ##
      # draw_gauge(Rect rect, Float rate, Boolean vertical, Integer align)
      def draw_gauge(rect, rate=1.0, vertical=false, align=align_gauge)
        r = DrawExt.calc_gauge_rect(rect, rate, vertical, align)
        draw_dark_rect(rect)
        draw_light_rect(r)
        return rect, r
      end

      ##
      # draw_gauge2(Rect rect)
      def draw_gauge2(rect, rate=1.0, vertical=false, align=align_gauge)
        r = DrawExt.calc_gauge_rect(rect, rate, vertical, align)
        r.contract!(anchor: 5, amount: 1)
        draw_dark_rect(rect)
        draw_light_rect(r)
        return rect, r
      end

      ##
      # draw_label_w_gauge(Rect rect, String label, Rate rate
      #                    Boolean vertical, Integer align)
      def draw_label_w_gauge(rect, label, rate, vertical=false, align=align_gauge)
        r, r1, r2 = calc_half_rects(rect)
        draw_light_label(r1, label)
        draw_gauge(r2, rate, vertical, align)
      end

      ##
      # draw_light_tile(Rect rect)
      def draw_light_tile(rect, cols=1, rows=1)
        tile_rect = calc_tile_rect(rect, cols, rows)
        draw_light_rect(tile_rect)
      end

      ##
      # draw_dark_tile(Rect rect)
      def draw_dark_tile(rect, cols=1, rows=1)
        tile_rect = calc_tile_rect(rect, cols, rows)
        draw_dark_rect(tile_rect)
      end

      ##
      # draw_fixed_grid(Bitmap bmp, Rect rect, int cols, int rows)
      #   Draws a fixed width and height grid to the target bitmap
      #   The (width) and height are taken from the (rect)
      def draw_fixed_grid(rect, cols, rows, shade=active_shade, state=active_state)
        rect = Convert.Rect(rect)
        w = rect.width
        h = rect.height
        rows.times do |y|
          cols.times do |x|
            draw_shade_rect(r.step(6, x).step(2, y), shade, state)
          end
        end
      end

      ##
      # draw_dynamic_grid(Rect rect, int cols, int rows)
      #   Draws a dynamic grid, the (width) and (height) represent the total (width)
      #   and (height) of the grid
      #   The (width) and (height) are taken from the (rect)
      def draw_dynamic_grid(rect, cols, rows, shade=active_shade, state=active_state)
        rect = Convert.Rect(rect)
        rect.width = rect.width / cols
        rect.height = rect.height / rows
        draw_fixed_grid(r, cols, rows, shade, state)
      end

      ##
      # @param [Rect] rect          | rect used for the size and position of the matrix
      # @param [Table] matrix       | matrix with all the data
      # @param [Boolean] background | should the background be drawn?
      def draw_matrix(rect, matrix, background=false, shade=active_shade, state=active_state)
        rect = Convert.Rect(rect)
        rect.width  = rect.width / matrix.xsize
        rect.height = rect.height / matrix.ysize
        matrix.ysize.times do |y|
          matrix.xsize.times do |x|
            r = rect.step(6, x).step(2, y)
            draw_shade_rect(r, shade, state) if background
            yield r, x, y, matrix[x, y]
          end
        end
      end

    end

    ### extensions
    extend Functions

    ### class_variables
    @@glob_merio_settings = {
      font_scale: 1.0,
      font_size: :default,
      font_name: nil,
      main_palette: nil,
      txt_palette: nil,
      gauge_palette: nil,
      fill_type: :smooth,
      active_state: :enb,
      active_shade: :light,
      align_label: 1,
      align_gauge: 0,
      border_anchor: 5,
      border_size: 1
    }

    class << self
      @@glob_merio_settings.each_key do |s|
        globname = "glob_" + s.to_s
        define_method(globname) do
          @@glob_merio_settings[s]
        end
        define_method(globname + "=") do |other|
          @@glob_merio_settings[s] = other
        end
      end
    end

    def self.glob_merio_settings
      @@glob_merio_settings
    end

    def self.glob_font_name
      @@glob_merio_settings[:font_name] || Font.default_name
    end

    def self.glob_main_palette=(new_palette)
      @@glob_merio_settings[:main_palette] = solve_palette(new_palette)
    end

    def self.glob_txt_palette=(new_palette)
      @@glob_merio_settings[:txt_palette] = solve_palette(new_palette)
    end

    def self.glob_gauge_palette=(new_palette)
      @@glob_merio_settings[:gauge_palette] = solve_palette(new_palette)
    end
  end
end
