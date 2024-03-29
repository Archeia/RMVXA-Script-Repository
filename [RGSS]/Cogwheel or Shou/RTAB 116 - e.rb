# Real time active battle (RTAB)  Ver 1.16
# Distribution original support URL
# http://members.jcom.home.ne.jp/cogwheel/

class Scene_Battle
  #--------------------------------------------------------------------------
  # * Open instance variable
  #--------------------------------------------------------------------------
  attr_reader   :status_window            # Status Window
  attr_reader   :spriteset                # Battle sprite
  attr_reader   :scroll_time              # Screen portable basic time
  attr_reader   :zoom_rate                # Enemy battler basic position
  attr_reader   :drive                    # Camera drive
  attr_accessor :force                    # Degree of action forcing
  attr_accessor :camera                   # Present camera possession person
  #--------------------------------------------------------------------------
  # * ATB fundamental setup
  #--------------------------------------------------------------------------
  def atb_setup
    # ATB initialization
    #
    # speed         : Battle system speed. Lower values speeds up the system.
    #
    # @active       : Degree of active setting (Command Window control)
    #                 3 : Always active state
    #                 2 : System pauses when selecting skill/item
    #                 1 : Same as 2, but pauses during target selection
    #                 0 : Same as 1, but pauses during command window selection
    #
    # @action       : Degree of action setting (Battler Action control)
    #                 3 : Actions are performed unless incapacitated/dead
    #                 2 : Actions are delayed when taking damage
    #                 1 : Actions are delayed during the opponent/target's turn
    #                 0 : Actions are delayed until his/her turn
    #
    # @anime_wait   : If true, the system pauses until Battle Animation is done.
    #
    # @damage_wait  : Sets how long (in frames) a delay will last after the
    #                 damage pop shows.
    #
    # @after_wait   : The delay (in frames) after the battle is finished before
    #                 moving to the 'game over' screen or showing the 'battle
    #                 result' window.
    #                 [a, b]  a) delay for party loss,  b) delay for enemy loss.
    #
    # @enemy_speed  : Reaction delay speed of enemy (in frames).  The Enemy
    #                 reacts immediately if this is set to 1 (do not use '0').
    #                 Action is caused with the chance of 1 / @enemy_speed
    #
    # @force        : With forced action forced condition at time of skill use
    #                 2 : As for skill everything not to reside permanently, by all means immediately execution
    #                 1 : As for independent skill to reside permanently, only cooperation skill immediately execution
    #                 0 : All the skill permanent residence just are done
    #
    # ($scene.force = Usually by making x, from the script of the event modification possibility)
    #
    # CAMERA SYSTEM : This system moves the Camera POV to the current battler.
    # @drive        : Camera drive system ON/OFF.  If true, the system is ON.
    # @scroll_time  : Time it takes to scroll/move the camera POV during battle.
    # @zoom_rate    : This controls the size/depth of the enemy battlers in the
    #                 window.  If both set to 1.0, no scaling performed.
    #                 [i, j]  i) Highest/furthest enemy, j) Lowest/closest enemy
    #                 -Decimal values are permitted.-
    #                 -System zooms in/out to target (scaled to 1) on decisions.
    
    #--Configurables--#
    speed         = 150     # IN FRAMES / FOR ATB SYSTEM  
    @active       = 3       # Active Setting (Range of 0 - 3) -Command Window-
    @action       = 0       # Action Setting (Range of 0 - 3) -Battler Action-
    @anime_wait   = false   # Pause system for battle animation
    @damage_wait  = 10      # Delay after damage pop appears, in frames
    @after_wait   = [80, 0] # Delay for party/troop after battle loss
    @enemy_speed  = 140     # Speed delay setting for enemy action
    @force        = 2       # 
    @drive        = true    # Turns camera system on/off
    @scroll_time  = 15      # Speed of camera system
    @zoom_rate = [0.2, 1.0] # Controls perspective of battlers on screen
    
    #--Reserved for the system, do not touch--#
    @help_time = 40         # Reserved:  Length of window delay, in frames
    @escape == false        # Reserved:  Determines if escape is possible
    @camera = nil           # Reserved:  Determines camera
    @max = 0                # Reserved:  To calculate max game speed 
    @turn_cnt = 0           # Reserved:  Counts turns
    @help_wait = 0          # Reserved:  Help window delay
    @action_battlers = []   # Reserved:  Holds battlers
    @synthe = []            # Reserved:  For Cooperative Skills & such
    @spell_p = {}           # Reserved:  Spell caster/battler array
    @spell_e = {}           # Reserved:  Spell caster/battler array
    @command_a  = false     # Reserved:  Determine if actor battler in use
    @command = []           # Reserved:  Available commands
    @party = false          # Reserved:  Party Command Window flag
    
    for battler in $game_party.actors + $game_troop.enemies
      spell_reset(battler)
      battler.at = battler.agi * rand(speed / 2)
      battler.damage_pop = {}
      battler.damage = {}
      battler.damage_sp = {}
      battler.critical = {}
      battler.recover_hp = {}
      battler.recover_sp = {}
      battler.state_p = {}
      battler.state_m = {}
      battler.animation = []
      if battler.is_a?(Game_Actor)
        @max += battler.agi
      end
    end 
    @max *= speed
    @max /= $game_party.actors.size

    for battler in $game_party.actors + $game_troop.enemies
      battler.atp = 100 * battler.at / @max
    end
  end

  #--------------------------------------------------------------------------
  # * Full AT Gauge SE
  #--------------------------------------------------------------------------
  def fullat_se
    Audio.se_play("Audio/SE/033-switch02", 80, 100)
  end

  #--------------------------------------------------------------------------
  # * Leveling Up SE
  #--------------------------------------------------------------------------
  def levelup_se
    Audio.se_play("Audio/SE/056-Right02", 80, 100)
  end

  #--------------------------------------------------------------------------
  # * Skill Acquisition SE
  #--------------------------------------------------------------------------
  def skill_se
    Audio.se_play("Audio/SE/056-Right02", 80, 150)
  end
end

class Window_Base < Window
  #-------------------------------------------------------------------------- 
  # * Draw Actor ATG
  #     actor : Actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : draw spot width
  #--------------------------------------------------------------------------
  def draw_actor_atg(actor, x, y, width = 144)
    if @at_gauge == nil
      # plus_x:     revised x-coordinate
      # rate_x:     revised X-coordinate as (%)
      # plus_y:     revised y-coordinate
      # plus_width: revised width
      # rate_width: revised width as (%)
      # height:     Vertical width
      # align1: Type 1 ( 0: left justify  1: center justify 2: right justify )
      # align2: Type 2 ( 0: Upper stuffing 1: Central arranging  2:Lower stuffing )
      # align3: Gauge type 0:Left justify 1: Right justify
      @plus_x = 0
      @rate_x = 0
      @plus_y = 16
      @plus_width = 0
      @rate_width = 100
      @width = @plus_width + width * @rate_width / 100
      @height = 16
      @align1 = 0
      @align2 = 1
      @align3 = 0
      # Gradation settings:  grade1: Empty gauge   grade2:Actual gauge
      # (0:On side gradation   1:Vertically gradation    2: Slantedly gradation）
      grade1 = 1
      grade2 = 0
      # Color setting. color1: Outermost framework, color2: Medium framework
      # color3: Empty framework dark color, color4: Empty framework light/write color
      color1 = Color.new(0, 0, 0)
      color2 = Color.new(255, 255, 192)
      color3 = Color.new(0, 0, 0, 192)
      color4 = Color.new(0, 0, 64, 192)
      # Color setting of gauge
      # Usually color setting of the time
      color5 = Color.new(0, 64, 80)
      color6 = Color.new(0, 128, 160)
      # When gauge is MAX, color setting
      color7 = Color.new(80, 0, 0)
      color8 = Color.new(240, 0, 0)
      # Color setting at time of cooperation skill use
      color9 = Color.new(80, 64, 32)
      color10 = Color.new(240, 192, 96)
      # Color setting at time of skill permanent residence
      color11 = Color.new(80, 0, 64)
      color12 = Color.new(240, 0, 192)
      # Drawing of gauge
      gauge_rect_at(@width, @height, @align3, color1, color2,
                  color3, color4, color5, color6, color7, color8,
                  color9, color10, color11, color12, grade1, grade2)
    end
    # Variable at substituting the width of the gauge which is drawn
    if actor.rtp == 0
      at = (width + @plus_width) * actor.atp * @rate_width / 10000
    else
      at = (width + @plus_width) * actor.rt * @rate_width / actor.rtp / 100
    end
    if at > width
      at = width
    end
    # Revision such as the left stuffing central posture of gauge
    case @align1
    when 1
      x += (@rect_width - width) / 2
    when 2
      x += @rect_width - width
    end
    case @align2
    when 1
      y -= @height / 2
    when 2
      y -= @height
    end
    self.contents.blt(x + @plus_x + width * @rate_x / 100, y + @plus_y,
                      @at_gauge, Rect.new(0, 0, @width, @height))
    if @align3 == 0
      rect_x = 0
    else
      x += @width - at - 1
      rect_x = @width - at - 1
    end
    # Color setting of gauge
    if at == width
        # Gauge drawing at the time of MAX
      self.contents.blt(x + @plus_x + @width * @rate_x / 100, y + @plus_y,
                        @at_gauge, Rect.new(rect_x, @height * 2, at, @height))
    else
      if actor.rtp == 0
        # Usually gauge drawing of the time
        self.contents.blt(x + @plus_x + @width * @rate_x / 100, y + @plus_y,
                          @at_gauge, Rect.new(rect_x, @height, at, @height))
      else
        if actor.spell == true
          #Gauge drawing at time of cooperation skill use
          self.contents.blt(x + @plus_x + @width * @rate_x / 100, y + @plus_y,
                        @at_gauge, Rect.new(rect_x, @height * 3, at, @height))
        else
          # Gauge drawing at time of skill permanent residence
          self.contents.blt(x + @plus_x + @width * @rate_x / 100, y + @plus_y,
                        @at_gauge, Rect.new(rect_x, @height * 4, at, @height))
        end
      end
    end
  end
end

#============================================================================== 
# ** Scene_Battle (part 1)
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    # Initialize each kind of temporary battle data
    $game_temp.in_battle = true
    $game_temp.battle_turn = 0
    $game_temp.battle_event_flags.clear
    $game_temp.battle_abort = false
    $game_temp.battle_main_phase = false
    $game_temp.battleback_name = $game_map.battleback_name
    $game_temp.forcing_battler = nil
    # Initialize battle event interpreter
    $game_system.battle_interpreter.setup(nil, 0)
    # Prepare troop
    @troop_id = $game_temp.battle_troop_id
    $game_troop.setup(@troop_id)
    atb_setup
    # Make actor command window
    s1 = $data_system.words.attack
    s2 = $data_system.words.skill
    s3 = $data_system.words.guard
    s4 = $data_system.words.item
    @actor_command_window = Window_Command.new(160, [s1, s2, s3, s4]) 
    @actor_command_window.y = 160
    @actor_command_window.back_opacity = 160
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # Make other windows
    @party_command_window = Window_PartyCommand.new
    @help_window = Window_Help.new
    @help_window.back_opacity = 160
    @help_window.visible = false
    @status_window = Window_BattleStatus.new
    @message_window = Window_Message.new
    # Make sprite set
    @spriteset = Spriteset_Battle.new
    # Initialize wait count
    @wait_count = 0
    # Execute transition
    if $data_system.battle_transition == ""
      Graphics.transition(20)
    else
      Graphics.transition(40, "Graphics/Transitions/" +
        $data_system.battle_transition)
    end
    # Start pre-battle phase
    start_phase1
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Refresh map 
    $game_map.refresh
    # Prepare for transition
    Graphics.freeze
    # Dispose of windows
    @actor_command_window.dispose
    @party_command_window.dispose
    @help_window.dispose
    @status_window.dispose
    @message_window.dispose
    if @skill_window != nil
      @skill_window.dispose
    end
    if @item_window != nil
      @item_window.dispose
    end
    if @result_window != nil
      @result_window.dispose
    end
    # Dispose of spriteset
    @spriteset.dispose
    # If switching to title screen
    if $scene.is_a?(Scene_Title)
      # Fade out screen
      Graphics.transition
      Graphics.freeze
    end
    # If switching from battle test to any screen other than game over screen
    if $BTEST and not $scene.is_a?(Scene_Gameover)
      $scene = nil
    end
  end
  #-------------------------------------------------------------------------- 
  # * Determine Battle Win/Loss Results
  #--------------------------------------------------------------------------
  def judge
    # If all dead determinant is true, or number of members in party is 0
    if $game_party.all_dead? or $game_party.actors.size == 0
      # If possible to lose
      if $game_temp.battle_can_lose
        # Return to BGM before battle starts
        $game_system.bgm_play($game_temp.map_bgm)
        # Battle end
        battle_end(2)
        # Return true
        return true
      end
      # Setting the game over flag
      $game_temp.gameover = true
      # Return true
      return true
    end
    # Return false if even 1 enemy exists
    for enemy in $game_troop.enemies
      if enemy.exist?
        return false
      end
    end
    # Start after battle phase (win)
    start_phase5
    # Return true
    return true
  end
  #-------------------------------------------------------------------------- 
  # * Frame renewal
  #--------------------------------------------------------------------------
  def update
    # If battle event is running
    if $game_system.battle_interpreter.running?
      if @command.size > 0
        @command_a = false
        @command = []
        command_delete
      end
      @status_window.at_refresh
      # Update interpreter
      $game_system.battle_interpreter.update
      # If a battler which is forcing actions doesn't exist
      if $game_temp.forcing_battler == nil
        # If battle event has finished running
        unless $game_system.battle_interpreter.running?
          # Refresh status window
          @status_window.refresh
          setup_battle_event
        end
      end
    end
    # Update system (timer) and screen
    $game_system.update
    $game_screen.update
    # If timer has reached 0
    if $game_system.timer_working and $game_system.timer == 0
      # Abort battle
      $game_temp.battle_abort = true
    end
    # Update windows 
    @help_window.update
    @party_command_window.update
    @actor_command_window.update
    @status_window.update
    @message_window.update
    # Update sprite set
    @spriteset.update
    # If transition is processing 
    if $game_temp.transition_processing
      # Clear transition processing flag
      $game_temp.transition_processing = false
      # Execute transition
      if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(40, "Graphics/Transitions/" +
          $game_temp.transition_name)
      end
    end
    # If message window is showing
    if $game_temp.message_window_showing
      return
    end
    # If game over
    if $game_temp.gameover
      # Switch to game over screen
      $scene = Scene_Gameover.new
      return
    end
    # If returning to title screen
    if $game_temp.to_title
      # Switch to title screen
      $scene = Scene_Title.new
      return
    end
    # If battle is aborted
    if $game_temp.battle_abort
      # Return to BGM used before battle started
      $game_system.bgm_play($game_temp.map_bgm)
      # Battle ends
      battle_end(1)
      return
    end
    # If help window is waiting	
    if @help_wait > 0
      @help_wait -= 1
      if @help_wait == 0
        # Hide help window 
        @help_window.visible = false
      end
    end
    # When the battler forced into action doesn't exist
    # while the battle event is in the midst of executing
    if $game_temp.forcing_battler == nil and
       $game_system.battle_interpreter.running?
      return
    end
    # Branch according to phase
    case @phase
    when 0  # AT gauge renewal phase
      if anime_wait_return
        update_phase0
      end
    when 1  # pre-battle phase
      update_phase1
      return
    when 2  # party command phase
      update_phase2
      return
    when 5  # after battle phase
      update_phase5
      return
    end
    if $scene != self
      return
    end
    if @phase == 0
      if @command.size != 0  # Actor command phase
        if @command_a == false
          start_phase3
        end
        update_phase3
      end
      # If waiting
      if @wait_count > 0
        # Decrease wait count 
        @wait_count -= 1
        return
      end
      update_phase4
    end
  end

