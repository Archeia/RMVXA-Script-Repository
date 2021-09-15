#==============================================================================#
# ** IEX(Icy Engine Xelion) - Emblem System
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Actors)
# ** Script Type   : State Modifier
# ** Date Created  : 11/??/2010 (DD/MM/YYYY)
# ** Date Modified : 07/24/2011 (DD/MM/YYYY)
# ** Script Tag    : IEX - Emblems System
# ** Difficulty    : Hard, Lunatic
# ** Version       : 1.2
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# This was my shot at replicating the TO - Knight of Lodis, emblem system. 
# If you have the IEX - Trait System, or BEM Passives and your wondering whats
# the difference between all of them.
# Passives - Are always active, the player chooses which passives to use.
# Traits   - Uses a condition in order to be active, they are PRESET
#            They become inactive wheb the condition isn't met.
# Emblems  - Uses a condition in order to activate it self, once activated
#            it stays on PERMANENTLY, unless negated.
# All of these use states.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** HOW TO USE
#------------------------------------------------------------------------------#
# V1.0 - Script Calls
#------------------------------------------------------------------------------#
#
# $scene = IEX_Scene_Emblem.new(actor)
# $scene = IEX_Scene_Emblem.new(member_index)
# If you plan on using this, please have the latest version of the
# ICY - WindowBaseExtended
# ICY - HM_WindowSelectable
#
#------------------------------------------------------------------------------#
# V1.0 - Notetags - States
#------------------------------------------------------------------------------#
# <emb id: eid>
#  This is used to sort the Emblems on the actor, you can have multiple
#  emblems with the same ID, but if there on the same actor, only the
#  last one will be shown. Replace eid
#
# <emb condition: phrase>
#  This is the name of the emblems condition. Replace phrase
#
# <emb states: id, id, id>
#  In addition to itself, the emblem, you can have as many, but note
#  If the state is already applied the new ones will be ignored.
#
# <emb noself>
#  The emeblem will not be included with states
#
# <emb description> </emb description>
#  Everything between these tags will go towards the items description
# 
#------------------------------------------------------------------------------#
# V1.1a - Notetags - States
#------------------------------------------------------------------------------#
# <emb negate: x> (or) <emb negates: x, x, x>
#  Any emblem id marked by x will have its effect negated.
#  NOTE: USE the EMBLEM'S ID, NOT the STATE'S ID
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
#
# BEM, Yggdrasil, Probably Takentai not sure about GTBS
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#------------------------------------------------------------------------------#
# 
# Below 
#  Materials
#
# Above 
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES 
#------------------------------------------------------------------------------# 
# ** - From Lunatic Mode
# Classes
#   ** Lunatic Changes
#   Game_Battler
#   **alias      :initialize
#   **alias      :slip_damage_effect
#   **alias      :attack_effect
#   **alias      :skill_effect
#   **alias      :item_effect
#   **new-method :iex_dead? 
#   Game_Enemy
#   **new-method :num_of_drops
#   Game_Actor
#   **alias      :setup
#   **new-method :iex_reset_battle_cache
#   **new-method :gain_emblem
#   Game_Party
#   **new-method :most_loot?(actor_id)
#   **new-method :most_drops?(actor_id)
#   Scene_Battle
#   **alias      :process_victory
#   **alias      :turn_end
#
#   RPG::State
#     new-method :iex_emblem_cache
#     new-method :stateIncludeSelf?
#     new-method :emb_states
#     new-method :emb_id
#     new-method :emb_condition
#     new-method :emb_description
#     new-method :emb_negates
#   Game_Battler
#     alias      :states
#     new-method :iex_check_condition
#     new-method :emblem_states
#     new-method :negate_emblem?(emb_id)
#   Game_Enemy
#     new-method :check_emblem_conditions
#   Game_Actor
#     alias      :setup
#     new-method :valid_emblem_id
#     new-method :emblems
#     new-method :emblem_states
#     new-method :check_emblem_conditions
#   Scene_Title
#     alias      :load_database
#     new-method :load_emblem_database
#   Game_Unit
#     new-method :alive_members
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
# (DD/MM/YYYY)
#  11/??/2010 - V1.0  Finished Script
#  12/20/2010 - V1.0  Fixed up Header
#  12/26/2010 - V1.1  Changed Condition Writing - Now apart of Lunatic Section
#  01/08/2011 - V1.1a Small Changes, Added Emblem Negation
#  07/24/2011 - V1.2  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment. 
#
#------------------------------------------------------------------------------#
$imported ||= {}
$imported["IEX_EmblemSystem"] = true

#==============================================================================#
# ** IEX::EMBLEM_SYSTEM
#==============================================================================#
module IEX
  module EMBLEM_SYSTEM
