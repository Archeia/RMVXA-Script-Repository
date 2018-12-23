#==============================================================================
#    Location Window
#      Addon to Customizable Main Menu 1.0b
#    Version: 1.0a
#    Author: modern algebra (rmrk.net)
#    Date: January 20, 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This is an Addon for the Customizable Main Menu (found at: 
#   http://rmrk.net/index.php/topic,44906.0.html). With this script, you can 
#   add a long window to properly display location in the main menu, as the
#   auto window function in the script doesn't create a wide enough window to
#   show long location names.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    Paste this script into its own slot in the Script Editor, above Main but
#   below the Customizable Main Menu script. 
#
#    Other than that, all you need to do is set the display text at line xx. 
#   That is the label drawn on the left hand side of the window to indicate 
#   what the window shows. Additionally, you will need to make sure that you 
#   have not created any custom windows in the Customizable Main Menu that have
#   :location as their identifer, or else this script will be overridden.
#
#    You can add or remove the location window in-game by using the following 
#   codes in a script call:
#
#      add_menu_window(:location)
#      remove_menu_window(:location)
#==============================================================================

if $imported && $imported[:MA_CustomizableMenu]
$imported[:MACMM_LocationWindow] = true

#==============================================================================
# *** MA Customizable Menu
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new constants - LOCATION_LABEL; LOCATION_FULL_WIDTH
#==============================================================================

module MA_CustomizableMenu
  #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  #  Editable Region
  #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #  The label to be shown at the left hand side of the window. Message codes 
  # are recognized
  LOCATION_LABEL = "\\i[231]"
  #  The value of this constant determines whether the location window should 
  # take up the entire width of the screen, or be the same width as the status 
  # window. false = Full; true = Status
  LOCATION_FULL_WIDTH = false
  #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #  End Editable Region
  #//////////////////////////////////////////////////////////////////////////
  OPTIONAL_WINDOWS_LIST.push(:location) unless OPTIONAL_WINDOWS_LIST.include?(:location)
end

#==============================================================================
# ** MACMM_LocationWindow
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This window shows the location data.
#==============================================================================

class MACMM_LocationWindow < Window_MACMM_AutoCustom
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize(*args)
    super([MA_CustomizableMenu::LOCATION_LABEL, "$game_map.display_name"])
    self.x = (MA_CustomizableMenu::COMMAND_WINDOW_ON_RIGHT ||
      MA_CustomizableMenu::LOCATION_FULL_WIDTH) ? 0 : $game_system.macmm_command_width
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Window Width
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def window_width
      MA_CustomizableMenu::LOCATION_FULL_WIDTH ? Graphics.width : 
      Graphics.width - $game_system.macmm_command_width
  end
end

#==============================================================================
# ** Scene Menu
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - manual_window; create_optional_windows
#==============================================================================

class Scene_Menu
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Optional Windows
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias macmm_locwin_crtoptwins_8ul5 create_optional_windows
  def create_optional_windows(*args, &block)
    if $game_system.macmm_optional_windows.include?(:location)
      # Make sure Location first window to be created
      $game_system.macmm_optional_windows.delete(:location)
      $game_system.macmm_optional_windows.push(:location)
    end
    macmm_locwin_crtoptwins_8ul5(*args, &block) # Call Original Method
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Manually Set Custom Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias macmm_locwin_mancustwin_2rw6 manual_custom_window
  def manual_custom_window(symbol, *args, &block)
    if symbol == :location
      @macmm_location_window = MACMM_LocationWindow.new
      set_custom_window_y(@macmm_location_window) if @macmm_location_window.width == Graphics.width
      @macmm_location_window.y = Graphics.height - @macmm_location_window.height
      # Change height of the Status Window
      if @status_window
        @status_window.height -= @macmm_location_window.height
        @status_window.create_contents
        @status_window.refresh
      end
    else
      macmm_locwin_mancustwin_2rw6(symbol, *args, &block) # Call Original Method
    end
  end
end

else
  p "Location Window requires the Customizable Main Menu, and the Location 
    Window must be below it in the Script Editor. You can find the script at:
      http://rmrk.net/index.php/topic,44906.0.html"
end