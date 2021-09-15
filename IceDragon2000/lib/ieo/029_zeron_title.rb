#encoding:UTF-8
#==============================================================================#
# ** IEO(Icy Engine Omega) - Zeron Title
#-*--------------------------------------------------------------------------*-#
# ** Author        : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Change (Title)
# ** Script Type   : Title Arrangement
# ** Date Created  : 06/02/2011
# ** Date Modified : 06/02/2011
# ** Script Tag    : IEO-029(Zeron Title)
# ** Difficulty    : Easy, Lunatic
# ** Version       : 1.0
# ** IEO ID        : 029
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# ** CREDITS/USED STUFF/EDITING
#-*--------------------------------------------------------------------------*-#
# You may:
# Edit and Adapt this script as long you credit aforementioned author(s).
#
# You may not:
# Claim this as your own work, or redistribute without the consent of the author.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#-*--------------------------------------------------------------------------*-#
#
# A rewrite of the title screen, so you can easily add new commands to it :3
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTRUCTIONS
#-*--------------------------------------------------------------------------*-#
#
# Plug 'n' Play
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#-*--------------------------------------------------------------------------*-#
#
# Doesn't do much damage, so should work fine with everything else.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#-*--------------------------------------------------------------------------*-#
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
#
#-*--------------------------------------------------------------------------*-#
# Below
#   Materials
#
# Above
#   Main
#   Everything else
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES
#-*--------------------------------------------------------------------------*-#
# Classes
#   Scene_Title
#     new-Cmethod  :hide_command?
#     new-Cmethod  :command_index
#     new-method   :menu_command
#     overwrite    :update
#     overwrite    :create_command_window
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#-*--------------------------------------------------------------------------*-#
# (DD/MM/YYYY)
#  06/02/2011 - V1.0  Started Script and Finished Script
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#
#  Breaks the Title Screen update method a bit.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
($imported ||= {})["IEO-ZeronTitle"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
($ieo_script = {})[[29, "ZeronTitle"]] = 1.0
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
#==============================================================================#
# IEO::TITLE_SCREEN
#==============================================================================#
module IEO
  module TITLE_SCREEN
#==============================================================================#
#                      Start Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  #--------------------------------------------------------------------------#
  # * TITLE_LAYOUT
  #--------------------------------------------------------------------------#
  # This controls the order in which commands appear in the menu
  # Default commands
  # :newgame, :continue, :shutdown
  #--------------------------------------------------------------------------#
    TITLE_LAYOUT = [
      :newgame,
      :continue,
      :shutdown,
      :iconview
    ]
#==============================================================================#
#                        End Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  end
end

#==============================================================================#
# Scene_Title - IEO029-Lunatic
#==============================================================================#
class Scene_Title < Scene_Base

  attr_accessor :continue_enabled

  #--------------------------------------------------------------------------#
  # * new method :title_command
  #--------------------------------------------------------------------------#
  def title_command(command)
    titlelay = IEO::TITLE_SCREEN::TITLE_LAYOUT
    case command
    when :newgame
      command_new_game()
    when :continue
      command_continue()
    when :shutdown
      command_shutdown()
    when :iconview
      command_iconview()
    end
  end

  #--------------------------------------------------------------------------#
  # * new class method :hide_command?
  #--------------------------------------------------------------------------#
  def self.hide_command?(com)
    case com
    when :newgame  ; return false
    when :continue ; return $scene.continue_enabled
    when :shutdown ; return false
    when :iconview ; return !$TEST
    end
    return false
  end

  #--------------------------------------------------------------------------#
  # * new class method :command_index
  #--------------------------------------------------------------------------#
  def self.command_index(com)
    return IEO::TITLE_SCREEN::TITLE_LAYOUT.index(com)
  end

end

#==============================================================================#
# IEO::Vocab
#==============================================================================#
module IEO
  module Vocab

    module_function

    def title(command)
      case command
      when :newgame  ; return ::Vocab.new_game
      when :continue ; return ::Vocab.continue
      when :shutdown ; return ::Vocab.shutdown
      #when :iconview ; return ::YEM::ICONVIEW::COMMAND_NAME
      else           ; return ""
      end
    end

  end
end

#==============================================================================#
# IEO::Icon
#==============================================================================#
module IEO
  module Icon
    module_function
    def title(command) ; return 0 end
  end
end

#==============================================================================#
# Window_TitleCommand
#==============================================================================#
class Window_TitleCommand < Window_Command

  #--------------------------------------------------------------------------#
  # * new method :get_current_command
  #--------------------------------------------------------------------------#
  def get_current_command ; return @commands[self.index] end

  #--------------------------------------------------------------------------#
  # * overwrite method :refresh
  #--------------------------------------------------------------------------#
  def refresh
    self.contents.clear
    for i in 0...@item_max
      draw_item(i, !Scene_Title.hide_command?(@commands[i]))
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :item_rect
  #--------------------------------------------------------------------------#
  def item_rect(index, adapt=true)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = (contents.width + @spacing) / @column_max - @spacing
    rect.height = WLH
    rect.x = index % @column_max * (rect.width + @spacing)
    rect.y = index / @column_max * WLH
    if $imported["IEO-BugFixesUpgrades"]
      if IEO::UPGRADE::ADAPTIVE_CURSOR
        if adapt
          tx = IEO::Vocab.title(@commands[index])
          rect.width = self.contents.text_size(tx).width+12
          icon = IEO::Icon.title(@commands[index])
          rect.width += 24 if icon > 0
        end
      end
    end
    return rect
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :draw_item
  #--------------------------------------------------------------------------#
  def draw_item(index, enabled = true)
    self.contents.font.size = Font.default_size
    rect = item_rect(index, false)
    rect.x += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    icon = IEO::Icon.title(@commands[index])
    if icon > 0
      draw_icon(icon, rect.x, rect.y)
      rect.x += 24 ; rect.width -= 24
    end
    self.contents.draw_text(rect, IEO::Vocab.title( @commands[index] ))
  end

end

#==============================================================================#
# Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base

  #--------------------------------------------------------------------------#
  # * overwrite method :create_command_window
  #--------------------------------------------------------------------------#
  def create_command_window()
    commands = IEO::TITLE_SCREEN::TITLE_LAYOUT
    @command_window = Window_TitleCommand.new(172, commands)
    @command_window.x = (544 - @command_window.width) / 2
    @command_window.y = 288
    if @continue_enabled                    # If continue is enabled
      @command_window.index = 1             # Move cursor over command
    end
    @command_window.openness = 0
    @command_window.open
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :update
  #--------------------------------------------------------------------------#
  def update()
    super()
    @command_window.update()
    if Input.trigger?(Input::C)
      com = @command_window.get_current_command()
      title_command(com)
    end
  end

end

IEO::REGISTER.log_script(29, "ZeronTitle", 1.0) if $imported["IEO-Register"]
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
