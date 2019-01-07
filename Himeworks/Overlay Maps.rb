=begin
#===============================================================================
 Title: Overlay Maps
 Author: Tsukihime
 Date: Jul 24, 2015
--------------------------------------------------------------------------------
 ** Change log
 Jul 24, 2015
   - fixed bug where character sprites are not disposed properly
 Jan 29, 2015
   - overlay map class now makes super calls
 Jan 2, 2015
   - fixed bug where parallax image wasn't showing up after transfer
 Jul 22, 2014
   - fixed bug where overlay maps were not properly refreshed when data changes
   - removed overlay map weather. There only weather available is on the
     current map, which will be applied to all layers
 Jul 20, 2014
   - fixed weather sync effects
 Dec 13, 2013
   - fixed stack overflow bug
 Oct 23, 2013
   - cleaned up weird code in Game_Map and Game_OverlayMap
 Oct 6, 2013
   - fixed bug where vehicles were drawn on overlay maps
   - fixed bug where airship shadow was drawn over an upper layer
 Aug 19, 2013
   - fixed bug where game map was disposed twice, causing various problems
 Jul 27, 2013
   - fixed bug where parallax map was not drawn after transferring
 Jun 5, 2013
   - fixed bug in compact regex
 Apr 9, 2013
   - refactored options into their own structure
 Mar 31, 2013
   - added overlay map opacity settings.
 Mar 27, 2013
   - added extended note-tag format
   - added support for overlay zooming add-on
 Mar 19, 2013
   - implemented map looping fix: maps will no longer loop automatically
   - added overlay map synchronization
 Mar 16, 2013
   - fixed overlay screen (shake, weather) effects
   - fixed parallax map
 Mar 15, 2013
   - added overlay map offsetting
   - added "scroll rate" for overlay maps
 Mar 14, 2013
   - fixed bug where sprites aren't drawn correctly on large maps
   - added support for layer ordering
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Tsukihime in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to create "overlay maps" on top of each other.
 Overlay maps allow you to create much more visually attractive maps since
 you now have control over different "layers", though these are only visual
 effects.
 
 An overlay map is just another map, except it is drawn over your current
 map. The overlay map comes with the following properties
 
 - It does not need to use the same tileset as your current map.
   This means you can merge multiple tilesets together in a single map

 - Events on the overlay map are processed in the current map, although you
   are still not able to reference events from different maps.

 - The player is unable to directly interact with the overlay map, or
   anything on the overlay map.

 - The player, however, can indirectly interact with events on the overlay
   map by setting switches or variables that will trigger the events.

 - To transfer between layers, you must use player transfer events

 - Map layers can re-use each other, so if one map uses another map
   as the top layer, then that map can use the previous map as the bottom layer
   
 - Each overlay map can have its own screen effects (weather, shaking, flashing)
   and zoom factor

You can have an unlimited number of overlay maps.
   
 A single map can contain multiple overlay maps.
