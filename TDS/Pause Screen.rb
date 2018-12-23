#==============================================================================
# ** TDS Pause Screen
#    Ver: 1.1
#------------------------------------------------------------------------------
#  * Description:
#  This script lets you pause the game by pressing a key.
#------------------------------------------------------------------------------
#  * Features: 
#  Pause the game.
#------------------------------------------------------------------------------
#  * Instructions:
#  To change the look, text, settings of the script go to the editable settings
#  area below and change it to your liking.
#
#  To call the pause menu press the pause key you set in the settings.
#
#  To disable the pause screen use this in a call script from an event:
#
#    disable_pause_screen
#
#  To enable the pause screen use this in a call script from an event:
#
#    enable_pause_screen
#------------------------------------------------------------------------------
# List of Keys: 
#  Any of the keys below can be used as a paused key.
#  
#  :DOWN :LEFT :RIGHT :UP
#
#  :A :B :C :X :Y :Z :L :R
#
#  :SHIFT :CTRL :ALT 
#  
#  :F5 :F6 :F7 :F8 :F9 
#------------------------------------------------------------------------------
#  * Notes:
#  None.
#------------------------------------------------------------------------------
# WARNING:
#
# Do not release, distribute or change my work without my expressed written 
# consent, doing so violates the terms of use of this work.
#
# If you really want to share my work please just post a link to the original
# site.
#
# * Not Knowing English or understanding these terms will not excuse you in any
#   way from the consequenses.
#==============================================================================
# * Import to Global Hash *
#==============================================================================
($imported ||= {})[:TDS_Pause_Screen] = true

#==============================================================================
# ** TDS
#------------------------------------------------------------------------------
#  A module containing TDS data structures, mostly script settings.
#==============================================================================

module TDS
  #============================================================================
  # ** Pause_Screen_Settings
  #----------------------------------------------------------------------------
  #  This Module contains Pause Screen Settings & Methods.
  #============================================================================  
  module Pause_Screen_Settings
    #--------------------------------------------------------------------------
    # * Constants (Settings)
    #--------------------------------------------------------------------------        
    # Pause Key
    Pause_Key = :ALT
    # Scenes in which the game cannot be paused.
    Pause_Scene_Disabled = [Scene_Title]    
    # If True you can pause the game even if an event is running.
    Ignore_Interpreter = true
    
    # Pause Text
    Pause_Text = "Pause"
    # Pause Text Font Size
    Pause_Text_Font_Size = 50
    # Pause Text Font Name
    Pause_Text_Font_Name = Font.default_name
    # Pause Text Font Color
    Pause_Text_Font_Color = Font.default_color 
    # Pause Text Font Bold Flag
    Pause_Text_Font_Bold = false
    # Pause Text Font Italic Flag
    Pause_Text_Font_Italic =  false
    
    # Blur Pause Image
    Blur_Pause_Image = true
    # Pause Image Tone
    Pause_Image_Tone = Tone.new(-30, -30, -30)
    #--------------------------------------------------------------------------
    # * Determine if Game can be Paused
    #--------------------------------------------------------------------------
    def self.can_pause_game?
      # Return false if Scene cannot be paused 
      return false if Pause_Scene_Disabled.include?(SceneManager.scene.class)
      # Return false if Game Pause is disabled
      return false if $game_system.game_pause_disabled?      
      # Return false if Interpreter is running and not ignoring it
      return false if Ignore_Interpreter == false and $game_map.interpreter.running?
      # Return true
      return true      
    end
    #--------------------------------------------------------------------------
    # * Apply Pause Settings on Sprite
    #--------------------------------------------------------------------------
    def self.apply_pause_sprite_settings(sprite)
      # Blur Sprite Bitmap
      sprite.bitmap.blur if Blur_Pause_Image
      # Set Sprite Bitmap Tone
      sprite.tone.set(Pause_Image_Tone)
      # Set Sprite Bitmap Font Size
      sprite.bitmap.font.size = Pause_Text_Font_Size
      # Set Sprite Bitmap Font Name
      sprite.bitmap.font.name = Pause_Text_Font_Name
      # Set Sprite Bitmap Font Color
      sprite.bitmap.font.color = Pause_Text_Font_Color 
      # Set Sprite Bitmap Font Bold Flag
      sprite.bitmap.font.bold = Pause_Text_Font_Bold
      # Set Sprite Bitmap Font Italic Flag
      sprite.bitmap.font.italic = Pause_Text_Font_Italic     
      # Draw Pause Text
      sprite.bitmap.draw_text(sprite.bitmap.rect, Pause_Text, 1)
    end    
  end
end


