module MapEditor3
  class Editor
    attr_reader :map
    attr_reader :cursor
    attr_accessor :player
    attr_reader :tile_palette

    def initialize
      @map = nil
      @player = nil
      @tile_palette = TilePalette.new
      @cursor = MapCursor.new
      @cursor.map = @map
    end

    def refresh
      @map.refresh
    end

    def update(main = false)
      @map.update(main)
      @player.update
      @cursor.update
    end

    def tile_data_at(x, y)
      data = Table.new(1, 1, @map.data.zsize)
      data.zsize.times do |z|
        data[0, 0, z] = @map.data[x, y, z]
      end
      data
    end

    def tile_data_at_cursor
      tile_data_at(@cursor.x, @cursor.y)
    end

    def characters_at(x, y)
      list = @map.events_xy(x, y)
      list
    end

    def characters_at_cursor
      characters_at(@cursor.x, @cursor.y)
    end

    def map=(map)
      @map = map
      @cursor.map = @map
    end

    def write_tile_id_at(tile_id, x, y, z)
      if tile_id > 1024
        asolve = AutotileSolver.new
        # set center tile
        @map.data[x, y, z] = asolve.solve(@map.data, x, y, z, tile_id)
        # now solve all sorrounding tiles
        asolve.sorrounding_tiles(@map.data, x, y, z) do |n, dx, dy, dz|
          @map.data[dx, dy, dz] = asolve.solve(@map.data, dx, dy, dz, n)
        end
      else
        # is a tileB..tileE
        @map.data[x, y, z] = tile_id
      end
    end

    def write_tile_id(tile_id, z)
      write_tile_id_at(tile_id, @cursor.x, @cursor.y, z)
    end

    def write_tile(tile)
      if tile.is_a?(Table)
        tile.zsize.times do |z|
          write_tile_id(tile[0, 0, z], z)
        end
      else
        write_tile_id(tile, tile > 1024 ? 0 : 2)
      end
    end

    def write_current_tile
      write_tile(@tile_palette.tile)
    end

    def erase_current_tile
      @map.data.zsize.times do |z|
        @map.data[@cursor.x, @cursor.y, z] = 0
      end
    end

    def copy_current_tile
      @tile_palette.tile = tile_data_at_cursor
    end

    def swap_palette
      @tile_palette.swap
    end
  end
end
