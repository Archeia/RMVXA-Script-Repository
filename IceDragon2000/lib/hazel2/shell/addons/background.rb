# // 02/06/2012
module Hazel
  class Shell
    module Addons
      module Background
        include Hazel::Shell::Addons::OwnViewport

        def init_sbackground
          @shell_register.register('Background', version: '2.0.0'.freeze)

          @sbackground_sprite = Sprite::Background.new(self.ownviewport)

          @shell_callback.add(:redraw, &method(:refresh_sbackground))
          @shell_callback.add(:x=) { @sbackground_sprite.x = 0 }
          @shell_callback.add(:y=) { @sbackground_sprite.y = open_y1_abs }
          @shell_callback.add(:z=) { @sbackground_sprite.z = self.z - 1 }
          @shell_callback.add(:width=) do
            refresh_sbackground
          end
          @shell_callback.add(:height=) do
            refresh_sbackground
          end
          update_position = -> do
            @sbackground_sprite.x      = 0
            @sbackground_sprite.y      = open_y1_abs
            @sbackground_sprite.z      = self.z - 1
            lw = @sbackground_sprite.width
            lh = @sbackground_sprite.height
            if lw != self.width || lh != self.height
              refresh_sbackground
            end
          end
          @shell_callback.add(:on_move, &update_position)
          @shell_callback.add(:on_set, &update_position)
          @shell_callback.add(:openness=) do
            @sbackground_sprite.opacity = self.openness
            @sbackground_sprite.y       = open_y1_abs
          end
          @shell_callback.add(:visible=) { @sbackground_sprite.visible = self.visible }
          @shell_callback.add(:viewport=) { @sbackground_sprite.viewport = self.ownviewport }
          refresh_sbackground
        end

        def dispose_sbackground
          @sbackground_sprite.dispose_all
          @sbackground_sprite = nil
        end

        def update_sbackground
          @sbackground_sprite.update
        end

        def refresh_sbackground
          @sbackground_sprite.dispose_bitmap_safe
          @sbackground_sprite.bitmap = Bitmap.new(self.width, self.height)
          draw_sbackground
        end

        def draw_sbackground
          bmp = @sbackground_sprite.bitmap
          #bmp.fill(Palette['black'])
          ###
          merio = bmp.merio
          merio.draw_dark_rect(bmp.rect)
          ###
          #bmp.fill_rect(bmp.rect, Palette['droid_dark_ui_dis'])
          #anchr_mid_cent = MACL::Surface::ANCHOR_MIDDLE_CENTER
          #contract_amount = standard_padding / 2
          #bmp.fill_rect(bmp.rect.contract(anchor: anchr_mid_cent, amount: 1), Palette['droid_dark_ui_enb'])
          #bmp.fill_rect(bmp.rect.contract(anchor: anchr_mid_cent, amount: contract_amount), Palette['droid_light_ui_dis'])
          #bmp.fill_rect(bmp.rect.contract(anchor: anchr_mid_cent, amount: contract_amount + 1), Palette['droid_dark_ui_enb'])
        end

        def sbackground_opacity
          @sbackground_sprite.opacity
        end

        def sbackground_opacity=(n)
          @sbackground_sprite.opacity = n
        end

        def init_shell_addons
          super
          init_sbackground
        end

        def dispose_shell_addons
          super
          dispose_sbackground
        end

        def update_shell_addons
          super
          update_sbackground
        end
      end
    end
  end
end
