#==============================================================================#
# ** IEX(Icy Engine Xelion) - Map Layering
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Maps)
# ** Script Type   : Multi-Map Layering
# ** Date Created  : ??/??/2010 (DD/MM/YYYY)
# ** Date Modified : 08/07/2011 (DD/MM/YYYY)
# ** Script Tag    : IEX - Map Layering
# ** Difficulty    : Hard
# ** Version       : 1.3
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# This script aims to help people who want to do Parallax mapping without the
# image editing.
# This allows you to place another map on top of another, this can be stacked
# *I reccommend only using about 2 layer maps per base map.
# This however causes you to use a lot of maps, the advantage is you can change
# any tile you want on the layer map, so no serious photoshopping is required.
# These layer maps also update like normal ones, so the water animations are
# all fine.
# As a bonus, you can use SwapXt with this, just do what you normally do.
# And setup the map, don't forget to add the new tilesets to the layer maps
#
# The main tag for basemaps is
# <lay_map: x>
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FEATURES
#------------------------------------------------------------------------------#
# V1.0 - Tags - Maps - Place in map's name
#------------------------------------------------------------------------------#
# ~BASEMAPS~ Will not work with Layermaps (Unless the base map is used as a base)
# <lay_map: x> (or) <laymap: x, x, x> (or) <lay maps: x, x>
# Use this tag with the base map, this will place the maps marked by x
# over the current map.
#
# EG: <lay_map: 2> This will lay map(id 2) over the current one
#
# ~LAYERMAPS~ Will not work with Basemaps (Unless the base map is used as a layer)
# <NEGATE_1STLAYER> (or) <negate 1st layer>
# This causes the map to remove all its first layer tiles (Everything in A1~A5)
#
# <ONLY1_ATILE> (or) <ONLY1 ALAYER>
# This does almost the same thing as the NEGATE_1STLAYER
# The difference is, this will only clear the 1st layer if it finds a Autotile
# above it (Like the normal grass, with the tall grass over it)
# It will then remove the tile below it.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
#
# Compatable with SwapXT
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#------------------------------------------------------------------------------#
#
# Below
#  Materials
#  SwapXT
#
# Above
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES
#------------------------------------------------------------------------------#
# Classes
#   RPG::MapInfo
#     alias      :name
#     new-method :layer_maps
#     new-method :switch_map
#     new-method :overlay_2ndLayer?
#     new-method :negates_1stLayer?
#   Game_Map
#     alias      :initialize
#     alias      :setup
#   Spriteset_Map
#     alias      :initialize
#     alias      :dispose
#     alias      :update
#     new-method :update_layer_tilemaps
#     new-method :update_layer_viewports
#     new-method :create_layer_maps
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
# (DD/MM/YYYY)
#  ??/??/2010 - V1.0  Finished Script
#  01/01/2011 - V1.0  Finished Docing
#  01/08/2011 - V1.0a Few Changes, nothing much
#  01/10/2011 - V1.1  Changed Tilemap
#  07/07/2011 - V1.2  Added more layer control
#  08/07/2011 - V1.3  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment.
#
#------------------------------------------------------------------------------#
$imported ||= {}
$imported["IEX_MapLayering"] = true
#==============================================================================#
# ** IEX::MapLayering
#==============================================================================#
module IEX
  module MapLayering
    TONE_VIEWPORT_Z = 40
    LAYERS_ADD_Z    = 0
  end
end

#==============================================================================#
# ** RPG::MapInfo
#==============================================================================#
class RPG::MapInfo

  #--------------------------------------------------------------------------#
  # * alias-method :name
  #--------------------------------------------------------------------------#
  alias :iex_map_lay_rpgm_name :name unless $@
  def name( *args, &block )
    if @striped_name.nil?
      @striped_name = iex_map_lay_rpgm_name( *args, &block ).clone
      @striped_name.gsub!(/<(lay_map|lay map|laymap)s?:[ ]*(\d+(?:\s*,\s*\d+)*)>/i) { "" }
      @striped_name.gsub!(/<(?:NEGATE_1STLAYER|negate 1stlayer|negate_1st_layer|negate 1st layer)>/i) { "" }
      @striped_name.gsub!(/<(?:ONLY1_ATILE|ONLY1 ATILE|ONLY1_ALAYER|ONLY1 ALAYER)>/i) { "" }
    end
    return @striped_name
  end

  #--------------------------------------------------------------------------#
  # * new-method :layer_maps
  #--------------------------------------------------------------------------#
  def layer_maps
    if @layer_maps.nil?
      @layer_maps = []
      case @name
      when /<(?:lay_map|lay map|laymap)s?:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
        $1.scan(/\d+/).each { |mp_id|
        layer_maps.push(mp_id.to_i) unless mp_id.to_i <= 0
       }
      end
    end
    return @layer_maps
  end

  #--------------------------------------------------------------------------#
  # * new-method :overlay_2ndLayer?
  #--------------------------------------------------------------------------#
  def overlay_2ndLayer?
    if @overlay_2nd.nil?
      @overlay_2nd = false
      case @name
      when /<(?:ONLY1_ATILE|ONLY1 ATILE|ONLY1_ALAYER|ONLY1 ALAYER)>/i
        @overlay_2nd = true
      end
    end
    return @overlay_2nd
  end

  #--------------------------------------------------------------------------#
  # * new-method :negates_1stLayer?
  #--------------------------------------------------------------------------#
  def negates_1stLayer?
    if @negates_1st.nil?
      @negates_1st = false
      case @name
      when /<(?:NEGATE_1STLAYER|negate 1stlayer|negate_1st_layer|negate 1st layer)>/i
        @negates_1st = true
      end
    end
    return @negates_1st
  end

