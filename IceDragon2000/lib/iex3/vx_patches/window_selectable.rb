class Window_Selectable
  protected def ensure_cursor_visible
    row = @index / @column_max
    self.top_row = row if row < top_row
    self.bottom_row = row if row > bottom_row
  end

  protected def update_cursor
    if @cursor_all
      cursor_rect.set(0, 0, contents.width, row_max * item_height)
      self.top_row = 0
    elsif @index < 0
      cursor_rect.empty
    else
      ensure_cursor_visible
      cursor_rect.set item_rect(@index)
    end
  end
end
