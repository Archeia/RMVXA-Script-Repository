module MapEditor3
  class DrawContext
    class Spritesheet
      attr_reader :bitmap
      attr_reader :cell_width
      attr_reader :cell_height

      def initialize(bitmap, cw, ch)
        @cell_width, @cell_height = cw, ch
        @bitmap = bitmap
        @cols = @bitmap.width / @cell_width
      end

      def draw(dst, x, y, index, sy = nil)
        sx = index
        unless sy
          sx = index % @cols
          sy = (index / @cols)
        end
        dst.blt(x, y, @bitmap, Rect.new(sx * @cell_width, sy * @cell_height,
                                        @cell_width, @cell_height))
      end

      def call(*args)
        draw(*args)
      end
    end

    attr_accessor :bitmap

    def initialize(bitmap)
      @bitmap = bitmap
    end

    # @param [Rect] rect
    # @param [Rect] cell_sizes
    def grid(rect, cell_sizes, color)
      x, y = rect.x, rect.y
      w, h = rect.w, rect.h
      cw, ch = cell_sizes.w, cell_sizes.h
      cols = w / cw
      rows = h / ch

      cols.times do |c|
        @bitmap.fill_rect(x + c * cw, y, 1, h, color)
      end

      rows.times do |r|
        @bitmap.fill_rect(x, y + r * ch, w, 1, color)
      end

      rect
    end

    def rect_outline(rect, color, s = 1)
      @bitmap.fill_rect(rect, color)
      @bitmap.clear_rect(rect.x + s, rect.y + s, rect.width - s * 2, rect.height - s * 2)
    end

    def passage_icon(x, y, flag)
      s = Spritesheet.new(Cache.spritesheet('passage_icons'), 32, 32)
      if flag.flagged?(TileData::Flags::STAR)
        s.draw(@bitmap, x, y, 4)
      end

      s.draw(@bitmap, x, y, flag.flagged?(TileData::Flags::BOTTOM) ? 2 : 6, 7)
      s.draw(@bitmap, x, y, flag.flagged?(TileData::Flags::LEFT) ? 3 : 7, 7)
      s.draw(@bitmap, x, y, flag.flagged?(TileData::Flags::RIGHT) ? 1 : 5, 7)
      s.draw(@bitmap, x, y, flag.flagged?(TileData::Flags::TOP) ? 0 : 4, 7)
    end
  end
end