--------------------------------------------------------------------------------
 ** Usage
 
 Place this script below Materials and above Main.
 
 There are two types of note-tags: compact, and extended.
 The compact note-tag is short and easy to type, but the extended note-tag
 is probably better for organization. Note that the compact note-tag
 is deprecated and will not support any additional options that may be
 added in the future.
 
 To assign overlay maps to a map, tag the map with

 Compact:
   
    <overlay map: map order ox oy scroll_rate sync zoom>
    
 Extended
 
    <overlay map>
      map: x
      order: x
      offset: ox oy
      scrollrate: x
      sync: 0/1
      zoom: x
      opacity: x
    </overlay map>
   
 The map is the ID of the map that will be drawn as an overlay.
 
 The order determines whether it will be drawn above or below the current map.
 If it is negative, then it will be drawn under.
 If it is positive, then it will be drawn over.
 If it is not specified, then it assumes to be over, in the order that the
 tags are specified.
 
 ox and oy determine the offset of the origin. By default, the map's origin
 is drawn at (ox = 0, oy = 0), but you can change this if necessary.
   Positive x-values shift it right.
   Negative x-values shift it to the left. 
   Positive y-values shift it down.
   Negative y-values shift it up.
 
 The scroll rate specifies how fast the overlay map scrolls per step taken.
 The default scroll rate is 32, which means it will scroll
 32 pixels per move, or basically one tile. Higher scroll rates mean the
 overlay map will scroll faster for each step you take, while slower scroll
 rates results in less scrolling for each step you take.
 
 Sync specifies whether the overlay map is synchronized with the current
 map. This means that any screen effects such as shaking or weather will affect
 the overlay map as well.
   0 = not synchronized
   1 = synchronized
   
 The zoom value is a special option if you have installed the Overlay Map Zoom
 script. Refer to that script for more details.
 
 The opacity value specifies the opacity of the overlay map.
 
 You can have multiple overlay maps by simply adding
 more tags. Note that the order they are drawn depends on the order you tag
 them.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_OverlayMaps"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Overlay_Maps
    Regex = /<overlay[-_ ]map: (\d+)\s*(-?\d+)?\s*(-?\d+)?\s*(-?\d+)?\s*(\d+)?\s*(\d+)?\s*([\d.]+)?>/im
    ExtRegex = /<overlay[-_ ]map>(.*?)<\/overlay[-_ ]map>/im
    
    class Data
      attr_accessor :map_id
      attr_accessor :order
      attr_accessor :offset_x
      attr_accessor :offset_y
      attr_accessor :scroll_rate
      attr_accessor :synchronized
      attr_accessor :zoom
      attr_accessor :opacity
      
      def initialize
        @map_id = 0
        @order = 1
        @offset_x = 0
        @offset_y = 0
        @scroll_rate = 32
        @synchronized = true
        @zoom = 1.0
        @opacity = 255
      end
    end
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================

module RPG
  class Map
    
    def overlay_maps
      return @overlay_maps unless @overlays_maps.nil?
      load_notetag_overlay_maps
      return @overlay_maps
    end    
    
    def load_notetag_overlay_maps
      @overlay_maps = []
      
      # load compact notes
      res = self.note.scan(TH::Overlay_Maps::Regex)
      res.each {|result|
        data = TH::Overlay_Maps::Data.new
        data.map_id = result[0].to_i
        data.order = result[1] ? result[1].to_i : 1
        data.offset_x = result[2] ? result[2].to_i : 0
        data.offset_y = result[3] ? result[3].to_i : 0
        data.scroll_rate = result[4] ? result[4].to_i : 32
        data.synchronized = result[5] ? result[5].to_i != 0 : true
        data.zoom = result[6] ? result[6].to_f : 1
        @overlay_maps.push(data)
      }
      # load extended notes
      res = self.note.scan(TH::Overlay_Maps::ExtRegex)
      res.each {|result|
        map_data = load_options_overlay_maps(result[0].strip.split("\r\n"))
        @overlay_maps.push(map_data)
      }
    end
    
    #---------------------------------------------------------------------------
    # Given a list of options, parse the options and return a list of
    # arguments
    #---------------------------------------------------------------------------
    def load_options_overlay_maps(options)
      # load defaults
      data = TH::Overlay_Maps::Data.new
      # parse options
      options.each {|option|        
        name, value = option.split(":")
        value = value.strip
        case name.strip.downcase
        when "map"
          data.map_id = value.to_i
        when "order"
          data.order = value.to_i
        when "offset"
          data.offset_x, data.offset_y = value.split.map{|x| x.to_i}
        when "sync"
          data.synchronized = value == "true" || value == "1"
        when "scrollrate"
          data.scroll_rate = value.to_i
        when "zoom"
          data.zoom = value.to_f
        when "opacity"
          data.opacity = value.to_f
        end
      }
      return data
    end
  end
end

class Game_Map
  attr_reader :overlay_maps
  
  alias :th_overlay_maps_initialize :initialize
  def initialize
    th_overlay_maps_initialize
    @overlay_maps = []
  end
  
  alias :th_overlay_maps_setup :setup
  def setup(map_id)
    th_overlay_maps_setup(map_id)
    setup_overlay_maps
  end
  
  def setup_overlay_maps
    @overlay_maps = []
    @map.overlay_maps.each {|overlayData|
      map = Game_OverlayMap.new
      map.setup(overlayData)
      @overlay_maps.push(map)
    }
  end
  
  alias :th_overlay_maps_update :update
  def update(main = false)
    th_overlay_maps_update(main)
    update_overlay_maps
  end
  
  def update_overlay_maps
    @overlay_maps.each {|map| map.update}
  end
  
  alias :th_overlay_maps_refresh :refresh
  def refresh
    th_overlay_maps_refresh
    @overlay_maps.each {|map| map.refresh }
  end