#============================================================================== 
# ** Scene_Battle (part 2)
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

  #--------------------------------------------------------------------------
  # * Frame renewal (AT gauge renewal phase)
  #--------------------------------------------------------------------------
  def update_phase0
    if $game_temp.battle_turn == 0
      $game_temp.battle_turn = 1
    end
    # If B button was pressed
    if @command_a == false and @party == false
      if Input.trigger?(Input::B)
        # Play cancel SE
        $game_system.se_play($data_system.cancel_se)
        @party = true
      end
    end
    if @party == true and
        ((@action > 0 and @action_battlers.empty?) or (@action == 0 and 
        (@action_battlers.empty? or @action_battlers[0].phase == 1)))
      # Start party command phase
      start_phase2
      return
    end
    # AT gauge increase processing 
    cnt = 0
    for battler in $game_party.actors + $game_troop.enemies
      active?(battler)
      if battler.rtp == 0
        if battler.at >= @max
          if battler.is_a?(Game_Actor)
            if battler.inputable?
              unless @action_battlers.include?(battler) or
                  @command.include?(battler) or @escape == true
                if battler.current_action.forcing
                  fullat_se
                  force_action(battler)
                  action_start(battler)
                else
                  fullat_se
                  @command.push(battler)
                end
              end
            else
              unless @action_battlers.include?(battler) or
                      battler == @command[0]
                battler.current_action.clear
                if @command.include?(battler)
                  @command.delete(battler)
                else
                  if battler.movable?
                    fullat_se
                  end
                end
                action_start(battler)
              end
            end
          else
            unless @action_battlers.include?(battler) 
              if battler.current_action.forcing
                force_action(battler)
                action_start(battler)
              else
                if @enemy_speed != 0
                  if rand(@enemy_speed) == 0
                    number = cnt - $game_party.actors.size
                    enemy_action(number)
                  end
                else
                  number = cnt - $game_party.actors.size
                  enemy_action(number)
                end
              end
            end
          end
        else
          battler.at += battler.agi
          if battler.guarding?
            battler.at += battler.agi
          end
          if battler.movable?
            battler.atp = 100 * battler.at / @max
          end
        end
      else 
        if battler.rt >= battler.rtp
          speller = synthe?(battler)
          if speller != nil
            battler = speller[0]
          end
          unless @action_battlers.include?(battler)
            if battler.is_a?(Game_Actor)
              fullat_se
            end
            battler.rt = battler.rtp
            action_start(battler)
          end
        else
          battler.rt += battler.agi
          speller = synthe?(battler)
          if speller != nil
            for spell in speller
              if spell != battler
                spell.rt += battler.agi
              end
            end
          end
        end
      end
      cnt += 1
    end
    # Refresh AT gauge
    @status_window.at_refresh
    # Escape processing 
    if @escape == true and
        ((@action > 0 and @action_battlers.empty?) or (@action == 0 and 
        (@action_battlers.empty? or @action_battlers[0].phase == 1)))
      temp = false
      for battler in $game_party.actors
        if battler.inputable?
          temp = true
        end
      end
      if temp == true
        for battler in $game_party.actors
          if battler.at < @max and battler.inputable?
            temp = false
            break
          end
        end
        if temp == true
          @escape = false
          for battler in $game_party.actors
            battler.at %= @max
          end
          $game_temp.battle_main_phase = false
          update_phase2_escape
        end
      end
    end
  end
  #-------------------------------------------------------------------------- 
  # * Start Party Command Phase
  #--------------------------------------------------------------------------
  def start_phase2
    # Shift to phase 2
    @phase = 2
    @party = false
    # Enable party command window
    @party_command_window.active = true
    @party_command_window.visible = true
    # Set actor to non-selecting
    @actor_index = -1
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
    if @command.size != 0
      # Actor blink effect OFF
      if @active_actor != nil
        @active_actor.blink = false
      end
    end
    # Camera set
    @camera == "party"
    @spriteset.screen_target(0, 0, 1)
    # Clear main phase flag
    $game_temp.battle_main_phase = false
  end
  #-------------------------------------------------------------------------- 
  # * Frame renewal (party command phase)
  #--------------------------------------------------------------------------
  def update_phase2
    # When C button is pushed
    if Input.trigger?(Input::C)
      # It diverges at cursor position of the party command window
      case @party_command_window.index
      when 0  # It fights
        # Nullifying the party command window
        @party_command_window.active = false
        @party_command_window.visible = false
        # Performing decision SE
        $game_system.se_play($data_system.decision_se)
        @escape = false
        @phase = 0
        if $game_temp.battle_turn == 0
          $game_temp.battle_turn = 1
        end
        if @command_a == true
          # Actor command phase start
          start_phase3
        else
          $game_temp.battle_main_phase = true
        end
      when 1  # It escapes
        # When it is not flight possible,
        if $game_temp.battle_can_escape == false
          # Performing buzzer SE
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # Performing decision SE
        $game_system.se_play($data_system.decision_se)
        @phase = 0
        # Nullifying the party command window 
        @party_command_window.active = false
        @party_command_window.visible = false
        $game_temp.battle_main_phase = true
        if $game_temp.battle_turn == 0
          update_phase2_escape
          $game_temp.battle_turn = 1
          for battler in $game_party.actors
            battler.at -= @max / 2
          end
          return
        end
        # Performing decision SE
        $game_system.se_play($data_system.decision_se)
        @escape = true
        for battler in $game_party.actors
          @command_a = false
          @command.delete(battler)
          @action_battlers.delete(battler)
          skill_reset(battler)
        end
      end
      return
    end
  end
  #-------------------------------------------------------------------------- 
  # * Frame renewal (party command phase: It escapes)
  #--------------------------------------------------------------------------
  def update_phase2_escape
    # The enemy it is fast, calculating mean value
    enemies_agi = 0
    enemies_number = 0
    for enemy in $game_troop.enemies
      if enemy.exist?
        enemies_agi += enemy.agi
        enemies_number += 1
      end
    end
    if enemies_number > 0
      enemies_agi /= enemies_number
    end
    # The actor it is fast, calculating mean value
    actors_agi = 0
    actors_number = 0
    for actor in $game_party.actors
      if actor.exist?
        actors_agi += actor.agi
        actors_number += 1
      end
    end
    if actors_number > 0
      actors_agi /= actors_number
    end
    # Flight success decision
    success = rand(100) < 50 * actors_agi / enemies_agi
    # In case of flight success
    if success
      # Performing flight SE
      $game_system.se_play($data_system.escape_se)
      # You reset to BGM before the battle starting
      $game_system.bgm_play($game_temp.map_bgm)
      # Battle end
      battle_end(1)
    # In case of failure of flight 
    else 
      @help_window.set_text("Cannot escape", 1)
      @help_wait = @help_time
      # Clearing the action of party everyone
      $game_party.clear_actions
      # Main phase start
      start_phase4
    end
  end
  #--------------------------------------------------------------------------
  # * After battle phase start
  #--------------------------------------------------------------------------
  def start_phase5
    # It moves to phase 5
    @phase = 5
    # Performing battle end ME
    $game_system.me_play($game_system.battle_end_me)
    # You reset to BGM before the battle starting
    $game_system.bgm_play($game_temp.map_bgm)
    # Initializing EXP, the gold and the treasure
    exp = 0
    gold = 0
    treasures = []
    if @active_actor != nil
      @active_actor.blink = false
    end
    # Setting the main phase flag
    $game_temp.battle_main_phase = true
    # Nullifying the party command window
    @party_command_window.active = false
    @party_command_window.visible = false
    # Nullifying the actor command window 
    @actor_command_window.active = false
    @actor_command_window.visible = false
    if @skill_window != nil
      # Releasing the skill window
      @skill_window.dispose
      @skill_window = nil
    end
    if @item_window != nil
      # Releasing the item window 
      @item_window.dispose
      @item_window = nil
    end
    # The help window is hidden 
    @help_window.visible = false if @help_wait == 0
    # Loop
    for enemy in $game_troop.enemies
      # When the enemy hides and it is not state,
      unless enemy.hidden
        # Adding acquisition EXP and the gold
        exp += enemy.exp
        gold += enemy.gold
        # Treasure appearance decision
        if rand(100) < enemy.treasure_prob
          if enemy.item_id > 0
            treasures.push($data_items[enemy.item_id])
          end
          if enemy.weapon_id > 0
            treasures.push($data_weapons[enemy.weapon_id])
          end
          if enemy.armor_id > 0
            treasures.push($data_armors[enemy.armor_id])
          end
        end
      end
    end
    # It limits the number of treasures up to 6 
    treasures = treasures[0..5]
    # EXP acquisition
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      if actor.cant_get_exp? == false
        last_level = actor.level
        actor.exp += exp
        if actor.level > last_level
          @status_window.level_up(i)
          actor.damage[[actor, -1]] = "Level up!"
          actor.up_level = actor.level - last_level
        end
      end
    end
    # Gold acquisition
    $game_party.gain_gold(gold)
    # Treasure acquisition
    for item in treasures
      case item
      when RPG::Item
        $game_party.gain_item(item.id, 1)
      when RPG::Weapon
        $game_party.gain_weapon(item.id, 1)
      when RPG::Armor
        $game_party.gain_armor(item.id, 1)
      end
    end
    # Drawing up the battle result window
    @result_window = Window_BattleResult.new(exp, gold, treasures)
    # Setting wait count
    @phase5_wait_count = 100
  end
  #-------------------------------------------------------------------------- 
  # * Frame renewal (after battle phase)
  #--------------------------------------------------------------------------
  def update_phase5
    # When wait count is larger than 0,
    if @phase5_wait_count > 0
      # Wait count is decreased
      @phase5_wait_count -= 1
      # When wait count becomes 0,
      if @phase5_wait_count == 0
        # Indicating the result window
        @result_window.visible = true
        # Clearing the main phase flag
        $game_temp.battle_main_phase = false
        # Refreshing the status window
        @status_window.refresh
        for actor in $game_party.actors
          if actor.damage.include?([actor, 0])
            @phase5_wait_count = 20
            actor.damage_pop[[actor, 0]] = true
          end
          if actor.damage.include?([actor, -1])
            @phase5_wait_count = 20
            actor.damage_pop[[actor, -1]] = true
            for level in actor.level - actor.up_level + 1..actor.level
              for skill in $data_classes[actor.class_id].learnings
                if level == skill.level and not actor.skill_learn?(skill.id)
                  actor.damage[[actor, 0]] = "New Skill!"
                  break
                end
              end
            end
          end
        end
      end
      return
    end
    # When C button is pushed, 
    if Input.trigger?(Input::C)
      # Battle end
      battle_end(0)
    end
  end

#============================================================================== 
# ** Scene_Battle (Part 3)
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

  #--------------------------------------------------------------------------
  # * Actor command phase start
  #--------------------------------------------------------------------------
  def start_phase3
    if victory?
      return
    end
    # Clearing the main phase flag
    $game_temp.battle_main_phase = false
    @command_a = true
    @active_actor = @command[0]
    cnt = 0
    for actor in $game_party.actors
      if actor == @active_actor
        @actor_index = cnt
      end
      cnt += 1
    end
    @active_actor.blink = true
    unless @active_actor.inputable?
      @active_actor.current_action.clear
      phase3_next_actor
      return
    end
    phase3_setup_command_window
    # Setting of camera
    @camera = "command"
    plus = ($game_party.actors.size - 1) / 2.0 - @actor_index
    y = [(plus.abs - 1.5) * 10 , 0].min
    @spriteset.screen_target(plus * 50, y, 1.0 + y * 0.002)
  end
  #-------------------------------------------------------------------------- 
  # * Command input end of actor
  #--------------------------------------------------------------------------
  def phase3_next_actor
    @command.shift
    @command_a = false
    # Setting the main phase flag
    $game_temp.battle_main_phase = true
    # Nullifying the actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # Blinking effect OFF of actor
    if @active_actor != nil
      @active_actor.blink = false
    end
    action_start(@active_actor)
    # You reset on the basis of the camera
    if @camera == "command"
      @spriteset.screen_target(0, 0, 1)
    end
    return
  end
  #--------------------------------------------------------------------------
  # * Setup of actor command window
  #--------------------------------------------------------------------------
  def phase3_setup_command_window 
    # Nullifying the party command window
    @party_command_window.active = false
    @party_command_window.visible = false
    # Enabling the actor command window
    @actor_command_window.active = true
    @actor_command_window.visible = true
    # Setting the position of the actor command window
    @actor_command_window.x = @actor_index * 160 +
                              (4 - $game_party.actors.size) * 80
    # Setting the index to 0
    @actor_command_window.index = 0
  end
  #-------------------------------------------------------------------------- 
  # * Enemy action compilation
  #--------------------------------------------------------------------------
  def enemy_action(number)
    enemy = $game_troop.enemies[number]
    unless enemy.current_action.forcing
      enemy.make_action
    end
    action_start(enemy)
  end
  #--------------------------------------------------------------------------
  # * Frame renewal (actor command phase)
  #--------------------------------------------------------------------------
  def update_phase3
    if victory? and @command_a
      command_delete
      @command.push(@active_actor)
      return
    end
    # When the enemy arrow is effective,
    if @enemy_arrow != nil
      update_phase3_enemy_select
    # When the actor arrow is effective,
    elsif @actor_arrow != nil
      update_phase3_actor_select
    # When the skill window is effective,
    elsif @skill_window != nil
      update_phase3_skill_select
    # When the item window is effective
    elsif @item_window != nil
      update_phase3_item_select
    # When the actor command window is effective,
    elsif @actor_command_window.active
      update_phase3_basic_command
    end
  end
  #-------------------------------------------------------------------------- 
  # * Frame renewal (actor command phase: Basic command)
  #--------------------------------------------------------------------------
  def update_phase3_basic_command
    unless @active_actor.inputable?
      @active_actor.current_action.clear
      phase3_next_actor
      return
    end
    # The B when button is pushed,
    if Input.trigger?(Input::B) and @party == false
      # Performing cancellation SE
      $game_system.se_play($data_system.cancel_se)
      @party = true
    end
    if @party == true and
        ((@action > 0 and @action_battlers.empty?) or (@action == 0 and 
        (@action_battlers.empty? or @action_battlers[0].phase == 1)))
      # To party command phase
      start_phase2
      return
    end
    # When C button is pushed,
    if Input.trigger?(Input::C)
      @party = false
      # It diverges at cursor position of the actor command window
      case @actor_command_window.index
      when 0  # Attack
        # Performing decision SE
        $game_system.se_play($data_system.decision_se)
        # Starting the selection of the enemy
        start_enemy_select
      when 1  # Skill
        # Performing decision SE
        $game_system.se_play($data_system.decision_se)
        # Starting the selection of skill
        start_skill_select
      when 2  # Defense 
        # Performing decision SE
        $game_system.se_play($data_system.decision_se)
        # Setting action
        @active_actor.current_action.kind = 0
        @active_actor.current_action.basic = 1
        # To command input of the following actor
        phase3_next_actor
      when 3  # Item
        # Performing decision SE
        $game_system.se_play($data_system.decision_se)
        # Starting the selection of the item
        start_item_select
      end
      return
    end
    # Change Character
    if @command.size > 1
      # When the R when button is pushed,
      if Input.trigger?(Input::R)
        $game_system.se_play($data_system.cursor_se)
        @party = false
        # Blinking effect OFF of actor
        if @active_actor != nil
          @active_actor.blink = false
        end
        @command.push(@command[0])
        @command.shift
        @command_a = false
        # Start-up of new command window
        start_phase3
      end
      # When the L when button is pushed,
      if Input.trigger?(Input::L)
        $game_system.se_play($data_system.cursor_se)
        @party = false
        # Blinking effect OFF of actor
        if @active_actor != nil
          @active_actor.blink = false
        end
        @command.unshift(@command[@command.size - 1]) 
        @command.delete_at(@command.size - 1)
        @command_a = false
        # Start-up of new command window
        start_phase3
      end
     # When the right button is pushed,
      if Input.trigger?(Input::RIGHT)
        $game_system.se_play($data_system.cursor_se)
        @party = false
        # Blinking effect OFF of actor
        if @active_actor != nil
          @active_actor.blink = false
        end
        actor = $game_party.actors[@actor_index]
        while actor == @command[0] or (not @command.include?(actor))
          @actor_index += 1
          @actor_index %= $game_party.actors.size
          actor = $game_party.actors[@actor_index]
          if actor == @command[0]
            break
          end
        end
        while actor != @command[0]
          @command.push(@command.shift)
        end
        @command_a = false
        # Start-up of new command window
        start_phase3
      end
     # When the left button is pushed,
      if Input.trigger?(Input::LEFT)
        $game_system.se_play($data_system.cursor_se)
        @party = false
        # Blinking effect OFF of actor
        if @active_actor != nil
          @active_actor.blink = false
        end
        actor = $game_party.actors[@actor_index] 
        while actor == @command[0] or (not @command.include?(actor))
          @actor_index -= 1
          @actor_index %= $game_party.actors.size
          actor = $game_party.actors[@actor_index]
          if actor == @command[0]
            break
          end
        end
        while actor != @command[0]
          @command.push(@command.shift)
        end
        @command_a = false
        # Start-up of new command window
        start_phase3
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Frame renewal (actor command phase: Skill selection)
  #--------------------------------------------------------------------------
  def update_phase3_skill_select
    # During command selecting when it becomes incapacitation,
    unless @active_actor.inputable?
      @active_actor.current_action.clear
      command_delete
      # To command input of the following actor
      phase3_next_actor
      return
    end
    # The skill window is put in visible state
    @skill_window.visible = true
    # Renewing the skill window
    @skill_window.update
    # The B when button is pushed,
    if Input.trigger?(Input::B)
      # Performing cancellation SE
      $game_system.se_play($data_system.cancel_se)
      # End selection of skill 
      end_skill_select
      return
    end
    # When C button is pushed,
    if Input.trigger?(Input::C)
      # Acquiring the data which presently is selected in the skill window
      @skill = @skill_window.skill
      # When you cannot use,
      if @skill == nil or not @active_actor.skill_can_use?(@skill.id)
        # Performing buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Performing decision SE
      $game_system.se_play($data_system.decision_se)
      # Setting action
      @active_actor.current_action.skill_id = @skill.id
      # The skill window is put in invisibility state
      @skill_window.visible = false
      # When the effective range is the enemy single unit,
      if @skill.scope == 1
        # Starting the selection of the enemy
        start_enemy_select
      # When the effective range is the friend single unit,
      elsif @skill.scope == 3 or @skill.scope == 5
        # Starting the selection of the actor
        start_actor_select
      # When the effective range is not the single unit,
      else
        # Setting action
        @active_actor.current_action.kind = 1
        # End selection of skill
        end_skill_select
        # To command input of the following actor
        phase3_next_actor
      end
      return
    end
  end
  #-------------------------------------------------------------------------- 
  # * Frame renewal (actor command phase: Item selection)
  #--------------------------------------------------------------------------
  def update_phase3_item_select
    # During command selecting when it becomes incapacitation,
    unless @active_actor.inputable?
      @active_actor.current_action.clear
      command_delete
      # To command input of the following actor
      phase3_next_actor
      return
    end
    # The item window is put in visible state
    @item_window.visible = true
    # Renewing the item window
    @item_window.update
    # The B when button is pushed,
    if Input.trigger?(Input::B)
      # Performing cancellation SE
      $game_system.se_play($data_system.cancel_se)
      # End selection of item
      end_item_select
      return
    end
    #When C button is pushed,
    if Input.trigger?(Input::C)
      # Acquiring the data which presently is selected in the item window
      @item = @item_window.item
      # When you cannot use,
      unless $game_party.item_can_use?(@item.id)
        # Performing buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Performing decision SE
      $game_system.se_play($data_system.decision_se)
      # Setting action
      @active_actor.current_action.item_id = @item.id
      # The item window is put in invisibility state 
      @item_window.visible = false
      # When the effective range is the enemy single unit,
      if @item.scope == 1
        # Starting the selection of the enemy
        start_enemy_select
      # When the effective range is the friend single unit,
      elsif @item.scope == 3 or @item.scope == 5
        # Starting the selection of the actor
        start_actor_select
      # When the effective range is not the single unit,
      else
        # Setting action
        @active_actor.current_action.kind = 2
        # End selection of item
        end_item_select
        # To command input of the following actor
        phase3_next_actor
      end
      return
    end
  end
  #-------------------------------------------------------------------------- 
  # * Frame renewal (actor command phase: Enemy selection)
  #--------------------------------------------------------------------------
  def update_phase3_enemy_select
    # During command selecting when it becomes incapacitation,
    unless @active_actor.inputable?
      # You reset on the basis of the camera
      if @camera == "select"
        @spriteset.screen_target(0, 0, 1)
      end
      @active_actor.current_action.clear
      command_delete
      # To command input of the following actor
      phase3_next_actor
      return
    end
    # Renewing the enemy arrow
    @enemy_arrow.update
    # The B when button is pushed,
    if Input.trigger?(Input::B)
      # Performing cancellation SE
      $game_system.se_play($data_system.cancel_se)
      # You reset on the basis of the camera
      if @camera == "select"
        # Setting of camera
        @camera = "command"
        plus = ($game_party.actors.size - 1) / 2.0 - @actor_index
        y = [(plus.abs - 1.5) * 10 , 0].min
        @spriteset.screen_target(plus * 50, y, 1.0 + y * 0.002)
      end
      # End selection of enemy
      end_enemy_select
      return
    end
    # When C button is pushed,
    if Input.trigger?(Input::C)
      # Performing decision SE
      $game_system.se_play($data_system.decision_se)
      # Performing decision SE 
      @active_actor.current_action.kind = 0
      @active_actor.current_action.basic = 0
      @active_actor.current_action.target_index = @enemy_arrow.index
      # When it is in the midst of skill window indicating,
      if @skill_window != nil
        # Resetting action
        @active_actor.current_action.kind = 1
        # End selection of skill
        end_skill_select
      end
      # When it is in the midst of item window indicating,
      if @item_window != nil
        # Resetting action
        @active_actor.current_action.kind = 2
        # End selection of item
        end_item_select
      end
      # End selection of enemy
      end_enemy_select
      # To command input of the following actor
      phase3_next_actor
    end
  end
  #-------------------------------------------------------------------------- 
  # * Frame renewal (actor command phase: Actor selection)
  #--------------------------------------------------------------------------
  def update_phase3_actor_select
    # During command selecting when it becomes incapacitation,
    unless @active_actor.inputable?
      @active_actor.current_action.clear
      command_delete
      # To command input of the following actor
      phase3_next_actor
      return
    end
    # Renewing the actor arrow
    @actor_arrow.update
    # The B when button is pushed,
    if Input.trigger?(Input::B)
      # Performing cancellation SE
      $game_system.se_play($data_system.cancel_se)
      # End selection of actor
      end_actor_select
      return
    end
    # When C button is pushed,
    if Input.trigger?(Input::C)
      # Performing decision SE
      $game_system.se_play($data_system.decision_se)
      # Setting action
      @active_actor.current_action.kind = 0
      @active_actor.current_action.basic = 0
      @active_actor.current_action.target_index = @actor_arrow.index
      # End selection of actor
      end_actor_select
      # When it is in the midst of skill window indicating,
      if @skill_window != nil
        # Resetting action
        @active_actor.current_action.kind = 1
        # End selection of skill
        end_skill_select
      end
      # When it is in the midst of item window indicating 
      if @item_window != nil
        # Resetting action
        @active_actor.current_action.kind = 2
        # End selection of item
        end_item_select
      end
      # To command input of the following actor
      phase3_next_actor
    end
  end
  #--------------------------------------------------------------------------
  # * Start of enemy selection
  #--------------------------------------------------------------------------
  alias :start_enemy_select_rtab :start_enemy_select
  def start_enemy_select
    @camera = "select"
    for enemy in $game_troop.enemies
      if enemy.exist?
        zoom = 1 / enemy.zoom
        @spriteset.screen_target(enemy.attack_x(zoom) * 0.75,
                                  enemy.attack_y(zoom) * 0.75, zoom)
        break
      end
    end
    # Original processing
    start_enemy_select_rtab
  end
  #--------------------------------------------------------------------------
  # * Enemy selection end
  #--------------------------------------------------------------------------
  alias :end_enemy_select_rtab :end_enemy_select
  def end_enemy_select
    # Original processing
    end_enemy_select_rtab
    if (@action == 0 and not @action_battlers.empty?) or
          (@camera == "select" and (@active_actor.current_action.kind != 0 or
                                            @active_actor.animation1_id != 0))
      @spriteset.screen_target(0, 0, 1)
    end
  end
  #-------------------------------------------------------------------------- 
  # * Start of skill selection
  #--------------------------------------------------------------------------
  def start_skill_select
    # Drawing up the skill window
    @skill_window = Window_Skill.new(@active_actor)
    # Help window association
    @skill_window.help_window = @help_window
    # Nullifying the actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end

