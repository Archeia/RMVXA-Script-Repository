#encoding:UTF-8
# Game_CharacterBase
#==============================================================================
# ** Game_CharacterBase
#------------------------------------------------------------------------------
#  This base class handles characters. It retains basic information, such as 
# coordinates and graphics, shared by all characters.
#==============================================================================

class Game_CharacterBase
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :id                       # ID
  attr_reader   :x                        # map X coordinate (logical)
  attr_reader   :y                        # map Y coordinate (logical)
  attr_reader   :real_x                   # map X coordinate (real)
  attr_reader   :real_y                   # map Y coordinate (real)
  attr_reader   :tile_id                  # tile ID (invalid if 0)
  attr_reader   :character_name           # character graphic filename
  attr_reader   :character_index          # character graphic index
  attr_reader   :move_speed               # movement speed
  attr_reader   :move_frequency           # movement frequency
  attr_reader   :walk_anime               # walking animation
  attr_reader   :step_anime               # stepping animation
  attr_reader   :direction_fix            # direction fix
  attr_reader   :opacity                  # opacity level
  attr_reader   :blend_type               # blending method
  attr_reader   :direction                # direction
  attr_reader   :pattern                  # pattern
  attr_reader   :priority_type            # priority type
  attr_reader   :through                  # pass-through
  attr_reader   :bush_depth               # bush depth
  attr_accessor :animation_id             # animation ID
  attr_accessor :balloon_id               # balloon icon ID
  attr_accessor :transparent              # transparency flag
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    init_public_members
    init_private_members
  end
  #--------------------------------------------------------------------------
  # * Initialize Public Member Variables
  #--------------------------------------------------------------------------
  def init_public_members
    @id = 0
    @x = 0
    @y = 0
    @real_x = 0
    @real_y = 0
    @tile_id = 0
    @character_name = ""
    @character_index = 0
    @move_speed = 4
    @move_frequency = 6
    @walk_anime = true
    @step_anime = false
    @direction_fix = false
    @opacity = 255
    @blend_type = 0
    @direction = 2
    @pattern = 1
    @priority_type = 1
    @through = false
    @bush_depth = 0
    @animation_id = 0
    @balloon_id = 0
    @transparent = false
  end
  #--------------------------------------------------------------------------
  # * Initialize Private Member Variables
  #--------------------------------------------------------------------------
  def init_private_members
    @original_direction = 2               # Original direction
    @original_pattern = 1                 # Original pattern
    @anime_count = 0                      # Animation count
    @stop_count = 0                       # Stop count
    @jump_count = 0                       # Jump count
    @jump_peak = 0                        # Jump peak count
    @locked = false                       # Locked flag
    @prelock_direction = 0                # Direction before lock
    @move_succeed = true                  # Move success flag
  end
  #--------------------------------------------------------------------------
  # * Determine Coordinate Match
  #--------------------------------------------------------------------------
  def pos?(x, y)
    @x == x && @y == y
  end
  #--------------------------------------------------------------------------
  # * Determine if Coordinates Match and Pass-Through Is Off (nt = No Through)
  #--------------------------------------------------------------------------
  def pos_nt?(x, y)
    pos?(x, y) && !@through
  end
  #--------------------------------------------------------------------------
  # * Determine if [Same as Characters] Priority
  #--------------------------------------------------------------------------
  def normal_priority?
    @priority_type == 1
  end
  #--------------------------------------------------------------------------
  # * Determine if Moving
  #--------------------------------------------------------------------------
  def moving?
    @real_x != @x || @real_y != @y
  end
  #--------------------------------------------------------------------------
  # * Determine if Jumping
  #--------------------------------------------------------------------------
  def jumping?
    @jump_count > 0
  end
  #--------------------------------------------------------------------------
  # * Calculate Jump Height
  #--------------------------------------------------------------------------
  def jump_height
    (@jump_peak * @jump_peak - (@jump_count - @jump_peak).abs ** 2) / 2
  end
  #--------------------------------------------------------------------------
  # * Determine if Stopping
  #--------------------------------------------------------------------------
  def stopping?
    !moving? && !jumping?
  end
  #--------------------------------------------------------------------------
  # * Get Move Speed (Account for Dash)
  #--------------------------------------------------------------------------
  def real_move_speed
    @move_speed + (dash? ? 1 : 0)
  end
  #--------------------------------------------------------------------------
  # * Calculate Move Distance per Frame
  #--------------------------------------------------------------------------
  def distance_per_frame
    2 ** real_move_speed / 256.0
  end
  #--------------------------------------------------------------------------
  # * Determine if Dashing
  #--------------------------------------------------------------------------
  def dash?
    return false
  end
  #--------------------------------------------------------------------------
  # * Determine if Debug Pass-Through State
  #--------------------------------------------------------------------------
  def debug_through?
    return false
  end
  #--------------------------------------------------------------------------
  # * Straighten Position
  #--------------------------------------------------------------------------
  def straighten
    @pattern = 1 if @walk_anime || @step_anime
    @anime_count = 0
  end
  #--------------------------------------------------------------------------
  # * Get Opposite Direction
  #     d : Direction (2,4,6,8)
  #--------------------------------------------------------------------------
  def reverse_dir(d)
    return 10 - d
  end
  #--------------------------------------------------------------------------
  # * Determine if Passable
  #     d : Direction (2,4,6,8)
  #--------------------------------------------------------------------------
  def passable?(x, y, d)
    x2 = $game_map.round_x_with_direction(x, d)
    y2 = $game_map.round_y_with_direction(y, d)
    return false unless $game_map.valid?(x2, y2)
    return true if @through || debug_through?
    return false unless map_passable?(x, y, d)
    return false unless map_passable?(x2, y2, reverse_dir(d))
    return false if collide_with_characters?(x2, y2)
    return true
  end
  #--------------------------------------------------------------------------
  # * Determine Diagonal Passability
  #     horz : Horizontal (4 or 6)
  #     vert : Vertical (2 or 8)
  #--------------------------------------------------------------------------
  def diagonal_passable?(x, y, horz, vert)
    x2 = $game_map.round_x_with_direction(x, horz)
    y2 = $game_map.round_y_with_direction(y, vert)
    (passable?(x, y, vert) && passable?(x, y2, horz)) ||
    (passable?(x, y, horz) && passable?(x2, y, vert))
  end
  #--------------------------------------------------------------------------
  # * Determine if Map is Passable
  #     d : Direction (2,4,6,8)
  #--------------------------------------------------------------------------
  def map_passable?(x, y, d)
    $game_map.passable?(x, y, d)
  end
  #--------------------------------------------------------------------------
  # * Detect Collision with Character 
  #--------------------------------------------------------------------------
  def collide_with_characters?(x, y)
    collide_with_events?(x, y) || collide_with_vehicles?(x, y)
  end
  #--------------------------------------------------------------------------
  # * Detect Collision with Event
  #--------------------------------------------------------------------------
  def collide_with_events?(x, y)
    $game_map.events_xy_nt(x, y).any? do |event|
      event.normal_priority? || self.is_a?(Game_Event)
    end
  end
  #--------------------------------------------------------------------------
  # * Detect Collision with Vehicle
  #--------------------------------------------------------------------------
  def collide_with_vehicles?(x, y)
    $game_map.boat.pos_nt?(x, y) || $game_map.ship.pos_nt?(x, y)
  end
  #--------------------------------------------------------------------------
  # * Move to Designated Position
  #--------------------------------------------------------------------------
  def moveto(x, y)
    @x = x % $game_map.width
    @y = y % $game_map.height
    @real_x = @x
    @real_y = @y
    @prelock_direction = 0
    straighten
    update_bush_depth
  end
  #--------------------------------------------------------------------------
  # * Change Direction to Designated Direction
  #     d : Direction (2,4,6,8)
  #--------------------------------------------------------------------------
  def set_direction(d)
    @direction = d if !@direction_fix && d != 0
    @stop_count = 0
  end
  #--------------------------------------------------------------------------
  # * Determine Tile
  #--------------------------------------------------------------------------
  def tile?
    @tile_id > 0 && @priority_type == 0
  end
  #--------------------------------------------------------------------------
  # * Determine Object Character
  #--------------------------------------------------------------------------
  def object_character?
    @tile_id > 0 || @character_name[0, 1] == '!'
  end
  #--------------------------------------------------------------------------
  # * Get Number of Pixels to Shift Up from Tile Position
  #--------------------------------------------------------------------------
  def shift_y
    object_character? ? 0 : 4
  end
  #--------------------------------------------------------------------------
  # * Get Screen X-Coordinates
  #--------------------------------------------------------------------------
  def screen_x
    $game_map.adjust_x(@real_x) * 32 + 16
  end
  #--------------------------------------------------------------------------
  # * Get Screen Y-Coordinates
  #--------------------------------------------------------------------------
  def screen_y
    $game_map.adjust_y(@real_y) * 32 + 32 - shift_y - jump_height
  end
  #--------------------------------------------------------------------------
  # * Get Screen Z-Coordinates
  #--------------------------------------------------------------------------
  def screen_z
    @priority_type * 100
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    update_animation
    return update_jump if jumping?
    return update_move if moving?
    return update_stop
  end
  #--------------------------------------------------------------------------
  # * Update While Jumping
  #--------------------------------------------------------------------------
  def update_jump
    @jump_count -= 1
    @real_x = (@real_x * @jump_count + @x) / (@jump_count + 1.0)
    @real_y = (@real_y * @jump_count + @y) / (@jump_count + 1.0)
    update_bush_depth
    if @jump_count == 0
      @real_x = @x = $game_map.round_x(@x)
      @real_y = @y = $game_map.round_y(@y)
    end
  end
  #--------------------------------------------------------------------------
  # * Update While Moving
  #--------------------------------------------------------------------------
  def update_move
    @real_x = [@real_x - distance_per_frame, @x].max if @x < @real_x
    @real_x = [@real_x + distance_per_frame, @x].min if @x > @real_x
    @real_y = [@real_y - distance_per_frame, @y].max if @y < @real_y
    @real_y = [@real_y + distance_per_frame, @y].min if @y > @real_y
    update_bush_depth unless moving?
  end
  #--------------------------------------------------------------------------
  # * Update While Stopped
  #--------------------------------------------------------------------------
  def update_stop
    @stop_count += 1 unless @locked
  end
  #--------------------------------------------------------------------------
  # * Update Walking/Stepping Animation
  #--------------------------------------------------------------------------
  def update_animation
    update_anime_count
    if @anime_count > 18 - real_move_speed * 2
      update_anime_pattern
      @anime_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # * Update Animation Count
  #--------------------------------------------------------------------------
  def update_anime_count
    if moving? && @walk_anime
      @anime_count += 1.5
    elsif @step_anime || @pattern != @original_pattern
      @anime_count += 1
    end
  end
  #--------------------------------------------------------------------------
  # * Update Animation Pattern
  #--------------------------------------------------------------------------
  def update_anime_pattern
    if !@step_anime && @stop_count > 0
      @pattern = @original_pattern
    else
      @pattern = (@pattern + 1) % 4
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Ladder
  #--------------------------------------------------------------------------
  def ladder?
    $game_map.ladder?(@x, @y)
  end
  #--------------------------------------------------------------------------
  # * Update Bush Depth
  #--------------------------------------------------------------------------
  def update_bush_depth
    if normal_priority? && !object_character? && bush? && !jumping?
      @bush_depth = 8 unless moving?
    else
      @bush_depth = 0
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Bush
  #--------------------------------------------------------------------------
  def bush?
    $game_map.bush?(@x, @y)
  end
  #--------------------------------------------------------------------------
  # * Get Terrain Tag
  #--------------------------------------------------------------------------
  def terrain_tag
    $game_map.terrain_tag(@x, @y)
  end
  #--------------------------------------------------------------------------
  # * Get Region ID
  #--------------------------------------------------------------------------
  def region_id
    $game_map.region_id(@x, @y)
  end
  #--------------------------------------------------------------------------
  # * Increase Steps
  #--------------------------------------------------------------------------
  def increase_steps
    set_direction(8) if ladder?
    @stop_count = 0
    update_bush_depth
  end
  #--------------------------------------------------------------------------
  # * Change Graphics
  #     character_name  : new character graphic filename
  #     character_index : new character graphic index
  #--------------------------------------------------------------------------
  def set_graphic(character_name, character_index)
    @tile_id = 0
    @character_name = character_name
    @character_index = character_index
    @original_pattern = 1
  end
  #--------------------------------------------------------------------------
  # * Determine Triggering of Frontal Touch Event
  #--------------------------------------------------------------------------
  def check_event_trigger_touch_front
    x2 = $game_map.round_x_with_direction(@x, @direction)
    y2 = $game_map.round_y_with_direction(@y, @direction)
    check_event_trigger_touch(x2, y2)
  end
  #--------------------------------------------------------------------------
  # * Determine if Touch Event is Triggered
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    return false
  end
  #--------------------------------------------------------------------------
  # * Move Straight
  #     d:        Direction (2,4,6,8)
  #     turn_ok : Allows change of direction on the spot
  #--------------------------------------------------------------------------
  def move_straight(d, turn_ok = true)
    @move_succeed = passable?(@x, @y, d)
    if @move_succeed
      set_direction(d)
      @x = $game_map.round_x_with_direction(@x, d)
      @y = $game_map.round_y_with_direction(@y, d)
      @real_x = $game_map.x_with_direction(@x, reverse_dir(d))
      @real_y = $game_map.y_with_direction(@y, reverse_dir(d))
      increase_steps
    elsif turn_ok
      set_direction(d)
      check_event_trigger_touch_front
    end
  end
  #--------------------------------------------------------------------------
  # * Move Diagonally
  #     horz:  Horizontal (4 or 6)
  #     vert:  Vertical (2 or 8)
  #--------------------------------------------------------------------------
  def move_diagonal(horz, vert)
    @move_succeed = diagonal_passable?(x, y, horz, vert)
    if @move_succeed
      @x = $game_map.round_x_with_direction(@x, horz)
      @y = $game_map.round_y_with_direction(@y, vert)
      @real_x = $game_map.x_with_direction(@x, reverse_dir(horz))
      @real_y = $game_map.y_with_direction(@y, reverse_dir(vert))
      increase_steps
    end
    set_direction(horz) if @direction == reverse_dir(horz)
    set_direction(vert) if @direction == reverse_dir(vert)
  end
end
