module MapEditor3
  class MapDataOptimizer
    def remove_invalid_tiles(data)
      data.ysize.times do |y|
        data.xsize.times do |x|
          2.times do |z|
            # invalid data in A layers
            tile_id = data[x, y, z]
            if tile_id.between?(0, 1536 - 1) || tile_id.between?(1664, 2048 - 1)
              puts "removing invalid A layer data (#{tile_id}) at: #{[x, y, z]}"
              data[x, y, z] = 0
            end
          end
          # invalid data in the B..E layer
          if data[x, y, 2] >= 1024
            puts "removing invalid BCDE layer data (#{tile_id}) at: #{[x, y]}"
            data[x, y, 2] = 0
          end
        end
      end
    end

    def flatten_a_layers(data)
      data.ysize.times do |y|
        data.xsize.times do |x|
          if data[x, y, 1] >= 1536
            tile_id = data[x, y, 1]
            puts "flattening A layer data (#{tile_id}) at: #{[x, y]}"
            data[x, y, 0] = tile_id
            data[x, y, 1] = 0
          end
        end
      end
    end

    def run(data)
      remove_invalid_tiles(data)
      flatten_a_layers(data)
    end
  end
end
