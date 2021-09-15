module Mixin
  module MouseSelectable
    def top_rect
      Rect.new(self.x, self.y, self.width, 32)
    end

    def bottom_rect
      Rect.new(self.x, self.y2-32, self.width, 32)
    end

    #alias :pre_mouse_update :update
    #def update
    #  pre_mouse_update
    #
    #end

    def mouse_index?(i)
      Mouse.in_area?(item_rect_to_screen(item_rect(i)).to_v4) && i.between?(0,item_max-1)
    end

    def current_item_to_screen
      item_rect_to_screen(item_rect(self.index))
    end

    def item_rect_to_screen(rect)
      rect = rect.dup
      rect.x = self.x + standard_padding + rect.x - self.ox
      rect.y = self.y + standard_padding + rect.y - self.oy
      rect.height -= 2
      rect
    end

    def cursor_rect_to_screen
      item_rect_to_screen(cursor_rect.to_rect)
    end

    def screen_x2content_x(sx)
      sx - self.x - self.padding + self.ox
    end

    def screen_y2content_y(sy)
      sy - self.y - self.padding + self.oy
    end

    def mouse_in_contents?
      rect = self.contents_rect
      Mouse.x.between?(rect.x, rect.x2) && Mouse.y.between?(rect.y, rect.y2)
    end

    def process_cursor_move
      return unless cursor_movable? && !win_busy?
      last_index = @index
      unless mouse_select_index
        cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
        cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
        cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
        cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
        cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
        cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
      end
      #Sound.play_cursor if @index != last_index
    end

    def mouse_select_index
      return false unless [Mouse.x, Mouse.y] != @last_mouse_pos
      @last_mouse_pos = [Mouse.x, Mouse.y]
      return false unless mouse_in_contents?
      i = calc_col_index(Mouse.x) + (calc_row_index(Mouse.y) * col_max)
      i = i.clamp(0,(item_max-1).max(0))
      self.index = i if i != self.index
      # // LAGGY O_O But kinda works o-e
      #for i in (top_row*col_max)...((top_row*col_max)+page_item_max)
      #  if mouse_index?(i)
      #    self.index = i
      #    return true
      #  end
      #end
      return true
    end

    def calc_col_index(x)
      (screen_x2content_x(x) / (item_width + spacing).to_f).floor
    end

    def calc_row_index(y)
      (screen_y2content_y(y) / (item_height).to_f).floor
    end

    def process_handling
      return unless open? && active && !win_busy?
      if mouse_in_contents?
        return process_ok       if ok_enabled?     && Mouse.trigger?(:left)
        return process_cancel   if cancel_enabled? && Mouse.trigger?(:right)
      end
      return process_ok       if ok_enabled?        && Input.trigger?(:C)
      return process_cancel   if cancel_enabled?    && Input.trigger?(:B)
      return process_pagedown if handle?(:pagedown) && Input.trigger?(:R)
      return process_pageup   if handle?(:pageup)   && Input.trigger?(:L)
    end
  end
end
