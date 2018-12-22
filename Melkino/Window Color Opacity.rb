#===========================================================================
# Window Color Opacity - v1.1
# Author: Melkino
#===========================================================================

$imported = {} if $imported.nil?
$imported["MK-WindowOpacity"] = true

#-------------------------------------------------------------------------
# ▼ About
#-------------------------------------------------------------------------
# This script lets you change the opacity of the colored portion of game
# windows. Window borders are unaffected, though.
#-------------------------------------------------------------------------
# ▼ Updates
#-------------------------------------------------------------------------
# Apr 12, 2014 - v.1.1 - Added compatibility for Yanfly's System Options
# May 9, 2012 - v.1.0 - Started & finished script
#-------------------------------------------------------------------------
# ▼ Installation & Usage
#-------------------------------------------------------------------------
# Paste below Materials and above Main.
# The config area has two settings, but only one will take effect
# depending on whether or not you have Yanfly's System Options script
# installed.
#-------------------------------------------------------------------------
class Window_Base < Window
  
module MK_WIN_OPA
#-------------------------------------------------------------------------
# Configuration Settings
#-------------------------------------------------------------------------

  #If you are using Yanfly's System Options, set the option below:
  
  OPACITY_OPTION_VAR_ID = 2  # Variable ID that will track opacity.
                              # Use this ID when creating your own custom 
                              # bar in the "Custom Variables" section of 
                              # Yanfly's script.
    
  # The windows' opacity will be equal to the number stored in the variable.
  # Use an event or script call at the start of your game to set the
  #   opacity, or else the window backgrounds will be transparent.
  # Make sure to set the Min and Max values of your bar to 0 and 255 
  #   respectively to avoid potential display/crashing errors.
  
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  
  # If you are NOT using the script mentioned above, set the opacity here:
   OPACITY = 255        # Any number between 0 and 255
  
# ----------------------------------------
#  End Configuration Settings
# ----------------------------------------  
end #module

  alias mel_windowpacity_initialize initialize
  def initialize(x, y, width, height)
    super
    self.windowskin = Cache.system("Window")
    
    if $imported["YEA-SystemOptions"]
      self.back_opacity = $game_variables[MK_WIN_OPA::OPACITY_OPTION_VAR_ID]
    else
      self.back_opacity = MK_WIN_OPA::OPACITY
    end
    
    update_padding
    update_tone
    create_contents
   @opening = @closing = false
  end
end

#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================