#===============================================================================
# One Game Instance
# Version 1.0
# Author game_guy
#-------------------------------------------------------------------------------
# Intro:
# Prevents players from opening multiple instances of your games.
#
# Features:
# Prevents Multiple Instances
# Custom File/Error
# XP/VX Compatible
#
# Instructions:
# Place as first script.
# Configure the 2 variables and thats all!
#
# Compatibility:
# Works with everything.
#
# Credits:
# game_guy ~ For creating it.
# ZenVirZan ~ For requesting it.
#===============================================================================

# Custom error message.
ERROR = "Instance already running."
# Custom file name, I'd recommend leaving the ENV[Appdata]
TOKEN_FILE = ENV['APPDATA'] + "game_name.token"

begin
  if FileTest.exists?(TOKEN_FILE)
    begin
      File.delete(TOKEN_FILE)
    rescue Errno::EACCES
      if !DEBUG && !$TEST
        msgbox ERROR
        exit
      end
    end
  end
  $token = File.open(TOKEN_FILE, "w")
end