=begin
Customisable ATB/Stamina Based Battle System Script
by Fomar0153
Version 1.2
----------------------
Notes
----------------------
No requirements
Customises the battle system to be similar to
ATB or Stamina based battle systems.
----------------------
Instructions
----------------------
Edit variables in CBS to suit your needs.
The guard status should be set to 2~2 turns.
----------------------
Change Log
----------------------
1.0 -> 1.1 Restored turn functionality and a glitch
           related to message windows
1.1 -> 1.2 Added CTB related options
           Added the ability to pass a turn 
           Fixed a bug which caused an error on maps
           with no random battles 
           Added options for turn functionality to be based on time
           or number of actions
           Added the ability to change the bar colours based on states
----------------------
Known bugs
----------------------
None
=end
module CBS

  MAX_STAMINA = 1000
  RESET_STAMINA = true
  
  # If ATB is set to false then the bars won't appear and
  # the pauses where the bars would be filling up are removed
  # effectively turning this into a CTB system
  ATB = true
  SAMINA_GAUGE_NAME = "ATB"
  ENABLE_PASSING = true
  PASSING_COST = 200
  
  # If seconds per turn is set to 0 then a turn length will be 
  # decided on number of actions
  TURN_LENGTH = 4
  
  ESCAPE_COST = 500
  # If reset stamina is set to true then all characters
  # will start with a random amount of stamina capped at
  # the percentage you set.
  # If reset stamina is set to false then this just
  # affects enemies.
  STAMINA_START_PERCENT = 20

  # Default skill cost
  # If you want to customise skill costs do it like this
  # SKILL_COST[skill_id] = cost
  SKILL_COST = []
  SKILL_COST[0] = 1000
  # Attack
  SKILL_COST[1] = 1000
  # Guard
  SKILL_COST[2] = 500
  ITEM_COST = 1000

  # If you prefer to have states handle agility buffs then set STATES_HANDLE_AGI to true
  STATES_HANDLE_AGI = false
  # In the following section mult means the amount you multiply stamina gains by
  # if STATES_HANDLE_AGI is set to true then it is only used to determine bar color
  # with debuffs taking precedence over buffs
  STAMINA_STATES = []
  # Default colour 
  STAMINA_STATES[0] = [1,31,32]
  # in the form
  # STAMINA_STATES[STATE_ID] = [MULT,FILL_COLOUR,EMPTY_COLOR]
  # e.g. Haste
  STAMINA_STATES[10] = [2,4,32]
  # e.g. Stop  
  STAMINA_STATES[11] = [0,8,32]
  # e.g. Slow  
  STAMINA_STATES[12] = [0.5,8,32]

  #--------------------------------------------------------------------------
  # ● New Method stamina_gain
  #--------------------------------------------------------------------------
  def self.stamina_gain(battler)
    return ((2 + [0, battler.agi / 10].max) * self.stamina_mult(battler)).to_i
  end
  #--------------------------------------------------------------------------
  # ● New Method stamina_gain
  #--------------------------------------------------------------------------
  def self.stamina_mult(battler)
    return 1 if STATES_HANDLE_AGI
    mult = STAMINA_STATES[0][0]
    for state in battler.states
      unless STAMINA_STATES[state.id].nil?
        mult *= STAMINA_STATES[state.id][0]
      end
    end
    return mult
  end
  #--------------------------------------------------------------------------
  # ● New Method stamina_gain
  #--------------------------------------------------------------------------
  def self.stamina_colors(battler)
    colors = STAMINA_STATES[0]
    for state in battler.states
      unless STAMINA_STATES[state.id].nil?
        if STAMINA_STATES[state.id][0] < colors[0] or colors[0] == 1
          colors = STAMINA_STATES[state.id]
        end
      end
    end
    return colors
  end
  #--------------------------------------------------------------------------
  # ● New Method stamina_start
  #--------------------------------------------------------------------------
  def self.stamina_start(battler)
    battler.stamina = rand(MAX_STAMINA * STAMINA_START_PERCENT / 100)
  end
