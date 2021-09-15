$simport.r('iss2/parax/spriteset_mix', '1.0.0', 'Mixin for quick inclusion') do |d|
  d.depend!('iss2/parax', '~> 1.0')
end

module ISS2
  module Parax
    module SpritesetMix
      def create_parax
        @parax = SpritesetParallax.new(@viewport1)
      end

      def dispose_parax
        @parax.dispose if @parax
        @parax = nil
      end

      def update_parax
        if @parax
          @parax.update
          @parax.ox = @tilemap.ox
          @parax.oy = @tilemap.oy
        end
      end

      def refresh_parax
        @parax.refresh
      end
    end
  end
end
