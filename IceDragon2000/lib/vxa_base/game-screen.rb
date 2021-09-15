#encoding:UTF-8
# Game_Screen
#==============================================================================
# ** Game_Screen
#------------------------------------------------------------------------------
#  This class handles screen maintenance data, such as changes in color tone,
# flashes, etc. It's used within the Game_Map and Game_Troop classes.
#==============================================================================

class Game_Screen
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :brightness               # brightness
  attr_reader   :tone                     # color tone
  attr_reader   :flash_color              # flash color
  attr_reader   :pictures                 # pictures
  attr_reader   :shake                    # shake positioning
  attr_reader   :weather_type             # weather type
  attr_reader   :weather_power            # weather intensity (Float)
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @pictures = Game_Pictures.new
    clear
  end
  #--------------------------------------------------------------------------
  # * Clear
  #--------------------------------------------------------------------------
  def clear
    clear_fade
    clear_tone
    clear_flash
    clear_shake
    clear_weather
    clear_pictures
  end
  #--------------------------------------------------------------------------
  # * Clear Fade In/Out
  #--------------------------------------------------------------------------
  def clear_fade
    @brightness = 255
    @fadeout_duration = 0
    @fadein_duration = 0
  end
  #--------------------------------------------------------------------------
  # * Clear Color Tone
  #--------------------------------------------------------------------------
  def clear_tone
    @tone = Tone.new
    @tone_target = Tone.new
    @tone_duration = 0
  end
  #--------------------------------------------------------------------------
  # * Clear Flash
  #--------------------------------------------------------------------------
  def clear_flash
    @flash_color = Color.new
    @flash_duration = 0
  end
  #--------------------------------------------------------------------------
  # * Clear Shake
  #--------------------------------------------------------------------------
  def clear_shake
    @shake_power = 0
    @shake_speed = 0
    @shake_duration = 0
    @shake_direction = 1
    @shake = 0
  end
  #--------------------------------------------------------------------------
  # * Clear Weather
  #--------------------------------------------------------------------------
  def clear_weather
    @weather_type = :none
    @weather_power = 0
    @weather_power_target = 0
    @weather_duration = 0
  end
  #--------------------------------------------------------------------------
  # * Clear Picture
  #--------------------------------------------------------------------------
  def clear_pictures
    @pictures.each {|picture| picture.erase }
  end
  #--------------------------------------------------------------------------
  # * Start Fadeout
  #--------------------------------------------------------------------------
  def start_fadeout(duration)
    @fadeout_duration = duration
    @fadein_duration = 0
  end
  #--------------------------------------------------------------------------
  # * Start Fadein
  #--------------------------------------------------------------------------
  def start_fadein(duration)
    @fadein_duration = duration
    @fadeout_duration = 0
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
  # * Start Flashing
  #--------------------------------------------------------------------------
  def start_flash(color, duration)
    @flash_color = color.clone
    @flash_duration = duration
  end
  #--------------------------------------------------------------------------
  # * Start Shaking
  #     power: intensity
  #     speed: speed
  #--------------------------------------------------------------------------
  def start_shake(power, speed, duration)
    @shake_power = power
    @shake_speed = speed
    @shake_duration = duration
  end
  #--------------------------------------------------------------------------
  # * Change Weather
  #     type  : type (:none, :rain, :storm, :snow)
  #     power: intensity
  #    If weather type is none (:none), set @weather_power_target (target
  #    value of intensity) to 0 to represent gradual stopping of rain, but
  #    only in this case.
  #--------------------------------------------------------------------------
  def change_weather(type, power, duration)
    @weather_type = type if type != :none || duration == 0
    @weather_power_target = type == :none ? 0.0 : power.to_f
    @weather_duration = duration
    @weather_power = @weather_power_target if duration == 0
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    update_fadeout
    update_fadein
    update_tone
    update_flash
    update_shake
    update_weather
    update_pictures
  end
  #--------------------------------------------------------------------------
  # * Update Fadeout
  #--------------------------------------------------------------------------
  def update_fadeout
    if @fadeout_duration > 0
      d = @fadeout_duration
      @brightness = (@brightness * (d - 1)) / d
      @fadeout_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * Update Fadein
  #--------------------------------------------------------------------------
  def update_fadein
    if @fadein_duration > 0
      d = @fadein_duration
      @brightness = (@brightness * (d - 1) + 255) / d
      @fadein_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * Update Tone
  #--------------------------------------------------------------------------
  def update_tone
    if @tone_duration > 0
      d = @tone_duration
      @tone.red = (@tone.red * (d - 1) + @tone_target.red) / d
      @tone.green = (@tone.green * (d - 1) + @tone_target.green) / d
      @tone.blue = (@tone.blue * (d - 1) + @tone_target.blue) / d
      @tone.gray = (@tone.gray * (d - 1) + @tone_target.gray) / d
      @tone_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * Update Flash
  #--------------------------------------------------------------------------
  def update_flash
    if @flash_duration > 0
      d = @flash_duration
      @flash_color.alpha = @flash_color.alpha * (d - 1) / d
      @flash_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * Update Shake
  #--------------------------------------------------------------------------
  def update_shake
    if @shake_duration > 0 || @shake != 0
      delta = (@shake_power * @shake_speed * @shake_direction) / 10.0
      if @shake_duration <= 1 && @shake * (@shake + delta) < 0
        @shake = 0
      else
        @shake += delta
      end
      @shake_direction = -1 if @shake > @shake_power * 2
      @shake_direction = 1 if @shake < - @shake_power * 2
      @shake_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * Update Weather
  #--------------------------------------------------------------------------
  def update_weather
    if @weather_duration > 0
      d = @weather_duration
      @weather_power = (@weather_power * (d - 1) + @weather_power_target) / d
      @weather_duration -= 1
      if @weather_duration == 0 && @weather_power_target == 0
        @weather_type = :none
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Update Pictures
  #--------------------------------------------------------------------------
  def update_pictures
    @pictures.each {|picture| picture.update }
  end
  #--------------------------------------------------------------------------
  # * Start Flash (for Poison/Damage Floor)
  #--------------------------------------------------------------------------
  def start_flash_for_damage
    start_flash(Color.new(255,0,0,128), 8)
  end
end
