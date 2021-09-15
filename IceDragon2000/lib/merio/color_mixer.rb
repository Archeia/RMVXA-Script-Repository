module DrawExt
  module Merio
    class ColorMixer
      private def make
        c = Color.new
        yield c
        c
      end

      def clamp_i(a)
        [[a, 0].max, 255].min
      end

      def iadd_i(a, b)
        clamp_i(a + b)
      end

      def iadd(color, int)
        make do |c|
          c.red = iadd_i(color.red, int)
          c.green = iadd_i(color.green, int)
          c.blue = iadd_i(color.blue, int)
        end
      end

      def iadda(color, int)
        c = iadd(color, int)
        c.alpha = iadd_i(color.alpha, int)
        c
      end

      def isub_i(a, b)
        clamp_i(a - b)
      end

      def isub(color, int)
        make do |c|
          c.red = isub_i(color.red, int)
          c.green = isub_i(color.green, int)
          c.blue = isub_i(color.blue, int)
        end
      end

      def isuba(color, int)
        c = isub(color, int)
        c.alpha = isub_i(color.alpha, int)
        c
      end

      def imul_i(a, b)
        clamp_i(a * b / 255)
      end

      def imul(color, int)
        make do |c|
          c.red = imul_i(color.red, int)
          c.green = imul_i(color.green, int)
          c.blue = imul_i(color.blue, int)
        end
      end

      def imula(color, int)
        c = imul(color, int)
        c.alpha = imul_i(color.alpha, int)
        c
      end

      def idiv_i(a, b)
        clamp_i((a * 255) / [b, 1].max)
      end

      def idiv(color, int)
        make do |c|
          c.red = idiv_i(color.red, int)
          c.green = idiv_i(color.green, int)
          c.blue = idiv_i(color.blue, int)
        end
      end

      def idiva(color, int)
        c = idiv(color, int)
        c.alpha = idiv_i(color.alpha, int)
        c
      end

      def fadd_f(a, b)
        clamp_i(a + b * 255)
      end

      def fadd(color, flt)
        make do |c|
          c.red = fadd_f(color.red, flt)
          c.green = fadd_f(color.green, flt)
          c.blue = fadd_f(color.blue, flt)
        end
      end

      def fadda(color, flt)
        c = fadd(color, flt)
        c.alpha = fadd_f(color.alpha, flt)
        c
      end

      def fsub_f(a, b)
        clamp_i(a - b * 255)
      end

      def fsub(color, flt)
        make do |c|
          c.red = fsub_f(color.red, flt)
          c.green = fsub_f(color.green, flt)
          c.blue = fsub_f(color.blue, flt)
        end
      end

      def fsuba(color, flt)
        c = fsub(color, flt)
        c.alpha = fsub_f(color.alpha, flt)
        c
      end

      def fmul_f(a, b)
        clamp_i(a * b)
      end

      def fmul(color, flt)
        make do |c|
          c.red = fmul_f(color.red, flt)
          c.green = fmul_f(color.green, flt)
          c.blue = fmul_f(color.blue, flt)
        end
      end

      def fmula(color, flt)
        c = fmul(color, flt)
        c.alpha = fmul_f(color.alpha, flt)
        c
      end

      def fdiv_f(a, b)
        clamp_i(a / b)
      end

      def fdfv(color, flt)
        make do |c|
          c.red = fdiv_f(color.red, flt)
          c.green = fdiv_i(color.green, flt)
          c.blue = idiv_i(color.blue, flt)
        end
      end

      def fdiva(color, flt)
        c = fdiv(color, flt)
        c.alpha = fdiv_f(color.alpha, flt)
        c
      end

      def lerp_i(a, b, d)
        clamp_i(a + (b - a) * d)
      end

      def lerp(a, b, d)
        make do |c|
          c.red = lerp_i(a.red, b.red, d)
          c.green = lerp_i(a.green, b.green, d)
          c.blue = lerp_i(a.blue, b.blue, d)
        end
      end

      def lerpa(a, b, d)
        make do |c|
          c.red = lerp_i(a.red, b.red, d)
          c.green = lerp_i(a.green, b.green, d)
          c.blue = lerp_i(a.blue, b.blue, d)
          c.alpha = lerp_i(a.alpha, b.alpha, d)
        end
      end

      def fset_a(color, a)
        make do |c|
          c.red = color.red
          c.green = color.green
          c.blue = color.blue
          c.alpha = a * 255
        end
      end
    end
  end
end