#==============================================================================#
#                           Start Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
    TOTAL_EMBLEMS = 36
  #--------------------------------------------------------------------------#
  # * EMBLEM_SYS_ICONS
  #--------------------------------------------------------------------------#
  # :symbol => icon_index,
  #--------------------------------------------------------------------------#
    EMBLEM_SYS_ICONS = {
      :unlockable => 6483,
      :locked     => 6484,
      :help       => 6422,
      :name       => 1,
      :class      => 1,
      :emblem_num => 1,
    } # Do Not Remove
  #--------------------------------------------------------------------------#
  # * EMBLEM_SYS_TEXT
  #--------------------------------------------------------------------------#
  # :symbol => 'string',
  #--------------------------------------------------------------------------#
    EMBLEM_SYS_TEXT = {
      :locked     => "-Locked-",
      :unavailable=> 'This emblem is not available',
      :emblems    => "Emblems",
      :help_text  => '',
      :name       => 'Name',
      :class      => 'Class',
      :emblem_num => 'Emblem Count'
    } # Do Not Remove
  #--------------------------------------------------------------------------#
  # * EMBLEM_SYS_COLORS
  #--------------------------------------------------------------------------#
  # :symbol => Color.new(red, green, blue, alpha*),
  #--------------------------------------------------------------------------#  
    EMBLEM_SYS_COLORS = {
      :back       => Color.new(166, 124, 82, 128),
      :border     => Color.new(126, 84, 42),
    } # Do Not Remove
  #--------------------------------------------------------------------------#
  # * ACTOR_VALID_EMBLEMS
  #--------------------------------------------------------------------------#
  # Actor_ID => [id, id..range],
  # Do not Remove Actor 0, it is the default for all unstated actors.
  #--------------------------------------------------------------------------#
    ACTOR_VALID_EMBLEMS = {
    # Actor_ID => [x, x..y],
      0 => [84..84+35], #[60..92], # Do Not Remove
      1 => [84..84+19, 84+23..84+35],
    } # Do Not Remove

#==============================================================================#
#                           End Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#    
  end
end 
#==============================================================================#
#                           Start Lunatic Mode
#------------------------------------------------------------------------------#
#==============================================================================# 
#==============================================================================#
# ** Game_Battler - Condition - Lunatic Mode
#==============================================================================#
class Game_Battler
  
  #--------------------------------------------------------------------------#
  # * iex_check_condition 
  #--------------------------------------------------------------------------#
  # Evaluates and returns a condition 
  # <emb condition: cond_name>
  # <emb condition: alwaystrue>
  #--------------------------------------------------------------------------#
  def iex_check_condition(cond_name)
    can_get = false
    case cond_name.to_s.upcase
    #--------------------------------------------------------------------------#
    # EDIT HERE
    #--------------------------------------------------------------------------#
    when "ALWAYSTRUE"
      can_get = true
    when "ALWAYSFALSE"  
      can_get = false
    when /(\w+)?[ ]*(?:HEAL_COUNT|heal count|healcount):?[ ]*(\d+)\+/i  
      val = $2.to_i
      case $1.to_s.upcase
      when "ITEM"
        can_get = @item_heal_count >= val
      else
        can_get = @heal_count >= val
      end  
    when /(\w+)?[ ]*(?:KILL_COUNT|kill count|killcount):?[ ]*(\d+)\+/i  
      val = $2.to_i
      case $1.to_s.upcase
      when "SKILL", "MAGIC"
        can_get = @skill_kill_count >= val
      when "ITEM"
        can_get = @item_kill_count >= val 
      else
        can_get = @kill_count >= val
      end  
    when /(?:DODGE_COUNT|dodgecount):?[ ]*(\d+)\+/i  
      can_get = @dodge_count >= $1.to_i
    when /(?:HIT_COUNT|hitcount):?[ ]*(\d+)\+/i  
      can_get = @hit_count >= $1.to_i 
    when /(?:USED_SKILLS|USED SKILLS|USEDSKILLS):?[ ]*(\d+)\+/i
      can_get = @used_skills.size >= $1.to_i
    when /(?:BATTLE_NO_DEATH|BATTLENODEATH|BATTLE NO DEATH):?[ ]*(\d+)\+/i
      can_get = @no_death_battle_count >= $1.to_i
    when /(?:HAVE_SKILLS|HAVESKILLS|HAVE SKILLS):?[ ]*(\d+)\+/i  
      can_get = @skills.size >= $1.to_i
    when "EATEN_ALL_BERRIES", "EATEN ALL BERRIES", "EATENALLBERRIES"  
      can_get = ([51, 52, 53, 54, 55, 56] - @used_items).size == 0
    when "WARLOCK" 
      can_get = (@skill_kill_count >= 5 && @kill_count >= 5)
    when "LAST_MAN", "LASTMAN"  
      can_get = @last_man
    when "MOSTLOOT", "MOST_LOOT", "MOST LOOT"  
      can_get = (@at_end_battle == true and $game_party.most_loot?(@actor_id))
    when "MOSTDROPS", "MOST_DROPS", "MOST DROPS"
      can_get = (@at_end_battle == true and $game_party.most_drops?(@actor_id))
    when "HEALTHYFIGHT", "HEALTHY_FIGHT", "HEALTHY FIGHT"  
      can_get = (@at_end_battle == true and @receieved_hits == 0)
      
    when "HEALSIBLING", "HEAL_SIBLING", "HEAL SIBLING"  
      can_get = IEX::EARTHEN.sibling_heal(self)
    when "SIBLINGLOVE", "SIBLING_LOVE", "SIBLING LOVE"  
      can_get = IEX::EARTHEN.sibling_love(self)
    when "JEALOUSY"  
      can_get = IEX::EARTHEN.jealousy_check(self)
    when "PARTNER"  
      can_get = @actor_id == $game_party.partner(1)  
    #--------------------------------------------------------------------------#
    # STOP EDIT HERE
    #--------------------------------------------------------------------------#
    else ; can_get = false
    end  
    return can_get
  end
  
