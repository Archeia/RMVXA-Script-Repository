module MapEditor3
  class Sprite_BaseCursor < Sprite_Base
    def initialize(viewport)
      super(viewport)
      white = Color.new(255, 255, 255, 255)
      self.bitmap = Bitmap.new(32, 32)
      ctx = DrawContext.new(bitmap)
      ctx.rect_outline(bitmap.rect, white, 2)
      bitmap.fill_rect(1, 1, 30, 1, Color.new(32, 32, 32, 128))
    end

    def dispose
      bitmap.dispose
      super
    end
  end
end
