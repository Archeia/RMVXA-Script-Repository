module Automation
  class Zoom < BaseEased
    def setup_values(src, dst)
      src, dst = Array(src), Array(dst)
      src *= 2 if src.size < 2
      dst *= 2 if dst.size < 2
      @src = Convert.Vector2(src)
      @dst = Convert.Vector2(dst)
    end

    def update_value(target, v)
      target.zoom_x = v.x
      target.zoom_y = v.y
    end

    type :zoom
  end
end
