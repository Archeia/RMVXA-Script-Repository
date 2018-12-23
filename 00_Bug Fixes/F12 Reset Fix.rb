#==============================================================================
#   ** F12 Reset Fix
#   Author: Acezon
#   Date: 2 June 2013
#------------------------------------------------------------------------------
#   Version 2.1
#   - Fixed issue where game window is not in focus
#     when Console_on is set to false
#   - Now compatible with Tsuki's Test Edit script
#   Version 2.0
#   - Console option added
#   - Automatically focuses window after pressing F12
#   Version 1.1
#   - Respawning the exe was better
#   Version 1.0
#   - Initial Release
#------------------------------------------------------------------------------
#   Just credit me. Free to use for commercial/non-commercial games.
#   Thanks to Tsukihime and Cidiomar for the console scriptlet
#==============================================================================

$imported = {} if $imported.nil?
$imported["Acezon-F12ResetFix"] = true

#==============================================================================
# ** START Configuration
#==============================================================================
module Config
  Console_on = false       # duh
end
#==============================================================================
# ** END Configuration
#==============================================================================

alias f12_reset_fix rgss_main
def rgss_main(*args, &block)
  f12_reset_fix(*args) do
    if $run_once_f12
      pid = spawn ($TEST ? 'Game.exe test' : 'Game')
      # Tell OS to ignore exit status
      Process.detach(pid)
      sleep(0.01)
      exit
    end
    $run_once_f12 = true
    # Run default rgss_main
    block.call
  end
end

module SceneManager
  class << self
    alias :acezon_f12_first :first_scene_class
  end

  def self.first_scene_class
    focus_game_window
    acezon_f12_first
  end

  def self.focus_game_window
    # Just to prevent re-spawning the console since
    # Tsuki uses this same part in his Test Edit script
    if !$imported["TH_TestEdit"]
      # Get game window text
      console_w = Win32API.new('user32','GetForegroundWindow', 'V', 'L').call
      buf_len = Win32API.new('user32','GetWindowTextLength', 'L', 'I').call(console_w)
      str = ' ' * (buf_len + 1)
      Win32API.new('user32', 'GetWindowText', 'LPI', 'I').call(console_w , str, str.length)

      if Config::Console_on
        # Initiate console
        Win32API.new('kernel32.dll', 'AllocConsole', '', '').call
        Win32API.new('kernel32.dll', 'SetConsoleTitle', 'P', '').call('RGSS3 Console')
        $stdout.reopen('CONOUT$')
      end

      # Sometimes pressing F12 will put the editor in focus first,
      # so we have to remove the program's name
      game_title = str.strip
      game_title.sub! ' - RPG Maker VX Ace', ''

      # Set game window to be foreground
      hwnd = Win32API.new('user32.dll', 'FindWindow', 'PP','N').call(0, game_title)
      Win32API.new('user32.dll', 'SetForegroundWindow', 'P', '').call(hwnd)
    end
  end
end