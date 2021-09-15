#encoding:UTF-8
# Game_Player
#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles the player. It includes event starting determinants and
# map scrolling functions. The instance of this class is referenced by
# $game_player.
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :followers                # Followers (party members)
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super
    @vehicle_type = :walk           # Type of vehicle currently being ridden
    @vehicle_getting_on = false     # Boarding vehicle flag
    @vehicle_getting_off = false    # Getting off vehicle flag
    @followers = Game_Followers.new(self)
    @transparent = $data_system.opt_transparent
    clear_transfer_info
  end
  #--------------------------------------------------------------------------
  # * Clear Transfer Player Information
  #--------------------------------------------------------------------------
  def clear_transfer_info
    @transferring = false           # Player transfer flag
    @new_map_id = 0                 # Destination map ID
    @new_x = 0                      # Destination X coordinate
    @new_y = 0                      # Destination Y coordinate
    @new_direction = 0              # Post-movement direction
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    @character_name = actor ? actor.character_name : ""
    @character_index = actor ? actor.character_index : 0
    @followers.refresh
  end
  #--------------------------------------------------------------------------
  # * Get Corresponding Actor
  #--------------------------------------------------------------------------
  def actor
    $game_party.battle_members[0]
  end
  #--------------------------------------------------------------------------
  # * Determine if Stopping
  #--------------------------------------------------------------------------
  def stopping?
    return false if @vehicle_getting_on || @vehicle_getting_off
    return super
  end
  #--------------------------------------------------------------------------
  # * Player Transfer Reservation
  #     d:  Post move direction (2,4,6,8)
  #--------------------------------------------------------------------------
  def reserve_transfer(map_id, x, y, d = 2)
    @transferring = true
    @new_map_id = map_id
    @new_x = x
    @new_y = y
    @new_direction = d
  end
  #--------------------------------------------------------------------------
  # * Determine if Player Transfer is Reserved
  #--------------------------------------------------------------------------
  def transfer?
    @transferring
  end
  #--------------------------------------------------------------------------
  # * Execute Player Transfer
  #--------------------------------------------------------------------------
  def perform_transfer
    if transfer?
      set_direction(@new_direction)
      if @new_map_id != $game_map.map_id
        $game_map.setup(@new_map_id)
        $game_map.autoplay
      end
      moveto(@new_x, @new_y)
      clear_transfer_info
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Map is Passable
  #     d:  Direction (2,4,6,8)
  #--------------------------------------------------------------------------
  def map_passable?(x, y, d)
    case @vehicle_type
    when :boat
      $game_map.boat_passable?(x, y)
    when :ship
      $game_map.ship_passable?(x, y)
    when :airship
      true
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # * Get Vehicle Currently Being Ridden
  #--------------------------------------------------------------------------
  def vehicle
    $game_map.vehicle(@vehicle_type)
  end
  #--------------------------------------------------------------------------
  # * Determine if on Boat
  #--------------------------------------------------------------------------
  def in_boat?
    @vehicle_type == :boat
  end
  #--------------------------------------------------------------------------
  # * Determine if on Ship
  #--------------------------------------------------------------------------
  def in_ship?
    @vehicle_type == :ship
  end
  #--------------------------------------------------------------------------
  # * Determine if Riding in Airship
  #--------------------------------------------------------------------------
  def in_airship?
    @vehicle_type == :airship
  end
  #--------------------------------------------------------------------------
  # * Determine if Walking Normally
  #--------------------------------------------------------------------------
  def normal_walk?
    @vehicle_type == :walk && !@move_route_forcing
  end
  #--------------------------------------------------------------------------
  # * Determine if Dashing
  #--------------------------------------------------------------------------
  def dash?
    return false if @move_route_forcing
    return false if $game_map.disable_dash?
    return false if vehicle
    return Input.press?(:A)
  end
  #--------------------------------------------------------------------------
  # * Determine if Debug Pass-through State
  #--------------------------------------------------------------------------
  def debug_through?
    $TEST && Input.press?(:CTRL)
  end
  #--------------------------------------------------------------------------
  # * Detect Collision (Including Followers)
  #--------------------------------------------------------------------------
  def collide?(x, y)
    !@through && (pos?(x, y) || followers.collide?(x, y))
  end
  #--------------------------------------------------------------------------
  # * X Coordinate of Screen Center
  #--------------------------------------------------------------------------
  def center_x
    (Graphics.width / 32 - 1) / 2.0
  end
  #--------------------------------------------------------------------------
  # * Y Coordinate of Screen Center
  #--------------------------------------------------------------------------
  def center_y
    (Graphics.height / 32 - 1) / 2.0
  end
  #--------------------------------------------------------------------------
  # * Set Map Display Position to Center of Screen
  #--------------------------------------------------------------------------
  def center(x, y)
    $game_map.set_display_pos(x - center_x, y - center_y)
  end
  #--------------------------------------------------------------------------
  # * Move to Designated Position
  #--------------------------------------------------------------------------
  def moveto(x, y)
    super
    center(x, y)
    make_encounter_count
    vehicle.refresh if vehicle
    @followers.synchronize(x, y, direction)
  end
  #--------------------------------------------------------------------------
  # * Increase Steps
  #--------------------------------------------------------------------------
  def increase_steps
    super
    $game_party.increase_steps if normal_walk?
  end
  #--------------------------------------------------------------------------
  # * Create Encounter Count
  #--------------------------------------------------------------------------
  def make_encounter_count
    n = $game_map.encounter_step
    @encounter_count = rand(n) + rand(n) + 1
  end
  #--------------------------------------------------------------------------
  # * Create Group ID for Troop Encountered
  #--------------------------------------------------------------------------
  def make_encounter_troop_id
    encounter_list = []
    weight_sum = 0
    $game_map.encounter_list.each do |encounter|
      next unless encounter_ok?(encounter)
      encounter_list.push(encounter)
      weight_sum += encounter.weight
    end
    if weight_sum > 0
      value = rand(weight_sum)
      encounter_list.each do |encounter|
        value -= encounter.weight
        return encounter.troop_id if value < 0
      end
    end
    return 0
  end
  #--------------------------------------------------------------------------
  # * Determine Usability of Encounter Item
  #--------------------------------------------------------------------------
  def encounter_ok?(encounter)
    return true if encounter.region_set.empty?
    return true if encounter.region_set.include?(region_id)
    return false
  end
  #--------------------------------------------------------------------------
  # * Execute Encounter Processing
  #--------------------------------------------------------------------------
  def encounter
    return false if $game_map.interpreter.running?
    return false if $game_system.encounter_disabled
    return false if @encounter_count > 0
    make_encounter_count
    troop_id = make_encounter_troop_id
    return false unless $data_troops[troop_id]
    BattleManager.setup(troop_id)
    BattleManager.on_encounter
    return true
  end
  #--------------------------------------------------------------------------
  # * Trigger Map Event
  #     triggers : Trigger array
  #     normal   : Is priority set to [Same as Characters] ?
  #--------------------------------------------------------------------------
  def start_map_event(x, y, triggers, normal)
    return if $game_map.interpreter.running?
    $game_map.events_xy(x, y).each do |event|
      if event.trigger_in?(triggers) && event.normal_priority? == normal
        event.start
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Same Position Event is Triggered
  #--------------------------------------------------------------------------
  def check_event_trigger_here(triggers)
    start_map_event(@x, @y, triggers, false)
  end
  #--------------------------------------------------------------------------
  # * Determine if Front Event is Triggered
  #--------------------------------------------------------------------------
  def check_event_trigger_there(triggers)
    x2 = $game_map.round_x_with_direction(@x, @direction)
    y2 = $game_map.round_y_with_direction(@y, @direction)
    start_map_event(x2, y2, triggers, true)
    return if $game_map.any_event_starting?
    return unless $game_map.counter?(x2, y2)
    x3 = $game_map.round_x_with_direction(x2, @direction)
    y3 = $game_map.round_y_with_direction(y2, @direction)
    start_map_event(x3, y3, triggers, true)
  end
  #--------------------------------------------------------------------------
  # * Determine if Touch Event is Triggered
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    start_map_event(x, y, [1,2], true)
  end
  #--------------------------------------------------------------------------
  # * Processing of Movement via Input from Directional Buttons
  #--------------------------------------------------------------------------
  def move_by_input
    return if !movable? || $game_map.interpreter.running?
    move_straight(Input.dir4) if Input.dir4 > 0
  end
  #--------------------------------------------------------------------------
  # * Determine if Movement is Possible
  #--------------------------------------------------------------------------
  def movable?
    return false if moving?
    return false if @move_route_forcing || @followers.gathering?
    return false if @vehicle_getting_on || @vehicle_getting_off
    return false if $game_message.busy? || $game_message.visible
    return false if vehicle && !vehicle.movable?
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
    update_nonmoving(last_moving) unless moving?
    @followers.update
  end
  #--------------------------------------------------------------------------
  # * Scroll Processing
  #--------------------------------------------------------------------------
  def update_scroll(last_real_x, last_real_y)
    ax1 = $game_map.adjust_x(last_real_x)
    ay1 = $game_map.adjust_y(last_real_y)
    ax2 = $game_map.adjust_x(@real_x)
    ay2 = $game_map.adjust_y(@real_y)
    $game_map.scroll_down (ay2 - ay1) if ay2 > ay1 && ay2 > center_y
    $game_map.scroll_left (ax1 - ax2) if ax2 < ax1 && ax2 < center_x
    $game_map.scroll_right(ax2 - ax1) if ax2 > ax1 && ax2 > center_x
    $game_map.scroll_up   (ay1 - ay2) if ay2 < ay1 && ay2 < center_y
  end
  #--------------------------------------------------------------------------
  # * Vehicle Processing
  #--------------------------------------------------------------------------
  def update_vehicle
    return if @followers.gathering?
    return unless vehicle
    if @vehicle_getting_on
      update_vehicle_get_on
    elsif @vehicle_getting_off
      update_vehicle_get_off
    else
      vehicle.sync_with_player
    end
  end
  #--------------------------------------------------------------------------
  # * Update Boarding onto Vehicle 
  #--------------------------------------------------------------------------
  def update_vehicle_get_on
    if !@followers.gathering? && !moving?
      @direction = vehicle.direction
      @move_speed = vehicle.speed
      @vehicle_getting_on = false
      @transparent = true
      @through = true if in_airship?
      vehicle.get_on
    end
  end
  #--------------------------------------------------------------------------
  # * Update Disembarking from Vehicle 
  #--------------------------------------------------------------------------
  def update_vehicle_get_off
    if !@followers.gathering? && vehicle.altitude == 0
      @vehicle_getting_off = false
      @vehicle_type = :walk
      @transparent = false
    end
  end
  #--------------------------------------------------------------------------
  # * Processing When Not Moving
  #     last_moving : Was it moving previously?
  #--------------------------------------------------------------------------
  def update_nonmoving(last_moving)
    return if $game_map.interpreter.running?
    if last_moving
      $game_party.on_player_walk
      return if check_touch_event
    end
    if movable? && Input.trigger?(:C)
      return if get_on_off_vehicle
      return if check_action_event
    end
    update_encounter if last_moving
  end
  #--------------------------------------------------------------------------
  # * Update Encounter
  #--------------------------------------------------------------------------
  def update_encounter
    return if $TEST && Input.press?(:CTRL)
    return if $game_party.encounter_none?
    return if in_airship?
    return if @move_route_forcing
    @encounter_count -= encounter_progress_value
  end
  #--------------------------------------------------------------------------
  # * Get Encounter Progress Value
  #--------------------------------------------------------------------------
  def encounter_progress_value
    value = $game_map.bush?(@x, @y) ? 2 : 1
    value *= 0.5 if $game_party.encounter_half?
    value *= 0.5 if in_ship?
    value
  end
  #--------------------------------------------------------------------------
  # * Determine if Event Start Caused by Touch (Overlap)
  #--------------------------------------------------------------------------
  def check_touch_event
    return false if in_airship?
    check_event_trigger_here([1,2])
    $game_map.setup_starting_event
  end
  #--------------------------------------------------------------------------
  # * Determine if Event Start Caused by [OK] Button
  #--------------------------------------------------------------------------
  def check_action_event
    return false if in_airship?
    check_event_trigger_here([0])
    return true if $game_map.setup_starting_event
    check_event_trigger_there([0,1,2])
    $game_map.setup_starting_event
  end
  #--------------------------------------------------------------------------
  # * Getting On and Off Vehicles
  #--------------------------------------------------------------------------
  def get_on_off_vehicle
    if vehicle
      get_off_vehicle
    else
      get_on_vehicle
    end
  end
  #--------------------------------------------------------------------------
  # * Board Vehicle
  #    Assumes that the player is not currently in a vehicle.
  #--------------------------------------------------------------------------
  def get_on_vehicle
    front_x = $game_map.round_x_with_direction(@x, @direction)
    front_y = $game_map.round_y_with_direction(@y, @direction)
    @vehicle_type = :boat    if $game_map.boat.pos?(front_x, front_y)
    @vehicle_type = :ship    if $game_map.ship.pos?(front_x, front_y)
    @vehicle_type = :airship if $game_map.airship.pos?(@x, @y)
    if vehicle
      @vehicle_getting_on = true
      force_move_forward unless in_airship?
      @followers.gather
    end
    @vehicle_getting_on
  end
  #--------------------------------------------------------------------------
  # * Get Off Vehicle
  #    Assumes that the player is currently riding in a vehicle.
  #--------------------------------------------------------------------------
  def get_off_vehicle
    if vehicle.land_ok?(@x, @y, @direction)
      set_direction(2) if in_airship?
      @followers.synchronize(@x, @y, @direction)
      vehicle.get_off
      unless in_airship?
        force_move_forward
        @transparent = false
      end
      @vehicle_getting_off = true
      @move_speed = 4
      @through = false
      make_encounter_count
      @followers.gather
    end
    @vehicle_getting_off
  end
  #--------------------------------------------------------------------------
  # * Force One Step Forward
  #--------------------------------------------------------------------------
  def force_move_forward
    @through = true
    move_forward
    @through = false
  end
  #--------------------------------------------------------------------------
  # * Determine if Damage Floor
  #--------------------------------------------------------------------------
  def on_damage_floor?
    $game_map.damage_floor?(@x, @y) && !in_airship?
  end
  #--------------------------------------------------------------------------
  # * Move Straight
  #--------------------------------------------------------------------------
  def move_straight(d, turn_ok = true)
    @followers.move if passable?(@x, @y, d)
    super
  end
  #--------------------------------------------------------------------------
  # * Move Diagonally
  #--------------------------------------------------------------------------
  def move_diagonal(horz, vert)
    @followers.move if diagonal_passable?(@x, @y, horz, vert)
    super
  end
end
