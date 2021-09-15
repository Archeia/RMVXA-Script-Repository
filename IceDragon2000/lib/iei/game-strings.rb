#-skip 1
=begin
#-// 23/06/2012
#-// 23/06/2012
#-define HDR_TYP :type=>"class"
#-define HDR_GNM :name=>"IEI - Game::Strings"
#-define HDR_GDC :dc=>"23/06/2012"
#-define HDR_GDM :dm=>"23/06/2012"
#-define HDR_GAUT :author=>"IceDragon"
#-define HDR_VER :version=>"1.0"
#-inject gen_script_header_wotail HDR_TYP,HDR_GNM,HDR_GAUT,HDR_GDC,HDR_GDM,HDR_VER
#-inject gen_script_des "Introduction"
  Nothing big, just a class similar to Game::Variables,
  only difference it holds strings

#-inject gen_script_des "How To Use"
  $game.strings[id] = "string"
#-skip 1
=end
#-inject gen_script_header_tail
$simport.r 'iei/game_strings', '1.0.0', 'IEI Loginix'
#-inject gen_module_header 'DataManager'
class << DataManager

  # // Create the Game::Strings object on new games
  alias gms_crt_gm_objs create_game_objects
  def create_game_objects
    gms_crt_gm_objs
    $game.strings = Game::Strings.new
  end

  # // Save the Game::Strings, or create a new one if it doesn't exist
  alias gms_mk_sv_cont make_save_contents
  def make_save_contents
    contents = gms_mk_sv_cont
    contents[:strings] = $game.strings||Game::Strings.new
    contents
  end

  # // Pull the Game::Strings or create a new one if it doesn't exist
  alias gms_ex_sv_cont make_save_contents
  def extract_save_contents contents
    gms_ex_sv_cont contents
    $game.strings = contents[:strings]||Game::Strings.new
  end

end

#-inject gen_class_header 'Game::Strings'
class Game::Strings
  def initialize
    @data = Array.new
  end

  def [](id)
    @data[id] || ""
  end

  def []=(id, v)
    @data[id] = v
  end
end
#-inject gen_script_footer
