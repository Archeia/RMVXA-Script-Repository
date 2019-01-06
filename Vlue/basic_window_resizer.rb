#Basic Window Resizer v1.1
#----------#
#Features: Allows you to resize the window to whatever size you like! (This is not
#            like Graphics.resize, this will scale to fit)
#
#Usage:   Script calls:
#           Window_Resize.r(width, height)     - Self-explanatory
#           Window_Resize.f                    - fits the game window to monitor size
#           Window_Resize.full                 - switches to full screen unless already fullscreened
#           Window_Resize.window               - same as full but opposite
#           Window_Resize.toggle               - toggles between full and window
#
#No Customization
#
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

SWPO = Win32API.new 'user32', 'SetWindowPos', ['l','i','i','i','i','i','p'], 'i'
WINX = Win32API.new 'user32', 'FindWindowEx', ['l','l','p','p'], 'i'
SMET = Win32API.new 'user32', 'GetSystemMetrics', ['i'], 'i'

module Window_Resize
  def self.r(width, height)
    resw = SMET.call(0)
    resh = SMET.call(1)
    window_loc = WINX.call(0,0,"RGSS Player",0)
    width += (SMET.call(5) + SMET.call(45)) * 2
    height += (SMET.call(6) + SMET.call(45)) * 2 + SMET.call(4)
    x = (resw - width) / 2; y = (resh - height) / 2
    y = 0 if y < 0;x = 0 if x < 0
    SWPO.call(window_loc,0,x,y,width,height,0)
  end
  def self.f
    resw = SMET.call(0)
    resh = SMET.call(1)
    window_loc = WINX.call(0,0,"RGSS Player",0)
    SWPO.call(window_loc,0,0,0,resw,resh,0)
  end
  def self.full
    resw = SMET.call(0)
    return unless resw > 640
    toggle
  end
  def self.window
    resw = SMET.call(0)
    return unless resw <= 640
    toggle
  end
  def self.toggle
    keybd = Win32API.new 'user32.dll', 'keybd_event', ['i', 'i', 'l', 'l'], 'v'
    keybd.call 0xA4, 0, 0, 0
    keybd.call 13, 0, 0, 0
    keybd.call 13, 0, 2, 0
    keybd.call 0xA4, 0, 2, 0
  end
end