module MapEditor3
  class Sprite_CursorOverlay < Sprite_Base
    attr_reader :cursor

    def initialize(cursor, viewport)
      @cursor = cursor
      super(viewport)
      self.bitmap = Bitmap.new(32, 32)
      bitmap.font.size = 12
      bitmap.font.outline = false
      bitmap.font.name = ['Arial']
    end

    def dispose
      bitmap.dispose
      super
    end

    def refresh
      #chars = @cursor.characters_at_cursor
      bitmap.clear
      str = "%d, %d" % [@cursor.x, @cursor.y]
      bitmap.fill_rect(1, 1, 30, 30, Color.new(32, 32, 32, 96))
      bitmap.draw_text(2, 2, 32, 12, str)
    end

    def on_cursor_change
      refresh
    end

    def cursor=(cursor)
      @cursor = cursor
      on_cursor_change
    end
  end
end
