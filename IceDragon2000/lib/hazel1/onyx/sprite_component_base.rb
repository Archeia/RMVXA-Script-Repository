#
# src/hazel/onyx/sprite_componentbase.rb
#   by IceDragon
# vr 0.1
class Hazel::Onyx::Sprite_ComponentBase < Sprite

  attr_reader :component

  def initialize(component)
    super(nil)
    @component = component
    init
    update_position
  end

  def init
    # do something in child class
    refresh_size
    refresh_bitmap
  end

  def viewport=(n)
    raise(Hazel::Onyx::OnyxError,
          "Onyx Sprites are not allowed to have viewports")
  end

  def update
    super
    update_component
    update_size
    update_position
  end

  def update_component
    @component.update
  end

  def update_position
    self.x = @component.x
    self.y = @component.y
    self.z = @component.z
  end

  def update_size
    bmp = self.bitmap
    if !bmp || (bmp.width != @component.width || bmp.height != @component.height)
      refresh_size
    end
  end

  def refresh_bitmap
    # you may want to override this, if you use custom graphics
    self.bitmap.clear
  end

  def refresh_size
    self.bitmap.dispose if self.bitmap
    self.bitmap = Bitmap.new(@component.width, @component.height)
    refresh_bitmap
  end

end