end

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● New attr_accessor
  #--------------------------------------------------------------------------
  attr_accessor :stamina
  #--------------------------------------------------------------------------
  # ● Aliases initialize
  #--------------------------------------------------------------------------
  alias cbs_initialize initialize
  def initialize
    cbs_initialize
    @stamina = 0
  end
  #--------------------------------------------------------------------------
  # ● New Method stamina_rate
  #--------------------------------------------------------------------------
  def stamina_rate
    @stamina.to_f / CBS::MAX_STAMINA
  end
  #--------------------------------------------------------------------------
  # ● New Method stamina_rate
  #--------------------------------------------------------------------------
  def stamina_gain
    return if not movable?
    @stamina = [CBS::MAX_STAMINA, @stamina + CBS.stamina_gain(self)].min
  end
  #--------------------------------------------------------------------------
  # ● New Method stamina_color
  #--------------------------------------------------------------------------
  def stamina_color
    for state in @states
      unless CBS::STAMINA_STATES[state].nil?
        return STAMINA_STATES[state]
      end
    end
    return STAMINA_STATES[0]
  end
end

#--------------------------------------------------------------------------
# ● New Class Window_PartyHorzCommand
#--------------------------------------------------------------------------
class Window_PartyHorzCommand < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ● New Method initialize
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0)
    self.openness = 0
    deactivate
  end
  #--------------------------------------------------------------------------
  # ● New Method window_width
  #--------------------------------------------------------------------------
  def window_width
    return Graphics.width
  end
  #--------------------------------------------------------------------------
  # ● New Method visible_line_number
  #--------------------------------------------------------------------------
  def visible_line_number
    return 1
  end
  #--------------------------------------------------------------------------
  # ● New Method make_command_list
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::fight,  :fight)
    add_command(Vocab::escape, :escape, BattleManager.can_escape?)
  end
  #--------------------------------------------------------------------------
  # ● New Method setup
  #--------------------------------------------------------------------------
  def setup
    clear_command_list
    make_command_list
    refresh
    select(0)
    activate
    open
  end
end

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● Rewrote update
  #--------------------------------------------------------------------------
  def update
    super
    if (CBS::ENABLE_PASSING and @actor_command_window.active) and Input.press?(:A)
      command_pass
    end
    if BattleManager.in_turn? and !inputting?
      while @subject.nil? and !CBS::ATB
        process_stamina
      end
      if CBS::ATB
        process_stamina
      end
      process_event
      process_action
    end
    BattleManager.judge_win_loss
  end
  #--------------------------------------------------------------------------
  # ● New Method inputting?
  #--------------------------------------------------------------------------
  def inputting?
    return @actor_command_window.active || @skill_window.active ||
      @item_window.active || @actor_window.active || @enemy_window.active
  end
  #--------------------------------------------------------------------------
  # ● New Method process_stamina
  #--------------------------------------------------------------------------
  def process_stamina
    @actor_command_window.close
    return if @subject
    BattleManager.advance_turn
    all_battle_members.each do |battler|
      battler.stamina_gain
    end
    @status_window.refresh
    if @status_window.close?
      @status_window.open
    end
    if BattleManager.escaping?
      $game_party.battle_members.each do |battler|
        if battler.stamina < CBS::MAX_STAMINA
          $game_troop.members.each do |enemy|
            if enemy.stamina == CBS::MAX_STAMINA
              enemy.make_actions
              @subject = enemy
            end
          end
          return
        end
      end
      unless BattleManager.process_escape
        $game_party.battle_members.each do |actor|
          actor.stamina -= CBS::ESCAPE_COST
        end
      end
    end
    all_battle_members.each do |battler|
      if battler.stamina == CBS::MAX_STAMINA
        battler.make_actions
        @subject = battler
        if @subject.inputable? and battler.is_a?(Game_Actor)
          @actor_command_window.setup(@subject)
          BattleManager.set_actor(battler)
        end
        return
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● Rewrote create_info_viewport
  #--------------------------------------------------------------------------
  def create_info_viewport
    @info_viewport = Viewport.new
    @info_viewport.rect.y = Graphics.height - @status_window.height - 48
    @info_viewport.rect.height = @status_window.height + 48
    @info_viewport.z = 100
    @info_viewport.ox = 0
    @status_window.viewport = @info_viewport
  end
  #--------------------------------------------------------------------------
  # ● Rewrote create_party_command_window
  #--------------------------------------------------------------------------
  def create_party_command_window
    @party_command_window = Window_PartyHorzCommand.new
    @party_command_window.viewport = @info_viewport
    @party_command_window.set_handler(:fight,  method(:command_fight))
    @party_command_window.set_handler(:escape, method(:command_escape))
    @party_command_window.unselect
  end
  #--------------------------------------------------------------------------
  # ● Rewrote create_status_window
  #--------------------------------------------------------------------------
  def create_status_window
    @status_window = Window_BattleStatus.new
  end
  #--------------------------------------------------------------------------
  # ● Rewrote create_actor_command_window
  #--------------------------------------------------------------------------
  def create_actor_command_window
    @actor_command_window = Window_ActorCommand.new
    @actor_command_window.viewport = @info_viewport
    @actor_command_window.set_handler(:attack, method(:command_attack))
    @actor_command_window.set_handler(:skill,  method(:command_skill))
    @actor_command_window.set_handler(:guard,  method(:command_guard))
    @actor_command_window.set_handler(:item,   method(:command_item))
    @actor_command_window.set_handler(:cancel, method(:prior_command))
    @actor_command_window.x = Graphics.width - 128
    @actor_command_window.y = 48
  end
  #--------------------------------------------------------------------------
  # ● Destroyed update_info_viewport
  #--------------------------------------------------------------------------
  def update_info_viewport
    # no thank you
  end
