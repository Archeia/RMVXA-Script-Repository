#encoding:UTF-8
# Game_Map
#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles maps. It includes scrolling and passage determination
# functions. The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :screen                   # map screen state
  attr_reader   :interpreter              # map event interpreter
  attr_reader   :events                   # events
  attr_reader   :display_x                # display X coordinate
  attr_reader   :display_y                # display Y coordinate
  attr_reader   :parallax_name            # parallax background filename
  attr_reader   :vehicles                 # vehicle
  attr_reader   :battleback1_name         # battle background (floor) filename
  attr_reader   :battleback2_name         # battle background (wall) filename
  attr_accessor :name_display             # map name display flag
  attr_accessor :need_refresh             # refresh request flag
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @screen = Game_Screen.new
    @interpreter = Game_Interpreter.new
    @map_id = 0
    @events = {}
    @display_x = 0
    @display_y = 0
    create_vehicles
    @name_display = true
  end
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  def setup(map_id)
    @map_id = map_id
    @map = load_data(sprintf("Data/Map%03d.rvdata2", @map_id))
    @tileset_id = @map.tileset_id
    @display_x = 0
    @display_y = 0
    referesh_vehicles
    setup_events
    setup_scroll
    setup_parallax
    setup_battleback
    @need_refresh = false
  end
  #--------------------------------------------------------------------------
  # * Create Vehicles
  #--------------------------------------------------------------------------
  def create_vehicles
    @vehicles = []
    @vehicles[0] = Game_Vehicle.new(:boat)
    @vehicles[1] = Game_Vehicle.new(:ship)
    @vehicles[2] = Game_Vehicle.new(:airship)
  end
  #--------------------------------------------------------------------------
  # * Refresh Vehicles
  #--------------------------------------------------------------------------
  def referesh_vehicles
    @vehicles.each {|vehicle| vehicle.refresh }
  end
  #--------------------------------------------------------------------------
  # * Get Vehicle
  #--------------------------------------------------------------------------
  def vehicle(type)
    return @vehicles[0] if type == :boat
    return @vehicles[1] if type == :ship
    return @vehicles[2] if type == :airship
    return nil
  end
  #--------------------------------------------------------------------------
  # * Get Boat
  #--------------------------------------------------------------------------
  def boat
    @vehicles[0]
  end
  #--------------------------------------------------------------------------
  # * Get Ship
  #--------------------------------------------------------------------------
  def ship
    @vehicles[1]
  end
  #--------------------------------------------------------------------------
  # * Get Airship
  #--------------------------------------------------------------------------
  def airship
    @vehicles[2]
  end
  #--------------------------------------------------------------------------
  # * Event Setup
  #--------------------------------------------------------------------------
  def setup_events
    @events = {}
    @map.events.each do |i, event|
      @events[i] = Game_Event.new(@map_id, event)
    end
    @common_events = parallel_common_events.collect do |common_event|
      Game_CommonEvent.new(common_event.id)
    end
    refresh_tile_events
  end
  #--------------------------------------------------------------------------
  # * Get Array of Parallel Common Events
  #--------------------------------------------------------------------------
  def parallel_common_events
    $data_common_events.select {|event| event && event.parallel? }
  end
  #--------------------------------------------------------------------------
  # * Scroll Setup
  #--------------------------------------------------------------------------
  def setup_scroll
    @scroll_direction = 2
    @scroll_rest = 0
    @scroll_speed = 4
  end
  #--------------------------------------------------------------------------
  # * Parallax Background Setup
  #--------------------------------------------------------------------------
  def setup_parallax
    @parallax_name = @map.parallax_name
    @parallax_loop_x = @map.parallax_loop_x
    @parallax_loop_y = @map.parallax_loop_y
    @parallax_sx = @map.parallax_sx
    @parallax_sy = @map.parallax_sy
    @parallax_x = 0
    @parallax_y = 0
  end
  #--------------------------------------------------------------------------
  # * Set Up Battle Background
  #--------------------------------------------------------------------------
  def setup_battleback
    if @map.specify_battleback
      @battleback1_name = @map.battleback1_name
      @battleback2_name = @map.battleback2_name
    else
      @battleback1_name = nil
      @battleback2_name = nil
    end
  end
  #--------------------------------------------------------------------------
  # * Set Display Position
  #--------------------------------------------------------------------------
  def set_display_pos(x, y)
    x = [0, [x, width - screen_tile_x].min].max unless loop_horizontal?
    y = [0, [y, height - screen_tile_y].min].max unless loop_vertical?
    @display_x = (x + width) % width
    @display_y = (y + height) % height
    @parallax_x = x
    @parallax_y = y
  end
  #--------------------------------------------------------------------------
  # * Calculate X Coordinate of Parallax Display Origin
  #--------------------------------------------------------------------------
  def parallax_ox(bitmap)
    if @parallax_loop_x
      @parallax_x * 16
    else
      w1 = [bitmap.width - Graphics.width, 0].max
      w2 = [width * 32 - Graphics.width, 1].max
      @parallax_x * 16 * w1 / w2
    end
  end
  #--------------------------------------------------------------------------
  # * Calculate Y Coordinate of Parallax Display Origin
  #--------------------------------------------------------------------------
  def parallax_oy(bitmap)
    if @parallax_loop_y
      @parallax_y * 16
    else
      h1 = [bitmap.height - Graphics.height, 0].max
      h2 = [height * 32 - Graphics.height, 1].max
      @parallax_y * 16 * h1 / h2
    end
  end
  #--------------------------------------------------------------------------
  # * Get Map ID
  #--------------------------------------------------------------------------
  def map_id
    @map_id
  end
  #--------------------------------------------------------------------------
  # * Get Tileset
  #--------------------------------------------------------------------------
  def tileset
    $data_tilesets[@tileset_id]
  end
  #--------------------------------------------------------------------------
  # * Get Display Name
  #--------------------------------------------------------------------------
  def display_name
    @map.display_name
  end
  #--------------------------------------------------------------------------
  # * Get Width
  #--------------------------------------------------------------------------
  def width
    @map.width
  end
  #--------------------------------------------------------------------------
  # * Get Height
  #--------------------------------------------------------------------------
  def height
    @map.height
  end
  #--------------------------------------------------------------------------
  # * Loop Horizontally?
  #--------------------------------------------------------------------------
  def loop_horizontal?
    @map.scroll_type == 2 || @map.scroll_type == 3
  end
  #--------------------------------------------------------------------------
  # * Loop Vertically?
  #--------------------------------------------------------------------------
  def loop_vertical?
    @map.scroll_type == 1 || @map.scroll_type == 3
  end
  #--------------------------------------------------------------------------
  # * Get Whether Dash is Disabled
  #--------------------------------------------------------------------------
  def disable_dash?
    @map.disable_dashing
  end
  #--------------------------------------------------------------------------
  # * Get Encounter List
  #--------------------------------------------------------------------------
  def encounter_list
    @map.encounter_list
  end
  #--------------------------------------------------------------------------
  # * Get Encounter Steps
  #--------------------------------------------------------------------------
  def encounter_step
    @map.encounter_step
  end
  #--------------------------------------------------------------------------
  # * Get Map Data
  #--------------------------------------------------------------------------
  def data
    @map.data
  end
  #--------------------------------------------------------------------------
  # * Determine if Field Type
  #--------------------------------------------------------------------------
  def overworld?
    tileset.mode == 0
  end
  #--------------------------------------------------------------------------
  # * Number of Horizontal Tiles on Screen
  #--------------------------------------------------------------------------
  def screen_tile_x
    Graphics.width / 32
  end
  #--------------------------------------------------------------------------
  # * Number of Vertical Tiles on Screen
  #--------------------------------------------------------------------------
  def screen_tile_y
    Graphics.height / 32
  end
  #--------------------------------------------------------------------------
  # * Calculate X Coordinate, Minus Display Coordinate
  #--------------------------------------------------------------------------
  def adjust_x(x)
    if loop_horizontal? && x < @display_x - (width - screen_tile_x) / 2
      x - @display_x + @map.width
    else
      x - @display_x
    end
  end
  #--------------------------------------------------------------------------
  # * Calculate Y Coordinate, Minus Display Coordinate
  #--------------------------------------------------------------------------
  def adjust_y(y)
    if loop_vertical? && y < @display_y - (height - screen_tile_y) / 2
      y - @display_y + @map.height
    else
      y - @display_y
    end
  end
  #--------------------------------------------------------------------------
  # * Calculate X Coordinate After Loop Adjustment
  #--------------------------------------------------------------------------
  def round_x(x)
    loop_horizontal? ? (x + width) % width : x
  end
  #--------------------------------------------------------------------------
  # * Calculate Y Coordinate After Loop Adjustment
  #--------------------------------------------------------------------------
  def round_y(y)
    loop_vertical? ? (y + height) % height : y
  end
  #--------------------------------------------------------------------------
  # * Calculate X Coordinate Shifted One Tile in Specific Direction
  #   (No Loop Adjustment)
  #--------------------------------------------------------------------------
  def x_with_direction(x, d)
    x + (d == 6 ? 1 : d == 4 ? -1 : 0)
  end
  #--------------------------------------------------------------------------
  # * Calculate Y Coordinate Shifted One Tile in Specific Direction
  #   (No Loop Adjustment)
  #--------------------------------------------------------------------------
  def y_with_direction(y, d)
    y + (d == 2 ? 1 : d == 8 ? -1 : 0)
  end
  #--------------------------------------------------------------------------
  # * Calculate X Coordinate Shifted One Tile in Specific Direction
  #   (With Loop Adjustment)
  #--------------------------------------------------------------------------
  def round_x_with_direction(x, d)
    round_x(x + (d == 6 ? 1 : d == 4 ? -1 : 0))
  end
  #--------------------------------------------------------------------------
  # * Calculate Y Coordinate Shifted One Tile in Specific Direction
  #   (With Loop Adjustment)
  #--------------------------------------------------------------------------
  def round_y_with_direction(y, d)
    round_y(y + (d == 2 ? 1 : d == 8 ? -1 : 0))
  end
  #--------------------------------------------------------------------------
  # * Automatically Switch BGM and BGS
  #--------------------------------------------------------------------------
  def autoplay
    @map.bgm.play if @map.autoplay_bgm
    @map.bgs.play if @map.autoplay_bgs
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    @events.each_value {|event| event.refresh }
    @common_events.each {|event| event.refresh }
    refresh_tile_events
    @need_refresh = false
  end
  #--------------------------------------------------------------------------
  # * Refresh Array of Tile-Handling Events
  #--------------------------------------------------------------------------
  def refresh_tile_events
    @tile_events = @events.values.select {|event| event.tile? }
  end
  #--------------------------------------------------------------------------
  # * Get Array of Events at Designated Coordinates
  #--------------------------------------------------------------------------
  def events_xy(x, y)
    @events.values.select {|event| event.pos?(x, y) }
  end
  #--------------------------------------------------------------------------
  # * Get Array of Events at Designated Coordinates (Except Pass-Through)
  #--------------------------------------------------------------------------
  def events_xy_nt(x, y)
    @events.values.select {|event| event.pos_nt?(x, y) }
  end
  #--------------------------------------------------------------------------
  # * Get Array of Tile-Handling Events at Designated Coordinates
  #   (Except Pass-Through)
  #--------------------------------------------------------------------------
  def tile_events_xy(x, y)
    @tile_events.select {|event| event.pos_nt?(x, y) }
  end
  #--------------------------------------------------------------------------
  # * Get ID of Events at Designated Coordinates (One Only)
  #--------------------------------------------------------------------------
  def event_id_xy(x, y)
    list = events_xy(x, y)
    list.empty? ? 0 : list[0].id
  end
  #--------------------------------------------------------------------------
  # * Scroll Down
  #--------------------------------------------------------------------------
  def scroll_down(distance)
    if loop_vertical?
      @display_y += distance
      @display_y %= @map.height
      @parallax_y += distance if @parallax_loop_y
    else
      last_y = @display_y
      @display_y = [@display_y + distance, height - screen_tile_y].min
      @parallax_y += @display_y - last_y
    end
  end
  #--------------------------------------------------------------------------
  # * Scroll Left
  #--------------------------------------------------------------------------
  def scroll_left(distance)
    if loop_horizontal?
      @display_x += @map.width - distance
      @display_x %= @map.width 
      @parallax_x -= distance if @parallax_loop_x
    else
      last_x = @display_x
      @display_x = [@display_x - distance, 0].max
      @parallax_x += @display_x - last_x
    end
  end
  #--------------------------------------------------------------------------
  # * Scroll Right
  #--------------------------------------------------------------------------
  def scroll_right(distance)
    if loop_horizontal?
      @display_x += distance
      @display_x %= @map.width
      @parallax_x += distance if @parallax_loop_x
    else
      last_x = @display_x
      @display_x = [@display_x + distance, (width - screen_tile_x)].min
      @parallax_x += @display_x - last_x
    end
  end
  #--------------------------------------------------------------------------
  # * Scroll Up
  #--------------------------------------------------------------------------
  def scroll_up(distance)
    if loop_vertical?
      @display_y += @map.height - distance
      @display_y %= @map.height
      @parallax_y -= distance if @parallax_loop_y
    else
      last_y = @display_y
      @display_y = [@display_y - distance, 0].max
      @parallax_y += @display_y - last_y
    end
  end
  #--------------------------------------------------------------------------
  # * Determine Valid Coordinates
  #--------------------------------------------------------------------------
  def valid?(x, y)
    x >= 0 && x < width && y >= 0 && y < height
  end
  #--------------------------------------------------------------------------
  # * Check Passage
  #     bit:  Inhibit passage check bit
  #--------------------------------------------------------------------------
  def check_passage(x, y, bit)
    all_tiles(x, y).each do |tile_id|
      flag = tileset.flags[tile_id]
      next if flag & 0x10 != 0            # [☆]: No effect on passage
      return true  if flag & bit == 0     # [○] : Passable
      return false if flag & bit == bit   # [×] : Impassable
    end
    return false                          # Impassable
  end
  #--------------------------------------------------------------------------
  # * Get Tile ID at Specified Coordinates
  #--------------------------------------------------------------------------
  def tile_id(x, y, z)
    @map.data[x, y, z] || 0
  end
  #--------------------------------------------------------------------------
  # * Get Array of All Layer Tiles (Top to Bottom) at Specified Coordinates
  #--------------------------------------------------------------------------
  def layered_tiles(x, y)
    [2, 1, 0].collect {|z| tile_id(x, y, z) }
  end
  #--------------------------------------------------------------------------
  # * Get Array of All Tiles (Including Events) at Specified Coordinates
  #--------------------------------------------------------------------------
  def all_tiles(x, y)
    tile_events_xy(x, y).collect {|ev| ev.tile_id } + layered_tiles(x, y)
  end
  #--------------------------------------------------------------------------
  # * Get Type of Auto Tile at Specified Coordinates
  #--------------------------------------------------------------------------
  def autotile_type(x, y, z)
    tile_id(x, y, z) >= 2048 ? (tile_id(x, y, z) - 2048) / 48 : -1
  end
  #--------------------------------------------------------------------------
  # * Determine Passability of Normal Character
  #     d:  direction (2,4,6,8)
  #    Determines whether the tile at the specified coordinates is passable
  #    in the specified direction.
  #--------------------------------------------------------------------------
  def passable?(x, y, d)
    check_passage(x, y, (1 << (d / 2 - 1)) & 0x0f)
  end
  #--------------------------------------------------------------------------
  # * Determine if Passable by Boat
  #--------------------------------------------------------------------------
  def boat_passable?(x, y)
    check_passage(x, y, 0x0200)
  end
  #--------------------------------------------------------------------------
  # * Determine if Passable by Ship
  #--------------------------------------------------------------------------
  def ship_passable?(x, y)
    check_passage(x, y, 0x0400)
  end
  #--------------------------------------------------------------------------
  # * Determine if Airship can Land
  #--------------------------------------------------------------------------
  def airship_land_ok?(x, y)
    check_passage(x, y, 0x0800) && check_passage(x, y, 0x0f)
  end
  #--------------------------------------------------------------------------
  # * Determine Flag for All Layers at Specified Coordinates
  #--------------------------------------------------------------------------
  def layered_tiles_flag?(x, y, bit)
    layered_tiles(x, y).any? {|tile_id| tileset.flags[tile_id] & bit != 0 }
  end
  #--------------------------------------------------------------------------
  # * Determine if Ladder
  #--------------------------------------------------------------------------
  def ladder?(x, y)
    valid?(x, y) && layered_tiles_flag?(x, y, 0x20)
  end
  #--------------------------------------------------------------------------
  # * Determine if Bush
  #--------------------------------------------------------------------------
  def bush?(x, y)
    valid?(x, y) && layered_tiles_flag?(x, y, 0x40)
  end
  #--------------------------------------------------------------------------
  # * Determine if Counter
  #--------------------------------------------------------------------------
  def counter?(x, y)
    valid?(x, y) && layered_tiles_flag?(x, y, 0x80)
  end
  #--------------------------------------------------------------------------
  # * Determine if Damage Floor
  #--------------------------------------------------------------------------
  def damage_floor?(x, y)
    valid?(x, y) && layered_tiles_flag?(x, y, 0x100)
  end
  #--------------------------------------------------------------------------
  # * Get Terrain Tag
  #--------------------------------------------------------------------------
  def terrain_tag(x, y)
    return 0 unless valid?(x, y)
    layered_tiles(x, y).each do |tile_id|
      tag = tileset.flags[tile_id] >> 12
      return tag if tag > 0
    end
    return 0
  end
  #--------------------------------------------------------------------------
  # * Get Region ID
  #--------------------------------------------------------------------------
  def region_id(x, y)
    valid?(x, y) ? @map.data[x, y, 3] >> 8 : 0
  end
  #--------------------------------------------------------------------------
  # * Start Scroll
  #--------------------------------------------------------------------------
  def start_scroll(direction, distance, speed)
    @scroll_direction = direction
    @scroll_rest = distance
    @scroll_speed = speed
  end
  #--------------------------------------------------------------------------
  # * Determine if Scrolling
  #--------------------------------------------------------------------------
  def scrolling?
    @scroll_rest > 0
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #     main:  Interpreter update flag
  #--------------------------------------------------------------------------
  def update(main = false)
    refresh if @need_refresh
    update_interpreter if main
    update_scroll
    update_events
    update_vehicles
    update_parallax
    @screen.update
  end
  #--------------------------------------------------------------------------
  # * Update Scroll
  #--------------------------------------------------------------------------
  def update_scroll
    return unless scrolling?
    last_x = @display_x
    last_y = @display_y
    do_scroll(@scroll_direction, scroll_distance)
    if @display_x == last_x && @display_y == last_y
      @scroll_rest = 0
    else
      @scroll_rest -= scroll_distance
    end
  end
  #--------------------------------------------------------------------------
  # * Calculate Scroll Distance
  #--------------------------------------------------------------------------
  def scroll_distance
    2 ** @scroll_speed / 256.0
  end
  #--------------------------------------------------------------------------
  # * Execute Scroll
  #--------------------------------------------------------------------------
  def do_scroll(direction, distance)
    case direction
    when 2;  scroll_down (distance)
    when 4;  scroll_left (distance)
    when 6;  scroll_right(distance)
    when 8;  scroll_up   (distance)
    end
  end
  #--------------------------------------------------------------------------
  # * Update Events
  #--------------------------------------------------------------------------
  def update_events
    @events.each_value {|event| event.update }
    @common_events.each {|event| event.update }
  end
  #--------------------------------------------------------------------------
  # * Update Vehicles
  #--------------------------------------------------------------------------
  def update_vehicles
    @vehicles.each {|vehicle| vehicle.update }
  end
  #--------------------------------------------------------------------------
  # * Update Parallax
  #--------------------------------------------------------------------------
  def update_parallax
    @parallax_x += @parallax_sx / 64.0 if @parallax_loop_x
    @parallax_y += @parallax_sy / 64.0 if @parallax_loop_y
  end
  #--------------------------------------------------------------------------
  # * Change Tileset
  #--------------------------------------------------------------------------
  def change_tileset(tileset_id)
    @tileset_id = tileset_id
    refresh
  end
  #--------------------------------------------------------------------------
  # * Change Battle Background
  #--------------------------------------------------------------------------
  def change_battleback(battleback1_name, battleback2_name)
    @battleback1_name = battleback1_name
    @battleback2_name = battleback2_name
  end
  #--------------------------------------------------------------------------
  # * Change Parallax Background
  #--------------------------------------------------------------------------
  def change_parallax(name, loop_x, loop_y, sx, sy)
    @parallax_name = name
    @parallax_x = 0 if @parallax_loop_x && !loop_x
    @parallax_y = 0 if @parallax_loop_y && !loop_y
    @parallax_loop_x = loop_x
    @parallax_loop_y = loop_y
    @parallax_sx = sx
    @parallax_sy = sy
  end
  #--------------------------------------------------------------------------
  # * Update Interpreter
  #--------------------------------------------------------------------------
  def update_interpreter
    loop do
      @interpreter.update
      return if @interpreter.running?
      if @interpreter.event_id > 0
        unlock_event(@interpreter.event_id)
        @interpreter.clear
      end
      return unless setup_starting_event
    end
  end
  #--------------------------------------------------------------------------
  # * Unlock Event
  #--------------------------------------------------------------------------
  def unlock_event(event_id)
    @events[event_id].unlock if @events[event_id]
  end
  #--------------------------------------------------------------------------
  # * Starting Event Setup
  #--------------------------------------------------------------------------
  def setup_starting_event
    refresh if @need_refresh
    return true if @interpreter.setup_reserved_common_event
    return true if setup_starting_map_event
    return true if setup_autorun_common_event
    return false
  end
  #--------------------------------------------------------------------------
  # * Determine Existence of Starting Map Event
  #--------------------------------------------------------------------------
  def any_event_starting?
    @events.values.any? {|event| event.starting }
  end
  #--------------------------------------------------------------------------
  # * Detect/Set Up Starting Map Event
  #--------------------------------------------------------------------------
  def setup_starting_map_event
    event = @events.values.find {|event| event.starting }
    event.clear_starting_flag if event
    @interpreter.setup(event.list, event.id) if event
    event
  end
  #--------------------------------------------------------------------------
  # * Detect/Set Up Autorun Common Event
  #--------------------------------------------------------------------------
  def setup_autorun_common_event
    event = $data_common_events.find do |event|
      event && event.autorun? && $game_switches[event.switch_id]
    end
    @interpreter.setup(event.list) if event
    event
  end
end
