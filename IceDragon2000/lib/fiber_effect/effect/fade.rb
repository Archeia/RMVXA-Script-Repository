#
# EDOS/lib/fiber_effect/fade.rb
#   by IceDragon
#   dc 19/06/2013
#   dm 19/06/2013
# vr 1.0.0
module EDOS
  module FiberEffect
    class Fade < EffectBase

      attr_accessor :sp
      attr_accessor :fade_type

      def fiber_run
        @time ||= Graphics.frame_rate * 2
        @fade_type ||= :out
        delta = 255 / time.to_f
        op = sp.opacity
        t = @time
        while t > 0
          if @fade_type == :out
            sp.opacity -= delta
          elsif @fade_type == :in
            sp.opacity += delta
          end
          t -= 1
          Fiber.yield
        end
        super
      end

    end
  end
end
