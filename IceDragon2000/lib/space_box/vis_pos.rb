#
# EDOS/lib/class/sprite.rb
#   by IceDragon
#   dc 22/06/2013
#   dm 22/06/2013
# vr 1.0.0
module Mixin
  module VisPos
    #### experimental
    ### visible x|y (in short where the sprite is actually drawn)
    def visx
      self.x - self.ox
    end

    def visy
      self.y - self.oy
    end

    def visx2
      self.x2 - self.ox
    end

    def visy2
      self.y2 - self.oy
    end
  end
end