end        
    
#==============================================================================#
# ** Game_Battler - Lunatic Mode
#==============================================================================#
class Game_Battler
  
  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :dodge_count
  attr_accessor :hit_count
  attr_accessor :receieved_hits
  attr_accessor :kill_count
  attr_accessor :skill_kill_count
  attr_accessor :heal_count
  attr_accessor :item_heal_count
  attr_accessor :item_kill_count
  attr_accessor :last_man
  attr_accessor :battle_loot
  attr_accessor :battle_drop_count
  attr_accessor :used_skills
  attr_accessor :used_items
  attr_accessor :no_death_battle_count
  attr_accessor :healed_by
  
  #--------------------------------------------------------------------------#
  # * alias - initialize
  #--------------------------------------------------------------------------#
  alias :iex_emblem_initialize :initialize unless $@
  def initialize( *args, &block )
    iex_emblem_initialize( *args, &block )
    @dodge_count = 0      # This includes misses and evades
    @hit_count = 0        # Number of succesful hits given a row
    @receieved_hits = 0   # Hits received during battle, resets to 0 after battle
    @kill_count = 0       # Kill count by normal Attack
    @skill_kill_count = 0 # Kill count by Skill
    @item_kill_count = 0  # Kill count by Item
    @heal_count = 0       # Heal count by Skill
    @item_heal_count = 0  # Heal count by Item
    @last_man = false     # Changes at the end of battle 
    @battle_loot = 0      # Amount of gold received from a defeated enemy
    @battle_drop_count = 0# Number of drops received from a defeated enemy
    @used_skills = []     # Array containing the IDs of used skills
    @used_items = []      # Array containing the IDs of used items
    @healed_by = {}       # The key is an actor's ID, the value is a number
    @item_healed_by = {}  # The key is an item's ID, the value is a number
    @at_end_battle = false# At the end of battle?
    @no_death_battle_count = 0
    @iex_already_dead = false # Used to avoid, multi checking
  end
  
  #--------------------------------------------------------------------------#
  # * iex_dead?
  #--------------------------------------------------------------------------#
  # If using Melody there is a chance that conditions that require the
  # target to be dead would fail, this method checks if the targets
  # hp is 0 and tags it as dead, ignoring Immortality.
  #--------------------------------------------------------------------------#
  def iex_dead?()
    @iex_already_dead = false if @iex_already_dead == nil
    @iex_already_dead = false if self.hp > 0
    @iex_already_dead = true if self.hp <= 0
    return (self.hp <= 0 and @iex_already_dead)
  end
  
  #--------------------------------------------------------------------------#
  # * alias-method :slip_damage_effect
  #--------------------------------------------------------------------------# 
  alias iex_emb_slip_damage_effect slip_damage_effect unless $@
  def slip_damage_effect( *args, &block )
    iex_emb_slip_damage_effect( *args, &block )
    self.no_death_battle_count = 0 if self.actor? and self.dead?
  end
  
  #--------------------------------------------------------------------------#
  # * alias-method :attack_effect
  #--------------------------------------------------------------------------# 
  alias :iex_emb_attack_effect :attack_effect unless $@
  def attack_effect( attacker )
    emb_grab = iex_emb_attack_effect( attacker )
    if self.actor? and self.iex_dead?
      self.no_death_battle_count = 0
    end  
    if @evaded 
      @dodge_count += 1
    end  
    if @missed or @evaded
      attacker.hit_count = 0
    else
      attacker.hit_count += 1
    end
    if attacker.actor? and self.iex_dead?
      attacker.kill_count += 1
      unless self.actor?
        attacker.battle_loot += self.gold
        attacker.battle_drop_count += num_of_drops
      end  
    end 
    unless (@skipped or @missed or @evaded)
      if self.actor? 
        self.receieved_hits += 1
      end 
      attacker.check_emblem_conditions
      if attacker != self and self.actor?
        self.check_emblem_conditions
      end
      @dodge_count = 0
    end  
    return emb_grab
  end
  
  #--------------------------------------------------------------------------#
  # * alias-method :skill_effect
  #--------------------------------------------------------------------------# 
  alias :iex_emb_skill_effect :skill_effect unless $@
  def skill_effect( user, skill )
    if user.actor?
      user.used_skills.push(skill.id) unless user.used_skills.include?(skill.id)
    end
    iex_emb_skill_effect(user, skill)
    if self.actor? and self.iex_dead?
      self.no_death_battle_count = 0
    end  
    if self.actor? and skill.base_damage < 0
      user.heal_count += 1
      self.healed_by[user.id] = 0 if self.healed_by[user.id] == nil
      self.healed_by[user.id] += 1
    end  
    if self.actor? and skill.base_damage > 0
      self.receieved_hits += 1
    end 
    if user.actor? and self.iex_dead?
      user.skill_kill_count += 1
      unless self.actor?
        user.battle_loot += self.gold
        user.battle_drop_count += num_of_drops
      end 
    end  
    user.check_emblem_conditions
    if user != self and self.actor?
      self.check_emblem_conditions
    end 
  end
  
  #--------------------------------------------------------------------------#
  # * alias-method :item_effect
  #--------------------------------------------------------------------------# 
  alias :iex_emb_item_effect :item_effect unless $@
  def item_effect( user, item )
    if user.actor?
      user.used_items.push(item.id) unless user.used_items.include?(item.id)
    end
    iex_emb_item_effect(user, item)
    if self.actor? and self.iex_dead?
      self.no_death_battle_count = 0
    end  
    if user.actor? and item.base_damage < 0
      user.item_heal_count += 1
      self.item_healed_by[item.id] = 0 if self.item_healed_by[item.id] == nil
      self.item_healed_by[item.id] += 1
    end  
    if user.actor? and self.iex_dead?
      user.item_kill_count += 1
      unless self.actor?
        user.battle_loot += self.gold
        user.battle_drop_count += num_of_drops
      end 
    end  
    user.check_emblem_conditions
    if self.actor? and item.base_damage > 0
      self.receieved_hits += 1
    end  
    if user != self and self.actor?
      self.check_emblem_conditions
    end 
  end
  
