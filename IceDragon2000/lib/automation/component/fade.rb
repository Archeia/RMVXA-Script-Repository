module Automation
  class Fade < BaseEased
    def update_value(target, v)
      target.opacity = v
    end

    type :fade
  end
end