#--------------------------------------------------------------------------
  # ● Rewrote start_party_command_selection
  #--------------------------------------------------------------------------
  def start_party_command_selection
    unless scene_changing?
      refresh_status
      @status_window.unselect
      @status_window.open
      if BattleManager.input_start
        @actor_command_window.close
        @party_command_window.setup
      else
        @party_command_window.deactivate
        turn_start
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● Rewrote start_actor_command_selection
  #--------------------------------------------------------------------------
  def start_actor_command_selection
    @party_command_window.close
    BattleManager.set_escaping(false)
    turn_start
  end
  #--------------------------------------------------------------------------
  # ● Rewrote prior_command
  #--------------------------------------------------------------------------
  def prior_command
    start_party_command_selection
  end
  #--------------------------------------------------------------------------
  # ● Rewrote process_action
  #--------------------------------------------------------------------------
  def process_action
    return if scene_changing?
    if !@subject || !@subject.current_action
      @subject = BattleManager.next_subject
    end
    if Input.trigger?(:B) and (@subject == nil)
      start_party_command_selection
    end
    return unless @subject
    if @subject.current_action
      @subject.current_action.prepare
      if @subject.current_action.valid?
        @status_window.open
        execute_action
      end
      @subject.remove_current_action
      refresh_status
      @log_window.display_auto_affected_status(@subject)
      @log_window.wait_and_clear
    end
    process_action_end unless @subject.current_action
  end
  #--------------------------------------------------------------------------
  # ● Aliases use_item
  #--------------------------------------------------------------------------
  alias cbs_use_item use_item
  def use_item
    cbs_use_item
    @subject.stamina_loss
  end
  #--------------------------------------------------------------------------
  # ● Rewrote turn_end
  #--------------------------------------------------------------------------
  def turn_end
    all_battle_members.each do |battler|
      battler.on_turn_end
      refresh_status
      @log_window.display_auto_affected_status(battler)
      @log_window.wait_and_clear
    end
  end
  #--------------------------------------------------------------------------
  # ● Rewrote command_fight
  #--------------------------------------------------------------------------
  def command_fight
    BattleManager.next_command
    start_actor_command_selection
  end
  #--------------------------------------------------------------------------
  # ● Rewrote command_escape
  #--------------------------------------------------------------------------
  def command_escape
    @party_command_window.close
    BattleManager.set_escaping(true)
    turn_start
  end
  #--------------------------------------------------------------------------
  # ● New method command_pass
  #--------------------------------------------------------------------------
  def command_pass
    BattleManager.actor.stamina -= CBS::PASSING_COST
    BattleManager.clear_actor
    @subject = nil
    turn_start
    @actor_command_window.active = false
    @actor_command_window.close
  end
  #--------------------------------------------------------------------------
  # ● Destroyed next_command
  #--------------------------------------------------------------------------
  def next_command
    # no thank you
  end