end

#==============================================================================#
# ** Game_Enemy - Lunatic Mode
#==============================================================================#
class Game_Enemy < Game_Battler
  
  #--------------------------------------------------------------------------#
  # * num_of_drops
  #--------------------------------------------------------------------------#
  # Returns the number of drops present on an enemy
  #--------------------------------------------------------------------------#
  def num_of_drops()
    size = 0
    size += more_drops.size if $imported["IEX_Rand_Drop"]
    size += drop_item1.kind == 0 ? 0 : 1
    size += drop_item2.kind == 0 ? 0 : 1
    return size
  end
  
end

#==============================================================================#
# ** Game_Actor - Lunatic Mode
#==============================================================================#
class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------#
  # * alias - setup - Lunatic
  #--------------------------------------------------------------------------#
  alias iex_lunEmb_setup setup unless $@
  def setup( *args, &block )
    iex_lunEmb_setup( *args, &block )
    @kill_count = 0
    @skill_kill_count = 0
    @heal_count = 0
    @item_heal_count = 0
    @item_kill_count = 0
    @last_man = false
    @battle_loot = 0
    @battle_drop_count = 0
    @used_skills = []
    @used_items = []
    @no_death_battle_count = 0
    @at_end_battle = false
  end
  
  #--------------------------------------------------------------------------#
  # * iex_reset_battle_cache
  #--------------------------------------------------------------------------#
  def iex_reset_battle_cache()
    @battle_loot = 0
    @battle_drop_count = 0
    @receieved_hits = 0
    @last_man = false  
    @at_end_battle = false
    @gained_emblems = []
  end
  
  #--------------------------------------------------------------------------#
  # * gain_emblem
  #--------------------------------------------------------------------------#
  # Used in battle
  #--------------------------------------------------------------------------#
  def gain_emblem( sta )
    return if sta == nil
    return unless @valid_emblem_ids.include?(sta.id)
    @emblem_ids[sta.emb_id - 1] = sta.id
    if $game_temp.in_battle
      @gained_emblems.push(sta.id)
    end 
  end
  
end

#==============================================================================#
# ** Game_Party - Lunatic Mode
#==============================================================================#
class Game_Party < Game_Unit
  
  #--------------------------------------------------------------------------#
  # * most_loot?
  #--------------------------------------------------------------------------#
  # Returns the member with the most loot (Member who received the most gold from
  # dead enemies)
  #--------------------------------------------------------------------------#
  def most_loot?(act_id)
    return false unless $game_temp.in_battle
    return false if members.size <= 1
    loot_array = []
    for mem in members
      next if mem == nil
      loot_array.push([mem.battle_loot, mem.id])
    end  
    loot_array.sort!
    loot_array.reverse!
    return false if loot_array[0][0] == 0
    return loot_array[0][1] == act_id
  end
  
  #--------------------------------------------------------------------------#
  # * most_drops?
  #--------------------------------------------------------------------------#
  # Returns the member with the most drops (Member who received the most drops from
  # dead enemies)
  #--------------------------------------------------------------------------#
  def most_drops?(act_id)
    return false unless $game_temp.in_battle
    return false if members.size <= 1
    drop_array = []
    for mem in members
      next if mem == nil
      drop_array.push([mem.battle_drop_count, mem.id])
    end  
    drop_array.sort!
    drop_array.reverse!
    return false if drop_array[0][0] == 0
    return drop_array[0][1] == act_id
  end
  
end

#==============================================================================#
# ** Scene_Battle - Lunatic Mode
#==============================================================================#
class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------#
  # * alias-method :turn_end
  #--------------------------------------------------------------------------# 
  alias iex_emblems_turn_end turn_end unless $@
  def turn_end( *args, &block )
    iex_emblems_turn_end( *args, &block )
    for mem in $game_party.members ; mem.check_emblem_conditions ; end
  end
  
  #--------------------------------------------------------------------------#
  # * alias-method :process_victory
  #--------------------------------------------------------------------------#   
  alias iex_emblems_process_victory process_victory unless $@
  def process_victory( *args, &block )
    if $game_party.alive_members.size == 1 and not $game_party.members.size <= 1
      mem = $game_party.alive_members[0]
      mem.last_man = true
    end
    for memb in $game_party.members
      memb.at_end_battle = true
      unless memb.dead?
        memb.no_death_battle_count += 1
      else
        memb.no_death_battle_count = 0
      end  
      memb.check_emblem_conditions
    end
    iex_emblems_process_victory( *args, &block ) 
    for memb in $game_party.members
      memb.iex_reset_battle_cache
    end  
  end  
  
