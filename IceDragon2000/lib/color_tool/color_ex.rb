#
# EDOS/lib/mixin/color.rb
#   by IceDragon
#   dm 27/03/2013
# vr 2.1.0
module Mixin
  module ColorEx
    extend MACL::Mixin::Archijust

    class Blend
      attr_accessor :color

      def initialize(color)
        @color = color
      end

      def none(obj)
        @color
      end

      [
        :alpha,
        :add,
        :subtract,
        :screen,
        :multiply,
        :divide,
        :overlay,
        :softlight,
        :dodge,
        :burn,
        :alpha
      ].each do |meth|
        methname = "blend_#{meth}"
        define_method(meth.to_s + "!") do |obj|
          @color.set(ColorTool.send(methname, @color, obj))
        end
        define_method(meth) do |obj|
          @color.dup.blend.send(meth.to_s + "!", obj)
        end
      end

      def lighten!(rate)
        add!((255 * rate).to_i)
      end

      def lighten(rate)
        @color.dup.blend.lighten!(rate)
      end

      def darken!(rate)
        subtract!((255 * rate).to_i)
      end

      def darken(rate)
        @color.dup.blend.darken!(rate)
      end

      def median!
        v = ColorTool.get_mid_v(@color)
        @color.set(v, v, v, @color.alpha)
        @color
      end

      def median
        @color.dup.blend.median!
      end

      def average!
        vmax = ColorTool.get_max_v(@color)
        vmin = ColorTool.get_min_v(@color)
        v = (vmax + vmin) / 2.0
        @color.set(v, v, v, @color.alpha)
        @color
      end

      def average
        @color.dup.blend.average!
      end

      def self_add!(rate)
        c = @color.dup
        c.red   *= rate
        c.green *= rate
        c.blue  *= rate
        add!(rate)
      end

      def self_subtract!(rate)
        c = @color.dup
        c.red   *= rate
        c.green *= rate
        c.blue  *= rate
        subtract!(c)
      end

      def self_add(rate)
        @color.dup.blend.self_add!(rate)
      end

      def self_subtract(rate)
        @color.dup.blend.self_subtract!(rate)
      end
    end

    def hset(hsh)
      self.red   = hsh[:red]   || self.red
      self.green = hsh[:green] || self.green
      self.blue  = hsh[:blue]  || self.blue
      self.alpha = hsh[:alpha] || self.alpha
      self
    end

    def blend
      if !@blend || !@blend.color.equal?(self)
        @blend = Blend.new(self)
      end
      return @blend
    end

    def lumf
      ColorTool.calc_lumf(self)
    end

    def from_lum(l)
      ColorTool.new_lum(self, l)
    end

    def shade_dark?
      lumf < 0.5
    end

    def shade_light?
      !shade_dark?
    end

    #[
    #  :none,
    #  :alpha,
    #  :add,
    #  :subtract,
    #  :screen,
    #  :multiply,
    #  :divide,
    #  :overlay,
    #  :softlight,
    #  :dodge,
    #  :burn,
    #  :lighten,
    #  :darken,
    #  :self_add,
    #  :self_subtract
    #].each do |meth|
    #  methname = "blend_#{meth}"
    #  define_exfunc(methname) do |obj|
    #    puts "> Use of #{methname} is depreceated please use #blend.#{meth} instead"
    #    blend.send(meth, obj)
    #    self
    #  end
    #end

    define_exfunc('lerp') do
      |color, rate|

      s, t, r = self.to_a, color.to_a, self.to_a # // Self, Target, Result

      for i in 0...s.size
        r[i] = (s[i] - ((s[i] - t[i]) * rate)).clamp(s[i].min(t[i]), s[i].max(t[i]))
      end

      self.red   = r[0]
      self.green = r[1]
      self.blue  = r[2]
      self.alpha = r[3]

      return self
    end
  end
end
