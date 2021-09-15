#
$simport.r 'iek/surface_micro', '1.0.0', 'A smaller version of rm-macl\'s Surface'

module Mixin
  module SurfaceMicro
    ##
    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] z
    #   @optional
    # @return [self]
    def moveto(x, y, z=nil)
      self.x = x
      self.y = y
      self.z = z if z
      self
    end

    ##
    # @param [Integer] ox
    # @param [Integer] oy
    # @return [self]
    def set_origin(ox, oy)
      self.ox = ox
      self.oy = oy
      self
    end

    ##
    # @param [Integer] w
    # @param [Integer] h
    # @return [self]
    def resize(w, h)
      self.width = w
      self.height = h
      self
    end

    ##
    # @return [Integer]
    def x2
      x + width
    end

    ##
    # @param [Integer] x2
    def x2=(x2)
      self.x = x2 - width
    end

    ##
    # @return [Integer]
    def y2
      y + height
    end

    ##
    # @param [Integer] y2
    def y2=(y2)
      self.y = y2 - height
    end

    ##
    # center-x coordinate
    # @return [Integer]
    def cx
      x + width / 2
    end

    ##
    # @param [Integer] cx
    def cx=(cx)
      self.x = cx - width/2
    end

    ##
    # center-y coordinate
    # @return [Integer]
    def cy
      y + height / 2
    end

    ##
    # @param [Integer] cy
    def cy=(cy)
      self.y = cy - height/2
    end

    ##
    # final-x coordinate
    # @return [Integer]
    def fx
      rx = x - ox
      if viewport
        rx += viewport.rect.x
        rx -= viewport.ox
      end
      rx
    end

    ##
    # final-y coordinate
    # @return [Integer]
    def fy
      ry = y - oy
      if viewport
        ry += viewport.rect.y
        ry -= viewport.oy
      end
      ry
    end

    ##
    # final-center-x coordinate
    # @return [Integer]
    def fcx
      rx = x - ox
      if viewport
        rx += viewport.rect.x
        rx -= viewport.ox
      end
      rx += width / 2
      rx
    end

    ##
    # final-center-y coordinate
    # @return [Integer]
    def fcy
      ry = y - oy
      if viewport
        ry += viewport.rect.y
        ry -= viewport.oy
      end
      ry += height / 2
      ry
    end
  end
end
