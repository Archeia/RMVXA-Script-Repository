#==============================================================================#
# ** IEX(Icy Engine Xelion) - Game Pause
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Requested By  : Celianna
# ** Script-Status : Addon (Area, Maps)
# ** Script Type   : Passage Edit
# ** Date Created  : 01/06/2010 (DD/MM/YYYY)
# ** Date Modified : 07/24/2011 (DD/MM/YYYY)
# ** Script Tag    : IEX - Game Pause
# ** Difficulty    : Easy
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# Its a pause script. 
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FEATURES
#------------------------------------------------------------------------------#
# V1.0 - Tags - Areas - Place in area's name
#------------------------------------------------------------------------------#
# <SWITCH_BLOCK> 
# <SWITCH_BLOCK: x>
# All are case insensitive.
# The first tag will cause the area to always be impassable.
# The second tag will cause the are to only be impassable when switch x is
# set to false.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
#
# AudioEngineXT ** Special Case
# FModEx Library
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#------------------------------------------------------------------------------#
# 
# Below 
#  Materials
#
# Above 
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES 
#------------------------------------------------------------------------------# 
# ** Only used for AudioEngineXT
# Classes
#   Scene_Map
#     alias      :start
#     alias      :terminate
#     alias      :update
#     new-method :create_pause_sprite
#   **new-method :pause_bgm
#   **new-method :resume_bgm
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
#
# (DD/MM/YYYY)
#  01/06/2010 - V1.0  Started and Finished Script
#  01/06/2011 - V1.0a Added Compatibility for AudioEngineXT
#  01/08/2011 - V1.0b Added Compatibility for FModEx Library
#  01/08/2011 - V1.0c Small Changes
#  07/24/2011 - V1.1  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment. 
#
#------------------------------------------------------------------------------#
$imported ||= {} 
$imported["IEX_GamePause"] = true
#==============================================================================#
#                           Start Customization
#------------------------------------------------------------------------------#
#==============================================================================#
$pause_button = Input::C # Accept Button (Z, Space, Enter)
$pause_image  = nil # Change this later, to use an image, the image must
                    # be in the Picture Folder  
$pause_mode   = 1   # 0 - Spriteset will also update, 1 - No Spriteset Update

$pause_text   = "Paused!" 
$dimming_opac = 128

# Used for AudioEngine XT, set this to false if your not using it.
# NOTE tell the players not to play with the Pause Button (Repeated Pressing)
# >.< The engine may Crash.
$AE_XT_support = false
# Installation!
# Audio_Engine_XT
# IEX - GamePause
# Audio_Engine_XT_Save/Load
$FmodEx_support = false

#==============================================================================#
#                           End Customization
#------------------------------------------------------------------------------#
#==============================================================================#
# Do not edit beyond this point
$forced_pause = false

#==============================================================================#
# ** Scene_Map
#==============================================================================#
class Scene_Map < Scene_Base

  #--------------------------------------------------------------------------#
  # * alias-method :start
  #--------------------------------------------------------------------------#  
  alias :iex_pause_start :start unless $@
  def start( *args, &block )
    iex_pause_start( *args, &block )
    create_pause_sprite()
  end
  
  #--------------------------------------------------------------------------#
  # * alias-method :terminate
  #--------------------------------------------------------------------------# 
  alias :iex_pause_terminate :terminate unless $@
  def terminate()
    iex_pause_terminate()
    @pause_sprite.dispose() unless @pause_sprite.nil?()
    @dimming_sprite.dispose() unless @dimming_sprite.nil?()
    @pause_sprite = nil
    @dimming_sprite = nil
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :create_pause_sprite
  #--------------------------------------------------------------------------#  
  def create_pause_sprite()
    @pause_sprite   = Sprite.new()
    @dimming_sprite = Sprite.new()
    @dimming_sprite.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    rect = Rect.new(0, 0, Graphics.width, Graphics.height)
    color = Color.new(0, 0, 0, 255)
    @dimming_sprite.bitmap.fill_rect(rect, color)
    @dimming_sprite.opacity = 0
    if $pause_image == nil
      @pause_sprite.bitmap = Bitmap.new(320, 56)
      @pause_sprite.bitmap.font.size = 48
      @pause_sprite.bitmap.draw_text(0, 0, 320, 56, $pause_text, 1)
    else
      @pause_sprite.bitmap = Cache.picture($pause_image)
    end  
    @dimming_sprite.x = 0
    @dimming_sprite.y = 0
    @dimming_sprite.z = 9998
    @dimming_sprite.visible = false
    
    
    @pause_sprite.x = (Graphics.width - @pause_sprite.src_rect.width) / 2
    @pause_sprite.y = (Graphics.height - @pause_sprite.src_rect.height) / 2
    @pause_sprite.z = 9999
    @pause_sprite.visible = false
  end
  
  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#   
  alias :iex_pause_update :update unless $@
  def update()
    create_pause_sprite if @pause_sprite.nil?()
    $forced_pause = !$forced_pause if Input.trigger?($pause_button) 
    if $forced_pause
      @dimming_sprite.visible = true
      @pause_sprite.visible = true
      RPG::BGS.stop
      pause_bgm if $AE_XT_support
      $game_system.pause_bgm if $FmodEx_support
      loop do
        @dimming_sprite.opacity = [@dimming_sprite.opacity + 5, $dimming_opac].min
        case $pause_mode
        when 0 
          Graphics.update                   # Update game screen
          Input.update                      # Update input information
          #$game_map.update                  # Update map
          @spriteset.update                 # Update sprite set
        when 1
          Graphics.update                   # Update game screen
          Input.update                      # Update input information
        end  
        $forced_pause = !$forced_pause if Input.trigger?($pause_button) 
        break unless $forced_pause
      end
      RPG::BGS.last.play
      $game_system.resume_bgm if $FmodEx_support
      resume_bgm(500) if $AE_XT_support
    else
      @dimming_sprite.opacity = 0
      @dimming_sprite.visible = false
      @pause_sprite.visible = false
      iex_pause_update()
    end  
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :pause_bgm
  #--------------------------------------------------------------------------#   
  def pause_bgm()
    #pause
    get_in_pause = $audioxt_bgm_id + ",pause"
    open("\\\\.\\pipe\\audio_engine_xt",'w') { |pipe| pipe.write(get_in_pause); } rescue nil
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :resume_bgm
  #--------------------------------------------------------------------------#   
  def resume_bgm()
    #get the id of song previously playing
    restore_song = $audioxt_bgm_id + ",play," + $audioxt_bgm_volume
    #send string to server. when here it is:  id,play,volume
    open("\\\\.\\pipe\\audio_engine_xt",'w') { |pipe| pipe.write(restore_song); } rescue $recover_safe_audioxt = 1    
    recover if $recover_safe_audioxt == 1    
  end
  
end

#==============================================================================#
# ** END OF FILE
#==============================================================================#