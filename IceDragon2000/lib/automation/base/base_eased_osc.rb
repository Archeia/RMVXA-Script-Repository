module Automation
  class BaseEasedOsc < BaseEased
    ##
    # dead?
    # @return [Boolean]
    def dead?
      # in the case of *Osc, they are never dead, since they repeat, over
      # and over again
      return false
    end

    def refresh_time
      flip_values
      reset_time
    end

    type :eased_osc
  end
end
