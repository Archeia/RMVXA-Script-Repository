#
# EDOS/lib/shell/decorations/title.rb
#   by IceDragon
#   dc 27/06/2013
#   dm 27/06/2013
# vr 1.0.0
module Hazel
  class Shell
    module Decoration
      class ScrollBar < DecorationBase

        ### instance_attributes
        attr_accessor :text
        attr_accessor :align

        ##
        # init
        def init
          @scroll_bar = UI::MerioScrollBar.new(nil, *scroll_bar_size)
          @parent.shell_callback.add(:viewport=) do
            @scroll_bar.viewport = @parent.viewport
          end
          @parent.shell_callback.add(:padding=) do
            @scroll_bar.padding = @parent.padding
          end
          @parent.shell_callback.add(:x=) do
            @scroll_bar.x = @parent.x2 + @rel_x
          end
          @parent.shell_callback.add(:y=) do
            @scroll_bar.y = @parent.y + @rel_y
          end
          @parent.shell_callback.add(:z=) do
            @scroll_bar.z = @parent.z + @rel_z
          end
          @parent.shell_callback.add(:visible=) do
            @scroll_bar.visible = @parent.visible
          end
          @parent.add_callback(:index=) do
            @scroll_bar.set_index_max(@parent.row_max)
            @scroll_bar.set_index(@parent.row_index)
          end
          super
        end

        def scroll_bar_size
          Size2.new(Metric.ui_element, @parent.height)
        end

        ##
        # dispose
        def dispose
          @scroll_bar.dispose
          super
        end

        ##
        # update
        def update
          @scroll_bar.update
          super
        end

        register(:scroll_bar)

      end
    end
  end
end
