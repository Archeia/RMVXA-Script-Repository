module Hazel
  class Shell::Command < Shell::WindowSelectable
    def initialize(x, y)
      clear_command_list
      make_command_list
      super x, y, window_width, window_height
      refresh
      select(0)
      activate
    end

    def window_width
      return 160
    end

    def window_height
      fitting_height(visible_line_number)
    end

    def visible_line_number
      item_max / col_max
    end

    def item_max
      @list.size
    end

    def clear_command_list
      @list = []
    end

    def make_command_list
    end

    def add_command(name, symbol, enabled = true, ext = nil)
      @list.push({:name=>name, :symbol=>symbol, :enabled=>enabled, :ext=>ext})
    end

    def command_name(index)
      @list[index][:name]
    end

    def command_enabled?(index)
      @list[index][:enabled]
    end

    def current_data
      index >= 0 ? @list[index] : nil
    end

    def current_item_enabled?
      current_data ? current_data[:enabled] : false
    end

    def current_symbol
      current_data ? current_data[:symbol] : nil
    end

    def current_ext
      current_data ? current_data[:ext] : nil
    end

    def select_symbol(symbol)
      @list.each_index {|i| select(i) if @list[i][:symbol] == symbol }
    end

    def select_ext(ext)
      @list.each_index {|i| select(i) if @list[i][:ext] == ext }
    end

    def draw_item(index)
      rect = item_rect_for_text(index)
      artist do |art|
        art.change_color(contents.font.color, command_enabled?(index))
        art.draw_text(rect, command_name(index), alignment)
      end
    end

    def alignment
      return 0
    end

    def ok_enabled?
      return true
    end

    def call_ok_handler
      if handle?(current_symbol)
        call_handler(current_symbol)
      elsif handle?(:ok)
        super
      else
        activate
      end
    end

    def refresh
      clear_command_list
      make_command_list
      create_contents
      super
    end
  end
end
