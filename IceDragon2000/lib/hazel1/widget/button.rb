#
# hazel/widget/button.rb
# vr 1.00
class Hazel::Widget::Button < Hazel::Widget

  include Hazel::Mixin::MouseEvent

  OFF = 0x00
  ON  = 0x01

  OFF_DISABLED = 0x10
  ON_DISABLED  = 0x11

  def self.get_active_state(state)
    if (state >> 4) & 0x1 == 0x1 # was disabled
      return state & 0x0F
    else
      return state
    end
  end

  def self.get_disabled_state(state)
    if (state >> 4) & 0x1 == 0x1 # was disabled
      return state
    else
      return (state << 4) + 0x10
    end
  end

  def self.get_state_inverse(state)
    if (state >> 4) & 0x1 == 0x1 # disabled
      return ((state >> 4) + 1) % 2 + 0x10
    else
      return (state + 1) % 2
    end
  end

  attr_accessor :state

  def initialize(x, y, w, h)
    super(x, y, w, h)
    init_mouse_event
    init_state
  end

  def init_state
    @state = OFF
  end

  def active?
    return !(@state > 1)
  end

  def toggle
    on_event(:toggle)

    @event[:toggle] = true
  end

  def update
    super
    handle_mouse_event
  end

  register_event(:toggle)

end