#==============================================================================
# ** Scene_Battle (Part 4)
#------------------------------------------------------------------------------
# 　It is the class which processes the battle picture.
#==============================================================================

  #--------------------------------------------------------------------------
  # * Main phase start
  #--------------------------------------------------------------------------
  def start_phase4
    $game_temp.battle_main_phase = true
  end
  #-------------------------------------------------------------------------- 
  # * Frame renewal (main phase)
  #--------------------------------------------------------------------------
  def update_phase4
    # When the battler who is forced action exists
    if $game_temp.forcing_battler != nil
      battler = $game_temp.forcing_battler
      if battler.current_action.forcing == false
        if @action_battlers.include?(battler)
          if @action > 0 or @action_battlers[0].phase == 1
            @action_battlers.delete(battler)
            @action_battlers.push(battler)
          end
          if battler.phase == 1 
            battler.current_action.forcing = true
            force_action(battler)
          end
        else
          battler.current_action.forcing = true
          force_action(battler)
          action_start(battler)
          @action_battlers.delete(battler)
          @action_battlers.push(battler)
        end
        battler.at = @max
        battler.atp = 100 * battler.at / @max
      end
    end
    # When action is 1 or more, conduct is caused simultaneously
    for battler in @action_battlers.reverse
      # When it is in wait,
      if battler.wait > 0
        # Wait count is decreased
        battler.wait -= 1
        break if @action == 0
        next
      end
      unless fin? and battler.phase < 3 and 
          not $game_system.battle_interpreter.running?
        action_phase(battler)
      end
      break if @action == 0
    end
    # When the battler who is forced action does not exist
    if $game_temp.forcing_battler == nil
      # Setting up the battle event
      setup_battle_event
      # When it is in the midst of battle event executing,
      if $game_system.battle_interpreter.running?
        return
      end
    end
    # The case where victory or defeat is decided processing
    if fin?
      # When being defeated, designated time wait
      if $game_party.all_dead? and @after_wait[0] > 0
        @after_wait[0] -= 1
        return
      end
      # At the time of victory, designated time wait
      if victory? and @after_wait[1] > 0
        @after_wait[1] -= 1
        return
      end
      # When battle ends, at the same time the actor is immediately before the acting, eliminating the conduct of the actor
      for battler in @action_battlers.reverse
        if battler.phase < 3 and not $game_system.battle_interpreter.running?
          @action_battlers.delete(battler)
        end
      end
      # Victory or defeat decision
      if @action_battlers.empty? and
          not $game_system.battle_interpreter.running?
        judge
      end
    end
  end
  #-------------------------------------------------------------------------- 
  # * Action renewal (main phase)
  #--------------------------------------------------------------------------
  def action_phase(battler) 
    # When action 1 is, verification whether or not the battler while acting
    if @action == 1 and battler.phase <= 3
      for target in battler.target
        speller = synthe?(target)
        if speller == nil
          # When the target is in the midst of usual acting,
          if @action_battlers.include?(target)
            if target.phase > 2
              return
            end
          end
        else
          # When the target is in the midst of cooperation skill moving
          for spell in speller
            if @action_battlers.include?(spell)
              if spell.phase > 2
                return
              end
            end
          end
        end
      end
    end
    case battler.phase
    when 1
      update_phase4_step1(battler)
    when 2
      update_phase4_step2(battler)
    when 3
      update_phase4_step3(battler)
    when 4
      update_phase4_step4(battler)
    when 5
      update_phase4_step5(battler)
    when 6
      update_phase4_step6(battler)
    end
  end
  #-------------------------------------------------------------------------- 
  # * Frame Update (main phase step 1 : action preparation)
  #--------------------------------------------------------------------------
  def update_phase4_step1(battler) 
    # Already, when it is removed from battle
    if battler.index == nil
      @action_battlers.delete(battler)
      anime_wait_return
      return
    end
    speller = synthe?(battler)
    if speller == nil
      # When it is while the damage receiving
      unless battler.damage.empty? or @action > 2
        return
      end
      # Whether or not conduct possibility decision
      unless battler.movable? 
        battler.phase = 6
        return
      end
    else
      # When it is while the damage receiving,
      for spell in speller
        unless spell.damage.empty? or @action > 2
          return
        end
        # Whether or not conduct possibility decision
        unless spell.movable?
          battler.phase = 6
          return
        end
      end
    end
    # At the time of skill use, permanent residence time setting
    # When forced action and @force 2 being, skill immediately motion
    if battler.current_action.kind == 1 and
      (not battler.current_action.forcing or @force != 2)
      if battler.rtp == 0
        # If it is in the midst of skill residing permanently, cancellation 
        skill_reset(battler)
        # Skill permanent residence time setting
        recite_time(battler)
        # Cooperation skill setting
        synthe_spell(battler)
        # When skill you reside permanently,
        if battler.rtp > 0
          # When forced action and @force 1 being, only cooperation skill immediately motion
          speller = synthe?(battler)
          if battler.current_action.forcing and @force > 0 and speller != nil
            for spell in speller
              spell.rt = spell.rtp
            end
          else
            battler.blink = true
            if battler.current_action.forcing
              $game_temp.forcing_battler = nil
              battler.current_action.forcing = false
            end
            @action_battlers.delete(battler)
            return
          end
        end
      end
    end
    # Blinking effect OFF of actor
    if battler != nil
      battler.blink = false
    end
    speller = synthe?(battler)
    if speller == nil
      @spell_p.delete(battler)
      @spell_e.delete(battler)
    else
      for spell in speller
        spell.blink = false
        @spell_p.delete(spell)
        @spell_e.delete(spell)
      end
    end
    # It moves to step 2
    battler.phase = 2
  end
  #-------------------------------------------------------------------------- 
  # * Frame renewal (main phase step 2: Action start)
  #--------------------------------------------------------------------------
  def update_phase4_step2(battler) 
    # If it is not forced action
    unless battler.current_action.forcing
      # When restriction [ the enemy is attacked ] [ friend attacks ] usually usually
      if battler.restriction == 2 or battler.restriction == 3
        # Setting attack to action
        battler.current_action.kind = 0
        battler.current_action.basic = 0
      end
    end
    # It diverges with classification of action
    case battler.current_action.kind
    when 0  # Basis
      if fin?
        battler.phase = 6
        return
      end
      make_basic_action_result(battler)
    when 1  # Skill
      if fin? and $data_skills[battler.current_action.skill_id].scope == 1..2
        battler.phase = 6
        return
      end
      make_skill_action_result(battler)
    when 2  # Item
      if fin? and $data_items[battler.current_action.item_id].scope == 1..2
        battler.phase = 6
        return
      end
      make_item_action_result(battler)
    end
    if battler.phase == 2
      # It moves to step 3
      battler.phase = 3
    end
  end
  #-------------------------------------------------------------------------- 
  # * Basic action result compilation
  #--------------------------------------------------------------------------
  def make_basic_action_result(battler)
    # In case of attack
    if battler.current_action.basic == 0
      # Setting animation ID
      battler.anime1 = battler.animation1_id
      battler.anime2 = battler.animation2_id
      # When the conduct side battler is the enemy
      if battler.is_a?(Game_Enemy)
        if battler.restriction == 3
          target = $game_troop.random_target_enemy
        elsif battler.restriction == 2
          target = $game_party.random_target_actor
        else
          index = battler.current_action.target_index
          target = $game_party.smooth_target_actor(index)
        end
      end
      # When the conduct side battler is the actor
      if battler.is_a?(Game_Actor)
        if battler.restriction == 3
          target = $game_party.random_target_actor
        elsif battler.restriction == 2
          target = $game_troop.random_target_enemy
        else
          index = battler.current_action.target_index
          target = $game_troop.smooth_target_enemy(index)
        end
      end
      # Setting the arrangement of the object side battler
      battler.target = [target]
      # Applying the effect of normality attack
      for target in battler.target
        target.attack_effect(battler)
      end
      return
    end
    # In case of defense 
    if battler.current_action.basic == 1
      return
    end
    # When escapes and is
    if battler.is_a?(Game_Enemy) and battler.current_action.basic == 2
      return
    end
    # When what is not and is
    if battler.current_action.basic == 3
      # It moves to step 6
      battler.phase = 6
      return
    end
  end
  #-------------------------------------------------------------------------- 
  # * Object side battler setting of skill or item
  #     scope : Effective range of skill or item
  #--------------------------------------------------------------------------
  def set_target_battlers(scope, battler)
    # When the conduct side battler is the enemy,
    if battler.is_a?(Game_Enemy)
      # It diverges in the effective range
      case scope
      when 1  # Enemy single unit
        index =battler.current_action.target_index
        battler.target.push($game_party.smooth_target_actor(index))
      when 2  # Whole enemy
        for actor in $game_party.actors
          if actor.exist?
            battler.target.push(actor)
          end
        end
      when 3  # Friend single unit
        index = battler.current_action.target_index
        battler.target.push($game_troop.smooth_target_enemy(index))
      when 4  # Whole friend
        for enemy in $game_troop.enemies
          if enemy.exist?
            battler.target.push(enemy)
          end
        end
      when 5  # Friend single unit (HP 0)
        index = battler.current_action.target_index
        enemy = $game_troop.enemies[index]
        if enemy != nil and enemy.hp0?
          battler.target.push(enemy)
        end
      when 6  # Whole friend (HP 0)
        for enemy in $game_troop.enemies
          if enemy != nil and enemy.hp0?
            battler.target.push(enemy)
          end
        end
      when 7  # User 
        battler.target.push(battler)
      end
    end
    # When the conduct side battler is the actor,
    if battler.is_a?(Game_Actor)
      # It diverges in the effective range
      case scope
      when 1  # Enemy single unit
        index = battler.current_action.target_index
        battler.target.push($game_troop.smooth_target_enemy(index))
      when 2  # Whole enemy
        for enemy in $game_troop.enemies
          if enemy.exist?
            battler.target.push(enemy)
          end
        end
      when 3  # Friend single unit
        index = battler.current_action.target_index
        battler.target.push($game_party.smooth_target_actor(index))
      when 4  # Whole friend
        for actor in $game_party.actors
          if actor.exist?
            battler.target.push(actor)
          end
        end
      when 5  # Friend single unit (HP 0)
        index = battler.current_action.target_index
        actor = $game_party.actors[index]
        if actor != nil and actor.hp0?
          battler.target.push(actor)
        end
      when 6  # Whole friend (HP 0)
        for actor in $game_party.actors
          if actor != nil and actor.hp0?
            battler.target.push(actor)
          end
        end
      when 7  # User
        battler.target.push(battler)
      end
    end
  end
  #-------------------------------------------------------------------------- 
  # * Skill action result compilation
  #--------------------------------------------------------------------------
  def make_skill_action_result(battler)
    # Acquiring skill
    @skill = $data_skills[battler.current_action.skill_id]
    # Verification whether or not it is cooperation skill,
    speller = synthe?(battler)
    # If it is not forced action
    unless battler.current_action.forcing
      # When with SP and so on is cut off and it becomes not be able to use
      if speller == nil
        unless battler.skill_can_use?(@skill.id)
          # It moves to step 6
          battler.phase = 6
         return
        end
      end
    end
    # SP consumption
    temp = false
    if speller != nil
      for spell in speller
        if spell.current_action.spell_id == 0
          spell.sp -= @skill.sp_cost
        else
          spell.sp -= $data_skills[spell.current_action.spell_id].sp_cost
        end
        # Refreshing the status window
        status_refresh(spell)
      end
    else
      battler.sp -= @skill.sp_cost
      # Refreshing the status window
      status_refresh(battler)
    end
    # Setting animation ID
    battler.anime1 = @skill.animation1_id
    battler.anime2 = @skill.animation2_id
    # Setting common event ID 
    battler.event = @skill.common_event_id
    # Setting the object side battler
    set_target_battlers(@skill.scope, battler)
    # Applying the effect of skill
    for target in battler.target
      if speller != nil
        damage = 0
        d_result = false
        effective = false
        state_p = []
        state_m = []
        for spell in speller
          if spell.current_action.spell_id != 0
            @skill = $data_skills[spell.current_action.spell_id]
          end
          effective |= target.skill_effect(spell, @skill)
          if target.damage[spell].class != String
            d_result = true
            damage += target.damage[spell]
          elsif effective
            effect = target.damage[spell]
          end
          state_p += target.state_p[spell]
          state_m += target.state_m[spell]
          target.damage.delete(spell)
          target.state_p.delete(spell)
          target.state_m.delete(spell)
        end
        if d_result
          target.damage[battler] = damage
        elsif effective
          target.damage[battler] = effect
        else
          target.damage[battler] = 0
        end
        target.state_p[battler] = state_p
        target.state_m[battler] = state_m
      else
        target.skill_effect(battler, @skill)
      end
    end
  end
  #-------------------------------------------------------------------------- 
  # * Item action result compilation
  #--------------------------------------------------------------------------
  def make_item_action_result(battler)
    # Acquiring the item
    @item = $data_items[battler.current_action.item_id]
    # When with the item and so on is cut off and it becomes not be able to use
    unless $game_party.item_can_use?(@item.id)
      # It moves to step 6
      battler.phase = 6
      return
    end
    # In case of consumable
    if @item.consumable
      # The item which you use is decreased 1
      $game_party.lose_item(@item.id, 1)
    end
    # Setting animation ID
    battler.anime1 = @item.animation1_id
    battler.anime2 = @item.animation2_id
    # Setting common event ID
    battler.event = @item.common_event_id
    # Deciding the object
    index = battler.current_action.target_index
    target = $game_party.smooth_target_actor(index)
    # Setting the object side battler
    set_target_battlers(@item.scope, battler)
    # Applying the effect of the item
    for target in battler.target
      target.item_effect(@item, battler)
    end
  end
  #-------------------------------------------------------------------------- 
  # * Frame renewal (main phase step 3: Conduct side animation)
  #--------------------------------------------------------------------------
  def update_phase4_step3(battler)
    # Renewal of help window. It diverges with classification of action
    case battler.current_action.kind
    when 0  # Basis
      if battler.current_action.basic == 1
        @help_window.set_text($data_system.words.guard, 1)
        @help_wait = @help_time
      end
      if battler.current_action.basic == 2
        # Escape
        @help_window.set_text("Escape", 1)
        @help_wait = @help_time
        battler.escape
        battler.phase = 4
        return
      end
    when 1  # Skill 
      skill =  $data_skills[battler.current_action.skill_id]
      @help_window.set_text(skill.name, 1)
      @help_wait = @help_time
    when 2  # Item
      item = $data_items[battler.current_action.item_id]
      @help_window.set_text(item.name, 1)
      @help_wait = @help_time
    end
    # When conduct side animation (ID 0 is, the white flash)
    if battler.anime1 == 0
      battler.white_flash = true
      battler.wait = 5
      # Camera setting
      if battler.target[0].is_a?(Game_Enemy)
        camera_set(battler)
      end
    else
      battler.animation.push([battler.anime1, true])
      speller = synthe?(battler)
      if speller != nil
        for spell in speller
          if spell != battler
            if spell.current_action.spell_id == 0
              spell.animation.push([battler.anime1, true])
            else
              skill = spell.current_action.spell_id
              spell.animation.push([$data_skills[skill].animation1_id, true])
              spell.current_action.spell_id = 0
            end
          end
        end
      end
      battler.wait = 2 * $data_animations[battler.anime1].frame_max - 10
    end
    # It moves to step 4
    battler.phase = 4
  end
  #--------------------------------------------------------------------------
  # * Frame renewal (main phase step 4: Object side animation)
  #--------------------------------------------------------------------------
  def update_phase4_step4(battler)
    # Camera setting
    if battler.target[0].is_a?(Game_Enemy) and battler.anime1 != 0
       camera_set(battler)
    end
    # Object side animation
    for target in battler.target
      target.animation.push([battler.anime2,
                                          (target.damage[battler] != "Miss")])
      unless battler.anime2 == 0
        battler.wait = 2 * $data_animations[battler.anime2].frame_max - 10
      end
    end
    # It moves to step 5
    battler.phase = 5
  end
  #--------------------------------------------------------------------------
  # * Frame renewal (main phase step 5: Damage indication)
  #--------------------------------------------------------------------------
  def update_phase4_step5(battler)
    # Damage indication
    for target in battler.target
      if target.damage[battler] != nil
        target.damage_pop[battler] = true
        target.damage_effect(battler, battler.current_action.kind)
        battler.wait = @damage_wait
        # Refreshing the status window
        status_refresh(target)
      end
    end
    # It moves to step 6
    battler.phase = 6
  end
  #--------------------------------------------------------------------------
  # * Frame renewal (main phase step 6: Refreshment)
  #--------------------------------------------------------------------------
  def update_phase4_step6(battler)
    # The camera is reset
    if battler.target[0].is_a?(Game_Enemy) and @camera == battler
      @spriteset.screen_target(0, 0, 1)
    end
    # Skill learning
    if battler.target[0].is_a?(Game_Actor) and battler.current_action.kind == 1
      for target in battler.target
        skill_learning(target, target.class_id,
                        battler.current_action.skill_id)
      end
    end
    # Clearing the battler of the action forced object
    if battler.current_action.forcing == true and
        battler.current_action.force_kind == 0 and
        battler.current_action.force_basic == 0 and
        battler.current_action.force_skill_id == 0
      $game_temp.forcing_battler = nil
      battler.current_action.forcing = false
    end
    refresh_phase(battler)
    speller = synthe?(battler)
    if speller != nil
      for spell in speller
        if spell != battler
          refresh_phase(spell)
        end
      end
      synthe_delete(speller)
    end
    # When common event ID is valid
    if battler.event > 0
      # Setting up the event
      common_event = $data_common_events[battler.event]
      $game_system.battle_interpreter.setup(common_event.list, 0)
    end
    act = 0
    for actor in $game_party.actors + $game_troop.enemies
      if actor.movable?
        act += 1
      end
    end
    if @turn_cnt >= act and act > 0
      @turn_cnt %= act
      $game_temp.battle_turn += 1
      # Searching the full page of the battle event
      for index in 0...$data_troops[@troop_id].pages.size
        # Acquiring the event page
        page = $data_troops[@troop_id].pages[index]
        # When the span of this page [ turn ] is
        if page.span == 1
          # Clearing the execution being completed flag
          $game_temp.battle_event_flags[index] = false
        end
      end
    end
    battler.phase = 1
    @action_battlers.delete(battler)
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh_phase(battler)
    battler.at -= @max
    if battler.movable?
      battler.atp = 100 * battler.at / @max
    end
    spell_reset(battler)
    # Slip damage
    if battler.hp > 0 and battler.slip_damage?
      battler.slip_damage_effect
      battler.damage_pop["slip"] = true
    end
    # State natural cancellation
    battler.remove_states_auto
    # Refreshing the status window
    status_refresh(battler, true)
    unless battler.movable?
      return
    end
    # Turn several counts
    @turn_cnt += 1
  end
  #--------------------------------------------------------------------------
  # * Battler action start
  #--------------------------------------------------------------------------
  def action_start(battler)
    battler.phase = 1
    battler.anime1 = 0
    battler.anime2 = 0
    battler.target = []
    battler.event = 0
    @action_battlers.unshift(battler)
  end
  #--------------------------------------------------------------------------
  # * Refreshing the status window
  #--------------------------------------------------------------------------
  def status_refresh(battler, at = false)
    if battler.is_a?(Game_Actor)
      for i in 0...$game_party.actors.size
        if battler == $game_party.actors[i]
          number = i + 1
        end
      end
      @status_window.refresh(number)
      if at == true
        @status_window.at_refresh(number)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Animation wait judgement processing
  #--------------------------------------------------------------------------
  def anime_wait_return
    if (@action_battlers.empty? or @anime_wait == false) and
        not $game_system.battle_interpreter.running?
      # When the enemy arrow is valid
      if @enemy_arrow != nil
        return [@active - 2, 0].min == 0
      # When the actor arrow is valid
      elsif @actor_arrow != nil
        return [@active - 2, 0].min == 0
      # When the skill window is valid
      elsif @skill_window != nil
        return [@active - 3, 0].min == 0
      # When the item window is valid
      elsif @item_window != nil
        return [@active - 3, 0].min == 0
      # When the actor command window is valid
      elsif @actor_command_window.active
        return [@active - 1, 0].min == 0
      else
        return true
      end
    else
      return false
    end
  end
  #--------------------------------------------------------------------------
  # * Actor command elimination judgement
  #--------------------------------------------------------------------------
  def command_delete
    # When the enemy arrow is valid
    if @enemy_arrow != nil
      end_enemy_select
    # When the actor is valid
    elsif @actor_arrow != nil
      end_actor_select
    end
    # When the skill window is valid
    if @skill_window != nil
      end_skill_select
    # When the item window is valid
    elsif @item_window != nil
      end_item_select
    end
    # When the actor command window is valid
    if @actor_command_window.active
      @command.shift
      @command_a = false
      # Setting the main phase flag
      $game_temp.battle_main_phase = true
      # Hides the actor command window when it is invalid
      @actor_command_window.active = false
      @actor_command_window.visible = false
      # Blinking effect OFF of actor
      if @active_actor != nil
        @active_actor.blink = false
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Forcing action setting
  #--------------------------------------------------------------------------
  def force_action(battler)
    battler.current_action.kind = battler.current_action.force_kind
    battler.current_action.basic = battler.current_action.force_basic
    battler.current_action.skill_id = battler.current_action.force_skill_id
    battler.current_action.force_kind = 0
    battler.current_action.force_basic = 0
    battler.current_action.force_skill_id = 0
  end
  #--------------------------------------------------------------------------
  # * Camera set
  #--------------------------------------------------------------------------
  def camera_set(battler)
    @camera = battler
    if battler.target.size == 1
      if battler.current_action.kind == 0
        zoom = 1.2 / battler.target[0].zoom
      elsif synthe?(battler) == nil
        zoom = 1.5 / battler.target[0].zoom
      else
        zoom = 2.0 / battler.target[0].zoom
      end
      @spriteset.screen_target(battler.target[0].attack_x(zoom),
                                battler.target[0].attack_y(zoom), zoom)
    else
      @spriteset.screen_target(0, 0, 0.75)
    end
  end
  #--------------------------------------------------------------------------
  # * Skill permanent residence time compilation
  #--------------------------------------------------------------------------
  def recite_time(battler)
  end
  #--------------------------------------------------------------------------
  # * Cooperation skill distinction
  #--------------------------------------------------------------------------
  def synthe_spell(battler)
  end
  #--------------------------------------------------------------------------
  # * Skill learning system
  #--------------------------------------------------------------------------
  def skill_learning(actor, class_id, skill_id)
  end
  #--------------------------------------------------------------------------
  # * Conduct possible decision
  #--------------------------------------------------------------------------
  def active?(battler)
    speller = synthe?(battler)
    if speller != nil
      if synthe_delete?(speller)
        return false
      end
    else
      unless battler.inputable?
        spell_reset(battler)
        unless battler.movable?
          battler.atp = 0
          return false
        end
      end
      if battler.current_action.forcing
        spell_reset(battler)
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * During synthesis skill residing permanently?
  #--------------------------------------------------------------------------
  def synthe?(battler)
    for speller in @synthe
      if speller.include?(battler)
        return speller
      end
    end
    return nil
  end
  #--------------------------------------------------------------------------
  # * Synthesis skill elimination judgement
  #--------------------------------------------------------------------------
  def synthe_delete?(speller)
    for battler in speller
      if not battler.inputable? and dead_ok?(battler)
        synthe_delete(speller)
        return true
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Synthesis skill elimination
  #--------------------------------------------------------------------------
  def synthe_delete(speller)
    for battler in speller
      spell_reset(battler)
      if dead_ok?(battler)
        @action_battlers.delete(battler)
      end
    end
    @synthe.delete(speller)
  end
  #--------------------------------------------------------------------------
  # * Cooperation the skill permanent residence cancellation which is included
  #--------------------------------------------------------------------------
  def skill_reset(battler)
    speller = synthe?(battler)
    if speller != nil
      synthe_delete(speller)
    else
      spell_reset(battler)
    end
  end
  #--------------------------------------------------------------------------
  # * Skill permanent residence cancellation
  #--------------------------------------------------------------------------
  def spell_reset(battler)
    battler.rt = 0
    battler.rtp = 0
    battler.blink = false
    battler.spell = false
    battler.current_action.spell_id = 0
    @spell_p.delete(battler)
    @spell_e.delete(battler)
  end
  #--------------------------------------------------------------------------
  # * Battle end decision
  #--------------------------------------------------------------------------
  def fin?
   return (victory? or $game_party.all_dead? or $game_party.actors.size == 0)
  end
  #--------------------------------------------------------------------------
  # * Enemy total destruction decision
  #--------------------------------------------------------------------------
  def victory?
    for battler in $game_troop.enemies
      if not battler.hidden and (battler.rest_hp > 0 or
          battler.immortal or battler.damage_pop.size > 0)
        return false
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Death permission decision
  #--------------------------------------------------------------------------
  def dead_ok?(battler)
    speller = synthe?(battler)
    if speller == nil
      if @action_battlers.include?(battler)
        if battler.phase > 2
          return false
        end
      end
    else
      for battler in speller
        if @action_battlers.include?(battler)
          if battler.phase > 2
            return false
          end
        end
      end
    end
    return true
  end
