module Automation
  class Colorizer < BaseEased
    def setup_values(src, dst)
      @src, @dst = Convert.Color(src), Convert.Color(dst)
    end

    def update_value(target, v)
      target.color = v
    end

    type :colorizer
  end
end
