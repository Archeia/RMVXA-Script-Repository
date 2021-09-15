module Automation
  class Ajar < BaseEased
    # @param [Integer]
    # @target [Integer] openness
    def update_value(target, v)
      target.openness = v
    end

    type :ajar
  end
end
