#encoding:UTF-8
# Sprite_Timer
#==============================================================================
# ** Sprite_Timer
#------------------------------------------------------------------------------
#  This sprite is for timer displays. It monitors $game_timer and automatically 
# changes sprite states.
#==============================================================================

class Sprite_Timer < Sprite
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    create_bitmap
    update
  end
  #--------------------------------------------------------------------------
  # * Free
  #--------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose
    super
  end
  #--------------------------------------------------------------------------
  # * Create Bitmap
  #--------------------------------------------------------------------------
  def create_bitmap
    self.bitmap = Bitmap.new(96, 48)
    self.bitmap.font.size = 32
    self.bitmap.font.color.set(255, 255, 255)
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    update_bitmap
    update_position
    update_visibility
  end
  #--------------------------------------------------------------------------
  # * Update Transfer Origin Bitmap
  #--------------------------------------------------------------------------
  def update_bitmap
    if $game_timer.sec != @total_sec
      @total_sec = $game_timer.sec
      redraw
    end
  end
  #--------------------------------------------------------------------------
  # * Redraw
  #--------------------------------------------------------------------------
  def redraw
    self.bitmap.clear
    self.bitmap.draw_text(self.bitmap.rect, timer_text, 1)
  end
  #--------------------------------------------------------------------------
  # * Create Text
  #--------------------------------------------------------------------------
  def timer_text
    sprintf("%02d:%02d", @total_sec / 60, @total_sec % 60)
  end
  #--------------------------------------------------------------------------
  # * Update Position
  #--------------------------------------------------------------------------
  def update_position
    self.x = Graphics.width - self.bitmap.width
    self.y = 0
    self.z = 200
  end
  #--------------------------------------------------------------------------
  # * Update Visibility
  #--------------------------------------------------------------------------
  def update_visibility
    self.visible = $game_timer.working?
  end
end
