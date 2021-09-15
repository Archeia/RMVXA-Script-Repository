module MapEditor3
  class TilePalette
    attr_accessor :tile
    attr_accessor :tile_alt

    def initialize
      @tile = 0
      @tile_alt = 0
    end

    def swap
      @tile, @tile_alt = @tile_alt, @tile
    end
  end
end
