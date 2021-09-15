#encoding:UTF-8
# Spriteset_Battle
#==============================================================================
# ** Spriteset_Battle
#------------------------------------------------------------------------------
#  This class brings together battle screen sprites. It's used within the
# Scene_Battle class.
#==============================================================================

class Spriteset_Battle
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    create_viewports
    create_battleback1
    create_battleback2
    create_enemies
    create_actors
    create_pictures
    create_timer
    update
  end
  #--------------------------------------------------------------------------
  # * Create Viewport
  #--------------------------------------------------------------------------
  def create_viewports
    @viewport1 = Viewport.new
    @viewport2 = Viewport.new
    @viewport3 = Viewport.new
    @viewport2.z = 50
    @viewport3.z = 100
  end
  #--------------------------------------------------------------------------
  # * Create Battle Background (Floor) Sprite
  #--------------------------------------------------------------------------
  def create_battleback1
    @back1_sprite = Sprite.new(@viewport1)
    @back1_sprite.bitmap = battleback1_bitmap
    @back1_sprite.z = 0
    center_sprite(@back1_sprite)
  end
  #--------------------------------------------------------------------------
  # * Create Battle Background (Wall) Sprite
  #--------------------------------------------------------------------------
  def create_battleback2
    @back2_sprite = Sprite.new(@viewport1)
    @back2_sprite.bitmap = battleback2_bitmap
    @back2_sprite.z = 1
    center_sprite(@back2_sprite)
  end
  #--------------------------------------------------------------------------
  # * Get Battle Background (Floor) Bitmap
  #--------------------------------------------------------------------------
  def battleback1_bitmap
    if battleback1_name
      Cache.battleback1(battleback1_name)
    else
      create_blurry_background_bitmap
    end
  end
  #--------------------------------------------------------------------------
  # * Get Battle Background (Wall) Bitmap
  #--------------------------------------------------------------------------
  def battleback2_bitmap
    if battleback2_name
      Cache.battleback2(battleback2_name)
    else
      Bitmap.new(1, 1)
    end
  end
  #--------------------------------------------------------------------------
  # * Create Battle Background Bitmap from Processed Map Screen
  #--------------------------------------------------------------------------
  def create_blurry_background_bitmap
    source = SceneManager.background_bitmap
    bitmap = Bitmap.new(640, 480)
    bitmap.stretch_blt(bitmap.rect, source, source.rect)
    bitmap.radial_blur(120, 16)
    bitmap
  end
  #--------------------------------------------------------------------------
  # * Get Filename of Battle Background (Floor)
  #--------------------------------------------------------------------------
  def battleback1_name
    if $BTEST
      $data_system.battleback1_name
    elsif $game_map.battleback1_name
      $game_map.battleback1_name
    elsif $game_map.overworld?
      overworld_battleback1_name
    end
  end
  #--------------------------------------------------------------------------
  # * Get Filename of Battle Background (Wall)
  #--------------------------------------------------------------------------
  def battleback2_name
    if $BTEST
      $data_system.battleback2_name
    elsif $game_map.battleback2_name
      $game_map.battleback2_name
    elsif $game_map.overworld?
      overworld_battleback2_name
    end
  end
  #--------------------------------------------------------------------------
  # * Get Filename of Field Battle Background (Floor)
  #--------------------------------------------------------------------------
  def overworld_battleback1_name
    $game_player.vehicle ? ship_battleback1_name : normal_battleback1_name
  end
  #--------------------------------------------------------------------------
  # * Get Filename of Field Battle Background (Wall)
  #--------------------------------------------------------------------------
  def overworld_battleback2_name
    $game_player.vehicle ? ship_battleback2_name : normal_battleback2_name
  end
  #--------------------------------------------------------------------------
  # * Get Filename of Normal Battle Background (Floor)
  #--------------------------------------------------------------------------
  def normal_battleback1_name
    terrain_battleback1_name(autotile_type(1)) ||
    terrain_battleback1_name(autotile_type(0)) ||
    default_battleback1_name
  end
  #--------------------------------------------------------------------------
  # * Get Filename of Normal Battle Background (Wall)
  #--------------------------------------------------------------------------
  def normal_battleback2_name
    terrain_battleback2_name(autotile_type(1)) ||
    terrain_battleback2_name(autotile_type(0)) ||
    default_battleback2_name
  end
  #--------------------------------------------------------------------------
  # * Get Filename of Battle Background (Floor) Corresponding to Terrain
  #--------------------------------------------------------------------------
  def terrain_battleback1_name(type)
    case type
    when 24,25        # Wasteland
      "Wasteland"
    when 26,27        # Dirt field
      "DirtField"
    when 32,33        # Desert
      "Desert"
    when 34           # Rocks
      "Lava1"
    when 35           # Rocks (lava)
      "Lava2"
    when 40,41        # Snowfield
      "Snowfield"
    when 42           # Clouds
      "Clouds"
    when 4,5          # Poisonous swamp
      "PoisonSwamp"
    end
  end
  #--------------------------------------------------------------------------
  # * Get Filename of Battle Background (Wall) Corresponding to Terrain
  #--------------------------------------------------------------------------
  def terrain_battleback2_name(type)
    case type
    when 20,21        # Forest
      "Forest1"
    when 22,30,38     # Low hill
      "Cliff"
    when 24,25,26,27  # Wasteland, dirt field
      "Wasteland"
    when 32,33        # Desert
      "Desert"
    when 34,35        #  Rocks
      "Lava"
    when 40,41        # Snowfield
      "Snowfield"
    when 42           # Clouds
      "Clouds"
    when 4,5          # Poisonous swamp
      "PoisonSwamp"
    end
  end
  #--------------------------------------------------------------------------
  # * Get Filename of Default Battle Background (Floor)
  #--------------------------------------------------------------------------
  def default_battleback1_name
    "Grassland"
  end
  #--------------------------------------------------------------------------
  # * Get Filename of Default Battle Background (Wall)
  #--------------------------------------------------------------------------
  def default_battleback2_name
    "Grassland"
  end
  #--------------------------------------------------------------------------
  # * Get Filename of Battle Background (Floor) When on Ship
  #--------------------------------------------------------------------------
  def ship_battleback1_name
    "Ship"
  end
  #--------------------------------------------------------------------------
  # * Get Filename of Battle Background (Wall) When on Ship
  #--------------------------------------------------------------------------
  def ship_battleback2_name
    "Ship"
  end
  #--------------------------------------------------------------------------
  # * Get Type of Auto Tile at Player's Feet
  #--------------------------------------------------------------------------
  def autotile_type(z)
    $game_map.autotile_type($game_player.x, $game_player.y, z)
  end
  #--------------------------------------------------------------------------
  # * Move Sprite to Screen Center
  #--------------------------------------------------------------------------
  def center_sprite(sprite)
    sprite.ox = sprite.bitmap.width / 2
    sprite.oy = sprite.bitmap.height / 2
    sprite.x = Graphics.width / 2
    sprite.y = Graphics.height / 2
  end
  #--------------------------------------------------------------------------
  # * Create Enemy Sprite
  #--------------------------------------------------------------------------
  def create_enemies
    @enemy_sprites = $game_troop.members.reverse.collect do |enemy|
      Sprite_Battler.new(@viewport1, enemy)
    end
  end
  #--------------------------------------------------------------------------
  # * Create Actor Sprite
  #    By default, the actor image is not displayed, but for convenience
  #    a dummy sprite is created for treating enemies and allies the same.
  #--------------------------------------------------------------------------
  def create_actors
    @actor_sprites = Array.new(4) { Sprite_Battler.new(@viewport1) }
  end
  #--------------------------------------------------------------------------
  # * Create Picture Sprite
  #    Create an empty array in the initial state and then add to it as
  #    necessary.
  #--------------------------------------------------------------------------
  def create_pictures
    @picture_sprites = []
  end
  #--------------------------------------------------------------------------
  # * Create Timer Sprite
  #--------------------------------------------------------------------------
  def create_timer
    @timer_sprite = Sprite_Timer.new(@viewport2)
  end
  #--------------------------------------------------------------------------
  # * Free
  #--------------------------------------------------------------------------
  def dispose
    dispose_battleback1
    dispose_battleback2
    dispose_enemies
    dispose_actors
    dispose_pictures
    dispose_timer
    dispose_viewports
  end
  #--------------------------------------------------------------------------
  # * Free Battle Background (Floor) Sprite
  #--------------------------------------------------------------------------
  def dispose_battleback1
    @back1_sprite.bitmap.dispose
    @back1_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Free Battle Background (Wall) Sprite
  #--------------------------------------------------------------------------
  def dispose_battleback2
    @back2_sprite.bitmap.dispose
    @back2_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Free Enemy Sprite
  #--------------------------------------------------------------------------
  def dispose_enemies
    @enemy_sprites.each {|sprite| sprite.dispose }
  end
  #--------------------------------------------------------------------------
  # * Free Actor Sprite
  #--------------------------------------------------------------------------
  def dispose_actors
    @actor_sprites.each {|sprite| sprite.dispose }
  end
  #--------------------------------------------------------------------------
  # * Free Picture Sprite
  #--------------------------------------------------------------------------
  def dispose_pictures
    @picture_sprites.compact.each {|sprite| sprite.dispose }
  end
  #--------------------------------------------------------------------------
  # * Free Timer Sprite
  #--------------------------------------------------------------------------
  def dispose_timer
    @timer_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Free Viewport
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
    update_battleback1
    update_battleback2
    update_enemies
    update_actors
    update_pictures
    update_timer
    update_viewports
  end
  #--------------------------------------------------------------------------
  # * Update Battle Background (Floor) Sprite
  #--------------------------------------------------------------------------
  def update_battleback1
    @back1_sprite.update
  end
  #--------------------------------------------------------------------------
  # * Update Battle Background (Wall) Sprite
  #--------------------------------------------------------------------------
  def update_battleback2
    @back2_sprite.update
  end
  #--------------------------------------------------------------------------
  # * Update Enemy Sprite
  #--------------------------------------------------------------------------
  def update_enemies
    @enemy_sprites.each {|sprite| sprite.update }
  end
  #--------------------------------------------------------------------------
  # * Update Actor Sprite
  #--------------------------------------------------------------------------
  def update_actors
    @actor_sprites.each_with_index do |sprite, i|
      sprite.battler = $game_party.members[i]
      sprite.update
    end
  end
  #--------------------------------------------------------------------------
  # *Update Picture Sprite
  #--------------------------------------------------------------------------
  def update_pictures
    $game_troop.screen.pictures.each do |pic|
      @picture_sprites[pic.number] ||= Sprite_Picture.new(@viewport2, pic)
      @picture_sprites[pic.number].update
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
    @viewport1.tone.set($game_troop.screen.tone)
    @viewport1.ox = $game_troop.screen.shake
    @viewport2.color.set($game_troop.screen.flash_color)
    @viewport3.color.set(0, 0, 0, 255 - $game_troop.screen.brightness)
    @viewport1.update
    @viewport2.update
    @viewport3.update
  end
  #--------------------------------------------------------------------------
  # * Get Enemy and Actor Sprites
  #--------------------------------------------------------------------------
  def battler_sprites
    @enemy_sprites + @actor_sprites
  end
  #--------------------------------------------------------------------------
  # * Determine if Animation is Being Displayed
  #--------------------------------------------------------------------------
  def animation?
    battler_sprites.any? {|sprite| sprite.animation? }
  end
  #--------------------------------------------------------------------------
  # * Determine if Effect Is Executing
  #--------------------------------------------------------------------------
  def effect?
    battler_sprites.any? {|sprite| sprite.effect? }
  end
end