end

#==============================================================================#
#                           End Lunatic Mode
#------------------------------------------------------------------------------#
#==============================================================================#  

#==============================================================================#
# ** IEX::EMBLEM_SYSTEM
#==============================================================================#
module IEX
  module EMBLEM_SYSTEM
    # Credit to Yanfly for the range to array method
    module_function
    #--------------------------------------------------------------------------#
    # convert_integer_array
    #--------------------------------------------------------------------------#
    def convert_integer_array(array)
      result = []
      array.each { |i|
        case i
        when Range; result |= i.to_a
        when Integer; result |= [i]
        end }
      return result
    end
  
    #--------------------------------------------------------------------------
    # converted_contants
    #--------------------------------------------------------------------------
    for key in ACTOR_VALID_EMBLEMS.keys
      ACTOR_VALID_EMBLEMS[key] = convert_integer_array(ACTOR_VALID_EMBLEMS[key])
    end 
    
  end
end

#==============================================================================#
# ** RPG::State
#==============================================================================#
class RPG::State
   
  #--------------------------------------------------------------------------#
  # * iex_emblem_cache
  #--------------------------------------------------------------------------#
  # This is the Emblem's Cache
  #--------------------------------------------------------------------------#
  def iex_emblem_cache
    @emb_cache_complete = false
    @emb_states = []
    @emb_negateIds = []
    @emb_id = 0
    @emb_condition = "AlwaysFalse"
    @emb_description = ''
    @emb_includeSelf = true
    emb_des_on = false
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when /<(?:EMB_|EMBLEM_|emb |emblem )(?:STATE)s?:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
      $1.scan(/\d+/).each { |sid|
      @emb_states.push(sid.to_i) }
    when /<(?:EMB_|EMBLEM_|emb |emblem )(?:NEGATE)s?:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
      $1.scan(/\d+/).each { |sid|
      @emb_negateIds.push(sid.to_i) }
    when /<(?:EMEBLEM_ID|emblem id|EMB_ID|emb id):[ ]*(\d+)>/i
      @emb_id = $1.to_i
    when /<(?:EMB_|EMBLEM_|emb |emblem )(?:CONDITION|cond):[ ]*(.*)>/i
      @emb_condition = $1.to_s  
    when /<(?:EMB_|EMBLEM_|emb |emblem )(?:DESCRIPTION|des)>/i
      emb_des_on = true
    when /<\/(?:EMB_|EMBLEM_|emb |emblem )(?:DESCRIPTION|des)>/i
      emb_des_on = false
    when /<(?:EMB_|EMBLEM_|emb |emblem )(?:NOSELF|no self|NOT_SELF|not self)>/i  
      @emb_includeSelf = false
    else
      @emb_description += line.to_s if emb_des_on
    end  }
    @emb_cache_complete = true
    emb_des_on = false
  end
  
  #--------------------------------------------------------------------------#
  # * stateIncludeSelf?
  #--------------------------------------------------------------------------#
  # Include self, with states? By default YES
  #--------------------------------------------------------------------------#
  def stateIncludeSelf?
    iex_emblem_cache unless @emb_cache_complete
    return @emb_includeSelf 
  end
  
  #--------------------------------------------------------------------------#
  # * emb_states
  #--------------------------------------------------------------------------#
  # In addition to it self, the Emblem can include other states
  # Note, if the state has already been applied it will be ignored
  #--------------------------------------------------------------------------#
  def emb_states
    iex_emblem_cache unless @emb_cache_complete
    return @emb_states
  end
  
  #--------------------------------------------------------------------------#
  # * emb_id
  #--------------------------------------------------------------------------#
  # Each Emblem has an ID, therefore you can have 3 different emblems
  # all with the same ID but for different characters!
  #--------------------------------------------------------------------------#
  def emb_id
    iex_emblem_cache unless @emb_cache_complete
    return @emb_id
  end
  
  #--------------------------------------------------------------------------#
  # * emb_condition
  #--------------------------------------------------------------------------#
  # The emblem's condition name
  #--------------------------------------------------------------------------#
  def emb_condition
    iex_emblem_cache unless @emb_cache_complete
    return @emb_condition
  end
  
  #--------------------------------------------------------------------------#
  # * emb_description
  #--------------------------------------------------------------------------#
  # The emblem's description
  #--------------------------------------------------------------------------#
  def emb_description
    iex_emblem_cache unless @emb_cache_complete
    return @emb_description
  end
  
  #--------------------------------------------------------------------------#
  # * emb_negates
  #--------------------------------------------------------------------------#
  # The emblem's negation
  #--------------------------------------------------------------------------#
  def emb_negates
    iex_emblem_cache unless @emb_cache_complete
    return @emb_negateIds
  end
  
end
  
