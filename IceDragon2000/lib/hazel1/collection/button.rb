#
# hazel/collection-button.rb
# vr 1.0
class Hazel::Collection::Button < Hazel::Collection

  def get_usel_state
    return Button::OFF
  end

  def get_sel_state
    return Button::ON
  end

  def toggle
    @objs.each(&:toggle)
  end

  def set_state(new_state)
    @objs.each_with_object(new_state, &:state=)
  end

  def clear
    @objs.each_with_object(nil, &:collection=)
    super
  end

end