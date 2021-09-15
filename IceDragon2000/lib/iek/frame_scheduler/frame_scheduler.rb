$simport.r 'iek/frame_scheduler', '1.0.0', 'A frame based scehduler' do |h|
  h.depend 'iek/rgss3_ext/graphics', '>= 1.0.0'
end

class FrameScheduler
  class Job
    @@id = 0
    attr_reader :id
    attr_reader :time
    attr_reader :duration
    attr_accessor :active

    def initialize(duration, &block)
      @id = @@id += 1
      @time = @duration = duration
      @callback = block
      @active = true
    end

    def rate
      @time / @duration
    end

    def done?
      false
    end

    def trigger
      @callback.try(:call)
    end

    def on_timeout
      trigger
    end

    ###
    # @return [Void]
    ###
    def update
      return unless @active
      @time -= 1
      if @time < 0
        on_timeout
      end
    end

    ###
    # Forces the Timeout to finish prematurely
    # @return [Void]
    ###
    def finish
      @time = 0.0
      @trigger.()
    end

    private :trigger
    private :on_timeout
  end

  class Interval < Job
    ###
    # Intervals are never done.
    # @return [Boolean]
    ###
    def done?
      false
    end

    def reset
      @time = @duration
    end

    ###
    # When time reaches 0 or less
    ###
    def on_timeout
      trigger
      reset
    end

    ###
    # Force end the interval
    # Intervals do nothing on #finish
    ###
    def finish
      #
    end
  end

  class Timeout < Job
    ###
    # Has this timeout reached its end?
    # @return [Boolean]
    ###
    def done?
      @time <= 0
    end

    ###
    # When time reaches 0 or less
    ###
    def on_timeout
      trigger
      @active = false
    end
  end

  ### instance attribute
  attr_accessor :tasks
  attr_accessor :intervals

  ###
  # @param [String] str
  # @return [Float] duration  in seconds
  ###
  def self.parse_duration(str)
    #   - milliseconds
    # s - seconds
    # m - minutes
    # h - hours
    # d - days
    # w - weeks
    # M - months
    # y - years
    # Now lets be honest here, who would be running this thing for more than
    # a few hours anyway...
    value = 0.0
    str.scan(/(\d+|\d+\.\d+)([smhdwMy])?/).each do |a|
      v = a[0].to_f
      letter = a[1].to_s
      case letter
      when ""
        value += v / 1000.0
      when "s"
        value += v
      when "m"
        value += v * 60.0
      when "h"
        value += v * 60.0 * 60.0
      when "d"
        value += v * 60.0 * 60.0 * 24.0
      when "w"
        value += v * 60.0 * 60.0 * 24.0 * 7.0
      when "M"
        value += v * 60.0 * 60.0 * 24.0 * 7.0 * 30.0
      when "y"
        value += v * 60.0 * 60.0 * 24.0 * 7.0 * 30.0 * 12.0
      end
    end
    value
  end

  def initialize
    @jobs = []
    @paused = false
    @tick = 0.0
  end

  ###
  # @return [Float] uptime  in seconds
  ###
  def uptime
    @tick
  end

  ###
  # Pauses the Scheduler
  ###
  def pause
    @paused = true
  end

  ###
  # Unpauses the Scheduler
  ###
  def resume
    @paused = false
  end

  ###
  # every(duration) { execute_every_duration }
  ###
  def every(duration, &block)
    duration = self.class.parse_duration(duration) if duration.is_a?(String)
    interval = Interval.new(Graphics.sec_to_frame(duration), &block)
    @jobs.push interval
    interval
  end

  ###
  # in(duration) { to_execute_on_timeout }
  # @param [Integer] duration
  # @return [Timeout]
  ###
  def in(duration, &block)
    duration = self.class.parse_duration(duration) if duration.is_a?(String)
    timeout = Timeout.new(Graphics.sec_to_frame(duration), &block)
    @jobs.push timeout
    timeout
  end

  ###
  # Clears all jobs
  ###
  def clear
    @jobs.clear
  end

  ###
  # Removes a job
  # @overload remove(obj)
  ###
  def remove(obj=nil)
    @jobs.delete(obj)
  end

  ###
  # Removes a job by id
  ###
  def remove_by_id(id)
    @jobs.delete { |job| job.id == id }
  end

  ###
  # Force all jobs to finish.
  # @return [Void]
  ###
  def finish
    return unless @jobs
    @jobs.each(&:finish)
  end

  ###
  # Frame update
  ###
  def update
    return if @paused
    dead = []
    @jobs.each do |task|
      task.update
      dead << task if task.done?
    end
    @jobs -= dead unless dead.empty?
    @tick += 1
  end
end
