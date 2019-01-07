###-----------------------------------------------------------------------------
#  Old (VX) Battleback script v1.0
#  Created by Neon Black
#  V0.1 - 7.7.2012 - Original alpha version
#  V1.0 - 1.8.2013 - Version created for release
#  Created for both commercial and non-commercial use as long as credit is
#  given to Neon Black.
###-----------------------------------------------------------------------------

module CP             # Do not
module OLD_BATTLEBACK #  change these.

# The switch to disable the changes this script makes entirely.  While this
# switch is on, the default battlebacks are used.
DISABLE_SWITCH = 79

# This sets the colour offset of the battleback.  Use this to darken or
# lighten the battleback as you see fit.
COLOR_SET = Color.new(16, 16, 16, 128)

# Determines if events are shown in the background image.  The default
# behaviour of this is "false".
EVENTS_IN_BACKGROUND = true

# The percentage to stretch the battleback by.  Read as a percentage.  Set it
# to 100 to prevent it from stretching.
STRETCH_X = 110
STRETCH_Y = 110

# Set if phasing and the radial blur are used.  VX Ace uses radial blur but NO
# phasing if no battleback is defined by a map while VX uses both phasing and
# radial blur by default.
USE_PHASING = true
USE_RADIAL = true

# The battlefloor image settings.  First is the name of the battlefloor image
# which must be placed in the "Graphics/System" folder.  Second is the Y
# position of the image on the screen which can be adjusted to move the image
# up or down.  Finally is the opacity of the image.
BATTLEFLOOR = "BattleFloor"
BF_Y_OFFSET = Graphics.height - 120
BF_OPACITY = 128

# The amplitude, length, and speed of the phasing option.  Amp is the
# distance of the horizontal movement from the edges of the screen.  Length is
# the distance vertically between each part of the wave, and speed is how
# quickly the phasing effect moves.
WAVE_AMP = 8
WAVE_LENGTH = 240
WAVE_SPEED = 120

# The angle and division of the radial blur.  Angle is how far it is rotated
# clockwise while division is the number of times the image is copied before
# reaching the angle.  This is time consuming by the system.
BLUR_ANGLE = 90
BLUR_DIVISION = 12

###--------------------------------------------------------------------------###
#  The following lines are the actual core code of the script.  While you are  #
#  certainly invited to look, modifying it may result in undesirable results.  #
#  Modify at your own risk!                                                    #
###--------------------------------------------------------------------------###


end
end

$imported = {} if $imported == nil
$imported["CP_OLD_BATTLEBACK"] = 1.0

class Spriteset_Battle
  include CP::OLD_BATTLEBACK
  
  ## Does radial blur and phasing.
  def radial_blur(sprite)
    sprite.bitmap.radial_blur(BLUR_ANGLE, BLUR_DIVISION)
  end
  
  def phasing(sprite)
    sprite.wave_amp = WAVE_AMP
    sprite.wave_length = WAVE_LENGTH
    sprite.wave_speed = WAVE_SPEED
  end
  
  ## Creates the blurred background image.
  alias cp_old_bb1 create_battleback1
  def create_battleback1
    return cp_old_bb1 if $game_switches[DISABLE_SWITCH]
    @back1_sprite = Sprite.new(@viewport1)
    @back1_sprite.bitmap = create_blurry_background_bitmap
    @back1_sprite.color.set(COLOR_SET)
    radial_blur(@back1_sprite) if USE_RADIAL
    phasing(@back1_sprite) if USE_PHASING
    @back1_sprite.z = 0
    center_sprite(@back1_sprite)
  end
  
  ## Creates the floor shadow or other floor image.
  alias cp_old_bb2 create_battleback2
  def create_battleback2
    return cp_old_bb2 if $game_switches[DISABLE_SWITCH]
    @back2_sprite = Sprite.new(@viewport1)
    @back2_sprite.bitmap = Cache.system(BATTLEFLOOR)
    @back2_sprite.opacity = BF_OPACITY
    @back2_sprite.z = 1
    center_sprite(@back2_sprite)
    @back2_sprite.y = BF_Y_OFFSET
  end
  
  ## Sends back a blurred background image.
  alias cp_old_bbb create_blurry_background_bitmap
  def create_blurry_background_bitmap
    return cp_old_bbb if $game_switches[DISABLE_SWITCH]
    if EVENTS_IN_BACKGROUND && !$BTEST  ## Determines what kind of image to use.
      source = Scene_Map.pre_battle_scene
    elsif !$BTEST
      source = SceneManager.background_bitmap
    else
      source =  Cache.battleback1(battleback1_name)
    end
    bitmap = Bitmap.new((source.width * STRETCH_X) / 100,
                        (source.height * STRETCH_Y) / 100)
    bitmap.stretch_blt(bitmap.rect, source, source.rect)
    bitmap
  end
end

## Stores a background with events that can be grabbed by the battle sprites.
class Scene_Map < Scene_Base
  @@pre_battle_scene = Bitmap.new(1, 1)
  def self.pre_battle_scene; return @@pre_battle_scene; end
  
  alias cp_pre_battle pre_battle_scene
  def pre_battle_scene
    SceneManager.snapshot_for_background
    @@pre_battle_scene = SceneManager.background_bitmap.clone
    cp_pre_battle
  end
end

###--------------------------------------------------------------------------###
#  End of script.                                                              #
###--------------------------------------------------------------------------###