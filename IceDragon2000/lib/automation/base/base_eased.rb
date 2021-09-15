module Automation
  class BaseEased < BaseTime
    def initialize(src, dst, time, easer=:linear)
      @easer = MACL::Convert.Easer(easer)
      setup_values(src, dst)
      super(time)
    end

    def setup_values(src, dst)
      @src, @dst = src, dst
    end

    def flip_values
      @dst, @src = @src, @dst
    end

    def use_change?
      false
    end

    def update_by_time(target)
      if use_change?
        v1 = @easer.ease(1.0 - @prev_time / @mtime, @src, @dst)
        v2 = @easer.ease(1.0 - @time / @mtime, @src, @dst)
        update_value_by_change(target, v2 - v1)
      else
        update_value(target, @easer.ease(1.0 - @time / @mtime, @src, @dst))
      end
    end

    def update_value(target, v)
      #
    end

    def update_value_by_change(target, ch)
      #
    end

    type :eased
  end
end