end

#-------------------------------------------------------------------------------
# The overlay map class. It is a game map, but it holds overlay map objects
# that the player cannot interact with. All overlay map objects interact
# with the map it is created on
#-------------------------------------------------------------------------------
class Game_OverlayMap < Game_Map
  attr_reader :order           # layer order
  attr_reader :synchronized    # shares same screen as current map
  attr_reader :scroll_rate     # pixels to scroll per frame
  attr_reader :offset_x
  attr_reader :offset_y         
  attr_reader :zoom
  attr_reader :opacity
  
  #-----------------------------------------------------------------------------
  # Don't create overlay maps for overlay maps...
  #-----------------------------------------------------------------------------
  def setup(data)
    @order = data.order
    @offset_x = data.offset_x
    @offset_y = data.offset_y
    @synchronized = data.synchronized
    @opacity = data.opacity
    @scroll_rate = data.scroll_rate
    @zoom = data.zoom
    th_overlay_maps_setup(data.map_id)
    @screen = Game_Screen.new
    @interpreter = Game_OverlayInterpreter.new(self)
  end
  
  def update(main=false)
    th_overlay_maps_update(main)
  end
  
  def vehicles
    @vehicles.select {|veh|
      veh.instance_variable_get(:@map_id) == @map_id 
    }
  end
  
  #-----------------------------------------------------------------------------
  # Create overlay events
  #-----------------------------------------------------------------------------
  def setup_events
    @events = {}
    @map.events.each do |i, event|
      @events[i] = Game_OverlayEvent.new(@map_id, event, self)
    end
    @common_events = parallel_common_events.collect do |common_event|
      Game_CommonEvent.new(common_event.id)
    end
    refresh_tile_events
  end
end

