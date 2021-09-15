#encoding:UTF-8
# Game_Event
#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  This class handles events. Functions include event page switching via
# condition determinants and running parallel process events. Used within the
# Game_Map class.
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :trigger                  # trigger
  attr_reader   :list                     # list of event commands
  attr_reader   :starting                 # starting flag
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     event:  RPG::Event
  #--------------------------------------------------------------------------
  def initialize(map_id, event)
    super()
    @map_id = map_id
    @event = event
    @id = @event.id
    moveto(@event.x, @event.y)
    refresh
  end
  #--------------------------------------------------------------------------
  # * Initialize Public Member Variables
  #--------------------------------------------------------------------------
  def init_public_members
    super
    @trigger = 0
    @list = nil
    @starting = false
  end
  #--------------------------------------------------------------------------
  # * Initialize Private Member Variables
  #--------------------------------------------------------------------------
  def init_private_members
    super
    @move_type = 0                        # Movement type
    @erased = false                       # Temporary erase flag
    @page = nil                           # Event page
  end
  #--------------------------------------------------------------------------
  # * Detect Collision with Character 
  #--------------------------------------------------------------------------
  def collide_with_characters?(x, y)
    super || collide_with_player_characters?(x, y)
  end
  #--------------------------------------------------------------------------
  # * Detect Collision with Player (Including Followers)
  #--------------------------------------------------------------------------
  def collide_with_player_characters?(x, y)
    normal_priority? && $game_player.collide?(x, y)
  end
  #--------------------------------------------------------------------------
  # * Lock (Processing in Which Executing Events Stop)
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
  # * Update While Stopped
  #--------------------------------------------------------------------------
  def update_stop
    super
    update_self_movement unless @move_route_forcing
  end
  #--------------------------------------------------------------------------
  # * Update During Autonomous Movement
  #--------------------------------------------------------------------------
  def update_self_movement
    if near_the_screen? && @stop_count > stop_count_threshold
      case @move_type
      when 1;  move_type_random
      when 2;  move_type_toward_player
      when 3;  move_type_custom
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Near Visible Area of Screen
  #     dx:  A certain number of tiles left/right of screen's center
  #     dy:  A certain number of tiles above/below screen's center
  #--------------------------------------------------------------------------
  def near_the_screen?(dx = 12, dy = 8)
    ax = $game_map.adjust_x(@real_x) - Graphics.width / 2 / 32
    ay = $game_map.adjust_y(@real_y) - Graphics.height / 2 / 32
    ax >= -dx && ax <= dx && ay >= -dy && ay <= dy
  end
  #--------------------------------------------------------------------------
  # * Calculate Threshold of Counter for Stopping Autonomous Movement Startup
  #--------------------------------------------------------------------------
  def stop_count_threshold
    30 * (5 - @move_frequency)
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
    if near_the_player?
      case rand(6)
      when 0..3;  move_toward_player
      when 4;     move_random
      when 5;     move_forward
      end
    else
      move_random
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Near Player
  #--------------------------------------------------------------------------
  def near_the_player?
    sx = distance_x_from($game_player.x).abs
    sy = distance_y_from($game_player.y).abs
    sx + sy < 20
  end
  #--------------------------------------------------------------------------
  # * Move Type : Custom
  #--------------------------------------------------------------------------
  def move_type_custom
    update_routine_move
  end
  #--------------------------------------------------------------------------
  # * Clear Starting Flag
  #--------------------------------------------------------------------------
  def clear_starting_flag
    @starting = false
  end
  #--------------------------------------------------------------------------
  # * Determine if Contents Are Empty
  #--------------------------------------------------------------------------
  def empty?
    !@list || @list.size <= 1
  end
  #--------------------------------------------------------------------------
  # * Determine if One of Specified Triggers
  #     triggers : Trigger array
  #--------------------------------------------------------------------------
  def trigger_in?(triggers)
    triggers.include?(@trigger)
  end
  #--------------------------------------------------------------------------
  # * Start Event
  #--------------------------------------------------------------------------
  def start
    return if empty?
    @starting = true
    lock if trigger_in?([0,1,2])
  end
  #--------------------------------------------------------------------------
  # * Temporarily Erase
  #--------------------------------------------------------------------------
  def erase
    @erased = true
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    new_page = @erased ? nil : find_proper_page
    setup_page(new_page) if !new_page || new_page != @page
  end
  #--------------------------------------------------------------------------
  # * Find Event Page Meeting Conditions
  #--------------------------------------------------------------------------
  def find_proper_page
    @event.pages.reverse.find {|page| conditions_met?(page) }
  end
  #--------------------------------------------------------------------------
  # * Determine if Event Page Conditions Are Met
  #--------------------------------------------------------------------------
  def conditions_met?(page)
    c = page.condition
    if c.switch1_valid
      return false unless $game_switches[c.switch1_id]
    end
    if c.switch2_valid
      return false unless $game_switches[c.switch2_id]
    end
    if c.variable_valid
      return false if $game_variables[c.variable_id] < c.variable_value
    end
    if c.self_switch_valid
      key = [@map_id, @event.id, c.self_switch_ch]
      return false if $game_self_switches[key] != true
    end
    if c.item_valid
      item = $data_items[c.item_id]
      return false unless $game_party.has_item?(item)
    end
    if c.actor_valid
      actor = $game_actors[c.actor_id]
      return false unless $game_party.members.include?(actor)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Event Page Setup
  #--------------------------------------------------------------------------
  def setup_page(new_page)
    @page = new_page
    if @page
      setup_page_settings
    else
      clear_page_settings
    end
    update_bush_depth
    clear_starting_flag
    check_event_trigger_auto
  end
  #--------------------------------------------------------------------------
  # * Clear Event Page Settings
  #--------------------------------------------------------------------------
  def clear_page_settings
    @tile_id          = 0
    @character_name   = ""
    @character_index  = 0
    @move_type        = 0
    @through          = true
    @trigger          = nil
    @list             = nil
    @interpreter      = nil
  end
  #--------------------------------------------------------------------------
  # * Set Up Event Page Settings
  #--------------------------------------------------------------------------
  def setup_page_settings
    @tile_id          = @page.graphic.tile_id
    @character_name   = @page.graphic.character_name
    @character_index  = @page.graphic.character_index
    if @original_direction != @page.graphic.direction
      @direction          = @page.graphic.direction
      @original_direction = @direction
      @prelock_direction  = 0
    end
    if @original_pattern != @page.graphic.pattern
      @pattern            = @page.graphic.pattern
      @original_pattern   = @pattern
    end
    @move_type          = @page.move_type
    @move_speed         = @page.move_speed
    @move_frequency     = @page.move_frequency
    @move_route         = @page.move_route
    @move_route_index   = 0
    @move_route_forcing = false
    @walk_anime         = @page.walk_anime
    @step_anime         = @page.step_anime
    @direction_fix      = @page.direction_fix
    @through            = @page.through
    @priority_type      = @page.priority_type
    @trigger            = @page.trigger
    @list               = @page.list
    @interpreter = @trigger == 4 ? Game_Interpreter.new : nil
  end
  #--------------------------------------------------------------------------
  # * Determine if Touch Event is Triggered
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    return if $game_map.interpreter.running?
    if @trigger == 2 && $game_player.pos?(x, y)
      start if !jumping? && normal_priority?
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Autorun Event is Triggered
  #--------------------------------------------------------------------------
  def check_event_trigger_auto
    start if @trigger == 3
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    check_event_trigger_auto
    return unless @interpreter
    @interpreter.setup(@list, @event.id) unless @interpreter.running?
    @interpreter.update
  end
end
