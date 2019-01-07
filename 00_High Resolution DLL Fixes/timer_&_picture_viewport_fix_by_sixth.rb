#-------------------------------------------------------------------------------
# This snippet was made to fix some unwanted behaviours of the timer and picture
# sprites on higher resolutions (meaning not the default 544x416 resolution).
# If you are using Yanfly's or Dekita's core scripts, put this below those!
#-------------------------------------------------------------------------------
# Made by: Sixth
#-------------------------------------------------------------------------------

class Spriteset_Map
  #--------------------------------------------------------------------------
  # alias method: Create Viewport
  #--------------------------------------------------------------------------
  alias timer_view_new121 create_viewports
  def create_viewports
    timer_view_new121
    @viewportTimer = Viewport.new
    @viewportPicture = Viewport.new
    @viewportTimer.z = 190
    @viewportPicture.z = 170   
  end
  #--------------------------------------------------------------------------
  # overwrite method: Create Timer Sprite
  #--------------------------------------------------------------------------
  def create_timer
    @timer_sprite = Sprite_Timer.new(@viewportTimer)
  end
  #--------------------------------------------------------------------------
  # alias method: Free Viewport
  #--------------------------------------------------------------------------
  alias timer_view_disp_new121 dispose_viewports
  def dispose_viewports
    timer_view_disp_new121
    @viewportTimer.dispose
    @viewportPicture.dispose
  end
  #--------------------------------------------------------------------------
  # overwrite method: Update Picture Sprite
  #--------------------------------------------------------------------------
  def update_pictures
    $game_map.screen.pictures.each do |pic|
      @picture_sprites[pic.number] ||= Sprite_Picture.new(@viewportPicture, pic)
      @picture_sprites[pic.number].update
    end
  end
  #--------------------------------------------------------------------------
  # alias method: Update Viewport
  #--------------------------------------------------------------------------
  alias timer_view_upd_new121 update_viewports
  def update_viewports
    timer_view_upd_new121
    @viewportTimer.color.set($game_map.screen.flash_color)
    @viewportTimer.update
    @viewportPicture.color.set($game_map.screen.flash_color)
    @viewportPicture.update
  end
end

class Spriteset_Battle
  #--------------------------------------------------------------------------
  # alias method: Create Viewport
  #--------------------------------------------------------------------------
  alias timer_view_new122 create_viewports
  def create_viewports
    timer_view_new122
    @viewportTimer = Viewport.new
    @viewportPicture = Viewport.new
    @viewportTimer.z = 190
    @viewportPicture.z = 170
  end
  #--------------------------------------------------------------------------
  # overwrite method: Create Timer Sprite
  #--------------------------------------------------------------------------
  def create_timer
    @timer_sprite = Sprite_Timer.new(@viewportTimer)
  end
  #--------------------------------------------------------------------------
  # alias method: Free Viewport
  #--------------------------------------------------------------------------
  alias timer_view_disp122 dispose_viewports
  def dispose_viewports
    timer_view_disp122
    @viewportTimer.dispose
    @viewportPicture.dispose
  end
  #--------------------------------------------------------------------------
  # overwrite method: Update Picture Sprite
  #--------------------------------------------------------------------------
  def update_pictures
    $game_troop.screen.pictures.each do |pic|
      @picture_sprites[pic.number] ||= Sprite_Picture.new(@viewportPicture, pic)
      @picture_sprites[pic.number].update
    end
  end
  #--------------------------------------------------------------------------
  # alias method: Update Viewport
  #--------------------------------------------------------------------------
  alias timer_view_upd122 update_viewports
  def update_viewports
    timer_view_upd122
    @viewportTimer.color.set($game_troop.screen.flash_color)
    @viewportTimer.update
    @viewportPicture.color.set($game_troop.screen.flash_color)
    @viewportPicture.update
  end
end