#==============================================================================
# ** Game_Temp
#------------------------------------------------------------------------------
#  This class handles temporary data that is not included with save data.
# The instance of this class is referenced by $game_temp.
#==============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :game_paused                           # Game Paused Flag
  attr_accessor :pause_frame_count                     # On Pause Frame Count
  #--------------------------------------------------------------------------
  # * Alias Listing
  #--------------------------------------------------------------------------  
  alias tds_pause_screen_game_temp_initialize                      initialize
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(*args, &block)
    # Run Original Method
    tds_pause_screen_game_temp_initialize(*args, &block) 
    # Set Game Paused Flag & Pause Frame Count
    @game_paused = false ; @pause_frame_count = 0
  end
  #--------------------------------------------------------------------------
  # * Determine if Game has been paused
  #--------------------------------------------------------------------------
  def game_paused? ; @game_paused end
  #--------------------------------------------------------------------------
  # * On Game Pause Start Processing
  #--------------------------------------------------------------------------
  def on_game_pause_start
    # Set Game Paused Flag & Pause Frame Count
    @game_paused = true ; @pause_frame_count = Graphics.frame_count
  end
  #--------------------------------------------------------------------------
  # * On Game Pause Ending Processing
  #--------------------------------------------------------------------------
  def on_game_pause_end
    # Set Game Paused Flag & Graphics Frame Count
    @game_paused = false ; Graphics.frame_count = @pause_frame_count
  end
end


#==============================================================================
# ** Game_System
#------------------------------------------------------------------------------
#  This class handles system data. It saves the disable state of saving and 
# menus. Instances of this class are referenced by $game_system.
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :game_pause_disabled               # Game Pause Disabled Flag
  #--------------------------------------------------------------------------
  # * Alias Listing
  #--------------------------------------------------------------------------  
  alias tds_pause_screen_game_system_initialize                      initialize  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(*args, &block)
    # Run Original Method
    tds_pause_screen_game_system_initialize(*args, &block)
    # Set Game Pause Disabled Flag
    @game_pause_disabled = false
  end
  #--------------------------------------------------------------------------
  # * Determine if Game Pause is disabled
  #--------------------------------------------------------------------------
  def game_pause_disabled? ; @game_pause_disabled end
  #--------------------------------------------------------------------------
  # * Disable Game Pause
  #--------------------------------------------------------------------------
  def disable_game_pause ; @game_pause_disabled = true end
  #--------------------------------------------------------------------------
  # * Enable Game Pause
  #--------------------------------------------------------------------------    
  def enable_game_pause  ; @game_pause_disabled = false end
end


#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Disable Pause Screen
  #--------------------------------------------------------------------------
  def disable_pause_screen ; $game_system.disable_game_pause end
  #--------------------------------------------------------------------------
  # * Enable Pause Screen
  #--------------------------------------------------------------------------
  def enable_pause_screen ; $game_system.enable_game_pause end    
end


#==============================================================================
# ** Graphics
#------------------------------------------------------------------------------
#  The module that carries out graphics processing.
#==============================================================================

class << Graphics
  #--------------------------------------------------------------------------
  # * Alias Listing
  #--------------------------------------------------------------------------  
  alias tds_pause_screen_graphics_update                               update
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update(*args, &block)
    # Update Game Pause Input
    update_game_pause_input    
    # Run Original Method
    tds_pause_screen_graphics_update(*args, &block)    
  end  
  #--------------------------------------------------------------------------
  # * Update Game Pause Input
  #--------------------------------------------------------------------------
  def update_game_pause_input    
    # If Input Trigger (Pause Key)
    if Input.trigger?(TDS::Pause_Screen_Settings::Pause_Key)
      # Return if Game cannot be paused
      return if !TDS::Pause_Screen_Settings.can_pause_game?
      # Play OK Sound & Start Game Pause
      Sound.play_ok ; start_game_pause
    end
  end  
  #--------------------------------------------------------------------------
  # * Start Game Pause
  #--------------------------------------------------------------------------
  def start_game_pause
    # Process on Game Pause Start
    $game_temp.on_game_pause_start
    # Make Pause Cover Sprite
    @pause_cover = Sprite.new
    @pause_cover.bitmap = snap_to_bitmap
    @pause_cover.opacity = 0
    @pause_cover.z = 5000
    # Apply Pause Settings to Pause Cover Sprite
    TDS::Pause_Screen_Settings.apply_pause_sprite_settings(@pause_cover)    
    # Fade In Pause Cover
    15.times { tds_pause_screen_graphics_update ; @pause_cover.opacity += 17}
    # Update Loop While Game is Paused
    while $game_temp.game_paused? do 
      # Update Graphics & Input
      tds_pause_screen_graphics_update ; Input.update
      # Go Through Inputs
      [TDS::Pause_Screen_Settings::Pause_Key, :B].each {|key|
        # If Input Trigger
        if Input.trigger?(key)
          # Play Sound
          key == TDS::Pause_Screen_Settings::Pause_Key ? Sound.play_ok : Sound.play_cancel
          # Process Game Temp On Game Pause End
          $game_temp.on_game_pause_end
        end
      }      
    end    
    # Fade Out Pause Cover
    10.times { tds_pause_screen_graphics_update ; @pause_cover.opacity -= 26}    
    # Dispose of Pause Cover Sprite
    @pause_cover.bitmap.dispose ; @pause_cover.dispose ; @pause_cover = nil
  end    
end