class SchedulerJob
  attr_reader :id
  attr_reader :time
  attr_reader :duration
  attr_accessor :active

  def initialize(duration, &block)
    @id = Random.random.base64(16)
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
  # @param [Float] delta
  # @return [Void]
  ###
  def update(delta)
    return unless @active
    @time -= delta
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
