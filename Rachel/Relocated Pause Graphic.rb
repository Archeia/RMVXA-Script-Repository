#==============================================================================
# Relocated Pause Graphic
# by: Racheal
# Created: 11/11/2013
# Editted: 19/02/2015
#==============================================================================
# Replicates the pause graphic in Window_Message to allow for repositioning
#==============================================================================
# Instructions:
# * Insert in the Materials section
# * Configure to your liking below
#==============================================================================

#==============================================================================
# Customization
#==============================================================================
module Racheal_Move_Pause
  #Set the position of the pause graphic. :left, :center, and :right supported
  POSITION = :center
  
  #Set fine tuning of position here
  X_OFFSET = 0
  Y_OFFSET = 0
end
#==============================================================================
# End Customization
#==============================================================================

class Window_Message < Window_Base
  #--------------------------------------------------------------------------
  # * Alias: Initialize
  #--------------------------------------------------------------------------
  alias move_pause_graphic_initialize initialize
  def initialize
    move_pause_graphic_initialize
    make_pause_sprite
  end
  #--------------------------------------------------------------------------
  # * Alias: Dispose
  #--------------------------------------------------------------------------
  alias move_pause_graphic_dispose dispose
  def dispose
    move_pause_graphic_dispose
    @pause_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Make Pause Sprite
  #--------------------------------------------------------------------------
  def make_pause_sprite
    @pause_sprite = Sprite.new
    @pause_sprite.bitmap = Cache.system("pause")
    w = @pause_sprite.bitmap.width
    h = @pause_sprite.bitmap.height
    @pause_sprite.src_rect = Rect.new(0, 0, w/2, h/2)
    @pause_sprite.z = self.z + 10
    @pause_sprite.visible = false
  end
  #--------------------------------------------------------------------------
  # * Alias: Update
  #--------------------------------------------------------------------------
  alias move_pause_graphic_update update
  def update
    move_pause_graphic_update
    update_pause_sprite if @pause_sprite.visible
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update_pause_sprite
    frame = Graphics.frame_count % 160 / 40
    @pause_sprite.src_rect.x = @pause_sprite.bitmap.width/2 * (frame % 2)
    @pause_sprite.src_rect.y = @pause_sprite.bitmap.height/2 * (frame / 2)
  end
  #--------------------------------------------------------------------------
  # * Overwrite: Set Pause
  #--------------------------------------------------------------------------
  def pause=(pause)
    if pause
      case Racheal_Move_Pause::POSITION
      when :left
        @pause_sprite.x = self.x + padding + Racheal_Move_Pause::X_OFFSET
      when :center
        @pause_sprite.x = self.x + self.width / 2 + Racheal_Move_Pause::X_OFFSET
      when :right
        @pause_sprite.x = self.x + self.width - padding - Racheal_Move_Pause::X_OFFSET
      end
      @pause_sprite.y = self.y + self.height - padding - Racheal_Move_Pause::Y_OFFSET
    end
    @pause_sprite.visible = pause
  end
end