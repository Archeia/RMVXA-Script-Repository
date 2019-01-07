=begin
#===============================================================================
 Title: Region Fog
 Author: Hime
 Date: Apr 18, 2014
--------------------------------------------------------------------------------
 ** Change log
 Apr 18, 2014
   - fixed crash issue when region fog was not created
 Sep 3, 2013
   - properly disposes region fog
   - added support for custom fog tiles
   - introduced extended note-tag
 Sep 1, 2013
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to control fog of war using region tiles. 
 Each map can assign multiple different regions of fog. Different fog regions
 are separate from one another.
 
 Script calls are used to show or hide region fog.

--------------------------------------------------------------------------------
 ** Required
 
 Script: Bit Switches
 (http://himeworks.com/2013/06/07/bit-switches/)
 
 Image: region_fog_tileset
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Bit Switches and above Main.
 Place the "region_fog_tileset" image into your Graphics/System folder

--------------------------------------------------------------------------------
 ** Usage
 
 The simple note-tag allows you to specify all of the region fogs and their
 switches in the same tag:
 
   <region fog>
   region: x1, switch: y1
   region: x2, switch: y2
   </region fog>
   
 Where x and y are numbers. You can assign the same switch to multiple regions,
 across different maps as well.
 
 If you require more advanced options, or don't want to use all of the options
 available, use the extended note-tag as follows:
 
   <region fog: 2>
     switch: 2
     tile: 1
   </region fog>
   
 Which will designate region 2 as a region fog, whose visibility is based on
 bit-switch 2, and uses tile 1.
 
 -- Using custom tiles --
 
 By default, the fog tile you get is black. If you look at the
 region_fog_tileset image, you will see a 32x32 black square near the top-left.
 
 Each tile has an ID. The top-left tile is tile 0, which is no fog.
 The one next to it is tile 1, which is the default black fog. You can add your
 own fog tiles as well, and reference in the extended note-tag if you want
 specific regions to use specific fog tiles. 
 
 -- Changing fog visibility --
  
 To show or hide the a region fog, you will need to change the value of the
 switch. These are bit switches, so you won't be able to use the "Control
 Switches" event command to change them.
 
 To hide the fog, make the script call
 
   hide_region_fog(switch_id)
   
 To show the fog, make the script call
 
   show_region_fog(switch_id)
   
--------------------------------------------------------------------------------
 ** Example
 
 Here's a sample region fog setup:
 
   <region fog>
     region: 1, switch: 1
     region: 2, switch: 2
     region: 3, switch: 1
   </region fog>
   
 This means that the fog for regions 1 and 3 use the same bitswitch.
 If you called
 
   hide_region_fog(1)
   
 This would hide the fog for both region 1 and region 3.

#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_RegionFog"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Region_Fog
    
    # Variable that will store the region fog settings
    Var_ID = 1
#===============================================================================
# ** Rest of Script
#===============================================================================    
    Regex = /<region[-_ ]fog>(.*?)<\/region[-_ ]fog>/im
    Data_Regex = /region:\s*(\d+)\s*,\s*switch:\s*(\d+)/
    
    Ext_Regex = /<region[-_ ]fog:\s*(\d+)\s*>(.*?)<\/region[-_ ]fog>/im
  end
end

module RPG
  class Map
    
    def fog_regions
      load_notetag_region_fog unless @fog_regions
      return @fog_regions
    end
    
    def load_notetag_region_fog
      @fog_regions = {}
      res = self.note.match(TH::Region_Fog::Regex)
      if res
        res[1].strip.split("\r\n").each do |data|
          data =~ TH::Region_Fog::Data_Regex
          region_id = $1.to_i
          switch_id = $2.to_i
          
          fogData = Data_RegionFog.new(region_id)
          fogData.switch_id = switch_id
          @fog_regions[region_id] = fogData
        end
      end
        
      res = self.note.scan(TH::Region_Fog::Ext_Regex)
      res.each do |data|
        region_id = data[0].to_i
        switch_id = 0
        tile_id = 1
        data[1].split("\r\n").each do |option|
          if option =~ /switch:\s*(\d+)/i
            switch_id = $1.to_i
          elsif option =~ /tile:\s*(\d+)/i
            tile_id = $1.to_i
          end
        end
        fogData = Data_RegionFog.new(region_id)
        fogData.switch_id = switch_id
        fogData.tile_id = tile_id
        @fog_regions[region_id] = fogData
      end
    end
  end
end

class Data_RegionFog
  
  attr_accessor :region_id
  attr_accessor :switch_id
  attr_accessor :tile_id
  
  def initialize(region_id)
    @region_id = region_id
    @switch_id = 0
    @tile_id = 1
  end
end

class Game_Interpreter
  
  def show_region_fog(switch_id)
    $game_map.change_region_fog(switch_id, false)
  end
  
  def hide_region_fog(switch_id)
    $game_map.change_region_fog(switch_id, true)
  end
end

class Game_Map
  include TH::Bit_Switches
  
  attr_reader :region_fog
  
  alias :th_region_fog_setup :setup
  def setup(map_id)
    @region_fog_cache = {}
    th_region_fog_setup(map_id)
    setup_region_fog
  end
  
  alias :th_region_fog_refresh :refresh
  def refresh
    update_region_fogs
    th_region_fog_refresh
  end
  
  def setup_region_fog
    @region_fog = Table.new(data.xsize, data.ysize, data.zsize)
    build_region_cache
    update_region_fogs
  end
  
  #-----------------------------------------------------------------------------
  # Pre-compute all of the tiles that need to be updated for a given region
  # so we don't need to do this everytime
  #-----------------------------------------------------------------------------
  def build_region_cache
    for x in 0...@region_fog.xsize
      for y in 0...@region_fog.ysize
        rid = region_id(x, y)
        if rid > 0
          @region_fog_cache[rid] = [] unless @region_fog_cache[rid]
          @region_fog_cache[rid] << [x,y]
        end
      end
    end
  end
  
  def update_region_fogs
    @map.fog_regions.each do |region_id, fogData|
      update_region_fog(region_id, fogData)
    end
  end
  
  def update_region_fog(region_id, fogData)
    val = bit_switch?(TH::Region_Fog::Var_ID, fogData.switch_id)
    tile_id = val ? 0 : fogData.tile_id
    return unless @region_fog_cache[region_id]
    @region_fog_cache[region_id].each do |(x,y)|
      @region_fog[x, y, 2] = tile_id
    end
  end
  
  #-----------------------------------------------------------------------------
  # Get the bitswitch assigned to this region
  #-----------------------------------------------------------------------------
  def get_fog_bitswitch(region_id)
    @map.fog_regions[region_id]
  end
  
  #-----------------------------------------------------------------------------
  # Show or hide the fog for the given region
  #-----------------------------------------------------------------------------
  def change_region_fog(switch_id, val)
    set_bit_switch(TH::Region_Fog::Var_ID, switch_id, val)
  end
end

class Spriteset_Map
  
  alias :th_region_fog_create_tilemap :create_tilemap
  def create_tilemap
    th_region_fog_create_tilemap
    create_region_fog
  end
  
  def create_region_fog
    @region_fog = Tilemap.new(@viewport2)
    @region_fog.map_data = $game_map.region_fog
    load_region_tileset
  end
  
  def load_region_tileset
    @region_fog.bitmaps[5] = Cache.system("region_fog_tileset")
  end
  
  alias :th_region_fog_update :update
  def update
    th_region_fog_update
    update_region_fog if @region_fog
  end
  
  def update_region_fog
    @region_fog.map_data = $game_map.region_fog
    @region_fog.ox = $game_map.display_x * 32
    @region_fog.oy = $game_map.display_y * 32
    @region_fog.update
  end
  
  alias :th_region_fog_dispose :dispose
  def dispose
    th_region_fog_dispose
    dispose_region_fog
  end
  
  def dispose_region_fog
    @region_fog.dispose if @region_fog
  end
end