module Automation
  class Moveto < BaseEased
    def setup_values(src, dst)
      @src, @dst = Convert.Vector2(src), Convert.Vector2(dst)
    end

    def update_value(target, v)
      target.x = v.x
      target.y = v.y
    end

    type :moveto
  end
end
