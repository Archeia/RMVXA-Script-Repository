#==============================================================================#
# ** IEX(Icy Engine Xelion) - Trait System
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Actors)
# ** Script Type   : State Modifier
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# This was a very old idea I had when using GTBS, but due to some problems
# I lost it.
# What this script does is allows states to be applied temporarily to an actor
# using custom conditions.
# If you have the IEX - Emblem System, or BEM Passives and your wondering whats
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
# V1.0 - Notetags - States
#------------------------------------------------------------------------------#
# <trt id: eid>
#  Not really used, and isn't neccessary.
#
# <trt condition: phrase>
#  This is the name of the traits condition. Replace phrase
#  You can stack as many conditions as you like
#
# <trt states: id, id, id>
#  In addition to itself, the trait, you can have as many other states, but note
#  If the state is already applied the new ones will be ignored.
#
# <trt noself>
#  The trait will not be included with states
#
# <trt description> </trt description>
#  Everything between these tags will go towards the traits description
#  Currently not used.
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
# Classes
#   RPG::State
#     new-method :init_trait_cache
#     new-method :trait_states
#     new-method :trait_id
#     new-method :trait_conditions
#     new-method :trait_description
#   RPG::Enemy
#     new-method :init_trait_cache
#     new-method :atraits
#   Game_Battler
#     alias      :initialize
#     alias      :states
#     new-method :check_trait_condition
#     new-method :atraits
#     new-method :active_atraits
#     new-method :atrait_states
#   Game_Enemy
#     alias      :initialize
#   Game_Actor
#     alias      :setup
#     new-method :class_traits
#     new-method :emblems
#     new-method :emblem_states
#     new-method :check_emblem_conditions
#   Scene_Title
#     alias      :load_database
#     new-method :load_trait_database
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
# (DD/MM/YYYY)
#  05/10/2014 - v2.0.0
#  01/08/2011 - V1.0a   Small Changes
#  11/??/2010 - V1.0    Finished Script
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment.
#
#------------------------------------------------------------------------------#
$simport.register('iex/traits_system', '2.0.0')
#==============================================================================
# ** IEX::TraitsSystem
#------------------------------------------------------------------------------
#==============================================================================
module IEX
  module TraitsSystem
#==============================================================================
#                           Start Primary Customization
#------------------------------------------------------------------------------
#==============================================================================
  #--------------------------------------------------------------------------#
  # * ACTOR_TRAITS
  #--------------------------------------------------------------------------#
  # actor_id => [state_id, state_id, state_id],
  #--------------------------------------------------------------------------#
    ACTOR_TRAITS = {
      0 => [],
      1 => [121, 124],
      2 => [123, 130],
      3 => [120, 125],
      4 => [127, 128],
      5 => [126, 135],
      6 => [122, 133],
      7 => [129, 132],
      8 => [131, 134],
    } # Do Not Remove
  #--------------------------------------------------------------------------#
  # * CLASS_TRAITS
  #--------------------------------------------------------------------------#
  # class_id => [state_id, state_id, state_id],
  #--------------------------------------------------------------------------#
    CLASS_TRAITS = {
      0 => [],
    }
#==============================================================================
#                           End Primary Customization
#------------------------------------------------------------------------------
#==============================================================================
  end
end

#==============================================================================
# ** Game_Battler - Lunatic
#------------------------------------------------------------------------------
#==============================================================================
class Game_Battler
  def check_trait_condition(cond_name)
    active = false
    case cond_name.to_s.upcase
    when 'ALWAYS_TRUE', 'ALWAYSTRUE', 'ALWAYS TRUE'
      active = true
    when 'ALWAYS_FALSE', 'ALWAYSFALSE', 'ALWAYS FALSE'
      active = false
    when /(?:PARTYWORTHX|PARTY_WORTHX|PARTY WORTHX):?[ ]*(\d+)/i
      wor = 0
      for mem in $game_party.members
        wor += mem.level * $1.to_i
      end
      active = $game_party.gold > wor.to_i
    when /(\w+):?[ ]*(\d+)([%%])/i
      val = $2.to_i
      rate = val / 100.0
      case $1.to_s.upcase
      when 'HP'
        active = (hp > 0) && (hp <= (maxhp * rate))
      when 'MP'
        active = mp <= (maxmp * rate)
      end
    when 'DAWN'
      active = $game_switches[ICY::ITS::DAWN_SWITCH]
    when 'DAY'
      active = $game_switches[ICY::ITS::DAY_SWITCH]
    when 'DUSK'
      active = $game_switches[ICY::ITS::DUSK_SWITCH]
    when 'NIGHT'
      active = $game_switches[ICY::ITS::NIGHT_SWITCH]
    end
    return active
  end
end

#==============================================================================
# ** IEX::TraitsSystem
#------------------------------------------------------------------------------
#==============================================================================
module IEX
  module TraitsSystem
    # Credit to Yanfly for the range to array method
    module_function
    #--------------------------------------------------------------------------
    # convert_integer_array
    #--------------------------------------------------------------------------
    def self.convert_integer_array(array)
      array.map do |i|
        case i
        when Range
          i.to_a
        when Numeric
          [i]
        end
      end.flatten
    end

    #--------------------------------------------------------------------------
    # converted_contants
    #--------------------------------------------------------------------------
    for key in ACTOR_TRAITS.keys
      ACTOR_TRAITS[key] = convert_integer_array(ACTOR_TRAITS[key])
    end

    for key in CLASS_TRAITS.keys
      CLASS_TRAITS[key] = convert_integer_array(CLASS_TRAITS[key])
    end
  end
