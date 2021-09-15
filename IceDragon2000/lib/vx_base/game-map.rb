#encoding:UTF-8
# Game_Map*
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
  attr_reader   :display_x                # display X coordinate * 256
  attr_reader   :display_y                # display Y coordinate * 256
  attr_reader   :parallax_name            # parallax background filename
  attr_reader   :passages                 # passage table
  attr_reader   :events                   # events
  attr_reader   :vehicles                 # vehicle
  attr_accessor :need_refresh             # refresh request flag
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @screen = Game_Screen.new
    @interpreter = Game_Interpreter.new(0, true)
    @map_id = 0
    @display_x = 0
    @display_y = 0
    create_vehicles
  end
  #--------------------------------------------------------------------------
  # * Setup
  #     map_id : map ID
  #--------------------------------------------------------------------------
  def setup(map_id)
    @map_id = map_id
    @map = load_data(sprintf("Data/Map%03d.rvdata", @map_id))
    @display_x = 0
    @display_y = 0
    @passages = $data_system.passages
    referesh_vehicles
    setup_events
    setup_scroll
    setup_parallax
    @need_refresh = false
  end
  #--------------------------------------------------------------------------
  # * Create Vehicles
  #--------------------------------------------------------------------------
  def create_vehicles
    @vehicles = []
    @vehicles[0] = Game_Vehicle.new(0)    # Boat
    @vehicles[1] = Game_Vehicle.new(1)    # Ship
    @vehicles[2] = Game_Vehicle.new(2)    # Airship
  end
  #--------------------------------------------------------------------------
  # * Refresh Vehicles
  #--------------------------------------------------------------------------
  def referesh_vehicles
    for vehicle in @vehicles
      vehicle.refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Get Boat
  #--------------------------------------------------------------------------
  def boat
    return @vehicles[0]
  end
  #--------------------------------------------------------------------------
  # * Get Ship
  #--------------------------------------------------------------------------
  def ship
    return @vehicles[1]
  end
  #--------------------------------------------------------------------------
  # * Get Airship
  #--------------------------------------------------------------------------
  def airship
    return @vehicles[2]
  end
  #--------------------------------------------------------------------------
  # * Event Setup
  #--------------------------------------------------------------------------
  def setup_events
    @events = {}          # Map event
    for i in @map.events.keys
      @events[i] = Game_Event.new(@map_id, @map.events[i])
    end
    @common_events = {}   # Common event
    for i in 1...$data_common_events.size
      @common_events[i] = Game_CommonEvent.new(i)
    end
  end
  #--------------------------------------------------------------------------
  # * Scroll Setup
  #--------------------------------------------------------------------------
  def setup_scroll
    @scroll_direction = 2
    @scroll_rest = 0
    @scroll_speed = 4
    @margin_x = (width - 17) * 256 / 2      # Screen non-display width /2
    @margin_y = (height - 13) * 256 / 2     # Screen non-display height /2
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
  # * Set Display Position
  #     x : New display X coordinate (*256)
  #     y : New display Y coordinate (*256)
  #--------------------------------------------------------------------------
  def set_display_pos(x, y)
    @display_x = (x + @map.width * 256) % (@map.width * 256)
    @display_y = (y + @map.height * 256) % (@map.height * 256)
    @parallax_x = x
    @parallax_y = y
  end
  #--------------------------------------------------------------------------
  # * Calculate X coordinate for parallax display 
  #     bitmap : Parallax bitmap
  #--------------------------------------------------------------------------
  def calc_parallax_x(bitmap)
    if bitmap == nil
      return 0
    elsif @parallax_loop_x
      return @parallax_x / 16
    elsif loop_horizontal?
      return 0
    else
      w1 = bitmap.width - 544
      w2 = @map.width * 32 - 544
      if w1 <= 0 or w2 <= 0
        return 0
      else
        return @parallax_x * w1 / w2 / 8
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Calculate Y coordinate for parallax display 
  #     bitmap : Parallax bitmap
  #--------------------------------------------------------------------------
  def calc_parallax_y(bitmap)
    if bitmap == nil
      return 0
    elsif @parallax_loop_y
      return @parallax_y / 16
    elsif loop_vertical?
      return 0
    else
      h1 = bitmap.height - 416
      h2 = @map.height * 32 - 416
      if h1 <= 0 or h2 <= 0
        return 0
      else
        return @parallax_y * h1 / h2 / 8
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Get Map ID
  #--------------------------------------------------------------------------
  def map_id
    return @map_id
  end
  #--------------------------------------------------------------------------
  # * Get Width
  #--------------------------------------------------------------------------
  def width
    return @map.width
  end
  #--------------------------------------------------------------------------
  # * Get Height
  #--------------------------------------------------------------------------
  def height
    return @map.height
  end
  #--------------------------------------------------------------------------
  # * Loop Horizontally?
  #--------------------------------------------------------------------------
  def loop_horizontal?
    return (@map.scroll_type == 2 or @map.scroll_type == 3)
  end
  #--------------------------------------------------------------------------
  # * Loop Vertically?
  #--------------------------------------------------------------------------
  def loop_vertical?
    return (@map.scroll_type == 1 or @map.scroll_type == 3)
  end
  #--------------------------------------------------------------------------
  # * Get Whether Dash is Disabled
  #--------------------------------------------------------------------------
  def disable_dash?
    return @map.disable_dashing
  end
  #--------------------------------------------------------------------------
  # * Get Encounter List
  #--------------------------------------------------------------------------
  def encounter_list
    return @map.encounter_list
  end
  #--------------------------------------------------------------------------
  # * Get Encounter Steps
  #--------------------------------------------------------------------------
  def encounter_step
    return @map.encounter_step
  end
  #--------------------------------------------------------------------------
  # * Get Map Data
  #--------------------------------------------------------------------------
  def data
    return @map.data
  end
  #--------------------------------------------------------------------------
  # * Calculate X coordinate, minus display coordinate
  #     x : x-coordinate
  #--------------------------------------------------------------------------
  def adjust_x(x)
    if loop_horizontal? and x < @display_x - @margin_x
      return x - @display_x + @map.width * 256
    else
      return x - @display_x
    end
  end
  #--------------------------------------------------------------------------
  # * Calculate Y coordinate, minus display coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def adjust_y(y)
    if loop_vertical? and y < @display_y - @margin_y
      return y - @display_y + @map.height * 256
    else
      return y - @display_y
    end
  end
  #--------------------------------------------------------------------------
  # * Calculate X coordinate after loop adjustment
  #     x : x-coordinate
  #--------------------------------------------------------------------------
  def round_x(x)
    if loop_horizontal?
      return (x + width) % width
    else
      return x
    end
  end
  #--------------------------------------------------------------------------
  # * Calculate Y coordinate after loop adjustment
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def round_y(y)
    if loop_vertical?
      return (y + height) % height
    else
      return y
    end
  end
  #--------------------------------------------------------------------------
  # * Calculate X coordinate one square in a particular direction
  #     x         : x-coordinate
  #     direction : direction  (2,4,6,8)
  #--------------------------------------------------------------------------
  def x_with_direction(x, direction)
    return round_x(x + (direction == 6 ? 1 : direction == 4 ? -1 : 0))
  end
  #--------------------------------------------------------------------------
  # * Calculate Y coordinate one square in a particular direction
  #     y         : y-coordinate
  #     direction : direction (2,4,6,8)
  #--------------------------------------------------------------------------
  def y_with_direction(y, direction)
    return round_y(y + (direction == 2 ? 1 : direction == 8 ? -1 : 0))
  end
  #--------------------------------------------------------------------------
  # * Get array of event at designated coordinates
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def events_xy( x, y )
    return $game_map.events.values.inject([]) { |result, event|
      result.push(event) if event.pos?( x, y ) ; result
    }
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
    if @map_id > 0
      for event in @events.values
        event.refresh
      end
      for common_event in @common_events.values
        common_event.refresh
      end
    end
    @need_refresh = false
  end
  #--------------------------------------------------------------------------
  # * Scroll Down
  #     distance : scroll distance
  #--------------------------------------------------------------------------
  def scroll_down(distance)
    if loop_vertical?
      @display_y += distance
      @display_y %= @map.height * 256
      @parallax_y += distance
    else
      last_y = @display_y
      @display_y = [@display_y + distance, (height - 13) * 256].min
      @parallax_y += @display_y - last_y
    end
  end
  #--------------------------------------------------------------------------
  # * Scroll Left
  #     distance : scroll distance
  #--------------------------------------------------------------------------
  def scroll_left(distance)
    if loop_horizontal?
      @display_x += @map.width * 256 - distance
      @display_x %= @map.width * 256
      @parallax_x -= distance
    else
      last_x = @display_x
      @display_x = [@display_x - distance, 0].max
      @parallax_x += @display_x - last_x
    end
  end
  #--------------------------------------------------------------------------
  # * Scroll Right
  #     distance : scroll distance
  #--------------------------------------------------------------------------
  def scroll_right(distance)
    if loop_horizontal?
      @display_x += distance
      @display_x %= @map.width * 256
      @parallax_x += distance
    else
      last_x = @display_x
      @display_x = [@display_x + distance, (width - 17) * 256].min
      @parallax_x += @display_x - last_x
    end
  end
  #--------------------------------------------------------------------------
  # * Scroll Up
  #     distance : scroll distance
  #--------------------------------------------------------------------------
  def scroll_up(distance)
    if loop_vertical?
      @display_y += @map.height * 256 - distance
      @display_y %= @map.height * 256
      @parallax_y -= distance
    else
      last_y = @display_y
      @display_y = [@display_y - distance, 0].max
      @parallax_y += @display_y - last_y
    end
  end
  #--------------------------------------------------------------------------
  # * Determine Valid Coordinates
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def valid?(x, y)
    return (x >= 0 and x < width and y >= 0 and y < height)
  end
  #--------------------------------------------------------------------------
  # * Determine if Passable
  #     x    : x coordinate
  #     y    : y coordinate
  #     flag : The impassable bit to be looked up
  #            (normally 0x01, only changed for vehicles)
  #--------------------------------------------------------------------------
  def passable?(x, y, flag = 0x01)
    for event in events_xy(x, y)            # events with matching coordinates
      next if event.tile_id == 0            # graphics are not tiled
      next if event.priority_type > 0       # not [Below characters]
      next if event.through                 # pass-through state
      pass = @passages[event.tile_id]       # get passable attribute
      next if pass & 0x10 == 0x10           # *: Does not affect passage
      return true if pass & flag == 0x00    # o: Passable
      return false if pass & flag == flag   # x: Impassable
    end
    for i in [2, 1, 0]                      # in order from on top of layer
      tile_id = @map.data[x, y, i]          # get tile ID
      return false if tile_id == nil        # failed to get tile: Impassable
      pass = @passages[tile_id]             # get passable attribute
      next if pass & 0x10 == 0x10           # *: Does not affect passage
      return true if pass & flag == 0x00    # o: Passable
      return false if pass & flag == flag   # x: Impassable
    end
    return false                            # Impassable
  end
  #--------------------------------------------------------------------------
  # * Determine if Boat is Passable
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def boat_passable?(x, y)
    return passable?(x, y, 0x02)
  end
  #--------------------------------------------------------------------------
  # * Determine if Ship is Passable
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def ship_passable?(x, y)
    return passable?(x, y, 0x04)
  end
  #--------------------------------------------------------------------------
  # * Determine if Airship can Land
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def airship_land_ok?(x, y)
    return passable?(x, y, 0x08)
  end
  #--------------------------------------------------------------------------
  # * Determine bush
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def bush?(x, y)
    return false unless valid?(x, y)
    return @passages[@map.data[x, y, 1]] & 0x40 == 0x40
  end
  #--------------------------------------------------------------------------
  # * Determine Counter
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def counter?(x, y)
    return false unless valid?(x, y)
    return @passages[@map.data[x, y, 0]] & 0x80 == 0x80
  end
  #--------------------------------------------------------------------------
  # * Start Scroll
  #     direction : scroll direction
  #     distance  : scroll distance
  #     speed     : scroll speed
  #--------------------------------------------------------------------------
  def start_scroll(direction, distance, speed)
    @scroll_direction = direction
    @scroll_rest = distance * 256
    @scroll_speed = speed
  end
  #--------------------------------------------------------------------------
  # * Determine if Scrolling
  #--------------------------------------------------------------------------
  def scrolling?
    return @scroll_rest > 0
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    refresh if $game_map.need_refresh
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
    if @scroll_rest > 0                 # If scrolling
      distance = 2 ** @scroll_speed     # Convert to distance
      case @scroll_direction
      when 2  # Down
        scroll_down(distance)
      when 4  # Left
        scroll_left(distance)
      when 6  # Right
        scroll_right(distance)
      when 8  # Up
        scroll_up(distance)
      end
      @scroll_rest -= distance          # Subtract scrolled distance
    end
  end
  #--------------------------------------------------------------------------
  # * Update Events
  #--------------------------------------------------------------------------
  def update_events
    for event in @events.values
      event.update
    end
    for common_event in @common_events.values
      common_event.update
    end
  end
  #--------------------------------------------------------------------------
  # * Update Vehicles
  #--------------------------------------------------------------------------
  def update_vehicles
    for vehicle in @vehicles
      vehicle.update
    end
  end
  #--------------------------------------------------------------------------
  # * Update Parallax
  #--------------------------------------------------------------------------
  def update_parallax
    @parallax_x += @parallax_sx * 4 if @parallax_loop_x
    @parallax_y += @parallax_sy * 4 if @parallax_loop_y
  end
end
