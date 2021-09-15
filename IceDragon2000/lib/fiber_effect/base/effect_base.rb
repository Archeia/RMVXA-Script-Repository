#
# EDOS/lib/fiber_effect/effect_base.rb
#   by IceDragon
#   dc 09/06/2013
#   dm 14/06/2013
# vr 1.1.0
module EDOS
  module FiberEffect
    class EffectBase

      attr_accessor :time

      def done?
        !!@done
      end

      def run
        @done = false
        @fiber = Fiber.new { fiber_run }
      end

      def terminate
        @fiber = nil
      end

      def rerun
        terminate
        run
      end

      def update
        @fiber.resume if @fiber
      end

      def fiber_run
        @done = true
        terminate
      end

      private :fiber_run

    end
  end
end