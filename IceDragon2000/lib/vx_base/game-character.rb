#encoding:UTF-8
# Game_Character
#==============================================================================
# ** Game_Character
#------------------------------------------------------------------------------
#  This class deals with characters. It's used as a superclass of the
# Game_Player and Game_Event classes.
#==============================================================================

class Game_Character
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :id                       # ID
  attr_reader   :x                        # map x-coordinate (logical)
  attr_reader   :y                        # map y-coordinate (logical)
  attr_reader   :real_x                   # map x-coordinate (actual-x * 256)
  attr_reader   :real_y                   # map y-coordinate (actual-y * 256)
  attr_reader   :tile_id                  # tile ID (invalid if 0)
  attr_reader   :character_name           # character graphic filename
  attr_reader   :character_index          # character graphic index
  attr_reader   :opacity                  # opacity level
  attr_reader   :blend_type               # blending method
  attr_reader   :direction                # direction
  attr_reader   :pattern                  # pattern
  attr_reader   :move_route_forcing       # forced move route flag
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
    @id = 0
    @x = 0
    @y = 0
    @real_x = 0
    @real_y = 0
    @tile_id = 0
    @character_name = ""
    @character_index = 0
    @opacity = 255
    @blend_type = 0
    @direction = 2
    @pattern = 1
    @move_route_forcing = false
    @priority_type = 1
    @through = false
    @bush_depth = 0
    @animation_id = 0
    @balloon_id = 0
    @transparent = false
    @original_direction = 2               # Original direction
    @original_pattern = 1                 # Original pattern
    @move_type = 0                        # Movement type
    @move_speed = 4                       # Movement speed
    @move_frequency = 6                   # Movement frequency
    @move_route = nil                     # Move route
    @move_route_index = 0                 # Move route index
    @original_move_route = nil            # Original move route
    @original_move_route_index = 0        # Original move route index
    @walk_anime = true                    # Walking animation
    @step_anime = false                   # Stepping animation
    @direction_fix = false                # Fixed direction
    @anime_count = 0                      # Animation count
    @stop_count = 0                       # Stop count
    @jump_count = 0                       # Jump count
    @jump_peak = 0                        # Jump peak count
    @wait_count = 0                       # Wait count
    @locked = false                       # Locked flag
    @prelock_direction = 0                # Direction before lock
    @move_failed = false                  # Movement failed flag
  end
  #--------------------------------------------------------------------------
  # * Determine if Moving
  #    Compare with logical coordinates.
  #--------------------------------------------------------------------------
  def moving?
    return (@real_x != @x * 256 or @real_y != @y * 256)
  end
  #--------------------------------------------------------------------------
  # * Determine if Jumping
  #--------------------------------------------------------------------------
  def jumping?
    return @jump_count > 0
  end
  #--------------------------------------------------------------------------
  # * Determine if Stopping
  #--------------------------------------------------------------------------
  def stopping?
    return (not (moving? or jumping?))
  end
  #--------------------------------------------------------------------------
  # * Determine if Dashing
  #--------------------------------------------------------------------------
  def dash?
    return false
  end
  #--------------------------------------------------------------------------
  # * Determine if Debug Pass-through State
  #--------------------------------------------------------------------------
  def debug_through?
    return false
  end
  #--------------------------------------------------------------------------
  # * Straighten Position
  #--------------------------------------------------------------------------
  def straighten
    @pattern = 1 if @walk_anime or @step_anime
    @anime_count = 0
  end
  #--------------------------------------------------------------------------
  # * Force Move Route
  #     move_route : new move route
  #--------------------------------------------------------------------------
  def force_move_route(move_route)
    if @original_move_route == nil
      @original_move_route = @move_route
      @original_move_route_index = @move_route_index
    end
    @move_route = move_route
    @move_route_index = 0
    @move_route_forcing = true
    @prelock_direction = 0
    @wait_count = 0
    move_type_custom
  end
  #--------------------------------------------------------------------------
  # * Determine Coordinate Match
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def pos?(x, y)
    return (@x == x and @y == y)
  end
  #--------------------------------------------------------------------------
  # * Coordinate Match and "Passage OFF" Determination (nt = No Through)
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def pos_nt?(x, y)
    return (pos?(x, y) and not @through)
  end
  #--------------------------------------------------------------------------
  # * Determine if Passable
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def passable?(x, y)
    x = $game_map.round_x(x)                        # Horizontal loop adj.
    y = $game_map.round_y(y)                        # Vertical loop adj.
    return false unless $game_map.valid?(x, y)      # Outside map?
    return true if @through or debug_through?       # Through ON?
    return false unless map_passable?(x, y)         # Map Impassable?
    return false if collide_with_characters?(x, y)  # Collide with character?
    return true                                     # Passable
  end
  #--------------------------------------------------------------------------
  # * Determine if Map is Passable
  #     x : x-coordinate
  #     y : y-coordinate
  #    Gets whether the tile at the designated coordinates is passable.
  #--------------------------------------------------------------------------
  def map_passable?(x, y)
    return $game_map.passable?(x, y)
  end
  #--------------------------------------------------------------------------
  # * Determine Character Collision
  #     x : x-coordinate
  #     y : y-coordinate
  #    Detects normal character collision, including the player and vehicles.
  #--------------------------------------------------------------------------
  def collide_with_characters?(x, y)
    for event in $game_map.events_xy(x, y)          # Matches event position
      unless event.through                          # Passage OFF?
        return true if self.is_a?(Game_Event)       # Self is event
        return true if event.priority_type == 1     # Target is normal char
      end
    end
    if @priority_type == 1                          # Self is normal char
      return true if $game_player.pos_nt?(x, y)     # Matches player position
      return true if $game_map.boat.pos_nt?(x, y)   # Matches boat position
      return true if $game_map.ship.pos_nt?(x, y)   # Matches ship position
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Lock (process for stopping event in progress)
  #--------------------------------------------------------------------------
  def lock
    unless @locked
      @prelock_direction = @direction
      turn_toward_player
      @locked = true
    end
  end
  #--------------------------------------------------------------------------
  # * Unlock
  #--------------------------------------------------------------------------
  def unlock
    if @locked
      @locked = false
      set_direction(@prelock_direction)
    end
  end
  #--------------------------------------------------------------------------
  # * Move to Designated Position
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def moveto(x, y)
    @x = x % $game_map.width
    @y = y % $game_map.height
    @real_x = @x * 256
    @real_y = @y * 256
    @prelock_direction = 0
    straighten
    update_bush_depth
  end
  #--------------------------------------------------------------------------
  # * Change Direction to Designated Direction
  #     direction : Direction
  #--------------------------------------------------------------------------
  def set_direction(direction)
    if not @direction_fix and direction != 0
      @direction = direction
      @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # * Determine Object Type
  #--------------------------------------------------------------------------
  def object?
    return (@tile_id > 0 or @character_name[0, 1] == '!')
  end
  #--------------------------------------------------------------------------
  # * Get Screen X-Coordinates
  #--------------------------------------------------------------------------
  def screen_x
    return ($game_map.adjust_x(@real_x) + 8007) / 8 - 1000 + 16
  end
  #--------------------------------------------------------------------------
  # * Get Screen Y-Coordinates
  #--------------------------------------------------------------------------
  def screen_y
    y = ($game_map.adjust_y(@real_y) + 8007) / 8 - 1000 + 32
    y -= 4 unless object?
    if @jump_count >= @jump_peak
      n = @jump_count - @jump_peak
    else
      n = @jump_peak - @jump_count
    end
    return y - (@jump_peak * @jump_peak - n * n) / 2
  end
  #--------------------------------------------------------------------------
  # * Get Screen Z-Coordinates
  #--------------------------------------------------------------------------
  def screen_z
    if @priority_type == 2
      return 200
    elsif @priority_type == 0
      return 60
    elsif @tile_id > 0
      pass = $game_map.passages[@tile_id]
      if pass & 0x10 == 0x10    # [☆]
        return 160
      else
        return 40
      end
    else
      return 100
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    if jumping?                 # Jumping
      update_jump
    elsif moving?               # Moving
      update_move
    else                        # Stopped
      update_stop
    end
    if @wait_count > 0          # Waiting
      @wait_count -= 1
    elsif @move_route_forcing   # Forced move route
      move_type_custom
    elsif not @locked           # Not locked
      update_self_movement
    end
    update_animation
  end
  #--------------------------------------------------------------------------
  # * Update While Jumping
  #--------------------------------------------------------------------------
  def update_jump
    @jump_count -= 1
    @real_x = (@real_x * @jump_count + @x * 256) / (@jump_count + 1)
    @real_y = (@real_y * @jump_count + @y * 256) / (@jump_count + 1)
    update_bush_depth
  end
  #--------------------------------------------------------------------------
  # * Update While Moving
  #--------------------------------------------------------------------------
  def update_move
    distance = 2 ** @move_speed   # Convert to movement distance
    distance *= 2 if dash?        # If dashing, double it
    @real_x = [@real_x - distance, @x * 256].max if @x * 256 < @real_x
    @real_x = [@real_x + distance, @x * 256].min if @x * 256 > @real_x
    @real_y = [@real_y - distance, @y * 256].max if @y * 256 < @real_y
    @real_y = [@real_y + distance, @y * 256].min if @y * 256 > @real_y
    update_bush_depth unless moving?
    if @walk_anime
      @anime_count += 1.5
    elsif @step_anime
      @anime_count += 1
    end
  end
  #--------------------------------------------------------------------------
  # * Update While Stopped
  #--------------------------------------------------------------------------
  def update_stop
    if @step_anime
      @anime_count += 1
    elsif @pattern != @original_pattern
      @anime_count += 1.5
    end
    @stop_count += 1 unless @locked
  end
  #--------------------------------------------------------------------------
  # * Update During Self movement
  #--------------------------------------------------------------------------
  def update_self_movement
    if @stop_count > 30 * (5 - @move_frequency)
      case @move_type
      when 1;  move_type_random
      when 2;  move_type_toward_player
      when 3;  move_type_custom
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Update Animation Count
  #--------------------------------------------------------------------------
  def update_animation
    speed = @move_speed + (dash? ? 1 : 0)
    if @anime_count > 18 - speed * 2
      if not @step_anime and @stop_count > 0
        @pattern = @original_pattern
      else
        @pattern = (@pattern + 1) % 4
      end
      @anime_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # * Update Bush Depth
  #--------------------------------------------------------------------------
  def update_bush_depth
    if object? or @priority_type != 1 or @jump_count > 0
      @bush_depth = 0
    else
      bush = $game_map.bush?(@x, @y)
      if bush and not moving?
        @bush_depth = 8
      elsif not bush
        @bush_depth = 0
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Move Type : Random
  #--------------------------------------------------------------------------
  def move_type_random
    case rand(6)
    when 0..1;  move_random
    when 2..4;  move_forward
    when 5;     @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # * Move Type : Approach
  #--------------------------------------------------------------------------
  def move_type_toward_player
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    if sx.abs + sy.abs >= 20
      move_random
    else
      case rand(6)
      when 0..3;  move_toward_player
      when 4;     move_random
      when 5;     move_forward
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Move Type : Custom
  #--------------------------------------------------------------------------
  def move_type_custom
    if stopping?
      command = @move_route.list[@move_route_index]   # Get movement command
      @move_failed = false
      if command.code == 0                            # End of list
        if @move_route.repeat                         # [Repeat Action]
          @move_route_index = 0
        elsif @move_route_forcing                     # Forced move route
          @move_route_forcing = false                 # Cancel forcing
          @move_route = @original_move_route          # Restore original
          @move_route_index = @original_move_route_index
          @original_move_route = nil
        end
      else
        case command.code
        when 1    # Move Down
          move_down
        when 2    # Move Left
          move_left
        when 3    # Move Right
          move_right
        when 4    # Move Up
          move_up
        when 5    # Move Lower Left
          move_lower_left
        when 6    # Move Lower Right
          move_lower_right
        when 7    # Move Upper Left
          move_upper_left
        when 8    # Move Upper Right
          move_upper_right
        when 9    # Move at Random
          move_random
        when 10   # Move toward Player
          move_toward_player
        when 11   # Move away from Player
          move_away_from_player
        when 12   # 1 Step Forward
          move_forward
        when 13   # 1 Step Backwards
          move_backward
        when 14   # Jump
          jump(command.parameters[0], command.parameters[1])
        when 15   # Wait
          @wait_count = command.parameters[0] - 1
        when 16   # Turn Down
          turn_down
        when 17   # Turn Left
          turn_left
        when 18   # Turn Right
          turn_right
        when 19   # Turn Up
          turn_up
        when 20   # Turn 90° Right
          turn_right_90
        when 21   # Turn 90° Left
          turn_left_90
        when 22   # Turn 180°
          turn_180
        when 23   # Turn 90° Right or Left
          turn_right_or_left_90
        when 24   # Turn at Random
          turn_random
        when 25   # Turn toward Player
          turn_toward_player
        when 26   # Turn away from Player
          turn_away_from_player
        when 27   # Switch ON
          $game_switches[command.parameters[0]] = true
          $game_map.need_refresh = true
        when 28   # Switch OFF
          $game_switches[command.parameters[0]] = false
          $game_map.need_refresh = true
        when 29   # Change Speed
          @move_speed = command.parameters[0]
        when 30   # Change Frequency
          @move_frequency = command.parameters[0]
        when 31   # Walking Animation ON
          @walk_anime = true
        when 32   # Walking Animation OFF
          @walk_anime = false
        when 33   # Stepping Animation ON
          @step_anime = true
        when 34   # Stepping Animation OFF
          @step_anime = false
        when 35   # Direction Fix ON
          @direction_fix = true
        when 36   # Direction Fix OFF
          @direction_fix = false
        when 37   # Through ON
          @through = true
        when 38   # Through OFF
          @through = false
        when 39   # Transparent ON
          @transparent = true
        when 40   # Transparent OFF
          @transparent = false
        when 41   # Change Graphic
          set_graphic(command.parameters[0], command.parameters[1])
        when 42   # Change Opacity
          @opacity = command.parameters[0]
        when 43   # Change Blending
          @blend_type = command.parameters[0]
        when 44   # Play SE
          command.parameters[0].play
        when 45   # Script
          eval(command.parameters[0])
        end
        if not @move_route.skippable and @move_failed
          return  # [Skip if Cannot Move] OFF & movement failure
        end
        @move_route_index += 1
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Increase Steps
  #--------------------------------------------------------------------------
  def increase_steps
    @stop_count = 0
    update_bush_depth
  end
  #--------------------------------------------------------------------------
  # * Calculate X Distance From Player
  #--------------------------------------------------------------------------
  def distance_x_from_player
    sx = @x - $game_player.x
    if $game_map.loop_horizontal?         # When looping horizontally
      if sx.abs > $game_map.width / 2     # Larger than half the map width?
        sx -= $game_map.width             # Subtract map width
      end
    end
    return sx
  end
  #--------------------------------------------------------------------------
  # * Calculate Y Distance From Player
  #--------------------------------------------------------------------------
  def distance_y_from_player
    sy = @y - $game_player.y
    if $game_map.loop_vertical?           # When looping vertically
      if sy.abs > $game_map.height / 2    # Larger than half the map height?
        sy -= $game_map.height            # Subtract map height
      end
    end
    return sy
  end
  #--------------------------------------------------------------------------
  # * Move Down
  #     turn_ok : Allows change of direction on the spot
  #--------------------------------------------------------------------------
  def move_down(turn_ok = true)
    if passable?(@x, @y+1)                  # Passable
      turn_down
      @y = $game_map.round_y(@y+1)
      @real_y = (@y-1)*256
      increase_steps
      @move_failed = false
    else                                    # Impassable
      turn_down if turn_ok
      check_event_trigger_touch(@x, @y+1)   # Touch event is triggered?
      @move_failed = true
    end
  end
  #--------------------------------------------------------------------------
  # * Move Left
  #     turn_ok : Allows change of direction on the spot
  #--------------------------------------------------------------------------
  def move_left(turn_ok = true)
    if passable?(@x-1, @y)                  # Passable
      turn_left
      @x = $game_map.round_x(@x-1)
      @real_x = (@x+1)*256
      increase_steps
      @move_failed = false
    else                                    # Impassable
      turn_left if turn_ok
      check_event_trigger_touch(@x-1, @y)   # Touch event is triggered?
      @move_failed = true
    end
  end
  #--------------------------------------------------------------------------
  # * Move Right
  #     turn_ok : Allows change of direction on the spot
  #--------------------------------------------------------------------------
  def move_right(turn_ok = true)
    if passable?(@x+1, @y)                  # Passable
      turn_right
      @x = $game_map.round_x(@x+1)
      @real_x = (@x-1)*256
      increase_steps
      @move_failed = false
    else                                    # Impassable
      turn_right if turn_ok
      check_event_trigger_touch(@x+1, @y)   # Touch event is triggered?
      @move_failed = true
    end
  end
  #--------------------------------------------------------------------------
  # * Move up
  #     turn_ok : Allows change of direction on the spot
  #--------------------------------------------------------------------------
  def move_up(turn_ok = true)
    if passable?(@x, @y-1)                  # Passable
      turn_up
      @y = $game_map.round_y(@y-1)
      @real_y = (@y+1)*256
      increase_steps
      @move_failed = false
    else                                    # Impassable
      turn_up if turn_ok
      check_event_trigger_touch(@x, @y-1)   # Touch event is triggered?
      @move_failed = true
    end
  end
  #--------------------------------------------------------------------------
  # * Move Lower Left
  #--------------------------------------------------------------------------
  def move_lower_left
    unless @direction_fix
      @direction = (@direction == 6 ? 4 : @direction == 8 ? 2 : @direction)
    end
    if (passable?(@x, @y+1) and passable?(@x-1, @y+1)) or
       (passable?(@x-1, @y) and passable?(@x-1, @y+1))
      @x -= 1
      @y += 1
      increase_steps
      @move_failed = false
    else
      @move_failed = true
    end
  end
  #--------------------------------------------------------------------------
  # * Move Lower Right
  #--------------------------------------------------------------------------
  def move_lower_right
    unless @direction_fix
      @direction = (@direction == 4 ? 6 : @direction == 8 ? 2 : @direction)
    end
    if (passable?(@x, @y+1) and passable?(@x+1, @y+1)) or
       (passable?(@x+1, @y) and passable?(@x+1, @y+1))
      @x += 1
      @y += 1
      increase_steps
      @move_failed = false
    else
      @move_failed = true
    end
  end
  #--------------------------------------------------------------------------
  # * Move Upper Left
  #--------------------------------------------------------------------------
  def move_upper_left
    unless @direction_fix
      @direction = (@direction == 6 ? 4 : @direction == 2 ? 8 : @direction)
    end
    if (passable?(@x, @y-1) and passable?(@x-1, @y-1)) or
       (passable?(@x-1, @y) and passable?(@x-1, @y-1))
      @x -= 1
      @y -= 1
      increase_steps
      @move_failed = false
    else
      @move_failed = true
    end
  end
  #--------------------------------------------------------------------------
  # * Move Upper Right
  #--------------------------------------------------------------------------
  def move_upper_right
    unless @direction_fix
      @direction = (@direction == 4 ? 6 : @direction == 2 ? 8 : @direction)
    end
    if (passable?(@x, @y-1) and passable?(@x+1, @y-1)) or
       (passable?(@x+1, @y) and passable?(@x+1, @y-1))
      @x += 1
      @y -= 1
      increase_steps
      @move_failed = false
    else
      @move_failed = true
    end
  end
  #--------------------------------------------------------------------------
  # * Move at Random
  #--------------------------------------------------------------------------
  def move_random
    case rand(4)
    when 0;  move_down(false)
    when 1;  move_left(false)
    when 2;  move_right(false)
    when 3;  move_up(false)
    end
  end
  #--------------------------------------------------------------------------
  # * Move toward Player
  #--------------------------------------------------------------------------
  def move_toward_player
    sx = distance_x_from_player
    sy = distance_y_from_player
    if sx != 0 or sy != 0
      if sx.abs > sy.abs                  # Horizontal distance is longer
        sx > 0 ? move_left : move_right   # Prioritize left-right
        if @move_failed and sy != 0
          sy > 0 ? move_up : move_down
        end
      else                                # Vertical distance is longer
        sy > 0 ? move_up : move_down      # Prioritize up-down
        if @move_failed and sx != 0
          sx > 0 ? move_left : move_right
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Move away from Player
  #--------------------------------------------------------------------------
  def move_away_from_player
    sx = distance_x_from_player
    sy = distance_y_from_player
    if sx != 0 or sy != 0
      if sx.abs > sy.abs                  # Horizontal distance is longer
        sx > 0 ? move_right : move_left   # Prioritize left-right
        if @move_failed and sy != 0
          sy > 0 ? move_down : move_up
        end
      else                                # Vertical distance is longer
        sy > 0 ? move_down : move_up      # Prioritize up-down
        if @move_failed and sx != 0
          sx > 0 ? move_right : move_left
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 1 Step Forward
  #--------------------------------------------------------------------------
  def move_forward
    case @direction
    when 2;  move_down(false)
    when 4;  move_left(false)
    when 6;  move_right(false)
    when 8;  move_up(false)
    end
  end
  #--------------------------------------------------------------------------
  # * 1 Step Backward
  #--------------------------------------------------------------------------
  def move_backward
    last_direction_fix = @direction_fix
    @direction_fix = true
    case @direction
    when 2;  move_up(false)
    when 4;  move_right(false)
    when 6;  move_left(false)
    when 8;  move_down(false)
    end
    @direction_fix = last_direction_fix
  end
  #--------------------------------------------------------------------------
  # * Jump
  #     x_plus : x-coordinate plus value
  #     y_plus : y-coordinate plus value
  #--------------------------------------------------------------------------
  def jump(x_plus, y_plus)
    if x_plus.abs > y_plus.abs            # Horizontal distance is longer
      x_plus < 0 ? turn_left : turn_right
    elsif x_plus.abs > y_plus.abs         # Vertical distance is longer
      y_plus < 0 ? turn_up : turn_down
    end
    @x += x_plus
    @y += y_plus
    distance = Math.sqrt(x_plus * x_plus + y_plus * y_plus).round
    @jump_peak = 10 + distance - @move_speed
    @jump_count = @jump_peak * 2
    @stop_count = 0
    straighten
  end
  #--------------------------------------------------------------------------
  # * Turn Down
  #--------------------------------------------------------------------------
  def turn_down
    set_direction(2)
  end
  #--------------------------------------------------------------------------
  # * Turn Left
  #--------------------------------------------------------------------------
  def turn_left
    set_direction(4)
  end
  #--------------------------------------------------------------------------
  # * Turn Right
  #--------------------------------------------------------------------------
  def turn_right
    set_direction(6)
  end
  #--------------------------------------------------------------------------
  # * Turn Up
  #--------------------------------------------------------------------------
  def turn_up
    set_direction(8)
  end
  #--------------------------------------------------------------------------
  # * Turn 90° Right
  #--------------------------------------------------------------------------
  def turn_right_90
    case @direction
    when 2;  turn_left
    when 4;  turn_up
    when 6;  turn_down
    when 8;  turn_right
    end
  end
  #--------------------------------------------------------------------------
  # * Turn 90° Left
  #--------------------------------------------------------------------------
  def turn_left_90
    case @direction
    when 2;  turn_right
    when 4;  turn_down
    when 6;  turn_up
    when 8;  turn_left
    end
  end
  #--------------------------------------------------------------------------
  # * Turn 180°
  #--------------------------------------------------------------------------
  def turn_180
    case @direction
    when 2;  turn_up
    when 4;  turn_right
    when 6;  turn_left
    when 8;  turn_down
    end
  end
  #--------------------------------------------------------------------------
  # * Turn 90° Right or Left
  #--------------------------------------------------------------------------
  def turn_right_or_left_90
    case rand(2)
    when 0;  turn_right_90
    when 1;  turn_left_90
    end
  end
  #--------------------------------------------------------------------------
  # * Turn at Random
  #--------------------------------------------------------------------------
  def turn_random
    case rand(4)
    when 0;  turn_up
    when 1;  turn_right
    when 2;  turn_left
    when 3;  turn_down
    end
  end
  #--------------------------------------------------------------------------
  # * Turn toward Player
  #--------------------------------------------------------------------------
  def turn_toward_player
    sx = distance_x_from_player
    sy = distance_y_from_player
    if sx.abs > sy.abs                    # Horizontal distance is longer
      sx > 0 ? turn_left : turn_right
    elsif sx.abs < sy.abs                 # Vertical distance is longer
      sy > 0 ? turn_up : turn_down
    end
  end
  #--------------------------------------------------------------------------
  # * Turn away from Player
  #--------------------------------------------------------------------------
  def turn_away_from_player
    sx = distance_x_from_player
    sy = distance_y_from_player
    if sx.abs > sy.abs                    # Horizontal distance is longer
      sx > 0 ? turn_right : turn_left
    elsif sx.abs < sy.abs                 # Vertical distance is longer
      sy > 0 ? turn_down : turn_up
    end
  end
  #--------------------------------------------------------------------------
  # * Change Graphic
  #     character_name  : new character graphic filename
  #     character_index : new character graphic index
  #--------------------------------------------------------------------------
  def set_graphic(character_name, character_index)
    @tile_id = 0
    @character_name = character_name
    @character_index = character_index
  end
end
