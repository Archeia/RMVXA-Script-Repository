#Version/Build Number
#----------#
#Features: Allows you to display what version your game is on and for purely
#       special purposes what build as well (not fancy, just how many times
#       game hs been started in unreleased)
#
#Usage: Plug and play and customize
#
#Customization: Set below, in comments.
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)

#FLAVORTEXT: Just any text before version number, not neccesary
FLAVORTEXT   = "Game Name "
#VERSION: The Version, however you want to display it
VERSION   = "v1.0 "
#VERSION_ONLY: Whether you want to show build number or not
VERSION_ONLY = false
#RELEASE: Set to true to prevent build from rising each time game is started
RELEASE   = false
#VFONT_SIZE, VWINDOW_X, VWINDOW_Y, the font size, x, and y position of window
VFONT_SIZE   = 14
VWINDOW_X = -12
VWINDOW_Y = 384

#NO TOUCHY!
$build_number = 0

module Version
  def self.init
    if File.exist?("System/Version.vmdt") then else Version.run_new end
      File.open("System/Version.vmdt", "rb") do |file|
      $build_number = Marshal.load(file)
        end
      $build_number += 1 if !RELEASE
      File.open("System/Version.vmdt", "wb") do |file|
      Marshal.dump($build_number, file)
    end
  end
  def self.run_new
    file = File.new("System/Version.vmdt", "wb")
    Marshal.dump($build_number, file)
    file.close
  end
end

class Scene_Title
  alias version_initialize start
  def start
    version_initialize
    @version_window = Window_Version.new
  end
end

class Window_Version < Window_Base
  def initialize
    super(VWINDOW_X, VWINDOW_Y, 200, fitting_height(1))
    self.opacity = 0
    refresh
  end
  def refresh
    self.contents.clear
    self.contents.font.size = VFONT_SIZE
    self.contents.draw_text(0,0,200,line_height,version)
  end
  def version
    return FLAVORTEXT + VERSION if VERSION_ONLY
    return FLAVORTEXT + VERSION + "Build: " + $build_number.to_s
  end
end

Version::init