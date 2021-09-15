#
# EDOS/src/levias/panel/panel.rb
#   by IceDragon
#   dc 30/03/2013
#   dm 30/03/2013
# vr 1.0.0
module Levias
  class Panel

    ZORDER_BACKGROUND = 0
    ZORDER_CONTENT = 1

    attr_reader :x, :y, :z, :visible
    attr_accessor :width, :height

    def initialize(width, height)
      @x, @y, @z      = 0, 0, 0
      @width, @height = width, height
      @background     = Sprite.new
      @content        = Sprite.new

      create_bitmaps
      refresh
    end

    def dispose_bitmaps
      @background.bitmap.dispose if @background.bitmap
      @content.bitmap.dispose if @content.bitmap
    end

    def dispose
      dispose_bitmaps
      @background.dispose
      @content.dispose
      @disposed = true
    end

    def disposed?
      !!@disposed
    end

    def create_bitmaps
      dispose_bitmaps
      @background.bitmap = Bitmap.new(@width, @height)
      @content.bitmap = Bitmap.new(@width, @height)
    end

    def refresh_background
      # do to background
    end

    def refresh_content
      # do to content
    end

    def refresh
      refresh_background
      refresh_content
    end

    def x=(new_x)
      @background.x = @content.x = @x = new_x
    end

    def y=(new_y)
      @background.y = @content.y = @y = new_y
    end

    def z=(new_z)
      @z = new_z
      @background.z = ZORDER_BACKGROUND + @z
      @content.z    = ZORDER_CONTENT + @z
    end

    def visible=(new_visible)
      @background.visible = @content.visible = @visible = new_visible
    end

    def background_rect
      @background.bitmap.rect
    end

    def content_rect
      @content.bitmap.rect.contract(anchor: 5, amount: Metric.contract)
    end

    # shorthand
    def hide
      self.visible = false
    end

    def show
      self.visible = true
    end

  end
end
