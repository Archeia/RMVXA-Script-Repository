#
# hazel/widget-radiobutton.rb
# vr 0.60
class Hazel::Widget::RadioButton < Hazel::Widget::Button

  class RadioError < Hazel::HazelError
  end

  attr_accessor :radio_id

  def initialize(x, y, w, h)
    super(x, y, w, h)
    @radio_id = 0
  end

  attr_accessor :collection

  def toggle
    raise(RadioError,
      "RadioButton tried to toggle without a collection") unless @collection
    @collection.set_state(@collection.get_usel_state) # temp
    @state = @collection.get_sel_state

    super
  end

end
