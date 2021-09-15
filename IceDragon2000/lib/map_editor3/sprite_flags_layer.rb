module MapEditor3
  class Sprite_FlagsLayer < Sprite_Base
    attr_reader :flags
    attr_reader :tile_data

    def initialize(viewport = nil)
      super viewport
    end

    def dispose
      dispose_bitmap_safe
      super
    end

    def refresh
      unless @tile_data && @flags
        dispose_bitmap_safe
        return
      end
      w = @tile_data.xsize * 32
      h = @tile_data.ysize * 32
      if !bitmap || (bitmap.width != w) || (bitmap.height != h)
        dispose_bitmap_safe
        self.bitmap = Bitmap.new(w, h)
      else
        bitmap.clear
      end
      ctx = DrawContext.new(bitmap)
      @tile_data.ysize.times do |y|
        @tile_data.xsize.times do |x|
          ctx.passage_icon(x * 32, y * 32, @flags[@tile_data[x, y]])
        end
      end
    end

    def tile_data=(tile_data)
      @tile_data = tile_data
      refresh
    end

    def flags=(flags)
      @flags = flags
      refresh
    end
  end
end
