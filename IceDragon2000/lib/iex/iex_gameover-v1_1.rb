#==============================================================================#
# ** IEX(Icy Engine Xelion) - Gameover
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon
# ** Script-Status : ReWrite
# ** Script Type   : Gameover
# ** Date Created  : 11/07/2010
# ** Date Modified : 07/24/2011
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# This script rewrites the default gameover screen, and adds some new features
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FEATURES
#------------------------------------------------------------------------------#
# V1.0
#------------------------------------------------------------------------------#
# Plays a BGM for the Gameover, ME is played before
# Command window with the option to load a save file
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
#  Place this script below any custom save scenes
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
#
# (DD/MM/YYYY)
#  11/05/2010 - V1.0 Finished Script
#  07/24/2011 - V1.1  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment.
#
#------------------------------------------------------------------------------#
$imported ||= {}
$imported["IEX_Gameover"] = true
#==============================================================================#
# ** IEX::GAMEOVER
#==============================================================================#
module IEX
  module GAMEOVER
#==============================================================================#
#                           Start Customization
#------------------------------------------------------------------------------#
#==============================================================================#
    GAMEOVER_BGM = 'Dungeon3'
  #--------------------------------------------------------------------------#
  # * Gameover Icons & Command Window Pos
  #--------------------------------------------------------------------------#
  # The
  # Icons are used for the command window
  #--------------------------------------------------------------------------#
  # COMMAND_WINDOW_POS = [x, y, width, height(not used), opacity]
    COMMAND_WINDOW_POS = [4, 4, Graphics.width - 4, 56, 255]
    COLUMNS = 3 # Number of columns in Command Window

    GAMEOVER_ICONS = {
   #:something    => icon_index,
    :return_title => 210,
    :continue     => 811,
    :shutdown     => 848,
    } # Do Not Remove

    FADE_TIMES = {
    :from_save  => 60,
    :from_gm_ov => 60,
    } # Do Not Remove

#==============================================================================#
#                           End Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  end
end
#==============================================================================#
# ** IEX_Gameover_Window_Command
#------------------------------------------------------------------------------#
#  This window deals with general command choices.
#==============================================================================#
$called_from_gameover = false
class IEX_Gameover_Window_Command < Window_Selectable
 #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :commands                 # command
  attr_accessor :back_sprite
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     width      : window width
  #     commands   : command array [[command, icon, enabled]]
  #     column_max : digit count (if 2 or more, horizontal selection)
  #     row_max    : row count (0: match command count)
  #     spacing    : blank space when items are arrange horizontally
  #--------------------------------------------------------------------------
  def initialize(width, commands, fontsize = 18, column_max = 1, row_max = 0, spacing = 32)
    if row_max == 0
      row_max = (commands.size + column_max - 1) / column_max
    end
    super(0, 0, width, row_max * WLH + 32, spacing)
    @commands = commands
    @item_max = commands.size
    @column_max = column_max
    @fontsize = fontsize
    @back_sprite = Sprite.new
    @back_sprite.x = self.x
    @back_sprite.y = self.y
    refresh
    self.index = 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :set_coords
  #--------------------------------------------------------------------------#
  def set_coords( coords )
    self.x = coords[0]
    self.y = coords[1]
    self.width = coords[2]
    self.height = coords[3]
    self.opacity = coords[4]
    refresh()
  end

  #--------------------------------------------------------------------------#
  # * super-method :dispose
  #--------------------------------------------------------------------------#
  def dispose()
    if @back_sprite != nil
      @back_sprite.dispose
      @back_sprite = nil
    end
    super()
  end

  #--------------------------------------------------------------------------#
  # * super-method :update
  #--------------------------------------------------------------------------#
  def update()
    super()
    if @back_sprite != nil
      @back_sprite.visible = self.visible
      @back_sprite.x = self.x
      @back_sprite.y = self.y
    end
  end

  #--------------------------------------------------------------------------#
  # * super-method :visible
  #--------------------------------------------------------------------------#
  def visible=(vis)
    @back_sprite.visible = vis
    super(vis)
  end

  #--------------------------------------------------------------------------#
  # * new-method :refresh
  #--------------------------------------------------------------------------#
  def refresh
   create_contents()
    for i in 0...@item_max
      icon = @commands[i][1]
      enable = @commands[i][2]
      draw_item(i, icon, enable)
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :draw_item
  #--------------------------------------------------------------------------#
  def draw_item(index, icon_index, enabled = true)
    rect = item_rect(index)
    rect.x += 24
    rect.width -= 8
    draw_icon(icon_index, (rect.x - 24), rect.y, enabled)
    self.contents.clear_rect(rect)
    self.contents.font.size = @fontsize
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(rect, @commands[index][0])
  end

end

