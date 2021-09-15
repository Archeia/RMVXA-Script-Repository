# // 02/06/2012
module Hazel
  module Shell::Addons::Contents
    include Mixin::ArtistHost

    attr_accessor :contents
    attr_reader :content_sprite

    def init_shell_addons
      super
      init_contents
    end

    def dispose_shell_addons
      super
      dispose_all_contents # // . x .
    end

    def update_shell_addons
      super
      update_contents
    end

    def init_contents
      @shell_register.register("Contents", version: "2.0.0".freeze)

      @content_sprite = Sprite::Content.new(self.ownviewport)
      create_contents
      init_artist

      @shell_callback.add(:redraw, &method(:create_contents))
      @shell_callback.add(:x=) { @content_sprite.x = self.padding }
      @shell_callback.add(:y=) { @content_sprite.y = self.padding }
      @shell_callback.add(:z=) { @content_sprite.z = self.z + 1 }
      @shell_callback.add(:width=) do
        update_contents_rect
      end
      @shell_callback.add(:height=) do
        update_contents_rect
      end
      update_position = ->() do
        update_content_pos
        update_contents_rect
      end
      @shell_callback.add(:on_move, &update_position)
      @shell_callback.add(:on_set, &update_position)
      #@shell_callback.add(:openness=) do
      #  @content_sprite.zoom_y = open_height / self.height.to_f
      #  @content_sprite.y      = self.open_y1
      #end
      @shell_callback.add(:padding=) do
        update_contents_rect
      end
      @shell_callback.add(:visible=) { @content_sprite.visible = self.visible }
      @shell_callback.add(:viewport=) { @content_sprite.viewport = self.ownviewport }
    end

    def dispose_all_contents
      self.contents.dispose unless self.contents.disposed? if self.contents
      @content_sprite.dispose
    end

    def update_contents
      @content_sprite.update
    end

    def update_contents_rect
      return unless @content_sprite
      @content_sprite.src_rect.width = contents_width_visible
      @content_sprite.src_rect.height = contents_height_visible
    end

    def contents_x
      self.x + padding
    end

    def contents_y
      self.y + padding
    end

    def contents_width_visible
      self.width - (padding * 2)
    end

    def contents_width
      return contents_width_visible()
    end

    def contents_height_visible
      self.height - (padding * 2) - padding_bottom
    end

    def contents_height
      return contents_height_visible
    end

    def contents_rect
      Rect.new(contents_x, contents_y, contents_width, contents_height)
    end

    def ox
      @content_sprite.src_rect.x
    end

    def oy
      @content_sprite.src_rect.y
    end

    def ox=(n)
      @content_sprite.src_rect.x = n
    end

    def oy=(n)
      @content_sprite.src_rect.y = n
    end

    def update_content_pos()
      @content_sprite.x = self.padding
      @content_sprite.y = self.padding
      @content_sprite.z = self.z + 1
    end

    def create_contents
      self.contents.dispose if self.contents && !self.contents.disposed?
      wd = contents_width
      hg = contents_height
      wd = wd.max(1)
      hg = hg.max(1)
      self.contents = Bitmap.new(wd, hg)
      @content_sprite.bitmap = self.contents
      update_contents_rect
    end

    def contents_opacity
      @content_sprite.opacity
    end

    def contents_opacity=(n)
      @content_sprite.opacity = n
    end
  end
end
