#==============================================================================
# ** TDS Title Image Stretch
#    Ver: 1.1
#------------------------------------------------------------------------------
#  * Description:
#  This script automatically resizes the background images in the title screen
#  to fit the resolution of the game.
#------------------------------------------------------------------------------
#  * Features: 
#  Resizes the title screen images to fit the resolution of the screen.
#------------------------------------------------------------------------------
#  * Instructions:
#  Just put it in your game and enjoy.
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
($imported ||= {})[:TDS_Title_Image_Stretch] = true

#==============================================================================
# ** Scene_Title
#------------------------------------------------------------------------------
#  This class performs the title screen processing.
#==============================================================================

class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------
  # * Create Background
  #--------------------------------------------------------------------------
  def create_background
    # Get Screen Size Rect
    screen = Rect.new(0, 0, Graphics.width, Graphics.height)    
    # Create Sprite 1 (Layer 1)
    @sprite1 = Sprite.new
    @sprite1.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    # Get Bitmap
    bitmap = Cache.title1($data_system.title1_name)
    # Stretch Background
    @sprite1.bitmap.stretch_blt(screen, bitmap, bitmap.rect)
    # Create Sprite 2 (Layer 2)
    @sprite2 = Sprite.new
    @sprite2.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    # Get Bitmap
    bitmap = Cache.title2($data_system.title2_name)    
    # Stretch Background
    @sprite2.bitmap.stretch_blt(screen, bitmap, bitmap.rect)    
  end
end