#-------------------------------------------------------------------------------
# Events that are drawn on overlay maps. All passage settings should be based
# on the map they are drawn on
#-------------------------------------------------------------------------------
class Game_OverlayEvent < Game_Event
  
  def initialize(map_id, event, map)
    @map = map
    super(map_id, event)
    @opacity = map.opacity
  end
  
  def near_the_screen?(dx = 12, dy = 8)
    ax = $game_map.adjust_x(@real_x) - Graphics.width / 2 / 32
    ay = $game_map.adjust_y(@real_y) - Graphics.height / 2 / 32
    ax >= -dx && ax <= dx && ay >= -dy && ay <= dy
  end
  
  def passable?(x, y, d)
    x2 = @map.round_x_with_direction(x, d)
    y2 = @map.round_y_with_direction(y, d)
    return false unless @map.valid?(x2, y2)
    return true if @through || debug_through?
    return false unless map_passable?(x, y, d)
    return false unless map_passable?(x2, y2, reverse_dir(d))
    return false if collide_with_characters?(x2, y2)
    return true
  end
  
  def diagonal_passable?(x, y, horz, vert)
    x2 = @map.round_x_with_direction(x, horz)
    y2 = @map.round_y_with_direction(y, vert)
    (passable?(x, y, vert) && passable?(x, y2, horz)) ||
    (passable?(x, y, horz) && passable?(x2, y, vert))
  end
  
  def map_passable?(x, y, d)
    @map.passable?(x, y, d)
  end
  
  def collide_with_events?(x, y)
    @map.events_xy_nt(x, y).any? do |event|
      event.normal_priority? || self.is_a?(Game_Event)
    end
  end
  
  def collide_with_vehicles?(x, y)
    @map.boat.pos_nt?(x, y) || $game_map.ship.pos_nt?(x, y)
  end
  
  def moveto(x, y)
    @x = x % @map.width
    @y = y % @map.height
    @real_x = @x
    @real_y = @y
    @prelock_direction = 0
    straighten
    update_bush_depth
  end
  
  def screen_x
    @map.adjust_x(@real_x) * 32
  end
  
  def screen_y
    @map.adjust_y(@real_y) * 32 - shift_y - jump_height
  end
  
  def ladder?
    @map.ladder?(@x, @y)
  end
  
  def bush?
    @map.bush?(@x, @y)
  end
  
  def terrain_tag
    @map.terrain_tag(@x, @y)
  end
  
  def region_id
    @map.region_id(@x, @y)
  end
  
  def check_event_trigger_touch_front
    x2 = @map.round_x_with_direction(@x, @direction)
    y2 = @map.round_y_with_direction(@y, @direction)
    check_event_trigger_touch(x2, y2)
  end
  
  def move_straight(d, turn_ok = true)
    @move_succeed = passable?(@x, @y, d)
    if @move_succeed
      set_direction(d)
      @x = @map.round_x_with_direction(@x, d)
      @y = @map.round_y_with_direction(@y, d)
      @real_x = @map.x_with_direction(@x, reverse_dir(d))
      @real_y = @map.y_with_direction(@y, reverse_dir(d))
      increase_steps
    elsif turn_ok
      set_direction(d)
      check_event_trigger_touch_front
    end
  end
  
  def move_diagonal(horz, vert)
    @move_succeed = diagonal_passable?(x, y, horz, vert)
    if @move_succeed
      @x = @map.round_x_with_direction(@x, horz)
      @y = @map.round_y_with_direction(@y, vert)
      @real_x = @map.x_with_direction(@x, reverse_dir(horz))
      @real_y = @map.y_with_direction(@y, reverse_dir(vert))
      increase_steps
    end
    set_direction(horz) if @direction == reverse_dir(horz)
    set_direction(vert) if @direction == reverse_dir(vert)
  end
  
  #-----------------------------------------------------------------------------
  # Overlay events use an overlay interpreter
  #-----------------------------------------------------------------------------
  def setup_page_settings
    super
    @interpreter = @trigger == 4 ? Game_OverlayInterpreter.new(@map) : nil
  end
end

#-------------------------------------------------------------------------------
# This interpreter is used by overlay events and maps. It holds a reference to
# the appropriate overlay map
#-------------------------------------------------------------------------------
class Game_OverlayInterpreter < Game_Interpreter
  
  def initialize(map, depth = 0)
    @map = map
    super(depth)
  end
  
  def screen
    $game_party.in_battle ? $game_troop.screen : @map.screen
  end
  
  def command_117
    common_event = $data_common_events[@params[0]]
    if common_event
      child = Game_OverlayInterpreter.new(@map, @depth + 1)
      child.setup(common_event.list, same_map? ? @event_id : 0)
      child.run
    end
  end
end

class Spriteset_Map
  
  #-----------------------------------------------------------------------------
  # Instead of having a weather sprite for every layer, we assume that there
  # can only be one weather, which is defined by the current map. Therefore,
  # draw the weather on its own viewport and push the viewport to the very
  # top
  #-----------------------------------------------------------------------------
  def create_weather
    return unless @map_id == $game_map.map_id
    @weather_viewport = Viewport.new    
    @weather_viewport.z = $game_map.overlay_maps.size > 0 ? $game_map.overlay_maps.max {|map| map.order }.order * 100 + 50 : 50
    @weather = Spriteset_Weather.new(@weather_viewport)
  end
  
  def dispose_weather
    @weather.dispose
    @weather_viewport.dispose
  end
end

