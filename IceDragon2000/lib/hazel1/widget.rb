#
# hazel/widget.rb
# vr 0.1.1
class Hazel::Widget < Hazel::WidgetBase

  attr_reader :events_handle

  def initialize(x, y, w, h)
    super(x, y, w, h)
    @events_handle = Hazel::EventHandle.new(self)
  end

public

  def add_event_handle(*args, &block)
    @events_handle.add(*args, &block)
  end

private

  def call_event_handle(*args, &block)
    @events_handle.call(*args, &block)
  end

  def on_event(*args, &block)
    @events_handle.try(*args, &block)
  end

public

  def self.init_valid_events
    @valid_events = {}
  end

  def self.register_event(event)
    init_valid_events unless @valid_events
    @valid_events[event] = true
  end

  def self.get_invalid_events(widget)
    init_valid_events unless @valid_events
    widget.events_handle.events.reject do |sym|
      @valid_events.include?(sym)
    end
  end

end