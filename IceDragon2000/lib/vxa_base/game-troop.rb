#encoding:UTF-8
# Game_Troop
#==============================================================================
# ** Game_Troop
#------------------------------------------------------------------------------
#  This class handles enemy groups and battle-related data. Also performs
# battle events. The instance of this class is referenced by $game_troop.
#==============================================================================

class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # * Characters to be added to the end of enemy names
  #--------------------------------------------------------------------------
  LETTER_TABLE_HALF = [' A',' B',' C',' D',' E',' F',' G',' H',' I',' J',
                       ' K',' L',' M',' N',' O',' P',' Q',' R',' S',' T',
                       ' U',' V',' W',' X',' Y',' Z']
  LETTER_TABLE_FULL = ['Ａ','Ｂ','Ｃ','Ｄ','Ｅ','Ｆ','Ｇ','Ｈ','Ｉ','Ｊ',
                       'Ｋ','Ｌ','Ｍ','Ｎ','Ｏ','Ｐ','Ｑ','Ｒ','Ｓ','Ｔ',
                       'Ｕ','Ｖ','Ｗ','Ｘ','Ｙ','Ｚ']
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :screen                   # battle screen state
  attr_reader   :interpreter              # battle event interpreter
  attr_reader   :event_flags              # battle event executed flag
  attr_reader   :turn_count               # number of turns
  attr_reader   :name_counts              # hash for enemy name appearance
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super
    @screen = Game_Screen.new
    @interpreter = Game_Interpreter.new
    @event_flags = {}
    clear
  end
  #--------------------------------------------------------------------------
  # * Get Members
  #--------------------------------------------------------------------------
  def members
    @enemies
  end
  #--------------------------------------------------------------------------
  # * Clear
  #--------------------------------------------------------------------------
  def clear
    @screen.clear
    @interpreter.clear
    @event_flags.clear
    @enemies = []
    @turn_count = 0
    @names_count = {}
  end
  #--------------------------------------------------------------------------
  # * Get Troop Objects
  #--------------------------------------------------------------------------
  def troop
    $data_troops[@troop_id]
  end
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  def setup(troop_id)
    clear
    @troop_id = troop_id
    @enemies = []
    troop.members.each do |member|
      next unless $data_enemies[member.enemy_id]
      enemy = Game_Enemy.new(@enemies.size, member.enemy_id)
      enemy.hide if member.hidden
      enemy.screen_x = member.x
      enemy.screen_y = member.y
      @enemies.push(enemy)
    end
    init_screen_tone
    make_unique_names
  end
  #--------------------------------------------------------------------------
  # * Initialize Screen Tone
  #--------------------------------------------------------------------------
  def init_screen_tone
    @screen.start_tone_change($game_map.screen.tone, 0) if $game_map
  end
  #--------------------------------------------------------------------------
  # * Add letters (ABC, etc) to enemy characters with the same name
  #--------------------------------------------------------------------------
  def make_unique_names
    members.each do |enemy|
      next unless enemy.alive?
      next unless enemy.letter.empty?
      n = @names_count[enemy.original_name] || 0
      enemy.letter = letter_table[n % letter_table.size]
      @names_count[enemy.original_name] = n + 1
    end
    members.each do |enemy|
      n = @names_count[enemy.original_name] || 0
      enemy.plural = true if n >= 2
    end
  end
  #--------------------------------------------------------------------------
  # * Get Text Table to Place Behind Enemy Name
  #--------------------------------------------------------------------------
  def letter_table
    $game_system.japanese? ? LETTER_TABLE_FULL : LETTER_TABLE_HALF
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    @screen.update
  end
  #--------------------------------------------------------------------------
  # * Get Enemy Name Array
  #    For display at start of battle. Overlapping names are removed.
  #--------------------------------------------------------------------------
  def enemy_names
    names = []
    members.each do |enemy|
      next unless enemy.alive?
      next if names.include?(enemy.original_name)
      names.push(enemy.original_name)
    end
    names
  end
  #--------------------------------------------------------------------------
  # * Determine if Battle Event (Page) Conditions Are Met
  #--------------------------------------------------------------------------
  def conditions_met?(page)
    c = page.condition
    if !c.turn_ending && !c.turn_valid && !c.enemy_valid &&
       !c.actor_valid && !c.switch_valid
      return false      # Conditions not set: not executed
    end
    if @event_flags[page]
      return false      # Executed
    end
    if c.turn_ending    # At turn end
      return false unless BattleManager.turn_end?
    end
    if c.turn_valid     # Number of turns
      n = @turn_count
      a = c.turn_a
      b = c.turn_b
      return false if (b == 0 && n != a)
      return false if (b > 0 && (n < 1 || n < a || n % b != a % b))
    end
    if c.enemy_valid    # Enemy
      enemy = $game_troop.members[c.enemy_index]
      return false if enemy == nil
      return false if enemy.hp_rate * 100 > c.enemy_hp
    end
    if c.actor_valid    # Actor
      actor = $game_actors[c.actor_id]
      return false if actor == nil 
      return false if actor.hp_rate * 100 > c.actor_hp
    end
    if c.switch_valid   # Switch
      return false if !$game_switches[c.switch_id]
    end
    return true         # Condition met
  end
  #--------------------------------------------------------------------------
  # * Battle Event Setup
  #--------------------------------------------------------------------------
  def setup_battle_event
    return if @interpreter.running?
    return if @interpreter.setup_reserved_common_event
    troop.pages.each do |page|
      next unless conditions_met?(page)
      @interpreter.setup(page.list)
      @event_flags[page] = true if page.span <= 1
      return
    end
  end
  #--------------------------------------------------------------------------
  # * Increase Turns
  #--------------------------------------------------------------------------
  def increase_turn
    troop.pages.each {|page| @event_flags[page] = false if page.span == 1 }
    @turn_count += 1
  end
  #--------------------------------------------------------------------------
  # * Calculate Total Experience
  #--------------------------------------------------------------------------
  def exp_total
    dead_members.inject(0) {|r, enemy| r += enemy.exp }
  end
  #--------------------------------------------------------------------------
  # * Calculate Total Gold
  #--------------------------------------------------------------------------
  def gold_total
    dead_members.inject(0) {|r, enemy| r += enemy.gold } * gold_rate
  end
  #--------------------------------------------------------------------------
  # * Get Multiplier for Gold
  #--------------------------------------------------------------------------
  def gold_rate
    $game_party.gold_double? ? 2 : 1
  end
  #--------------------------------------------------------------------------
  # * Create Array of Dropped Items
  #--------------------------------------------------------------------------
  def make_drop_items
    dead_members.inject([]) {|r, enemy| r += enemy.make_drop_items }
  end
end
