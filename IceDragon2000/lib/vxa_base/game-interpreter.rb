#encoding:UTF-8
# Game_Interpreter
#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :map_id             # Map ID
  attr_reader   :event_id           # Event ID (normal events only)
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     depth : nest depth
  #--------------------------------------------------------------------------
  def initialize(depth = 0)
    @depth = depth
    check_overflow
    clear
  end
  #--------------------------------------------------------------------------
  # * Check for Overflow
  #    Under normal usage, the depth will not exceed 100. Since recursive
  #    event calls are likely to result in an infinite loop, the depth is
  #    cut off at 100 and an error results.
  #--------------------------------------------------------------------------
  def check_overflow
    if @depth >= 100
      msgbox(Vocab::EventOverflow)
      exit
    end
  end
  #--------------------------------------------------------------------------
  # * Clear
  #--------------------------------------------------------------------------
  def clear
    @map_id = 0
    @event_id = 0
    @list = nil                       # Execution content
    @index = 0                        # Index
    @branch = {}                      # Branch data
    @fiber = nil                      # Fiber
  end
  #--------------------------------------------------------------------------
  # * Event Setup
  #--------------------------------------------------------------------------
  def setup(list, event_id = 0)
    clear
    @map_id = $game_map.map_id
    @event_id = event_id
    @list = list
    create_fiber
  end
  #--------------------------------------------------------------------------
  # * Create Fiber
  #--------------------------------------------------------------------------
  def create_fiber
    @fiber = Fiber.new { run } if @list
  end
  #--------------------------------------------------------------------------
  # * Dump Objects
  #    Define fibers in advance as they are not compatible with Marshal.
  #    Advance the event execution position by one and save.
  #--------------------------------------------------------------------------
  def marshal_dump
    [@depth, @map_id, @event_id, @list, @index + 1, @branch]
  end
  #--------------------------------------------------------------------------
  # * Load Objects
  #     obj:  An array of objects dumped by marshal_dump.
  #    Restore data through multiple assignment and if necessary create fiber.
  #--------------------------------------------------------------------------
  def marshal_load(obj)
    @depth, @map_id, @event_id, @list, @index, @branch = obj
    create_fiber
  end
  #--------------------------------------------------------------------------
  # * Determine if Same Map as at Event Start
  #--------------------------------------------------------------------------
  def same_map?
    @map_id == $game_map.map_id
  end
  #--------------------------------------------------------------------------
  # * Detect/Set Up Call-Reserved Common Events
  #--------------------------------------------------------------------------
  def setup_reserved_common_event
    if $game_temp.common_event_reserved?
      setup($game_temp.reserved_common_event.list)
      $game_temp.clear_common_event
      true
    else
      false
    end
  end
  #--------------------------------------------------------------------------
  # * Execute
  #--------------------------------------------------------------------------
  def run
    wait_for_message
    while @list[@index] do
      execute_command
      @index += 1
    end
    Fiber.yield
    @fiber = nil
  end
  #--------------------------------------------------------------------------
  # * Determine if Running
  #--------------------------------------------------------------------------
  def running?
    @fiber != nil
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    @fiber.resume if @fiber
  end
  #--------------------------------------------------------------------------
  # * Actor Iterator (ID)
  #     param : If 1 or more, ID. If 0, all
  #--------------------------------------------------------------------------
  def iterate_actor_id(param)
    if param == 0
      $game_party.members.each {|actor| yield actor }
    else
      actor = $game_actors[param]
      yield actor if actor
    end
  end
  #--------------------------------------------------------------------------
  # * Actor Iterator (Variable)
  #     param1:  Specify as fixed if 0 and variable if 1
  #     param2:  Actor or variable ID
  #--------------------------------------------------------------------------
  def iterate_actor_var(param1, param2)
    if param1 == 0
      iterate_actor_id(param2) {|actor| yield actor }
    else
      iterate_actor_id($game_variables[param2]) {|actor| yield actor }
    end
  end
  #--------------------------------------------------------------------------
  # * Actor Iterator (Index)
  #     param : If 0 or more, index. If -1, all.
  #--------------------------------------------------------------------------
  def iterate_actor_index(param)
    if param < 0
      $game_party.members.each {|actor| yield actor }
    else
      actor = $game_party.members[param]
      yield actor if actor
    end
  end
  #--------------------------------------------------------------------------
  # * Enemy Iterator (Index)
  #     param : If 0 or more, index. If -1, all.
  #--------------------------------------------------------------------------
  def iterate_enemy_index(param)
    if param < 0
      $game_troop.members.each {|enemy| yield enemy }
    else
      enemy = $game_troop.members[param]
      yield enemy if enemy
    end
  end
  #--------------------------------------------------------------------------
  # * Battler Iterator (Account for Entire Enemy Group or Entire Party)
  #     param1 : If 0, enemy. If 1, actor.
  #     param2:  Index if enemy and ID if actor.
  #--------------------------------------------------------------------------
  def iterate_battler(param1, param2)
    if $game_party.in_battle
      if param1 == 0
        iterate_enemy_index(param2) {|enemy| yield enemy }
      else
        iterate_actor_id(param2) {|actor| yield actor }
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Get Target of Screen Command
  #--------------------------------------------------------------------------
  def screen
    $game_party.in_battle ? $game_troop.screen : $game_map.screen
  end
  #--------------------------------------------------------------------------
  # * Event Command Execution
  #--------------------------------------------------------------------------
  def execute_command
    command = @list[@index]
    @params = command.parameters
    @indent = command.indent
    method_name = "command_#{command.code}"
    send(method_name) if respond_to?(method_name)
  end
  #--------------------------------------------------------------------------
  # * Command Skip
  #    Skip commands deeper than current index and advance index.
  #--------------------------------------------------------------------------
  def command_skip
    @index += 1 while @list[@index + 1].indent > @indent
  end
  #--------------------------------------------------------------------------
  # * Get Code of Next Event Command
  #--------------------------------------------------------------------------
  def next_event_code
    @list[@index + 1].code
  end
  #--------------------------------------------------------------------------
  # * Get Character
  #     param : If -1, player. If 0, this event. Otherwise, event ID.
  #--------------------------------------------------------------------------
  def get_character(param)
    if $game_party.in_battle
      nil
    elsif param < 0
      $game_player
    else
      events = same_map? ? $game_map.events : {}
      events[param > 0 ? param : @event_id]
    end
  end
  #--------------------------------------------------------------------------
  # * Calculate Operated Value
  #     operation    : Operation (0: Increase 1: Decrease)
  #     operand_type : Operand type (0: Constant 1: Variable)
  #     operand      : Operand (numeric value or variable ID)
  #--------------------------------------------------------------------------
  def operate_value(operation, operand_type, operand)
    value = operand_type == 0 ? operand : $game_variables[operand]
    operation == 0 ? value : -value
  end
  #--------------------------------------------------------------------------
  # * Wait
  #--------------------------------------------------------------------------
  def wait(duration)
    duration.times { Fiber.yield }
  end
  #--------------------------------------------------------------------------
  # * Wait While Message Display is Busy
  #--------------------------------------------------------------------------
  def wait_for_message
    Fiber.yield while $game_message.busy?
  end
  #--------------------------------------------------------------------------
  # * Show Text
  #--------------------------------------------------------------------------
  def command_101
    wait_for_message
    $game_message.face_name = @params[0]
    $game_message.face_index = @params[1]
    $game_message.background = @params[2]
    $game_message.position = @params[3]
    while next_event_code == 401       # Text data
      @index += 1
      $game_message.add(@list[@index].parameters[0])
    end
    case next_event_code
    when 102  # Show Choices
      @index += 1
      setup_choices(@list[@index].parameters)
    when 103  # Input Number
      @index += 1
      setup_num_input(@list[@index].parameters)
    when 104  # Select Item
      @index += 1
      setup_item_choice(@list[@index].parameters)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # * Show Choices
  #--------------------------------------------------------------------------
  def command_102
    wait_for_message
    setup_choices(@params)
    Fiber.yield while $game_message.choice?
  end
  #--------------------------------------------------------------------------
  # * Setup Choices
  #--------------------------------------------------------------------------
  def setup_choices(params)
    params[0].each {|s| $game_message.choices.push(s) }
    $game_message.choice_cancel_type = params[1]
    $game_message.choice_proc = Proc.new {|n| @branch[@indent] = n }
  end
  #--------------------------------------------------------------------------
  # * When [**]
  #--------------------------------------------------------------------------
  def command_402
    command_skip if @branch[@indent] != @params[0]
  end
  #--------------------------------------------------------------------------
  # * When Cancel
  #--------------------------------------------------------------------------
  def command_403
    command_skip if @branch[@indent] != 4
  end
  #--------------------------------------------------------------------------
  # * Input Number
  #--------------------------------------------------------------------------
  def command_103
    wait_for_message
    setup_num_input(@params)
    Fiber.yield while $game_message.num_input?
  end
  #--------------------------------------------------------------------------
  # * Number Input Setup
  #--------------------------------------------------------------------------
  def setup_num_input(params)
    $game_message.num_input_variable_id = params[0]
    $game_message.num_input_digits_max = params[1]
  end
  #--------------------------------------------------------------------------
  # * Select Item
  #--------------------------------------------------------------------------
  def command_104
    wait_for_message
    setup_item_choice(@params)
    Fiber.yield while $game_message.item_choice?
  end
  #--------------------------------------------------------------------------
  # * Set Up Item Selection
  #--------------------------------------------------------------------------
  def setup_item_choice(params)
    $game_message.item_choice_variable_id = params[0]
  end
  #--------------------------------------------------------------------------
  # * Show Scrolling Text
  #--------------------------------------------------------------------------
  def command_105
    Fiber.yield while $game_message.visible
    $game_message.scroll_mode = true
    $game_message.scroll_speed = @params[0]
    $game_message.scroll_no_fast = @params[1]
    while next_event_code == 405
      @index += 1
      $game_message.add(@list[@index].parameters[0])
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # * Comment
  #--------------------------------------------------------------------------
  def command_108
    @comments = [@params[0]]
    while next_event_code == 408
      @index += 1
      @comments.push(@list[@index].parameters[0])
    end
  end
  #--------------------------------------------------------------------------
  # * Conditional Branch
  #--------------------------------------------------------------------------
  def command_111
    result = false
    case @params[0]
    when 0  # Switch
      result = ($game_switches[@params[1]] == (@params[2] == 0))
    when 1  # Variable
      value1 = $game_variables[@params[1]]
      if @params[2] == 0
        value2 = @params[3]
      else
        value2 = $game_variables[@params[3]]
      end
      case @params[4]
      when 0  # value1 is equal to value2
        result = (value1 == value2)
      when 1  # value1 is greater than or equal to value2
        result = (value1 >= value2)
      when 2  # value1 is less than or equal to value2
        result = (value1 <= value2)
      when 3  # value1 is greater than value2
        result = (value1 > value2)
      when 4  # value1 is less than value2
        result = (value1 < value2)
      when 5  # value1 is not equal to value2
        result = (value1 != value2)
      end
    when 2  # Self switch
      if @event_id > 0
        key = [@map_id, @event_id, @params[1]]
        result = ($game_self_switches[key] == (@params[2] == 0))
      end
    when 3  # Timer
      if $game_timer.working?
        if @params[2] == 0
          result = ($game_timer.sec >= @params[1])
        else
          result = ($game_timer.sec <= @params[1])
        end
      end
    when 4  # Actor
      actor = $game_actors[@params[1]]
      if actor
        case @params[2]
        when 0  # in party
          result = ($game_party.members.include?(actor))
        when 1  # name
          result = (actor.name == @params[3])
        when 2  # Class
          result = (actor.class_id == @params[3])
        when 3  # Skills
          result = (actor.skill_learn?($data_skills[@params[3]]))
        when 4  # Weapons
          result = (actor.weapons.include?($data_weapons[@params[3]]))
        when 5  # Armors
          result = (actor.armors.include?($data_armors[@params[3]]))
        when 6  # States
          result = (actor.state?(@params[3]))
        end
      end
    when 5  # Enemy
      enemy = $game_troop.members[@params[1]]
      if enemy
        case @params[2]
        when 0  # appear
          result = (enemy.alive?)
        when 1  # state
          result = (enemy.state?(@params[3]))
        end
      end
    when 6  # Character
      character = get_character(@params[1])
      if character
        result = (character.direction == @params[2])
      end
    when 7  # Gold
      case @params[2]
      when 0  # Greater than or equal to
        result = ($game_party.gold >= @params[1])
      when 1  # Less than or equal to
        result = ($game_party.gold <= @params[1])
      when 2  # Less than
        result = ($game_party.gold < @params[1])
      end
    when 8  # Item
      result = $game_party.has_item?($data_items[@params[1]])
    when 9  # Weapon
      result = $game_party.has_item?($data_weapons[@params[1]], @params[2])
    when 10  # Armor
      result = $game_party.has_item?($data_armors[@params[1]], @params[2])
    when 11  # Button
      result = Input.press?(@params[1])
    when 12  # Script
      result = eval(@params[1])
    when 13  # Vehicle
      result = ($game_player.vehicle == $game_map.vehicles[@params[1]])
    end
    @branch[@indent] = result
    command_skip if !@branch[@indent]
  end
  #--------------------------------------------------------------------------
  # * Else
  #--------------------------------------------------------------------------
  def command_411
    command_skip if @branch[@indent]
  end
  #--------------------------------------------------------------------------
  # * Loop
  #--------------------------------------------------------------------------
  def command_112
  end
  #--------------------------------------------------------------------------
  # * Repeat Above
  #--------------------------------------------------------------------------
  def command_413
    begin
      @index -= 1
    end until @list[@index].indent == @indent
  end
  #--------------------------------------------------------------------------
  # * Break Loop
  #--------------------------------------------------------------------------
  def command_113
    loop do
      @index += 1
      return if @index >= @list.size - 1
      return if @list[@index].code == 413 && @list[@index].indent < @indent
    end
  end
  #--------------------------------------------------------------------------
  # * Exit Event Processing
  #--------------------------------------------------------------------------
  def command_115
    @index = @list.size
  end
  #--------------------------------------------------------------------------
  # * Common Event
  #--------------------------------------------------------------------------
  def command_117
    common_event = $data_common_events[@params[0]]
    if common_event
      child = Game_Interpreter.new(@depth + 1)
      child.setup(common_event.list, same_map? ? @event_id : 0)
      child.run
    end
  end
  #--------------------------------------------------------------------------
  # * Label
  #--------------------------------------------------------------------------
  def command_118
  end
  #--------------------------------------------------------------------------
  # * Jump to Label
  #--------------------------------------------------------------------------
  def command_119
    label_name = @params[0]
    @list.size.times do |i|
      if @list[i].code == 118 && @list[i].parameters[0] == label_name
        @index = i
        return
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Control Switches
  #--------------------------------------------------------------------------
  def command_121
    (@params[0]..@params[1]).each do |i|
      $game_switches[i] = (@params[2] == 0)
    end
  end
  #--------------------------------------------------------------------------
  # * Control Variables
  #--------------------------------------------------------------------------
  def command_122
    value = 0
    case @params[3]  # Operand
    when 0  # Constant
      value = @params[4]
    when 1  # Variable
      value = $game_variables[@params[4]]
    when 2  # Random
      value = @params[4] + rand(@params[5] - @params[4] + 1)
    when 3  # Game Data
      value = game_data_operand(@params[4], @params[5], @params[6])
    when 4  # Script
      value = eval(@params[4])
    end
    (@params[0]..@params[1]).each do |i|
      operate_variable(i, @params[2], value)
    end
  end
  #--------------------------------------------------------------------------
  # * Get Game Data for Variable Operand
  #--------------------------------------------------------------------------
  def game_data_operand(type, param1, param2)
    case type
    when 0  # Items
      return $game_party.item_number($data_items[param1])
    when 1  # Weapons
      return $game_party.item_number($data_weapons[param1])
    when 2  # Armor
      return $game_party.item_number($data_armors[param1])
    when 3  # Actors
      actor = $game_actors[param1]
      if actor
        case param2
        when 0      # Level
          return actor.level
        when 1      # EXP
          return actor.exp
        when 2      # HP
          return actor.hp
        when 3      # MP
          return actor.mp
        when 4..11  # Parameter
          return actor.param(param2 - 4)
        end
      end
    when 4  # Enemies
      enemy = $game_troop.members[param1]
      if enemy
        case param2
        when 0      # HP
          return enemy.hp
        when 1      # MP
          return enemy.mp
        when 2..9   # Parameter
          return enemy.param(param2 - 2)
        end
      end
    when 5  # Character
      character = get_character(param1)
      if character
        case param2
        when 0  # x-coordinate
          return character.x
        when 1  # y-coordinate
          return character.y
        when 2  # direction
          return character.direction
        when 3  # screen x-coordinate
          return character.screen_x
        when 4  # screen y-coordinate
          return character.screen_y
        end
      end
    when 6  # Party
      actor = $game_party.members[param1]
      return actor ? actor.id : 0
    when 7  # Other
      case param1
      when 0  # map ID
        return $game_map.map_id
      when 1  # number of party members
        return $game_party.members.size
      when 2  # gold
        return $game_party.gold
      when 3  # steps
        return $game_party.steps
      when 4  # play time
        return Graphics.frame_count / Graphics.frame_rate
      when 5  # timer
        return $game_timer.sec
      when 6  # save count
        return $game_system.save_count
      when 7  # battle count
        return $game_system.battle_count
      end
    end
    return 0
  end
  #--------------------------------------------------------------------------
  # * Execute Variable Operation
  #--------------------------------------------------------------------------
  def operate_variable(variable_id, operation_type, value)
    begin
      case operation_type
      when 0  # Set
        $game_variables[variable_id] = value
      when 1  # Add
        $game_variables[variable_id] += value
      when 2  # Sub
        $game_variables[variable_id] -= value
      when 3  # Mul
        $game_variables[variable_id] *= value
      when 4  # Div
        $game_variables[variable_id] /= value
      when 5  # Mod
        $game_variables[variable_id] %= value
      end
    rescue
      $game_variables[variable_id] = 0
    end
  end
  #--------------------------------------------------------------------------
  # * Control Self Switch
  #--------------------------------------------------------------------------
  def command_123
    if @event_id > 0
      key = [@map_id, @event_id, @params[0]]
      $game_self_switches[key] = (@params[1] == 0)
    end
  end
  #--------------------------------------------------------------------------
  # * Control Timer
  #--------------------------------------------------------------------------
  def command_124
    if @params[0] == 0  # Start
      $game_timer.start(@params[1] * Graphics.frame_rate)
    else                # Stop
      $game_timer.stop
    end
  end
  #--------------------------------------------------------------------------
  # * Change Gold
  #--------------------------------------------------------------------------
  def command_125
    value = operate_value(@params[0], @params[1], @params[2])
    $game_party.gain_gold(value)
  end
  #--------------------------------------------------------------------------
  # * Change Items
  #--------------------------------------------------------------------------
  def command_126
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_items[@params[0]], value)
  end
  #--------------------------------------------------------------------------
  # * Change Weapons
  #--------------------------------------------------------------------------
  def command_127
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_weapons[@params[0]], value, @params[4])
  end
  #--------------------------------------------------------------------------
  # * Change Armor
  #--------------------------------------------------------------------------
  def command_128
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_armors[@params[0]], value, @params[4])
  end
  #--------------------------------------------------------------------------
  # * Change Party Member
  #--------------------------------------------------------------------------
  def command_129
    actor = $game_actors[@params[0]]
    if actor
      if @params[1] == 0    # Add
        if @params[2] == 1  # Initialize
          $game_actors[@params[0]].setup(@params[0])
        end
        $game_party.add_actor(@params[0])
      else                  # Remove
        $game_party.remove_actor(@params[0])
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Change Battle BGM
  #--------------------------------------------------------------------------
  def command_132
    $game_system.battle_bgm = @params[0]
  end
  #--------------------------------------------------------------------------
  # * Change Battle End ME
  #--------------------------------------------------------------------------
  def command_133
    $game_system.battle_end_me = @params[0]
  end
  #--------------------------------------------------------------------------
  # * Change Save Access
  #--------------------------------------------------------------------------
  def command_134
    $game_system.save_disabled = (@params[0] == 0)
  end
  #--------------------------------------------------------------------------
  # * Change Menu Access
  #--------------------------------------------------------------------------
  def command_135
    $game_system.menu_disabled = (@params[0] == 0)
  end
  #--------------------------------------------------------------------------
  # * Change Encounter Disable
  #--------------------------------------------------------------------------
  def command_136
    $game_system.encounter_disabled = (@params[0] == 0)
    $game_player.make_encounter_count
  end
  #--------------------------------------------------------------------------
  # * Change Formation Access
  #--------------------------------------------------------------------------
  def command_137
    $game_system.formation_disabled = (@params[0] == 0)
  end
  #--------------------------------------------------------------------------
  # * Change Window Color
  #--------------------------------------------------------------------------
  def command_138
    $game_system.window_tone = @params[0]
  end
  #--------------------------------------------------------------------------
  # * Transfer Player
  #--------------------------------------------------------------------------
  def command_201
    return if $game_party.in_battle
    Fiber.yield while $game_player.transfer? || $game_message.visible
    if @params[0] == 0                      # Direct designation
      map_id = @params[1]
      x = @params[2]
      y = @params[3]
    else                                    # Designation with variables
      map_id = $game_variables[@params[1]]
      x = $game_variables[@params[2]]
      y = $game_variables[@params[3]]
    end
    $game_player.reserve_transfer(map_id, x, y, @params[4])
    $game_temp.fade_type = @params[5]
    Fiber.yield while $game_player.transfer?
  end
  #--------------------------------------------------------------------------
  # * Set Vehicle Location
  #--------------------------------------------------------------------------
  def command_202
    if @params[1] == 0                      # Direct designation
      map_id = @params[2]
      x = @params[3]
      y = @params[4]
    else                                    # Designation with variables
      map_id = $game_variables[@params[2]]
      x = $game_variables[@params[3]]
      y = $game_variables[@params[4]]
    end
    vehicle = $game_map.vehicles[@params[0]]
    vehicle.set_location(map_id, x, y) if vehicle
  end
  #--------------------------------------------------------------------------
  # * Set Event Location
  #--------------------------------------------------------------------------
  def command_203
    character = get_character(@params[0])
    if character
      if @params[1] == 0                      # Direct designation
        character.moveto(@params[2], @params[3])
      elsif @params[1] == 1                   # Designation with variables
        new_x = $game_variables[@params[2]]
        new_y = $game_variables[@params[3]]
        character.moveto(new_x, new_y)
      else                                    # Exchange with another event
        character2 = get_character(@params[2])
        character.swap(character2) if character2
      end
      character.set_direction(@params[4]) if @params[4] > 0
    end
  end
  #--------------------------------------------------------------------------
  # * Scroll Map
  #--------------------------------------------------------------------------
  def command_204
    return if $game_party.in_battle
    Fiber.yield while $game_map.scrolling?
    $game_map.start_scroll(@params[0], @params[1], @params[2])
  end
  #--------------------------------------------------------------------------
  # * Set Move Route
  #--------------------------------------------------------------------------
  def command_205
    $game_map.refresh if $game_map.need_refresh
    character = get_character(@params[0])
    if character
      character.force_move_route(@params[1])
      Fiber.yield while character.move_route_forcing if @params[1].wait
    end
  end
  #--------------------------------------------------------------------------
  # * Getting On and Off Vehicles
  #--------------------------------------------------------------------------
  def command_206
    $game_player.get_on_off_vehicle
  end
  #--------------------------------------------------------------------------
  # * Change Transparency
  #--------------------------------------------------------------------------
  def command_211
    $game_player.transparent = (@params[0] == 0)
  end
  #--------------------------------------------------------------------------
  # * Show Animation
  #--------------------------------------------------------------------------
  def command_212
    character = get_character(@params[0])
    if character
      character.animation_id = @params[1]
      Fiber.yield while character.animation_id > 0 if @params[2]
    end
  end
  #--------------------------------------------------------------------------
  # * Show Balloon Icon
  #--------------------------------------------------------------------------
  def command_213
    character = get_character(@params[0])
    if character
      character.balloon_id = @params[1]
      Fiber.yield while character.balloon_id > 0 if @params[2]
    end
  end
  #--------------------------------------------------------------------------
  # * Temporarily Erase Event
  #--------------------------------------------------------------------------
  def command_214
    $game_map.events[@event_id].erase if same_map? && @event_id > 0
  end
  #--------------------------------------------------------------------------
  # * Change Player Followers
  #--------------------------------------------------------------------------
  def command_216
    $game_player.followers.visible = (@params[0] == 0)
    $game_player.refresh
  end
  #--------------------------------------------------------------------------
  # * Gather Followers
  #--------------------------------------------------------------------------
  def command_217
    return if $game_party.in_battle
    $game_player.followers.gather
    Fiber.yield until $game_player.followers.gather?
  end
  #--------------------------------------------------------------------------
  # * Fadeout Screen
  #--------------------------------------------------------------------------
  def command_221
    Fiber.yield while $game_message.visible
    screen.start_fadeout(30)
    wait(30)
  end
  #--------------------------------------------------------------------------
  # * Fadein Screen
  #--------------------------------------------------------------------------
  def command_222
    Fiber.yield while $game_message.visible
    screen.start_fadein(30)
    wait(30)
  end
  #--------------------------------------------------------------------------
  # * Tint Screen
  #--------------------------------------------------------------------------
  def command_223
    screen.start_tone_change(@params[0], @params[1])
    wait(@params[1]) if @params[2]
  end
  #--------------------------------------------------------------------------
  # * Screen Flash
  #--------------------------------------------------------------------------
  def command_224
    screen.start_flash(@params[0], @params[1])
    wait(@params[1]) if @params[2]
  end
  #--------------------------------------------------------------------------
  # * Screen Shake
  #--------------------------------------------------------------------------
  def command_225
    screen.start_shake(@params[0], @params[1], @params[2])
    wait(@params[1]) if @params[2]
  end
  #--------------------------------------------------------------------------
  # * Wait
  #--------------------------------------------------------------------------
  def command_230
    wait(@params[0])
  end
  #--------------------------------------------------------------------------
  # * Show Picture
  #--------------------------------------------------------------------------
  def command_231
    if @params[3] == 0    # Direct designation
      x = @params[4]
      y = @params[5]
    else                  # Designation with variables
      x = $game_variables[@params[4]]
      y = $game_variables[@params[5]]
    end
    screen.pictures[@params[0]].show(@params[1], @params[2],
      x, y, @params[6], @params[7], @params[8], @params[9])
  end
  #--------------------------------------------------------------------------
  # * Move Picture
  #--------------------------------------------------------------------------
  def command_232
    if @params[3] == 0    # Direct designation
      x = @params[4]
      y = @params[5]
    else                  # Designation with variables
      x = $game_variables[@params[4]]
      y = $game_variables[@params[5]]
    end
    screen.pictures[@params[0]].move(@params[2], x, y, @params[6],
      @params[7], @params[8], @params[9], @params[10])
    wait(@params[10]) if @params[11]
  end
  #--------------------------------------------------------------------------
  # * Rotate Picture
  #--------------------------------------------------------------------------
  def command_233
    screen.pictures[@params[0]].rotate(@params[1])
  end
  #--------------------------------------------------------------------------
  # * Tint Picture
  #--------------------------------------------------------------------------
  def command_234
    screen.pictures[@params[0]].start_tone_change(@params[1], @params[2])
    wait(@params[2]) if @params[3]
  end
  #--------------------------------------------------------------------------
  # * Erase Picture
  #--------------------------------------------------------------------------
  def command_235
    screen.pictures[@params[0]].erase
  end
  #--------------------------------------------------------------------------
  # * Set Weather
  #--------------------------------------------------------------------------
  def command_236
    return if $game_party.in_battle
    screen.change_weather(@params[0], @params[1], @params[2])
    wait(@params[2]) if @params[3]
  end
  #--------------------------------------------------------------------------
  # * Play BGM
  #--------------------------------------------------------------------------
  def command_241
    @params[0].play
  end
  #--------------------------------------------------------------------------
  # * Fadeout BGM
  #--------------------------------------------------------------------------
  def command_242
    RPG::BGM.fade(@params[0] * 1000)
  end
  #--------------------------------------------------------------------------
  # * Save BGM
  #--------------------------------------------------------------------------
  def command_243
    $game_system.save_bgm
  end
  #--------------------------------------------------------------------------
  # * Resume BGM
  #--------------------------------------------------------------------------
  def command_244
    $game_system.replay_bgm
  end
  #--------------------------------------------------------------------------
  # * Play BGS
  #--------------------------------------------------------------------------
  def command_245
    @params[0].play
  end
  #--------------------------------------------------------------------------
  # * Fadeout BGS
  #--------------------------------------------------------------------------
  def command_246
    RPG::BGS.fade(@params[0] * 1000)
  end
  #--------------------------------------------------------------------------
  # * Play ME
  #--------------------------------------------------------------------------
  def command_249
    @params[0].play
  end
  #--------------------------------------------------------------------------
  # * Play SE
  #--------------------------------------------------------------------------
  def command_250
    @params[0].play
  end
  #--------------------------------------------------------------------------
  # * Stop SE
  #--------------------------------------------------------------------------
  def command_251
    RPG::SE.stop
  end
  #--------------------------------------------------------------------------
  # * Play Movie
  #--------------------------------------------------------------------------
  def command_261
    Fiber.yield while $game_message.visible
    Fiber.yield
    name = @params[0]
    Graphics.play_movie('Movies/' + name) unless name.empty?
  end
  #--------------------------------------------------------------------------
  # * Change Map Name Display
  #--------------------------------------------------------------------------
  def command_281
    $game_map.name_display = (@params[0] == 0)
  end
  #--------------------------------------------------------------------------
  # * Change Tileset
  #--------------------------------------------------------------------------
  def command_282
    $game_map.change_tileset(@params[0])
  end
  #--------------------------------------------------------------------------
  # * Change Battle Background
  #--------------------------------------------------------------------------
  def command_283
    $game_map.change_battleback(@params[0], @params[1])
  end
  #--------------------------------------------------------------------------
  # * Change Parallax Background
  #--------------------------------------------------------------------------
  def command_284
    $game_map.change_parallax(@params[0], @params[1], @params[2],
                              @params[3], @params[4])
  end
  #--------------------------------------------------------------------------
  # * Get Location Info
  #--------------------------------------------------------------------------
  def command_285
    if @params[2] == 0      # Direct designation
      x = @params[3]
      y = @params[4]
    else                    # Designation with variables
      x = $game_variables[@params[3]]
      y = $game_variables[@params[4]]
    end
    case @params[1]
    when 0      # Terrain Tag
      value = $game_map.terrain_tag(x, y)
    when 1      # Event ID
      value = $game_map.event_id_xy(x, y)
    when 2..4   # Tile ID
      value = $game_map.tile_id(x, y, @params[1] - 2)
    else        # Region ID
      value = $game_map.region_id(x, y)
    end
    $game_variables[@params[0]] = value
  end
  #--------------------------------------------------------------------------
  # * Battle Processing
  #--------------------------------------------------------------------------
  def command_301
    return if $game_party.in_battle
    if @params[0] == 0                      # Direct designation
      troop_id = @params[1]
    elsif @params[0] == 1                   # Designation with variables
      troop_id = $game_variables[@params[1]]
    else                                    # Map-designated troop
      troop_id = $game_player.make_encounter_troop_id
    end
    if $data_troops[troop_id]
      BattleManager.setup(troop_id, @params[2], @params[3])
      BattleManager.event_proc = Proc.new {|n| @branch[@indent] = n }
      $game_player.make_encounter_count
      SceneManager.call(Scene_Battle)
    end
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # * If Win
  #--------------------------------------------------------------------------
  def command_601
    command_skip if @branch[@indent] != 0
  end
  #--------------------------------------------------------------------------
  # * If Escape
  #--------------------------------------------------------------------------
  def command_602
    command_skip if @branch[@indent] != 1
  end
  #--------------------------------------------------------------------------
  # * If Lose
  #--------------------------------------------------------------------------
  def command_603
    command_skip if @branch[@indent] != 2
  end
  #--------------------------------------------------------------------------
  # * Shop Processing
  #--------------------------------------------------------------------------
  def command_302
    return if $game_party.in_battle
    goods = [@params]
    while next_event_code == 605
      @index += 1
      goods.push(@list[@index].parameters)
    end
    SceneManager.call(Scene_Shop)
    SceneManager.scene.prepare(goods, @params[4])
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # * Name Input Processing
  #--------------------------------------------------------------------------
  def command_303
    return if $game_party.in_battle
    if $data_actors[@params[0]]
      SceneManager.call(Scene_Name)
      SceneManager.scene.prepare(@params[0], @params[1])
      Fiber.yield
    end
  end
  #--------------------------------------------------------------------------
  # * Change HP
  #--------------------------------------------------------------------------
  def command_311
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      next if actor.dead?
      actor.change_hp(value, @params[5])
      actor.perform_collapse_effect if actor.dead?
    end
    SceneManager.goto(Scene_Gameover) if $game_party.all_dead?
  end
  #--------------------------------------------------------------------------
  # * Change MP
  #--------------------------------------------------------------------------
  def command_312
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.mp += value
    end
  end
  #--------------------------------------------------------------------------
  # * Change State
  #--------------------------------------------------------------------------
  def command_313
    iterate_actor_var(@params[0], @params[1]) do |actor|
      already_dead = actor.dead?
      if @params[2] == 0
        actor.add_state(@params[3])
      else
        actor.remove_state(@params[3])
      end
      actor.perform_collapse_effect if actor.dead? && !already_dead
    end
    $game_party.clear_results
  end
  #--------------------------------------------------------------------------
  # * Recover All
  #--------------------------------------------------------------------------
  def command_314
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.recover_all
    end
  end
  #--------------------------------------------------------------------------
  # * Change EXP
  #--------------------------------------------------------------------------
  def command_315
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.change_exp(actor.exp + value, @params[5])
    end
  end
  #--------------------------------------------------------------------------
  # * Change Level
  #--------------------------------------------------------------------------
  def command_316
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.change_level(actor.level + value, @params[5])
    end
  end
  #--------------------------------------------------------------------------
  # * Change Parameters
  #--------------------------------------------------------------------------
  def command_317
    value = operate_value(@params[3], @params[4], @params[5])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.add_param(@params[2], value)
    end
  end
  #--------------------------------------------------------------------------
  # * Change Skills
  #--------------------------------------------------------------------------
  def command_318
    iterate_actor_var(@params[0], @params[1]) do |actor|
      if @params[2] == 0
        actor.learn_skill(@params[3])
      else
        actor.forget_skill(@params[3])
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Change Equipment
  #--------------------------------------------------------------------------
  def command_319
    actor = $game_actors[@params[0]]
    actor.change_equip_by_id(@params[1], @params[2]) if actor
  end
  #--------------------------------------------------------------------------
  # * Change Name
  #--------------------------------------------------------------------------
  def command_320
    actor = $game_actors[@params[0]]
    actor.name = @params[1] if actor
  end
  #--------------------------------------------------------------------------
  # * Change Class
  #--------------------------------------------------------------------------
  def command_321
    actor = $game_actors[@params[0]]
    actor.change_class(@params[1]) if actor && $data_classes[@params[1]]
  end
  #--------------------------------------------------------------------------
  # * Change Actor Graphic
  #--------------------------------------------------------------------------
  def command_322
    actor = $game_actors[@params[0]]
    if actor
      actor.set_graphic(@params[1], @params[2], @params[3], @params[4])
    end
    $game_player.refresh
  end
  #--------------------------------------------------------------------------
  # * Change Vehicle Graphic
  #--------------------------------------------------------------------------
  def command_323
    vehicle = $game_map.vehicles[@params[0]]
    vehicle.set_graphic(@params[1], @params[2]) if vehicle
  end
  #--------------------------------------------------------------------------
  # * Change Nickname
  #--------------------------------------------------------------------------
  def command_324
    actor = $game_actors[@params[0]]
    actor.nickname = @params[1] if actor
  end
  #--------------------------------------------------------------------------
  # * Change Enemy HP
  #--------------------------------------------------------------------------
  def command_331
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_enemy_index(@params[0]) do |enemy|
      return if enemy.dead?
      enemy.change_hp(value, @params[4])
      enemy.perform_collapse_effect if enemy.dead?
    end
  end
  #--------------------------------------------------------------------------
  # * Change Enemy MP
  #--------------------------------------------------------------------------
  def command_332
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.mp += value
    end
  end
  #--------------------------------------------------------------------------
  # * Change Enemy State
  #--------------------------------------------------------------------------
  def command_333
    iterate_enemy_index(@params[0]) do |enemy|
      already_dead = enemy.dead?
      if @params[1] == 0
        enemy.add_state(@params[2])
      else
        enemy.remove_state(@params[2])
      end
      enemy.perform_collapse_effect if enemy.dead? && !already_dead
    end
  end
  #--------------------------------------------------------------------------
  # * Enemy Recover All
  #--------------------------------------------------------------------------
  def command_334
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.recover_all
    end
  end
  #--------------------------------------------------------------------------
  # * Enemy Appear
  #--------------------------------------------------------------------------
  def command_335
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.appear
      $game_troop.make_unique_names
    end
  end
  #--------------------------------------------------------------------------
  # * Enemy Transform
  #--------------------------------------------------------------------------
  def command_336
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.transform(@params[1])
      $game_troop.make_unique_names
    end
  end
  #--------------------------------------------------------------------------
  # * Show Battle Animation
  #--------------------------------------------------------------------------
  def command_337
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.animation_id = @params[1] if enemy.alive?
    end
  end
  #--------------------------------------------------------------------------
  # * Force Action
  #--------------------------------------------------------------------------
  def command_339
    iterate_battler(@params[0], @params[1]) do |battler|
      next if battler.death_state?
      battler.force_action(@params[2], @params[3])
      BattleManager.force_action(battler)
      Fiber.yield while BattleManager.action_forced?
    end
  end
  #--------------------------------------------------------------------------
  # * Abort Battle
  #--------------------------------------------------------------------------
  def command_340
    BattleManager.abort
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # * Open Menu Screen
  #--------------------------------------------------------------------------
  def command_351
    return if $game_party.in_battle
    SceneManager.call(Scene_Menu)
    Window_MenuCommand::init_command_position
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # * Open Save Screen
  #--------------------------------------------------------------------------
  def command_352
    return if $game_party.in_battle
    SceneManager.call(Scene_Save)
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # * Game Over
  #--------------------------------------------------------------------------
  def command_353
    SceneManager.goto(Scene_Gameover)
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # * Return to Title Screen
  #--------------------------------------------------------------------------
  def command_354
    SceneManager.goto(Scene_Title)
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # * Script
  #--------------------------------------------------------------------------
  def command_355
    script = @list[@index].parameters[0] + "\n"
    while next_event_code == 655
      @index += 1
      script += @list[@index].parameters[0] + "\n"
    end
    eval(script)
  end
end