end

#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
# 　It is the class which handles the actor. This class Game_Actors class 
#  ($game_actors) is used in inside, Game_Party class ($game_party) from is
#  referred to.
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Acquisition in battle picture X coordinate
  #--------------------------------------------------------------------------
  def screen_x
    # Calculating X coordinate from line order inside the party, it returns
    if self.index != nil
      return self.index * 160 + (4 - $game_party.actors.size) * 80 + 80
    else
      return 0
    end
  end
end

#==============================================================================
# ** Spriteset_Battle
#------------------------------------------------------------------------------
# 　It is the class which collected the sprite of the battle picture. This class
#  is used inside Scene_Battle クラ ス.
#==============================================================================

class Spriteset_Battle
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :real_x                   # X coordinate revision (presently value)
  attr_reader   :real_y                   # Y coordinate revision (presently value)
  attr_reader   :real_zoom                # Enlargement ratio (presently value)
  #--------------------------------------------------------------------------
  # * Object initialization
  #--------------------------------------------------------------------------
  def initialize
    # Drawing up the viewport
    @viewport1 = Viewport.new(0, 0, 640, 480)
    @viewport2 = Viewport.new(0, 0, 640, 480)
    @viewport3 = Viewport.new(0, 0, 640, 480)
    @viewport4 = Viewport.new(0, 0, 640, 480)
    @viewport2.z = 101
    @viewport3.z = 200
    @viewport4.z = 5000
    @wait = 0
    @real_x = 0
    @real_y = 0
    @real_zoom = 1.0
    @target_x = 0
    @target_y = 0
    @target_zoom = 1.0
    @gap_x = 0
    @gap_y = 0
    @gap_zoom = 0.0
    # Make battleback sprite
    @battleback_sprite = Sprite.new(@viewport1)
    # Drawing up enemy sprite
    @enemy_sprites = []
    for enemy in $game_troop.enemies.reverse
      @enemy_sprites.push(Sprite_Battler.new(@viewport1, enemy))
    end
    # Drawing up actor sprite
    @actor_sprites = []
    @actor_sprites.push(Sprite_Battler.new(@viewport2))
    @actor_sprites.push(Sprite_Battler.new(@viewport2))
    @actor_sprites.push(Sprite_Battler.new(@viewport2))
    @actor_sprites.push(Sprite_Battler.new(@viewport2))
    # Drawing up the weather
    @weather = RPG::Weather.new(@viewport1)
    # Drawing up picture sprite
    @picture_sprites = []
    for i in 51..100
      @picture_sprites.push(Sprite_Picture.new(@viewport3,
        $game_screen.pictures[i]))
    end
    # Drawing up timer sprite
    @timer_sprite = Sprite_Timer.new
    # Frame renewal
    update
  end
  #--------------------------------------------------------------------------
  # * Frame renewal
  #--------------------------------------------------------------------------
  def update
    # Contents of actor sprite renewal (in replacement of actor correspondence)
    @actor_sprites[0].battler = $game_party.actors[0]
    @actor_sprites[1].battler = $game_party.actors[1]
    @actor_sprites[2].battler = $game_party.actors[2]
    @actor_sprites[3].battler = $game_party.actors[3]
    # When file name of the battle back is different from present ones,
    if @battleback_name != $game_temp.battleback_name
      make_battleback
    end
    # Scroll of picture
    screen_scroll
    # Position revision of monster
    for enemy in $game_troop.enemies
      enemy.real_x = @real_x
      enemy.real_y = @real_y
      enemy.real_zoom = @real_zoom
    end
    # Renewing battler sprite
    for sprite in @enemy_sprites + @actor_sprites
      sprite.update
    end
    # Renewing weather graphics
    @weather.type = $game_screen.weather_type
    @weather.max = $game_screen.weather_max
    @weather.update
    # Renewing picture sprite
    for sprite in @picture_sprites
      sprite.update
    end
    # Renewing timer sprite
    @timer_sprite.update
    # Setting the color tone and shake position of the picture
    @viewport1.tone = $game_screen.tone
    @viewport1.ox = $game_screen.shake
    # Setting the flash color of the picture
    @viewport4.color = $game_screen.flash_color
    # Renewing the viewport
    @viewport1.update
    @viewport2.update
    @viewport4.update
  end
  #--------------------------------------------------------------------------
  # * Setting of battle background
  #--------------------------------------------------------------------------
  def make_battleback
    @battleback_name = $game_temp.battleback_name
    if @battleback_sprite.bitmap != nil
      @battleback_sprite.bitmap.dispose
    end
    @battleback_sprite.bitmap = RPG::Cache.battleback(@battleback_name)
    if @battleback_sprite.bitmap.width == 640 and
       @battleback_sprite.bitmap.height == 320
      @battleback_sprite.src_rect.set(0, 0, 1280, 640)
      @base_zoom = 2.0
      @battleback_sprite.zoom_x = @base_zoom
      @battleback_sprite.zoom_y = @base_zoom
      @real_y = 4
      @battleback_sprite.x = 320
      @battleback_sprite.y = @real_y
      @battleback_sprite.ox = @battleback_sprite.bitmap.width / 2
      @battleback_sprite.oy = @battleback_sprite.bitmap.height / 4
    elsif @battleback_sprite.bitmap.width == 640 and
          @battleback_sprite.bitmap.height == 480
      @battleback_sprite.src_rect.set(0, 0, 960, 720)
      @base_zoom = 1.5
      @battleback_sprite.zoom_x = @base_zoom
      @battleback_sprite.zoom_y = @base_zoom
      @battleback_sprite.x = 320
      @battleback_sprite.y = 0
      @battleback_sprite.ox = @battleback_sprite.bitmap.width / 2
      @battleback_sprite.oy = @battleback_sprite.bitmap.height / 4
    else
      @battleback_sprite.src_rect.set(0, 0, @battleback_sprite.bitmap.width,
                                      @battleback_sprite.bitmap.height)
      @base_zoom = 1.0
      @battleback_sprite.zoom_x = @base_zoom
      @battleback_sprite.zoom_y = @base_zoom
      @battleback_sprite.x = 320
      @battleback_sprite.y = 0
      @battleback_sprite.ox = @battleback_sprite.bitmap.width / 2
      @battleback_sprite.oy = @battleback_sprite.bitmap.height / 4
    end
  end
  #--------------------------------------------------------------------------
  # * Position enlargement ratio setting of scroll goal of picture
  #--------------------------------------------------------------------------
  def screen_target(x, y, zoom)
    return unless $scene.drive
    @wait = $scene.scroll_time
    @target_x = x
    @target_y = y
    @target_zoom = zoom
    screen_over
    @gap_x = @target_x - @real_x
    @gap_y = @target_y - @real_y
    @gap_zoom = @target_zoom - @real_zoom
  end
  #--------------------------------------------------------------------------
  # * Scroll of picture
  #--------------------------------------------------------------------------
  def screen_scroll
    if @wait > 0
      @real_x = @target_x - @gap_x * (@wait ** 2) / ($scene.scroll_time ** 2)
      @real_y = @target_y - @gap_y * (@wait ** 2) / ($scene.scroll_time ** 2)
      @real_zoom = @target_zoom -
                    @gap_zoom * (@wait ** 2) / ($scene.scroll_time ** 2)
      @battleback_sprite.x = 320 + @real_x
      @battleback_sprite.y = @real_y
      @battleback_sprite.zoom_x = @base_zoom * @real_zoom
      @battleback_sprite.zoom_y = @base_zoom * @real_zoom
      @battleback_sprite.ox = @battleback_sprite.bitmap.width / 2
      @battleback_sprite.oy = @battleback_sprite.bitmap.height / 4
      @wait -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * When the screen goes outside the picture, revision processing
  #--------------------------------------------------------------------------
  def screen_over
    width = @battleback_sprite.bitmap.width * @base_zoom * @target_zoom / 2
    unless 324 + @target_x > width and 324 - @target_x > width
      if 324 + @target_x > width
        @target_x = width - 324
      elsif 324 - @target_x > width
        @target_x = 324 - width
      end
    end
    height = @battleback_sprite.bitmap.height * @base_zoom * @target_zoom / 4
    unless @target_y > height - 4 and 484 - @target_y > 3 * height
      if @target_y > height - 4
        @target_y = height - 4
      elsif 484 - @target_y > 3 * height
        @target_y = 484 - 3 * height
      end
    end
  end
