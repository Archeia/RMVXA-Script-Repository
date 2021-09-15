module MapEditor3
  class Sprite_EditorCursor
    attr_reader :viewport
    attr_reader :visible
    attr_reader :cursor

    def initialize(cursor, viewport)
      @visible = true
      @cursor = cursor
      @viewport = viewport
      @sprite = Sprite_BaseCursor.new(@viewport)
      @overlay = Sprite_CursorOverlay.new(@cursor, @viewport)
      @sprites = [@sprite, @overlay]
    end

    def on_cursor_move
      @overlay.refresh
    end

    def on_cursor_change
      @overlay.cursor = @cursor
    end

    def dispose
      @sprites.each(&:dispose)
    end

    def set_position(x, y, z)
      @sprites.each do |s|
        s.x = x
        s.y = y
        s.z = z
      end
    end

    def update
      set_position(@cursor.screen_x, @cursor.screen_y, @cursor.screen_z)
      @sprites.each(&:update)
    end

    def visible=(visible)
      @visible = visible
      @sprite.visible = @visible
    end

    def viewport=(viewport)
      @viewport = viewport
      @sprite.viewport = @viewport
    end

    def cursor=(cursor)
      @cursor = cursor
      on_cursor_change
    end
  end
end
