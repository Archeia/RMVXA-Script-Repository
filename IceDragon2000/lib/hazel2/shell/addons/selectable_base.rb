#
# EDOS/lib/shell/addons/selectable_base.rb
#   by IceDragon
#   dc ??/??/????
#   dm 15/06/2013
# vr 2.1.0
#   CHANGELOG
#     vr 2.1.0
#       added #row_index and #col_index
module Hazel
  module Shell::Addons::SelectableBase
    ### mixins
    include Shell::Addons::HandlerBase

    ### instance_attributes
    attr_reader :help_window
    attr_reader :index

    def init_shell_addons
      super
      @shell_register.register 'SelectableBase', version: '2.1.0'.freeze
    end

    def visible_cols
      (self.width - padding * 2) / (item_width + spacing)
    end

    def visible_rows
      (self.height - padding * 2) / (item_height + spacing)
    end

    def col_max
      1
    end

    def spacing
      Metric.spacing
    end

    def item_max
      0
    end

    def row_max
      ((item_max + col_max - 1) / col_max).max(1)
    end

    def row
      return (index / col_max)
    end

    def top_row
      return (oy / item_height)
    end

    def top_row=(row)
      row = 0 if row < 0
      row = row_max - 1 if row > row_max - 1
      self.oy = row * item_height
    end

    def page_row_max
      (height - padding - padding_bottom) / item_height
    end

    def page_item_max
      page_row_max * col_max
    end

    def horizontal?
      page_row_max == 1
    end

    def bottom_row
      top_row + page_row_max - 1
    end

    def bottom_row=(row)
      self.top_row = row - (page_row_max - 1)
    end

    def row_index
      (index / col_max.max(1))
    end

    def col_index
      (index % col_max.max(1))
    end

    def item_width
      (width - standard_padding * 2 + spacing) / col_max - spacing
    end

    def item_height
      line_height
    end

    def item_rect_base(index)
      rect = Rect.new
      rect.width = item_width
      rect.height = item_height
      rect.x = index % col_max * (item_width + spacing)
      rect.y = (index / col_max * item_height)
      rect
    end

    def item_margins
      return 0, 0, 0, 0
    end

    def item_rect(index)
      rect = item_rect_base index
      l, t, r, b = *item_margins
      rect.x += l
      rect.width -= l + r
      rect.y += t
      rect.height -= t + b
      rect
    end

    def item_paddings
      return 0, 0, 0, 0
    end

    def item_rect_for_content(index)
      l, t, r, b = *item_paddings
      rect = item_rect index
      rect.x += l
      rect.width -= l + r
      rect.y += t
      rect.height -= t + b
      rect
    end

    def item_rect_for_text(index)
      rect = item_rect_for_content(index)
      rect.x += 4
      rect.width -= 8
      rect
    end

    def cursor_item_rect(index)
      return item_rect(index)
    end

    def help_window=(help_window)
      @help_window = help_window
      call_update_help
    end

    def active=(active)
      super(active)
      update_cursor
      call_update_help
    end

    def index=(index)
      @index = index
      update_cursor
      call_update_help
    end

    def pred_index(wrap = true)
      self.index = self.index.pred
      self.index = wrap ? self.index.modulo(item_max) : self.index.clamp(0, item_max - 1)
    end

    def succ_index(wrap = true)
      self.index = self.index.succ
      self.index = wrap ? self.index.modulo(item_max) : self.index.clamp(0, item_max - 1)
    end

    def call_update_help
      update_help if active && @help_window
    end

    def update_help
      @help_window.clear
    end

    def select(index)
      self.index = index if index
    end

    def unselect
      self.index = -1
    end

    def draw_all_items
      item_max.times { |i| draw_item(i) }
    end

    def draw_item(index)
      ##
    end

    def clear_item(index)
      contents.clear_rect(item_rect(index))
    end

    def redraw_item(index)
      clear_item(index) if index >= 0
      draw_item(index)  if index >= 0
    end

    def redraw_current_item
      redraw_item(@index)
    end

    def refresh
      contents.clear
      draw_all_items
    end

    ## ~overwrite
    # contents_height
    def contents_height
      h = super
      diff = h % item_height
      [h - diff, row_max * item_height].max
    end
  end
end
