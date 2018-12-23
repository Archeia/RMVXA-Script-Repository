# Add function for temporarily switching a window's current drawing font.
class Font
  def use( window )
        old_font = window.contents.font.dup
        window.contents.font = self
        yield
        window.contents.font = old_font  
  end
end

# Fixes the arrow character (→) used in places in the UI
# since custom font does not support that character
module Mez
  module ArrowFix
        FONT = Font.new(["Mona"])  # This is the font used for the arrows, checked in order.
  end
end

# For Actor Equip Window
class Window_EquipStatus
  alias mez_wes_dra draw_right_arrow
  def draw_right_arrow(x, y)
        Mez::ArrowFix::FONT.use(self) do
          mez_wes_dra(x, y)
        end
  end
end
