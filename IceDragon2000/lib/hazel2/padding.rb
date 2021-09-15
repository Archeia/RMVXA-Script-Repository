#
# EDOS/lib/hazel2/padding.rb
#   by IceDragon
module Hazel
  class Padding
    attr_accessor :left
    attr_accessor :right
    attr_accessor :bottom
    attr_accessor :top

    def initialize(t = 1, r = nil, b = nil, l = nil)
      @top    = t
      @right  = r || @top
      @bottom = b || @top
      @left   = l || @top
    end

    def set(t, r, b, l)
      @top    = t
      @right  = r
      @bottom = b
      @left   = l
      self
    end

    def to_a
      return @top, @right, @bottom, @left
    end

    def to_i
      return @top
    end

    def [](index)
      case index
      when 0 then @top
      when 1 then @right
      when 2 then @bottom
      when 3 then @left
      else
        raise ArgumentError, "index out of range (expected 0...4)"
      end
    end

    def []=(index, n)
      case index
      when 0 then @top    = n
      when 1 then @right  = n
      when 2 then @bottom = n
      when 3 then @left   = n
      else
        raise ArgumentError, "index out of range (expected 0...4)"
      end
    end

    def calc_surface(rect)
      r = rect.dup

      r.x     += @left
      r.width -= @left
      r.width -= @right

      r.y      += @top
      r.height -= @top
      r.height -= @bottom

      return r
    end
  end
end