end

#==============================================================================
# ** Game_Battler (Part 1)
#------------------------------------------------------------------------------
# 　It is the class which handles the battler. This class is used as superclass 
#  of Game_Actor class and Game_Enemy クラ ス.
#==============================================================================

class Game_Battler
  #--------------------------------------------------------------------------
  # * Release instance variable addition
  #--------------------------------------------------------------------------
  attr_accessor :up_level                  # The frequency of levelling up
  attr_accessor :at                        # AT (time gauge)
  attr_accessor :atp                       # AT (for indication)
  attr_accessor :rt                        # RP (permanent residence gauge)
  attr_accessor :rtp                       # RP (permanent residence necessary quantity)
  attr_accessor :spell                     # In the midst of synthesis skill motion
  attr_accessor :recover_hp                # HP recovery quantity
  attr_accessor :recover_sp                # SP recovery quantity
  attr_accessor :state_p                   # Status abnormal arrangement
  attr_accessor :state_m                   # Status abnormal arrangement
  attr_accessor :damage_sp                 # SP damage indicatory flag
  attr_accessor :animation                 # Arrangement of animation ID and Hit
  attr_accessor :phase
  attr_accessor :wait
  attr_accessor :target
  attr_accessor :anime1
  attr_accessor :anime2
  attr_accessor :event
  #--------------------------------------------------------------------------
  # * Object initialization
  #--------------------------------------------------------------------------
  alias :initialize_rtab :initialize
  def initialize
    initialize_rtab
    @damage_pop = {}
    @damage = {}
    @damage_sp = {}
    @critical = {}
    @recover_hp = {}
    @recover_sp = {}
    @state_p = {}
    @state_m = {}
    @animation = []
    @phase = 1
    @wait = 0
    @target = []
    @anime1 = 0
    @anime2 = 0
    @event = 0
  end
  #--------------------------------------------------------------------------
  # * Existence decision
  #--------------------------------------------------------------------------
  def exist?
    return (not @hidden and (@hp > 0 or @immortal or @damage.size > 0))
  end
  #--------------------------------------------------------------------------
  # * Remaining HP estimate
  #--------------------------------------------------------------------------
  def rest_hp
    # Substituting reality HP to rest_hp
    rest_hp = @hp
    # All damage which the battler receives is made to reflect on rest_hp
    for pre_damage in @damage
      if pre_damage[1].is_a?(Numeric)
        rest_hp -= pre_damage[1]
      end
    end
    return rest_hp
  end
  #--------------------------------------------------------------------------
  # * Cancellation of state
  #     state_id : State ID
  #     force    : Forced cancellation flag (with processing of automatic state use)
  #--------------------------------------------------------------------------
  def remove_state(state_id, force = false)
    # When this state is added,
    if state?(state_id)
      # When with the state which it is forced is added, at the same time cancellation is not forcing
      if @states_turn[state_id] == -1 and not force
        # Method end
        return
      end
      # When present HP 0 and option [ the state of HP 0 you regard ] it is valid
      if @hp == 0 and $data_states[state_id].zero_hp
        # Whether or not [ you regard the state of HP 0 ] there is a state in other things, decision
        zero_hp = false
        for i in @states
          if i != state_id and $data_states[i].zero_hp
            zero_hp = true
          end
        end
        # If you are possible to cancel aggressive failure, HP in 1 modification
        if zero_hp == false
          @hp = 1
        end
      end
      unless self.movable?
        # Deleting state ID from @states arrangement and @states_turn hash
        @states.delete(state_id)
        @states_turn.delete(state_id)
        if self.movable?
          self.at = 0
        end
      else
        # Deleting state ID from @states arrangement and @states_turn hash
        @states.delete(state_id)
        @states_turn.delete(state_id)
      end
    end
    # The maximum check of HP and SP
    @hp = [@hp, self.maxhp].min
    @sp = [@sp, self.maxsp].min
  end
  #--------------------------------------------------------------------------
  # * Effective application of normality attack
  #     attacker : Attack person (battler)
  #--------------------------------------------------------------------------
  def attack_effect(attacker)
    # Clearing the critical flag
    self.critical[attacker] = false
    state_p[attacker] = []
    state_m[attacker] = []
    # First on-target hit decision
    hit_result = (rand(100) < attacker.hit)
    # In case of on-target hit
    hit_result = true
    if hit_result == true
      # Calculating the basic damage
      atk = [attacker.atk - self.pdef / 2, 0].max
      self.damage[attacker] = atk * (20 + attacker.str) / 20
      # Attribute correction
      self.damage[attacker] *= elements_correct(attacker.element_set)
      self.damage[attacker] /= 100
      # When the mark of the damage is correct,
      if self.damage[attacker] > 0
        # Critical correction
        if rand(100) < 4 * attacker.dex / self.agi
          self.damage[attacker] *= 2
          self.critical[attacker] = true
        end
        # Defense correction
        if self.guarding?
          self.damage[attacker] /= 2
        end
      end
      # Dispersion
      if self.damage[attacker].abs > 0
        amp = [self.damage[attacker].abs * 15 / 100, 1].max
        self.damage[attacker] += rand(amp+1) + rand(amp+1) - amp
      end
      # Second on-target hit decision
      eva = 8 * self.agi / attacker.dex + self.eva
      hit = self.damage[attacker] < 0 ? 100 : 100 - eva
      hit = self.cant_evade? ? 100 : hit
      hit_result = (rand(100) < hit)
    end
    # In case of on-target hit
    if hit_result == true
      # State shocking cancellation
      remove_states_shock
      # From HP damage subtraction
      # State change
      @state_changed = false
      states_plus(attacker, attacker.plus_state_set)
      states_minus(attacker, attacker.minus_state_set)
    # In case of miss
    else
      # Setting "Miss" to the damage
      self.damage[attacker] = "Miss"
      # Clearing the critical flag
      self.critical[attacker] = false
    end
    # Method end
    return true
  end
  #--------------------------------------------------------------------------
  # * Effective application of skill
  #     user  : User of skill (battler)
  #     skill : Skill
  #--------------------------------------------------------------------------
  def skill_effect(user, skill)
    # Clearing the critical flag
    self.critical[user] = false
    state_p[user] = []
    state_m[user] = []
    # Effective range of skill with friend of HP 1 or more, your own HP 0,
    # Or when the effective range of skill with the friend of HP 0, your own HP are 1 or more
    if ((skill.scope == 3 or skill.scope == 4) and self.hp == 0) or
       ((skill.scope == 5 or skill.scope == 6) and self.hp >= 1)
      # Method end
      return false
    end
    # Clearing the effective flag
    effective = false
    # When common event ID is valid setting the effective flag
    effective |= skill.common_event_id > 0
    # First on-target hit decision
    hit = skill.hit
    if skill.atk_f > 0
      hit *= user.hit / 100
    end
    hit_result = (rand(100) < hit)
    # In case of uncertain skill setting the effective flag
    effective |= hit < 100
    # In case of on-target hit
    if hit_result == true
      # Calculating power
      power = skill.power + user.atk * skill.atk_f / 100
      if power > 0
        power -= self.pdef * skill.pdef_f / 200
        power -= self.mdef * skill.mdef_f / 200
        power = [power, 0].max
      end
      # Calculating magnification ratio
      rate = 20
      rate += (user.str * skill.str_f / 100)
      rate += (user.dex * skill.dex_f / 100)
      rate += (user.agi * skill.agi_f / 100)
      rate += (user.int * skill.int_f / 100)
      # Calculating the basic damage
      self.damage[user] = power * rate / 20
      # Attribute correction
      self.damage[user] *= elements_correct(skill.element_set)
      self.damage[user] /= 100
      # When the mark of the damage is correct
      if self.damage[user] > 0
        # Defense correction
        if self.guarding?
          self.damage[user] /= 2
        end
      end
      # Dispersion
      if skill.variance > 0 and self.damage[user].abs > 0
        amp = [self.damage[user].abs * skill.variance / 100, 1].max
        self.damage[user] += rand(amp+1) + rand(amp+1) - amp
      end
      # Second on-target hit decision
      eva = 8 * self.agi / user.dex + self.eva
      hit = self.damage[user] < 0 ? 100 : 100 - eva * skill.eva_f / 100
      hit = self.cant_evade? ? 100 : hit
      hit_result = (rand(100) < hit)
      # In case of uncertain skill setting the effective flag
      effective |= hit < 100
    end
    # In case of on-target hit
    if hit_result == true
      # In case of physical attack other than power 0
      if skill.power != 0 and skill.atk_f > 0
        # State shocking cancellation
        remove_states_shock
        # Setting the effective flag
        effective = true
      end
      # The fluctuation decision of HP
      last_hp = [[self.hp - self.damage[user], self.maxhp].min, 0].max      # Effective decision
      effective |= self.hp != last_hp
      # State change
      @state_changed = false
      effective |= states_plus(user, skill.plus_state_set)
      effective |= states_minus(user, skill.minus_state_set)
      unless $game_temp.in_battle
        self.damage_effect(user, 1)
      end
      # When power 0 is,
      if skill.power == 0
        # Setting the null line to the damage
        self.damage[user] = ""
        # When there is no change in the state,
        unless @state_changed
          # Setting "Miss" to the damage
          self.damage[user] = "Miss"
        end
      end
    # In case of miss
    else
      # Setting "Miss" to the damage
      self.damage[user] = "Miss"
    end
    # When it is not in the midst of fighting,
    unless $game_temp.in_battle
      # Setting nil to the damage
      self.damage[user] = nil
    end
    # Method end
    return effective
  end
  #--------------------------------------------------------------------------
  # * Effective application of item
  #     item : Item
  #--------------------------------------------------------------------------
  def item_effect(item, user = $game_party.actors[0])
    # Clearing the critical flag
    self.critical[user] = false
    state_p[user] = []
    state_m[user] = []
    self.recover_hp[user] = 0
    self.recover_sp[user] = 0
    # Effective range of item with friend of HP 1 or more, your own HP 0,
    # Or when the effective range of the item with the friend of HP 0, your own HP are 1 or more,
    if ((item.scope == 3 or item.scope == 4) and self.hp == 0) or
       ((item.scope == 5 or item.scope == 6) and self.hp >= 1)
      # Method end
      return false
    end
    # Clearing the effective flag
    effective = false
    # When common event ID is valid setting the effective flag
    effective |= item.common_event_id > 0
    # On-target hit decision
    hit_result = (rand(100) < item.hit)
    # In case of uncertain skill setting the effective flag
    effective |= item.hit < 100
    # In case of on-target hit
    if hit_result == true
      # Calculating the recovery quantity
      self.recover_hp[user] = maxhp * item.recover_hp_rate / 100 +
                              item.recover_hp
      self.recover_sp[user] = maxsp * item.recover_sp_rate / 100 +
                              item.recover_sp
      if self.recover_hp[user] < 0
        self.recover_hp[user] += self.pdef * item.pdef_f / 20
        self.recover_hp[user] += self.mdef * item.mdef_f / 20
        self.recover_hp[user] = [self.recover_hp[user], 0].min
      end
      # Attribute correction
      self.recover_hp[user] *= elements_correct(item.element_set)
      self.recover_hp[user] /= 100
      self.recover_sp[user] *= elements_correct(item.element_set)
      self.recover_sp[user] /= 100
      # Dispersion
      if item.variance > 0 and self.recover_hp[user].abs > 0
        amp = [self.recover_hp[user].abs * item.variance / 100, 1].max
        self.recover_hp[user] += rand(amp+1) + rand(amp+1) - amp
      end
      if item.variance > 0 and self.recover_sp[user].abs > 0
        amp = [self.recover_sp[user].abs * item.variance / 100, 1].max
        self.recover_sp[user] += rand(amp+1) + rand(amp+1) - amp
      end
      # When the mark of the recovery quantity is negative number
      if self.recover_hp[user] < 0
        # Defense correction
        if self.guarding?
          self.recover_hp[user] /= 2
        end
      end
      # The mark of the HP recovery quantity it reverses, sets to the value of the damage
      self.damage[user] = -self.recover_hp[user]
      # The fluctuation decision of HP and SP
      last_hp = [[self.hp + self.recover_hp[user], self.maxhp].min, 0].max
      last_sp = [[self.sp + self.recover_sp[user], self.maxsp].min, 0].max
      effective |= self.hp != last_hp
      effective |= self.sp != last_sp
      # State change
      @state_changed = false
      effective |= states_plus(user, item.plus_state_set)
      effective |= states_minus(user, item.minus_state_set)
      unless $game_temp.in_battle
        self.damage_effect(user, 2)
      end
      # When parameter rise value is valid
      if item.parameter_type > 0 and item.parameter_points != 0
        # It diverges with parameter
        case item.parameter_type
        when 1  # MaxHP
          @maxhp_plus += item.parameter_points
        when 2  # MaxSP
          @maxsp_plus += item.parameter_points
        when 3  #Strength
          @str_plus += item.parameter_points
        when 4  # Dexterity
          @dex_plus += item.parameter_points
        when 5  # Agility
          @agi_plus += item.parameter_points
        when 6  # Intelligence
          @int_plus += item.parameter_points
        end
        # Setting the effective flag
        effective = true
      end
      # When HP recovery factor and the recovery quantity 0 is
      if item.recover_hp_rate == 0 and item.recover_hp == 0
        # Setting the null line to the damage
        self.damage[user] = ""
        # When SP recovery factor and the recovery quantity 0, parameter rise value is invalid,
        if item.recover_sp_rate == 0 and item.recover_sp == 0 and
           (item.parameter_type == 0 or item.parameter_points == 0)
          # When there is no change in the state,
          unless @state_changed
            # Setting "Miss" to the damage
            self.damage[user] = "Miss"
          end
        end
      end
    # In case of miss
    else
      # Setting "Miss" to the damage
      self.damage[user] = "Miss"
    end
    # When it is not in the midst of fighting,
    unless $game_temp.in_battle
      # Setting nil to the damage
      self.damage[user] = nil
    end
    # Method end
    return effective
  end
  #--------------------------------------------------------------------------
  # * State change (+) application
  #     plus_state_set  : State change (+)
  #--------------------------------------------------------------------------
  def states_plus(battler, plus_state_set)
    # Clearing the effective flag
    effective = false
    # The loop (the state which is added)
    for i in plus_state_set
      # When this state is not defended,
      unless self.state_guard?(i)
        # If this state is not full, setting the effective flag
        effective |= self.state_full?(i) == false
        # When the state [ it does not resist ] is,
        if $data_states[i].nonresistance
          # Setting the state change flag
          @state_changed = true
          # Adding the state
          self.state_p[battler].push(i)
        # When this state is not full,
        elsif self.state_full?(i) == false
          # It converts degree of state validity to probability, compares with random number
          if rand(100) < [0,100,80,60,40,20,0][self.state_ranks[i]]
            # Setting the state change flag
            @state_changed = true
            # Adding the state
            self.state_p[battler].push(i)
          end
        end
      end
    end
    # Method end
    return effective
  end
  #--------------------------------------------------------------------------
  # * State change (-) application
  #     minus_state_set : State change (-)
  #--------------------------------------------------------------------------
  def states_minus(battler, minus_state_set)
    # Clearing the effective flag
    effective = false
    # The loop (the state which is cancelled)
    for i in minus_state_set
      # If this state is added, setting the effective flag
      effective |= self.state?(i)
      # Setting the state change flag
      @state_changed = true
      # Cancelling the state
      self.state_m[battler].push(i)
    end
    # Method end
    return effective
  end
  #--------------------------------------------------------------------------
  # * Damage operation
  #--------------------------------------------------------------------------
  def damage_effect(battler, item)
    if item == 2
      self.hp += self.recover_hp[battler]
      self.sp += self.recover_sp[battler]
      if self.recover_sp[battler] != 0
        self.damage_sp[battler] = -self.recover_sp[battler]
      end
      self.recover_hp.delete(battler)
      self.recover_sp.delete(battler)
    else
      if self.damage[battler].class != String
        self.hp -= self.damage[battler]
      end
    end
    for i in self.state_p[battler]
      add_state(i)
    end
    for i in self.state_m[battler]
      remove_state(i)
    end
  end
  #--------------------------------------------------------------------------
  # * Effective application of slip damage
  #--------------------------------------------------------------------------
  def slip_damage_effect
    # Setting the damage
    self.damage["slip"] = self.maxhp / 10
    # Dispersion
    if self.damage["slip"].abs > 0
      amp = [self.damage["slip"].abs * 15 / 100, 1].max
      self.damage["slip"] += rand(amp+1) + rand(amp+1) - amp
    end
    # From HP damage subtraction
    self.hp -= self.damage["slip"]
    # Method end
    return true
  end
