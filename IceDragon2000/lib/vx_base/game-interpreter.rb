#encoding:UTF-8
# Game_Interpreter*
#==============================================================================
# ** Game_Interpreter (Bugs Fixed)
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     depth : nest depth
  #     main  : main flag
  #--------------------------------------------------------------------------
  def initialize(depth = 0, main = false)
    @depth = depth
    @main = main
    if @depth > 100
      print("Common event call has exceeded maximum limit.")
      exit
    end
    clear
  end
  #--------------------------------------------------------------------------
  # * Clear
  #--------------------------------------------------------------------------
  def clear
    @map_id = 0                       # Map ID when starting up
    @original_event_id = 0            # Event ID when starting up
    @event_id = 0                     # Event ID
    @list = nil                       # Execution content
    @index = 0                        # Index
    @message_waiting = false          # Waiting for message to end
    @moving_character = nil           # Moving character
    @wait_count = 0                   # Wait count
    @child_interpreter = nil          # Child interpreter
    @branch = {}                      # Branch data
  end
  #--------------------------------------------------------------------------
  # * Event Setup
  #     list     : list of event commands
  #     event_id : event ID
  #--------------------------------------------------------------------------
  def setup(list, event_id = 0)
    clear                             # Clear internal interpreter state
    @map_id = $game_map.map_id        # Memorize map ID
    @original_event_id = event_id     # Memorize event ID
    @event_id = event_id              # Memorize event ID
    @list = list                      # Memorize execution contents
    @index = 0                        # Initialize index
    cancel_menu_call                  # Cancel menu call
  end
  #--------------------------------------------------------------------------
  # * Cancel Menu Call
  #    Handles the situation when a player is moving and the cancel button
  #    is pushed,  starting an event in the state where a menu call was
  #    reserved.
  #--------------------------------------------------------------------------
  def cancel_menu_call
    if @main and $game_temp.next_scene == "menu" and $game_temp.menu_beep
      $game_temp.next_scene = nil
      $game_temp.menu_beep = false
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Running
  #--------------------------------------------------------------------------
  def running?
    return @list != nil
  end
  #--------------------------------------------------------------------------
  # * Starting Event Setup
  #--------------------------------------------------------------------------
  def setup_starting_event
    if $game_map.need_refresh             # If necessary, refresh the map
      $game_map.refresh
    end
    if $game_temp.common_event_id > 0     # Common event call reserved?
      setup($data_common_events[$game_temp.common_event_id].list)
      $game_temp.common_event_id = 0
      return
    end
    for event in $game_map.events.values  # Map event
      if event.starting                   # If a starting event is found
        event.clear_starting              # Clear starting flag
        setup(event.list, event.id)       # Set up event
        return
      end
    end
    for event in $data_common_events.compact      # Common event
      if event.trigger == 1 and                   # If autorun and
         $game_switches[event.switch_id] == true  # condition switch is ON
        setup(event.list)                         # Set up event
        return
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    loop do
      if $game_map.map_id != @map_id        # Map is different?
        @event_id = 0                       # Make event ID 0
      end
      if @child_interpreter != nil          # If child interpreter exists
        @child_interpreter.update           # Update child interpreter
        if @child_interpreter.running?      # If running
          return                            # Return
        else                                # After execution has finished
          @child_interpreter = nil          # Erase child interpreter
        end
      end
      if @message_waiting                   # Waiting for message finish
        return
      end
      if @moving_character != nil           # Waiting for move to finish
        if @moving_character.move_route_forcing
          return
        end
        @moving_character = nil
      end
      if @wait_count > 0                    # Waiting
        @wait_count -= 1
        return
      end
      if $game_troop.forcing_battler != nil # Forcing battle action
        return
      end
      if $game_temp.next_scene != nil       # Opening screens
        return
      end
      if @list == nil                       # If content list is empty
        setup_starting_event if @main       # Set up starting event
        return if @list == nil              # Nothing was set up
      end
      return if execute_command == false    # Execute event command
      @index += 1                           # Advance index
    end
  end
  #--------------------------------------------------------------------------
  # * Actor iterator (ID)
  #     param : If 1 or more, ID. If 0, all
  #--------------------------------------------------------------------------
  def iterate_actor_id(param)
    if param == 0       # All
      for actor in $game_party.members do yield actor end
    else                # One
      actor = $game_actors[param]
      yield actor unless actor == nil
    end
  end
  #--------------------------------------------------------------------------
  # * Actor iterator (index)
  #     param : If 0 or more, index. If -1, all.
  #--------------------------------------------------------------------------
  def iterate_actor_index(param)
    if param == -1      # All
      for actor in $game_party.members do yield actor end
    else                # One
      actor = $game_party.members[param]
      yield actor unless actor == nil
    end
  end
  #--------------------------------------------------------------------------
  # * Enemy iterator (index)
  #     param : If 0 or more, index. If -1, all.
  #--------------------------------------------------------------------------
  def iterate_enemy_index(param)
    if param == -1      # All
      for enemy in $game_troop.members do yield enemy end
    else                # One
      enemy = $game_troop.members[param]
      yield enemy unless enemy == nil
    end
  end
  #--------------------------------------------------------------------------
  # * Battler iterator (for entire troop, entire party)
  #     param1 : If 0, enemy. If 1, actor.
  #     param : If 0 or more, index. If -1, all.
  #--------------------------------------------------------------------------
  def iterate_battler(param1, param2)
    if $game_temp.in_battle
      if param1 == 0      # Enemy
        iterate_enemy_index(param2) do |enemy| yield enemy end
      else                # Actor
        iterate_actor_index(param2) do |enemy| yield enemy end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Get Screen Command Target
  #--------------------------------------------------------------------------
  def screen
    if $game_temp.in_battle
      return $game_troop.screen
    else
      return $game_map.screen
    end
  end
  #--------------------------------------------------------------------------
  # * Event Command Execution
  #--------------------------------------------------------------------------
  def execute_command
    if @index >= @list.size-1
      command_end
      return true
    else
      @params = @list[@index].parameters
      @indent = @list[@index].indent
      case @list[@index].code
      when 101  # Show Text
        return command_101
      when 102  # Show Choices
        return command_102
      when 402  # When [**]
        return command_402
      when 403  # When Cancel
        return command_403
      when 103  # Input Number
        return command_103
      when 111  # Conditional Branch
        return command_111
      when 411  # Else
        return command_411
      when 112  # Loop
        return command_112
      when 413  # Repeat Above
        return command_413
      when 113  # Break Loop
        return command_113
      when 115  # Exit Event Processing
        return command_115
      when 117  # Call Common Event
        return command_117
      when 118  # Label
        return command_118
      when 119  # Jump to Label
        return command_119
      when 121  # Control Switches
        return command_121
      when 122  # Control Variables
        return command_122
      when 123  # Control Self Switch
        return command_123
      when 124  # Control Timer
        return command_124
      when 125  # Change Gold
        return command_125
      when 126  # Change Items
        return command_126
      when 127  # Change Weapons
        return command_127
      when 128  # Change Armor
        return command_128
      when 129  # Change Party Member
        return command_129
      when 132  # Change Battle BGM
        return command_132
      when 133  # Change Battle End ME
        return command_133
      when 134  # Change Save Access
        return command_134
      when 135  # Change Menu Access
        return command_135
      when 136  # Change Encounter
        return command_136
      when 201  # Transfer Player
        return command_201
      when 202  # Set Vehicle Location
        return command_202
      when 203  # Set Event Location
        return command_203
      when 204  # Scroll Map
        return command_204
      when 205  # Set Move Route
        return command_205
      when 206  # Get on/off Vehicle
        return command_206
      when 211  # Change Transparency
        return command_211
      when 212  # Show Animation
        return command_212
      when 213  # Show Balloon Icon
        return command_213
      when 214  # Erase Event
        return command_214
      when 221  # Fadeout Screen
        return command_221
      when 222  # Fadein Screen
        return command_222
      when 223  # Tint Screen
        return command_223
      when 224  # Flash Screen
        return command_224
      when 225  # Shake Screen
        return command_225
      when 230  # Wait
        return command_230
      when 231  # Show Picture
        return command_231
      when 232  # Move Picture
        return command_232
      when 233  # Rotate Picture
        return command_233
      when 234  # Tint Picture
        return command_234
      when 235  # Erase picture
        return command_235
      when 236  # Set Weather Effects
        return command_236
      when 241  # Play BGM
        return command_241
      when 242  # Fadeout BGM
        return command_242
      when 245  # Play BGS
        return command_245
      when 246  # Fadeout BGS
        return command_246
      when 249  # Play ME
        return command_249
      when 250  # Play SE
        return command_250
      when 251  # Stop SE
        return command_251
      when 301  # Battle Processing
        return command_301
      when 601  # If Win
        return command_601
      when 602  # If Escape
        return command_602
      when 603  # If Lose
        return command_603
      when 302  # Shop Processing
        return command_302
      when 303  # Name Input Processing
        return command_303
      when 311  # Change HP
        return command_311
      when 312  # Change MP
        return command_312
      when 313  # Change State
        return command_313
      when 314  # Recover All
        return command_314
      when 315  # Change EXP
        return command_315
      when 316  # Change Level
        return command_316
      when 317  # Change Parameters
        return command_317
      when 318  # Change Skills
        return command_318
      when 319  # Change Equipment
        return command_319
      when 320  # Change Name
        return command_320
      when 321  # Change Class
        return command_321
      when 322  # Change Actor Graphic
        return command_322
      when 323  # Change Vehicle Graphic
        return command_323
      when 331  #  Change Enemy HP
        return command_331
      when 332  #  Change Enemy MP
        return command_332
      when 333  # Change Enemy State
        return command_333
      when 334  # Enemy Recover All
        return command_334
      when 335  # Enemy Appear
        return command_335
      when 336  # Enemy Transform
        return command_336
      when 337  # Show Battle Animation
        return command_337
      when 339  # Force Action
        return command_339
      when 340  # Abort Battle
        return command_340
      when 351  # Open Menu Screen
        return command_351
      when 352  # Open Save Screen
        return command_352
      when 353  # Game Over
        return command_353
      when 354  # Return to Title Screen
        return command_354
      when 355  # Script
        return command_355
      else      # Other
        return true
      end
    end
  end
  #--------------------------------------------------------------------------
  # * End Event
  #--------------------------------------------------------------------------
  def command_end
    @list = nil                             # Clear execution content list
    if @main and @event_id > 0              # If main map event
      $game_map.events[@event_id].unlock    # Clear event lock
    end
  end
  #--------------------------------------------------------------------------
  # * Command Skip
  #--------------------------------------------------------------------------
  def command_skip
    while @list[@index+1].indent > @indent  # Next indent is deeper
      @index += 1                           # Advance index
    end
  end
  #--------------------------------------------------------------------------
  # * Get Character
  #     param : if -1, player. If 0, this event. Otherwise, event ID.
  #--------------------------------------------------------------------------
  def get_character(param)
    case param
    when -1   # Player
      return $game_player
    when 0    # This event
      events = $game_map.events
      return events == nil ? nil : events[@event_id]
    else      # Particular event
      events = $game_map.events
      return events == nil ? nil : events[param]
    end
  end
  #--------------------------------------------------------------------------
  # * Calculate Operated Value
  #     operation    : operation (0: increase, 1: decrease)
  #     operand_type : operand type (0: invariable 1: variable)
  #     operand      : operand (number or variable ID)
  #--------------------------------------------------------------------------
  def operate_value(operation, operand_type, operand)
    if operand_type == 0
      value = operand
    else
      value = $game_variables[operand]
    end
    if operation == 1
      value = -value
    end
    return value
  end
  #--------------------------------------------------------------------------
  # * Show Text
  #--------------------------------------------------------------------------
  def command_101
    unless $game_message.busy
      $game_message.face_name = @params[0]
      $game_message.face_index = @params[1]
      $game_message.background = @params[2]
      $game_message.position = @params[3]
      @index += 1
      while @list[@index].code == 401       # Text data
        $game_message.texts.push(@list[@index].parameters[0])
        @index += 1
      end
      if @list[@index].code == 102          # Show choices
        setup_choices(@list[@index].parameters)
      elsif @list[@index].code == 103       # Number input processing
        setup_num_input(@list[@index].parameters)
      end
      set_message_waiting                   # Set to message wait state
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Set message wait flag and callback
  #--------------------------------------------------------------------------
  def set_message_waiting
    @message_waiting = true
    $game_message.main_proc = Proc.new { @message_waiting = false }
  end
  #--------------------------------------------------------------------------
  # * Show Choices
  #--------------------------------------------------------------------------
  def command_102
    unless $game_message.busy
      setup_choices(@params)                # Setup
      set_message_waiting                   # Set to message wait state
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Setup Choices
  #--------------------------------------------------------------------------
  def setup_choices(params)
    if $game_message.texts.size <= 4 - params[0].size
      $game_message.choice_start = $game_message.texts.size
      $game_message.choice_max = params[0].size
      for s in params[0]
        $game_message.texts.push(s)
      end
      $game_message.choice_cancel_type = params[1]
      $game_message.choice_proc = Proc.new { |n| @branch[@indent] = n }
      @index += 1
    end
  end
  #--------------------------------------------------------------------------
  # * When [**]
  #--------------------------------------------------------------------------
  def command_402
    if @branch[@indent] == @params[0]       # If matching choice
      @branch.delete(@indent)               # Erase branching data
      return true                           # Continue
    else                                    # If doesn't match condition
      return command_skip                   # Command skip
    end
  end
  #--------------------------------------------------------------------------
  # * When Cancel
  #--------------------------------------------------------------------------
  def command_403
    if @branch[@indent] == 4                # If canceling choice
      @branch.delete(@indent)               # Erase branching data
      return true                           # Continue
    else                                    # If doesn't match condition
      return command_skip                   # Command skip
    end
  end
  #--------------------------------------------------------------------------
  # * Input Number
  #--------------------------------------------------------------------------
  def command_103
    unless $game_message.busy
      setup_num_input(@params)              # Setup
      set_message_waiting                   # Set to message wait state
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Number Input Setup
  #--------------------------------------------------------------------------
  def setup_num_input(params)
    if $game_message.texts.size < 4
      $game_message.num_input_variable_id = params[0]
      $game_message.num_input_digits_max = params[1]
      @index += 1
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
      if @original_event_id > 0
        key = [@map_id, @original_event_id, @params[1]]
        if @params[2] == 0
          result = ($game_self_switches[key] == true)
        else
          result = ($game_self_switches[key] != true)
        end
      end
    when 3  # Timer
      if $game_system.timer_working
        sec = $game_system.timer / Graphics.frame_rate
        if @params[2] == 0
          result = (sec >= @params[1])
        else
          result = (sec <= @params[1])
        end
      end
    when 4  # Actor
      actor = $game_actors[@params[1]]
      if actor != nil
        case @params[2]
        when 0  # in party
          result = ($game_party.members.include?(actor))
        when 1  # name
          result = (actor.name == @params[3])
        when 2  # skill
          result = (actor.skill_learn?($data_skills[@params[3]]))
        when 3  # weapon
          result = (actor.weapons.include?($data_weapons[@params[3]]))
        when 4  # armor
          result = (actor.armors.include?($data_armors[@params[3]]))
        when 5  # state
          result = (actor.state?(@params[3]))
        end
      end
    when 5  # Enemy
      enemy = $game_troop.members[@params[1]]
      if enemy != nil
        case @params[2]
        when 0  # appear
          result = (enemy.exist?)
        when 1  # state
          result = (enemy.state?(@params[3]))
        end
      end
    when 6  # Character
      character = get_character(@params[1])
      if character != nil
        result = (character.direction == @params[2])
      end
    when 7  # Gold
      if @params[2] == 0
        result = ($game_party.gold >= @params[1])
      else
        result = ($game_party.gold <= @params[1])
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
      result = ($game_player.vehicle_type == @params[1])
    end
    @branch[@indent] = result     # Store determination results in hash
    if @branch[@indent] == true
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
  #--------------------------------------------------------------------------
  # * Else
  #--------------------------------------------------------------------------
  def command_411
    if @branch[@indent] == false
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
  #--------------------------------------------------------------------------
  # * Loop
  #--------------------------------------------------------------------------
  def command_112
    return true
  end
  #--------------------------------------------------------------------------
  # * Repeat Above
  #--------------------------------------------------------------------------
  def command_413
    begin
      @index -= 1
    end until @list[@index].indent == @indent
    return true
  end
  #--------------------------------------------------------------------------
  # * Break Loop
  #--------------------------------------------------------------------------
  def command_113
    loop do
      @index += 1
      if @index >= @list.size-1
        return true
      end
      if @list[@index].code == 413 and    # Command [Repeat Above]
         @list[@index].indent < @indent   # Indent is shallow
        return true
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Exit Event Processing
  #--------------------------------------------------------------------------
  def command_115
    command_end
    return true
  end
  #--------------------------------------------------------------------------
  # * Call Common Event
  #--------------------------------------------------------------------------
  def command_117
    common_event = $data_common_events[@params[0]]
    if common_event != nil
      @child_interpreter = Game_Interpreter.new(@depth + 1)
      @child_interpreter.setup(common_event.list, @event_id)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Label
  #--------------------------------------------------------------------------
  def command_118
    return true
  end
  #--------------------------------------------------------------------------
  # * Jump to Label
  #--------------------------------------------------------------------------
  def command_119
    label_name = @params[0]
    for i in 0...@list.size
      if @list[i].code == 118 and @list[i].parameters[0] == label_name
        @index = i
        return true
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Control Switches
  #--------------------------------------------------------------------------
  def command_121
    for i in @params[0] .. @params[1]   # Batch control
      $game_switches[i] = (@params[2] == 0)
    end
    $game_map.need_refresh = true
    return true
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
    when 3  # Item
      value = $game_party.item_number($data_items[@params[4]])
    when 4  # Actor
      actor = $game_actors[@params[4]]
      if actor != nil
        case @params[5]
        when 0  # Level
          value = actor.level
        when 1  # Experience
          value = actor.exp
        when 2  # HP
          value = actor.hp
        when 3  # MP
          value = actor.mp
        when 4  # Maximum HP
          value = actor.maxhp
        when 5  # Maximum MP
          value = actor.maxmp
        when 6  # Attack
          value = actor.atk
        when 7  # Defense
          value = actor.def
        when 8  # Spirit
          value = actor.spi
        when 9  # Agility
          value = actor.agi
        end
      end
    when 5  # Enemy
      enemy = $game_troop.members[@params[4]]
      if enemy != nil
        case @params[5]
        when 0  # HP
          value = enemy.hp
        when 1  # MP
          value = enemy.mp
        when 2  # Maximum HP
          value = enemy.maxhp
        when 3  # Maximum MP
          value = enemy.maxmp
        when 4  # Attack
          value = enemy.atk
        when 5  # Defense
          value = enemy.def
        when 6  # Spirit
          value = enemy.spi
        when 7  # Agility
          value = enemy.agi
        end
      end
    when 6  # Character
      character = get_character(@params[4])
      if character != nil
        case @params[5]
        when 0  # x-coordinate
          value = character.x
        when 1  # y-coordinate
          value = character.y
        when 2  # direction
          value = character.direction
        when 3  # screen x-coordinate
          value = character.screen_x
        when 4  # screen y-coordinate
          value = character.screen_y
        end
      end
    when 7  # Other
      case @params[4]
      when 0  # map ID
        value = $game_map.map_id
      when 1  # number of party members
        value = $game_party.members.size
      when 2  # gold
        value = $game_party.gold
      when 3  # steps
        value = $game_party.steps
      when 4  # play time
        value = Graphics.frame_count / Graphics.frame_rate
      when 5  # timer
        value = $game_system.timer / Graphics.frame_rate
      when 6  # save count
        value = $game_system.save_count
      end
    end
    for i in @params[0] .. @params[1]   # Batch control
      case @params[2]  # Operation
      when 0  # Set
        $game_variables[i] = value
      when 1  # Add
        $game_variables[i] += value
      when 2  # Sub
        $game_variables[i] -= value
      when 3  # Mul
        $game_variables[i] *= value
      when 4  # Div
        $game_variables[i] /= value if value != 0
      when 5  # Mod
        $game_variables[i] %= value if value != 0
      end
      if $game_variables[i] > 99999999    # Maximum limit check
        $game_variables[i] = 99999999
      end
      if $game_variables[i] < -99999999   # Minimum limit check
        $game_variables[i] = -99999999
      end
    end
    $game_map.need_refresh = true
    return true
  end
  #--------------------------------------------------------------------------
  # * Control Self Switch
  #--------------------------------------------------------------------------
  def command_123
    if @original_event_id > 0
      key = [@map_id, @original_event_id, @params[0]]
      $game_self_switches[key] = (@params[1] == 0)
    end
    $game_map.need_refresh = true
    return true
  end
  #--------------------------------------------------------------------------
  # * Control Timer
  #--------------------------------------------------------------------------
  def command_124
    if @params[0] == 0  # Start
      $game_system.timer = @params[1] * Graphics.frame_rate
      $game_system.timer_working = true
    end
    if @params[0] == 1  # Stop
      $game_system.timer_working = false
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Gold
  #--------------------------------------------------------------------------
  def command_125
    value = operate_value(@params[0], @params[1], @params[2])
    $game_party.gain_gold(value)
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Items
  #--------------------------------------------------------------------------
  def command_126
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_items[@params[0]], value)
    $game_map.need_refresh = true
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Weapons
  #--------------------------------------------------------------------------
  def command_127
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_weapons[@params[0]], value, @params[4])
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Armor
  #--------------------------------------------------------------------------
  def command_128
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_armors[@params[0]], value, @params[4])
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Party Member
  #--------------------------------------------------------------------------
  def command_129
    actor = $game_actors[@params[0]]
    if actor != nil
      if @params[1] == 0    # Add
        if @params[2] == 1  # Initialize
          $game_actors[@params[0]].setup(@params[0])
        end
        $game_party.add_actor(@params[0])
      else                  # Remove
        $game_party.remove_actor(@params[0])
      end
      $game_map.need_refresh = true
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Battle BGM
  #--------------------------------------------------------------------------
  def command_132
    $game_system.battle_bgm = @params[0]
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Battle End ME
  #--------------------------------------------------------------------------
  def command_133
    $game_system.battle_end_me = @params[0]
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Save Access
  #--------------------------------------------------------------------------
  def command_134
    $game_system.save_disabled = (@params[0] == 0)
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Menu Access
  #--------------------------------------------------------------------------
  def command_135
    $game_system.menu_disabled = (@params[0] == 0)
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Encounter
  #--------------------------------------------------------------------------
  def command_136
    $game_system.encounter_disabled = (@params[0] == 0)
    $game_player.make_encounter_count
    return true
  end
  #--------------------------------------------------------------------------
  # * Transfer Player
  #--------------------------------------------------------------------------
  def command_201
    return true if $game_temp.in_battle
    if $game_player.transfer? or            # Transferring Player
       $game_message.visible                # Displaying a message
      return false
    end
    if @params[0] == 0                      # Direct designation
      map_id = @params[1]
      x = @params[2]
      y = @params[3]
      direction = @params[4]
    else                                    # Designation with variables
      map_id = $game_variables[@params[1]]
      x = $game_variables[@params[2]]
      y = $game_variables[@params[3]]
      direction = @params[4]
    end
    $game_player.reserve_transfer(map_id, x, y, direction)
    @index += 1
    return false
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
    if @params[0] == 0                      # Boat
      $game_map.boat.set_location(map_id, x, y)
    elsif @params[0] == 1                   # Ship
      $game_map.ship.set_location(map_id, x, y)
    else                                    # Airship
      $game_map.airship.set_location(map_id, x, y)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Set Event Location
  #--------------------------------------------------------------------------
  def command_203
    character = get_character(@params[0])
    if character != nil
      if @params[1] == 0                      # Direct designation
        character.moveto(@params[2], @params[3])
      elsif @params[1] == 1                   # Designation with variables
        new_x = $game_variables[@params[2]]
        new_y = $game_variables[@params[3]]
        character.moveto(new_x, new_y)
      else                                    # Exchange with another event
        old_x = character.x
        old_y = character.y
        character2 = get_character(@params[2])
        if character2 != nil
          character.moveto(character2.x, character2.y)
          character2.moveto(old_x, old_y)
        end
      end
      case @params[4]   # Direction
      when 8  # Up
        character.turn_up
      when 6  # Right
        character.turn_right
      when 2  # Down
        character.turn_down
      when 4  # Left
        character.turn_left
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Scroll Map
  #--------------------------------------------------------------------------
  def command_204
    return true if $game_temp.in_battle
    return false if $game_map.scrolling?
    $game_map.start_scroll(@params[0], @params[1], @params[2])
    return true
  end
  #--------------------------------------------------------------------------
  # * Set Move Route
  #--------------------------------------------------------------------------
  def command_205
    if $game_map.need_refresh
      $game_map.refresh
    end
    character = get_character(@params[0])
    if character != nil
      character.force_move_route(@params[1])
      @moving_character = character if @params[1].wait
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Get on/off Vehicle
  #--------------------------------------------------------------------------
  def command_206
    $game_player.get_on_off_vehicle
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Transparency
  #--------------------------------------------------------------------------
  def command_211
    $game_player.transparent = (@params[0] == 0)
    return true
  end
  #--------------------------------------------------------------------------
  # * Show Animation
  #--------------------------------------------------------------------------
  def command_212
    character = get_character(@params[0])
    if character != nil
      character.animation_id = @params[1]
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Show Balloon Icon
  #--------------------------------------------------------------------------
  def command_213
    character = get_character(@params[0])
    if character != nil
      character.balloon_id = @params[1]
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Erase Event
  #--------------------------------------------------------------------------
  def command_214
    if @event_id > 0
      $game_map.events[@event_id].erase
    end
    @index += 1
    return false
  end
  #--------------------------------------------------------------------------
  # * Fadeout Screen
  #--------------------------------------------------------------------------
  def command_221
    if $game_message.visible
      return false
    else
      screen.start_fadeout(30)
      @wait_count = 30
      return true
    end
  end
  #--------------------------------------------------------------------------
  # * Fadein Screen
  #--------------------------------------------------------------------------
  def command_222
    if $game_message.visible
      return false
    else
      screen.start_fadein(30)
      @wait_count = 30
      return true
    end
  end
  #--------------------------------------------------------------------------
  # * Tint Screen
  #--------------------------------------------------------------------------
  def command_223
    screen.start_tone_change(@params[0], @params[1])
    @wait_count = @params[1] if @params[2]
    return true
  end
  #--------------------------------------------------------------------------
  # * Screen Flash
  #--------------------------------------------------------------------------
  def command_224
    screen.start_flash(@params[0], @params[1])
    @wait_count = @params[1] if @params[2]
    return true
  end
  #--------------------------------------------------------------------------
  # * Screen Shake
  #--------------------------------------------------------------------------
  def command_225
    screen.start_shake(@params[0], @params[1], @params[2])
    @wait_count = @params[2] if @params[3]
    return true
  end
  #--------------------------------------------------------------------------
  # * Wait
  #--------------------------------------------------------------------------
  def command_230
    @wait_count = @params[0]
    return true
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
    return true
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
    @wait_count = @params[10] if @params[11]
    return true
  end
  #--------------------------------------------------------------------------
  # * Rotate Picture
  #--------------------------------------------------------------------------
  def command_233
    screen.pictures[@params[0]].rotate(@params[1])
    return true
  end
  #--------------------------------------------------------------------------
  # * Tint Picture
  #--------------------------------------------------------------------------
  def command_234
    screen.pictures[@params[0]].start_tone_change(@params[1], @params[2])
    @wait_count = @params[2] if @params[3]
    return true
  end
  #--------------------------------------------------------------------------
  # * Erase Picture
  #--------------------------------------------------------------------------
  def command_235
    screen.pictures[@params[0]].erase
    return true
  end
  #--------------------------------------------------------------------------
  # * Set Weather Effects
  #--------------------------------------------------------------------------
  def command_236
    return true if $game_temp.in_battle
    screen.weather(@params[0], @params[1], @params[2])
    @wait_count = @params[2] if @params[3]
    return true
  end
  #--------------------------------------------------------------------------
  # * Play BGM
  #--------------------------------------------------------------------------
  def command_241
    @params[0].play
    return true
  end
  #--------------------------------------------------------------------------
  # * Fadeout BGM
  #--------------------------------------------------------------------------
  def command_242
    RPG::BGM.fade(@params[0] * 1000)
    return true
  end
  #--------------------------------------------------------------------------
  # * Play BGS
  #--------------------------------------------------------------------------
  def command_245
    @params[0].play
    return true
  end
  #--------------------------------------------------------------------------
  # * Fadeout BGS
  #--------------------------------------------------------------------------
  def command_246
    RPG::BGS.fade(@params[0] * 1000)
    return true
  end
  #--------------------------------------------------------------------------
  # * Play ME
  #--------------------------------------------------------------------------
  def command_249
    @params[0].play
    return true
  end
  #--------------------------------------------------------------------------
  # * Play SE
  #--------------------------------------------------------------------------
  def command_250
    @params[0].play
    return true
  end
  #--------------------------------------------------------------------------
  # * Stop SE
  #--------------------------------------------------------------------------
  def command_251
    RPG::SE.stop
    return true
  end
  #--------------------------------------------------------------------------
  # * Battle Processing
  #--------------------------------------------------------------------------
  def command_301
    return true if $game_temp.in_battle
    if @params[0] == 0                      # Direct designation
      troop_id = @params[1]
    else                                    # Designation with variables
      troop_id = $game_variables[@params[1]]
    end
    if $data_troops[troop_id] != nil
      $game_troop.setup(troop_id)
      $game_troop.can_escape = @params[2]
      $game_troop.can_lose = @params[3]
      $game_temp.battle_proc = Proc.new { |n| @branch[@indent] = n }
      $game_temp.next_scene = "battle"
    end
    @index += 1
    return false
  end
  #--------------------------------------------------------------------------
  # * If Win
  #--------------------------------------------------------------------------
  def command_601
    if @branch[@indent] == 0
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
  #--------------------------------------------------------------------------
  # * If Escape
  #--------------------------------------------------------------------------
  def command_602
    if @branch[@indent] == 1
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
  #--------------------------------------------------------------------------
  # * If Lose
  #--------------------------------------------------------------------------
  def command_603
    if @branch[@indent] == 2
      @branch.delete(@indent)
      return true
    end
    return command_skip
  end
  #--------------------------------------------------------------------------
  # * Shop Processing
  #--------------------------------------------------------------------------
  def command_302
    $game_temp.next_scene = "shop"
    $game_temp.shop_goods = [@params]
    $game_temp.shop_purchase_only = @params[2]
    loop do
      @index += 1
      if @list[@index].code == 605          # Shop second line or after
        $game_temp.shop_goods.push(@list[@index].parameters)
      else
        return false
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Name Input Processing
  #--------------------------------------------------------------------------
  def command_303
    if $data_actors[@params[0]] != nil
      $game_temp.next_scene = "name"
      $game_temp.name_actor_id = @params[0]
      $game_temp.name_max_char = @params[1]
    end
    @index += 1
    return false
  end
  #--------------------------------------------------------------------------
  # * Change HP
  #--------------------------------------------------------------------------
  def command_311
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_actor_id(@params[0]) do |actor|
      next if actor.dead?
      if @params[4] == false and actor.hp + value <= 0
        actor.hp = 1    # If incapacitation is not allowed, make 1
      else
        actor.hp += value
      end
      actor.perform_collapse
    end
    if $game_party.all_dead?
      $game_temp.next_scene = "gameover"
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Change MP
  #--------------------------------------------------------------------------
  def command_312
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_actor_id(@params[0]) do |actor|
      actor.mp += value
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Change State
  #--------------------------------------------------------------------------
  def command_313
    iterate_actor_id(@params[0]) do |actor|
      if @params[1] == 0
        actor.add_state(@params[2])
        actor.perform_collapse
      else
        actor.remove_state(@params[2])
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Recover All
  #--------------------------------------------------------------------------
  def command_314
    iterate_actor_id(@params[0]) do |actor|
      actor.recover_all
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Change EXP
  #--------------------------------------------------------------------------
  def command_315
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_actor_id(@params[0]) do |actor|
      actor.change_exp(actor.exp + value, @params[4])
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Level
  #--------------------------------------------------------------------------
  def command_316
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_actor_id(@params[0]) do |actor|
      actor.change_level(actor.level + value, @params[4])
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Parameters
  #--------------------------------------------------------------------------
  def command_317
    value = operate_value(@params[2], @params[3], @params[4])
    actor = $game_actors[@params[0]]
    if actor != nil
      case @params[1]
      when 0  # Maximum HP
        actor.maxhp += value
      when 1  # Maximum MP
        actor.maxmp += value
      when 2  # Attack
        actor.atk += value
      when 3  # Defense
        actor.def += value
      when 4  # Spirit
        actor.spi += value
      when 5  # Agility
        actor.agi += value
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Skills
  #--------------------------------------------------------------------------
  def command_318
    actor = $game_actors[@params[0]]
    if actor != nil
      if @params[1] == 0
        actor.learn_skill(@params[2])
      else
        actor.forget_skill(@params[2])
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Equipment
  #--------------------------------------------------------------------------
  def command_319
    actor = $game_actors[@params[0]]
    if actor != nil
      actor.change_equip_by_id(@params[1], @params[2])
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Name
  #--------------------------------------------------------------------------
  def command_320
    actor = $game_actors[@params[0]]
    if actor != nil
      actor.name = @params[1]
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Class
  #--------------------------------------------------------------------------
  def command_321
    actor = $game_actors[@params[0]]
    if actor != nil and $data_classes[@params[1]] != nil
      actor.class_id = @params[1]
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Actor Graphic
  #--------------------------------------------------------------------------
  def command_322
    actor = $game_actors[@params[0]]
    if actor != nil
      actor.set_graphic(@params[1], @params[2], @params[3], @params[4])
    end
    $game_player.refresh
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Vehicle Graphic
  #--------------------------------------------------------------------------
  def command_323
    if @params[0] == 0                      # Boat
      $game_map.boat.set_graphic(@params[1], @params[2])
    elsif @params[0] == 1                   # Ship
      $game_map.ship.set_graphic(@params[1], @params[2])
    else                                    # Airship
      $game_map.airship.set_graphic(@params[1], @params[2])
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Enemy HP
  #--------------------------------------------------------------------------
  def command_331
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_enemy_index(@params[0]) do |enemy|
      if enemy.hp > 0
        if @params[4] == false and enemy.hp + value <= 0
          enemy.hp = 1    # If incapacitation is not allowed, make 1
        else
          enemy.hp += value
        end
        enemy.perform_collapse
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Enemy MP
  #--------------------------------------------------------------------------
  def command_332
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.mp += value
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Change Enemy State
  #--------------------------------------------------------------------------
  def command_333
    iterate_enemy_index(@params[0]) do |enemy|
      if @params[2] == 1                    # If change of incapacitation
        enemy.immortal = false              # Clear immortal flag
      end
      if @params[1] == 0
        enemy.add_state(@params[2])
        enemy.perform_collapse
      else
        enemy.remove_state(@params[2])
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Enemy Recover All
  #--------------------------------------------------------------------------
  def command_334
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.recover_all
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Enemy Appear
  #--------------------------------------------------------------------------
  def command_335
    enemy = $game_troop.members[@params[0]]
    if enemy != nil and enemy.hidden
      enemy.hidden = false
      $game_troop.make_unique_names
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Enemy Transform
  #--------------------------------------------------------------------------
  def command_336
    enemy = $game_troop.members[@params[0]]
    if enemy != nil
      enemy.transform(@params[1])
      $game_troop.make_unique_names
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Show Battle Animation
  #--------------------------------------------------------------------------
  def command_337
    iterate_battler(0, @params[0]) do |battler|
      next unless battler.exist?
      battler.animation_id = @params[1]
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Force Action
  #--------------------------------------------------------------------------
  def command_339
    iterate_battler(@params[0], @params[1]) do |battler|
      next unless battler.exist?
      battler.action.kind = @params[2]
      if battler.action.kind == 0
        battler.action.basic = @params[3]
      else
        battler.action.skill_id = @params[3]
      end
      if @params[4] == -2                   # Last target
        battler.action.decide_last_target
      elsif @params[4] == -1                # Random
        battler.action.decide_random_target
      elsif @params[4] >= 0                 # Index designation
        battler.action.target_index = @params[4]
      end
      battler.action.forcing = true
      $game_troop.forcing_battler = battler
      @index += 1
      return false
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Abort Battle
  #--------------------------------------------------------------------------
  def command_340
    $game_temp.next_scene = "map"
    @index += 1
    return false
  end
  #--------------------------------------------------------------------------
  # * Open Menu Screen
  #--------------------------------------------------------------------------
  def command_351
    $game_temp.next_scene = "menu"
    $game_temp.menu_beep = false
    @index += 1
    return false
  end
  #--------------------------------------------------------------------------
  # * Open Save Screen
  #--------------------------------------------------------------------------
  def command_352
    $game_temp.next_scene = "save"
    @index += 1
    return false
  end
  #--------------------------------------------------------------------------
  # * Game Over
  #--------------------------------------------------------------------------
  def command_353
    $game_temp.next_scene = "gameover"
    return false
  end
  #--------------------------------------------------------------------------
  # * Return to Title Screen
  #--------------------------------------------------------------------------
  def command_354
    $game_temp.next_scene = "title"
    return false
  end
  #--------------------------------------------------------------------------
  # * Script
  #--------------------------------------------------------------------------
  def command_355
    script = @list[@index].parameters[0] + "\n"
    loop do
      if @list[@index+1].code == 655        # Second line of script and after
        script += @list[@index+1].parameters[0] + "\n"
      else
        break
      end
      @index += 1
    end
    eval(script)
    return true
  end
end
