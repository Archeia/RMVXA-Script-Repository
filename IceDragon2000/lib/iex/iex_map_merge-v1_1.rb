#==============================================================================
# ** IEX(Icy Engine Xelion) - Map Merge
#------------------------------------------------------------------------------
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Maps)
# ** Script Type   : Multi-Map Layering
# ** Date Created  : ??/??/2010 (DD/MM/YYYY)
# ** Date Modified : 08/07/2011 (DD/MM/YYYY)
# ** Script Tag    : IEX - Map Merge
# ** Difficulty    : Hard
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# This script allows you to merge multiple maps together (No, not pokemon style)
# You can then replicate the Harvest Moon, houses upgrade and such.
# It doesn't stop there.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** HOW TO USE?
#------------------------------------------------------------------------------#
# V1.0 - Tags - Maps - Place in map's name
#------------------------------------------------------------------------------#
# You create multiple maps, and then you create the one you want to use for
# the merging, place <map merge: map_id, map_id, etc...> map_id being the maps
# you want to merge with this one. Note, if there are tile overlaps, the last map
# is above the ones before it.
#
# To have a switch merge operated map, put <switch: switch_id>, when that Game
# Switch is set to true. That map will be merged with the base map.
# NOTE : Even though this type of map is switch operated, remember to add it to
# the <map merge>
#
# You can place maps on specific X, Y pos using <map coords: x, y>.
# NOTE : The X, Y will start on the base map, and will start in the 0,0 position
# of merging map (Or the map to be merged)
#
# If your using a switch map, do a script call with imm_merge_reset
# This will rebuild the maps cache and restart the Scene_Map
# That way you can see the changes.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
#
# Works with SwapXT (Just place this script below it)
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#------------------------------------------------------------------------------#
#
# Below
#  Materials
#  Anything that makes changes to the Game_Map
#
# Above
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES
#------------------------------------------------------------------------------#
# Classes
# new-class :IMM_Map_Store
# new-class :IMM_Map_Storage
#   RPG::MapInfo
#     alias      :name
#     new-method :get_merge_maps
#     new-method :switch_map
#     new-method :imm_map_coords
#     new-method :imm_No_TileA?
#   Game_Map
#     alias      :initialize
#     alias      :setup
#     new-method :imm_map_merge_create
#   Game_Interpreter
#     new-method :imm_merge_reset
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
# (DD/MM/YYYY)
#  IMM
#  10/04/2010 - V1.0  Finished Script
#  10/06/2010 - V1.2  Updated with bug fixes
#
#  IEX
#  01/01/2011 - V1.0  Ported to IEX + Finished Docing
#  01/08/2011 - V1.0a Small Changes
#  08/07/2011 - V1.1  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment.
#
#------------------------------------------------------------------------------#
$imported ||= {}
$imported["IEX_MapMerge"] = true
#==============================================================================#
# ** IEX::MAP_MERGER
#==============================================================================#
module IEX
  module MAP_MERGER
    TILE_VOID = [0, 1544]
  end
end

#==============================================================================#
# ** IEX::REGEXP::MAP_MERGER
#==============================================================================#
module IEX
  module REGEXP
    module MAP_MERGER
      MAP_MERGE_TAG = /<(?:IMM|MERGE|MAP_MERGE|map merge):[ ]*(\d+(?:\s*,\s*\d+)*)>/i
      SWITCH_MAP = /<(?:SWITCH|switch_map|switch map):[ ]*(\d+)>/i
      MAP_COORDS = /<(?:COORDS|MAP_COORDS|map coords|xy_pos|xy pos):[ ]*(\d+),[ ]*(\d+)>/i
   OV_TILES_ONLY = /<(?:NO_TILEA|no tilea)>/i
    end
  end
end

#==============================================================================#
# ** RPG::MapInfo
#==============================================================================#
class RPG::MapInfo

  #--------------------------------------------------------------------------#
  # * new-method :name
  #--------------------------------------------------------------------------#
  alias :imm_map_merge_name :name unless $@
  def name( *args, &block )
    if @imm_strip_name.nil?
      @imm_strip_name = imm_map_merge_name( *args, &block ).clone
      @imm_strip_name.gsub!(IEX::REGEXP::MAP_MERGER::MAP_MERGE_TAG) { "" }
      @imm_strip_name.gsub!(IEX::REGEXP::MAP_MERGER::SWITCH_MAP) { "" }
      @imm_strip_name.gsub!(IEX::REGEXP::MAP_MERGER::MAP_COORDS) { "" }
    end
    return @imm_strip_name
  end

  #--------------------------------------------------------------------------#
  # * new-method :get_merge_maps
  #--------------------------------------------------------------------------#
  def get_merge_maps
    if @merge_maps.nil?
      name_sr = @name.clone
      imms = []
      case name_sr
      when IEX::REGEXP::MAP_MERGER::MAP_MERGE_TAG
        $1.scan(/\d+/).each { |num|
        imms.push(num.to_i) if num.to_i > 0 }
      end
      @merge_maps = imms
    end
    return @merge_maps
  end

  #--------------------------------------------------------------------------#
  # * new-method :switch_map
  #--------------------------------------------------------------------------#
  def switch_map
    if @switch_map.nil?
      @switch_map = @name =~ IEX::REGEXP::MAP_MERGER::SWITCH_MAP ? $1.to_i : 0
    end
    return @switch_map
  end

  #--------------------------------------------------------------------------#
  # * new-method :imm_map_coords
  #--------------------------------------------------------------------------#
  def imm_map_coords
    if @map_coords.nil?
      @map_coords = @name.clone =~ IEX::REGEXP::MAP_MERGER::MAP_COORDS ? [$1.to_i, $2.to_i] : [0,0]
    end
    return @map_coords
  end

  #--------------------------------------------------------------------------#
  # * new-method :imm_No_TileA?
  #--------------------------------------------------------------------------#
  def imm_No_TileA?
    if @notileA.nil?
      @notileA = @name =~ IEX::REGEXP::MAP_MERGER::OV_TILES_ONLY ? true : false
    end
    return @notileA
  end

