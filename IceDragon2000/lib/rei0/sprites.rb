# ╒╕ ♥                                               REI::Sprite::Character ╒╕
# └┴────────────────────────────────────────────────────────────────────────┴┘
module REI
module Sprite
class Character < ::Sprite

  def initialize(viewport, character)
    super viewport
    setup_character character
    pre_init
    update
    post_init
  end

  def pre_init
    @gauges = nil
    @visual_handle = nil
  end

  def post_init
  end

  def setup_character(character)
    @character = character
  end

  def update
    @visual_handle = @character.visual
    (self.visible = false; return) unless @visual_handle
    update_visible
    return unless self.visible
    update_bitmap
    update_src_rect
    update_other
    update_position
    update_rei
  end

  def update_visible
    self.opacity = @visual_handle.opacity
    self.visible = !@visual_handle.transparent
    self.bush_depth = @visual_handle.bush_depth
    self.bush_opacity = @visual_handle.bush_opacity
  end

  def update_bitmap
    setup_bitmap if @visual_handle.refresh? :bitmap
  end

  def setup_bitmap
    @visual_handle.refresh :bitmap do |bool,handle|
      self.bitmap = @visual_handle.bmp_character
      false
    end
  end

  def update_src_rect
    self.src_rect.set @visual_handle.src_rect
  end

  def update_other
    self.zoom_x = @visual_handle.zoom_x
    self.zoom_y = @visual_handle.zoom_y
    self.angle  = @visual_handle.angle
    self.tone.set @visual_handle.tone
    self.color.set @visual_handle.color
  end

  def update_position
    self.x  = @visual_handle.screen_x
    self.y  = @visual_handle.screen_y
    self.z  = @visual_handle.screen_z
    self.ox = @visual_handle.ox
    self.oy = @visual_handle.oy
  end

  def update_rei
    setup_gauges if @visual_handle.refresh? :gauges
    update_rei_gauges if @gauges
  end

  def update_rei_gauges
    @gauges.each &:update
  end

  def setup_gauges
    @gauges.each &:dispose if @gauges
    gauges  = Array.new(@character.gauges.keys).map! do |sym|
      @character.gauges[sym]
    end
    @gauges = Array.new(gauges).map! do |gauge|
      YGG::Spriteset::Gauge.new(self, gauge)
    end
  end

end
end
end
