module Mixin
  module SmoothCursor
    def init_smooth_cursor
      @_cursor_tweener = MACL::Tween::Multi.new
      @target_cursor_rect = Rect.new(0, 0, 0, 0)
    end

    def update_smooth_cursor
      @_cursor_tweener.update
      cursor_rect.set(*@_cursor_tweener.values)
    end

    def smooth_update_cursor
      rect = @target_cursor_rect
      if @cursor_all
        rect.set(0, 0, contents.width, row_max * item_height)
        self.top_row = 0
      elsif @index < 0
        cursor_rect.empty
        rect.empty
      else
        ensure_cursor_visible
        rect.set(cursor_item_rect(@index))
      end
      set_smooth_cursor
    end

    def set_smooth_cursor
      if @_last_cursor != a = [@index, item_max, col_max, @cursor_all, active]
        easers = [:sine_inout, :sine_inout, :sine_out, :sine_out]
        times  = Array.new(4) { Metric::Time.sec_to_frame(0.12) }
        cra    = cursor_rect.to_a
        tcra   = @target_cursor_rect.to_a
        @_cursor_tweener.clear()
        for i in 0...4
          tween = MACL::Tween2.new(times[i], easers[i], [cra[i], tcra[i]])
          @_cursor_tweener.add_tween(tween)
        end
        @_last_cursor = a
      end
    end
  end
end