end

#==============================================================================#
# ** IMM_Map_Store
#==============================================================================#
class IMM_Map_Store

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :x
  attr_accessor :y

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( map, map_id, x = 0, y = 0 )
    @map = map
    @x = x
    @y = y
    @map_id = map_id
  end

  #--------------------------------------------------------------------------#
  # * new-method :x_pos
  #--------------------------------------------------------------------------#
  def x_pos ; return self.x end
  #--------------------------------------------------------------------------#
  # * new-method :y_pos
  #--------------------------------------------------------------------------#
  def y_pos ; return self.y end
  #--------------------------------------------------------------------------#
  # * new-method :data
  #--------------------------------------------------------------------------#
  def data ;  return @map.data end
  #--------------------------------------------------------------------------#
  # * new-method :map
  #--------------------------------------------------------------------------#
  def map ;   return @map end
  #--------------------------------------------------------------------------#
  # * new-method :map_id
  #--------------------------------------------------------------------------#
  def map_id ;return @map_id end

end

#==============================================================================#
# ** IMM_Map_Storage
#==============================================================================#
class IMM_Map_Storage

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize ; @data_store = [] ; end

  #--------------------------------------------------------------------------#
  # * new-method :has_map?
  #--------------------------------------------------------------------------#
  def has_map?( map_id=0 ) ; return @data_store[map_id].nil? ; end

  #--------------------------------------------------------------------------#
  # * new-method :has_map?
  #--------------------------------------------------------------------------#
  def map_data( map_id=0 ) ; return @data_store[map_id] ; end

  #--------------------------------------------------------------------------#
  # * new-method :add_map
  #--------------------------------------------------------------------------#
  def add_map( map_id = 0, map_data = nil )
    @data_store[map_id] = map_data if map_id != nil and map_data != nil
  end

  #--------------------------------------------------------------------------#
  # * new-method :remove_map
  #--------------------------------------------------------------------------#
  def remove_map( map_id=0 ) ; @data_store[map_id] = nil ; end

  #--------------------------------------------------------------------------#
  # * new-method :clear_maps
  #--------------------------------------------------------------------------#
  def clear_maps ; @data_store.clear ; end

end

#==============================================================================#
# ** Game Map
#==============================================================================#
class Game_Map

  #--------------------------------------------------------------------------#
  # * alias-method :setup
  #--------------------------------------------------------------------------#
  alias imm_map_merge_setup setup unless $@
  def setup( *args, &block )
    imm_map_merge_setup( *args, &block )
    $map_infos ||= load_data("Data/MapInfos.rvdata")
    $imm_map_store ||= IMM_Map_Storage.new
    imm_map_merge_create
  end

  #--------------------------------------------------------------------------#
  # * new-method :imm_map_merge_create
  #--------------------------------------------------------------------------#
  def imm_map_merge_create
    #@map = load_data(sprintf("Data/Map%03d.rvdata", @map_id))
    imms = $map_infos[@map_id].get_merge_maps
    return if imms == nil
    return if imms.empty?
    @imms_maps = []
    for ma in imms
      unless $map_infos[ma].switch_map.nil?
        next unless $game_switches[$map_infos[ma].switch_map]
      end
      unless $map_infos[ma].imm_map_coords.nil?
        coords = $map_infos[ma].imm_map_coords
      else ; coords = [0, 0]
      end
      imm_map = IMM_Map_Store.new(DataCache.load_map_by_id(ma), ma, coords[0], coords[1])
      @imms_maps.push(imm_map)
    end

    for y in 0...height
      for x in 0...width
        for m_map in @imms_maps
          next if m_map == nil
          next unless x >= m_map.x_pos
          next unless y >= m_map.y_pos
          imm_map_y = m_map.y_pos
          imm_map_x = m_map.x_pos
          next if m_map.data[x - imm_map_x, y - imm_map_y, 0].nil? &&
           m_map.data[x - imm_map_x, y - imm_map_y, 1].nil? &&
           m_map.data[x - imm_map_x, y - imm_map_y, 2].nil?
          for i in 0..2
            next if (@map_infos[imm_map.map_id].imm_No_TileA? and i == 0)
            unless IEX::MAP_MERGER::TILE_VOID.include?(m_map.data[x - imm_map_x, y - imm_map_y, i] )
              @map.data[x, y, i] = m_map.data[x - imm_map_x, y - imm_map_y, i]
            end
          end
        end

      end
    end
  end

end

#==============================================================================#
# ** Game Interpreter
#==============================================================================#
class Game_Interpreter

  #--------------------------------------------------------------------------#
  # * new-method :imm_merge_reset
  #--------------------------------------------------------------------------#
  def imm_merge_reset
    $game_map.imm_map_merge_create
    $scene = Scene_Map.new
  end

end

#==============================================================================#
# ** END OF FILE
#==============================================================================#
