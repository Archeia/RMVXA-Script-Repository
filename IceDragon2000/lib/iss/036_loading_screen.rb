#encoding:UTF-8
# ISS036 - Loading Screen
#==============================================================================#
# ** ISS - Loading Screen
#==============================================================================#
# ** Date Created  : 09/04/2011
# ** Date Modified : 11/12/2011
# ** Created By    : IceDragon
# ** For Game      : S.A.R.A
# ** ID            : 036
# ** Version       : 1.0
# ** Optional      : ISS000 - Core(2.1 or above)
#==============================================================================#
($imported ||= {})["ISS-LoadingScreen"] = true
#==============================================================================#
# ** ISS
#==============================================================================#
module ISS
  install_script(36, :system) if $simport.valid?('iss/core', '>= 1.9')
end

#==============================================================================#
# ** ISS::LoadingScreen
#==============================================================================#
class ISS::LoadingScreen

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :frames
  attr_accessor :cut_frames
  attr_accessor :cut_frame_start

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize
    @disposed = false
    @back_sprite = Sprite.new
    @back_sprite.bitmap = Cache.picture("BlackSheet")
    @loading_sprite = Sprite.new
    @loading_sprite.bitmap = Cache.picture("LoadingText")
    @loading_sprite.x = Graphics.width - @loading_sprite.width
    @loading_sprite.y = Graphics.height - @loading_sprite.height
    @loading_sprite.z = 3
    @loading_sprite.bush_opacity = 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :dispose
  #--------------------------------------------------------------------------#
  def dispose
    unless @back_sprite.nil?
      @back_sprite.bitmap.dispose; @back_sprite.bitmap = nil
      @back_sprite.dispose ; @back_sprite = nil
    end
    unless @loading_sprite.nil?
      @loading_sprite.bitmap.dispose; @loading_sprite.bitmap = nil
      @loading_sprite.dispose ; @loading_sprite = nil
    end
    @disposed = true
  end

  #--------------------------------------------------------------------------#
  # * new-method :disposed?
  #--------------------------------------------------------------------------#
  def disposed? ; return @disposed ; end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
  def update
    @frames = [@frames - 1, 0].max
    if @frames <= @cut_frame_start
      @loading_sprite.bush_depth += @loading_sprite.height / cut_frames
    end
  end

end

#==============================================================================#
# ** Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base

  #--------------------------------------------------------------------------#
  # * overwrite-method :start
  #--------------------------------------------------------------------------#
  def start
    super
    @__loading_screen = ISS::LoadingScreen.new
    @__loading_screen.frames = 120
    @__loading_screen.cut_frames = 40
    @__loading_screen.cut_frame_start = 40
    Graphics.transition(60)
    Graphics.wait(10) { @__loading_screen.update }
    load_database                   # Load database
    Graphics.wait(110) { @__loading_screen.update }
    create_game_objects             # Create game objects
    check_continue                  # Determine if continue is enabled
    Graphics.fadeout(60)
    create_title_graphic            # Create title graphic
    create_command_window           # Create command window
    @__loading_screen.dispose ; @__loading_screen = nil
    Graphics.fadein(60)
    play_title_music                # Play title screen music
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :command_new_game
  #--------------------------------------------------------------------------#
  def command_new_game
    confirm_player_location
    Sound.play_decision
    $game_party.setup_starting_members            # Initial party
    $game_map.setup($data_system.start_map_id)    # Initial map position
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    $scene = Scene_Map.new
    RPG::BGM.fade(1500)
    close_command_window
    Graphics.fadeout(60)
    @__loading_screen = ISS::LoadingScreen.new
    @__loading_screen.frames = 120
    @__loading_screen.cut_frames = 40
    @__loading_screen.cut_frame_start = 40
    Graphics.fadein(80)
    Graphics.wait(120) { |i| @__loading_screen.update }
    Graphics.frame_count = 0
    RPG::BGM.stop
    Graphics.fadeout(60)
    @__loading_screen.dispose ; @__loading_screen = nil
    $game_map.autoplay
  end

end
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
