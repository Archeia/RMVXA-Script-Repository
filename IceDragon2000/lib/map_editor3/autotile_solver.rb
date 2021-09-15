module MapEditor3
  class AutotileSolver
    include TileData::Helper

    def initialize
      @log = Moon::Logfmt::Logger.new
      @log.io = NullIO::OUT
    end

    def yield_sourrounding_tiles(data, x, y, z)
      return to_enum(:yield_sourrounding_tiles, data, x, y, z) unless block_given?
      yield data[x - 1, y - 1, z], x - 1, y - 1, z
      yield data[x, y - 1, z], x, y - 1, z
      yield data[x + 1, y - 1, z], x + 1, y - 1, z
      yield data[x - 1, y, z], x - 1, y, z
      yield data[x, y, z], x, y, z
      yield data[x + 1, y, z], x + 1, y, z
      yield data[x - 1, y + 1, z], x - 1, y + 1, z
      yield data[x, y + 1, z], x, y + 1, z
      yield data[x + 1, y + 1, z], x + 1, y + 1, z
    end

    def sorrounding_tiles(data, x, y, z, &block)
      if block_given?
        yield_sourrounding_tiles(data, x, y, z, &block)
      else
        result = []
        yield_sourrounding_tiles(data, x, y, z) do |d,_,_,_|
          result << d
        end
        result
      end
    end

    def sorrounding_tiles_base(data, x, y, z)
      sorrounding_tiles(data, x, y, z).map do |tile_id|
        normalize_tile_id(tile_id)
      end
    end

    def all_eq?(a, val)
      a.all? { |t| t == val }
    end

    # adjacents are: left, top, right, bottom
    def adjacents(a)
      return a[3], a[1], a[4], a[6]
    end

    # corners are: top-left, top-right, bottom-right, bottom-left
    def corners(a)
      return a[0], a[2], a[7], a[5]
    end

    def adjacent_eq?(a, val)
      all_eq?(adjacents(a), val)
    end

    def corners_eq?(a, val)
      all_eq?(corners(a), val)
    end

    def wrap_aref(c, i)
      c[i % c.size]
    end

    # solves the circular offset using the provided corners
    def circular_offset(c, o)
      @log.write msg: "circular_offset: #{c}, #{o}"
      s = c.size
      t1 = (o) % s
      t2 = (o + 1) % s
      if c[t1] == 0 && c[t2] == 0 then 3
      elsif c[t2] == 0            then 2
      elsif c[t1] == 0            then 1
      else
        0
      end
    end

    def tiles_bac(data, x, y, z, base_id)
      s = sorrounding_tiles_base(data, x, y, z)
      s.delete_at(4) # delete the mid tile
      b = s.map { |t| t == base_id ? 1 : 0 }
      a = adjacents(b)
      c = corners(b)
      return b, a, c
    end

    def bpack(a)
      a.each_with_index.reduce(0) { |r, (v, i)| r | v << i }
    end

    def solve_autotile_ground(data, x, y, z, tile_id)
      base_id = normalize_tile_id(tile_id)
      return tile_id if base_id < 0
      b, a, c = tiles_bac(data, x, y, z, base_id)
      result = base_id

      if all_eq?(b, 1)
        result += 0
      elsif all_eq?(a, 1)
        # adjacent tiles are unaffected
        @log.write msg: "corner_solver: #{c}"
        result += bpack(c) ^ 0b1111
      else
        offset = 16
        @log.write msg: "adjacent_solver: #{a}"
        case bpack(a.reverse)
        # .1.
        # 0 1
        # .1.
        when 0b0111 then offset += circular_offset(c, 1)
        # .0.
        # 1 1
        # .1.
        when 0b1011 then offset += 4 + circular_offset(c, 2)
        # .1.
        # 1 0
        # .1.
        when 0b1101 then offset += 8 + circular_offset(c, 3)
        # .1.
        # 0 1
        # .1.
        when 0b1110 then offset += 12 + circular_offset(c, 0)
        # .1.
        # 0 0
        # .1.
        when 0b0101 then offset += 16
        # .0.
        # 1 1
        # .0.
        when 0b1010 then offset += 17
        # .0.
        # 0 1
        # .1.
        when 0b0011 then offset += c[2] == 1 ? 18 : 19
        # .0.
        # 1 0
        # .1.
        when 0b1001 then offset += c[3] == 1 ? 20 : 21
        # .1.
        # 1 0
        # .0.
        when 0b1100 then offset += c[0] == 1 ? 22 : 23
        # .1.
        # 0 1
        # .0.
        when 0b0110 then offset += c[1] == 1 ? 24 : 25
        # .0.
        # 0 0
        # .1.
        when 0b0001 then offset += 26
        # .0.
        # 0 1
        # .0.
        when 0b0010 then offset += 27
        # .1.
        # 0 0
        # .0.
        when 0b0100 then offset += 28
        # .0.
        # 1 0
        # .0.
        when 0b1000 then offset += 29
        # .0.
        # 0 0
        # .0.
        when 0b0000 then offset += 30
        end
        result += offset
      end

      result
    end

    def solve_autotile_wall(data, x, y, z, tile_id)
      base_id = normalize_tile_id(tile_id)
      return tile_id if base_id < 0
      _, a, _ = tiles_bac(data, x, y, z, base_id)
      # the binary representation is normally backwards...
      case bpack(a.reverse)
      # .1.
      # 1 1
      # .1.
      when 0b1111 then base_id
      # .1.
      # 0 1
      # .1.
      when 0b0111 then base_id + 1
      # .0.
      # 1 1
      # .1.
      when 0b1011 then base_id + 2
      # .0.
      # 0 1
      # .1.
      when 0b0011 then base_id + 3
      # .1.
      # 1 0
      # .1.
      when 0b1101 then base_id + 4
      # .1.
      # 0 0
      # .1.
      when 0b0101 then base_id + 5
      # .0.
      # 1 0
      # .1.
      when 0b1001 then base_id + 6
      # .0.
      # 0 0
      # .1.
      when 0b0001 then base_id + 7
      # .1.
      # 1 1
      # .0.
      when 0b1110 then base_id + 8
      # .1.
      # 0 1
      # .0.
      when 0b0110 then base_id + 9
      # .0.
      # 1 1
      # .0.
      when 0b1010 then base_id + 10
      # .0.
      # 0 1
      # .0.
      when 0b0010 then base_id + 11
      # .1.
      # 1 0
      # .0.
      when 0b1100 then base_id + 12
      # .1.
      # 0 0
      # .0.
      when 0b0100 then base_id + 13
      # .0.
      # 1 0
      # .0.
      when 0b1000 then base_id + 14
      # .0.
      # 0 0
      # .0.
      when 0b0000 then base_id + 15
      else
        fail 'Somehow, the solver has failed to find the correct tile!'
      end
    end

    def solve_autotile_waterfall(data, x, y, z, tile_id)
      base_id = normalize_tile_id(tile_id)
      return tile_id if base_id < 0
      _, a, _ = tiles_bac(data, x, y, z, base_id)
      # with waterfalls you only care about the 2 adjacent sides.
      # if the left side and the right side are the same
      if a[0] == 1 && a[2] == 1
        base_id + 0
      # if the right tile is the same
      elsif a[2] == 1
        base_id + 1
      # if the left tile is the same
      elsif a[0] == 1
        base_id + 2
      # both sides are some other tile
      else
        base_id + 3
      end
    end

    def solve_autotile_a1(data, x, y, z, tile_id)
      @log.write msg: "solving an A1 tile: #{tile_id}"
      if is_a1_waterfall?(tile_id)
        solve_autotile_waterfall(data, x, y, tile_id)
      else
        solve_autotile_ground(data, x, y, z, tile_id)
      end
    end

    def solve_autotile_a2(data, x, y, z, tile_id)
      @log.write msg: "solving an A2 tile: #{tile_id}"
      solve_autotile_ground(data, x, y, z, tile_id)
    end

    def solve_autotile_a3(data, x, y, z, tile_id)
      @log.write msg: "solving an A3 tile: #{tile_id}"
      solve_autotile_wall(data, x, y, z, tile_id)
    end

    def solve_autotile_a4(data, x, y, z, tile_id)
      if is_a4_ceiling?(tile_id)
        @log.write msg: "solving an A4 (ceiling) tile: #{tile_id}"
        solve_autotile_ground(data, x, y, z, tile_id)
      else
        @log.write msg: "solving an A4 (wall) tile: #{tile_id}"
        solve_autotile_wall(data, x, y, z, tile_id)
      end
    end

    def solve(data, x, y, z, tile_id)
      if tile_id < 2048
        tile_id
      else
        r = case tile_id
        when TileData::TILE_A1_RANGE
          solve_autotile_a1(data, x, y, z, tile_id)
        when TileData::TILE_A2_RANGE
          solve_autotile_a2(data, x, y, z, tile_id)
        when TileData::TILE_A3_RANGE
          solve_autotile_a3(data, x, y, z, tile_id)
        when TileData::TILE_A4_RANGE
          solve_autotile_a4(data, x, y, z, tile_id)
        end
        @log.write msg: "solved: (base: #{normalize_tile_id(tile_id)}) #{tile_id} as #{r}"
        r
      end
    end
  end
end
