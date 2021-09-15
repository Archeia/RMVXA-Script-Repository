module Automation
  class BaseTime < Base
    attr_reader :time
    attr_reader :prev_time
    attr_accessor :mtime

    def initialize(time)
      @mtime = time.to_f  # in frames
      super()
    end

    def reset_time
      @prev_time = @time = @mtime
    end

    def reset
      reset_time
      super
    end

    def dead?
      return @time < 0.0
    end

    def refresh_time
      # normally doesn't do anything
    end

    def update(target)
      unless dead?
        refresh_time if @time < 0
        unless @time < 0
          update_by_time(target)
          @prev_time = @time
          @time -= 1.0
        end
      end
      super(target)
    end

    def update_by_time(target)
      #
    end

    type :time
  end
end