#-------------------------------------------------------------------------------
# The overlay map spriteset. Same as the map spriteset, except it holds a 
# reference to a specific overlay map and retrieves all valus from it.
#-------------------------------------------------------------------------------
class Spriteset_OverlayMap < Spriteset_Map
  
  def initialize(map)
    @tile_ratio = 32.0 / map.scroll_rate
    @zoom_ratio = map.zoom >= 1 ? map.zoom : 1.0 / map.zoom
    @screen_width = Graphics.width / map.scroll_rate
    @screen_height = Graphics.height / map.scroll_rate
    @offset_x = map.offset_x
    @offset_y = map.offset_y
    @opacity = map.opacity
    @map_id = map.map_id
    @map = map
    super()
  end
  
  #-----------------------------------------------------------------------------
  # Custom viewport ordering scheme
  #-----------------------------------------------------------------------------
  def create_viewports
    super
    @viewport1.z = 0 + (100 * @map.order)
    @viewport2.z = 50 + (100 * @map.order)
    @viewport3.z = 100 + (100 * @map.order)
  end
  
  def create_tilemap
    super
    @tilemap.map_data = @map.data
  end
  
  def load_tileset
    @tileset = @map.tileset
    @tileset.tileset_names.each_with_index do |name, i|
      if $imported["TH_OverlayZooming"]
        @tilemap.bitmaps[i] = Cache.tileset(name)
      else
        bmp = Cache.tileset(name)
        @tilemap.bitmaps[i] = Bitmap.new(bmp.width, bmp.height)
        @tilemap.bitmaps[i].blt(0, 0, bmp, bmp.rect, @map.opacity)
      end
    end
    @tilemap.flags = @tileset.flags
  end
  
  def create_characters
    super
    
    # Delete all existing character sprites. We don't care about $game_map
    dispose_characters
    
    @character_sprites = []
    @map.events.values.each do |event|
      @character_sprites.push(Sprite_Character.new(@viewport1, event))
    end
    @map.vehicles.each do |vehicle|
      @character_sprites.push(Sprite_Character.new(@viewport1, vehicle))
    end
  end

  def update_tileset
    if @tileset != @map.tileset
      load_tileset
      refresh_characters
    end
  end
  
  def dispose_characters
    @character_sprites.each {|sprite| sprite.dispose }
  end
  
  def update_characters
    super
    @character_sprites.each {|sprite|
      sprite.ox = ($game_map.display_x + @offset_x) * @map.scroll_rate
      sprite.oy = ($game_map.display_y + @offset_y) * @map.scroll_rate
    }
  end
  
  def update_tilemap
    @tilemap.map_data = @map.data
    @tilemap.ox = ($game_map.display_x + @offset_x) * @map.scroll_rate
    @tilemap.oy = ($game_map.display_y + @offset_y) * @map.scroll_rate
    @tilemap.update    
  end
  
  def create_weather
  end
  
  # Overlay maps do not have any weather settings
  def update_weather
    #if @map.synchronized
    #  @weather.type = $game_map.screen.weather_type
    #  @weather.power = $game_map.screen.weather_power
    #else
    #  @weather.type = @map.screen.weather_type
    #  @weather.power = @map.screen.weather_power
    #end
    #@weather.ox = $game_map.display_x * 32
    #@weather.oy = $game_map.display_y * 32
    #@weather.update
  end
  
  def dispose_weather
  end
  
  #-----------------------------------------------------------------------------
  # Get parallax name from the associated overlay map
  #-----------------------------------------------------------------------------
  def update_parallax
    if @parallax_name != @map.parallax_name
      @parallax_name = @map.parallax_name
      @parallax.bitmap.dispose if @parallax.bitmap
      @parallax.bitmap = Cache.parallax(@parallax_name).clone
    end
    
    # not sure why I need to check this now
    unless @parallax.bitmap.disposed?    
      @parallax.ox = @map.parallax_ox(@parallax.bitmap)
      @parallax.oy = @map.parallax_oy(@parallax.bitmap)
    end
  end
  
  alias :th_overlay_maps_update_shadow :update_shadow
  def update_shadow
    return if @map.order > 0
    th_overlay_maps_update_shadow
  end
  
  #-----------------------------------------------------------------------------
  # Overwrite.
  #-----------------------------------------------------------------------------
  def update_viewports
    update_sliding_viewports
    if @map.synchronized
      @viewport1.tone.set($game_map.screen.tone)
      @viewport1.ox += $game_map.screen.shake
      @viewport2.color.set($game_map.screen.flash_color)
      @viewport3.color.set(0, 0, 0, 255 - @map.screen.brightness)
    else
      @viewport1.tone.set(@map.screen.tone)
      @viewport1.ox += @map.screen.shake
      @viewport2.color.set(@map.screen.flash_color)
      @viewport3.color.set(0, 0, 0, 255 - @map.screen.brightness)
    end
    @viewport1.update
    @viewport2.update
    @viewport3.update
  end
  
  #-----------------------------------------------------------------------------
  # New. Use a sliding viewport technique to prevent the maps from looping
  # There are six cases to consider: three for horizontal, three for vertical
  #
  #    - display is on left edge of map
  #    - display is in the middle
  #    - display on on the right edge of map
  #
  # The viewport must be positioned appropriately depending on where the
  # player currently is, since the tilemap will simply loop if the map does
  # not fill up the screen.
  #
  # The calculations are pretty intuitive: starting from the left edge,
  # the viewport's x-position depends on the x-offset and the map's current
  # display position.
  #
  # When the screen is no longer on the edge, the viewport can be positioned
  # at (0, 0) with dimensions (width, height)
  #
  # Once you reach the right edge, you would subtract the width appropriately
  # so the tilemap doesn't spill over the right side.
  #
  # Note that these calculations assume the width and height of the overlay
  # map is at least 13 x 17: for smaller maps, this would not work because you
  # must consider the size of the map as well. Maybe I will update this function
  # again in the future to address that, but you typically wouldn't have maps
  # smaller than 13 x 17 without using custom scripts to create them.
  #-----------------------------------------------------------------------------
  def update_sliding_viewports
    # update x, ox, and width
    unless @map.loop_horizontal?
      # left edge of map
      if $game_map.display_x - @offset_x.abs <= 0
        @viewport1.rect.x = @viewport1.ox = [(-@offset_x - $game_map.display_x) * @map.scroll_rate, 0].max
        @viewport1.rect.width = Graphics.width
      # middle
      elsif $game_map.display_x + @screen_width < (@map.width * @tile_ratio - @offset_x) * @zoom_ratio
        @viewport1.rect.x = @viewport1.ox = 0
        @viewport1.rect.width = Graphics.width
      # right edge of map
      else
        @viewport1.rect.width = [(@map.width * @tile_ratio - @offset_x - $game_map.display_x) * @map.scroll_rate, 0].max
      end
    end
    
    # update y, oy, and height
    unless @map.loop_vertical?
      # top edge of map
      if $game_map.display_y - @offset_y.abs <= 0
        @viewport1.rect.y = @viewport1.oy = [(-@offset_y - $game_map.display_y) * @map.scroll_rate, 0].max
        @viewport1.rect.height = Graphics.height
      # middle
      elsif $game_map.display_y + @screen_height < (@map.height * @tile_ratio - @offset_y) * @zoom_ratio
        @viewport1.rect.y = @viewport1.oy = 0
        @viewport1.rect.height = Graphics.height
      # bottom edge
      else
        @viewport1.rect.height = [(@map.height * @tile_ratio - @offset_y - $game_map.display_y) * @map.scroll_rate, 0].max
      end
    end
  end
