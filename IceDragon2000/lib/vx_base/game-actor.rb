#encoding:UTF-8
# Game_Actor
#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It's used within the Game_Actors class
# ($game_actors) and referenced by the Game_Party class ($game_party).
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :name                     # name
  attr_reader   :character_name           # character graphic filename
  attr_reader   :character_index          # character graphic index
  attr_reader   :face_name                # face graphic filename
  attr_reader   :face_index               # face graphic index
  attr_reader   :class_id                 # class ID
  attr_reader   :weapon_id                # weapon ID
  attr_reader   :armor1_id                # shield ID
  attr_reader   :armor2_id                # helmet ID
  attr_reader   :armor3_id                # body armor ID
  attr_reader   :armor4_id                # accessory ID
  attr_reader   :level                    # level
  attr_reader   :exp                      # experience
  attr_accessor :last_skill_id            # for cursor memory: Skill
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     actor_id : actor ID
  #--------------------------------------------------------------------------
  def initialize(actor_id)
    super()
    setup(actor_id)
    @last_skill_id = 0
  end
  #--------------------------------------------------------------------------
  # * Setup
  #     actor_id : actor ID
  #--------------------------------------------------------------------------
  def setup(actor_id)
    actor = $data_actors[actor_id]
    @actor_id = actor_id
    @name = actor.name
    @character_name = actor.character_name
    @character_index = actor.character_index
    @face_name = actor.face_name
    @face_index = actor.face_index
    @class_id = actor.class_id
    @weapon_id = actor.weapon_id
    @armor1_id = actor.armor1_id
    @armor2_id = actor.armor2_id
    @armor3_id = actor.armor3_id
    @armor4_id = actor.armor4_id
    @level = actor.initial_level
    @exp_list = Array.new(101)
    make_exp_list
    @exp = @exp_list[@level]
    @skills = []
    for i in self.class.learnings
      learn_skill(i.skill_id) if i.level <= @level
    end
    clear_extra_values
    recover_all
  end
  #--------------------------------------------------------------------------
  # * Determine if Actor or Not
  #--------------------------------------------------------------------------
  def actor?
    return true
  end
  #--------------------------------------------------------------------------
  # * Get Actor ID
  #--------------------------------------------------------------------------
  def id
    return @actor_id
  end
  #--------------------------------------------------------------------------
  # * Get Index
  #--------------------------------------------------------------------------
  def index
    return $game_party.members.index(self)
  end
  #--------------------------------------------------------------------------
  # * Get Actor Object
  #--------------------------------------------------------------------------
  def actor
    return $data_actors[@actor_id]
  end
  #--------------------------------------------------------------------------
  # * Get Class Object
  #--------------------------------------------------------------------------
  def class
    return $data_classes[@class_id]
  end
  #--------------------------------------------------------------------------
  # * Get Skill Object Array
  #--------------------------------------------------------------------------
  def skills
    result = []
    for i in @skills
      result.push($data_skills[i])
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Get Weapon Object Array
  #--------------------------------------------------------------------------
  def weapons
    result = []
    result.push($data_weapons[@weapon_id])
    if two_swords_style
      result.push($data_weapons[@armor1_id])
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Get Armor Object Array
  #--------------------------------------------------------------------------
  def armors
    result = []
    unless two_swords_style
      result.push($data_armors[@armor1_id])
    end
    result.push($data_armors[@armor2_id])
    result.push($data_armors[@armor3_id])
    result.push($data_armors[@armor4_id])
    return result
  end
  #--------------------------------------------------------------------------
  # * Get Equipped Item Object Array
  #--------------------------------------------------------------------------
  def equips
    return weapons + armors
  end
  #--------------------------------------------------------------------------
  # * Calculate Experience
  #--------------------------------------------------------------------------
  def make_exp_list
    @exp_list[1] = @exp_list[100] = 0
    m = actor.exp_basis
    n = 0.75 + actor.exp_inflation / 200.0;
    for i in 2..99
      @exp_list[i] = @exp_list[i-1] + Integer(m)
      m *= 1 + n;
      n *= 0.9;
    end
  end
  #--------------------------------------------------------------------------
  # * Get Element Change Value
  #     element_id : element ID
  #--------------------------------------------------------------------------
  def element_rate(element_id)
    rank = self.class.element_ranks[element_id]
    result = [0,200,150,100,50,0,-100][rank]
    for armor in armors.compact
      result /= 2 if armor.element_set.include?(element_id)
    end
    for state in states
      result /= 2 if state.element_set.include?(element_id)
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Get Added State Success Rate
  #     state_id : state ID
  #--------------------------------------------------------------------------
  def state_probability(state_id)
    if $data_states[state_id].nonresistance
      return 100
    else
      rank = self.class.state_ranks[state_id]
      return [0,100,80,60,40,20,0][rank]
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if State is Resisted
  #     state_id : state ID
  #--------------------------------------------------------------------------
  def state_resist?(state_id)
    for armor in armors.compact
      return true if armor.state_set.include?(state_id)
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Get Normal Attack Element
  #--------------------------------------------------------------------------
  def element_set
    result = []
    if weapons.compact == []
      return [1]                  # Unarmed: melee attribute
    end
    for weapon in weapons.compact
      result |= weapon == nil ? [] : weapon.element_set
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Get Additional Effect of Normal Attack (state change)
  #--------------------------------------------------------------------------
  def plus_state_set
    result = []
    for weapon in weapons.compact
      result |= weapon == nil ? [] : weapon.state_set
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Get Maximum HP Limit
  #--------------------------------------------------------------------------
  def maxhp_limit
    return 9999
  end
  #--------------------------------------------------------------------------
  # * Get Basic Maximum HP
  #--------------------------------------------------------------------------
  def base_maxhp
    return actor.parameters[0, @level]
  end
  #--------------------------------------------------------------------------
  # * Get basic Maximum MP
  #--------------------------------------------------------------------------
  def base_maxmp
    return actor.parameters[1, @level]
  end
  #--------------------------------------------------------------------------
  # * Get Basic Attack
  #--------------------------------------------------------------------------
  def base_atk
    n = actor.parameters[2, @level]
    for item in equips.compact do n += item.atk end
    return n
  end
  #--------------------------------------------------------------------------
  # * Get Basic Defense
  #--------------------------------------------------------------------------
  def base_def
    n = actor.parameters[3, @level]
    for item in equips.compact do n += item.def end
    return n
  end
  #--------------------------------------------------------------------------
  # * Get Basic Spirit
  #--------------------------------------------------------------------------
  def base_spi 
    n = actor.parameters[4, @level]
    for item in equips.compact do n += item.spi end
    return n
  end
  #--------------------------------------------------------------------------
  # * Get Basic Agility
  #--------------------------------------------------------------------------
  def base_agi
    n = actor.parameters[5, @level]
    for item in equips.compact do n += item.agi end
    return n
  end
  #--------------------------------------------------------------------------
  # * Get Hit Rate
  #--------------------------------------------------------------------------
  def hit
    if two_swords_style
      n1 = weapons[0] == nil ? 95 : weapons[0].hit
      n2 = weapons[1] == nil ? 95 : weapons[1].hit
      n = [n1, n2].min
    else
      n = weapons[0] == nil ? 95 : weapons[0].hit
    end
    return n
  end
  #--------------------------------------------------------------------------
  # * Get Evasion Rate
  #--------------------------------------------------------------------------
  def eva
    n = 5
    for item in armors.compact do n += item.eva end
    return n
  end
  #--------------------------------------------------------------------------
  # * Get Critical Ratio
  #--------------------------------------------------------------------------
  def cri
    n = 4
    n += 4 if actor.critical_bonus
    for weapon in weapons.compact
      n += 4 if weapon.critical_bonus
    end
    return n
  end
  #--------------------------------------------------------------------------
  # * Get Ease of Hitting
  #--------------------------------------------------------------------------
  def odds
    return 4 - self.class.position
  end
  #--------------------------------------------------------------------------
  # * Get [Dual Wield] Option
  #--------------------------------------------------------------------------
  def two_swords_style
    return actor.two_swords_style
  end
  #--------------------------------------------------------------------------
  # * Get [Fixed Equipment] Option
  #--------------------------------------------------------------------------
  def fix_equipment
    return actor.fix_equipment
  end
  #--------------------------------------------------------------------------
  # * Get [Automatic Battle] Option
  #--------------------------------------------------------------------------
  def auto_battle
    return actor.auto_battle
  end
  #--------------------------------------------------------------------------
  # * Get [Super Guard] Option
  #--------------------------------------------------------------------------
  def super_guard
    return actor.super_guard
  end
  #--------------------------------------------------------------------------
  # * Get [Pharmocology] Option
  #--------------------------------------------------------------------------
  def pharmacology
    return actor.pharmacology
  end
  #--------------------------------------------------------------------------
  # * Get [First attack within turn] weapon option
  #--------------------------------------------------------------------------
  def fast_attack
    for weapon in weapons.compact
      return true if weapon.fast_attack
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Get [Chain attack] weapon option
  #--------------------------------------------------------------------------
  def dual_attack
    for weapon in weapons.compact
      return true if weapon.dual_attack
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Get [Prevent critical] armor option
  #--------------------------------------------------------------------------
  def prevent_critical
    for armor in armors.compact
      return true if armor.prevent_critical
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Get [half MP cost] armor option
  #--------------------------------------------------------------------------
  def half_mp_cost
    for armor in armors.compact
      return true if armor.half_mp_cost
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Get [Double Experience] Armor Option
  #--------------------------------------------------------------------------
  def double_exp_gain
    for armor in armors.compact
      return true if armor.double_exp_gain
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Get [Auto HP Recovery] Armor Option
  #--------------------------------------------------------------------------
  def auto_hp_recover
    for armor in armors.compact
      return true if armor.auto_hp_recover
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Get Normal Attack Animation ID
  #--------------------------------------------------------------------------
  def atk_animation_id
    if two_swords_style
      return weapons[0].animation_id if weapons[0] != nil
      return weapons[1] == nil ? 1 : 0
    else
      return weapons[0] == nil ? 1 : weapons[0].animation_id
    end
  end
  #--------------------------------------------------------------------------
  # * Get Normal Attack Animation ID (Dual Wield: Weapon 2)
  #--------------------------------------------------------------------------
  def atk_animation_id2
    if two_swords_style
      return weapons[1] == nil ? 0 : weapons[1].animation_id
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # * Get Experience String
  #--------------------------------------------------------------------------
  def exp_s
    return @exp_list[@level+1] > 0 ? @exp : "-------"
  end
  #--------------------------------------------------------------------------
  # * Get String for Next Level Experience
  #--------------------------------------------------------------------------
  def next_exp_s
    return @exp_list[@level+1] > 0 ? @exp_list[@level+1] : "-------"
  end
  #--------------------------------------------------------------------------
  # * Get String for Experience to Next Level
  #--------------------------------------------------------------------------
  def next_rest_exp_s
    return @exp_list[@level+1] > 0 ?
      (@exp_list[@level+1] - @exp) : "-------"
  end
  #--------------------------------------------------------------------------
  # * Change Equipment (designate ID)
  #     equip_type : Equip region (0..4)
  #     item_id    : Weapon ID or armor ID
  #     test       : Test flag (for battle test or temporary equipment)
  #    Used by event commands or battle test preparation.
  #--------------------------------------------------------------------------
  def change_equip_by_id(equip_type, item_id, test = false)
    if equip_type == 0 or (equip_type == 1 and two_swords_style)
      change_equip(equip_type, $data_weapons[item_id], test)
    else
      change_equip(equip_type, $data_armors[item_id], test)
    end
  end
  #--------------------------------------------------------------------------
  # * Change Equipment (designate object)
  #     equip_type : Equip region (0..4)
  #     item       : Weapon or armor (nil is used to unequip)
  #     test       : Test flag (for battle test or temporary equipment)
  #--------------------------------------------------------------------------
  def change_equip(equip_type, item, test = false)
    last_item = equips[equip_type]
    unless test
      return if $game_party.item_number(item) == 0 if item != nil
      $game_party.gain_item(last_item, 1)
      $game_party.lose_item(item, 1)
    end
    item_id = item == nil ? 0 : item.id
    case equip_type
    when 0  # Weapon
      @weapon_id = item_id
      unless two_hands_legal?             # If two hands is not allowed
        change_equip(1, nil, test)        # Unequip from other hand
      end
    when 1  # Shield
      @armor1_id = item_id
      unless two_hands_legal?             # If two hands is not allowed
        change_equip(0, nil, test)        # Unequip from other hand
      end
    when 2  # Head
      @armor2_id = item_id
    when 3  # Body
      @armor3_id = item_id
    when 4  # Accessory
      @armor4_id = item_id
    end
  end
  #--------------------------------------------------------------------------
  # * Discard Equipment
  #     item : Weapon or armor to be discarded.
  #    Used when the "Include Equipment" option is enabled.
  #--------------------------------------------------------------------------
  def discard_equip(item)
    if item.is_a?(RPG::Weapon)
      if @weapon_id == item.id
        @weapon_id = 0
      elsif two_swords_style and @armor1_id == item.id
        @armor1_id = 0
      end
    elsif item.is_a?(RPG::Armor)
      if not two_swords_style and @armor1_id == item.id
        @armor1_id = 0
      elsif @armor2_id == item.id
        @armor2_id = 0
      elsif @armor3_id == item.id
        @armor3_id = 0
      elsif @armor4_id == item.id
        @armor4_id = 0
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Two handed Equipment
  #--------------------------------------------------------------------------
  def two_hands_legal?
    if weapons[0] != nil and weapons[0].two_handed
      return false if @armor1_id != 0
    end
    if weapons[1] != nil and weapons[1].two_handed
      return false if @weapon_id != 0
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Determine if Equippable
  #     item : item
  #--------------------------------------------------------------------------
  def equippable?(item)
    if item.is_a?(RPG::Weapon)
      return self.class.weapon_set.include?(item.id)
    elsif item.is_a?(RPG::Armor)
      return false if two_swords_style and item.kind == 0
      return self.class.armor_set.include?(item.id)
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Change Experience
  #     exp  : New experience
  #     show : Level up display flag
  #--------------------------------------------------------------------------
  def change_exp(exp, show)
    last_level = @level
    last_skills = skills
    @exp = [[exp, 9999999].min, 0].max
    while @exp >= @exp_list[@level+1] and @exp_list[@level+1] > 0
      level_up
    end
    while @exp < @exp_list[@level]
      level_down
    end
    @hp = [@hp, maxhp].min
    @mp = [@mp, maxmp].min
    if show and @level > last_level
      display_level_up(skills - last_skills)
    end
  end
  #--------------------------------------------------------------------------
  # * Level Up
  #--------------------------------------------------------------------------
  def level_up
    @level += 1
    for learning in self.class.learnings
      learn_skill(learning.skill_id) if learning.level == @level
    end
  end
  #--------------------------------------------------------------------------
  # * Level Down
  #--------------------------------------------------------------------------
  def level_down
    @level -= 1
  end
  #--------------------------------------------------------------------------
  # * Show Level Up Message
  #     new_skills : Array of newly learned skills
  #--------------------------------------------------------------------------
  def display_level_up(new_skills)
    $game_message.new_page
    text = sprintf(Vocab::LevelUp, @name, Vocab::level, @level)
    $game_message.texts.push(text)
    for skill in new_skills
      text = sprintf(Vocab::ObtainSkill, skill.name)
      $game_message.texts.push(text)
    end
  end
  #--------------------------------------------------------------------------
  # * Get Experience (for the double experience point option)
  #     exp  : Amount to increase experience.
  #     show : Level up display flag
  #--------------------------------------------------------------------------
  def gain_exp(exp, show)
    if double_exp_gain
      change_exp(@exp + exp * 2, show)
    else
      change_exp(@exp + exp, show)
    end
  end
  #--------------------------------------------------------------------------
  # * Change Level
  #     level : new level
  #     show  : Level up display flag
  #--------------------------------------------------------------------------
  def change_level(level, show)
    level = [[level, 99].min, 1].max
    change_exp(@exp_list[level], show)
  end
  #--------------------------------------------------------------------------
  # * Learn Skill
  #     skill_id : skill ID
  #--------------------------------------------------------------------------
  def learn_skill(skill_id)
    unless skill_learn?($data_skills[skill_id])
      @skills.push(skill_id)
      @skills.sort!
    end
  end
  #--------------------------------------------------------------------------
  # * Forget Skill
  #     skill_id : skill ID
  #--------------------------------------------------------------------------
  def forget_skill(skill_id)
    @skills.delete(skill_id)
  end
  #--------------------------------------------------------------------------
  # * Determine if Finished Learning Skill
  #     skill : skill
  #--------------------------------------------------------------------------
  def skill_learn?(skill)
    return @skills.include?(skill.id)
  end
  #--------------------------------------------------------------------------
  # * Determine Usable Skills
  #     skill : skill
  #--------------------------------------------------------------------------
  def skill_can_use?(skill)
    return false unless skill_learn?(skill)
    return super
  end
  #--------------------------------------------------------------------------
  # * Change Name
  #     name : new name
  #--------------------------------------------------------------------------
  def name=(name)
    @name = name
  end
  #--------------------------------------------------------------------------
  # * Change Class ID
  #     class_id : New class ID
  #--------------------------------------------------------------------------
  def class_id=(class_id)
    @class_id = class_id
    for i in 0..4     # Remove unequippable items
      change_equip(i, nil) unless equippable?(equips[i])
    end
  end
  #--------------------------------------------------------------------------
  # * Change Graphics
  #     character_name  : new character graphic filename
  #     character_index : new character graphic index
  #     face_name       : new face graphic filename
  #     face_index      : new face graphic index
  #--------------------------------------------------------------------------
  def set_graphic(character_name, character_index, face_name, face_index)
    @character_name = character_name
    @character_index = character_index
    @face_name = face_name
    @face_index = face_index
  end
  #--------------------------------------------------------------------------
  # * Use Sprites?
  #--------------------------------------------------------------------------
  def use_sprite?
    return false
  end
  #--------------------------------------------------------------------------
  # * Perform Collapse
  #--------------------------------------------------------------------------
  def perform_collapse
    if $game_temp.in_battle and dead?
      @collapse = true
      Sound.play_actor_collapse
    end
  end
  #--------------------------------------------------------------------------
  # * Perform Automatic Recovery (called at end of turn)
  #--------------------------------------------------------------------------
  def do_auto_recovery
    if auto_hp_recover and not dead?
      self.hp += maxhp / 20
    end
  end
  #--------------------------------------------------------------------------
  # * Create Battle Action (for automatic battle)
  #--------------------------------------------------------------------------
  def make_action
    @action.clear
    return unless movable?
    action_list = []
    action = Game_BattleAction.new(self)
    action.set_attack
    action.evaluate
    action_list.push(action)
    for skill in skills
      action = Game_BattleAction.new(self)
      action.set_skill(skill.id)
      action.evaluate
      action_list.push(action)
    end
    max_value = 0
    for action in action_list
      if action.value > max_value
        @action = action
        max_value = action.value
      end
    end
  end
end