end

class Window_BattleStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # ● Rewrote initialize
  #--------------------------------------------------------------------------
  def initialize
    super(0, 48, Graphics.width, window_height) if CBS::ATB
    super(0, 48, Graphics.width - 128, window_height) unless CBS::ATB
    refresh
    self.openness = 0
  end
  #--------------------------------------------------------------------------
  # ● Rewrote window_width
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width - 128
  end
  #--------------------------------------------------------------------------
  # ● Rewrote refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_all_items
  end
  #--------------------------------------------------------------------------
  # ● Rewrote draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    actor = $game_party.battle_members[index]
    draw_basic_area(basic_area_rect(index), actor)
    draw_gauge_area(gauge_area_rect(index), actor)
  end
  #--------------------------------------------------------------------------
  # ● Rewrote basic_area_rect
  #--------------------------------------------------------------------------
  def basic_area_rect(index)
    rect = item_rect_for_text(index)
    rect.width -= gauge_area_width + 10
    rect
  end
  #--------------------------------------------------------------------------
  # ● Rewrote gauge_area_rect
  #--------------------------------------------------------------------------
  def gauge_area_rect(index)
    rect = item_rect_for_text(index)
    rect.x += rect.width - gauge_area_width #- 128 ####
    rect.width = gauge_area_width
    rect
  end
  #--------------------------------------------------------------------------
  # ● Rewrote gauge_area_width
  #--------------------------------------------------------------------------
  def gauge_area_width
    return 220 + 128 if CBS::ATB
    return 220
  end
  #--------------------------------------------------------------------------
  # ● Rewrote draw_gauge_area_with_tp
  #--------------------------------------------------------------------------
  def draw_gauge_area_with_tp(rect, actor)
    draw_actor_hp(actor, rect.x + 0, rect.y, 72)
    draw_actor_mp(actor, rect.x + 82, rect.y, 64)
    draw_actor_tp(actor, rect.x + 156, rect.y, 64)
    draw_actor_stamina(actor, rect.x + 240, rect.y, 108) if CBS::ATB
  end
  #--------------------------------------------------------------------------
  # ● Rewrote draw_gauge_area_without_tp
  #--------------------------------------------------------------------------
  def draw_gauge_area_without_tp(rect, actor)
    draw_actor_hp(actor, rect.x + 0, rect.y, 134)
    draw_actor_mp(actor, rect.x + 144,  rect.y, 76)
    draw_actor_stamina(actor, rect.x + 240, rect.y, 108) if CBS::ATB
  end
  #--------------------------------------------------------------------------
  # ● New Method draw_actor_stamina
  #--------------------------------------------------------------------------
  def draw_actor_stamina(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.stamina_rate, text_color(CBS.stamina_colors(actor)[2]),text_color(CBS.stamina_colors(actor)[1]))
    change_color(system_color)
    draw_text(x, y, 30, line_height, CBS::SAMINA_GAUGE_NAME)
  end
end

class Window_BattleSkill < Window_SkillList
  #--------------------------------------------------------------------------
  # ● Rewrote initialize
  #--------------------------------------------------------------------------
  def initialize(help_window, info_viewport)
    y = help_window.height
    super(0, y, Graphics.width, info_viewport.rect.y - y + 48)
    self.visible = false
    @help_window = help_window
    @info_viewport = info_viewport
  end
end

class Window_BattleActor < Window_BattleStatus
  #--------------------------------------------------------------------------
  # ● Rewrote initialize
  #--------------------------------------------------------------------------
  def initialize(info_viewport)
    super()
    self.y = info_viewport.rect.y + 48
    self.visible = false
    self.openness = 255
    @info_viewport = info_viewport
  end
