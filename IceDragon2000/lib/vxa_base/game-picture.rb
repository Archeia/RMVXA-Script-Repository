#encoding:UTF-8
# Game_Picture
#==============================================================================
# ** Game_Picture
#------------------------------------------------------------------------------
#  This class handles pictures. It is created only when a picture of a specific
# number is required internally for the Game_Pictures class.
#==============================================================================

class Game_Picture
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :number                   # picture index
  attr_reader   :name                     # filename
  attr_reader   :origin                   # starting point
  attr_reader   :x                        # x-coordinate
  attr_reader   :y                        # y-coordinate
  attr_reader   :zoom_x                   # x directional zoom rate
  attr_reader   :zoom_y                   # y directional zoom rate
  attr_reader   :opacity                  # opacity level
  attr_reader   :blend_type               # blend method
  attr_reader   :tone                     # color tone
  attr_reader   :angle                    # rotation angle
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(number)
    @number = number
    init_basic
    init_target
    init_tone
    init_rotate
  end
  #--------------------------------------------------------------------------
  # * Initialize Basic Variable
  #--------------------------------------------------------------------------
  def init_basic
    @name = ""
    @origin = @x = @y = 0
    @zoom_x = @zoom_y = 100.0
    @opacity = 255.0
    @blend_type = 1
  end
  #--------------------------------------------------------------------------
  # * Initialize Movement Target
  #--------------------------------------------------------------------------
  def init_target
    @target_x = @x
    @target_y = @y
    @target_zoom_x = @zoom_x
    @target_zoom_y = @zoom_y
    @target_opacity = @opacity
    @duration = 0
  end
  #--------------------------------------------------------------------------
  # * Initialize Color Tone
  #--------------------------------------------------------------------------
  def init_tone
    @tone = Tone.new
    @tone_target = Tone.new
    @tone_duration = 0
  end
  #--------------------------------------------------------------------------
  # * Initialize Rotation
  #--------------------------------------------------------------------------
  def init_rotate
    @angle = 0
    @rotate_speed = 0
  end
  #--------------------------------------------------------------------------
  # * Show Picture
  #--------------------------------------------------------------------------
  def show(name, origin, x, y, zoom_x, zoom_y, opacity, blend_type)
    @name = name
    @origin = origin
    @x = x.to_f
    @y = y.to_f
    @zoom_x = zoom_x.to_f
    @zoom_y = zoom_y.to_f
    @opacity = opacity.to_f
    @blend_type = blend_type
    init_target
    init_tone
    init_rotate
  end
  #--------------------------------------------------------------------------
  # * Move Picture
  #--------------------------------------------------------------------------
  def move(origin, x, y, zoom_x, zoom_y, opacity, blend_type, duration)
    @origin = origin
    @target_x = x.to_f
    @target_y = y.to_f
    @target_zoom_x = zoom_x.to_f
    @target_zoom_y = zoom_y.to_f
    @target_opacity = opacity.to_f
    @blend_type = blend_type
    @duration = duration
  end
  #--------------------------------------------------------------------------
  # * Change Rotation Speed
  #--------------------------------------------------------------------------
  def rotate(speed)
    @rotate_speed = speed
  end
  #--------------------------------------------------------------------------
  # * Start Changing Color Tone
  #--------------------------------------------------------------------------
  def start_tone_change(tone, duration)
    @tone_target = tone.clone
    @tone_duration = duration
    @tone = @tone_target.clone if @tone_duration == 0
  end
  #--------------------------------------------------------------------------
  # * Erase Picture
  #--------------------------------------------------------------------------
  def erase
    @name = ""
    @origin = 0
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    update_move
    update_tone_change
    update_rotate
  end
  #--------------------------------------------------------------------------
  # * Update Picture Move
  #--------------------------------------------------------------------------
  def update_move
    return if @duration == 0
    d = @duration
    @x = (@x * (d - 1) + @target_x) / d
    @y = (@y * (d - 1) + @target_y) / d
    @zoom_x  = (@zoom_x  * (d - 1) + @target_zoom_x)  / d
    @zoom_y  = (@zoom_y  * (d - 1) + @target_zoom_y)  / d
    @opacity = (@opacity * (d - 1) + @target_opacity) / d
    @duration -= 1
  end
  #--------------------------------------------------------------------------
  # * Update Color Tone Change
  #--------------------------------------------------------------------------
  def update_tone_change
    return if @tone_duration == 0
    d = @tone_duration
    @tone.red   = (@tone.red   * (d - 1) + @tone_target.red)   / d
    @tone.green = (@tone.green * (d - 1) + @tone_target.green) / d
    @tone.blue  = (@tone.blue  * (d - 1) + @tone_target.blue)  / d
    @tone.gray  = (@tone.gray  * (d - 1) + @tone_target.gray)  / d
    @tone_duration -= 1
  end
  #--------------------------------------------------------------------------
  # * Update Rotation
  #--------------------------------------------------------------------------
  def update_rotate
    return if @rotate_speed == 0
    @angle += @rotate_speed / 2.0
    @angle += 360 while @angle < 0
    @angle %= 360
  end
end
