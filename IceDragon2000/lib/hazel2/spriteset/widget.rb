#
# EDOS/lib/hazel2/spriteset/widget.rb
#   by IceDragon
module Hazel
  module Spriteset
    class Widget
      class SpriteWidgetBase < Sprite

        attr_reader :widget

        def initialize(viewport, widget)
          super(viewport)
          @widget = widget
          update_bitmap
          refresh
        end

        def dispose
          dispose_bitmap_safe
          super
        end

        def refresh

        end

        def update_bitmap
          if !self.bitmap || self.bitmap.disposed? ||
           (bitmap.width != @widget.width || bitmap.height != @widget.height)
            dispose_bitmap_safe
            self.bitmap = Bitmap.new(@widget.width, @widget.height)
            refresh
          end
        end

        def update_position
          self.x = @widget.x
          self.y = @widget.y
          self.z = @widget.z
        end

        def update
          update_bitmap
          if @widget.need_refresh
            @widget.need_refresh = false
            refresh
          end
          update_position
          super
        end

      end
      class SpriteButton < SpriteWidgetBase

        def refresh
          bitmap.clear
          bitmap.draw_gauge_ext(colors: DrawExt::KEYBOARD_BAR_COLORS)
        end

      end

      include Mixin::IDisposable

      attr_reader :viewport

      def initialize(viewport, widgets)
        @viewport = viewport
        @widgets = widgets
        @sprites = []
        @disposed = false
      end

      def viewport=(n)
        @viewport = n
        @sprites.each_with_object(@viewport, &:viewport=)
      end

      def dispose_sprites
        @sprites.each(&:dispose)
        @sprites.clear
      end

      def dispose
        dispose_sprites
        super
      end

      def update
        for sprite in @sprites
          sprite.update
        end
      end

      def run_gc
        @sprites.reject!(&:disposed?)
      end

      def setup_widgets(new_widgets)
        @widgets = new_widgets
        refresh
      end

      def add_widget(widget)
        klass = case widget.type
                when :base   then SpriteWidgetBase
                when :button then SpriteButton
                end
        @sprites << klass.new(@viewport, widget)
      end

      def remove_widget(widget)
        @sprites.select { |s| s.widget == widget }.each(&:dispose)
        run_gc
        @widgets.delete(widget)
      end

      def refresh
        dispose_sprites
        @widgets.each { |widget| add_widget(widget) }
      end

    end
  end
end