end

class Window_BattleEnemy < Window_Selectable
  # ● Rewrote initialize
  #--------------------------------------------------------------------------
  def initialize(info_viewport)
    super(0, info_viewport.rect.y + 48, window_width, fitting_height(4))
    refresh
    self.visible = false
    @info_viewport = info_viewport
  end
end

class Window_BattleItem < Window_ItemList
  #--------------------------------------------------------------------------
  # ● Rewrote initialize
  #--------------------------------------------------------------------------
  def initialize(help_window, info_viewport)
    y = help_window.height
    super(0, y, Graphics.width, info_viewport.rect.y - y + 48)
    self.visible = false
    @help_window = help_window
    @info_viewport = info_viewport
  end
end

module BattleManager
  #--------------------------------------------------------------------------
  # ● Rewrote setup
  #--------------------------------------------------------------------------
  def self.setup(troop_id, can_escape = true, can_lose = false)
    init_members
    $game_troop.setup(troop_id)
    @can_escape = can_escape
    @can_lose = can_lose
    make_escape_ratio
    @escaping = false
    @turn_counter = 0
    @actions_per_turn = $game_party.members.size + $game_troop.members.size
    ($game_party.members + $game_troop.members).each do |battler|
      if battler.is_a?(Game_Enemy) or CBS::RESET_STAMINA
        CBS.stamina_start(battler)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● New Method set_escaping
  #--------------------------------------------------------------------------
  def self.set_escaping(escaping)
    @escaping = escaping
  end
  #--------------------------------------------------------------------------
  # ● New Method escaping?
  #--------------------------------------------------------------------------
  def self.escaping?
    return @escaping
  end
  #--------------------------------------------------------------------------
  # ● Rewrote turn_start
  #--------------------------------------------------------------------------
  def self.turn_start
    @phase = :turn
    clear_actor
    $game_troop.increase_turn if $game_troop.turn_count == 0
  end
  #--------------------------------------------------------------------------
  # ● New Method set_actor
  #--------------------------------------------------------------------------
  def self.set_actor(actor)
    @actor_index = actor.index
  end
  #--------------------------------------------------------------------------
  # ● New Increase action counter
  #--------------------------------------------------------------------------
  def self.add_action
    return if @actions_per_turn.nil?
    @turn_counter += 1
    if @turn_counter == @actions_per_turn and CBS::TURN_LENGTH == 0
      $game_troop.increase_turn
      SceneManager.scene.turn_end
      @turn_counter = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● New Method advance_turn
  #--------------------------------------------------------------------------
  def self.advance_turn
    return if CBS::TURN_LENGTH == 0
    @turn_counter += 1
    if @turn_counter == 60 * CBS::TURN_LENGTH
      $game_troop.increase_turn
      SceneManager.scene.turn_end
      @turn_counter = 0
    end
  end
end

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● Rewrote on_turn_end
  #--------------------------------------------------------------------------
  def on_turn_end
    @result.clear
    regenerate_all
    update_state_turns
    update_buff_turns
    remove_states_auto(2)
  end
  #--------------------------------------------------------------------------
  # ● New Method on_turn_end
  #--------------------------------------------------------------------------
  def stamina_loss
    if self.actor?
      @stamina -= input.stamina_cost
    else
      @stamina -= @actions[0].stamina_cost
    end
    BattleManager.add_action
  end
end

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● Rewrote input
  #--------------------------------------------------------------------------
  def input
    if @actions[@action_input_index] == nil
      @actions[@action_input_index] = Game_Action.new(self)
    end
    return @actions[@action_input_index]
  end
end

class Game_Action
  #--------------------------------------------------------------------------
  # ● New Method stamina_cost
  #--------------------------------------------------------------------------
  def stamina_cost
    if @item.is_skill?
      return CBS::SKILL_COST[item.id] if CBS::SKILL_COST[item.id]
      return CBS::SKILL_COST[0]
    end
    return CBS::ITEM_COST if @item.is_item?
    return CBS::MAX_STAMINA
  end
end