#
# EDOS/lib/hazel2/shell/shell.rb
#   by IceDragon
module Hazel
  class Shell

    include Mixin::IDisposable

    attr_accessor :x
    attr_accessor :y
    attr_accessor :z
    attr_accessor :width
    attr_accessor :height
    attr_accessor :depth
    attr_accessor :ox
    attr_accessor :oy
    attr_accessor :oz
    attr_accessor :active
    attr_accessor :visible
    attr_accessor :opacity

   private

    def initialize(*args, &block)
      @x, @y, @z              = 0, 0, 0
      @width, @height, @depth = 0, 0, 0
      @ox, @oy, @oz           = 0, 0, 0
      @active                 = false
      @opacity                = 255
      @visible                = true
      ###
      _set_(*args, &block)
      init_internal
      post_init
    end

    def init_internal
      #
    end

    def post_init
      #
    end

    def _set_(*args,&block)
      x, y, w, h = 0, 0, 0, 0
      case args[0]
      when MACL::Mixin::Surface2
        x, y, w, h = *args[0].to_a
      when Hash
        x, y, w, h = *args[0].get_values(:x, :y, :width, :height)
      else
        x, y, w, h = *args
      end
      @x      = x || @x || 0
      @y      = y || @y || 0
      @width  = w || @width || 0
      @height = h || @height || 0
      return self
    end

   public

    def set(*args, &block)
      _set_(*args, &block)
    end

    def move(x, y, z = 0)
      self.x += x
      self.y += y
      self.z += z
      return self
    end

    def opacity=(n)
      @opacity = n.clamp(0, 255).to_i
    end

    def update
      #
    end

  end
end
