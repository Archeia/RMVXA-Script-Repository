#encoding:UTF-8
# Game_Vehicle
#==============================================================================
# ** Game_Vehicle
#------------------------------------------------------------------------------
#  This class handles vehicles. It's used within the Game_Map class. If there
# are no vehicles on the current map, the coordinates is set to (-1,-1).
#==============================================================================

class Game_Vehicle < Game_Character
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  MAX_ALTITUDE = 32                       # the airship flies at
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :type                     # vehicle type (0..2)
  attr_reader   :altitude                 # altitude (for the airship)
  attr_reader   :driving                  # driving flag
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     type : Vehicle type (0: boat, 1: ship, 2: airship)
  #--------------------------------------------------------------------------
  def initialize(type)
    super()
    @type = type
    @altitude = 0
    @driving = false
    @direction = 4
    @walk_anime = false
    @step_anime = false
    load_system_settings
  end
  #--------------------------------------------------------------------------
  # * Load System Settings
  #--------------------------------------------------------------------------
  def load_system_settings
    case @type
    when 0;  sys_vehicle = $data_system.boat
    when 1;  sys_vehicle = $data_system.ship
    when 2;  sys_vehicle = $data_system.airship
    else;    sys_vehicle = nil
    end
    if sys_vehicle != nil
      @character_name = sys_vehicle.character_name
      @character_index = sys_vehicle.character_index
      @bgm = sys_vehicle.bgm
      @map_id = sys_vehicle.start_map_id
      @x = sys_vehicle.start_x
      @y = sys_vehicle.start_y
    end
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
    case @type
    when 0;
      @priority_type = 1
      @move_speed = 4
    when 1;
      @priority_type = 1
      @move_speed = 5
    when 2;
      @priority_type = @driving ? 2 : 0
      @move_speed = 6
    end
    @walk_anime = @driving
    @step_anime = @driving
  end
  #--------------------------------------------------------------------------
  # * Change Position
  #     map_id : map ID
  #     x      : x coordinate
  #     y      : y coordinate
  #--------------------------------------------------------------------------
  def set_location(map_id, x, y)
    @map_id = map_id
    @x = x
    @y = y
    refresh
  end
  #--------------------------------------------------------------------------
  # * Determine Coordinate Match
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def pos?(x, y)
    return (@map_id == $game_map.map_id and super(x, y))
  end
  #--------------------------------------------------------------------------
  # * Determine Transparency
  #--------------------------------------------------------------------------
  def transparent
    return (@map_id != $game_map.map_id or super)
  end
  #--------------------------------------------------------------------------
  # * Board Vehicle
  #--------------------------------------------------------------------------
  def get_on
    @driving = true
    @walk_anime = true
    @step_anime = true
    if @type == 2               # If airship
      @priority_type = 2        # Change priority to "Above Characters"
    end
    @bgm.play                   # Start BGM
  end
  #--------------------------------------------------------------------------
  # * Get Off Vehicle
  #--------------------------------------------------------------------------
  def get_off
    @driving = false
    @walk_anime = false
    @step_anime = false
    @direction = 4
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
  # * Get Speed
  #--------------------------------------------------------------------------
  def speed
    return @move_speed
  end
  #--------------------------------------------------------------------------
  # * Get Screen Y-Coordinates
  #--------------------------------------------------------------------------
  def screen_y
    return super - altitude
  end
  #--------------------------------------------------------------------------
  # * Determine if Movement is Possible
  #--------------------------------------------------------------------------
  def movable?
    return false if (@type == 2 and @altitude < MAX_ALTITUDE)
    return (not moving?)
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if @type == 2               # If airship
      if @driving
        if @altitude < MAX_ALTITUDE
          @altitude += 1        # Increase altitude
        end
      elsif @altitude > 0
        @altitude -= 1          # Decrease altitude
        if @altitude == 0
          @priority_type = 0    # Return priority to "Below Characters"
        end
      end
    end
  end
end
