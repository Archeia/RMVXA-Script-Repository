#
# hazel/widget/checkbox.rb
# vr 1.00
class Hazel::Widget::Checkbox < Hazel::Widget::Button

  def initialize(x, y, w, h)
    super(x, y, w, h)
  end

  def toggle
    @state = Hazel::Widget::Button.get_state_inverse(@state)
    super
  end

end
