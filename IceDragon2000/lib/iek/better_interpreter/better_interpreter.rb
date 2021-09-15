$simport.r 'iek/better_interpreter', '1.0.0', 'Improves on the existing interpter by wrapping globals in methods'

class Game_Interpreter
  def game_temp
    $game_temp
  end

  def game_system
    $game_system
  end

  def game_timer
    $game_timer
  end

  def game_message
    $game_message
  end

  def game_switches
    $game_switches
  end

  def game_variables
    $game_variables
  end

  def game_self_switches
    $game_self_switches
  end

  def game_actors
    $game_actors
  end

  def game_party
    $game_party
  end

  def game_troop
    $game_troop
  end

  def game_map
    $game_map
  end

  def game_player
    $game_player
  end

  def setup(list, event_id = 0)
    clear
    @map_id = game_map.map_id
    @event_id = event_id
    @list = list
    create_fiber
  end

  def same_map?
    @map_id == game_map.map_id
  end

  def setup_reserved_common_event
    if game_temp.common_event_reserved?
      setup(game_temp.reserved_common_event.list)
      game_temp.clear_common_event
      true
    else
      false
    end
  end

  def iterate_actor_id(param)
    if param == 0
      game_party.members.each {|actor| yield actor }
    else
      actor = game_actors[param]
      yield actor if actor
    end
  end

  def iterate_actor_var(param1, param2)
    if param1 == 0
      iterate_actor_id(param2) {|actor| yield actor }
    else
      iterate_actor_id(game_variables[param2]) {|actor| yield actor }
    end
  end

  def iterate_actor_index(param)
    if param < 0
      game_party.members.each {|actor| yield actor }
    else
      actor = game_party.members[param]
      yield actor if actor
    end
  end

  def iterate_enemy_index(param)
    if param < 0
      game_troop.members.each {|enemy| yield enemy }
    else
      enemy = game_troop.members[param]
      yield enemy if enemy
    end
  end

  def iterate_battler(param1, param2)
    if game_party.in_battle
      if param1 == 0
        iterate_enemy_index(param2) {|enemy| yield enemy }
      else
        iterate_actor_id(param2) {|actor| yield actor }
      end
    end
  end

  def screen
    game_party.in_battle ? game_troop.screen : game_map.screen
  end

  def get_character(param)
    if game_party.in_battle
      nil
    elsif param < 0
      game_player
    else
      events = same_map? ? game_map.events : {}
      events[param > 0 ? param : @event_id]
    end
  end

  def operate_value(operation, operand_type, operand)
    value = operand_type == 0 ? operand : game_variables[operand]
    operation == 0 ? value : -value
  end

  def wait_for_message
    Fiber.yield while game_message.busy?
  end

  def command_101
    wait_for_message
    game_message.face_name = @params[0]
    game_message.face_index = @params[1]
    game_message.background = @params[2]
    game_message.position = @params[3]
    while next_event_code == 401
      @index += 1
      game_message.add(@list[@index].parameters[0])
    end
    case next_event_code
    when 10
      @index += 1
      setup_choices(@list[@index].parameters)
    when 10
      @index += 1
      setup_num_input(@list[@index].parameters)
    when 10
      @index += 1
      setup_item_choice(@list[@index].parameters)
    end
    wait_for_message
  end

  def command_102
    wait_for_message
    setup_choices(@params)
    Fiber.yield while game_message.choice?
  end

  def setup_choices(params)
    params[0].each {|s| game_message.choices.push(s) }
    game_message.choice_cancel_type = params[1]
    game_message.choice_proc = Proc.new {|n| @branch[@indent] = n }
  end

  def command_103
    wait_for_message
    setup_num_input(@params)
    Fiber.yield while game_message.num_input?
  end

  def setup_num_input(params)
    game_message.num_input_variable_id = params[0]
    game_message.num_input_digits_max = params[1]
  end

  def command_104
    wait_for_message
    setup_item_choice(@params)
    Fiber.yield while game_message.item_choice?
  end

  def setup_item_choice(params)
    game_message.item_choice_variable_id = params[0]
  end

  def command_105
    Fiber.yield while game_message.visible
    game_message.scroll_mode = true
    game_message.scroll_speed = @params[0]
    game_message.scroll_no_fast = @params[1]
    while next_event_code == 405
      @index += 1
      game_message.add(@list[@index].parameters[0])
    end
    wait_for_message
  end

  def command_111
    result = false
    case @params[0]
    when 0  # Switch
      result = (game_switches[@params[1]] == (@params[2] == 0))
    when 1  # Variable
      value1 = game_variables[@params[1]]
      if @params[2] == 0
        value2 = @params[3]
      else
        value2 = game_variables[@params[3]]
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
        result = (game_self_switches[key] == (@params[2] == 0))
      end
    when 3  # Timer
      if game_timer.working?
        if @params[2] == 0
          result = (game_timer.sec >= @params[1])
        else
          result = (game_timer.sec <= @params[1])
        end
      end
    when 4  # Actor
      actor = game_actors[@params[1]]
      if actor
        case @params[2]
        when 0  # in party
          result = (game_party.members.include?(actor))
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
      enemy = game_troop.members[@params[1]]
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
        result = (game_party.gold >= @params[1])
      when 1  # Less than or equal to
        result = (game_party.gold <= @params[1])
      when 2  # Less than
        result = (game_party.gold < @params[1])
      end
    when 8  # Item
      result = game_party.has_item?($data_items[@params[1]])
    when 9  # Weapon
      result = game_party.has_item?($data_weapons[@params[1]], @params[2])
    when 10  # Armor
      result = game_party.has_item?($data_armors[@params[1]], @params[2])
    when 11  # Button
      result = Input.press?(@params[1])
    when 12  # Script
      result = eval(@params[1])
    when 13  # Vehicle
      result = (game_player.vehicle == game_map.vehicles[@params[1]])
    end
    @branch[@indent] = result
    command_skip if !@branch[@indent]
  end

  def command_117
    common_event = $data_common_events[@params[0]]
    if common_event
      child = self.class.new(@depth + 1)
      child.setup(common_event.list, same_map? ? @event_id : 0)
      child.run
    end
  end

  def command_121
    (@params[0]..@params[1]).each do |i|
      game_switches[i] = (@params[2] == 0)
    end
  end

  def command_122
    value = 0
    case @params[3]  # Operand
    when 0  # Constant
      value = @params[4]
    when 1  # Variable
      value = game_variables[@params[4]]
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

  def game_data_operand(type, param1, param2)
    case type
    when 0  # Items
      return game_party.item_number($data_items[param1])
    when 1  # Weapons
      return game_party.item_number($data_weapons[param1])
    when 2  # Armor
      return game_party.item_number($data_armors[param1])
    when 3  # Actors
      actor = game_actors[param1]
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
      enemy = game_troop.members[param1]
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
      actor = game_party.members[param1]
      return actor ? actor.id : 0
    when 7  # Other
      case param1
      when 0  # map ID
        return game_map.map_id
      when 1  # number of party members
        return game_party.members.size
      when 2  # gold
        return game_party.gold
      when 3  # steps
        return game_party.steps
      when 4  # play time
        return Graphics.frame_count / Graphics.frame_rate
      when 5  # timer
        return game_timer.sec
      when 6  # save count
        return game_system.save_count
      when 7  # battle count
        return game_system.battle_count
      end
    end
    return 0
  end

  def operate_variable(variable_id, operation_type, value)
    begin
      case operation_type
      when 0  # Set
        game_variables[variable_id] = value
      when 1  # Add
        game_variables[variable_id] += value
      when 2  # Sub
        game_variables[variable_id] -= value
      when 3  # Mul
        game_variables[variable_id] *= value
      when 4  # Div
        game_variables[variable_id] /= value
      when 5  # Mod
        game_variables[variable_id] %= value
      end
    rescue
      game_variables[variable_id] = 0
    end
  end

  def command_123
    if @event_id > 0
      key = [@map_id, @event_id, @params[0]]
      game_self_switches[key] = (@params[1] == 0)
    end
  end

  def command_124
    if @params[0] == 0  # Start
      game_timer.start(@params[1] * Graphics.frame_rate)
    else                # Stop
      game_timer.stop
    end
  end

  def command_125
    value = operate_value(@params[0], @params[1], @params[2])
    game_party.gain_gold(value)
  end

  def command_126
    value = operate_value(@params[1], @params[2], @params[3])
    game_party.gain_item($data_items[@params[0]], value)
  end

  def command_127
    value = operate_value(@params[1], @params[2], @params[3])
    game_party.gain_item($data_weapons[@params[0]], value, @params[4])
  end

  def command_128
    value = operate_value(@params[1], @params[2], @params[3])
    game_party.gain_item($data_armors[@params[0]], value, @params[4])
  end

  def command_129
    actor = game_actors[@params[0]]
    if actor
      if @params[1] == 0    # Add
        if @params[2] == 1  # Initialize
          game_actors[@params[0]].setup(@params[0])
        end
        game_party.add_actor(@params[0])
      else                  # Remove
        game_party.remove_actor(@params[0])
      end
    end
  end

  def command_132
    game_system.battle_bgm = @params[0]
  end

  def command_133
    game_system.battle_end_me = @params[0]
  end

  def command_134
    game_system.save_disabled = (@params[0] == 0)
  end

  def command_135
    game_system.menu_disabled = (@params[0] == 0)
  end

  def command_136
    game_system.encounter_disabled = (@params[0] == 0)
    game_player.make_encounter_count
  end

  def command_137
    game_system.formation_disabled = (@params[0] == 0)
  end

  def command_138
    game_system.window_tone = @params[0]
  end

  def command_201
    return if game_party.in_battle
    Fiber.yield while game_player.transfer? || game_message.visible
    if @params[0] == 0                      # Direct designation
      map_id = @params[1]
      x = @params[2]
      y = @params[3]
    else                                    # Designation with variables
      map_id = game_variables[@params[1]]
      x = game_variables[@params[2]]
      y = game_variables[@params[3]]
    end
    game_player.reserve_transfer(map_id, x, y, @params[4])
    game_temp.fade_type = @params[5]
    Fiber.yield while game_player.transfer?
  end

  def command_202
    if @params[1] == 0                      # Direct designation
      map_id = @params[2]
      x = @params[3]
      y = @params[4]
    else                                    # Designation with variables
      map_id = game_variables[@params[2]]
      x = game_variables[@params[3]]
      y = game_variables[@params[4]]
    end
    vehicle = game_map.vehicles[@params[0]]
    vehicle.set_location(map_id, x, y) if vehicle
  end

  def command_203
    character = get_character(@params[0])
    if character
      if @params[1] == 0                      # Direct designation
        character.moveto(@params[2], @params[3])
      elsif @params[1] == 1                   # Designation with variables
        new_x = game_variables[@params[2]]
        new_y = game_variables[@params[3]]
        character.moveto(new_x, new_y)
      else                                    # Exchange with another event
        character2 = get_character(@params[2])
        character.swap(character2) if character2
      end
      character.set_direction(@params[4]) if @params[4] > 0
    end
  end

  def command_204
    return if game_party.in_battle
    Fiber.yield while game_map.scrolling?
    game_map.start_scroll(@params[0], @params[1], @params[2])
  end

  def command_205
    game_map.refresh if game_map.need_refresh
    character = get_character(@params[0])
    if character
      character.force_move_route(@params[1])
      Fiber.yield while character.move_route_forcing if @params[1].wait
    end
  end

  def command_206
    game_player.get_on_off_vehicle
  end

  def command_211
    game_player.transparent = (@params[0] == 0)
  end

  def command_214
    game_map.events[@event_id].erase if same_map? && @event_id > 0
  end

  def command_216
    game_player.followers.visible = (@params[0] == 0)
    game_player.refresh
  end

  def command_217
    return if game_party.in_battle
    game_player.followers.gather
    Fiber.yield until game_player.followers.gather?
  end

  def command_221
    Fiber.yield while game_message.visible
    screen.start_fadeout(30)
    wait(30)
  end

  def command_222
    Fiber.yield while game_message.visible
    screen.start_fadein(30)
    wait(30)
  end

  def command_231
    if @params[3] == 0    # Direct designation
      x = @params[4]
      y = @params[5]
    else                  # Designation with variables
      x = game_variables[@params[4]]
      y = game_variables[@params[5]]
    end
    screen.pictures[@params[0]].show(@params[1], @params[2],
      x, y, @params[6], @params[7], @params[8], @params[9])
  end

  def command_232
    if @params[3] == 0    # Direct designation
      x = @params[4]
      y = @params[5]
    else                  # Designation with variables
      x = game_variables[@params[4]]
      y = game_variables[@params[5]]
    end
    screen.pictures[@params[0]].move(@params[2], x, y, @params[6],
      @params[7], @params[8], @params[9], @params[10])
    wait(@params[10]) if @params[11]
  end

  def command_236
    return if game_party.in_battle
    screen.change_weather(@params[0], @params[1], @params[2])
    wait(@params[2]) if @params[3]
  end

  def command_243
    game_system.save_bgm
  end

  def command_244
    game_system.replay_bgm
  end

  def command_261
    Fiber.yield while game_message.visible
    Fiber.yield
    name = @params[0]
    Graphics.play_movie('Movies/' + name) unless name.empty?
  end

  def command_281
    game_map.name_display = (@params[0] == 0)
  end

  def command_282
    game_map.change_tileset(@params[0])
  end

  def command_283
    game_map.change_battleback(@params[0], @params[1])
  end

  def command_284
    game_map.change_parallax(@params[0], @params[1], @params[2],
                              @params[3], @params[4])
  end

  def command_285
    if @params[2] == 0      # Direct designation
      x = @params[3]
      y = @params[4]
    else                    # Designation with variables
      x = game_variables[@params[3]]
      y = game_variables[@params[4]]
    end
    case @params[1]
    when 0      # Terrain Tag
      value = game_map.terrain_tag(x, y)
    when 1      # Event ID
      value = game_map.event_id_xy(x, y)
    when 2..4   # Tile ID
      value = game_map.tile_id(x, y, @params[1] - 2)
    else        # Region ID
      value = game_map.region_id(x, y)
    end
    game_variables[@params[0]] = value
  end

  def command_301
    return if game_party.in_battle
    if @params[0] == 0                      # Direct designation
      troop_id = @params[1]
    elsif @params[0] == 1                   # Designation with variables
      troop_id = game_variables[@params[1]]
    else                                    # Map-designated troop
      troop_id = game_player.make_encounter_troop_id
    end
    if data_troops[troop_id]
      BattleManager.setup(troop_id, @params[2], @params[3])
      BattleManager.event_proc = Proc.new {|n| @branch[@indent] = n }
      game_player.make_encounter_count
      SceneManager.call(Scene_Battle)
    end
    Fiber.yield
  end

  def command_302
    return if game_party.in_battle
    goods = [@params]
    while next_event_code == 605
      @index += 1
      goods.push(@list[@index].parameters)
    end
    SceneManager.call(Scene_Shop)
    SceneManager.scene.prepare(goods, @params[4])
    Fiber.yield
  end

  def command_303
    return if game_party.in_battle
    if $data_actors[@params[0]]
      SceneManager.call(Scene_Name)
      SceneManager.scene.prepare(@params[0], @params[1])
      Fiber.yield
    end
  end

  def command_311
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      next if actor.dead?
      actor.change_hp(value, @params[5])
      actor.perform_collapse_effect if actor.dead?
    end
    SceneManager.goto(Scene_Gameover) if game_party.all_dead?
  end

  def command_312
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.mp += value
    end
  end

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
    game_party.clear_results
  end

  def command_319
    actor = game_actors[@params[0]]
    actor.change_equip_by_id(@params[1], @params[2]) if actor
  end

  def command_320
    actor = game_actors[@params[0]]
    actor.name = @params[1] if actor
  end

  def command_321
    actor = game_actors[@params[0]]
    actor.change_class(@params[1]) if actor && $data_classes[@params[1]]
  end

  def command_322
    actor = game_actors[@params[0]]
    if actor
      actor.set_graphic(@params[1], @params[2], @params[3], @params[4])
    end
    game_player.refresh
  end

  def command_323
    vehicle = game_map.vehicles[@params[0]]
    vehicle.set_graphic(@params[1], @params[2]) if vehicle
  end

  def command_324
    actor = game_actors[@params[0]]
    actor.nickname = @params[1] if actor
  end

  def command_335
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.appear
      game_troop.make_unique_names
    end
  end

  def command_336
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.transform(@params[1])
      game_troop.make_unique_names
    end
  end

  def command_351
    return if game_party.in_battle
    SceneManager.call(Scene_Menu)
    Window_MenuCommand::init_command_position
    Fiber.yield
  end

  def command_352
    return if game_party.in_battle
    SceneManager.call(Scene_Save)
    Fiber.yield
  end

  def command_355
    script = @list[@index].parameters[0] + "\n"
    while next_event_code == 655
      @index += 1
      script += @list[@index].parameters[0] + "\n"
    end
    name = 'script'
    name = "map/#{@map_id}/event/#{@event_id}/page/script" if @event_id != 0
    eval(script, self.send(:binding), name, @index)
  end
end
