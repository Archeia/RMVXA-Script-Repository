#Multiple Map Layers v1.1
#----------#
#Features: Let's you layer one or two maps on top of another! Even if they have
#           like different tilesets! Which is the point.
#
#Usage:   Just put <LAYER# #> in the note box of the base map, where the first
#          # is the layer #, and the second # is the map to squish on.
#
#         New Features:
#          show_layer(id)   - will show that layer
#          hide_layer(id)   - will hide that layer
#
#          Placing <L#> (where # is the number of the layer) in the name of event
#          will tie that event to that layer, which means it will only be active
#          and visible when that layer is.
#
#         As a general rule, all layered maps should be the same size as the base map, or things will happen.
#
#Examples:
#     <LAYER5 54>
#     <LAYER78 2>
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
class Game_Map
  attr_accessor   :maps
  alias mm_setup setup
  def setup(map_id)
    @maps = {}
    mm_setup(map_id)
    note = @map.note.clone
    while note.include?("<LAYER")
      /<LAYER(?<id>\d{1,3}) (?<cond>\d{1,3})>/ =~ note
      @maps[$1.to_i] = load_data(sprintf("Data/Map%03d.rvdata2", $2.to_i))
      @maps[$1.to_i].active = true
      note[note.index("<LAYER")] = "&"
    end
  end
  def layer(id)
    return false if @maps[id].nil?
    return @maps[id]
  end
  def check_passage(x, y, bit)
    passable = false
    all_tiles(x, y, 0).each do |tile_id|
      flag = tileset.flags[tile_id]
      next if flag & 0x10 != 0            # [☆]: No effect on passage
      break passable = true if flag & bit == 0     # [○] : Passable
      return false if flag & bit == bit   # [×] : Impassable
    end
    @maps.each do |id,map|
      next unless map.active
      all_tiles(x, y, id).each do |tile_id|
        flag = $data_tilesets[layer(id).tileset_id].flags[tile_id]
        next if flag & 0x10 != 0            # [☆]: No effect on passage
        break passable = true if flag & bit == 0     # [○] : Passable
        return false if flag & bit == bit   # [×] : Impassable
      end
    end
    return true if passable
    return false                          # Impassable
  end
  def all_tiles(x,y,id = 0)
    tile_events_xy(x, y).collect {|ev| ev.tile_id } + layered_tiles(x, y, id)
  end
  def layered_tiles(x,y, id = 0)
    [2, 1, 0].collect {|z| tile_id(x, y, z, id) }
  end
  def tile_id(x,y,z, id = 0)
    return @map.data[x,y,z] || 0 if id == 0
    @maps[id].data[x,y,z] || 0
  end
  def hide_layer(id)
    @maps[id].active = false if @maps[id]
    refresh
  end
  def show_layer(id)
    @maps[id].active = true if @maps[id]
    refresh
  end
end
 
class Game_Player
  def perform_transfer
    if transfer?
      set_direction(@new_direction)
      if @new_map_id != $game_map.map_id
        $game_map.setup(@new_map_id)
        SceneManager.scene.spriteset.load_tileset
        $game_map.autoplay
      end
      moveto(@new_x, @new_y)
      clear_transfer_info
    end
  end
end

class Game_Event
  alias mml_conditions_met? conditions_met?
  def conditions_met?(page)
    return false if layer && $game_map.maps[layer] && !$game_map.maps[layer].active
    mml_conditions_met?(page)
  end
  def layer
    @event.name =~ /<L(\d+)>/ ? $1.to_i : false
  end
end

class RPG::Map
  attr_accessor :active
end
 
class Scene_Map
  attr_accessor  :spriteset
end
 
class Spriteset_Map
  alias mm_load_tileset load_tileset
  alias mm_update_tilemap update_tilemap
  alias mm_dispose_tilemap dispose_tilemap
  def create_ex_tilemaps
    $game_map.maps.each do |id,map|
      @ex_tilemaps[id] = Tilemap.new(@viewport1)
      @ex_tilemaps[id].map_data = $game_map.layer(id).data
    end
  end
  def dispose_ex_tilemaps
    if @ex_tilemaps
      @ex_tilemaps.each do |id,tilemap|
        tilemap.dispose
      end
    end
    @ex_tilemaps = {}
  end
  def load_tileset
    mm_load_tileset
    dispose_ex_tilemaps
    create_ex_tilemaps
    @ex_tilesets = {}
    @ex_tilemaps.each do |id,tilemap|
      @ex_tilesets[id] = $data_tilesets[$game_map.layer(id).tileset_id]
      @ex_tilesets[id].tileset_names.each_with_index do |name, i|
        tilemap.bitmaps[i] = Cache.tileset(name)
      end
      tilemap.flags = @ex_tilesets[id].flags
    end
  end
  def dispose_tilemap
    mm_dispose_tilemap
    dispose_ex_tilemaps
  end
  def update_tilemap
    mm_update_tilemap
    @ex_tilemaps.each do |id,tilemap|
      tilemap.visible = $game_map.maps[id].active
      tilemap.map_data = $game_map.layer(id).data
      tilemap.ox = $game_map.display_x * 32
      tilemap.oy = $game_map.display_y * 32
      tilemap.update
    end
  end
end

class Game_Interpreter
  def hide_layer(id)
    $game_map.hide_layer(id)
  end
  def show_layer(id)
    $game_map.show_layer(id)
  end
end