#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Tile Swap
#  Author: Kread-EX
#  Version 1.0
#  Release date: 05/02/2012
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

#-------------------------------------------------------------------------------------------------
#  ▼ TERMS OF USAGE
#-------------------------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work for commercial purposes if you like it.
# #  Credit is appreciated.
# #
# # For support:
# # grimoirecastle.wordpress.com
# # OR
# # rpgmakervxace.net
# # OR
# # rpgrevolution.com
#-------------------------------------------------------------------------------------------------
#  ▼ INTRODUCTION
#-------------------------------------------------------------------------------------------------
# # Restores an old function from Rm2k: the ability to swap a tile for another
# # in a map.
#-------------------------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#-------------------------------------------------------------------------------------------------
# # Three possible commands have been added.
# #
# # $game_system.add_swap_tile(map_id, old_tile_id, new_tile_id, layer)
# # Swap a tile with another.
# #
# # $game_system.remove_swap_tile(map_id, old_tile_id, layer)
# # Removes a swap data.
# #
# # $game_system.clear_list(map_id)
# # Clears all the swap data for the map.
# #
# # Arguments:
# # map_id: the ID of the target map.
# # old_tile_id: the ID of the initial tile. Use Aquire Position Information to
# # determine it.
# # new_tile_id: the ID of the new tile. Use Aquire Position Information to
# # determine it.
# # layer: the layer cocnerned by the swapping.
#-------------------------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#-------------------------------------------------------------------------------------------------
# # Because this script overwrites a few methods, it can cause compatibility
# # issues. Don't hesitate to report them to me.
# #
# # List of aliases and overwrites:
# #
# # Game_System
# # initialize_list (new method)
# # swapped_tiles (new method)
# # add_swap_tile (new method)
# # remove_swap_tile (new method)
# # clear_list (new method)
# #
# # Game_Map
# # upd (new attr method)
# # setup (alias)
# # make_updated_map_data (new method)
# # tile_id (overwrite)
# # region_id (overwrite)
# #
# # Spriteset_Map
# # create_tilemap (overwrite)
# # update_tilemap (overwrite)
#-------------------------------------------------------------------------------------------------

$imported = {} if $imported.nil?
$imported['KRX-Tileswap'] = true

puts 'Load: Tile Swap v1.0 by Kread-EX'

#===========================================================================
# ■ Game_System
#===========================================================================

class Game_System
	#--------------------------------------------------------------------------
	# ● Declares the list
	#--------------------------------------------------------------------------
  def initialize_list(map_id)
    @swapped_tiles = {} if @swapped_tiles.nil?
    @swapped_tiles[map_id] = {} if @swapped_tiles[map_id].nil?
  end
	#--------------------------------------------------------------------------
	# ● Returns the swapped tiles
	#--------------------------------------------------------------------------
  def swapped_tiles(map_id, layer, tile_id)
    initialize_list(map_id)
    @swapped_tiles[map_id][[layer, tile_id]]
  end
	#--------------------------------------------------------------------------
	# ● Adds a tile to the swap list
	#--------------------------------------------------------------------------
  def add_swap_tile(map_id, old_tile, new_tile, layer)
    initialize_list(map_id)
    @swapped_tiles[map_id][[layer, old_tile]] = new_tile
    $game_map.upd = $game_map.make_updated_map_data
  end
	#--------------------------------------------------------------------------
	# ● Removes a tile to the swap list
	#--------------------------------------------------------------------------
  def remove_swap_tile(map_id, old_tile, layer)
    initialize_list(map_id)
    @swapped_tiles[map_id][[layer, old_tile]] = nil
    $game_map.upd = $game_map.make_updated_map_data
  end
	#--------------------------------------------------------------------------
	# ● Clears the swap list for a specific map
	#--------------------------------------------------------------------------
  def clear_list(map_id)
    @swapped_tiles[map_id] = {}
    $game_map.upd = $game_map.make_updated_map_data
  end
end

#===========================================================================
# ■ Game_Map
#===========================================================================

class Game_Map
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_accessor :upd
	#--------------------------------------------------------------------------
	# ● Setup
	#--------------------------------------------------------------------------
  alias_method(:krx_tswap_gm_setup, :setup)
  def setup(map_id)
    @map_id = map_id
    @map = load_data(sprintf("Data/Map%03d.rvdata2", @map_id))
    @upd = make_updated_map_data
    krx_tswap_gm_setup(map_id)
  end
	#--------------------------------------------------------------------------
	# ● Adds the swapped tiles to the raw map data
	#--------------------------------------------------------------------------
  def make_updated_map_data
    result = data.dup
    for i in 0...result.xsize
      for j in 0...result.ysize
        for k in 0...result.zsize
          t_id = result[i, j, k]
          n_id = $game_system.swapped_tiles(@map_id, k, t_id)
          result[i, j, k] = n_id unless n_id.nil?
        end
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # ● Returns the tile ID of a pair of coordinates
  #--------------------------------------------------------------------------
  def tile_id(x, y, z)
    @upd[x, y, z] || 0
  end
  #--------------------------------------------------------------------------
  # ● Returns the region ID of a pair of coordinates
  #--------------------------------------------------------------------------
  def region_id(x, y)
    valid?(x, y) ? @upd[x, y, 3] >> 8 : 0
  end
end

#===========================================================================
# ■ Spriteset_Map
#===========================================================================

class Spriteset_Map
  #--------------------------------------------------------------------------
  # ● Creates the tilemap
  #--------------------------------------------------------------------------
  def create_tilemap
    @tilemap = Tilemap.new(@viewport1)
    @tilemap.map_data = $game_map.upd
    load_tileset
  end
  #--------------------------------------------------------------------------
  # ● Updates the tilemap
  #--------------------------------------------------------------------------
  def update_tilemap
    @tilemap.map_data = $game_map.upd
    @tilemap.ox = $game_map.display_x * 32
    @tilemap.oy = $game_map.display_y * 32
    @tilemap.update
  end
end