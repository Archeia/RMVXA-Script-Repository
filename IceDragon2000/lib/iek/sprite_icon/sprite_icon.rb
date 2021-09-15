$simport.r 'iek/sprite_icon', '1.0.0', 'Generic Sprite for IconSet'

# There are plenty of situations where you need a simple Sprite_Icon class
class Sprite_Icon < Sprite_Base
  # @return [Integer]
  attr_reader :icon_index

  # @param [Viewport] viewport
  # @param [Integer] icon_index
  def initialize(viewport = nil, icon_index = 0)
    super viewport
    self.icon_index = icon_index
  end

  # @param [String]
  def iconset_name
    'IconSet'
  end

  # @return [Bitmap] the iconset bitmap
  def iconset_bitmap
    Cache.system(iconset_name)
  end

  # @param [Integer] icon_index
  # @return [Void]
  def icon_index=(icon_index)
    @icon_index = icon_index.to_i
    self.bitmap = iconset_bitmap
    update_src_rect
  end

  # @return [Void]
  def update_src_rect
    self.src_rect.set(@icon_index % 16 * 24, @icon_index / 16 * 24, 24, 24)
  end
end
