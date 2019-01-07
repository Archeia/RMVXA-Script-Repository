=begin
#===============================================================================
 Title: Map Regions
 Author: Hime
 Date: Apr 24, 2015
 URL: http://himeworks.com/2014/02/17/map-regions/
--------------------------------------------------------------------------------
 ** Change log
 Apr 24, 2015
   - BGM does not replay if new region has the same name
 Apr 4, 2015
   - supports filenames with quotes
 Jun 16, 2014
   - added support for calling common events on region change
 Feb 17, 2014
   - initial release
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
 
 This script allows you to separate your map into separate "map regions".
 
 Each region can be treated as a separate section of the map, with their own
 names, music, and battlebacks.
 
 When you move from one region to another, the new region's name will be
 used and the new region's music will be played.
 
--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, install this script below Materisls and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 To create a map region, note-tag the map with
 
   <map region: ID>
       name: REGION NAME
     bback1: FILENAME
     bback2: FILENAME
        bgm: FILENAME VOLUME PITCH
        bgs: FILENAME VOLUME PITCH
       fade: DURATION
  common_event: ID
   </map region>
   
 The following options are available. You do not need to include all of them.
 
     name - the name of the region
   bback1 - name of the file for the floor battleback
   bback2 - name of the file for the wall battleback
     bgm  - the BGM to play when you move into this region
     bgs  - the BGS to play when you move into this region
     fade - the fade duration for the previous BGM before the next one begins
  common_event - ID of the common event to execute
 
 When a region name is specified, the name of the map is changed to the region
 name. The map name window will also be shown automatically when you move into
 a new region.
 
 To enable region battlebacks, you need to first check the "specify battleback"
 box for the map.
 
 You can specify the volume and pitch of the music files if needed.
 These are specified as percentages, where 100 means 100% volume/pitch, and
 50 means 50% volume/pitch. If your filename has spaces, you can surround the
 name with quotes such as this
 
   "my music file"
 
 The fade duration is specified in milliseconds. Therefore, if you want the
 music to fade out for a second, you would write 1000.
 
--------------------------------------------------------------------------------
 ** Example
 
 Here's map region 10 with the name "Grassland", using Theme1 as the BGM, and a
 Storm BGS with a lowered volume:
 
   <map region: 10>
     name: Grassland
     bgm: Theme1
     bgs: Storm 50
   </map region>
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_MapRegions] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Map_Regions
    
    Ext_Regex = /<map[-_ ]region:\s*(\d+)>(.*?)<\/map[-_ ]region>/im
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  class Map
    
    def map_regions
      load_notetag_map_regions unless @map_regions
      return @map_regions
    end
    
    def load_notetag_map_regions
      @map_regions = {}
      results = self.note.scan(TH::Map_Regions::Ext_Regex)
      results.each do |res|
        id = res[0].to_i
        obj = Data_MapRegion.new(id)
        res[1].strip.split("\r\n").each do |line|
          case line
          when /name:\s*(.*)\s*/i
            obj.name = $1
          when /bback1:\s*(.*)\s*/i
            obj.battleback1_name = $1
          when /bback2:\s*(.*)\s*/i
            obj.battleback2_name = $1
          when /bgm:\s*(".+?"|\w+)\s*(\d+)?\s*(\d+)?/i
            obj.bgm = RPG::BGM.new($1.gsub('"', ""))
            obj.bgm.volume = $2.to_i if $2
            obj.bgm.pitch = $3.to_i if $3
          when /bgs:\s*(".+?"|\w+)\s*(\d+)?\s*(\d+)?/i
            obj.bgs = RPG::BGS.new($1)
            obj.bgs.volume = $2.to_i if $2
            obj.bgs.pitch = $3.to_i if $3
          when /fade:\s*(\d+)\s*/i
            obj.fade_duration = $1.to_i
          when /common[-_ ]event:\s*(\d+)\s*/im
            obj.common_event_id = $1.to_i
          end
        end
        @map_regions[id] = obj
      end
    end
  end
end

class Data_MapRegion
  attr_accessor :id
  attr_accessor :name
  attr_accessor :battleback1_name
  attr_accessor :battleback2_name
  attr_accessor :bgm
  attr_accessor :bgs
  attr_accessor :fade_duration
  attr_accessor :common_event_id
  
  def initialize(region_id)
    @id = region_id
    @name = ""
    @battleback1_name = ""
    @battleback2_name = ""
    @bgm = RPG::BGM.new
    @bgs = RPG::BGS.new
    @fade_duration = 0
    @common_event_id = 0
  end
end

class Game_Map
  attr_reader :region_name
  attr_reader :region_data
  
  alias :th_map_regions_display_name :display_name
  def display_name
    @region_name ? @region_name : th_map_regions_display_name
  end
  
  def update_region_location(r_id)
    data = @map.map_regions[r_id]
    return unless data
    update_region_music(data)
    update_region_name(data)
    update_battlebacks(data)
    update_script_call(data)
    @region_data = data
  end
  
  def update_region_music(data)
    return if @region_data && @region_data.bgm.name == data.bgm.name
    t = Thread.new {
      duration = data.fade_duration
      RPG::BGM.fade(duration)
      RPG::BGS.fade(duration)
      sleep(duration / 1000.0) # does not take into consideration frame rate
      data.bgm.play 
      data.bgs.play
    }
  end
  
  def update_region_name(data)
    @region_name = data.name
  end
  
  def update_battlebacks(data)    
    @battleback1_name = data.battleback1_name unless data.battleback1_name.empty?
    @battleback2_name = data.battleback2_name unless data.battleback2_name.empty?
  end
  
  def update_script_call(data)
    $game_temp.reserve_common_event(data.common_event_id)
  end
end

class Game_Player < Game_Character
  
  attr_reader :last_region_id
  
  def region_changed?(r_id)
    r_id != 0 && @last_region_id != r_id
  end
  
  alias :th_map_regions_update :update
  def update
    r_id = self.region_id
    @last_region_id = r_id unless r_id == 0
    th_map_regions_update
  end
end

class Scene_Map < Scene_Base 
  
  alias :th_map_regions_update :update
  def update
    update_region_change unless scene_changing?
    th_map_regions_update
  end
  
  def update_region_change
    r_id = $game_player.region_id
    if $game_player.region_changed?(r_id)
      $game_map.update_region_location(r_id)
      @map_name_window.open
    end
  end
end