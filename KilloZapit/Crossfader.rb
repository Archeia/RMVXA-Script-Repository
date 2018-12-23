#========================================================================
# ** Crossfader, by: KilloZapit
#------------------------------------------------------------------------
# Just a script to tweak the fades to use fancy crossfades like the
# battle transition screens for all fades. By default this is made to use 
# an image in the Graphics/System/ directory. You can set it to use no image, 
# but it's not hard to make a simple image to use. 
#------------------------------------------------------------------------

module KZFadeConfig
  # FADE_IMAGE: Transition image used for fades.
  # Works the battle transition image, use "" to use no image.
  FADE_IMAGE = "Graphics/System/Fade"
  # FADE_EDGE: Effects how smooth image fades are.
  FADE_EDGE = 100
  # FADE_TIME: Set to a number to set how long fades take or leave nil for
  # a default value based on the transition_speed method.
  FADE_TIME = nil
  # FADE_TIME_FACTOR: Multiplier for default fade times.
  FADE_TIME_FACTOR = 2
 
  # DO_MAP_FADES: If true, changes map transfers to use crossfades instead.
  # Only works with fades to black though, fades to white will be the same.
  DO_MAP_FADES = true
 
  # DO_BATTLE_FADES: If true, changes fadeing out after a battle to use
  # crossfades after a compleated battle.
  DO_BATTLE_FADES = true
  # D0_BATTLE_RUN_CROSSFADE: If this is true it will do a normal fade instead of
  # a crossfade if the battle ends and some enemies are still alive.
  D0_BATTLE_RUN_FADE = true
 
  # DO_GAMEOVER_FADES: changes the gameover scene to use crossfades as well,
  # though they will be a lot slower, using the gameover scene's fade times.
  DO_GAMEOVER_FADES = true
  # DO_GAMEOVER_FADEOUT_FROZEN_GRAPHICS: if this is true it will fade out what
  # ever was displayed on the screen before displaying the gameover screen,
  # if it is false it will fade directly to the gameover screen instead.
  DO_GAMEOVER_FADEOUT_FROZEN_GRAPHICS = false
end

class Scene_Base
 
  def crossfade_time
    KZFadeConfig::FADE_TIME || transition_speed * KZFadeConfig::FADE_TIME_FACTOR
  end
 
  def perform_transition
    Graphics.transition(crossfade_time, KZFadeConfig::FADE_IMAGE,
                        KZFadeConfig::FADE_EDGE)
  end
 
  #--------------------------------------------------------------------------
  # * Fade Out All Sounds and Graphics
  #--------------------------------------------------------------------------
  def fadeout_all(time = 1000)
    RPG::BGM.fade(time)
    RPG::BGS.fade(time)
    RPG::ME.fade(time)
    crossfade_to_black
    RPG::BGM.stop
    RPG::BGS.stop
    RPG::ME.stop
  end
    
  #--------------------------------------------------------------------------
  # * Do a crossfade to a blank screen
  #--------------------------------------------------------------------------
  def crossfade_to_black
    Graphics.freeze
    sprite = Sprite.new
    sprite.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    color = Color.new(0, 0, 0)
    sprite.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, color)
    sprite.x = 0
    sprite.y = 0
    sprite.z = 10000
    perform_transition
    Graphics.freeze
    sprite.dispose
  end
 
end

class Scene_Map
  #--------------------------------------------------------------------------
  # * Force one frame update during black screens to make sure all the images
  # are loaded and all the screen tints are set right.
  #--------------------------------------------------------------------------
  alias_method :perform_transition_fade_base, :perform_transition
  def perform_transition
    update_for_fade
    perform_transition_fade_base
  end
 
  #--------------------------------------------------------------------------
  # * Preprocessing for Transferring Player
  #--------------------------------------------------------------------------
  def pre_transfer
    @map_name_window.close
    case $game_temp.fade_type
    when 0
      crossfade_to_black
    when 1
      white_fadeout(fadeout_speed)
    end
  end
 
  #--------------------------------------------------------------------------
  # * Post Processing for Transferring Player
  #--------------------------------------------------------------------------
  def post_transfer
    case $game_temp.fade_type
    when 0
      perform_transition
    when 1
      Graphics.wait(fadein_speed / 2)
      update_for_fade
      white_fadein(fadein_speed)
    end
    @map_name_window.open
  end

end if KZFadeConfig::DO_MAP_FADES

class Scene_Battle < Scene_Base
 
  def pre_terminate
    super
    if SceneManager.scene_is?(Scene_Map)
      if (!KZFadeConfig::D0_BATTLE_RUN_FADE) || $game_troop.all_dead?
        crossfade_to_black
      else
        Graphics.fadeout(30)
      end
    elsif SceneManager.scene_is?(Scene_Title)
      Graphics.fadeout(60)
    end
  end
 
end if KZFadeConfig::DO_BATTLE_FADES

class Scene_Gameover < Scene_Base
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    play_gameover_music
    fadeout_frozen_graphics if KZFadeConfig::DO_GAMEOVER_FADEOUT_FROZEN_GRAPHICS
    create_background
  end
 
  #--------------------------------------------------------------------------
  # * Execute Transition
  #--------------------------------------------------------------------------
  def perform_transition
    Graphics.transition(fadein_speed, KZFadeConfig::FADE_IMAGE,
                        KZFadeConfig::FADE_EDGE)
  end
  #--------------------------------------------------------------------------
  # * Fade Out Frozen Graphics
  #--------------------------------------------------------------------------
  def fadeout_frozen_graphics
    Graphics.transition(fadeout_speed, KZFadeConfig::FADE_IMAGE,
                        KZFadeConfig::FADE_EDGE)
    Graphics.freeze
  end
 
end if KZFadeConfig::DO_GAMEOVER_FADES