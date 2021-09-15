#encoding:UTF-8
# Game_Player
#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles maps. It includes event starting determinants and map
# scrolling functions. The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  CENTER_X = (544 / 2 - 16) * 8     # Screen center X coordinate * 8
  CENTER_Y = (416 / 2 - 16) * 8     # Screen center Y coordinate * 8
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :vehicle_type       # type of vehicle currenting being ridden
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super
    @vehicle_type = -1
    @vehicle_getting_on = false     # Boarding vehicle flag
    @vehicle_getting_off = false    # Getting off vehicle flag
    @transferring = false           # Player transfer flag
    @new_map_id = 0                 # Destination map ID
    @new_x = 0                      # Destination X coordinate
    @new_y = 0                      # Destination Y coordinate
    @new_direction = 0              # Post-movement direction
    @walking_bgm = nil              # For walking BGM memory
  end
  #--------------------------------------------------------------------------
  # * Determine if Stopping
  #--------------------------------------------------------------------------
  def stopping?
    return false if @vehicle_getting_on
    return false if @vehicle_getting_off
    return super
  end
  #--------------------------------------------------------------------------
  # * Player Transfer Reservation
  #     map_id    : Map ID
  #     x : x-coordinate
  #     y         : y coordinate
  #     direction : post-movement direction
  #--------------------------------------------------------------------------
  def reserve_transfer(map_id, x, y, direction)
    @transferring = true
    @new_map_id = map_id
    @new_x = x
    @new_y = y
    @new_direction = direction
  end
  #--------------------------------------------------------------------------
  # * Determine if Player Transfer is Reserved
  #--------------------------------------------------------------------------
  def transfer?
    return @transferring
  end
  #--------------------------------------------------------------------------
  # * Execute Player Transfer
  #--------------------------------------------------------------------------
  def perform_transfer
    return unless @transferring
    @transferring = false
    set_direction(@new_direction)
    if $game_map.map_id != @new_map_id
      $game_map.setup(@new_map_id)     # Move to other map
    end
    moveto(@new_x, @new_y)
  end
  #--------------------------------------------------------------------------
  # * Determine if Map is Passable
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def map_passable?(x, y)
    case @vehicle_type
    when 0  # Boat
      return $game_map.boat_passable?(x, y)
    when 1  # Ship
      return $game_map.ship_passable?(x, y)
    when 2  # Airship
      return true
    else    # Walking
      return $game_map.passable?(x, y)
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Walking is Possible
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def can_walk?(x, y)
    last_vehicle_type = @vehicle_type   # Remove vehicle type
    @vehicle_type = -1                  # Temporarily set to walking
    result = passable?(x, y)            # Determine if passable
    @vehicle_type = last_vehicle_type   # Restore vehicle type
    return result
  end
  #--------------------------------------------------------------------------
  # * Determine if Airship can Land
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def airship_land_ok?(x, y)
    unless $game_map.airship_land_ok?(x, y)
      return false    # The tile passable attribute is unlandable
    end
    unless $game_map.events_xy(x, y).empty?
      return false    # Cannot land where there is an event
    end
    return true       # Can land
  end
  #--------------------------------------------------------------------------
  # * Determine if Riding in Some Kind of Vehicle
  #--------------------------------------------------------------------------
  def in_vehicle?
    return @vehicle_type >= 0
  end
  #--------------------------------------------------------------------------
  # * Determine if Riding in Airship
  #--------------------------------------------------------------------------
  def in_airship?
    return @vehicle_type == 2
  end
  #--------------------------------------------------------------------------
  # * Determine if Dashing
  #--------------------------------------------------------------------------
  def dash?
    return false if @move_route_forcing
    return false if $game_map.disable_dash?
    return false if in_vehicle?
    return Input.press?(Input::A)
  end
  #--------------------------------------------------------------------------
  # * Determine if Debug Pass-through State
  #--------------------------------------------------------------------------
  def debug_through?
    return false unless $TEST
    return Input.press?(Input::CTRL)
  end
  #--------------------------------------------------------------------------
  # * Set Map Display Position to Center of Screen
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def center(x, y)
    display_x = x * 256 - CENTER_X                    # Calculate coordinates
    unless $game_map.loop_horizontal?                 # No loop horizontally?
      max_x = ($game_map.width - 17) * 256            # Calculate max value
      display_x = [0, [display_x, max_x].min].max     # Adjust coordinates
    end
    display_y = y * 256 - CENTER_Y                    # Calculate coordinates
    unless $game_map.loop_vertical?                   # No loop vertically?
      max_y = ($game_map.height - 13) * 256           # Calculate max value
      display_y = [0, [display_y, max_y].min].max     # Adjust coordinates
    end
    $game_map.set_display_pos(display_x, display_y)   # Change map location
  end
  #--------------------------------------------------------------------------
  # * Move to Designated Position
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def moveto(x, y)
    super
    center(x, y)                                      # Centering
    make_encounter_count                              # Initialize encounter
    if in_vehicle?                                    # Riding in vehicle
      vehicle = $game_map.vehicles[@vehicle_type]     # Get vehicle
      vehicle.refresh                                 # Refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Increase Steps
  #--------------------------------------------------------------------------
  def increase_steps
    super
    return if @move_route_forcing
    return if in_vehicle?
    $game_party.increase_steps
    $game_party.on_player_walk
  end
  #--------------------------------------------------------------------------
  # * Get Encounter Count
  #--------------------------------------------------------------------------
  def encounter_count
    return @encounter_count
  end
  #--------------------------------------------------------------------------
  # * Make Encounter Count
  #--------------------------------------------------------------------------
  def make_encounter_count
    if $game_map.map_id != 0
      n = $game_map.encounter_step
      @encounter_count = rand(n) + rand(n) + 1  # As if rolling 2 dice
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if in Area
  #     area : Area data (RPG::Area)
  #--------------------------------------------------------------------------
  def in_area?(area)
    return false if area == nil
    return false if $game_map.map_id != area.map_id
    return false if @x < area.rect.x
    return false if @y < area.rect.y
    return false if @x >= area.rect.x + area.rect.width
    return false if @y >= area.rect.y + area.rect.height
    return true
  end
  #--------------------------------------------------------------------------
  # * Create Group ID for Troop Encountered
  #--------------------------------------------------------------------------
  def make_encounter_troop_id
    encounter_list = $game_map.encounter_list.clone
    for area in $data_areas.values
      encounter_list += area.encounter_list if in_area?(area)
    end
    if encounter_list.empty?
      make_encounter_count
      return 0
    end
    return encounter_list[rand(encounter_list.size)]
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    if $game_party.members.size == 0
      @character_name = ""
      @character_index = 0
    else
      actor = $game_party.members[0]   # Get front actor
      @character_name = actor.character_name
      @character_index = actor.character_index
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Same Position Event is Triggered
  #     triggers : Trigger array
  #--------------------------------------------------------------------------
  def check_event_trigger_here(triggers)
    return false if $game_map.interpreter.running?
    result = false
    for event in $game_map.events_xy(@x, @y)
      if triggers.include?(event.trigger) and event.priority_type != 1
        event.start
        result = true if event.starting
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Determine if Front Event is Triggered
  #     triggers : Trigger array
  #--------------------------------------------------------------------------
  def check_event_trigger_there(triggers)
    return false if $game_map.interpreter.running?
    result = false
    front_x = $game_map.x_with_direction(@x, @direction)
    front_y = $game_map.y_with_direction(@y, @direction)
    for event in $game_map.events_xy(front_x, front_y)
      if triggers.include?(event.trigger) and event.priority_type == 1
        event.start
        result = true
      end
    end
    if result == false and $game_map.counter?(front_x, front_y)
      front_x = $game_map.x_with_direction(front_x, @direction)
      front_y = $game_map.y_with_direction(front_y, @direction)
      for event in $game_map.events_xy(front_x, front_y)
        if triggers.include?(event.trigger) and event.priority_type == 1
          event.start
          result = true
        end
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Determine if Touch Event is Triggered
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    return false if $game_map.interpreter.running?
    result = false
    for event in $game_map.events_xy(x, y)
      if [1,2].include?(event.trigger) and event.priority_type == 1
        event.start
        result = true
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Processing of Movement via input from the Directional Buttons
  #--------------------------------------------------------------------------
  def move_by_input
    return unless movable?
    return if $game_map.interpreter.running?
    case Input.dir4
    when 2;  move_down
    when 4;  move_left
    when 6;  move_right
    when 8;  move_up
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Movement is Possible
  #--------------------------------------------------------------------------
  def movable?
    return false if moving?                     # Moving
    return false if @move_route_forcing         # On forced move route
    return false if @vehicle_getting_on         # Boarding vehicle
    return false if @vehicle_getting_off        # Getting off vehicle
    return false if $game_message.visible       # Displaying a message
    return false if in_airship? and not $game_map.airship.movable?
    return true
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    last_real_x = @real_x
    last_real_y = @real_y
    last_moving = moving?
    move_by_input
    super
    update_scroll(last_real_x, last_real_y)
    update_vehicle
    update_nonmoving(last_moving)
  end
  #--------------------------------------------------------------------------
  # * Update Scroll
  #--------------------------------------------------------------------------
  def update_scroll(last_real_x, last_real_y)
    ax1 = $game_map.adjust_x(last_real_x)
    ay1 = $game_map.adjust_y(last_real_y)
    ax2 = $game_map.adjust_x(@real_x)
    ay2 = $game_map.adjust_y(@real_y)
    if ay2 > ay1 and ay2 > CENTER_Y
      $game_map.scroll_down(ay2 - ay1)
    end
    if ax2 < ax1 and ax2 < CENTER_X
      $game_map.scroll_left(ax1 - ax2)
    end
    if ax2 > ax1 and ax2 > CENTER_X
      $game_map.scroll_right(ax2 - ax1)
    end
    if ay2 < ay1 and ay2 < CENTER_Y
      $game_map.scroll_up(ay1 - ay2)
    end
  end
  #--------------------------------------------------------------------------
  # * Update Vehicle
  #--------------------------------------------------------------------------
  def update_vehicle
    return unless in_vehicle?
    vehicle = $game_map.vehicles[@vehicle_type]
    if @vehicle_getting_on                    # Boarding?
      if not moving?
        @direction = vehicle.direction        # Change direction
        @move_speed = vehicle.speed           # Change movement speed
        @vehicle_getting_on = false           # Finish boarding operation
        @transparent = true                   # Transparency
      end
    elsif @vehicle_getting_off                # Getting off?
      if not moving? and vehicle.altitude == 0
        @vehicle_getting_off = false          # Finish getting off operation
        @vehicle_type = -1                    # Erase vehicle type
        @transparent = false                  # Remove transparency
      end
    else                                      # Riding in vehicle
      vehicle.sync_with_player                # Move at the same time as player
    end
  end
  #--------------------------------------------------------------------------
  # * Processing when not moving
  #     last_moving : Was it moving previously?
  #--------------------------------------------------------------------------
  def update_nonmoving(last_moving)
    return if $game_map.interpreter.running?
    return if moving?
    return if check_touch_event if last_moving
    if not $game_message.visible and Input.trigger?(Input::C)
      return if get_on_off_vehicle
      return if check_action_event
    end
    update_encounter if last_moving
  end
  #--------------------------------------------------------------------------
  # * Update Encounter
  #--------------------------------------------------------------------------
  def update_encounter
    return if $TEST and Input.press?(Input::CTRL)   # During test play?
    return if in_vehicle?                           # Riding in vehicle?
    if $game_map.bush?(@x, @y)                      # If in bush
      @encounter_count -= 2                         # Reduce encounters by 2
    else                                            # If not in bush
      @encounter_count -= 1                         # Reduce encounters by 1
    end
  end
  #--------------------------------------------------------------------------
  # * Determine Event Start Caused by Touch (overlap)
  #--------------------------------------------------------------------------
  def check_touch_event
    return false if in_airship?
    return check_event_trigger_here([1,2])
  end
  #--------------------------------------------------------------------------
  # * Determine Event Start Caused by [OK] Button
  #--------------------------------------------------------------------------
  def check_action_event
    return false if in_airship?
    return true if check_event_trigger_here([0])
    return check_event_trigger_there([0,1,2])
  end
  #--------------------------------------------------------------------------
  # * Getting On and Off Vehicles
  #--------------------------------------------------------------------------
  def get_on_off_vehicle
    return false unless movable?
    if in_vehicle?
      return get_off_vehicle
    else
      return get_on_vehicle
    end
  end
  #--------------------------------------------------------------------------
  # * Board Vehicle
  #    Assumes that the player is not currently in a vehicle.
  #--------------------------------------------------------------------------
  def get_on_vehicle
    front_x = $game_map.x_with_direction(@x, @direction)
    front_y = $game_map.y_with_direction(@y, @direction)
    if $game_map.airship.pos?(@x, @y)       # Is it overlapping with airship?
      get_on_airship
      return true
    elsif $game_map.ship.pos?(front_x, front_y)   # Is there a ship in front?
      get_on_ship
      return true
    elsif $game_map.boat.pos?(front_x, front_y)   # Is there a boat in front?
      get_on_boat
      return true
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Board Boat
  #--------------------------------------------------------------------------
  def get_on_boat
    @vehicle_getting_on = true        # Boarding flag
    @vehicle_type = 0                 # Set vehicle type
    force_move_forward                # Move one step forward
    @walking_bgm = RPG::BGM::last     # Memorize walking BGM
    $game_map.boat.get_on             # Boarding processing
  end
  #--------------------------------------------------------------------------
  # * Board Ship
  #--------------------------------------------------------------------------
  def get_on_ship
    @vehicle_getting_on = true        # Board
    @vehicle_type = 1                 # Set vehicle type
    force_move_forward                # Move one step forward
    @walking_bgm = RPG::BGM::last     # Memorize walking BGM
    $game_map.ship.get_on             # Boarding processing
  end
  #--------------------------------------------------------------------------
  # * Board Airship
  #--------------------------------------------------------------------------
  def get_on_airship
    @vehicle_getting_on = true        # Start boarding operation
    @vehicle_type = 2                 # Set vehicle type
    @through = true                   # Passage ON
    @walking_bgm = RPG::BGM::last     # Memorize walking BGM
    $game_map.airship.get_on          # Boarding processing
  end
  #--------------------------------------------------------------------------
  # * Get Off Vehicle
  #    Assumes that the player is currently riding in a vehicle.
  #--------------------------------------------------------------------------
  def get_off_vehicle
    if in_airship?                                # Airship
      return unless airship_land_ok?(@x, @y)      # Can't land?
    else                                          # Boat/ship
      front_x = $game_map.x_with_direction(@x, @direction)
      front_y = $game_map.y_with_direction(@y, @direction)
      return unless can_walk?(front_x, front_y)   # Can't touch land?
    end
    $game_map.vehicles[@vehicle_type].get_off     # Get off processing
    if in_airship?                                # Airship
      @direction = 2                              # Face down
    else                                          # Boat/ship
      force_move_forward                          # Move one step forward
      @transparent = false                        # Remove transparency
    end
    @vehicle_getting_off = true                   # Start getting off operation
    @move_speed = 4                               # Return move speed
    @through = false                              # Passage OFF
    @walking_bgm.play                             # Restore walking BGM
    make_encounter_count                          # Initialize encounter
  end
  #--------------------------------------------------------------------------
  # * Force One Step Forward
  #--------------------------------------------------------------------------
  def force_move_forward
    @through = true         # Passage ON
    move_forward            # Move one step forward
    @through = false        # Passage OFF
  end
end