end

#==============================================================================
# ** Game_BattleAction
#------------------------------------------------------------------------------
# 　Action (the conduct which is in the midst of fighting) it is the class which
#  is handled. This class is used inside Game_Battler クラ ス.
#==============================================================================

class Game_BattleAction
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :spell_id                 # Skill ID for union magic
  attr_accessor :force_kind               # Classification (basis/skill/item)
  attr_accessor :force_basic              # basis (attack/defend/escape)
  attr_accessor :force_skill_id           # Skill ID
  #--------------------------------------------------------------------------
  # * Validity decision
  #--------------------------------------------------------------------------
  def valid?
    return (not (@force_kind == 0 and @force_basic == 3))
  end
end

#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
# 　It is the class which handles the actor. This class Game_Actors class 
#  ($game_actors) is used in inside, Game_Party class ($game_party) from is
#  referred to.
#==============================================================================

class Game_Actor < Game_Battler
  def skill_can_use?(skill_id)
    return super
  end
end

#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
# 　It is the class which handles the enemy. This class Game_Troop class
#  ($game_troop) is used in inside.
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :height                  # Height of picture
  attr_accessor :real_x                  # X-coordinate revision
  attr_accessor :real_y                  # Y-coordinate revision
  attr_accessor :real_zoom               # Enlargement ratio
  #--------------------------------------------------------------------------
  # * Object initialization
  #     troop_id     :Troop ID
  #     member_index : Index of troop member
  #--------------------------------------------------------------------------
  def initialize(troop_id, member_index)
    super()
    @troop_id = troop_id
    @member_index = member_index
    troop = $data_troops[@troop_id]
    @enemy_id = troop.members[@member_index].enemy_id
    enemy = $data_enemies[@enemy_id]
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    @hp = maxhp
    @sp = maxsp
    @real_x = 0
    @real_y = 0
    @real_zoom = 1.0
    @fly = 0
    enemy.name.sub(/\\[Ff]\[([0-9]+)\]/) {@fly = $1.to_i}
    @hidden = troop.members[@member_index].hidden
    @immortal = troop.members[@member_index].immortal
  end
  alias :true_x :screen_x
  alias :true_y :screen_y
  #--------------------------------------------------------------------------
  # * Acquisition in battle picture X coordinate
  #--------------------------------------------------------------------------
  def screen_x
    return 320 + (true_x - 320) * @real_zoom + @real_x
  end
  #--------------------------------------------------------------------------
  # * Acquisition in battle picture Y coordinate
  #--------------------------------------------------------------------------
  def screen_y
    return true_y * @real_zoom + @real_y
  end
  #--------------------------------------------------------------------------
  # * Acquisition in battle picture Z coordinate
  #--------------------------------------------------------------------------
  def screen_z
    return true_y + @fly
  end
  #--------------------------------------------------------------------------
  # * Acquisition of battle picture enlargement ratio
  #--------------------------------------------------------------------------
  def zoom
    return ($scene.zoom_rate[1] - $scene.zoom_rate[0]) *
                          (true_y + @fly) / 320 + $scene.zoom_rate[0]
  end
  #--------------------------------------------------------------------------
  # * For attack and acquisition in battle picture X coordinate
  #--------------------------------------------------------------------------
  def attack_x(z)
    return (320 - true_x) * z * 0.75
  end
  #--------------------------------------------------------------------------
  # * For attack and acquisition of battle picture Y-coordinate
  #--------------------------------------------------------------------------
  def attack_y(z)
    return (160 - (true_y + @fly / 4) * z + @height * zoom * z / 2) * 0.75
  end
  #--------------------------------------------------------------------------
  # * Action compilation
  #--------------------------------------------------------------------------
  def make_action
    # Clearing current action
    self.current_action.clear
    # When it cannot move,
    unless self.inputable?
      # Method end
      return
    end
    # Presently extracting effective action
    available_actions = []
    rating_max = 0
    for action in self.actions
      # Turn conditional verification
      n = $game_temp.battle_turn
      a = action.condition_turn_a
      b = action.condition_turn_b
      if (b == 0 and n != a) or
         (b > 0 and (n < 1 or n < a or n % b != a % b))
        next
      end
      # HP conditional verification
      if self.hp * 100.0 / self.maxhp > action.condition_hp
        next
      end
      # Level conditional verification
      if $game_party.max_level < action.condition_level
        next
      end
      # Switch conditional verification
      switch_id = action.condition_switch_id
      if switch_id > 0 and $game_switches[switch_id] == false
        next
      end
      # Skill active conditional verification
      if action.kind == 1
        unless self.skill_can_use?(action.skill_id)
          next
        end
      end
      # It corresponds to condition : Adding this action
      available_actions.push(action)
      if action.rating > rating_max
        rating_max = action.rating
      end
    end
    # Maximum rating value as 3 total calculation (as for 0 or less exclusion)
    ratings_total = 0
    for action in available_actions
      if action.rating > rating_max - 3
        ratings_total += action.rating - (rating_max - 3)
      end
    end
    # When total of rating 0 is not,
    if ratings_total > 0
      # Drawing up random number
      value = rand(ratings_total)
      # Setting those which correspond to the random number which it drew up to current action
      for action in available_actions
        if action.rating > rating_max - 3
          if value < action.rating - (rating_max - 3)
            self.current_action.kind = action.kind
            self.current_action.basic = action.basic
            self.current_action.skill_id = action.skill_id
            self.current_action.decide_random_target_for_enemy
            return
          else
            value -= action.rating - (rating_max - 3)
          end
        end
      end
    end
  end
end

#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
# 　It is the class which handles the party. Information of the gold and the
#  item etc. is included. Instance of this ク lath is referred to being 
#  $game_party.
#==============================================================================

class Game_Party
  #--------------------------------------------------------------------------
  # * Total destruction decision
  #--------------------------------------------------------------------------
  def all_dead?
    # When party number of people 0 is
    if $game_party.actors.size == 0
      return false
    end
    # When the actor of HP 0 or more is in the party,
    for actor in @actors
      if actor.rest_hp > 0
        return false
      end
    end
    # Total destruction
    return true
  end
  #--------------------------------------------------------------------------
  # * Random of object actor decision
  #     hp0 : Limits to the actor of HP 0
  #--------------------------------------------------------------------------
  # Original target decisive routine smooth_target_actor_rtab and name modification
  alias :random_target_actor_rtab :random_target_actor
  def random_target_actor(hp0 = false)
    # Initializing the roulette
    roulette = []
    # Loop
    for actor in @actors
      # When it corresponds to condition
      if (not hp0 and actor.exist? and actor.rest_hp > 0) or
          (hp0 and actor.hp0?)
        # Acquiring the [ position ] of class of actor
        position = $data_classes[actor.class_id].position
        # At the time of avant-garde n = 4、At the time of medium defense n = 3、At the time rear guard n = 2
        n = 4 - position
        # In roulette actor n time addition
        n.times do
          roulette.push(actor)
        end
      end
    end
    # When size of the roulette 0 is
    if roulette.size == 0
      return random_target_actor_rtab(hp0)
    end
    # It turns the roulette, deciding the actor
    return roulette[rand(roulette.size)]
  end
  #--------------------------------------------------------------------------
  # * Smooth decision of object actor
  #     actor_index : actor index
  #--------------------------------------------------------------------------
  # Original target decisive routine smooth_target_actor_rtab and name modification
  alias :smooth_target_actor_rtab :smooth_target_actor
  def smooth_target_actor(actor_index)
    # Acquiring the actor
    actor = @actors[actor_index]
    # When the actor exists
    if actor != nil and actor.exist? and actor.rest_hp > 0
      return actor
    end
    # Loop
    for actor in @actors
      # When the actor exists
      if actor.exist? and actor.rest_hp > 0
        return actor
      end
    end
    # When friend has destroyed, original target decisive routine is executed
    return smooth_target_actor_rtab(actor_index)
  end
end

#==============================================================================
# ** Game_Troop
#------------------------------------------------------------------------------
# 　It is the class which handles the troop. As for instance of this class with
#  $game_troop reference the れ it increases.
#==============================================================================

class Game_Troop
  #--------------------------------------------------------------------------
  # * Random of object enemy decision
  #     hp0 : It limits to the enemy of HP 0
  #--------------------------------------------------------------------------
  # Original target decisive routine random_target_enemy_rtab and name modification
  alias :random_target_enemy_rtab :random_target_enemy
  def random_target_enemy(hp0 = false)
    # Initializing the roulette
    roulette = []
    # Loop
    for enemy in @enemies
      # When it corresponds to condition,
      if (not hp0 and enemy.exist? and enemy.rest_hp > 0) or
          (hp0 and enemy.hp0?)
        # Adding the enemy to the roulette
        roulette.push(enemy)
      end
    end
    # When size of the roulette 0 is,
    if roulette.size == 0
      return random_target_enemy_rtab(hp0)
    end
    # It turns the roulette, deciding the enemy
    return roulette[rand(roulette.size)]
  end
  #--------------------------------------------------------------------------
  # * Smooth decision of object enemy
  #     enemy_index : enemy index
  #--------------------------------------------------------------------------
  # Original target decisive routine smooth_target_enemy_rtab and name modification
  alias :smooth_target_enemy_rtab :smooth_target_enemy
  def smooth_target_enemy(enemy_index)
    # Acquiring the enemy
    enemy = @enemies[enemy_index]
    # When the enemy exists,
    if enemy != nil and enemy.exist? and enemy.rest_hp > 0
      return enemy
    end
    # Loop
    for enemy in @enemies
      # When the enemy exists,
      if enemy.exist? and enemy.rest_hp > 0
        return enemy
      end
    end
    # When the enemy has destroyed, it searches the enemy for the second time
    return smooth_target_enemy_rtab(enemy_index)
  end
end

#==============================================================================
# ** Sprite_Battler
#------------------------------------------------------------------------------
# 　It is sprite for battler indication. Instance of Game_Battler class is watched,
#  state of sprite changes automatically.
#==============================================================================

