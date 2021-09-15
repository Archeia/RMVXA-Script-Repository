module Hazel
  module Shell::Addons::CursorBase
    attr_reader :cursor_sprite

    def init_shell_addons
      super
      init_cont_cursor
    end

    def dispose_shell_addons
      super
      dispose_cont_cursor
    end

    def update_shell_addons
      super
      update_cont_cursor
    end

    def init_cont_cursor
      @shell_register.register('Shell-Cursor', version: '2.0.0'.freeze)

      @index = 0
      @cursor_sprite = Sprite::ShellCursor.new ownviewport
      @cursor_sprite.blend_type = 1
      init_cursor_state
      refresh_content_cursor

      @shell_callback.add(:redraw, &method(:refresh_content_cursor))
      update_cursor_func = lambda do
        update_cursor_sprite
      end
      @shell_callback.add(:move=, &update_cursor_func)
      @shell_callback.add(:on_set, &update_cursor_func)
      @shell_callback.add(:x=, &update_cursor_func)
      @shell_callback.add(:y=, &update_cursor_func)
      @shell_callback.add(:z=, &update_cursor_func)
      @shell_callback.add(:width=, &update_cursor_func)
      @shell_callback.add(:height=, &update_cursor_func)
      @shell_callback.add(:padding=, &update_cursor_func)

      @shell_callback.add(:visible=) { @cursor_sprite.visible = self.visible }
      @shell_callback.add(:viewport=) { @cursor_sprite.viewport = ownviewport }
    end

    def dispose_cont_cursor
      @cursor_sprite.dispose_all
      @cursor_sprite = nil
    end

    def update_cont_cursor
      process_cursor_move
      process_handling
      @cursor_sprite.update
      ##
      update_cursor_state
      @cursor_sprite.opacity = @_cursor_opacity
    end

    def on_cursor_rect_change(reason = :nil)
      update_cursor_sprite
    end

    def cursor_x
      self.padding + @cursor_rect.x - self.ox
      #((@cursor_sprite.width-@cursor_rect.width)/2) - self.ox
    end

    def cursor_y
      self.padding + @cursor_rect.y - self.oy
      #((@cursor_sprite.height-@cursor_rect.height)/2) - self.oy
    end

    def cursor_z
      self.z + 12
    end

    def content_cursor_scale_on_change?
      false
    end

    def update_cursor_sprite
      if content_cursor_scale_on_change?
        @cursor_sprite.zoom_x = (@cursor_rect.width.to_f / @cursor_rect2.width).clamp(0.0, 1.0)
        @cursor_sprite.zoom_y = (@cursor_rect.height.to_f / @cursor_rect2.height).clamp(0.0, 1.0)
      else
        if (@cursor_rect.width != @cursor_rect2.width) ||
          (@cursor_rect.height != @cursor_rect2.height)
          refresh_content_cursor_bitmap
        end
      end
      @cursor_sprite.x = cursor_x
      @cursor_sprite.y = cursor_y
      @cursor_sprite.z = cursor_z
    end

    include Mixin::CursorState
    alias :update_cursor_state :_update_cursor_state
    undef_method :_update_cursor_state

    def refresh_content_cursor_bitmap
      #w, h = @cursor_rect2.width, @cursor_rect2.height
      #@cursor_rect2.width, @cursor_rect2.height = @cursor_rect.width, @cursor_rect.height
      w, h = @cursor_rect.width, @cursor_rect.height
      @cursor_rect2.width, @cursor_rect2.height = w, h
      ##
      @cursor_sprite.dispose_bitmap_safe
      return unless w > 0 && h > 0
      @cursor_sprite.bitmap = Bitmap.new(w, h)
      redraw_cont_cursor
    end

    def refresh_content_cursor
      @cursor_rect ||= begin
        rect = RectCallback.new(0, 0, item_width, item_height)
        func = method :on_cursor_rect_change
        [:set, :empty, :x, :y, :width, :height].each do |sym|
          rect.add_callback(sym, &func)
        end
        rect
      end
      w, h = @cursor_rect.width, @cursor_rect.height
      @cursor_rect2 = Rect.new 0, 0, w, h
      refresh_content_cursor_bitmap
    end

    def redraw_cont_cursor
      bmp = @cursor_sprite.bitmap
      outline_color = Palette['droid_dark_ui_enb']
      fill_color    = Palette['droid_blue_light'].hset(alpha: 98)
      colors = [outline_color, fill_color]
      DrawExt.draw_box1(bmp, bmp.rect, colors)
    end

    attr_reader :cursor_rect

    def update_cursor
      if @cursor_all
        cursor_rect.set(0, 0, contents.width, row_max * item_height)
        self.top_row = 0
      elsif @index < 0
        cursor_rect.empty
      else
        ensure_cursor_visible
        cursor_rect.set cursor_item_rect(@index)
      end
    end

    def ensure_cursor_visible
      self.top_row = row if row < top_row
      self.bottom_row = row if row > bottom_row
    end

    def cursor_movable?
      active && open? && !@cursor_fix && !@cursor_all && item_max > 0
    end

    def cursor_down(wrap = false)
      if index < item_max - col_max || (wrap && col_max == 1)
        select((index + col_max) % item_max)
      end
    end

    def cursor_up(wrap = false)
      if index >= col_max || (wrap && col_max == 1)
        select((index - col_max + item_max) % item_max)
      end
    end

    def cursor_right(wrap = false)
      if col_max >= 2 && (index < item_max - 1 || (wrap && horizontal?))
        select((index + 1) % item_max)
      end
    end

    def cursor_left(wrap = false)
      if col_max >= 2 && (index > 0 || (wrap && horizontal?))
        select((index - 1 + item_max) % item_max)
      end
    end

    def cursor_pagedown
      if top_row + page_row_max < row_max
        self.top_row += page_row_max
        select([@index + page_item_max, item_max - 1].min)
      end
    end

    def cursor_pageup
      if top_row > 0
        self.top_row -= page_row_max
        select([@index - page_item_max, 0].max)
      end
    end

    def process_cursor_move
      return unless cursor_movable? && !win_busy?
      last_index = @index
      if Input.repeat?(:DOWN) && Input.repeat?(:LEFT)
        cursor_down(Input.trigger?(:DOWN))
        cursor_left(Input.trigger?(:LEFT))
      end
      if Input.repeat?(:DOWN) && Input.repeat?(:RIGHT)
        cursor_down(Input.trigger?(:DOWN))
        cursor_right(Input.trigger?(:RIGHT))
      end
      if Input.repeat?(:UP) && Input.repeat?(:LEFT)
        cursor_up(Input.trigger?(:UP))
        cursor_left(Input.trigger?(:LEFT))
      end
      if Input.repeat?(:UP) && Input.repeat?(:RIGHT)
        cursor_up(Input.trigger?(:UP))
        cursor_right(Input.trigger?(:RIGHT))
      end
      cursor_down(Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
      cursor_up(Input.trigger?(:UP))    if Input.repeat?(:UP)
      cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
      cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
      cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
      cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
      Sound.play_cursor if @index != last_index
    end

    def process_handling
      return unless open? && active && !win_busy?
      return process_ok       if ok_enabled?        && Input.trigger?(:C)
      return process_cancel   if cancel_enabled?    && Input.trigger?(:B)
      return process_pagedown if handle?(:pagedown) && Input.trigger?(:R)
      return process_pageup   if handle?(:pageup)   && Input.trigger?(:L)
    end

    def ok_enabled?
      handle?(:ok)
    end

    def cancel_enabled?
      handle?(:cancel)
    end

    def current_item_enabled?
      return true
    end

    def process_ok
      if current_item_enabled?
        Sound.play_ok
        Input.update
        deactivate
        call_ok_handler
      else
        Sound.play_buzzer
      end
    end

    def call_ok_handler
      call_handler :ok
    end

    def process_cancel
      Sound.play_cancel
      Input.update
      deactivate
      call_cancel_handler
    end

    def call_cancel_handler
      call_handler :cancel
    end

    def process_pageup
      Sound.play_cursor
      Input.update
      deactivate
      call_handler :pageup
    end

    def process_pagedown
      Sound.play_cursor
      Input.update
      deactivate
      call_handler :pagedown
    end
  end
end
