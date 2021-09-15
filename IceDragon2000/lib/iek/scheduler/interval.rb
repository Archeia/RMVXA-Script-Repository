class Interval < SchedulerJob
  # Intervals are never done.
  #
  # @return [Boolean]
  def done?
    false
  end

  def reset
    @time = @duration
  end

  # When time reaches 0 or less
  def on_timeout
    trigger
    reset
  end

  # Force end the interval
  # Intervals do nothing on #finish
  def finish
    #
  end
end
