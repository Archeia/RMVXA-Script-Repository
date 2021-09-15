#
# EDOS/src/REI/system.rb
#
module REI
  module System

    def hp_critical_thresh
      0.25
    end

    def hp_warning_thresh
      0.40
    end

    def mp_critical_thresh
      0.25
    end

    def mp_warning_thresh
      0.40
    end

    def locale(tag, subtag)
      return subtag
    end

    extend self

  end
end
