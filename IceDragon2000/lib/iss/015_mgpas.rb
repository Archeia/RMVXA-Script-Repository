#encoding:UTF-8
# ISS015 - MGPAS 1.0
# // Multi Game Progress Achievement System
# // ENV["HOME"] doesn't work in rmvx
# // ENV["USERPROFILE"]
#==============================================================================#
($imported ||= {})["ISS-MGPAS"] = true
#==============================================================================#
# ** ISS::MGPAS
#==============================================================================#
module ISS
  install_script(15, :system)
  module MGPAS

    #SAVE_NAME     = "CJSave"
    #SAVE_LOCATION = (ENV["USERPROFILE"].gsub(/\\/) { "//" }) + "//CodeJIFZ//"
    SAVE_NAME     = "SARAsave"
    SAVE_LOCATION = (ENV["USERPROFILE"].gsub(/\\/) { "//" }) + "//SARA//"
    SAVE_EXTENSION= ".rvdata"

    Dir.mkdir(SAVE_LOCATION) unless FileTest.exist?(SAVE_LOCATION)

    module_function()
  #--------------------------------------------------------------------------#
  # * new-method :make_filename
  #--------------------------------------------------------------------------#
    def make_filename(insert="")
      "#{PROGSYS::SAVE_LOCATION}#{PROGSYS::SAVE_NAME}#{insert}#{PROGSYS::SAVE_EXTENSION}"
    end

  #--------------------------------------------------------------------------#
  # * new-method :write_save_data
  #--------------------------------------------------------------------------#
    def write_save_data(file)
      characters = []
      for actor in $game_party.members
        characters.push([actor.character_name, actor.character_index])
      end
      $game_system.save_count += 1
      $game_system.version_id = $data_system.version_id
      $last_bgm = RPG::BGM::last
      $last_bgs = RPG::BGS::last
      Marshal.dump(characters,           file)
      Marshal.dump(Graphics.frame_count, file)
      Marshal.dump($last_bgm,            file)
      Marshal.dump($last_bgs,            file)
      Marshal.dump($game_system,         file)
      Marshal.dump($game_message,        file)
      Marshal.dump($game_switches,       file)
      Marshal.dump($game_variables,      file)
      Marshal.dump($game_self_switches,  file)
      Marshal.dump($game_actors,         file)
      Marshal.dump($game_party,          file)
      Marshal.dump($game_troop,          file)
      Marshal.dump($game_map,            file)
      Marshal.dump($game_player,         file)
    end
  #--------------------------------------------------------------------------#
  # * new-method :read_save_data
  #--------------------------------------------------------------------------#
    def read_save_data(file)
      characters           = Marshal.load(file)
      Graphics.frame_count = Marshal.load(file)
      $last_bgm            = Marshal.load(file)
      $last_bgs            = Marshal.load(file)
      $game_system         = Marshal.load(file)
      $game_message        = Marshal.load(file)
      $game_switches       = Marshal.load(file)
      $game_variables      = Marshal.load(file)
      $game_self_switches  = Marshal.load(file)
      $game_actors         = Marshal.load(file)
      $game_party          = Marshal.load(file)
      $game_troop          = Marshal.load(file)
      $game_map            = Marshal.load(file)
      $game_player         = Marshal.load(file)
      if $game_system.version_id != $data_system.version_id
        $game_map.setup($game_map.map_id)
        $game_player.center($game_player.x, $game_player.y)
      end
    end

    #class << self

    #  alias :mgpas_write_save_data :write_save_data unless $@
    #  def write_save_data(file)
    #    mgpas_write_save_data(file)
    #  end

    #  alias :mgpas_read_save_data :read_save_data unless $@
    #  def read_save_data(file)
    #    mgpas_read_save_data(file)
    #  end

    #end

  end
end
#==============================================================================#
# ** PROGSYS
#==============================================================================#
  PROGSYS = ISS::MGPAS
#==============================================================================#
# ** Game_Progress
#==============================================================================#
class Game_Progress

  #--------------------------------------------------------------------------#
  # * overwrite-method :initialize
  #--------------------------------------------------------------------------#
  def initialize
  end

end

#==============================================================================#
# ** Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base

  #--------------------------------------------------------------------------#
  # * overwrite-method :check_continue
  #--------------------------------------------------------------------------#
  def check_continue()
    @continue_enabled = (Dir.glob(PROGSYS.make_filename("*")).size > 0)
  end

end

#==============================================================================#
# ** Scene_File
#==============================================================================#
class Scene_File < Scene_Base

  #--------------------------------------------------------------------------#
  # * overwrite-method :make_filename
  #--------------------------------------------------------------------------#
  def make_filename(file_index)
    return PROGSYS.make_filename(file_index + 1)
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :write_save_data
  #--------------------------------------------------------------------------#
  def write_save_data(file)
    $last_bgm = @last_bgm
    $last_bgs = @last_bgs
    ISS::MGPAS.write_save_data(file)
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :read_save_data
  #--------------------------------------------------------------------------#
  def read_save_data(file)
    ISS::MGPAS.read_save_data(file)
    @last_bgm = $last_bgm
    @last_bgs = $last_bgs
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
