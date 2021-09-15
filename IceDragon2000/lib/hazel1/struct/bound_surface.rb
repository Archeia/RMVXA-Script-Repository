#
# EDOS/src/hazel/struct/bound_surface.rb
#   by IceDragon
#   dc 03/04/2013
#   dc 03/04/2013
# vr 1.0.0
#
# A Bounded surface, used for keeping the surface within a specified bounds
module Hazel
  class BoundSurface < MACL::Surface

    attr_accessor :bounds, :auto_bound

    def initialize(*args, &block)
      super(*args, &block)
      @auto_bound = true
    end

    def bound_do
      old_bound = @auto_bound
      @auto_bound = false
      yield self
      @auto_bound = old_bound
      refresh_bound
    end

    def refresh_bound
      MACL::Surface::Tool.bound_surface_to(self, bounds) if bounds
    end

    def x=(new_x)
      super(new_x)
      refresh_bound if @auto_bound
    end

    def y=(new_y)
      super(new_y)
      refresh_bound if @auto_bound
    end

    def x2=(new_x2)
      super(new_x2)
      refresh_bound if @auto_bound
    end

    def y2=(new_y2)
      super(new_y2)
      refresh_bound if @auto_bound
    end

  end
end