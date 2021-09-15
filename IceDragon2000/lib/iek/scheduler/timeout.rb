class Timeout < SchedulerJob
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
