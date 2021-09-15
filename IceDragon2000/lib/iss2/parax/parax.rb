$simport.r('iss2/parax', '1.0.0', 'An automatic Parallax mapping system')

module ISS2
  module Parax
    class SpritesetParallax
      attr_accessor :logger
      attr_reader :ox
      attr_reader :oy
      attr_reader :viewport

      def initialize(viewport)
        @logger = Moon::Logfmt::NullLogger
        @viewport = viewport
        @ox = 0
        @oy = 0
        @layers = []
        create_layers
      end

      def game_map
        $game_map
      end

      def add_layer(bmp, z)
        layer = Plane.new(@viewport)
        layer.z = z
        layer.ox = @ox
        layer.oy = @oy
        layer.bitmap = bmp
        @layers << layer
      end

      def create_layer(basename, z)
        map_id = game_map.map_id
        @logger.write msg: 'Attemping to load Parallax Map',
                      map_id: map_id, basename: basename, z: z
        begin
          bmp = Cache.parallax_map "#{basename}#{map_id}"
          add_layer bmp, z
        rescue => ex
          @logger.write err: ex.inspect
          return
        end
      end

      def create_layers
        create_layer 'ground', 1
        create_layer 'par', 900
      end

      def dispose_layers
        @layers.each(&:dispose)
        @layers.clear
      end

      def dispose
        dispose_layers
      end

      def update_layers
        @layers.each(&:update)
      end

      def update
        update_layers
      end

      def ox=(ox)
        @ox = ox
        @layers.each { |l| l.ox = @ox }
      end

      def oy=(oy)
        @oy = oy
        @layers.each { |l| l.oy = @oy }
      end

      def viewport=(viewport)
        @viewport = viewport
        @layers.each { |l| l.viewport = @viewport }
      end

      def refresh
        dispose_layers
        create_layers
      end
    end
  end
end
