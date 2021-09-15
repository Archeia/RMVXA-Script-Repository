module Automation
  class Resize < BaseEased
    def setup_values(src, dst)
      @src, @dst = Convert.Vector2(src), Convert.Vector2(dst)
    end

    def update_value(target, v)
      target.width  = v.x
      target.height = v.y
    end

    type :resize
  end
end
