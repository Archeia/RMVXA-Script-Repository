module Automation
  class MovetoOffset < BaseEased
    def setup_values(src, dst)
      @src, @dst = Convert.Vector2(src), Convert.Vector2(dst)
    end

    def update_value(target, v)
      target.ox = v.x
      target.oy = v.y
    end

    type :moveto_offset
  end
end
