module MapEditor3
  class TilemapHost
    attr_reader :viewport
    attr_reader :data
    attr_reader :flags
    attr_reader :x
    attr_reader :y
    attr_reader :visible

    def initialize
      init_properties
      create_all
      start
    end

    def on_flags_change
      @tilemap.flags = @flags
    end

    def hide
      self.visible = false
    end

    def show
      self.visible = true
    end

    def start
      self.x = 0
      self.y = 0
      self.visible = true
    end

    def content_width
      (@data && @data.xsize * 32) || 0
    end

    def content_height
      (@data && @data.ysize * 32) || 0
    end

    def init_properties
      @visible = true
      @x = 0
      @y = 0
    end

    def create_viewport
      @viewport = Viewport.new
    end

    def create_tilemap
      @tilemap = Tilemap.new(@viewport)
    end

    def create_graphics
      create_viewport
      create_tilemap
    end

    def create_all
      create_graphics
    end

    def dispose_tilemap
      @tilemap.dispose
    end

    def dispose_viewport
      @viewport.dispose
    end

    def dispose_graphics
      dispose_tilemap
      dispose_viewport
    end

    def dispose
      dispose_graphics
    end

    def update_viewport
      @viewport.update
    end

    def update_tilemap
      @tilemap.update
    end

    def update_graphics
      update_viewport
      update_tilemap
    end

    def update
      update_graphics
    end

    def x=(x)
      @x = x
      @viewport.x = x
    end

    def y=(y)
      @y = y
      @viewport.y = y
    end

    def bitmaps
      @tilemap.bitmaps
    end

    def bitmaps=(bitmaps)
      @tilemap.bitmaps = bitmaps
    end

    def data=(data)
      @data = data
      @tilemap.map_data = @data
    end

    def flags=(flags)
      @flags = flags
      on_flags_change
    end

    def visible=(visible)
      @visible = visible
      @viewport.visible = @visible
    end
  end
end
