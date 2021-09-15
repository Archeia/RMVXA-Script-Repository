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
    create_battleback
    create_battlefloor
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
    @viewport1 = Viewport.new(0, 0, 544, 416)
    @viewport2 = Viewport.new(0, 0, 544, 416)
    @viewport3 = Viewport.new(0, 0, 544, 416)
    @viewport2.z = 50
    @viewport3.z = 100
  end
  #--------------------------------------------------------------------------
  # * Create Battleback Sprite
  #--------------------------------------------------------------------------
  def create_battleback
    source = $game_temp.background_bitmap
    bitmap = Bitmap.new(640, 480)
    bitmap.stretch_blt(bitmap.rect, source, source.rect)
    bitmap.radial_blur(90, 12)
    @battleback_sprite = Sprite.new(@viewport1)
    @battleback_sprite.bitmap = bitmap
    @battleback_sprite.ox = 320
    @battleback_sprite.oy = 240
    @battleback_sprite.x = 272
    @battleback_sprite.y = 176
    @battleback_sprite.wave_amp = 8
    @battleback_sprite.wave_length = 240
    @battleback_sprite.wave_speed = 120
  end
  #--------------------------------------------------------------------------
  # * Create Battlefloor Sprite
  #--------------------------------------------------------------------------
  def create_battlefloor
    @battlefloor_sprite = Sprite.new(@viewport1)
    @battlefloor_sprite.bitmap = Cache.system("BattleFloor")
    @battlefloor_sprite.x = 0
    @battlefloor_sprite.y = 192
    @battlefloor_sprite.z = 1
    @battlefloor_sprite.opacity = 128
  end
  #--------------------------------------------------------------------------
  # * Create Enemy Sprite
  #--------------------------------------------------------------------------
  def create_enemies
    @enemy_sprites = []
    for enemy in $game_troop.members.reverse
      @enemy_sprites.push(Sprite_Battler.new(@viewport1, enemy))
    end
  end
  #--------------------------------------------------------------------------
  # * Create Actor Sprite
  #    By default, the actor image is not displayed, but a dummy sprite is
  #    created for treating enemies and allies the same, if required.
  #--------------------------------------------------------------------------
  def create_actors
    @actor_sprites = []
    @actor_sprites.push(Sprite_Battler.new(@viewport1))
    @actor_sprites.push(Sprite_Battler.new(@viewport1))
    @actor_sprites.push(Sprite_Battler.new(@viewport1))
    @actor_sprites.push(Sprite_Battler.new(@viewport1))
  end
  #--------------------------------------------------------------------------
  # * Create Picture Sprite
  #--------------------------------------------------------------------------
  def create_pictures
    @picture_sprites = []
    for i in 1..20
      @picture_sprites.push(Sprite_Picture.new(@viewport2,
        $game_troop.screen.pictures[i]))
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
    dispose_battleback_bitmap
    dispose_battleback
    dispose_battlefloor
    dispose_enemies
    dispose_actors
    dispose_pictures
    dispose_timer
    dispose_viewports
  end
  #--------------------------------------------------------------------------
  # * Dispose of Battleback Bitmap
  #--------------------------------------------------------------------------
  def dispose_battleback_bitmap
    @battleback_sprite.bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # * Dispose of Battleback Sprite
  #--------------------------------------------------------------------------
  def dispose_battleback
    @battleback_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Dispose of Battlefloor Sprite
  #--------------------------------------------------------------------------
  def dispose_battlefloor
    @battlefloor_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Dispose of Enemy Sprite
  #--------------------------------------------------------------------------
  def dispose_enemies
    for sprite in @enemy_sprites
      sprite.dispose
    end
  end
  #--------------------------------------------------------------------------
  # * Dispose of Actor Sprite
  #--------------------------------------------------------------------------
  def dispose_actors
    for sprite in @actor_sprites
      sprite.dispose
    end
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
    update_battleback
    update_battlefloor
    update_enemies
    update_actors
    update_pictures
    update_timer
    update_viewports
  end
  #--------------------------------------------------------------------------
  # * Update Battleback
  #--------------------------------------------------------------------------
  def update_battleback
    @battleback_sprite.update
  end
  #--------------------------------------------------------------------------
  # * Update Battlefloor
  #--------------------------------------------------------------------------
  def update_battlefloor
    @battlefloor_sprite.update
  end
  #--------------------------------------------------------------------------
  # * Update Enemy Sprite
  #--------------------------------------------------------------------------
  def update_enemies
    for sprite in @enemy_sprites
      sprite.update
    end
  end
  #--------------------------------------------------------------------------
  # * Update Actor Sprite
  #--------------------------------------------------------------------------
  def update_actors
    @actor_sprites[0].battler = $game_party.members[0]
    @actor_sprites[1].battler = $game_party.members[1]
    @actor_sprites[2].battler = $game_party.members[2]
    @actor_sprites[3].battler = $game_party.members[3]
    for sprite in @actor_sprites
      sprite.update
    end
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
    @viewport1.tone = $game_troop.screen.tone
    @viewport1.ox = $game_troop.screen.shake
    @viewport2.color = $game_troop.screen.flash_color
    @viewport3.color.set(0, 0, 0, 255 - $game_troop.screen.brightness)
    @viewport1.update
    @viewport2.update
    @viewport3.update
  end
  #--------------------------------------------------------------------------
  # * Determine if animation is being displayed
  #--------------------------------------------------------------------------
  def animation?
    for sprite in @enemy_sprites + @actor_sprites
      return true if sprite.animation?
    end
    return false
  end
end
