#==============================================================================
#    Flash Selected Enemy
#    Version: 1.0.0
#    Author: modern algebra (rmrk.net)
#    Date: July 18, 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    
#    This script will flash the battler of any enemy currently selected when 
#   the player is targetting.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials.
#
#    This script is designed to work with the DBS and may be incompatible with
#   other battle scripts. 
#
#    This script is completely plug & play, and without modification the 
#   selected enemy will whiten. If you want to change the colour to which it
#   flashes, the duration of the flash, or the time between flashes, then go to
#   the editable region starting at line 30 and change those three options.
#==============================================================================

$imported ||= {}
$imported[:"FlashSelectedEnemy 1.0.0"] = true

#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#    BEGIN Editable Region
#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
FSE_REST_FRAMES = 4        # Number of frames between flashes
FSE_FLASH_DURATION = 24    # Number of frames for each flash to complete
FSE_FLASH_COLOUR = [255,255,255] # Colour of the flash, format: [red, green, blue]
#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#    END Editable Region
#//////////////////////////////////////////////////////////////////////////////

#==============================================================================
# ** Sprite Battler
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - start_effect; update_effect
#    new method - update_fse_flash
#==============================================================================

class Sprite_Battler
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Start Effect
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_fse_strteffct_7fk9 start_effect
  def start_effect(effect_type, *args, &block)
    if effect_type == :fse_flash
      @effect_duration = FSE_FLASH_DURATION
      @fse_flash_mod = 320 / FSE_FLASH_DURATION
      @battler_visible = true
    end
    ma_fse_strteffct_7fk9(effect_type, *args, &block)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Effect
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_fse_updeffct_9hv2 update_effect
  def update_effect(*args, &block)
    # If playing an FSE flash
    if @effect_duration > 0 && @effect_type == :fse_flash
      update_fse_flash
    end
    # Stop effect if set to stop
    if @battler.sprite_effect_type == :fse_revert_to_normal
      revert_to_normal
      @battler.sprite_effect_type = nil
    end
    ma_fse_updeffct_9hv2(*args, &block) # Run Original Method
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Flash
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_fse_flash
    self.color.set(*FSE_FLASH_COLOUR)
    if @effect_duration > (FSE_FLASH_DURATION / 2)
      self.color.alpha = (FSE_FLASH_DURATION - @effect_duration) * @fse_flash_mod
    else
      self.color.alpha = @effect_duration * @fse_flash_mod
    end
  end
end

#==============================================================================
# ** Scene_Battle
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - select_enemy_selection; update
#==============================================================================

class Scene_Battle
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Start Enemy Selection
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_fse_strtenemyselect_3hk9 select_enemy_selection
  def select_enemy_selection(*args, &block)
    ma_fse_strtenemyselect_3hk9(*args, &block)
    @fse_effect_frames = FSE_FLASH_DURATION
    @fse_flash_frames = 0 # Initialize blink count
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Frame Update
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_fse_udat_8hz5 update
  def update(*args, &block)
    old_enemy = @enemy_window.active ? @enemy_window.enemy : nil
    ma_fse_udat_8hz5(*args, &block)
    if !@enemy_window.active || old_enemy != @enemy_window.enemy # If cursor moves
      # Set the flash to the newly selected enemy
      old_enemy.sprite_effect_type = :fse_revert_to_normal if old_enemy && !old_enemy.dead?
      @fse_flash_frames = 0
    end
    if @enemy_window.active
      if @fse_flash_frames <= 0
        @fse_flash_frames = @fse_effect_frames + FSE_REST_FRAMES
        @enemy_window.enemy.sprite_effect_type = :fse_flash
      end
      @fse_flash_frames -= 1
    end
  end
end