#==============================================================================#
# ** Scene_Gameover
#==============================================================================#
class Scene_Gameover < Scene_Base

  #--------------------------------------------------------------------------#
  # * overwrite-method :initialize
  #--------------------------------------------------------------------------#
  def initialize(skip = false)
    @skip = skip
    check_continue
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :perform_transition
  #--------------------------------------------------------------------------#
  def perform_transition()
    Graphics.transition(IEX::GAMEOVER::FADE_TIMES[:from_save])
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :start
  #--------------------------------------------------------------------------#
  def start()
    super()
    @bgm = RPG::BGM.new(IEX::GAMEOVER::GAMEOVER_BGM, 80)
    unless @skip
      RPG::BGM.stop
      RPG::BGS.stop
      $data_system.gameover_me.play
      Graphics.transition(120)
      Graphics.freeze
    end
    @bgm.play
    create_gameover_graphic()
    create_command_window()
    @iex_command_window.active = true
    @iex_command_window.visible = true
    @iex_command_window.open
  end

  #--------------------------------------------------------------------------#
  # * New Method - Check Continue
  #--------------------------------------------------------------------------#
  # Checks to see if continue is possible
  #--------------------------------------------------------------------------#
  def check_continue()
    if $imported["IEX_Scene_File"]
      @continue_enabled = (Dir.glob("#{IEX::Saving_Scene::Save_Data_Name}*.rvdata").size > 0)
    else
      @continue_enabled = (Dir.glob('Save*.rvdata').size > 0)
    end
  end

  #--------------------------------------------------------------------------#
  # * New Method - Create Command Window
  #--------------------------------------------------------------------------#
  # O.< The name say it all
  #--------------------------------------------------------------------------#
  def create_command_window()
    c1 = Vocab::to_title
    c2 = Vocab::continue
    c3 = Vocab::shutdown
    i1 = IEX::GAMEOVER::GAMEOVER_ICONS[:return_title]
    i2 = IEX::GAMEOVER::GAMEOVER_ICONS[:continue]
    i3 = IEX::GAMEOVER::GAMEOVER_ICONS[:shutdown]

    commands = [[c1, i1, true], [c2, i2, @continue_enabled], [c3, i3, true]]
    @iex_command_window = IEX_Gameover_Window_Command.new(IEX::GAMEOVER::COMMAND_WINDOW_POS[2], commands, 18, 3)
    @iex_command_window.active = false
    @iex_command_window.visible = false
    @iex_command_window.openness = 0
    @iex_command_window.x = IEX::GAMEOVER::COMMAND_WINDOW_POS[0]
    @iex_command_window.y = IEX::GAMEOVER::COMMAND_WINDOW_POS[1]
    @iex_command_window.opacity = IEX::GAMEOVER::COMMAND_WINDOW_POS[4]
    if @continue_enabled                           # If continue is enabled
      @iex_command_window.index = 1                # Move cursor over command
    end
  end

  #--------------------------------------------------------------------------#
  # * alias-method :terminate
  #--------------------------------------------------------------------------#
  alias :iex_gameover_sg_terminate :terminate unless $@
  def terminate( *args, &block )
    if @iex_command_window != nil
      @iex_command_window.dispose
      @iex_command_window = nil
    end
    iex_gameover_sg_terminate( *args, &block )
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :update
  #--------------------------------------------------------------------------#
  def update()
    super()
    if Input.trigger?(Input::C) and @iex_command_window.active
      case @iex_command_window.index
      when 0
        command_to_title
      when 1
        command_continue
      when 2
        command_shutdown
      end
    end
     @iex_command_window.update()
   end

  #--------------------------------------------------------------------------#
  # * New Method - Command To Title
  #--------------------------------------------------------------------------#
  # Good old return to the title.
  #--------------------------------------------------------------------------#
  def command_to_title()
    Sound.play_decision()
    @iex_command_window.visible = false
    @iex_command_window.active = false
    Graphics.fadeout(120)
    RPG::BGM.fade(800)
    RPG::BGS.fade(800)
    RPG::ME.fade(800)
    $scene = Scene_Title.new()
  end

  #--------------------------------------------------------------------------#
  # * New Method - Command Continue
  #--------------------------------------------------------------------------#
  # This is actually a copied method from the Scene Title
  # Its a bit rigged to work with the Scene File properly though
  #--------------------------------------------------------------------------#
  def command_continue()
    if @continue_enabled
      Sound.play_decision()
      Graphics.freeze
      @iex_command_window.visible = false
      @iex_command_window.active = false
      $called_from_gameover = true
      $scene = Scene_File.new(false, false, false)
      $game_map.refresh()
    else
      Sound.play_buzzer()
    end
  end

  #--------------------------------------------------------------------------#
  # * New Method - Command Shutdown
  #--------------------------------------------------------------------------#
  # This is actually a copied method from the Scene Title
  # And it pretty much exits the game
  #--------------------------------------------------------------------------#
  def command_shutdown()
    Sound.play_decision()
    Graphics.fadeout(120)
    RPG::BGM.fade(800)
    RPG::BGS.fade(800)
    RPG::ME.fade(800)
    @iex_command_window.visible = false
    $scene = nil
  end

end

#==============================================================================#
# ** Scene File
#==============================================================================#
class Scene_File < Scene_Base

  #--------------------------------------------------------------------------#
  # * alias-method :return_scene
  #--------------------------------------------------------------------------#
  alias :iex_gameover_sf_return_scene :return_scene unless $@
  def return_scene( *args, &block )
    if $called_from_gameover
      $scene = Scene_Gameover.new(true)
      $called_from_gameover = false
    else
      iex_gameover_sf_return_scene( *args, &block )
    end
  end

  #--------------------------------------------------------------------------#
  # * alias-method :perform_transition
  #--------------------------------------------------------------------------#
  alias :iex_gameover_sf_perform_transition :perform_transition unless $@
  def perform_transition( *args, &block )
    if $called_from_gameover
      Graphics.transition(IEX::GAMEOVER::FADE_TIMES[:from_gm_ov])
    else
      iex_gameover_sf_perform_transition( *args, &block )
    end
  end

end

#==============================================================================#
# ** END OF FILE
#==============================================================================#
