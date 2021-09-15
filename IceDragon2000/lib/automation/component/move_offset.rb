module Automation
  class MoveOffset < BaseEased
    def use_change?
      true
    end

    def setup_values(src, dst)
      @src, @dst = Convert.Vector2(src), Convert.Vector2(dst)
    end

    def update_value_by_change(target, ch)
      target.ox += ch.x
      target.oy += ch.y
    end

    type :move_offset
  end
end
