#==============================================================================
# Auto Window Arrow
#==============================================================================
# Author  : OriginalWij
# Port Version: Fomar
# Version : 1.0
#==============================================================================
 
#==============================================================================
# NOTE: The newest version is the ONLY supported version!
#
# v1.0
# - Initial release
#==============================================================================
 
#==============================================================================
# To use: NONE (Plug & Play)
#==============================================================================
 
#==============================================================================
# Arrow_Sprite                                                            (New)
#==============================================================================
 
class Arrow_Sprite < Sprite_Base
  #--------------------------------------------------------------------------
  # Initialize
  #--------------------------------------------------------------------------
  def initialize
    super()
    reset_bitmap
  end
  #--------------------------------------------------------------------------
  # Update
  #--------------------------------------------------------------------------
  def update
    if self.visible
      if @counter % 12 == 0
        @counter = 0
        @frame = (@frame + 1) % 4
        x = (@frame % 2) * 16
        y = (@frame / 2) * 16
        self.src_rect.set(x, y, 16, 16)
      end
      @counter += 1
    end
    super
  end
  #--------------------------------------------------------------------------
  # Reset Bitmap
  #--------------------------------------------------------------------------
  def reset_bitmap
    self.bitmap = Bitmap.new(32, 32)
    self.src_rect.set(0, 0, 16, 16)
    @counter = @frame = 0
  end
end

class Window_Message < Window_Base
  #--------------------------------------------------------------------------
  # Initialize                                                          (Mod)
  #--------------------------------------------------------------------------
  alias ow_awa_window_message_initialize initialize unless $@
  def initialize
    @arrow = Arrow_Sprite.new
    ow_awa_window_message_initialize
    #reset_arrow
  end
  #--------------------------------------------------------------------------
  # Dispose                                                             (Mod)
  #--------------------------------------------------------------------------
  alias ow_awa_window_message_dispose dispose unless $@
  def dispose
    ow_awa_window_message_dispose
    @arrow.dispose
  end
  #--------------------------------------------------------------------------
  # Update                                                              (Mod)
  #--------------------------------------------------------------------------
  alias ow_awa_window_message_update update unless $@
  def update
    ow_awa_window_message_update
    @arrow.update
  end
  #--------------------------------------------------------------------------
  # Set Windowskin                                                      (Mod)
  #--------------------------------------------------------------------------
  alias ow_awa_window_message_windowskin windowskin= unless $@
  def windowskin=(skin)
    @arrow.reset_bitmap
    @arrow.bitmap.blt(0, 0, skin, Rect.new(96, 64, 32, 32))
    reset_arrow
    arrow_skin = skin.dup
    arrow_skin.clear_rect(96, 64, 32, 32)
    ow_awa_window_message_windowskin(arrow_skin)
  end
  #--------------------------------------------------------------------------
  # Set Pause                                                           (Mod)
  #--------------------------------------------------------------------------
  alias ow_awa_window_message_pause pause= unless $@
  def pause=(bool)
    ow_awa_window_message_pause(bool)
    reset_arrow
  end
  #--------------------------------------------------------------------------
  # Reset Arrow                                                         (New)
  #--------------------------------------------------------------------------
  def reset_arrow(pos = nil)
    @arrow.visible = self.pause
    unless pos.nil?
      @check_x = @right ? 0 : ($game_message.face_name.empty? ? 0 : $game_variables[1988])
      @arrow.x = self.x + pos[:x] + 14 #24
      @arrow.y = [self.y + pos[:y] + 21, self.y + 112].min
      @arrow.y = self.y + 95 if pos[:x] == @check_x#112
    end
    @arrow.z = self.z + 1
  end
  #--------------------------------------------------------------------------
  # * Process All Text
  #--------------------------------------------------------------------------
  def process_all_text
    open_and_wait
    text = convert_escape_characters($game_message.all_text)
    pos = {}
    new_page(text, pos)
    until text.empty?
      last_pos = pos.clone
      process_character(text.slice!(0, 1), text, pos)
      reset_arrow(pos)
    end
    reset_arrow(last_pos)
  end
end