module DrawExt
#==============================================================================#
# ◙ Experimental Functions
#/============================================================================\#
# ● Functions in this section should be used with care.
#   In addition they are never included with the DrawExt::Include module
#\============================================================================/#
  def self.draw_diamond( info )
    bitmap        = info[:bitmap]
    color         = info[:color] || Color.new( 20, 20, 20 )
    x, y          = info[:x] || 0, info[:y] || 0
    width, height = info[:width] || 32, info[:height] || 32
    bmp = Bitmap.new( width, height )
    hw, hh = (width/2), (height/2)
    if info[:hollow] == true
      for dx in 0...hw
        bmp.set_pixel( hw-dx, dx, color )
        bmp.set_pixel( hw+(hw-dx), hh-dx, color )
        bmp.set_pixel( dx, hh+(dx), color )
        bmp.set_pixel( hw+dx, hh+(hh-dx), color )
      end
    else
      for dx in 0...hw
        for dy in 0...hh
          bmp.set_pixel( hw+dx, dy, color ) if dx < dy
          bmp.set_pixel( dx, hh+dy, color ) if dy < dx
          bmp.set_pixel( dx, hh-dy, color ) if dy < dx
          bmp.set_pixel( hw+hw-dx-1, hh+dy, color ) if dy < dx
        end
      end
    end
    if info[:return_only] == true
      return bmp
    else
      bitmap.blt( x, y, bmp, bmp.rect )
    end
  end
end