class Sprite_Battler < RPG::Sprite 
  #--------------------------------------------------------------------------
  # * Frame Renewal
  #--------------------------------------------------------------------------
  def update
    super
    # When the battler is nil
    if @battler == nil
      self.bitmap = nil
      loop_animation(nil)
      return
    end
    # When file name or hue differs from present ones
    if @battler.battler_name != @battler_name or
       @battler.battler_hue != @battler_hue
      # To acquire bitmap, setting
      @battler_name = @battler.battler_name
      @battler_hue = @battler.battler_hue
      self.bitmap = RPG::Cache.battler(@battler_name, @battler_hue)
      @width = bitmap.width
      @height = bitmap.height
      self.ox = @width / 2
      self.oy = @height
      if @battler.is_a?(Game_Enemy)
        @battler.height = @height
      end
      # Aggressive failure or it hides and if state it designates opacity as 0
      if @battler.dead? or @battler.hidden
        self.opacity = 0
      end
    end
    # When animation ID differs from present ones
    if @battler.state_animation_id != @state_animation_id
      @state_animation_id = @battler.state_animation_id
      loop_animation($data_animations[@state_animation_id])
    end
    # In case of the actor whom it should indicate 
    if @battler.is_a?(Game_Actor) and @battler_visible
      # When being main phase, opacity is lowered a little
      if $game_temp.battle_main_phase
        self.opacity += 3 if self.opacity < 255
      else
        self.opacity -= 3 if self.opacity > 207
      end
    end
    # Blinking
    if @battler.blink
      blink_on
    else
      blink_off
    end
    # In case of invisibility
    unless @battler_visible
      # Appearance
      if not @battler.hidden and not @battler.dead? and
         (@battler.damage.size < 2 or @battler.damage_pop.size < 2)
        appear
        @battler_visible = true
      end
    end
    # Damage
    for battler in @battler.damage_pop
      if battler[0].class == Array
        if battler[0][1] >= 0
          $scene.skill_se
        else
          $scene.levelup_se
        end
        damage(@battler.damage[battler[0]], false, 2)
      else
        damage(@battler.damage[battler[0]], @battler.critical[battler[0]])
      end
      if @battler.damage_sp.include?(battler[0])
        damage(@battler.damage_sp[battler[0]],
                @battler.critical[battler[0]], 1)
        @battler.damage_sp.delete(battler[0])
      end 
      @battler.damage_pop.delete(battler[0])
      @battler.damage.delete(battler[0])
      @battler.critical.delete(battler[0])
    end
    # When it is visible
    if @battler_visible
      # Flight
      if @battler.hidden
        $game_system.se_play($data_system.escape_se)
        escape
        @battler_visible = false
      end
      # White Flash
      if @battler.white_flash
        whiten
        @battler.white_flash = false
      end
      # Animation
      unless @battler.animation.empty?
        for animation in @battler.animation.reverse
          animation($data_animations[animation[0]], animation[1])
          @battler.animation.delete(animation)
        end
      end
      # Collapse
      if @battler.damage.empty? and @battler.dead?
        if $scene.dead_ok?(@battler)
          if @battler.is_a?(Game_Enemy)
            $game_system.se_play($data_system.enemy_collapse_se)
          else
            $game_system.se_play($data_system.actor_collapse_se)
          end
          collapse
          @battler_visible = false
        end
      end
    end
    # Setting the coordinate of sprite
    self.x = @battler.screen_x
    self.y = @battler.screen_y
    self.z = @battler.screen_z
    if @battler.is_a?(Game_Enemy)
      self.zoom_x = @battler.real_zoom * @battler.zoom
      self.zoom_y = @battler.real_zoom * @battler.zoom
    end
  end
end

#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
# 　It is superclass of all windows in the game.
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Drawing of gauge
  #--------------------------------------------------------------------------
  def gauge_rect_at(width, height, align3,
                    color1, color2, color3, color4, color5, color6, color7,
                    color8, color9, color10, color11, color12, grade1, grade2)
    # Framework drawing
    @at_gauge = Bitmap.new(width, height * 5)
    @at_gauge.fill_rect(0, 0, width, height, color1)
    @at_gauge.fill_rect(1, 1, width - 2, height - 2, color2)
    if (align3 == 1 and grade1 == 0) or grade1 > 0
      color = color3
      color3 = color4
      color4 = color
    end
    if (align3 == 1 and grade2 == 0) or grade2 > 0
      color = color5
      color5 = color6
      color6 = color
      color = color7
      color7 = color8
      color8 = color
      color = color9
      color9 = color10
      color10 = color
      color = color11
      color11 = color12
      color12 = color
    end
    if align3 == 0
      if grade1 == 2
        grade1 = 3
      end
      if grade2 == 2
        grade2 = 3
      end
    end
    # Drawing vertically of empty gauge gradation indication
    @at_gauge.gradation_rect(2, 2, width - 4, height - 4,
                                  color3, color4, grade1)
    # Drawing of actual gauge
    @at_gauge.gradation_rect(2, height + 2, width- 4, height - 4,
                                  color5, color6, grade2)
    @at_gauge.gradation_rect(2, height * 2 + 2, width- 4, height - 4,
                                  color7, color8, grade2)
    @at_gauge.gradation_rect(2, height * 3 + 2, width- 4, height - 4,
                                  color9, color10, grade2)
    @at_gauge.gradation_rect(2, height * 4 + 2, width- 4, height - 4,
                                  color11, color12, grade2)
  end
end

#==============================================================================
# ** Window_Help
#------------------------------------------------------------------------------
# 　It is the window which indicates the item description the skill and the
#  status etc. of the actor.
#==============================================================================

class Window_Help < Window_Base
  #--------------------------------------------------------------------------
  # * Enemy Setting
  #     enemy : The enemy which indicates name and the state
  #--------------------------------------------------------------------------
  def set_enemy(enemy)
    text = enemy.name.sub(/\\[Ff]\[([0-9]+)\]/) {""}
    state_text = make_battler_state_text(enemy, 112, false)
    if state_text != ""
      text += "  " + state_text
    end
    set_text(text, 1)
  end
end

#==============================================================================
# ** Window_BattleStatus
#------------------------------------------------------------------------------
# 　It is the window which indicates the status of the party member in the 
#  battle picture.
#==============================================================================

class Window_BattleStatus < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    x = (4 - $game_party.actors.size) * 80
    width = $game_party.actors.size * 160
    super(x, 320, width, 160)
    self.back_opacity = 160
    @actor_window = []
    for i in 0...$game_party.actors.size
      @actor_window.push(Window_ActorStatus.new(i, x + i * 160))
    end
    @level_up_flags = [false, false, false, false]
    refresh
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    for window in @actor_window
      window.dispose
    end
    super
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh(number = 0)    if number == 0
      cnt = 0
      for window in @actor_window
        window.refresh(@level_up_flags[cnt])
        cnt += 1
      end
    else
      @actor_window[number - 1].refresh(@level_up_flags[number - 1])
    end
  end
  #--------------------------------------------------------------------------
  # * AT gauge refreshment
  #--------------------------------------------------------------------------
  def at_refresh(number = 0)
    if number == 0
      for window in @actor_window
        window.at_refresh
      end
    else
      @actor_window[number - 1].at_refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Renewal
  #--------------------------------------------------------------------------
  def update
    super
    if self.x != (4 - $game_party.actors.size) * 80
      self.x = (4 - $game_party.actors.size) * 80
      self.width = $game_party.actors.size * 160
      for window in @actor_window
        window.dispose
      end
      @actor_window = []
      for i in 0...$game_party.actors.size
        @actor_window.push(Window_ActorStatus.new(i, x + i * 160))
      end
      refresh
    end
    for window in @actor_window
      window.update
    end
  end
end

#==============================================================================
# ** Window_ActorStatus
#------------------------------------------------------------------------------
# 　It is the window which indicates the status of the party member respectively
#  in the battle picture.
#==============================================================================

class Window_ActorStatus < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(id, x)
    @actor_num = id
    super(x, 320, 160, 160)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.opacity = 0
    self.back_opacity = 0
    actor = $game_party.actors[@actor_num]
    @actor_nm = actor.name
    @actor_mhp = actor.maxhp
    @actor_msp = actor.maxsp
    @actor_hp = actor.hp
    @actor_sp = actor.sp
    @actor_st = make_battler_state_text(actor, 120, true)
    @status_window = []
    for i in 0...5
      @status_window.push(Window_DetailsStatus.new(actor, i, x))
    end
    refresh(false)
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    for i in 0...5
      @status_window[i].dispose
    end
    super
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh(level_up_flags)
    self.contents.clear
    actor = $game_party.actors[@actor_num]
    @status_window[0].refresh(actor) if @actor_nm != actor.name
    @status_window[1].refresh(actor) if
      @actor_mhp != actor.maxhp or @actor_hp != actor.hp
    @status_window[2].refresh(actor) if
      @actor_msp != actor.maxsp or @actor_sp != actor.sp
    @status_window[3].refresh(actor, level_up_flags) if
      @actor_st != make_battler_state_text(actor, 120, true) or level_up_flags
    @actor_nm = actor.name
    @actor_mhp = actor.maxhp
    @actor_msp = actor.maxsp
    @actor_hp = actor.hp
    @actor_sp = actor.sp
    @actor_st = make_battler_state_text(actor, 120, true)
  end
  #--------------------------------------------------------------------------
  # * AT gauge refreshment
  #--------------------------------------------------------------------------
  def at_refresh
    @status_window[4].refresh($game_party.actors[@actor_num])
  end
  #--------------------------------------------------------------------------
  # * Frame Renewal
  #--------------------------------------------------------------------------
  def update
    for window in @status_window
      window.update
    end
  end
end

#==============================================================================
# ** Window_DetailsStatus
#------------------------------------------------------------------------------
# 　It is the window which indicates the status of the actor in individually in the battle picture.
#==============================================================================