end

#==============================================================================#
# ** Game_Map
#==============================================================================#
class Game_Map

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :iex_layer_maps

  #--------------------------------------------------------------------------#
  # * alias-method :setup
  #--------------------------------------------------------------------------#
  alias :iex_map_lay_gm_setup :setup unless $@
  def setup( *args, &block )
    iex_map_lay_gm_setup( *args, &block )
    @map_infos ||= load_data("Data/MapInfos.rvdata")
    @iex_layer_maps ||= []
    @iex_layer_maps.clear
    @map_infos[@map_id].layer_maps.each do |mp_id|
      next if mp_id.nil?
      da = {}
      tile_dat = []
      da[:map] = DataCache.load_map_by_id(mp_id)
      da[:tile_info] = {}
      profile_path_tile = "swapxt/tiles/" + mp_id.to_s + ".stx"
      if File.exist?(profile_path_tile)
        tile_dat[0], tile_dat[1], tile_dat[2], tile_dat[3],
        tile_dat[4], tile_dat[5], tile_dat[6], tile_dat[7],
        tile_dat[8] = File.read(profile_path_tile).split("\n")
      else
        for i in 0..8
          tile_dat.push("empty::*::")
        end
      end
      da[:tile_info]["A1"]= tile_dat[0].to_s
      da[:tile_info]["A2"]= tile_dat[1].to_s
      da[:tile_info]["A3"]= tile_dat[2].to_s
      da[:tile_info]["A4"]= tile_dat[3].to_s
      da[:tile_info]["A5"]= tile_dat[4].to_s
      da[:tile_info]["B"] = tile_dat[5].to_s
      da[:tile_info]["C"] = tile_dat[6].to_s
      da[:tile_info]["D"] = tile_dat[7].to_s
      da[:tile_info]["E"] = tile_dat[8].to_s

      da[:passages] = passages
      profile_path_passages = "swapxt/passages/" + mp_id.to_s + ".stx"
      if FileTest.exist?(profile_path_passages)
        pass = (File.read(profile_path_passages).split("\n"))[0]
        path = "Graphics/System/extra_tiles/" + pass.to_s + ".rvdata"
        if FileTest.exist?(path)
          sys = load_data(path)
          da[:passages] = sys.passages
        end
      end

      if @map_infos[mp_id].overlay_2ndLayer?
        for xi in 0..da[:map].data.xsize
          for yi in 0..da[:map].data.ysize
            da[:map].data[xi, yi, 0] = 0 if da[:map].data[xi, yi, 1].to_i > 0
          end
        end
      end

      if @map_infos[mp_id].negates_1stLayer?
        for xi in 0..da[:map].data.xsize
          for yi in 0..da[:map].data.ysize
            da[:map].data[xi, yi, 0] = 0
          end
        end
      end
      @iex_layer_maps.push(da.clone)
      da.clear
    end

  end

end

