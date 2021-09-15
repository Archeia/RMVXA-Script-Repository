#==============================================================================#
# ** IEX(Icy Engine Xelion) - Supa Balloons
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Sprite)
# ** Script-Type   : Emo-Balloon
# ** Date Created  : 08/12/2010 (DD/MM/YYYY)
# ** Date Modified : 01/08/2011 (DD/MM/YYYY)
# ** Script Tag    : IEX - Supa Balloons
# ** Difficulty    : Easy
# ** Version       : 1.0a
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# For those who love the fancy emotion balloons. You would have noticed that 
#  it was a bit quiet, too quiet!
#  So I made this little script to change that.
#  You can now assign specific sounds to each balloon in your game.
#  In addition you have for control over the wait times, support for custom
#  balloons and last but not least you can have them fade out.
#            (Instead of dissapearing suddenly)
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** HOW TO USE
#------------------------------------------------------------------------------#
# Plug 'n' Play
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
#
# Should have no problems
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#------------------------------------------------------------------------------#
# 
# Below 
#  Materials
#  Anything that makes changes to sprites
#
# Above 
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES 
#------------------------------------------------------------------------------# 
# Classes
#   Sprite_Character
#     overwrite  :start_balloon
#     overwrite  :update_balloon
#     new-method :update_balloon_fade
#     new-method :update_balloon_frames
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
# (DD/MM/YYYY)
#  08/12/2010 - V1.0  Started And Finished Script
#  01/08/2010 - V1.0a Small Change
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment
#
#------------------------------------------------------------------------------#
$imported = {} if $imported == nil
$imported["IEX_Supa_Balloons"] = true # Kind of a waste to import this though..
#------------------------------------------------------------------------------#
# ** Start Customization
#------------------------------------------------------------------------------#
module IEX
  module SUPA_BALLOONS
#==============================================================================
#                           Start Customization
#------------------------------------------------------------------------------
#============================================================================== 
    # Balloon Wait Control
     WAIT_GENERAL = 32 # General wait time for balloons. Default is 12
     WAIT_EQ = (8 * 8) # Wait time equation. WAIT_GENERAL is added to this. Default is (8 * 8) 
    
    # Balloon Fade Control
     FADE_BALLOON = true # Should the balloon fade when near finished..
     BALLOON_FADE_TIME = 15 # At what frame should fading begin. Counting down...
    
    # General Balloon Controls
     OFF_X = 16 # Offset X on object for balloon. Default is 16
     OFF_Y = 32 # Offset Y on object for balloon. Default is 32
    
    # Custom Balloon Controls
     CUSTOM_BALLOONS = ["Balloon", "Balloon1", "Balloon2"]
     # Custom Baloon Variable
     CUSTOM_BALLOONS_VAR = 17
     SOUND_SE = {
  # Custom_Balloon_ID = {}
      0 => { # Default Balloon
  # Balloon_id => ["SE_File_Name", Volume, Pitch],
         0 => ["",         0,    0], # Nil Balloon. Any missing balloons will use this
         1 => ["Def005",   80, 100], # Exclamation 
         2 => ["Def008",   80, 100], # Question
         3 => ["FX-Music", 80, 100], # Music Note
         4 => ["FX-Heart", 80, 100], # Heart
         5 => ["FX-Anger", 80, 100], # Anger
         6 => ["FX-Sweat", 80, 100], # Sweat
         7 => ["FX-Web",   80, 100], # Cobweb
         8 => ["",         0,    0], # Silence       
         9 => ["FX-Bulb",  80, 100], # Light Bulb
        10 => ["Sleep",    80,  60]  # Zzz
        },
        
      # Custom Balloons 
      1 => {}, 
      2 => {}
        } # DON'T TOUCH THIS
#==============================================================================
#                           End Customization
#------------------------------------------------------------------------------
#==============================================================================         
  end # END SUPA_BALLOONS
end # END IEX

#==============================================================================
# ** Sprite_Character
#------------------------------------------------------------------------------
#==============================================================================
class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------
  # * Start Balloon Icon Display
  #--------------------------------------------------------------------------
  def start_balloon
    dispose_balloon
    indx = $game_variables[IEX::SUPA_BALLOONS::CUSTOM_BALLOONS_VAR]
    if IEX::SUPA_BALLOONS::CUSTOM_BALLOONS[indx] != nil
     balloon_custom_image = IEX::SUPA_BALLOONS::CUSTOM_BALLOONS[indx] 
     sound_indx = indx
     else
     balloon_custom_image = IEX::SUPA_BALLOONS::CUSTOM_BALLOONS[0]
     sound_indx = 0
    end
    @balloon_duration = IEX::SUPA_BALLOONS::WAIT_EQ + IEX::SUPA_BALLOONS::WAIT_GENERAL
    @balloon_sprite = ::Sprite.new(viewport)
    @balloon_sprite.bitmap = Cache.system(balloon_custom_image)
    @balloon_sprite.ox = IEX::SUPA_BALLOONS::OFF_X
    @balloon_sprite.oy = IEX::SUPA_BALLOONS::OFF_Y
    if IEX::SUPA_BALLOONS::SOUND_SE[sound_indx][@balloon_id] != nil
      fil = IEX::SUPA_BALLOONS::SOUND_SE[sound_indx][@balloon_id][0]
      vol = IEX::SUPA_BALLOONS::SOUND_SE[sound_indx][@balloon_id][1]
      pit = IEX::SUPA_BALLOONS::SOUND_SE[sound_indx][@balloon_id][2]
    else
      fil = IEX::SUPA_BALLOONS::SOUND_SE[sound_indx][0][0]
      vol = IEX::SUPA_BALLOONS::SOUND_SE[sound_indx][0][1]
      pit = IEX::SUPA_BALLOONS::SOUND_SE[sound_indx][0][2]
    end
    if fil != nil
      sound_se = RPG::SE.new(fil, vol, pit)
      sound_se.play
    end
    update_balloon
  end
  
  #--------------------------------------------------------------------------
  # * Update Balloon Icon
  #--------------------------------------------------------------------------
  def update_balloon
    if @balloon_duration > 0
      @balloon_duration -= 1
      if @balloon_duration == 0 
        dispose_balloon
      elsif @balloon_duration <= IEX::SUPA_BALLOONS::BALLOON_FADE_TIME
        if IEX::SUPA_BALLOONS::FADE_BALLOON
          update_balloon_fade
          else
          update_balloon_frames
        end
      else
        update_balloon_frames
      end
    end
  end
  
  def update_balloon_fade
    if @balloon_sprite.opacity != 0
      fade_amt = 255 / IEX::SUPA_BALLOONS::BALLOON_FADE_TIME
      @balloon_sprite.opacity -= fade_amt
    end
  end
  
  def update_balloon_frames
    @balloon_sprite.x = x
    @balloon_sprite.y = y - height
    @balloon_sprite.z = z + 200
    if @balloon_duration < IEX::SUPA_BALLOONS::WAIT_GENERAL
      sx = 7 * 32
    else
      sx = (7 - (@balloon_duration - IEX::SUPA_BALLOONS::WAIT_GENERAL) / 8) * 32
    end
     sy = (@balloon_id - 1) * 32
     @balloon_sprite.src_rect.set(sx, sy, 32, 32)
  end
    
end # END Sprite_Character
  
################################################################################
#------------------------------------------------------------------------------#
#END\\\END\\\END\\\END\\\END\\\END\\\END///END///END///END///END///END///END///#
#------------------------------------------------------------------------------#
################################################################################