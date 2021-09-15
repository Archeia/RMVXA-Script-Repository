#
# EDOS/lib/fiber_effect/effect/half_slice.rb
#   by IceDragon
#   dc 19/06/2013
#   dm 19/06/2013
# vr 1.0.0
module EDOS
  module FiberEffect
    class HalfSlice < EffectBase

      attr_accessor :sp1
      attr_accessor :sp2

      attr_accessor :slice_size

      def fiber_run
        @time ||= Graphics.frame_rate * 2
        @slice_size ||= [sp1.width, sp2.width].max
        mw = slice_size
        delta = (mw / time.to_f)
        rdelta = delta.round
        t = @time
        org1_x = sp1.x
        org2_x = sp2.x
        while t > 0
          t -= 1
          sp1.x = org1_x - delta * (@time - t)
          sp2.x = org2_x + delta * (@time - t)
          Fiber.yield
        end
        super
      end

    end
  end
end