class Window_DetailsStatus < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(actor, id, x)
    @status_id = id
    super(x, 320 + id * 26, 160, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.opacity = 0
    self.back_opacity = 0
    refresh(actor, false)
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    super
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh(actor, level_up_flags = false)
    self.contents.clear
    case @status_id
    when 0
      draw_actor_name(actor, 4, 0)
    when 1
      draw_actor_hp(actor, 4, 0, 120)
    when 2
      draw_actor_sp(actor, 4, 0, 120)
    when 3
      if level_up_flags
        self.contents.font.color = normal_color
        self.contents.draw_text(4, 0, 120, 32, "LEVEL UP!")
      else
        draw_actor_state(actor, 4, 0)
      end
    when 4
      draw_actor_atg(actor, 4, 0, 120)
    end
  end
  #--------------------------------------------------------------------------
  # * Frame renewal
  #--------------------------------------------------------------------------
  def update
    #At the time of main phase opacity is lowered a little
    if $game_temp.battle_main_phase
      self.contents_opacity -= 4 if self.contents_opacity > 191
    else
      self.contents_opacity += 4 if self.contents_opacity < 255
    end
  end
end

#==============================================================================
# ** Arrow_Base
#------------------------------------------------------------------------------
# 　It is sprite for the arrow cursor indication which is used in the battle picture.
#  This class is used as superclass of Arrow_Enemy class and Arrow_Actor class.
#==============================================================================

class Arrow_Base < Sprite
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     viewport :viewport
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    self.bitmap = RPG::Cache.windowskin($game_system.windowskin_name)
    self.ox = 16
    self.oy = 32
    self.z = 2500
    @blink_count = 0
    @index = 0
    @help_window = nil
    update
  end
end

#==============================================================================
# ** Arrow_Enemy
#------------------------------------------------------------------------------
# 　It is arrow cursor in order to make the enemy select. 
#  This class succeeds Arrow_Base.
#==============================================================================

class Arrow_Enemy < Arrow_Base
  #--------------------------------------------------------------------------
  # * Frame renewal
  #--------------------------------------------------------------------------
  def update
    super
    # When it points to the enemy which does not exist, it throws
    $game_troop.enemies.size.times do
      break if self.enemy.exist?
      @index += 1
      @index %= $game_troop.enemies.size
    end
    # The cursor right
    if Input.repeat?(Input::RIGHT)
      $game_system.se_play($data_system.cursor_se)
      $game_troop.enemies.size.times do
        @index += 1
        @index %= $game_troop.enemies.size
        break if self.enemy.exist?
      end
      $scene.camera = "select"
      zoom = 1 / self.enemy.zoom
      $scene.spriteset.screen_target(self.enemy.attack_x(zoom) * 0.75,
                                      self.enemy.attack_y(zoom) * 0.75, zoom)
    end
    # The cursor left
    if Input.repeat?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      $game_troop.enemies.size.times do
        @index += $game_troop.enemies.size - 1
        @index %= $game_troop.enemies.size
        break if self.enemy.exist?
      end
      $scene.camera = "select"
      zoom = 1 / self.enemy.zoom
      $scene.spriteset.screen_target(self.enemy.attack_x(zoom) * 0.75,
                                      self.enemy.attack_y(zoom) * 0.75, zoom)
    end
    # Setting the coordinate of sprite
    if self.enemy != nil
      self.x = self.enemy.screen_x
      self.y = self.enemy.screen_y
    end
  end
end

#==============================================================================
# ** Interpreter
#------------------------------------------------------------------------------
#  It is the interpreter which executes event command. This class is used inside 
#  the Game_System class and Game_Event class.
#==============================================================================

class Interpreter
  #--------------------------------------------------------------------------
  # * Change Party Member
  #--------------------------------------------------------------------------
  def command_129
    # Acquiring the actor
    actor = $game_actors[@parameters[0]]
    # When the actor is valid
    if actor != nil
      # It diverges with operation
      if @parameters[1] == 0
        if @parameters[2] == 1
          $game_actors[@parameters[0]].setup(@parameters[0])
        end
        $game_party.add_actor(@parameters[0])
        if $game_temp.in_battle
          $game_actors[@parameters[0]].at = 0
          $game_actors[@parameters[0]].atp = 0
          $scene.spell_reset($game_actors[@parameters[0]])
          $game_actors[@parameters[0]].damage_pop = {}
          $game_actors[@parameters[0]].damage = {}
          $game_actors[@parameters[0]].damage_sp = {}
          $game_actors[@parameters[0]].critical = {}
          $game_actors[@parameters[0]].recover_hp = {}
          $game_actors[@parameters[0]].recover_sp = {}
          $game_actors[@parameters[0]].state_p = {}
          $game_actors[@parameters[0]].state_m = {}
          $game_actors[@parameters[0]].animation = []
        end
      else
        $game_party.remove_actor(@parameters[0])
      end
    end
    if $game_temp.in_battle
      $scene.status_window.update
    end
    # Continuation
    return true
  end
  #--------------------------------------------------------------------------
  # * The increase and decrease of HP
  #--------------------------------------------------------------------------
  alias :command_311_rtab :command_311
  def command_311
    command_311_rtab
    if $game_temp.in_battle
      $scene.status_window.refresh
    end
  end
  #--------------------------------------------------------------------------
  # *The increase and decrease of SP
  #--------------------------------------------------------------------------
  alias :command_312_rtab :command_312
  def command_312
    command_312_rtab
    if $game_temp.in_battle
      $scene.status_window.refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Modification of state
  #--------------------------------------------------------------------------
  alias :command_313_rtab :command_313
  def command_313
    command_313_rtab
    if $game_temp.in_battle
      $scene.status_window.refresh
    end
  end
  #--------------------------------------------------------------------------
  # * All recovery
  #--------------------------------------------------------------------------
  alias :command_314_rtab :command_314
  def command_314
    command_314_rtab
    if $game_temp.in_battle
      $scene.status_window.refresh
    end
  end
  #--------------------------------------------------------------------------
  # * The increase and decrease of EXP
  #--------------------------------------------------------------------------
  alias :command_315_rtab :command_315
  def command_315
    command_315_rtab
    if $game_temp.in_battle
      $scene.status_window.refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Increase and decrease of level
  #--------------------------------------------------------------------------
  alias :command_316_rtab :command_316
  def command_316
    command_316_rtab
    if $game_temp.in_battle
      $scene.status_window.refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Increase and decrease of parameter
  #--------------------------------------------------------------------------
  alias :command_317_rtab :command_317
  def command_317
    command_317_rtab
    if $game_temp.in_battle
      $scene.status_window.refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Modification of equipment
  #--------------------------------------------------------------------------
  alias :command_319_rtab :command_319
  def command_319
    command_319_rtab
    if $game_temp.in_battle
      $scene.status_window.refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Name modification of actor
  #--------------------------------------------------------------------------
  alias :command_320_rtab :command_320
  def command_320
    command_320_rtab
    if $game_temp.in_battle
      $scene.status_window.refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Class modification of actor
  #--------------------------------------------------------------------------
  alias :command_321_rtab :command_321
  def command_321
    command_321_rtab
    if $game_temp.in_battle
      $scene.status_window.refresh
    end
  end
  #-------------------------------------------------------------------------- 
  # * Indication of animation
  #--------------------------------------------------------------------------
  def command_337
    # Process iteration
    iterate_battler(@parameters[0], @parameters[1]) do |battler|
      # When the battler exists
      if battler.exist?
      #  Setting animation ID
        battler.animation.push([@parameters[2], true])
      end 
    end 
    # continuous 
    return true 
  end 
  #-------------------------------------------------------------------------- 
  # * Deal Damage
  #-------------------------------------------------------------------------- 
  def command_338 
  # of the damage the value which is operated acquisition 
  value = operate_value(0, @parameters[2], @parameters[3])
  # Process iteration
  iterate_battler(@parameters[0], @parameters[1]) do |battler|
  # battler exists with 
    if battler.exist? 
      # HP modification 
      battler.hp -= value 
      # fighting 
        if $game_temp.in_battle 
          # damage setting 
          battler.damage["event"] = value
          battler.damage_pop["event"] = true
        end 
      end 
    end 
    if $game_temp.in_battle 
      $scene.status_window.refresh 
    end 
    # continuation 
  return true 
  end
  #--------------------------------------------------------------------------
  # * Forcing the action
  #--------------------------------------------------------------------------
  def command_339
    # If it is not in the midst of fighting, disregard
    unless $game_temp.in_battle
      return true
    end
    # If the number of turns 0 disregard
    if $game_temp.battle_turn == 0
      return true
    end
    # Processing (With convenient ones, there are no times when it becomes plural)
    iterate_battler(@parameters[0], @parameters[1]) do |battler|
      # When the battler exists,
      if battler.exist?
      # Setting action
        battler.current_action.force_kind = @parameters[2]
        if battler.current_action.force_kind == 0
          battler.current_action.force_basic = @parameters[3]
        else
          battler.current_action.force_skill_id = @parameters[3]
        end
        #  Setting the conduct object
        if @parameters[4] == -2
          if battler.is_a?(Game_Enemy)
            battler.current_action.decide_last_target_for_enemy
          else
            battler.current_action.decide_last_target_for_actor
          end
        elsif @parameters[4] == -1
          if battler.is_a?(Game_Enemy)
            battler.current_action.decide_random_target_for_enemy
          else
            battler.current_action.decide_random_target_for_actor
          end
        elsif @parameters[4] >= 0
          battler.current_action.target_index = @parameters[4]
        end
        # When action validity and [ directly execution ] is,
        if battler.current_action.valid? and @parameters[5] == 1
          # Setting the battler of the forced object
          $game_temp.forcing_battler = battler
          # The index is advanced
          @index += 1
          # end 
          return false
        elsif battler.current_action.valid? and @parameters[5] == 0
          battler.current_action.forcing = true
        end
      end
    end
  # continuation
    return true
  end
end

#==============================================================================
# * Sprite module 
#------------------------------------------------------------------------------
# This module manages and controls animation. 
#============================================================================== 

module RPG

  class Sprite < ::Sprite
    def initialize(viewport = nil)
      super(viewport)
      @_whiten_duration = 0
      @_appear_duration = 0
      @_escape_duration = 0
      @_collapse_duration = 0
      @_damage = []
      @_animation = []
      @_animation_duration = 0
      @_blink = false
    end
    def damage(value, critical, type = 0)
      if value.is_a?(Numeric)
        damage_string = value.abs.to_s
      else
        damage_string = value.to_s
      end
      bitmap = Bitmap.new(160, 48)
      bitmap.font.name = "Arial Black"
      bitmap.font.size = 32
      bitmap.font.color.set(0, 0, 0)
      bitmap.draw_text(-1, 12-1, 160, 36, damage_string, 1)
      bitmap.draw_text(+1, 12-1, 160, 36, damage_string, 1)
      bitmap.draw_text(-1, 12+1, 160, 36, damage_string, 1)
      bitmap.draw_text(+1, 12+1, 160, 36, damage_string, 1)
      if value.is_a?(Numeric) and value < 0
        if type == 0
          bitmap.font.color.set(176, 255, 144)
        else
          bitmap.font.color.set(176, 144, 255)
        end
      else
        if type == 0
          bitmap.font.color.set(255, 255, 255)
        else
          bitmap.font.color.set(255, 176, 144)
        end
      end
      if type == 2
        bitmap.font.color.set(255, 224, 128)
      end
      bitmap.draw_text(0, 12, 160, 36, damage_string, 1)
      if critical
        string = "CRITICAL"
        bitmap.font.size = 20
        bitmap.font.color.set(0, 0, 0)
        bitmap.draw_text(-1, -1, 160, 20, string, 1)
        bitmap.draw_text(+1, -1, 160, 20, string, 1)
        bitmap.draw_text(-1, +1, 160, 20, string, 1)
        bitmap.draw_text(+1, +1, 160, 20, string, 1)
        bitmap.font.color.set(255, 255, 255)
        bitmap.draw_text(0, 0, 160, 20, string, 1)
      end
      num = @_damage.size
      if type != 2
        @_damage.push([::Sprite.new, 40, 0, rand(40) - 20, rand(30) + 50])
      else
        @_damage.push([::Sprite.new, 40, 0, rand(20) - 10, rand(20) + 60])
      end
      @_damage[num][0].bitmap = bitmap
      @_damage[num][0].ox = 80 + self.viewport.ox
      @_damage[num][0].oy = 20 + self.viewport.oy
      if self.battler.is_a?(Game_Actor)
        @_damage[num][0].x = self.x
        @_damage[num][0].y = self.y - self.oy / 2
      else
        @_damage[num][0].x = self.x + self.viewport.rect.x -
                            self.ox + self.src_rect.width / 2
        @_damage[num][0].y = self.y - self.oy * self.zoom_y / 2 +
                            self.viewport.rect.y
        @_damage[num][0].zoom_x = self.zoom_x
        @_damage[num][0].zoom_y = self.zoom_y
        @_damage[num][0].z = 3000
      end
    end
    def animation(animation, hit)
      return if animation == nil
      num = @_animation.size
      @_animation.push([animation, hit, animation.frame_max, []])
      bitmap = RPG::Cache.animation(animation.animation_name,
                                    animation.animation_hue)
      if @@_reference_count.include?(bitmap)
        @@_reference_count[bitmap] += 1
      else
        @@_reference_count[bitmap] = 1
      end
      if @_animation[num][0].position != 3 or
          not @@_animations.include?(animation)
        for i in 0..15
          sprite = ::Sprite.new
          sprite.bitmap = bitmap
          sprite.visible = false
          @_animation[num][3].push(sprite)
        end
        unless @@_animations.include?(animation)
          @@_animations.push(animation)
        end
      end
      update_animation(@_animation[num])
    end
    def loop_animation(animation)
      return if animation == @_loop_animation
      dispose_loop_animation
      @_loop_animation = animation
      return if @_loop_animation == nil
      @_loop_animation_index = 0
      animation_name = @_loop_animation.animation_name
      animation_hue = @_loop_animation.animation_hue
      bitmap = RPG::Cache.animation(animation_name, animation_hue)
      if @@_reference_count.include?(bitmap)
        @@_reference_count[bitmap] += 1
      else
        @@_reference_count[bitmap] = 1
      end
      @_loop_animation_sprites = []
      for i in 0..15
        sprite = ::Sprite.new
        sprite.bitmap = bitmap
        sprite.visible = false
        @_loop_animation_sprites.push(sprite)
      end
      # update_loop_animation
    end
    def dispose_damage
      for damage in @_damage.reverse
        damage[0].bitmap.dispose
        damage[0].dispose
        @_damage.delete(damage)
      end
    end
    def dispose_animation
      for anime in @_animation.reverse
        sprite = anime[3][0]
        if sprite != nil
          @@_reference_count[sprite.bitmap] -= 1
          if @@_reference_count[sprite.bitmap] == 0
            sprite.bitmap.dispose
          end
        end
        for sprite in anime[3]
          sprite.dispose
        end
        @_animation.delete(anime)
      end
    end
    def effect?
      @_whiten_duration > 0 or
      @_appear_duration > 0 or
      @_escape_duration > 0 or
      @_collapse_duration > 0 or
      @_damage.size == 0 or
      @_animation.size == 0
    end
    def update
      super
      if @_whiten_duration > 0
        @_whiten_duration -= 1
        self.color.alpha = 128 - (16 - @_whiten_duration) * 10
      end
      if @_appear_duration > 0
        @_appear_duration -= 1
        self.opacity = (16 - @_appear_duration) * 16
      end
      if @_escape_duration > 0
        @_escape_duration -= 1
        self.opacity = 256 - (32 - @_escape_duration) * 10
      end
      if @_collapse_duration > 0
        @_collapse_duration -= 1
        self.opacity = 256 - (48 - @_collapse_duration) * 6
      end
      for damage in @_damage
        if damage[1] > 0
          damage[1] -= 1
          damage[4] -= 3
          damage[2] -= damage[4]
          if self.battler.is_a?(Game_Actor)
            damage[0].x = self.x + (40 - damage[1]) * damage[3] / 10
            damage[0].y = self.y - self.oy / 2 + damage[2] / 10
          else
            damage[0].x = self.x + self.viewport.rect.x -
                          self.ox + self.src_rect.width / 2 +
                          (40 - damage[1]) * damage[3] / 10
            damage[0].y = self.y - self.oy * self.zoom_y / 2 +
                          self.viewport.rect.y + damage[2] / 10
            damage[0].zoom_x = self.zoom_x
            damage[0].zoom_y = self.zoom_y
          end
          damage[0].z = 2960 + damage[1]
          damage[0].opacity = 256 - (12 - damage[1]) * 32
          if damage[1] == 0
            damage[0].bitmap.dispose
            damage[0].dispose
            @_damage.delete(damage)
          end
        end
      end
      for anime in @_animation
        if (Graphics.frame_count % 2 == 0)
          anime[2] -= 1
          update_animation(anime)
        end
      end
      if @_loop_animation != nil and (Graphics.frame_count % 2 == 0)
        update_loop_animation
        @_loop_animation_index += 1
        @_loop_animation_index %= @_loop_animation.frame_max
      end
      if @_blink
        @_blink_count = (@_blink_count + 1) % 32
        if @_blink_count < 16
          alpha = (16 - @_blink_count) * 6
        else
          alpha = (@_blink_count - 16) * 6
        end
        self.color.set(255, 255, 255, alpha)
      end
      @@_animations.clear
    end
    def update_animation(anime)
      if anime[2] > 0
        frame_index = anime[0].frame_max - anime[2]
        cell_data = anime[0].frames[frame_index].cell_data
        position = anime[0].position
        animation_set_sprites(anime[3], cell_data, position)
        for timing in anime[0].timings
          if timing.frame == frame_index
            animation_process_timing(timing, anime[1])
          end
        end
      else
        @@_reference_count[anime[3][0].bitmap] -= 1
        if @@_reference_count[anime[3][0].bitmap] == 0
            anime[3][0].bitmap.dispose
        end
        for sprite in anime[3]
          sprite.dispose
        end
        @_animation.delete(anime)
      end
    end
    def animation_set_sprites(sprites, cell_data, position)
      for i in 0..15
        sprite = sprites[i]
        pattern = cell_data[i, 0]
        if sprite == nil or pattern == nil or pattern == -1
          sprite.visible = false if sprite != nil
          next
        end
        sprite.visible = true
        sprite.src_rect.set(pattern % 5 * 192, pattern / 5 * 192, 192, 192)
        if position == 3
          if self.viewport != nil
            sprite.x = self.viewport.rect.width / 2
            if $game_temp.in_battle and self.battler.is_a?(Game_Enemy)
              sprite.y = self.viewport.rect.height - 320
            else
              sprite.y = self.viewport.rect.height - 160
            end
          else
            sprite.x = 320
            sprite.y = 240
          end
        else
          sprite.x = self.x + self.viewport.rect.x -
                      self.ox + self.src_rect.width / 2
          if $game_temp.in_battle and self.battler.is_a?(Game_Enemy)
            sprite.y = self.y - self.oy * self.zoom_y / 2 +
                        self.viewport.rect.y
            if position == 0
              sprite.y -= self.src_rect.height * self.zoom_y / 4
            elsif position == 2
              sprite.y += self.src_rect.height * self.zoom_y / 4
            end
          else
            sprite.y = self.y + self.viewport.rect.y -
                        self.oy + self.src_rect.height / 2
            sprite.y -= self.src_rect.height / 4 if position == 0
            sprite.y += self.src_rect.height / 4 if position == 2
          end
        end
        sprite.x += cell_data[i, 1]
        sprite.y += cell_data[i, 2]
        sprite.z = 2000
        sprite.ox = 96
        sprite.oy = 96
        sprite.zoom_x = cell_data[i, 3] / 100.0
        sprite.zoom_y = cell_data[i, 3] / 100.0
        if position != 3
          sprite.zoom_x *= self.zoom_x
          sprite.zoom_y *= self.zoom_y
        end
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
        sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
        sprite.blend_type = cell_data[i, 7]
      end
    end
    def x=(x)
      sx = x - self.x
      if sx != 0
        for anime in @_animation
          if anime[3] != nil
            for i in 0..15
              anime[3][i].x += sx
            end
          end
        end
        if @_loop_animation_sprites != nil
          for i in 0..15
            @_loop_animation_sprites[i].x += sx
          end
        end
      end
      super
    end
    def y=(y)
      sy = y - self.y
      if sy != 0
        for anime in @_animation
          if anime[3] != nil
            for i in 0..15
              anime[3][i].y += sy
            end
          end
        end
        if @_loop_animation_sprites != nil
          for i in 0..15
            @_loop_animation_sprites[i].y += sy
          end
        end
      end
      super
    end
  end
end

#------------------------------------------------------------------------------
# New routine added to the Bitmap class. 
#============================================================================== 

class Bitmap
#-------------------------------------------------------------------------- 
# * Rectangle Gradation Indicator
#   color1: Start color 
#   color2: Ending color 
#   align: 0: On side gradation 
#          1: Vertically gradation 
#          2: The gradation (intense concerning slantedly heavily note) 
#-------------------------------------------------------------------------- 
  def gradation_rect(x, y, width, height, color1, color2, align = 0)
    if align == 0
      for i in x...x + width
        red   = color1.red + (color2.red - color1.red) * (i - x) / (width - 1)
        green = color1.green +
                (color2.green - color1.green) * (i - x) / (width - 1)
        blue  = color1.blue +
                (color2.blue - color1.blue) * (i - x) / (width - 1)
        alpha = color1.alpha +
                (color2.alpha - color1.alpha) * (i - x) / (width - 1)
        color = Color.new(red, green, blue, alpha)
        fill_rect(i, y, 1, height, color)
      end
    elsif align == 1
      for i in y...y + height
        red   = color1.red +
                (color2.red - color1.red) * (i - y) / (height - 1)
        green = color1.green +
                (color2.green - color1.green) * (i - y) / (height - 1)
        blue  = color1.blue +
                (color2.blue - color1.blue) * (i - y) / (height - 1)
        alpha = color1.alpha +
                (color2.alpha - color1.alpha) * (i - y) / (height - 1)
        color = Color.new(red, green, blue, alpha)
        fill_rect(x, i, width, 1, color)
      end
    elsif align == 2
      for i in x...x + width
        for j in y...y + height
          red   = color1.red + (color2.red - color1.red) *
                  ((i - x) / (width - 1.0) + (j - y) / (height - 1.0)) / 2
          green = color1.green + (color2.green - color1.green) *
                  ((i - x) / (width - 1.0) + (j - y) / (height - 1.0)) / 2
          blue  = color1.blue + (color2.blue - color1.blue) *
                  ((i - x) / (width - 1.0) + (j - y) / (height - 1.0)) / 2
          alpha = color1.alpha + (color2.alpha - color1.alpha) *
                  ((i - x) / (width - 1.0) + (j - y) / (height - 1.0)) / 2
          color = Color.new(red, green, blue, alpha)
          set_pixel(i, j, color)
        end
      end
    elsif align == 3
      for i in x...x + width
        for j in y...y + height
          red   = color1.red + (color2.red - color1.red) *
              ((x + width - i) / (width - 1.0) + (j - y) / (height - 1.0)) / 2
          green = color1.green + (color2.green - color1.green) *
              ((x + width - i) / (width - 1.0) + (j - y) / (height - 1.0)) / 2
          blue  = color1.blue + (color2.blue - color1.blue) *
              ((x + width - i) / (width - 1.0) + (j - y) / (height - 1.0)) / 2
          alpha = color1.alpha + (color2.alpha - color1.alpha) *
              ((x + width - i) / (width - 1.0) + (j - y) / (height - 1.0)) / 2
          color = Color.new(red, green, blue, alpha)
          set_pixel(i, j, color)
        end
      end
    end
  end
end