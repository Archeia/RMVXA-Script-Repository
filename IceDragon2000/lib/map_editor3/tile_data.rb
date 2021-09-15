module MapEditor3
  module TileData
    module Flags
      BOTTOM = 0b00001
      LEFT   = 0b00010
      RIGHT  = 0b00100
      TOP    = 0b01000
      DIRS   = BOTTOM | LEFT | RIGHT | TOP
      STAR   = 0b10000
    end

    TILE_A1_RANGE = (2048...2816).freeze
    TILE_A2_RANGE = (2816...4352).freeze
    TILE_A3_RANGE = (4352...5888).freeze
    TILE_A4_RANGE = (5888...8192).freeze
    TILE_A5_RANGE = (1536...1664).freeze
    TILE_B_RANGE  = (0...256).freeze
    TILE_C_RANGE  = (256...512).freeze
    TILE_D_RANGE  = (512...768).freeze
    TILE_E_RANGE  = (768...1024).freeze
    AUTOTILE_RANGE = (2048...8192).freeze # autotile

    AUTOTILE_COUNT = 48
    # waterfalls
    AUTOTILE_2x1_PREVIEW_ID = 3
    # walls
    AUTOTILE_2x2_PREVIEW_ID = 15
    # ground and such
    AUTOTILE_2x3_PREVIEW_ID = 47
    WATERFALL_AUTOTILE_IDS = [5, 7, 9, 11, 13, 15].freeze

    TILE_A_PREVIEW = Table.new(8, 32, 4)
    TILE_A_DATA = Table.new(8, 32)

    # TileA1
    128.times do |i|
      value = 2048 + i * AUTOTILE_COUNT
      x = i % 8
      y = i / 8
      TILE_A_DATA[x, y] = value
      preview_id = case value
      when TILE_A1_RANGE
        # is waterfall?
        if WATERFALL_AUTOTILE_IDS.include?(i)
          AUTOTILE_2x1_PREVIEW_ID
        else
          AUTOTILE_2x3_PREVIEW_ID
        end
      when TILE_A2_RANGE then AUTOTILE_2x3_PREVIEW_ID
      when TILE_A3_RANGE then AUTOTILE_2x2_PREVIEW_ID
      when TILE_A4_RANGE
        # is ceiling?
        if (y % 2) == 0
          AUTOTILE_2x3_PREVIEW_ID
        else
          AUTOTILE_2x2_PREVIEW_ID
        end
      end

      TILE_A_PREVIEW[x, y, 0] = value + preview_id
    end

    offset_i = 128

    # TileA5
    128.times do |i|
      value = TILE_A5_RANGE.first + i
      x = (i + offset_i) % 8
      y = (i + offset_i) / 8
      TILE_A_DATA[x, y] = TILE_A_PREVIEW[x, y, 0] = value
    end

    TILE_B_PREVIEW = Table.new(8, 32, 4)
    TILE_B_DATA = Table.new(8, 32)

    TILE_C_PREVIEW = Table.new(8, 32, 4)
    TILE_C_DATA = Table.new(8, 32)

    TILE_D_PREVIEW = Table.new(8, 32, 4)
    TILE_D_DATA = Table.new(8, 32)

    TILE_E_PREVIEW = Table.new(8, 32, 4)
    TILE_E_DATA = Table.new(8, 32)

    256.times do |i|
      x = i % 8
      y = i / 8
      value = i
      TILE_B_PREVIEW[x, y, 2] = TILE_B_DATA[x, y] = value
      TILE_C_PREVIEW[x, y, 2] = TILE_C_DATA[x, y] = 256 + value
      TILE_D_PREVIEW[x, y, 2] = TILE_D_DATA[x, y] = 512 + value
      TILE_E_PREVIEW[x, y, 2] = TILE_E_DATA[x, y] = 768 + value
    end

    TILE_A_PREVIEW.freeze
    TILE_B_PREVIEW.freeze
    TILE_C_PREVIEW.freeze
    TILE_D_PREVIEW.freeze
    TILE_E_PREVIEW.freeze

    TILE_A_DATA.freeze
    TILE_B_DATA.freeze
    TILE_C_DATA.freeze
    TILE_D_DATA.freeze
    TILE_E_DATA.freeze

    DATAS = [TILE_A_DATA, TILE_B_DATA, TILE_C_DATA, TILE_D_DATA, TILE_E_DATA].freeze
    PREVIEWS = [TILE_A_PREVIEW, TILE_B_PREVIEW, TILE_C_PREVIEW, TILE_D_PREVIEW, TILE_E_PREVIEW].freeze

    module Helper
      def normalize_tile_id(tile_id)
        if tile_id < 2048
          -1
        else
          2048 + ((tile_id - 2048) / 48) * 48
        end
      end

      def same_base_id?(src_tile_id, tile_id)
        normalize_tile_id(src_tile_id) == normalize_tile_id(tile_id)
      end

      def is_a_autotile?(tile_id)
        AUTOTILE_RANGE.include?(tile_id)
      end

      def is_a1_waterfall?(tile_id)
        return false unless TILE_A1_RANGE.include?(tile_id)
        n = normalize_tile_id(tile_id) - TILE_A1_RANGE.first
        # every other water tile is a waterfall
        autotile_id = n / 48
        WATERFALL_AUTOTILE_IDS.include?(autotile_id)
      end

      def is_a4_ceiling?(tile_id)
        return false unless TILE_A4_RANGE.include?(tile_id)
        n = normalize_tile_id(tile_id) - TILE_A4_RANGE.first
        # every other 8 block is a ceiling set
        ((n / 48) / 8) % 2 == 0
      end
    end
  end
end
