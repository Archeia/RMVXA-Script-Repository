#encoding:UTF-8
# Spriteset_Weather
#==============================================================================
# ** Spriteset_Weather
#------------------------------------------------------------------------------
#  A class for weather effects (rain, storm, and snow). It is used within the
# Spriteset_Map class.
#==============================================================================

class Spriteset_Weather
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :type                     # Weather type
  attr_accessor :ox                       # X coordinate of origin
  attr_accessor :oy                       # Y coordinate of orgin
  attr_reader   :power                    # Intensity
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    @viewport = viewport
    init_members
    create_rain_bitmap
    create_storm_bitmap
    create_snow_bitmap
  end
  #--------------------------------------------------------------------------
  # * Initialize Member Variables
  #--------------------------------------------------------------------------
  def init_members
    @type = :none
    @ox = 0
    @oy = 0
    @power = 0
    @sprites = []
  end
  #--------------------------------------------------------------------------
  # * Free
  #--------------------------------------------------------------------------
  def dispose
    @sprites.each {|sprite| sprite.dispose }
    @rain_bitmap.dispose
    @storm_bitmap.dispose
    @snow_bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # * Particle Color 1
  #--------------------------------------------------------------------------
  def particle_color1
    Color.new(255, 255, 255, 192)
  end
  #--------------------------------------------------------------------------
  # * Particle Color 2
  #--------------------------------------------------------------------------
  def particle_color2
    Color.new(255, 255, 255, 96)
  end
  #--------------------------------------------------------------------------
  # * Create [Rain] Weather Bitmap
  #--------------------------------------------------------------------------
  def create_rain_bitmap
    @rain_bitmap = Bitmap.new(7, 42)
    7.times {|i| @rain_bitmap.fill_rect(6-i, i*6, 1, 6, particle_color1) }
  end
  #--------------------------------------------------------------------------
  # * Create [Storm] Weather Bitmap
  #--------------------------------------------------------------------------
  def create_storm_bitmap
    @storm_bitmap = Bitmap.new(34, 64)
    32.times do |i|
      @storm_bitmap.fill_rect(33-i, i*2, 1, 2, particle_color2)
      @storm_bitmap.fill_rect(32-i, i*2, 1, 2, particle_color1)
      @storm_bitmap.fill_rect(31-i, i*2, 1, 2, particle_color2)
    end
  end
  #--------------------------------------------------------------------------
  # * Create [Snow] Weather Bitmap
  #--------------------------------------------------------------------------
  def create_snow_bitmap
    @snow_bitmap = Bitmap.new(6, 6)
    @snow_bitmap.fill_rect(0, 1, 6, 4, particle_color2)
    @snow_bitmap.fill_rect(1, 0, 4, 6, particle_color2)
    @snow_bitmap.fill_rect(1, 2, 4, 2, particle_color1)
    @snow_bitmap.fill_rect(2, 1, 2, 4, particle_color1)
  end
  #--------------------------------------------------------------------------
  # * Set Weather Intensity
  #--------------------------------------------------------------------------
  def power=(power)
    @power = power
    (sprite_max - @sprites.size).times { add_sprite }
    (@sprites.size - sprite_max).times { remove_sprite }
  end
  #--------------------------------------------------------------------------
  # * Get Maximum Number of Sprites
  #--------------------------------------------------------------------------
  def sprite_max
    (@power * 10).to_i
  end
  #--------------------------------------------------------------------------
  # * Add Sprite
  #--------------------------------------------------------------------------
  def add_sprite
    sprite = Sprite.new(@viewport)
    sprite.opacity = 0
    @sprites.push(sprite)
  end
  #--------------------------------------------------------------------------
  # * Delete Sprite
  #--------------------------------------------------------------------------
  def remove_sprite
    sprite = @sprites.pop
    sprite.dispose if sprite
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    update_screen
    @sprites.each {|sprite| update_sprite(sprite) }
  end
  #--------------------------------------------------------------------------
  # * Update Screen
  #--------------------------------------------------------------------------
  def update_screen
    @viewport.tone.set(-dimness, -dimness, -dimness)
  end
  #--------------------------------------------------------------------------
  # * Get Dimness
  #--------------------------------------------------------------------------
  def dimness
    (@power * 6).to_i
  end
  #--------------------------------------------------------------------------
  # * Update Sprite
  #--------------------------------------------------------------------------
  def update_sprite(sprite)
    sprite.ox = @ox
    sprite.oy = @oy
    case @type
    when :rain
      update_sprite_rain(sprite)
    when :storm
      update_sprite_storm(sprite)
    when :snow
      update_sprite_snow(sprite)
    end
    create_new_particle(sprite) if sprite.opacity < 64
  end
  #--------------------------------------------------------------------------
  # * Update Sprite [Rain]
  #--------------------------------------------------------------------------
  def update_sprite_rain(sprite)
    sprite.bitmap = @rain_bitmap
    sprite.x -= 1
    sprite.y += 6
    sprite.opacity -= 12
  end
  #--------------------------------------------------------------------------
  # * Update Sprite [Storm]
  #--------------------------------------------------------------------------
  def update_sprite_storm(sprite)
    sprite.bitmap = @storm_bitmap
    sprite.x -= 3
    sprite.y += 6
    sprite.opacity -= 12
  end
  #--------------------------------------------------------------------------
  # * Update Sprite [Snow]
  #--------------------------------------------------------------------------
  def update_sprite_snow(sprite)
    sprite.bitmap = @snow_bitmap
    sprite.x -= 1
    sprite.y += 3
    sprite.opacity -= 12
  end
  #--------------------------------------------------------------------------
  # * Create New Particle
  #--------------------------------------------------------------------------
  def create_new_particle(sprite)
    sprite.x = rand(Graphics.width + 100) - 100 + @ox
    sprite.y = rand(Graphics.height + 200) - 200 + @oy
    sprite.opacity = 160 + rand(96)
  end
end