#==============================================================================#
# ** DummyLockedState - A dummy state used in the Emblem view window
#==============================================================================#
class DummyLockedState < RPG::State
  
  #--------------------------------------------------------------------------#
  # * initialize
  #--------------------------------------------------------------------------#
  def initialize()
    super()
    iex_emblem_cache
    @icon_index = IEX::EMBLEM_SYSTEM::EMBLEM_SYS_ICONS[:locked]
    @name = IEX::EMBLEM_SYSTEM::EMBLEM_SYS_TEXT[:locked]
    @emb_description = IEX::EMBLEM_SYSTEM::EMBLEM_SYS_TEXT[:unavailable]
  end
  
end

#==============================================================================#
# ** DummyHelpState - A dummy state used in the Emblem help window
#==============================================================================#
class DummyHelpState < RPG::State
  
  #--------------------------------------------------------------------------#
  # * initialize
  #--------------------------------------------------------------------------#
  def initialize()
    super()
    iex_emblem_cache()
    @icon_index = IEX::EMBLEM_SYSTEM::EMBLEM_SYS_ICONS[:help]
    @name = IEX::EMBLEM_SYSTEM::EMBLEM_SYS_TEXT[:emblems]
    @emb_description = IEX::EMBLEM_SYSTEM::EMBLEM_SYS_TEXT[:help_text]
  end
  
end

#==============================================================================#
# ** Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base
  
  #--------------------------------------------------------------------------#
  # * alias-method :load_database
  #--------------------------------------------------------------------------#
  alias :iex_emb_load_database :load_database unless $@
  def load_database()
    iex_emb_load_database()
    load_emblem_database()
  end
  
  #--------------------------------------------------------------------------#
  # * alias-method :load_bt_database
  #--------------------------------------------------------------------------#
  alias :iex_emb_load_bt_database :load_bt_database unless $@
  def load_bt_database()
    iex_emb_load_bt_database()
    load_emblem_database()
  end
  
  #--------------------------------------------------------------------------#
  # * load_emblem_database
  #--------------------------------------------------------------------------#
  # This loads all the emblems caches so it doesn't have to during runtime
  #--------------------------------------------------------------------------#
  def load_emblem_database()
    for st in $data_states.compact
      st.iex_emblem_cache()
    end  
  end
  
end

#==============================================================================#
# ** Game_Unit
#==============================================================================#
class Game_Unit
  
  #--------------------------------------------------------------------------#
  # * Get array of Alive Members
  #--------------------------------------------------------------------------#
  def alive_members()
    result = []
    for battler in members
      next if battler.dead?
      result.push(battler)
    end
    return result
  end
  
end

#==============================================================================#
# ** Game_Battler
#==============================================================================#
class Game_Battler
      
  #--------------------------------------------------------------------------#
  # * emblem_states
  #--------------------------------------------------------------------------#
  # Dummy - Used for Enemies, since they don't have any emblems
  # This is overwriten in the Game_Actor class.
  #--------------------------------------------------------------------------#
  def emblem_states ; return [] end
  
  #--------------------------------------------------------------------------#
  # * alias - states
  #--------------------------------------------------------------------------#
  # Used to add the emblem states to the current set
  #--------------------------------------------------------------------------#
  alias :iex_emblem_states :states unless $@
  def states()
    result = iex_emblem_states
    result |= self.emblem_states if self.actor?
    return result
  end
  
end

#==============================================================================#
# ** Game_Enemy
#==============================================================================#
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------#
  # * check_emblem_conditions
  #--------------------------------------------------------------------------#
  # Dummy - Used for Enemies, since they don't have any emblems
  # This is overwriten in the Game_Actor class.
  #--------------------------------------------------------------------------#
  def check_emblem_conditions()
  end
  
end

