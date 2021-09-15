#
# src/hazel/default
#
module Hazel
  module Default

    # default button events

    # default toggle
    EV_BUTTON_TOGGLE = ->(this) do
      this.state = Hazel::Widget::Button.get_state_inverse(this.state)
    end

    # default mouse left click
    EV_BUTTON_LEFT_CLICK = ->(this) do
      this.toggle
      Sound.play_ex('button')
    end

  end
end