end

#==============================================================================
# ** RPG::State
#------------------------------------------------------------------------------
#==============================================================================
class RPG::State
  def init_trait_cache
    @trt_cache_complete = false
    @trait_states = []
    @trait_id = 0
    @trait_conditions = []
    @trait_description = ''
    trt_des_on = false
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when /<(?:TRAIT_|trait |TRT_|trt )(?:STATE)s?:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
      $1.scan(/\d+/).each { |sid|
      @trait_states.push(sid.to_i) }
    when /<(?:TRAIT_ID|trait id|TRT_ID|trt id):[ ]*(\d+)>/i
      @trait_id = $1.to_i
    when /<(?:TRT_|TRAIT_|trt |trait )(?:CONDITION|cond):[ ]*(.*)>/i
      @trait_conditions << $1.to_s
    when /<(?:TRT_|TRAIT_|trt |trait )(?:DESCRIPTION|des)>/i
      trt_des_on = true
    when /<\/(?:TRT_|TRAIT_|trt |trait )(?:DESCRIPTION|des)>/i
      trt_des_on = false
    else
      @trait_description += line.to_s if trt_des_on
    end  }
    @trait_conditions << "AlwaysTrue" if @trait_conditions.empty?
    @trt_cache_complete = true
    trt_des_on = false
  end

  def trait_states
    init_trait_cache unless @trt_cache_complete
    return @trait_states
  end

  def trait_id
    init_trait_cache unless @trt_cache_complete
    return @trait_id
  end

  def trait_conditions
    init_trait_cache unless @trt_cache_complete
    return @trait_conditions
  end

  def trait_description
    init_trait_cache unless @trt_cache_complete
    return @trait_description
  end
end

#==============================================================================
# ** RPG::Enemy
#------------------------------------------------------------------------------
#==============================================================================
class RPG::Enemy
  def init_trait_cache
    @trt_trait_ids = []
    @trt_trait_cache_complete = false
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when /<(?:TRAIT_ID|trait id|TRT_ID|trt id)s?:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
      $1.scan(/\d+/).each { |sid|
      @trt_trait_ids.push(sid.to_i) }
    end
    }
    @trt_trait_cache_complete = true
  end

  def atraits
    init_trait_cache unless @trt_trait_cache_complete
    return @trt_trait_ids
  end
end

#==============================================================================
# ** Scene_Title
#------------------------------------------------------------------------------
#==============================================================================
class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------#
  # * alias load_database
  #--------------------------------------------------------------------------#
  alias iex_trt_load_database load_database unless $@
  def load_database
    iex_trt_load_database
    load_trait_database
  end

  #--------------------------------------------------------------------------#
  # * load_trait_database
  #--------------------------------------------------------------------------#
  # This loads all the trait caches so it doesn't have to during runtime
  #--------------------------------------------------------------------------#
  def load_trait_database
    for st in $data_states
      next if st == nil
      st.init_trait_cache
    end
    for en in $data_enemies
      next if en == nil
      en.init_trait_cache
    end
  end
end

#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#==============================================================================
class Game_Battler
  alias :iex_trat_initialize :initialize unless $@
  def initialize
    iex_trat_initialize
    @current_trait_checking = false
  end

  def class_traits
    return []
  end

  def atraits
    tra_lst = []
    @ttrait_ids = [] if @ttrait_ids == nil
    for sid in @ttrait_ids + class_traits
      sta = $data_states[sid]
      next if sta == nil
      tra_lst(sta)
    end
    return tra_lst
  end

  def active_atraits
    @current_trait_checking = true
    tra_lst = []
    @ttrait_ids = [] if @ttrait_ids == nil
    for sid in @ttrait_ids
      sta = $data_states[sid]
      next if sta == nil
      failed = false
      sta.trait_conditions.each do |cond|
        failed = false
        unless check_trait_condition(cond)
          failed = true
          break
        end
      end
      tra_lst.push(sta) unless failed
    end
    @current_trait_checking = false
    return tra_lst
  end

  def atrait_states
    return active_atraits
  end

  alias :iex_trait_sstates :states unless $@
  def states
    result = iex_trait_sstates
    result |= atrait_states unless @current_trait_checking
    return result
  end
end

#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#==============================================================================
class Game_Enemy < Game_Battler
  alias :iex_traits_initialize :initialize unless $@
  def initialize(*args)
    @ttrait_ids = []
    iex_traits_initialize(*args)
    @ttrait_ids = enemy.atraits
  end
end

#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#==============================================================================
class Game_Actor < Game_Battler
  alias :iex_traits_setup :setup unless $@
  def setup(*args)
    @ttrait_ids = []
    iex_traits_setup(*args)
    if IEX::TraitsSystem::ACTOR_TRAITS.has_key?(@actor_id)
      @ttrait_ids = IEX::TraitsSystem::ACTOR_TRAITS[@actor_id].clone
    else
      @ttrait_ids = IEX::TraitsSystem::ACTOR_TRAITS[0].clone
    end
  end

  def class_traits
    if IEX::TraitsSystem::CLASS_TRAITS.has_key?(@class_id)
      return IEX::TraitsSystem::CLASS_TRAITS[@class_id].clone
    else
      return IEX::TraitsSystem::CLASS_TRAITS[0].clone
    end
  end
end