#==============================================================================#
# ** Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :emblem_ids
  attr_accessor :valid_emblem_ids
  attr_accessor :at_end_battle
  attr_accessor :gained_emblems
    
  #--------------------------------------------------------------------------#
  # * alias-method :setup
  #--------------------------------------------------------------------------#
  alias :iex_emblems_setup :setup unless $@
  def setup( *args, &block )
    @emblem_ids = []
    @valid_emblem_ids = []
    iex_emblems_setup( *args, &block )
    if IEX::EMBLEM_SYSTEM::ACTOR_VALID_EMBLEMS.has_key?(@actor_id)
      @valid_emblem_ids = IEX::EMBLEM_SYSTEM::ACTOR_VALID_EMBLEMS[@actor_id].clone
    else  
      @valid_emblem_ids = IEX::EMBLEM_SYSTEM::ACTOR_VALID_EMBLEMS[0].clone
    end  
    for i in 0...IEX::EMBLEM_SYSTEM::TOTAL_EMBLEMS
      @emblem_ids[i] = 0
    end  
    @gained_emblems = [] # Gained During Battle
  end
  
  #--------------------------------------------------------------------------#
  # * valid_emblem_id
  #--------------------------------------------------------------------------#
  # Is the emblem a valid one?
  #--------------------------------------------------------------------------#
  def valid_emblem_id( emb_id )
    for sid in @valid_emblem_ids.compact
      sta = $data_states[sid]
      #next if sta == nil
      return true if sta.emb_id == emb_id
    end  
    return false
  end
  
  #--------------------------------------------------------------------------#
  # * negate_emblem?
  #--------------------------------------------------------------------------#
  # Should the emblems effect be negated?
  #--------------------------------------------------------------------------#
  def negate_emblem?( nemb )
    eid = nemb
    eid = nemb.emb_id if nemb.is_a?(RPG::State)
    for emb in emblems
      return true if emb.emb_negates.include?(eid)
    end  
    return false
  end  
  
  #--------------------------------------------------------------------------#
  # * emblems - returns an array containing all the obtained emblems
  #--------------------------------------------------------------------------#
  def emblems()
    result = []
    for sid in @emblem_ids
      result.push($data_states[sid])
    end  
    return result
  end
  
  #--------------------------------------------------------------------------#
  # * emblem_states 
  #--------------------------------------------------------------------------#
  # Returns an array containing all the obtained emblems states
  #--------------------------------------------------------------------------#
  def emblem_states()
    result = []
    for emb in emblems.compact
      next if negate_emblem?(emb)
      result.push(emb) if emb.stateIncludeSelf?()
      for sid in emb.emb_states
        result.push($data_states[sid])
      end  
    end
    return result
  end
    
  #--------------------------------------------------------------------------#
  # * check_emblem_conditions
  #--------------------------------------------------------------------------#
  # Checks all unobtained emeblems to see if they can be collected
  #--------------------------------------------------------------------------#
  def check_emblem_conditions
    for sid in @valid_emblem_ids
      next if @emblem_ids.include?(sid)
      sta = $data_states[sid]
      #next if sta == nil
      if iex_check_condition(sta.emb_condition)
        gain_emblem(sta)
      end  
    end  
  end  
  
end

#==============================================================================#
# ** IEX_Scene_Emblem
#==============================================================================#
class IEX_Scene_Emblem < Scene_Base

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#   
  def initialize( actor, called = false )
    super()
    @index_call = false
    @act_index = 0
    if actor.kind_of?(Game_Battler)
      @actor = actor
    elsif actor != nil  
      @actor = $game_party.members[actor]
      @act_index = actor
      @index_call = true
    else 
      @actor = nil
    end  
    @call_from_menu = called
    @actor.check_emblem_conditions
  end
  
  #--------------------------------------------------------------------------#
  # * super-method :start
  #--------------------------------------------------------------------------#   
  def start()
    super()
    create_menu_background
    @windows = {}
    win_pos = [0, Graphics.width, Graphics.width / 2, Graphics.height, 
      Graphics.height / 2]
    @windows["Emblems"]  = IEX_Emblem_Window.new(@actor, win_pos[0], win_pos[0], 
      win_pos[1], win_pos[4])
    @windows["Help"]     = IEX_Emblem_Help_Window.new(win_pos[0], 
      @windows["Emblems"].height, win_pos[1], 96)#win_pos[4])
    @windows["Help"].set_emblem(@windows["Emblems"].current_emblem)
    ya = @windows["Help"].y + @windows["Help"].height 
    @windows["Actor_Status"] = IEX_Emblem_ActStatus_Window.new(@actor, 
      win_pos[0], ya, win_pos[2] + 96, win_pos[3] - ya)
    @windows["DummyHelp"]    = IEX_Emblem_Help_Window.new(
      @windows["Actor_Status"].width, ya, win_pos[2] - 96, 96)
    @windows["DummyHelp"].set_emblem(DummyHelpState.new)
  end
  
  #--------------------------------------------------------------------------#
  # * super-method :terminate
  #--------------------------------------------------------------------------#   
  def terminate()
    super()
    dispose_menu_background()
    for win in @windows.values.compact
      win.dispose
      win = nil
    end  
    @windows.clear
  end
  
  #--------------------------------------------------------------------------#
  # * super-method :update
  #--------------------------------------------------------------------------#   
  def update()
    super()
    update_menu_background()
    if Input.trigger?(Input::C)
      #Sound.play_decision
    elsif Input.trigger?(Input::R)  
      if @index_call 
        Sound.play_cursor
        @act_index = (@act_index + 1) % $game_party.members.size
        $scene = IEX_Scene_Emblem.new(@act_index)
      else
        Sound.play_buzzer
      end  
    elsif Input.trigger?(Input::L)  
      if @index_call 
        Sound.play_cursor
        @act_index = (@act_index - 1) % $game_party.members.size
        $scene = IEX_Scene_Emblem.new(@act_index)
      else  
        Sound.play_buzzer
      end 
    elsif Input.trigger?(Input::B)  
      Sound.play_cancel
      $scene = Scene_Map.new
    end  
    for win in @windows.values
      win.update if win.active
    end  
    @windows["Help"].set_emblem(@windows["Emblems"].current_emblem)
  end
  
end

