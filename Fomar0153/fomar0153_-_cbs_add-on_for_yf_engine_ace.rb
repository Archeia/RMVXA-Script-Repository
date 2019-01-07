=begin
YanFly Compatible Customisable ATB/Stamina Based Battle System Script
by Fomar0153
Version 1.1
----------------------
Notes
----------------------
Requires Yanfly Engine Ace - Ace Battle Engine
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
1.0 -> 1.1 Added CTB related options
           Added the ability to pass a turn 
           Added options for turn functionality to be based on time
           or number of actions
           Added the ability to change the bar colours based on states
----------------------
Known bugs
----------------------
None
=end

$imported = {} if $imported.nil?
$imported["Fomar0153-CBS"] = true

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

  # If TURN_LENGTH is set to 0 then a turn length will be 
  # decided on number of actions
  # TURN_LENGTH is number of seconds per turn
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
  alias yf_fomar_cbs_initialize initialize
  def initialize
    yf_fomar_cbs_initialize
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
  # ● Rewrote Method update_info_viewport
  #--------------------------------------------------------------------------
  def update_info_viewport
    move_info_viewport(0)   if @party_command_window.active
    move_info_viewport(128) if @actor_command_window.active
    move_info_viewport(64)  if BattleManager.in_turn? and !inputting?
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
    @status_window.refresh_stamina
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
          @status_window.index = @subject.index
          BattleManager.set_actor(battler)
        end
        return
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● Rewrote start_party_command_selection Yanfly version
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
  # ● Rewrote prior_command Yanfly version
  #--------------------------------------------------------------------------
  def prior_command
    redraw_current_status
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
    #BattleManager.turn_end
    #process_event
    #start_party_command_selection
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
    @status_window.show
    @actor_command_window.show
    @status_aid_window.hide
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
  # ● Rewrote turn_start Yanfly version
  #--------------------------------------------------------------------------
  def self.turn_start
    @phase = :turn
    clear_actor
    $game_troop.increase_turn if $game_troop.turn_count == 0
    @performed_battlers = []
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

class Window_BattleStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # Aliases method: draw_item yanfly version
  #--------------------------------------------------------------------------
  alias prefomar_draw_item draw_item
  def draw_item(index)
    unless CBS::ATB
      prefomar_draw_item(index)
      return
    end
    return if index.nil?
    clear_item(index)
    actor = battle_members[index]
    rect = item_rect(index)
    return if actor.nil?
    draw_actor_face(actor, rect.x+2, rect.y+2, actor.alive?)
    draw_actor_name(actor, rect.x, rect.y, rect.width-8)
    draw_actor_action(actor, rect.x, rect.y)
    draw_actor_icons(actor, rect.x, line_height*1, rect.width)
    gx = YEA::BATTLE::BATTLESTATUS_HPGAUGE_Y_PLUS
    contents.font.size = YEA::BATTLE::BATTLESTATUS_TEXT_FONT_SIZE
    draw_actor_hp(actor, rect.x+2, line_height*2, rect.width-4)
    if draw_tp?(actor) && draw_mp?(actor)
      dw = rect.width/2-2
      dw += 1 if $imported["YEA-CoreEngine"] && YEA::CORE::GAUGE_OUTLINE
      draw_actor_tp(actor, rect.x+2, line_height*2+gx, dw)
      dw = rect.width - rect.width/2 - 2
      draw_actor_mp(actor, rect.x+rect.width/2, line_height*2+gx, dw)
    elsif draw_tp?(actor) && !draw_mp?(actor)
      draw_actor_tp(actor, rect.x+2, line_height*2+gx, rect.width-4)
    else
      draw_actor_mp(actor, rect.x+2, line_height*2+gx, rect.width-4)
    end
    draw_actor_stamina(actor, rect.x+2, line_height*3, rect.width-4)
  end
  #--------------------------------------------------------------------------
  # overwrite method: draw_item yanfly version
  #--------------------------------------------------------------------------
  def draw_item_stamina(index)
    return if index.nil?
    actor = battle_members[index]
    rect = item_rect(index)
    return if actor.nil?
    gx = YEA::BATTLE::BATTLESTATUS_HPGAUGE_Y_PLUS
    contents.font.size = YEA::BATTLE::BATTLESTATUS_TEXT_FONT_SIZE
    draw_actor_stamina(actor, rect.x+2, line_height*3, rect.width-4)
  end
  #--------------------------------------------------------------------------
  # new method: refresh_stamina
  #--------------------------------------------------------------------------
  def refresh_stamina
    return unless CBS::ATB
    item_max.times {|i| draw_item_stamina(i) }
  end
  #--------------------------------------------------------------------------
  # new method: draw_actor_stamina
  #--------------------------------------------------------------------------
  def draw_actor_stamina(actor, dx, dy, width = 124)
    draw_gauge(dx, dy, width, actor.stamina_rate, text_color(CBS.stamina_colors(actor)[2]),text_color(CBS.stamina_colors(actor)[1]))
    change_color(system_color)
    cy = (Font.default_size - contents.font.size) / 2 + 1
    draw_text(dx+2, dy+cy, 30, line_height, CBS::SAMINA_GAUGE_NAME)
  end
end