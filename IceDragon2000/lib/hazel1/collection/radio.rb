#
# hazel/collection/radio.rb
# vr 1.0.0
class Hazel::Collection::Radio < Hazel::Collection::Button

  def toggle_all
    raise(Hazel::HazelError, "you cannot toggle a collection of RadioButton")
  end

  def add_obj(radio_button)
    radio_button.collection = self
    radio_button.radio_id = @objs.size

    super(radio_button)
  end

end