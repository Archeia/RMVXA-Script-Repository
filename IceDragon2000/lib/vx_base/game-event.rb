#encoding:UTF-8
# Game_Event
#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  This class deals with events. It handles functions including event page 
# switching via condition determinants, and running parallel process events.
# It's used within the Game_Map class.
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
  #     map_id : map ID
  #     event  : event (RPG::Event)
  #--------------------------------------------------------------------------
  def initialize(map_id, event)
    super()
    @map_id = map_id
    @event = event
    @id = @event.id
    @erased = false
    @starting = false
    @through = true
    moveto(@event.x, @event.y)            # Move to initial position
    refresh
  end
  #--------------------------------------------------------------------------
  # * Clear Starting Flag
  #--------------------------------------------------------------------------
  def clear_starting
    @starting = false
  end
  #--------------------------------------------------------------------------
  # * Start Event
  #--------------------------------------------------------------------------
  def start
    return if @list.size <= 1                   # Execution content empty?
    @starting = true
    lock if @trigger < 3
    unless $game_map.interpreter.running?
      $game_map.interpreter.setup_starting_event
    end
  end
  #--------------------------------------------------------------------------
  # * Temporarily Erase
  #--------------------------------------------------------------------------
  def erase
    @erased = true
    refresh
  end
  #--------------------------------------------------------------------------
  # * Determine if Event Page Conditions are Met
  #--------------------------------------------------------------------------
  def conditions_met?(page)
    c = page.condition
    if c.switch1_valid      # Swtich 1
      return false if $game_switches[c.switch1_id] == false
    end
    if c.switch2_valid      # Swtich 2
      return false if $game_switches[c.switch2_id] == false
    end
    if c.variable_valid     # Variable
      return false if $game_variables[c.variable_id] < c.variable_value
    end
    if c.self_switch_valid  # Self switch
      key = [@map_id, @event.id, c.self_switch_ch]
      return false if $game_self_switches[key] != true
    end
    if c.item_valid         # Item
      item = $data_items[c.item_id]
      return false if $game_party.item_number(item) == 0
    end
    if c.actor_valid        # Actor
      actor = $game_actors[c.actor_id]
      return false unless $game_party.members.include?(actor)
    end
    return true   # Conditions met
  end
  #--------------------------------------------------------------------------
  # * Event page setup
  #--------------------------------------------------------------------------
  def setup(new_page)
    @page = new_page
    if @page == nil
      @tile_id = 0
      @character_name = ""
      @character_index = 0
      @move_type = 0
      @through = true
      @trigger = nil
      @list = nil
      @interpreter = nil
    else
      @tile_id = @page.graphic.tile_id
      @character_name = @page.graphic.character_name
      @character_index = @page.graphic.character_index
      if @original_direction != @page.graphic.direction
        @direction = @page.graphic.direction
        @original_direction = @direction
        @prelock_direction = 0
      end
      if @original_pattern != @page.graphic.pattern
        @pattern = @page.graphic.pattern
        @original_pattern = @pattern
      end
      @move_type = @page.move_type
      @move_speed = @page.move_speed
      @move_frequency = @page.move_frequency
      @move_route = @page.move_route
      @move_route_index = 0
      @move_route_forcing = false
      @walk_anime = @page.walk_anime
      @step_anime = @page.step_anime
      @direction_fix = @page.direction_fix
      @through = @page.through
      @priority_type = @page.priority_type
      @trigger = @page.trigger
      @list = @page.list
      @interpreter = nil
      if @trigger == 4                       # Trigger is [Parallel Process]?
        @interpreter = Game_Interpreter.new  # For parallel processing
      end
    end
    update_bush_depth
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    new_page = nil
    unless @erased                          # If not temporarily erased
      for page in @event.pages.reverse      # From the largest numbered page
        next unless conditions_met?(page)   # Determine if conditions are met
        new_page = page
        break
      end
    end
    if new_page != @page            # Event page changed?
      clear_starting                # Clear starting flag
      setup(new_page)               # Set up event page
      check_event_trigger_auto      # Check autorun event
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if touch event is triggered
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    return if $game_map.interpreter.running?
    if @trigger == 2 and $game_player.pos?(x, y)
      start if not jumping? and @priority_type == 1
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
    check_event_trigger_auto                    # Check autorun event
    if @interpreter != nil                      # Now parallel processing?
      unless @interpreter.running?              # Not running
        @interpreter.setup(@list, @event.id)    # Set up
      end
      @interpreter.update                       # Update interpreter
    end
  end
end
