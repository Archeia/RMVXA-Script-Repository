#encoding:UTF-8
# Game_Vehicle
#==============================================================================
# ** Game_Vehicle
#------------------------------------------------------------------------------
#  This class handles vehicles. It's used within the Game_Map class. If there
# are no vehicles on the current map, the coordinates are set to (-1,-1).
#==============================================================================

class Game_Vehicle < Game_Character
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :altitude                 # altitude (for airships)
  attr_reader   :driving                  # driving flag
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     type:  vehicle type (:boat, :ship, :airship)
  #--------------------------------------------------------------------------
  def initialize(type)
    super()
    @type = type
    @altitude = 0
    @driving = false
    @direction = 4
    @walk_anime = false
    @step_anime = false
    @walking_bgm = nil
    init_move_speed
    load_system_settings
  end
  #--------------------------------------------------------------------------
  # * Initialize Move Speed
  #--------------------------------------------------------------------------
  def init_move_speed
    @move_speed = 4 if @type == :boat
    @move_speed = 5 if @type == :ship
    @move_speed = 6 if @type == :airship
  end
  #--------------------------------------------------------------------------
  # * Get System Settings
  #--------------------------------------------------------------------------
  def system_vehicle
    return $data_system.boat    if @type == :boat
    return $data_system.ship    if @type == :ship
    return $data_system.airship if @type == :airship
    return nil
  end
  #--------------------------------------------------------------------------
  # * Load System Settings
  #--------------------------------------------------------------------------
  def load_system_settings
    @map_id           = system_vehicle.start_map_id
    @x                = system_vehicle.start_x
    @y                = system_vehicle.start_y
    @character_name   = system_vehicle.character_name
    @character_index  = system_vehicle.character_index
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    if @driving
      @map_id = $game_map.map_id
      sync_with_player
    elsif @map_id == $game_map.map_id
      moveto(@x, @y)
    end
    if @type == :airship
      @priority_type = @driving ? 2 : 0
    else
      @priority_type = 1
    end
    @walk_anime = @step_anime = @driving
  end
  #--------------------------------------------------------------------------
  # * Change Position
  #--------------------------------------------------------------------------
  def set_location(map_id, x, y)
    @map_id = map_id
    @x = x
    @y = y
    refresh
  end
  #--------------------------------------------------------------------------
  # * Determine Coordinate Match
  #--------------------------------------------------------------------------
  def pos?(x, y)
    @map_id == $game_map.map_id && super(x, y)
  end
  #--------------------------------------------------------------------------
  # * Determine Transparency
  #--------------------------------------------------------------------------
  def transparent
    @map_id != $game_map.map_id || super
  end
  #--------------------------------------------------------------------------
  # * Board Vehicle
  #--------------------------------------------------------------------------
  def get_on
    @driving = true
    @walk_anime = true
    @step_anime = true
    @walking_bgm = RPG::BGM.last
    system_vehicle.bgm.play
  end
  #--------------------------------------------------------------------------
  # * Get Off Vehicle
  #--------------------------------------------------------------------------
  def get_off
    @driving = false
    @walk_anime = false
    @step_anime = false
    @direction = 4
    @walking_bgm.play
  end
  #--------------------------------------------------------------------------
  # * Synchronize With Player 
  #--------------------------------------------------------------------------
  def sync_with_player
    @x = $game_player.x
    @y = $game_player.y
    @real_x = $game_player.real_x
    @real_y = $game_player.real_y
    @direction = $game_player.direction
    update_bush_depth
  end
  #--------------------------------------------------------------------------
  # * Get Move Speed
  #--------------------------------------------------------------------------
  def speed
    @move_speed
  end
  #--------------------------------------------------------------------------
  # * Get Screen Y-Coordinates
  #--------------------------------------------------------------------------
  def screen_y
    super - altitude
  end
  #--------------------------------------------------------------------------
  # * Determine if Movement is Possible
  #--------------------------------------------------------------------------
  def movable?
    !moving? && !(@type == :airship && @altitude < max_altitude)
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    update_airship_altitude if @type == :airship
  end
  #--------------------------------------------------------------------------
  # * Update Airship Altitude
  #--------------------------------------------------------------------------
  def update_airship_altitude
    if @driving
      @altitude += 1 if @altitude < max_altitude && takeoff_ok?
    elsif @altitude > 0
      @altitude -= 1
      @priority_type = 0 if @altitude == 0
    end
    @step_anime = (@altitude == max_altitude)
    @priority_type = 2 if @altitude > 0
  end
  #--------------------------------------------------------------------------
  # * Get Maximum Altitude of Airship
  #--------------------------------------------------------------------------
  def max_altitude
    return 32
  end
  #--------------------------------------------------------------------------
  # * Determine if Takeoff Is Possible
  #--------------------------------------------------------------------------
  def takeoff_ok?
    $game_player.followers.gather?
  end
  #--------------------------------------------------------------------------
  # * Determine if Docking/Landing Is Possible
  #     d:  Direction (2,4,6,8)
  #--------------------------------------------------------------------------
  def land_ok?(x, y, d)
    if @type == :airship
      return false unless $game_map.airship_land_ok?(x, y)
      return false unless $game_map.events_xy(x, y).empty?
    else
      x2 = $game_map.round_x_with_direction(x, d)
      y2 = $game_map.round_y_with_direction(y, d)
      return false unless $game_map.valid?(x2, y2)
      return false unless $game_map.passable?(x2, y2, reverse_dir(d))
      return false if collide_with_characters?(x2, y2)
    end
    return true
  end
end
