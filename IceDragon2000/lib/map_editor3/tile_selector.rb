module MapEditor3
  class TileSelectorBackground
    attr_reader :viewport

    def initialize(viewport = nil)
      @viewport = viewport
      @plane = Plane.new(@viewport)
      @plane.z = -100
      @plane.bitmap = Bitmap.new(32, 32)

      cols = 2
      rows = 2
      colors = [Color.new(96, 96, 96, 255), Color.new(168, 168, 168, 255)]
      rows.times do |y|
        cols.times do |x|
          i = x + y
          @plane.bitmap.fill_rect(x * 16, y * 16, 16, 16, colors[i % colors.size])
        end
      end
    end

    def dispose
      @plane.dispose_bitmap
      @plane.dispose
    end

    def update
      @plane.update
    end
  end

  class TileSelector < TilemapHost
    attr_reader :controller
    attr_reader :page

    def init_properties
      super
      @page = 0
    end

    def page_count
      MapEditor3::TileData::DATAS.size
    end

    def start
      super
      self.page = @page
    end

    def create_cursors
      @cursors = Array.new(page_count) { RectCursor.new }
      @cursor = @cursors[@page]
      @cursors.each { |c| c.on_move = method(:on_cursor_move) }
    end

    def create_controller
      @controller = Game_CharacterController.new
      @controller.character = @cursor
      @controller.deactivate
    end

    def create_background
      @background = TileSelectorBackground.new(@viewport)
    end

    def create_cursor_sprite
      @cursor_sprite = Sprite_EditorCursor.new(@cursor, @viewport)
    end

    def create_graphics
      super
      create_background
      create_cursor_sprite
    end

    def create_all
      super
      create_cursors
      create_controller
      create_graphics
    end

    def on_cursor_move
      @cursor_sprite.on_cursor_move
      h = @viewport.height
      hh = h / 2
      cy = (@cursor.y + 1) * 32
      @viewport.oy = [[cy - hh, 0].max, content_height - h].min
    end

    def on_page_change
      @tile_data = MapEditor3::TileData::DATAS[@page]
      self.data = MapEditor3::TileData::PREVIEWS[@page]
      @cursor = @cursors[@page]
      @cursor.rect = @tile_data.to_rect
      @cursor_sprite.cursor = @cursor
      @controller.character = @cursor
      on_cursor_move
    end

    def create_viewport
      @viewport = Viewport.new(0, 32, 8 * 32, Graphics.height - 32)
    end

    def dispose_background
      @background.dispose
    end

    def dispose_cursor_sprite
      @cursor_sprite.dispose
    end

    def dispose_graphics
      dispose_background
      dispose_cursor_sprite
      super
    end

    def tile_id
      @tile_data[@cursor.x, @cursor.y]
    end

    def page_prev
      self.page = (@page - 1) % page_count
    end

    def page_next
      self.page = (@page + 1) % page_count
    end

    def process_ok
    end

    def process_cancel
    end

    def process_handling
      process_ok if Input.trigger?(:C)
      process_cancel if Input.trigger?(:B)
      page_prev if Input.trigger?(:L)
      page_next if Input.trigger?(:R)
    end

    def update_controller
      @controller.update
    end

    def process_cursor_move
      update_controller
      @cursor.update
    end

    def update_graphics
      super
      @background.update
      @cursor_sprite.update
    end

    def update
      process_cursor_move
      process_handling
      super
    end

    def page=(page)
      @page = page
      on_page_change
    end
  end
end
