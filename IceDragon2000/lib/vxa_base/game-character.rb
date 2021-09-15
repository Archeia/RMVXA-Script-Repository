#encoding:UTF-8
# Game_Character
#==============================================================================
# ** Game_Character
#------------------------------------------------------------------------------
#  A character class with mainly movement route and other such processing
# added. It is used as a super class of Game_Player, Game_Follower,
# GameVehicle, and Game_Event.
#==============================================================================

class Game_Character < Game_CharacterBase
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  ROUTE_END               = 0             # End of Move Route
  ROUTE_MOVE_DOWN         = 1             # Move Down
  ROUTE_MOVE_LEFT         = 2             # Move Left
  ROUTE_MOVE_RIGHT        = 3             # Move Right
  ROUTE_MOVE_UP           = 4             # Move Up
  ROUTE_MOVE_LOWER_L      = 5             # Move Lower Left
  ROUTE_MOVE_LOWER_R      = 6             # Move Lower Right
  ROUTE_MOVE_UPPER_L      = 7             # Move Upper Left
  ROUTE_MOVE_UPPER_R      = 8             # Move Upper Right
  ROUTE_MOVE_RANDOM       = 9             # Move at Random
  ROUTE_MOVE_TOWARD       = 10            # Move toward Player
  ROUTE_MOVE_AWAY         = 11            # Move away from Player
  ROUTE_MOVE_FORWARD      = 12            # 1 Step Forward
  ROUTE_MOVE_BACKWARD     = 13            # 1 Step Backward
  ROUTE_JUMP              = 14            # Jump
  ROUTE_WAIT              = 15            # Wait
  ROUTE_TURN_DOWN         = 16            # Turn Down
  ROUTE_TURN_LEFT         = 17            # Turn Left
  ROUTE_TURN_RIGHT        = 18            # Turn Right
  ROUTE_TURN_UP           = 19            # Turn Up
  ROUTE_TURN_90D_R        = 20            # Turn 90 Degrees Right
  ROUTE_TURN_90D_L        = 21            # Turn 90 Degrees Left
  ROUTE_TURN_180D         = 22            # Turn 180 Degrees
  ROUTE_TURN_90D_R_L      = 23            # Turn 90 Degrees Right/Left
  ROUTE_TURN_RANDOM       = 24            # Turn at Random
  ROUTE_TURN_TOWARD       = 25            # Turn toward player
  ROUTE_TURN_AWAY         = 26            # Turn away from Player
  ROUTE_SWITCH_ON         = 27            # Switch ON
  ROUTE_SWITCH_OFF        = 28            # Switch OFF
  ROUTE_CHANGE_SPEED      = 29            # Change Speed
  ROUTE_CHANGE_FREQ       = 30            # Change Frequency
  ROUTE_WALK_ANIME_ON     = 31            # Walking Animation ON
  ROUTE_WALK_ANIME_OFF    = 32            # Walking Animation OFF
  ROUTE_STEP_ANIME_ON     = 33            # Stepping Animation ON
  ROUTE_STEP_ANIME_OFF    = 34            # Stepping Animation OFF
  ROUTE_DIR_FIX_ON        = 35            # Direction Fix ON
  ROUTE_DIR_FIX_OFF       = 36            # Direction Fix OFF
  ROUTE_THROUGH_ON        = 37            # Pass-Through ON
  ROUTE_THROUGH_OFF       = 38            # Pass-Through OFF
  ROUTE_TRANSPARENT_ON    = 39            # Transparent ON
  ROUTE_TRANSPARENT_OFF   = 40            # Transparent OFF
  ROUTE_CHANGE_GRAPHIC    = 41            # Change Graphic
  ROUTE_CHANGE_OPACITY    = 42            # Change Opacity
  ROUTE_CHANGE_BLENDING   = 43            # Change Blending
  ROUTE_PLAY_SE           = 44            # Play SE
  ROUTE_SCRIPT            = 45            # Script
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :move_route_forcing       # forced move route flag
  #--------------------------------------------------------------------------
  # * Initialize Public Member Variables
  #--------------------------------------------------------------------------
  def init_public_members
    super
    @move_route_forcing = false
  end
  #--------------------------------------------------------------------------
  # * Initialize Private Member Variables
  #--------------------------------------------------------------------------
  def init_private_members
    super
    @move_route = nil                 # Move route
    @move_route_index = 0             # Move route execution position
    @original_move_route = nil        # Original move route
    @original_move_route_index = 0    # Original move route execution position
    @wait_count = 0                   # Wait count
  end
  #--------------------------------------------------------------------------
  # * Memorize Move Route
  #--------------------------------------------------------------------------
  def memorize_move_route
    @original_move_route        = @move_route
    @original_move_route_index  = @move_route_index
  end
  #--------------------------------------------------------------------------
  # * Restore Move Route
  #--------------------------------------------------------------------------
  def restore_move_route
    @move_route           = @original_move_route
    @move_route_index     = @original_move_route_index
    @original_move_route  = nil
  end
  #--------------------------------------------------------------------------
  # * Force Move Route
  #--------------------------------------------------------------------------
  def force_move_route(move_route)
    memorize_move_route unless @original_move_route
    @move_route = move_route
    @move_route_index = 0
    @move_route_forcing = true
    @prelock_direction = 0
    @wait_count = 0
  end
  #--------------------------------------------------------------------------
  # * Update While Stopped
  #--------------------------------------------------------------------------
  def update_stop
    super
    update_routine_move if @move_route_forcing
  end
  #--------------------------------------------------------------------------
  # * Update Move Along Route
  #--------------------------------------------------------------------------
  def update_routine_move
    if @wait_count > 0
      @wait_count -= 1
    else
      @move_succeed = true
      command = @move_route.list[@move_route_index]
      if command
        process_move_command(command)
        advance_move_route_index
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Process Move Command
  #--------------------------------------------------------------------------
  def process_move_command(command)
    params = command.parameters
    case command.code
    when ROUTE_END;               process_route_end
    when ROUTE_MOVE_DOWN;         move_straight(2)
    when ROUTE_MOVE_LEFT;         move_straight(4)
    when ROUTE_MOVE_RIGHT;        move_straight(6)
    when ROUTE_MOVE_UP;           move_straight(8)
    when ROUTE_MOVE_LOWER_L;      move_diagonal(4, 2)
    when ROUTE_MOVE_LOWER_R;      move_diagonal(6, 2)
    when ROUTE_MOVE_UPPER_L;      move_diagonal(4, 8)
    when ROUTE_MOVE_UPPER_R;      move_diagonal(6, 8)
    when ROUTE_MOVE_RANDOM;       move_random
    when ROUTE_MOVE_TOWARD;       move_toward_player
    when ROUTE_MOVE_AWAY;         move_away_from_player
    when ROUTE_MOVE_FORWARD;      move_forward
    when ROUTE_MOVE_BACKWARD;     move_backward
    when ROUTE_JUMP;              jump(params[0], params[1])
    when ROUTE_WAIT;              @wait_count = params[0] - 1
    when ROUTE_TURN_DOWN;         set_direction(2)
    when ROUTE_TURN_LEFT;         set_direction(4)
    when ROUTE_TURN_RIGHT;        set_direction(6)
    when ROUTE_TURN_UP;           set_direction(8)
    when ROUTE_TURN_90D_R;        turn_right_90
    when ROUTE_TURN_90D_L;        turn_left_90
    when ROUTE_TURN_180D;         turn_180
    when ROUTE_TURN_90D_R_L;      turn_right_or_left_90
    when ROUTE_TURN_RANDOM;       turn_random
    when ROUTE_TURN_TOWARD;       turn_toward_player
    when ROUTE_TURN_AWAY;         turn_away_from_player
    when ROUTE_SWITCH_ON;         $game_switches[params[0]] = true
    when ROUTE_SWITCH_OFF;        $game_switches[params[0]] = false
    when ROUTE_CHANGE_SPEED;      @move_speed = params[0]
    when ROUTE_CHANGE_FREQ;       @move_frequency = params[0]
    when ROUTE_WALK_ANIME_ON;     @walk_anime = true
    when ROUTE_WALK_ANIME_OFF;    @walk_anime = false
    when ROUTE_STEP_ANIME_ON;     @step_anime = true
    when ROUTE_STEP_ANIME_OFF;    @step_anime = false
    when ROUTE_DIR_FIX_ON;        @direction_fix = true
    when ROUTE_DIR_FIX_OFF;       @direction_fix = false
    when ROUTE_THROUGH_ON;        @through = true
    when ROUTE_THROUGH_OFF;       @through = false
    when ROUTE_TRANSPARENT_ON;    @transparent = true
    when ROUTE_TRANSPARENT_OFF;   @transparent = false
    when ROUTE_CHANGE_GRAPHIC;    set_graphic(params[0], params[1])
    when ROUTE_CHANGE_OPACITY;    @opacity = params[0]
    when ROUTE_CHANGE_BLENDING;   @blend_type = params[0]
    when ROUTE_PLAY_SE;           params[0].play
    when ROUTE_SCRIPT;            eval(params[0])
    end
  end
  #--------------------------------------------------------------------------
  # * Calculate Distance in X Axis Direction
  #--------------------------------------------------------------------------
  def distance_x_from(x)
    result = @x - x
    if $game_map.loop_horizontal? && result.abs > $game_map.width / 2
      if result < 0
        result += $game_map.width
      else
        result -= $game_map.width
      end
    end
    result
  end
  #--------------------------------------------------------------------------
  # * Calculate Distance in Y Axis Direction
  #--------------------------------------------------------------------------
  def distance_y_from(y)
    result = @y - y
    if $game_map.loop_vertical? && result.abs > $game_map.height / 2
      if result < 0
        result += $game_map.height
      else
        result -= $game_map.height
      end
    end
    result
  end
  #--------------------------------------------------------------------------
  # * Move at Random
  #--------------------------------------------------------------------------
  def move_random
    move_straight(2 + rand(4) * 2, false)
  end
  #--------------------------------------------------------------------------
  # * Move Toward Character
  #--------------------------------------------------------------------------
  def move_toward_character(character)
    sx = distance_x_from(character.x)
    sy = distance_y_from(character.y)
    if sx.abs > sy.abs
      move_straight(sx > 0 ? 4 : 6)
      move_straight(sy > 0 ? 8 : 2) if !@move_succeed && sy != 0
    elsif sy != 0
      move_straight(sy > 0 ? 8 : 2)
      move_straight(sx > 0 ? 4 : 6) if !@move_succeed && sx != 0
    end
  end
  #--------------------------------------------------------------------------
  # * Move Away from Character
  #--------------------------------------------------------------------------
  def move_away_from_character(character)
    sx = distance_x_from(character.x)
    sy = distance_y_from(character.y)
    if sx.abs > sy.abs
      move_straight(sx > 0 ? 6 : 4)
      move_straight(sy > 0 ? 2 : 8) if !@move_succeed && sy != 0
    elsif sy != 0
      move_straight(sy > 0 ? 2 : 8)
      move_straight(sx > 0 ? 6 : 4) if !@move_succeed && sx != 0
    end
  end
  #--------------------------------------------------------------------------
  # * Turn Toward Character
  #--------------------------------------------------------------------------
  def turn_toward_character(character)
    sx = distance_x_from(character.x)
    sy = distance_y_from(character.y)
    if sx.abs > sy.abs
      set_direction(sx > 0 ? 4 : 6)
    elsif sy != 0
      set_direction(sy > 0 ? 8 : 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Turn Away from Character
  #--------------------------------------------------------------------------
  def turn_away_from_character(character)
    sx = distance_x_from(character.x)
    sy = distance_y_from(character.y)
    if sx.abs > sy.abs
      set_direction(sx > 0 ? 6 : 4)
    elsif sy != 0
      set_direction(sy > 0 ? 2 : 8)
    end
  end
  #--------------------------------------------------------------------------
  # * Turn toward Player
  #--------------------------------------------------------------------------
  def turn_toward_player
    turn_toward_character($game_player)
  end
  #--------------------------------------------------------------------------
  # * Turn away from Player
  #--------------------------------------------------------------------------
  def turn_away_from_player
    turn_away_from_character($game_player)
  end
  #--------------------------------------------------------------------------
  # * Move toward Player
  #--------------------------------------------------------------------------
  def move_toward_player
    move_toward_character($game_player)
  end
  #--------------------------------------------------------------------------
  # * Move away from Player
  #--------------------------------------------------------------------------
  def move_away_from_player
    move_away_from_character($game_player)
  end
  #--------------------------------------------------------------------------
  # * 1 Step Forward
  #--------------------------------------------------------------------------
  def move_forward
    move_straight(@direction)
  end
  #--------------------------------------------------------------------------
  # * 1 Step Backward
  #--------------------------------------------------------------------------
  def move_backward
    last_direction_fix = @direction_fix
    @direction_fix = true
    move_straight(reverse_dir(@direction), false)
    @direction_fix = last_direction_fix
  end
  #--------------------------------------------------------------------------
  # * Jump
  #     x_plus : x-coordinate plus value
  #     y_plus : y-coordinate plus value
  #--------------------------------------------------------------------------
  def jump(x_plus, y_plus)
    if x_plus.abs > y_plus.abs
      set_direction(x_plus < 0 ? 4 : 6) if x_plus != 0
    else
      set_direction(y_plus < 0 ? 8 : 2) if y_plus != 0
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
  # * Process Move Route End
  #--------------------------------------------------------------------------
  def process_route_end
    if @move_route.repeat
      @move_route_index = -1
    elsif @move_route_forcing
      @move_route_forcing = false
      restore_move_route
    end
  end
  #--------------------------------------------------------------------------
  # * Advance Execution Position of Move Route
  #--------------------------------------------------------------------------
  def advance_move_route_index
    @move_route_index += 1 if @move_succeed || @move_route.skippable
  end
  #--------------------------------------------------------------------------
  # * Turn 90° Right
  #--------------------------------------------------------------------------
  def turn_right_90
    case @direction
    when 2;  set_direction(4)
    when 4;  set_direction(8)
    when 6;  set_direction(2)
    when 8;  set_direction(6)
    end
  end
  #--------------------------------------------------------------------------
  # * Turn 90° Left
  #--------------------------------------------------------------------------
  def turn_left_90
    case @direction
    when 2;  set_direction(6)
    when 4;  set_direction(2)
    when 6;  set_direction(8)
    when 8;  set_direction(4)
    end
  end
  #--------------------------------------------------------------------------
  # * Turn 180°
  #--------------------------------------------------------------------------
  def turn_180
    set_direction(reverse_dir(@direction))
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
    set_direction(2 + rand(4) * 2)
  end
  #--------------------------------------------------------------------------
  # * Swap Character Positions
  #--------------------------------------------------------------------------
  def swap(character)
    new_x = character.x
    new_y = character.y
    character.moveto(x, y)
    moveto(new_x, new_y)
  end
end
