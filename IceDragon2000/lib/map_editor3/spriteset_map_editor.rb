module MapEditor3
  class Spriteset_MapEditor < Spriteset_Map
    attr_reader :viewport1
    attr_reader :viewport2
    attr_reader :viewport3
    attr_reader :tilemap
    attr_accessor :editor

    def initialize(editor)
      @editor = editor
      super()
    end

    def on_cursor_move
      @cursor.on_cursor_move
    end

    def create_editor_cursor
      @cursor = Sprite_EditorCursor.new(@editor.cursor, @viewport1)
    end

    def create_grid_overlay
      @grid_overlay = Plane.new(@viewport1)
      @grid_overlay.bitmap = Bitmap.new(128, 128)
      ctx = DrawContext.new(@grid_overlay.bitmap)
      r = @grid_overlay.bitmap.rect.dup
      r.y += 1
      ctx.grid(r, Rect.new(0, 0, 32, 32), Color.new(32, 32, 32, 128))
      r.y -= 1
      ctx.grid(r, Rect.new(0, 0, 32, 32), Color.new(255, 255, 255, 128))
    end

    def create_all
      super
      create_editor_cursor
      create_grid_overlay
    end

    def dispose_editor_cursor
      @cursor.dispose
    end

    def dispose_grid_overlay
      @grid_overlay.bitmap.dispose
      @grid_overlay.dispose
    end

    def dispose
      dispose_editor_cursor
      dispose_grid_overlay
      super
    end

    def update_editor_cursor
      @cursor.update
    end

    def update_grid_overlay
      @grid_overlay.ox = @tilemap.ox
      @grid_overlay.oy = @tilemap.oy
    end

    def update
      super
      update_editor_cursor
      update_grid_overlay
    end

    def highlight_characters
      @character_sprites.each do |c|
        c.color = Color.new(0, 196, 0, 64)
      end
    end

    def unhighlight_characters
      @character_sprites.each do |c|
        c.color = Color.new(0, 0, 0, 0)
      end
    end
  end

  class Window_EditorInfo
    attr_accessor :editor
    attr_reader :viewport

    def initialize(editor, viewport = nil)
      @editor = editor
      @viewport = viewport
      create_tile_preview
      create_character_preview
    end

    def on_cursor_move
      chars = @editor.characters_at_cursor
      @character_preview.character = chars.first
      @tile_preview.data = @editor.tile_data_at_cursor
    end

    def create_tile_preview
      @tile_preview = TilePreview.new
      @tile_preview.flags = @editor.map.tileset.flags
      @tile_preview.viewport.z = @viewport.z
      load_tilesets
    end

    def load_tilesets
      @editor.map.tileset.tileset_names.each_with_index do |name, i|
        @tile_preview.bitmaps[i] = Cache.tileset(name)
      end
    end

    def create_character_preview
      @character_preview = CharacterPreview.new(@tile_preview.viewport)
    end

    def dispose
      @tile_preview.dispose
      @character_preview.dispose
    end

    def update
      @tile_preview.update
      @character_preview.update
    end
  end
end
