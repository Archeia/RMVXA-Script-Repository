#==============================================================================#
# ** Game_Map
#==============================================================================#
class Game_Map
  #--------------------------------------------------------------------------#
  # * alias-method :setup
  #--------------------------------------------------------------------------#
  alias :iss_swapxt_gmp_setup :setup
  def setup(map_id)
    iss_swapxt_gmp_setup(map_id)
    $game_swapxt.setup(map_id)
    unless $game_swapxt.loaded_system.nil?
      @passages = $game_swapxt.loaded_system.passages
    end
  end
end

#==============================================================================#
# ** Sprite_Character
#==============================================================================#
class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------#
  # * overwrite-method :tileset_bitmap
  #--------------------------------------------------------------------------#
  def tileset_bitmap(tile_id)
    set_number = tile_id / 256
    if ISS::SwapXT::EVENT_SWAPPING_SWITCH_ID.nil?
      defal = false
    else
      defal = $game_switches[ISS::SwapXT::EVENT_SWAPPING_SWITCH_ID]
    end
    btmpnm = $game_swapxt.tile_bitmapname(set_number + 5, defal)
    (set_number >= 0 && set_number <= 4) ? Cache.system(btmpnm) : nil
  end
end

#==============================================================================#
# ** Spriteset_Map
#==============================================================================#
class Spriteset_Map
  #--------------------------------------------------------------------------#
  # * alias-method :create_tilemap
  #--------------------------------------------------------------------------#
  alias :iss_swapxt_spmp_create_tilemap :create_tilemap
  def create_tilemap
    iss_swapxt_spmp_create_tilemap
    set_tilemap_bitmaps(@tilemap)
  end

  #--------------------------------------------------------------------------#
  # * new-method :set_tilemap_bitmaps
  #--------------------------------------------------------------------------#
  def set_tilemap_bitmaps(tilemap)
    gsxt = $game_swapxt
    9.times do |i|
      tilemap.bitmaps[i] = Cache.system(gsxt.tile_bitmapname(i, false))
    end
  end
end

#==============================================================================#
# ** Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------#
  # * alias-method :start
  #--------------------------------------------------------------------------#
  alias :iss_swapxt_scnt_start :start
  def start
    iss_swapxt_scnt_start
    ISS::SwapXT::Game_SwapXT.startup_error_checking
  end

  #--------------------------------------------------------------------------#
  # * alias-method :create_game_objects
  #--------------------------------------------------------------------------#
  alias :iss_swapxt_scnt_create_game_objects :create_game_objects
  def create_game_objects
    iss_swapxt_scnt_create_game_objects
    $game_swapxt = ISS::SwapXT::Game_SwapXT.new
  end
end

if $imported['ISS-MGPAS']
#==============================================================================#
# ** ISS::MGPAS
#==============================================================================#
module ISS::MGPAS
  class << self
    #--------------------------------------------------------------------------#
    # * alias-method :write_save_data
    #--------------------------------------------------------------------------#
    alias :iss_swapxt_scnf_write_save_data :write_save_data
    def write_save_data(file)
      iss_swapxt_scnf_write_save_data(file)
      Marshal.dump($game_swapxt,      file)
    end

    #--------------------------------------------------------------------------#
    # * alias-method :read_save_data
    #--------------------------------------------------------------------------#
    alias :iss_swapxt_scnf_read_save_data :read_save_data
    def read_save_data(file)
      iss_swapxt_scnf_read_save_data(file)
      $game_swapxt    = Marshal.load(file)
    end
  end
end

else

#==============================================================================#
# ** Scene_File
#==============================================================================#
class Scene_File < Scene_Base
  #--------------------------------------------------------------------------#
  # * alias-method :write_save_data
  #--------------------------------------------------------------------------#
  alias :iss_swapxt_scnf_write_save_data :write_save_data
  def write_save_data(file)
    iss_swapxt_scnf_write_save_data(file)
    Marshal.dump($game_swapxt,      file)
  end

  #--------------------------------------------------------------------------#
  # * alias-method :read_save_data
  #--------------------------------------------------------------------------#
  alias :iss_swapxt_scnf_read_save_data :read_save_data
  def read_save_data(file)
    iss_swapxt_scnf_read_save_data(file)
    $game_swapxt    = Marshal.load(file)
  end
end

end
