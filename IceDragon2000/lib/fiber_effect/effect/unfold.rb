#
# EDOS/lib/fiber_effect/effect/unfold.rb
#   by IceDragon
#   dc 09/06/2013
#   dm 14/06/2013
# vr 1.1.0
module EDOS
  module FiberEffect
    class Unfold < EffectBase

      attr_accessor :sp1, :sp2, :spacer

      def update_pos
        spacer.x = sp1.x2
        sp1.cy   = spacer.cy
        sp2.x    = spacer.x2
        sp2.cy   = spacer.cy
      end

      def fiber_run
        ## setup
        main_unfold_ticks = 60.0
        sub_unfold_ticks = 60.0

        main_ticks = 0.0
        sub_ticks = 0.0

        sp1.src_rect.width = 0
        sp2.src_rect.width = 0

        while sp1.src_rect.width < sp1.bitmap.width
          sp1.src_rect.width = sp1.bitmap.width * (main_ticks / main_unfold_ticks)
          update_pos
          main_ticks += 1.0
          Fiber.yield
        end

        sp1.src_rect.width = sp1.bitmap.width

        while sp2.src_rect.width < sp2.bitmap.width
          sp2.src_rect.width = sp2.bitmap.width * (sub_ticks / sub_unfold_ticks)
          sp2.src_rect.x = sp2.bitmap.width - sp2.src_rect.width
          update_pos
          sub_ticks += 1.0
          Fiber.yield
        end

        sp2.src_rect.x = 0
        sp2.src_rect.width = sp2.bitmap.width

        super
      end

    end
  end
end