#==============================================================================#
# ** Spriteset_Map
#==============================================================================#
class Spriteset_Map
  #--------------------------------------------------------------------------#
  # * Constant(s)
  #--------------------------------------------------------------------------#
  NO_TONE = Tone.new(0, 0, 0, 0)

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :iex_map_lay_spm_initialize :initialize unless $@
  def initialize( *args, &block )
    @active_layer_maps = []
    @iex_ml_viewports = []
    @iex_tone_viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @iex_tone_viewport.z = IEX::MapLayering::TONE_VIEWPORT_Z
    create_layer_maps
    iex_map_lay_spm_initialize(*args, &block)
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_layer_maps
  #--------------------------------------------------------------------------#
  def create_layer_maps
    @active_layer_maps = []
    coun = 1
    for mhsh in $game_map.iex_layer_maps
      next if mhsh.nil?
      coun += 1
      view = Viewport.new(0, 0, Graphics.width, Graphics.height)
      view.z = IEX::MapLayering::LAYERS_ADD_Z + coun
      @iex_ml_viewports.push( view )
      tilemap = Tilemap.new( view )
      tiledata = mhsh[:tile_info]
      if tiledata["A1"] == "empty::*::"
        tilemap.bitmaps[0] = Cache.system("TileA1")
      else
        tile1 = Cache_Swap_Tiles.swap(tiledata["A1"] + ".png") rescue nil
        tilemap.bitmaps[0] = tile1 if tiledata["A1"] != nil
      end
      if tiledata["A2"] == "empty::*::"
        tilemap.bitmaps[1] = Cache.system("TileA2")
      else
        tile2 = Cache_Swap_Tiles.swap(tiledata["A2"] + ".png") rescue nil
        tilemap.bitmaps[1] = tile2 if tiledata["A2"] != nil
      end
      if tiledata["A3"] == "empty::*::"
        tilemap.bitmaps[2] = Cache.system("TileA3")
      else
        tile3 = Cache_Swap_Tiles.swap(tiledata["A3"] + ".png") rescue nil
        tilemap.bitmaps[2] = tile3 if tiledata["A3"] != nil
      end
      if tiledata["A4"] == "empty::*::"
        tilemap.bitmaps[3] = Cache.system("TileA4")
      else
        tile4 = Cache_Swap_Tiles.swap(tiledata["A4"] + ".png") rescue nil
        tilemap.bitmaps[3] = tile4 if tiledata["A4"] != nil
      end
      if tiledata["A5"] == "empty::*::"
        tilemap.bitmaps[4] = Cache.system("TileA5")
      else
        tile5 = Cache_Swap_Tiles.swap(tiledata["A5"] + ".png") rescue nil
        tilemap.bitmaps[4] = tile5 if tiledata["A5"] != nil
      end
      if tiledata["B"] == "empty::*::"
        tilemap.bitmaps[5] = Cache.system("TileB")
      else
        tile6 = Cache_Swap_Tiles.swap(tiledata["B"] + ".png") rescue nil
        tilemap.bitmaps[5] = tile6 if tiledata["B"] != nil
      end
      if tiledata["C"] == "empty::*::"
        tilemap.bitmaps[6] = Cache.system("TileC")
      else
        tile7 = Cache_Swap_Tiles.swap(tiledata["C"] + ".png") rescue nil
        tilemap.bitmaps[6] = tile7 if tiledata["C"] != nil
      end
      if tiledata["D"] == "empty::*::"
        tilemap.bitmaps[7] = Cache.system("TileD")
      else
        tile8 = Cache_Swap_Tiles.swap(tiledata["D"] + ".png") rescue nil
        tilemap.bitmaps[7] = tile8 if tiledata["D"] != nil
      end
      if tiledata["E"] == "empty::*::"
        tilemap.bitmaps[8] = Cache.system("TileE")
      else
        tile9 = Cache_Swap_Tiles.swap(tiledata["E"] + ".png") rescue nil
        tilemap.bitmaps[8] = tile9 if tiledata["E"] != nil
      end
      tilemap.map_data = mhsh[:map].data
      tilemap.passages = mhsh[:passages]
      @active_layer_maps.push( tilemap )
    end
  end

  #--------------------------------------------------------------------------#
  # * alias-method :dispose
  #--------------------------------------------------------------------------#
  alias :iex_map_lay_spm_dispose :dispose unless $@
  def dispose
    iex_map_lay_spm_dispose
    @iex_tone_viewport.dispose
    @active_layer_maps.each(&:dispose)
    @iex_ml_viewports.each(&:dispose)
    @active_layer_maps = nil
    @iex_ml_viewports = nil
    @iex_tone_viewport = nil
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :iex_map_lay_spm_update :update unless $@
  def update
    update_layer_viewports
    update_layer_tilemaps
    iex_map_lay_spm_update
  end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
  def update_layer_viewports
    @viewport1.tone = NO_TONE
    @iex_tone_viewport.tone = $game_map.screen.tone
    @iex_tone_viewport.update
    for view in @iex_ml_viewports
      view.tone = NO_TONE
      view.ox = @viewport1.ox
      view.oy = @viewport1.oy
      view.update
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_layer_tilemaps
  #--------------------------------------------------------------------------#
  def update_layer_tilemaps
    for tmp in @active_layer_maps
      tmp.ox = @tilemap.ox
      tmp.oy = @tilemap.oy
      tmp.update
    end
  end
end

#==============================================================================#
# ** END OF FILE
#==============================================================================#