end

class Scene_Map < Scene_Base
  
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  alias :th_overlay_maps_create_spriteset :create_spriteset
  def create_spriteset
    th_overlay_maps_create_spriteset
    create_overlay_maps
  end
  
  def create_overlay_maps
    @layer_spritesets = []
    $game_map.overlay_maps.each {|lmap|
      @layer_spritesets.push(Spriteset_OverlayMap.new(lmap))
    }
    update_overlay_maps
  end
  
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  alias :th_overlay_maps_dispose_spriteset :dispose_spriteset
  def dispose_spriteset
    th_overlay_maps_dispose_spriteset
    dispose_overlay_maps
  end
  
  def dispose_overlay_maps
    @layer_spritesets.each {|spr| spr.dispose}
  end
  
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  alias :th_overlay_maps_update :update
  def update    
    th_overlay_maps_update
    update_overlay_maps
  end
  
  def update_overlay_maps
    @layer_spritesets.each {|spr| spr.update}
  end
  
  alias :th_overlay_maps_pre_transfer :pre_transfer
  def pre_transfer    
    th_overlay_maps_pre_transfer
    dispose_overlay_maps
  end
  
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  alias :th_overlay_maps_post_transfer :post_transfer
  def post_transfer
    create_overlay_maps
    th_overlay_maps_post_transfer
  end
end