#encoding:UTF-8
# ISS010 - Transfer Ref
module ISS
  module TransferRef

    MAPID_VAR = 32
    MAPX_VAR  = 33
    MAPY_VAR  = 34

    class TransHandler

      attr_accessor :map_id
      attr_accessor :entry_points

      def initialize(map_id)
        @map_id       = map_id
        @entry_points = {}
      end

      def etp
        return @entry_points
      end

      def etp=(value)
        @entry_points = value
      end

    end

    class EntryPoint

      attr_accessor :x
      attr_accessor :y

      def initialize(x, y)
        @x, @y = x, y
      end

    end

    EP = EntryPoint

    module_function()

    def get_map_id(tag)
      return TRANSFER_LIST[tag].map_id
    end

    def get_entry_point(tag, trans_id)
      return TRANSFER_LIST[tag].entry_points[trans_id]
    end

    def setup_transfer(tag, trans_id)
      map_id = get_map_id(tag)
      point  = get_entry_point(tag, trans_id)
      $game_variables[MAPID_VAR] = map_id
      $game_variables[MAPX_VAR]  = point.x
      $game_variables[MAPY_VAR]  = point.y
    end

  end
end

Tref = ISS::TransferRef
