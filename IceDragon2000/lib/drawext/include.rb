#
# EDOS/lib/drawext/include.rb
#   dc 16/06/2013
#   dm 16/06/2013
# vr 2.0.0
module DrawExt
  module Include

  public
    def draw_gauge_base(*args)
      DrawExt.draw_gauge_base(bitmap, *args)
    end

    def draw_gauge_bar(*args)
      DrawExt.draw_gauge_bar(bitmap, *args)
    end

    def draw_gauge_ext(*args)
      DrawExt.draw_gauge_ext(bitmap, *args)
    end

    def draw_gauge_ext_wtxt(*args)
      DrawExt.draw_gauge_ext_wtxt(bitmap, *args)
    end
  end
end
