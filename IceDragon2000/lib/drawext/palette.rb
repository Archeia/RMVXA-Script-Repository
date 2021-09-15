#
# EDOS/lib/drawext/palette.rb
#   by IceDragon
#   dc 06/07/2013
#   dm 06/07/2013
# vr 1.0.0
module DrawExt
  class DrawExtPalette < MACL::Palette
    def cast_key(sym)
      sym.to_sym
    end
  end
end
