#
# EDOS/lib/shell/decorations/title.rb
#   by IceDragon
#   dc 27/06/2013
#   dm 27/06/2013
# vr 1.0.0
module Hazel
  class Shell
    module Decoration
      class Title < DecorationBase

        ### instance_attributes
        attr_accessor :text
        attr_accessor :align

        ##
        # init
        def init
          @title_sp = Sprite::MerioTextBox.new(nil, @parent.width, Metric.ui_element_sml)
          @title_sp.merio_font_size = :small
          @parent.shell_callback.add(:x=) do
            @title_sp.x = @parent.x + @rel_x
          end
          @parent.shell_callback.add(:y=) do
            @title_sp.y2 = @parent.y + @rel_y
          end
          @parent.shell_callback.add(:z=) do
            @title_sp.z = @parent.z + @rel_z
          end
          super
        end

        ##
        # set_text(String text, in align)
        def set_text(text, align=@align || 0)
          @text = text
          @align = align
          @title_sp.set_text(@text, @align)
        end

        ##
        # dispose
        def dispose
          @title_sp.dispose
          super
        end

        ##
        # update
        def update
          @title_sp.update
          super
        end

        register(:title)

      end
    end
  end
end