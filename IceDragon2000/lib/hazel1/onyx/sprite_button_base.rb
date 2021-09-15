#
# src/hazel/onyx/button.rb
# vr 1.0
class Hazel::Onyx::Sprite_ButtonBase < Hazel::Onyx::Sprite_WidgetBase

  def init
    super
  end

  def dispose
    self.bitmap.dispose if self.bitmap && !self.bitmap.disposed?
    super
  end

  def update
    super
    event = @component.event
    if event[:toggle]
      event[:toggle] = false

      state = @component.state

      refresh_bitmap
    end
  end

end