# Whenever a multi-line description is printed, for some reason an extra glyph is added at the line break
# This Fixes that.
class Window_Base
  alias :process_normal_character_vxa :process_normal_character
  def process_normal_character(c, pos)
  return unless c >= ' ' #skip drawing if c is not a displayable character
  process_normal_character_vxa(c, pos)
  end
end

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
  FONT = Font.new(["VL Gothic", "Arial"])  # This is the font used for the arrows, checked in order.
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

# For Yanfly Victory Aftermath - remove if not using that script
class Window_VictoryLevelUp
  alias mez_wvlu_da draw_arrows
  def draw_arrows
  Mez::ArrowFix::FONT.use(self) do
    mez_wvlu_da
  end
  end
end