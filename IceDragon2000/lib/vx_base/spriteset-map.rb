#encoding:UTF-8
# Spriteset_Map
#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
#  This class brings together map screen sprites, tilemaps, etc. It's used
# within the Scene_Map class.
#==============================================================================

class Spriteset_Map
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    create_viewports
    create_tilemap
    create_parallax
    create_characters
    create_shadow
    create_weather
    create_pictures
    create_timer
    update
  end
  #--------------------------------------------------------------------------
  # * Create Viewport
  #--------------------------------------------------------------------------
  def create_viewports
    @viewport1 = Viewport.new(0, 0, 544, 416)
    @viewport2 = Viewport.new(0, 0, 544, 416)
    @viewport3 = Viewport.new(0, 0, 544, 416)
    @viewport2.z = 50
    @viewport3.z = 100
  end
  #--------------------------------------------------------------------------
  # * Create Tilemap
  #--------------------------------------------------------------------------
  def create_tilemap
    @tilemap = Tilemap.new(@viewport1)
    @tilemap.bitmaps[0] = Cache.system("TileA1")
    @tilemap.bitmaps[1] = Cache.system("TileA2")
    @tilemap.bitmaps[2] = Cache.system("TileA3")
    @tilemap.bitmaps[3] = Cache.system("TileA4")
    @tilemap.bitmaps[4] = Cache.system("TileA5")
    @tilemap.bitmaps[5] = Cache.system("TileB")
    @tilemap.bitmaps[6] = Cache.system("TileC")
    @tilemap.bitmaps[7] = Cache.system("TileD")
    @tilemap.bitmaps[8] = Cache.system("TileE")
    @tilemap.map_data = $game_map.data
    @tilemap.passages = $game_map.passages
  end
  #--------------------------------------------------------------------------
  # * Create Parallax
  #--------------------------------------------------------------------------
  def create_parallax
    @parallax = Plane.new(@viewport1)
    @parallax.z = -100
  end
  #--------------------------------------------------------------------------
  # * Create Character Sprite
  #--------------------------------------------------------------------------
  def create_characters
    @character_sprites = []
    for i in $game_map.events.keys.sort
      sprite = Sprite_Character.new(@viewport1, $game_map.events[i])
      @character_sprites.push(sprite)
    end
    for vehicle in $game_map.vehicles
      sprite = Sprite_Character.new(@viewport1, vehicle)
      @character_sprites.push(sprite)
    end
    @character_sprites.push(Sprite_Character.new(@viewport1, $game_player))
  end
  #--------------------------------------------------------------------------
  # * Create Airship Shadow Sprite
  #--------------------------------------------------------------------------
  def create_shadow
    @shadow_sprite = Sprite.new(@viewport1)
    @shadow_sprite.bitmap = Cache.system("Shadow")
    @shadow_sprite.ox = @shadow_sprite.bitmap.width / 2
    @shadow_sprite.oy = @shadow_sprite.bitmap.height
    @shadow_sprite.z = 180
  end
  #--------------------------------------------------------------------------
  # * Create Weather
  #--------------------------------------------------------------------------
  def create_weather
    @weather = Spriteset_Weather.new(@viewport2)
  end
  #--------------------------------------------------------------------------
  # * Create Picture Sprite
  #--------------------------------------------------------------------------
  def create_pictures
    @picture_sprites = []
    for i in 1..20
      @picture_sprites.push(Sprite_Picture.new(@viewport2,
        $game_map.screen.pictures[i]))
    end
  end
  #--------------------------------------------------------------------------
  # * Create Timer Sprite
  #--------------------------------------------------------------------------
  def create_timer
    @timer_sprite = Sprite_Timer.new(@viewport2)
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    dispose_tilemap
    dispose_parallax
    dispose_characters
    dispose_shadow
    dispose_weather
    dispose_pictures
    dispose_timer
    dispose_viewports
  end
  #--------------------------------------------------------------------------
  # * Dispose of Tilemap
  #--------------------------------------------------------------------------
  def dispose_tilemap
    @tilemap.dispose
  end
  #--------------------------------------------------------------------------
  # * Dispose of Parallax
  #--------------------------------------------------------------------------
  def dispose_parallax
    @parallax.dispose
  end
  #--------------------------------------------------------------------------
  # * Dispose of Character Sprite
  #--------------------------------------------------------------------------
  def dispose_characters
    for sprite in @character_sprites
      sprite.dispose
    end
  end
  #--------------------------------------------------------------------------
  # * Dispose of Airship Shadow Sprite
  #--------------------------------------------------------------------------
  def dispose_shadow
    @shadow_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Dispose of Weather
  #--------------------------------------------------------------------------
  def dispose_weather
    @weather.dispose
  end
  #--------------------------------------------------------------------------
  # * Dispose of Picture Sprite
  #--------------------------------------------------------------------------
  def dispose_pictures
    for sprite in @picture_sprites
      sprite.dispose
    end
  end
  #--------------------------------------------------------------------------
  # * Dispose of Timer Sprite
  #--------------------------------------------------------------------------
  def dispose_timer
    @timer_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Dispose of Viewport
  #--------------------------------------------------------------------------
  def dispose_viewports
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    update_tilemap
    update_parallax
    update_characters
    update_shadow
    update_weather
    update_pictures
    update_timer
    update_viewports
  end
  #--------------------------------------------------------------------------
  # * Update Tilemap
  #--------------------------------------------------------------------------
  def update_tilemap
    @tilemap.ox = $game_map.display_x / 8
    @tilemap.oy = $game_map.display_y / 8
    @tilemap.update
  end
  #--------------------------------------------------------------------------
  # * Update Parallax
  #--------------------------------------------------------------------------
  def update_parallax
    if @parallax_name != $game_map.parallax_name
      @parallax_name = $game_map.parallax_name
      if @parallax.bitmap != nil
        @parallax.bitmap.dispose
        @parallax.bitmap = nil
      end
      if @parallax_name != ""
        @parallax.bitmap = Cache.parallax(@parallax_name)
      end
      Graphics.frame_reset
    end
    @parallax.ox = $game_map.calc_parallax_x(@parallax.bitmap)
    @parallax.oy = $game_map.calc_parallax_y(@parallax.bitmap)
  end
  #--------------------------------------------------------------------------
  # * Update Character Sprite
  #--------------------------------------------------------------------------
  def update_characters
    for sprite in @character_sprites
      sprite.update
    end
  end
  #--------------------------------------------------------------------------
  # * Update Airship Shadow Sprite
  #--------------------------------------------------------------------------
  def update_shadow
    airship = $game_map.airship
    @shadow_sprite.x = airship.screen_x
    @shadow_sprite.y = airship.screen_y + airship.altitude
    @shadow_sprite.opacity = airship.altitude * 8
    @shadow_sprite.update
  end
  #--------------------------------------------------------------------------
  # * Update Weather
  #--------------------------------------------------------------------------
  def update_weather
    @weather.type = $game_map.screen.weather_type
    @weather.max = $game_map.screen.weather_max
    @weather.ox = $game_map.display_x / 8
    @weather.oy = $game_map.display_y / 8
    @weather.update
  end
  #--------------------------------------------------------------------------
  # *Update Picture Sprite
  #--------------------------------------------------------------------------
  def update_pictures
    for sprite in @picture_sprites
      sprite.update
    end
  end
  #--------------------------------------------------------------------------
  # * Update Timer Sprite
  #--------------------------------------------------------------------------
  def update_timer
    @timer_sprite.update
  end
  #--------------------------------------------------------------------------
  # * Update Viewport
  #--------------------------------------------------------------------------
  def update_viewports
    @viewport1.tone = $game_map.screen.tone
    @viewport1.ox = $game_map.screen.shake
    @viewport2.color = $game_map.screen.flash_color
    @viewport3.color.set(0, 0, 0, 255 - $game_map.screen.brightness)
    @viewport1.update
    @viewport2.update
    @viewport3.update
  end
end
