#==============================================================================
#    Website Launch from Title [VXA]
#    Version: 1.0
#    Author: modern algebra (rmrk.net)
#    Date: December 11, 2011
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This simple script adds the option to launch website from a command on
#   the title screen. Only works in Windows, but RMVXA only runs in Windows 
#   anyway, so that shouldn't be a problem. With this script, you can add 
#   multiple commands that open different websites.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    Paste this script into its own slot above Main and below Materials.
#
#    Just go down to the configurable constants area at line 27 and read the
#   instructions there to see how to set up a new website launch command.
#==============================================================================

$imported = {} unless $imported
$imported[:MAWebsiteLaunchTitle] = true

MAWLT_TITLE_WEBSITE_COMMANDS = [
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#  EDITABLE REGION
#``````````````````````````````````````````````````````````````````````````````
#    For each website launching command you want to include, simply add an 
#   array at line 45 with the following data, in the following order:
#
#      ["Command Name", index, "url address"]
#
#    "Command Name" is what will show up in the command window itself.
#    index is an integer and it determines in what order the command appears
#    "url address" is the URL opened when the command is pressed.
#
#    If you wish to add more than one website command, you may, but remember to
#   add a comma after all but the last array. It would look like this:
#
#      ["Command Name 1", index, "url address 1"],
#      ["Command Name 2", index, "url address 2"],
#      ["Command Name 3", index, "url address 3"]
#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  ["RMRK", 2, "http://rmrk.net"]
#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#  END EDITABLE REGION
#//////////////////////////////////////////////////////////////////////////////
]

#==============================================================================
# ** Window_TitleCommand
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - make_command_list; update_placement
#==============================================================================

class Window_TitleCommand
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Make Command List
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_wlft_mkcommands_7yh8 make_command_list
  def make_command_list(*args, &block)
    ma_wlft_mkcommands_7yh8(*args, &block) # Run Original Method
    MAWLT_TITLE_WEBSITE_COMMANDS.each_index { |i|
      website = MAWLT_TITLE_WEBSITE_COMMANDS[i]
      add_command(website[0], "website_launch_#{i}".to_sym)
      @list.insert(website[1], @list.pop)
    }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Placement
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_wlft_updplace_5fh2 update_placement
  def update_placement(*args, &block)
    ma_wlft_updplace_5fh2(*args, &block) # Run Original Method
    # Make sure title window doesn't go off screen
    self.y = Graphics.height - height if self.y + height > Graphics.height
  end
end

#==============================================================================
# ** Scene_Title
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - create_command_window
#==============================================================================

class Scene_Title
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Command Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_wlft_crtcmmndwin_3kj9 create_command_window
  def create_command_window(*args, &block)
    ma_wlft_crtcmmndwin_3kj9(*args, &block) # Run Original Method
    MAWLT_TITLE_WEBSITE_COMMANDS.each_index { |i|
      website = MAWLT_TITLE_WEBSITE_COMMANDS[i]
      @command_window.set_handler("website_launch_#{i}".to_sym, 
        lambda { 
          Thread.new { system("start #{website[2]}") }
          @command_window.activate 
        })
    }
  end
end