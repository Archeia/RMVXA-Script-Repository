# // 02/06/2012
module Hazel
  class Shell
    module Addons
      module OwnViewport

        attr_reader :ownviewport

        def init_shell_addons
          super
          init_ownviewport
        end

        def dispose_shell_addons
          super
          dispose_ownviewport
        end

        def update_shell_addons
          super
          update_ownviewport
        end

        def init_ownviewport
          @shell_register.register("OwnViewport", version: "2.0.0".freeze)

          @ownviewport = Viewport.new(oviewport_x, oviewport_y, oviewport_width, oviewport_height)

          @shell_callback.add(:x=) { @ownviewport.x = oviewport_x }
          @shell_callback.add(:y=) { @ownviewport.y = oviewport_y }
          @shell_callback.add(:z=) { @ownviewport.z = oviewport_z }
          @shell_callback.add(:width=) { @ownviewport.width = oviewport_width }
          @shell_callback.add(:height=) { @ownviewport.height = oviewport_height }

          update_position = ->() do
            if @ownviewport
              @ownviewport.x = oviewport_x
              @ownviewport.y = oviewport_y
              @ownviewport.z = oviewport_z
              @ownviewport.width = oviewport_width
              @ownviewport.height = oviewport_height
            end
          end

          @shell_callback.add(:redraw, &update_position)
          @shell_callback.add(:openness=, &update_position)
          @shell_callback.add(:on_move, &update_position)
          @shell_callback.add(:on_set, &update_position)
          @shell_callback.add(:visible=) { @ownviewport.visible = self.visible }
        end

        def dispose_ownviewport
          @ownviewport.dispose
        end

        def update_ownviewport
          @ownviewport.update
        end

        def oviewport_x
          self.x + (self.viewport ? self.viewport.rect.x : 0)
        end

        def oviewport_y
          self.open_y1 + (self.viewport ? self.viewport.rect.y : 0)
        end

        def oviewport_z
          self.z + (self.viewport ? self.viewport.z : 1)
        end

        def oviewport_width
          self.width
        end

        def oviewport_height
          self.open_height
        end

      end
    end
  end
end