#==============================================================================#
# ** IEX_Emblem_ActStatus_Window
#==============================================================================#
class IEX_Emblem_ActStatus_Window < Window_Base

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#   
  def initialize(actor, x, y, width, height)
    super(x, y, width, height)
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :refresh
  #--------------------------------------------------------------------------#   
  def refresh()
    create_contents()
    draw_actor_face(@actor, 4, 4)
    draw_actor_graphic(@actor, 96, 96)
    self.contents.font.size = Font.default_size
    self.contents.font.color = system_color
    t_x = 104 
    draw_icon(IEX::EMBLEM_SYSTEM::EMBLEM_SYS_ICONS[:name], t_x, 4)
    draw_icon(IEX::EMBLEM_SYSTEM::EMBLEM_SYS_ICONS[:class], t_x, 28)
    draw_icon(IEX::EMBLEM_SYSTEM::EMBLEM_SYS_ICONS[:emblem_num], t_x, 52)
    self.contents.draw_text(t_x + 24, 4, self.contents.width, 24, 
      IEX::EMBLEM_SYSTEM::EMBLEM_SYS_TEXT[:name])
    self.contents.draw_text(t_x + 24, 28, self.contents.width, 24, 
      IEX::EMBLEM_SYSTEM::EMBLEM_SYS_TEXT[:class])
    self.contents.draw_text(t_x + 24, 52, self.contents.width, 24, 
      IEX::EMBLEM_SYSTEM::EMBLEM_SYS_TEXT[:emblem_num])
    self.contents.font.color = normal_color
    self.contents.font.size = 18
    self.contents.draw_text(t_x + 128, 4, self.contents.width, 24, @actor.name)
    self.contents.draw_text(t_x + 128, 28, self.contents.width, 24, @actor.class.name)
    coun = 0
    @actor.emblems.each { |em| coun += 1 if em != nil}
    emblem = sprintf("%s / %s", coun, @actor.valid_emblem_ids.size)
    self.contents.draw_text(t_x + 128, 52, self.contents.width, 24, emblem)
  end
  
end

#==============================================================================#
# ** IEX_Emblem_Help_Window
#==============================================================================#
class IEX_Emblem_Help_Window < Window_Base

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#   
  def initialize( x, y, width, height )
    super( x, y, width, height )
    @last_emblem = ''
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :set_emblem
  #--------------------------------------------------------------------------#     
  def set_emblem( emb )
    return if @last_emblem == emb
    self.contents.clear
    rect = Rect.new(4, 4, 32, 32)
    self.contents.fill_rect(rect, IEX::EMBLEM_SYSTEM::EMBLEM_SYS_COLORS[:back])
    draw_border_rect(4, 4, 32, 32, 4, 
      IEX::EMBLEM_SYSTEM::EMBLEM_SYS_COLORS[:border])
    if emb != nil
      draw_icon(emb.icon_index, 8, 8)
      self.contents.font.size = Font.default_size
      self.contents.font.color = system_color
      self.contents.draw_text(42, 4, self.contents.width - 42, 24, emb.name)
      self.contents.font.color = normal_color
      self.contents.font.size = 18
      self.contents.draw_text(4, 42, self.contents.width, 24, emb.emb_description)
    end  
    @last_emblem = emb
  end
  
end

#==============================================================================#
# ** IEX_Emblem_Window
#==============================================================================#
class IEX_Emblem_Window < HM_Window_Selectable

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------# 
  def initialize( actor = nil, 
   x = 0, y = 0, width = Graphics.width, height = Graphics.height )
    super(x, y, width, height)
    @actor = actor
    @column_max = 12
    @item_sq_spacing = 42
    @rect_size = 32
    @selection_size = 38
    self.height = (@item_sq_spacing * 3) + 32
    @index = 0
    @locked_array = []
    @locked_state = DummyLockedState.new
    refresh()
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :current_emblem
  #--------------------------------------------------------------------------#   
  def current_emblem()
    return @locked_state if @locked_array.include?( @index )
    return @data[@index]
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :refresh
  #--------------------------------------------------------------------------#   
  def refresh()  
    @data = @actor.emblems
    @item_max = @data.size
    create_contents()
    prep_coord_vars()
    for i in 0...@data.size ; draw_item(i) ; end
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :draw_item
  #--------------------------------------------------------------------------#   
  def draw_item( index )
    emb = nil 
    rect = Rect.new( @nw_x, @nw_y, @rect_size, @rect_size )
    if @actor.valid_emblem_id(index.to_i + 1)
      emb = @data[index]
      color1 = IEX::EMBLEM_SYSTEM::EMBLEM_SYS_COLORS[:back]
      color2 = IEX::EMBLEM_SYSTEM::EMBLEM_SYS_COLORS[:border]
      x_icon = IEX::EMBLEM_SYSTEM::EMBLEM_SYS_ICONS[:unlockable]
      self.contents.fill_rect( rect, color1 )
      draw_border_rect( @nw_x, @nw_y, @rect_size, @rect_size, 4, color2 )
    else   
      color1 = IEX::EMBLEM_SYSTEM::EMBLEM_SYS_COLORS[:border]
      color2 = IEX::EMBLEM_SYSTEM::EMBLEM_SYS_COLORS[:back]
      x_icon = IEX::EMBLEM_SYSTEM::EMBLEM_SYS_ICONS[:locked]
      @locked_array.push( index )
    end  
    unless emb.nil?()
      draw_icon( emb.icon_index, @nw_x + 4, @nw_y + 4 ) 
    else
      draw_icon( x_icon, @nw_x + 4, @nw_y + 4 )
    end  
    advance_space()
  end
  
end

#==============================================================================#
# ** END OF FILE
#==============================================================================#