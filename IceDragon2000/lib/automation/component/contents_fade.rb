module Automation
  class ContentsFade < BaseEased
    def update_value(target, v)
      target.contents_opacity = v
    end

    type :contents_fade
  end
end
