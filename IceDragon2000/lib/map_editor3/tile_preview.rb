module MapEditor3
  class TilePreview < TilemapHost
    def create_viewport
      @viewport = Viewport.new(0, 0, 32 * 6, 32)
    end

    def edit_data(data)
      d = Table.new(6, 1, 4)
      # per layer preview = composite preview = src
      d[2, 0, 0] = d[0, 0, 0] = data[0, 0, 0]
      d[3, 0, 1] = d[0, 0, 1] = data[0, 0, 1]
      d[4, 0, 2] = d[0, 0, 2] = data[0, 0, 2]
      d[5, 0, 3] = d[0, 0, 3] = data[0, 0, 3]
      d
    end

    def data=(data)
      @data = data
      @tilemap.map_data = edit_data(@data)
    end
  end
end
