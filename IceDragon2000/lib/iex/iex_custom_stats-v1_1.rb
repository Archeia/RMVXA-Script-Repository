#==============================================================================#
# ** IEX(Icy Engine Xelion) - Custom Stats
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Battler Stats)
# ** Script Type   : Custom Stats
# ** Date Created  : 1?/??/2010 (DD/MM/YYYY)
# ** Date Modified : 07/17/2011 (DD/MM/YYYY)
# ** Script Tag    : IEX - Custom Stats
# ** Difficulty    : Easy, Medium, Hard, Lunatic
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# *WARNING* It is almost impossible to directly target an error thrown by this 
# script, this is due to it being mostly meta-programmed.
# This script is intended for mostly scripter use...
# Its made to be lazy alternative to creating custom stats.
# Don't complain.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FEATURES
#------------------------------------------------------------------------------#
#
# Custom Base Stat formulae for every Actor, you can add and remove, stats that
# should be affected from the STATS array.
# Also you can add more custom base stats if needed.
#
#------------------------------------------------------------------------------#
=begin 
   Notetags - If your familiar with Melody or other Yanfly scripts
              this should be easy. You can change any expression in the
              REGEX TAGS section
    # Default expression used for Stat changes
      :stat_change1    => /<(\w+)[ ]*:?[ ]*([\+\-]?\d+)>/i,
      :stat_change2    => /<(\w+)[ ]*:?[ ]*([\+\-]?\d+)([%%])>/i,
      # EG  <firepower: 20>  # Changes by 20 points
      # EG2 <firepower: 20%> # Changes by 20%
    # Default expression used for Regeneration
      :stat_regen1     => /<(\w+)[ ](?:REGEN):?[ ]*(\d+)>/i,
      :stat_regen2     => /<(\w+)[ ](?:REGEN):?[ ]*(\d+)([%%])>/i,
      # EG  <gunpowder regen: 20>  # Recovers a steady 20 points
      # EG2 <gunpowder regen: 20%> # Recovers by 20%
    # Default expression used for Degeneration  
      :stat_degen1     => /<(\w+)[ ](?:DEGEN):?[ ]*(\d+)>/i,
      :stat_degen2     => /<(\w+)[ ](?:DEGEN):?[ ]*(\d+)([%%])>/i,
      # EG  <gunpowder degen: 20>  # Loses a steady 20 points
      # EG2 <gunpowder degen: 20%> # Degenerates by 20%
    # Default expression used for Anti-Regens  
      :stat_anti_regen => /<(\w+)[ ](?:ANTI_REGEN|anti regen|antiregen)>/i,
    # Default expression used for Anti-Degens    
      :stat_anti_degen => /<(\w+)[ ](?:ANTI_DEGEN|anti degen|antidegen)>/i,
      # EG  <gunpowder anitdegen> # Degen states for gunpowder are ineffective
      # EG2 <gunpowder anitregen> # Regen states for gunpowder are ineffective
      
   In short
   Valid for Enemy / Equipment / States
   <stat: +/-x>
   <stat: +/-x%>
   
   Valid for states only.
   <stat regen: x>
   <stat regen: x%>
   <stat degen: x>
   <stat degen: x%>
   <stat antiregen>
   <stat antidegen>
   
   - QUICK JUMPS -
       RGXTGCSS2 - Regex Tags
       GBTCSS2   - Base Stat Formulae
=end
#==============================================================================#
# ** CHANGES 
#------------------------------------------------------------------------------#
# ** - For non Melody users
# (stat) - Substitue for actual stat
# Modules
#   Vocab
#     meta-prog  - Vocabulary for new stats
# Classes
#   Game_Battler
#   **new-method :stack  
#   **new-method :perform_slip_effect
#   **overwrite  :slip_damage_effect
#     alias      :initialize
#     alias      :perform_slip_effect
#     new-method :custom_base_formula
#     new-method :anti_regens
#     new-method :anti_degens
#     new-method :anti_stat_regen?(stat)
#     new-method :anti_stat_degen?(stat)
#     new-method :css2_slip_damage
#   Game_Battler, Game_Enemy, Game_Actor
#     meta-prog  - Stats
#   RPG::BaseItem, RPG::State, RPG::Enemy
#     new-method :iex_css2_cache
#     meta-prog  >>
#     (stat)_set
#     (stat)_rate
#     (stat)_set=(val)
#     (stat)_rate=(val)
#     (stat)
#     <<
#   RPG::State
#     new-method :iex_css2_state_cache
#     new-method :css2_slipDamage?
#     new-method :css2_slipDamageRates
#     new-method :css2_slipDamageSets
#     new-method :css2_AntiRegens
#     new-method :css2_AntiDegens  
#   Scene_Title
#     alias      :load_database
#     new-method :iex_css2_cache_load
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#------------------------------------------------------------------------------#
# 
# Below 
#  Materials
#  Below Custom Battle Systems
# Above 
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
#
# (DD/MM/YYYY)
#  1?/??/2010 - BETA  Started Script
#  12/29/2010 - V1.0  Completed Script
#  01/08/2011 - V1.0a Few changes, nothing to mention really.
#  07/17/2011 - V1.1  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#  
#
#  Errors are hard to locate.
#
#------------------------------------------------------------------------------#
$imported ||= {} 
$imported["IEX_CustomStats"] = true
#==============================================================================#
# ** IEX::Custom_Stats
#==============================================================================#
module IEX
  module Custom_Stats
#==============================================================================#
#                        Start Basic Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  #--------------------------------------------------------------------------#
  # * STATS 
  #--------------------------------------------------------------------------#
  # The following hash serves 2 purposes.
  # 1 Showing the stats to be created, 2 Vocab assignment
  # When creating a new stat.
  # DO
  # :nameofstat => ["Abreviation", "FullName"],
  # 
  # DONT DO
  # :I'manDa    => [Abre, Fullanme],
  # :ImAmAmA    => [:abre, :fullname],
  # :12Asas     => [],
  # 
  #--------------------------------------------------------------------------#
    STATS = { # DO NOT REMOVE
    # Symbol    => ["Abrv", "Full"],
      :en       => ["EN", "Energy"],
      :link     => ["LNK", "Link" ],
      :bombfuse => ["BMB", "Bombs"]
    } # DO NOT REMOVE

  #--------------------------------------------------------------------------#
  # * BEHAVIOUR / PROPERTIES
  #--------------------------------------------------------------------------#
  # When ever you add a new stat to the STATS.
  # Several new methods and changes occur.
  #--------------------------------------------------------------------------#
=begin
  - RPG::State / RPG::BaseItem / RPG::Enemy-
  (stat) or (stat)_set - This returns the value for the stat
  (stat)=              - This assigns the value for the stat
  (stat)_rate          - This returns the rate for the stat
  (stat)_rate=         - This assigns the rate for the stat
  
  - RPG::State -
  css2_slipDamage?     - Is this a valid custom stat slip state?
  
  css2_slipDamageRates 
  css2_slipDamageSets  - Returns a hash with the stat (symbol) as the key
  
  css2_AntiRegens      - Returns and array with stats (symbols), which will be 
                         negated for regeneration
  css2_AntiDegens      - Returns and array with stats (symbols), which will be 
                         negated for degeneration
   
  # These are added to the base_(stat)
  # If its a healable type, its added to the base_max_stat
  
  - Vocab -
  (stat)               - Returns the full name of the stat
  (stat)_a             - Returns the abreviation of the stat
  
  - Game_Battler -
  # Normal      - Normal Properties
  base_(stat)          - This returns the base value for the stat
  (stat)               - This returns the value for the stat
  (stat)=              - This assigns the bonus value for the stat
  
  # :healable   - When the healable behavior is applied, multiple changes occur
  base_max(stat)       - This returns the base_max value for the stat
  max(stat)            - This returns the max stat (Added along with the base)
  max(stat)=           - This assigns a value to the max stat
  (stat)=              - This is an assigment for the stat (Works just like hp=)
  @(stat)              - A instance variable is created, this is the stats value
  @(stat)_plus         - A instance variable is created, this is the stats bonus (For its base)
  attr_reader :(stat)  - Though I could have just wrote a method to return the value
                         I decided to use and attr_reader instead.
  #--------------------------------------------------------------------------#                         
  Note All of these are meta-programmed into the necessary locations.
  
  Example of what you will actually do.
  Lets say you have a stat :blades
  with the :healable behaviour
  You can access things like this -
    $game_actors[1].blades
    Vocab.blades
    $data_weapons[1].blades_set
  You can assign like this
    $data_weapons[1].blades = 24
    $game_actors[1].blades = 2
  #--------------------------------------------------------------------------#
  Valid Behaviours / Properties are
  :equip    - The stat can be affected by equipment
  :state    - The stat can be affected by states
  :healable - The stat can be recovered and altered at will
  :regen *  - This will only work if Both the :state and :healable properties are
              present, this will allow the stat to regenerate, or degenerate from
              states.
=end
    BEHAVIOUR = {
  #   :stat     => [:etc], 
  # You can always have it empty if you like.
  #   :stat     => [ ],
      :en       => [:equip, :state, :regen, :healable],
      :link     => [:equip, :state, :regen, :healable],
      :bombfuse => [:equip, :state, :regen, :healable],
    } # DO NOT REMOVE
#==============================================================================#
#                          End Bssic Customization
#------------------------------------------------------------------------------#
#==============================================================================#
#==============================================================================#
#                       Start Customization - Lunatic
#------------------------------------------------------------------------------#
#==============================================================================#
  #--------------------------------------------------------------------------#
  # * RGXTGCSS2 - REGEX_TAGS
  #--------------------------------------------------------------------------#
  # Normally I would throw this into my REGEXP module directly..
  # But for the sake of convenience....
  #--------------------------------------------------------------------------#
    REGEX_TAGS = {
    # Default expression used for Stat changes
      :stat_change1    => /<(\w+)[ ]*:?[ ]*([\+\-]?\d+)>/i,
      :stat_change2    => /<(\w+)[ ]*:?[ ]*([\+\-]?\d+)([%%])>/i,
      # EG  <firepower: 20>  # Changes by 20 points
      # EG2 <firepower: 20%> # Changes by 20%
    # Default expression used for Regeneration
      :stat_regen1     => /<(\w+)[ ](?:REGEN):?[ ]*(\d+)>/i,
      :stat_regen2     => /<(\w+)[ ](?:REGEN):?[ ]*(\d+)([%%])>/i,
      # EG  <gunpowder regen: 20>  # Recovers a steady 20 points
      # EG2 <gunpowder regen: 20%> # Recovers by 20%
    # Default expression used for Degeneration  
      :stat_degen1     => /<(\w+)[ ](?:DEGEN):?[ ]*(\d+)>/i,
      :stat_degen2     => /<(\w+)[ ](?:DEGEN):?[ ]*(\d+)([%%])>/i,
      # EG  <gunpowder degen: 20>  # Loses a steady 20 points
      # EG2 <gunpowder degen: 20%> # Degenerates by 20%
    # Default expression used for Anti-Regens  
      :stat_anti_regen => /<(\w+)[ ](?:ANTI_REGEN|anti regen|antiregen)>/i,
    # Default expression used for Anti-Degens    
      :stat_anti_degen => /<(\w+)[ ](?:ANTI_DEGEN|anti degen|antidegen)>/i,
      # EG  <gunpowder anitdegen> # Degen states for gunpowder are ineffective
      # EG2 <gunpowder anitregen> # Regen states for gunpowder are ineffective
    } # DO NOT REMOVE
      
  end # End Custom_Stats
end # End IEX

#==============================================================================#
# ** GBTCSS2 - Game_Battler - Lunatic
#==============================================================================#
class Game_Battler
  
  #--------------------------------------------------------------------------#
  # * custom_base_formula - This is normally ineffective with enemies..
  #--------------------------------------------------------------------------#
  def custom_base_formula(stat)
    value = 0
    case stat.to_s.downcase
  #--------------------------------------------------------------------------#
  # * Start here
  #--------------------------------------------------------------------------#
    when :link
      value = [@level / 4, 1].max + 1
    when :bombfuse
      value = [@level / 4, 1].max + 1
  #--------------------------------------------------------------------------#
  # * End here for custom
  #--------------------------------------------------------------------------#
    else
      value = 0
  #--------------------------------------------------------------------------#
  # * End here for else
  #--------------------------------------------------------------------------#   
    end  
    return value
  end
  
end

#==============================================================================#
#                            End Customization!!!
#------------------------------------------------------------------------------#
# STOP, TOMARE!! >.< What the hell? Do you want to end up in the hospital.
# @_@ You will have SERIOUS headaches if you continue.
#==============================================================================#

#==============================================================================#
# ** Vocab
#==============================================================================#
module Vocab
  
  IEX::Custom_Stats::STATS.keys.each { |sta|
    sta = sta.to_s.downcase
    aStr = %Q(
      # Stat
      def self.#{sta}
        return IEX::Custom_Stats::STATS['#{sta}'.to_sym][1]
      end

      # Stat (Abbreviation)
      def self.#{sta}_a
        return IEX::Custom_Stats::STATS['#{sta}'.to_sym][0]
      end
    )
    module_eval(aStr)
  }
  
end

#==============================================================================#
# ** IEX
#==============================================================================#
module IEX
#==============================================================================#
# ** Custom_Stats
#==============================================================================#
  module Custom_Stats
    def self.valid_regen_type?(sta)
      sta = sta.to_s.downcase.to_sym
      return false if BEHAVIOUR[sta] == nil
      ans = (BEHAVIOUR[sta].include?(:regen) && BEHAVIOUR[sta].include?(:healable))
      return ans
    end  
  end  
#==============================================================================#
# ** IMath
#==============================================================================#
  module IMath
    
    def self.cal_percent(perc, val)
      ans = val.to_i
      ans *= 100.0
      ans = ans * (perc.to_i / 100.0)
      ans /= 100.0
      return Integer(ans)
    end  
    
  end
#==============================================================================#
# ** REGEXP::Custom_Stats
#==============================================================================#
  module REGEXP
    module Custom_Stats
      STAT_CHANGE1 = IEX::Custom_Stats::REGEX_TAGS[:stat_change1] # Set
      STAT_CHANGE2 = IEX::Custom_Stats::REGEX_TAGS[:stat_change2] # Rate
      STAT_REGEN1  = IEX::Custom_Stats::REGEX_TAGS[:stat_regen1]
      STAT_REGEN2  = IEX::Custom_Stats::REGEX_TAGS[:stat_regen2]
      STAT_DEGEN1  = IEX::Custom_Stats::REGEX_TAGS[:stat_degen1]
      STAT_DEGEN2  = IEX::Custom_Stats::REGEX_TAGS[:stat_degen2]
      STAT_ANTI_R  = IEX::Custom_Stats::REGEX_TAGS[:stat_anti_regen]
      STAT_ANTI_D  = IEX::Custom_Stats::REGEX_TAGS[:stat_anti_degen]
    end  
  end
end

#==============================================================================#
# ** RPG 
#==============================================================================#
module RPG
#==============================================================================#
# ** BaseItem / State / Enemy
#==============================================================================#
['BaseItem', 'State', 'Enemy'].each { |klass|
  meth = '#{meth}' # Dummy Method name, when the first Eval is done, it will escape
                   # the quotes, this allows the sub evaluation.
  cStr = %Q(
    class #{klass}
    
      def iex_css2_cache
        @iex_css2_cache_complete = false
        @css2_stat_sets = {}
        @css2_stat_rates = {}
        IEX::Custom_Stats::STATS.keys.each { |sta|
          @css2_stat_sets[sta.to_s.downcase]  = 0
          @css2_stat_rates[sta.to_s.downcase] = 0
        }  
        self.note.split(/[\r\n]+/).each { |line|
        case line
        when IEX::REGEXP::Custom_Stats::STAT_CHANGE1
          @css2_stat_sets[$1.to_s.downcase] = $2.to_i
        when IEX::REGEXP::Custom_Stats::STAT_CHANGE1
          @css2_stat_rates[$1.to_s.downcase] = $2.to_i
        end
        }
        @iex_css2_cache_complete = true
      end 
 
    IEX::Custom_Stats::STATS.keys.each { |meth|
    meth = meth.to_s.downcase
    aStr = %Q(
      
      def #{meth}
        iex_css2_cache unless @iex_css2_cache_complete
        return Integer(@css2_stat_sets['#{meth}'])
      end
      
      def #{meth}=(val)
        iex_css2_cache unless @iex_css2_cache_complete
        @css2_stat_sets['#{meth}'] = val
      end 
      
      def #{meth}_set
        iex_css2_cache unless @iex_css2_cache_complete
        return Integer(@css2_stat_sets['#{meth}'])
      end
      
      def #{meth}_rate
        iex_css2_cache unless @iex_css2_cache_complete
        return @css2_stat_rates['#{meth}']
      end  
      
      def #{meth}_rate=(val)
        iex_css2_cache unless @iex_css2_cache_complete
        @css2_stat_rates['#{meth}'] = val
      end 
      
      )
    module_eval(aStr)
  }
end

  )
  module_eval(cStr)
} 
#==============================================================================#
# ** State
#==============================================================================#
  class State
    
  #--------------------------------------------------------------------------#
  # * new-method :iex_css2_state_cache
  #--------------------------------------------------------------------------#  
    def iex_css2_state_cache()
      @css2_state_cache_complete = false
      @css2_slipDamageRates = {}
      @css2_slipDamageSets  = {}
      @css2_AntiRegens = []
      @css2_AntiDegens = []
      @css2_slip_damage = false
      self.note.split(/[\r\n]+/).each { |line|
      case line
      when IEX::REGEXP::Custom_Stats::STAT_REGEN1
        next unless IEX::Custom_Stats.valid_regen_type?($1.to_s.downcase)
        @css2_slipDamageSets[$1.to_s.downcase]  = -$2.to_i
        @css2_slip_damage = true
      when IEX::REGEXP::Custom_Stats::STAT_REGEN2
        next unless IEX::Custom_Stats.valid_regen_type?($1.to_s.downcase)
        @css2_slipDamageRates[$1.to_s.downcase] = -$2.to_i
        @css2_slip_damage = true
      when IEX::REGEXP::Custom_Stats::STAT_DEGEN1  
        next unless IEX::Custom_Stats.valid_regen_type?($1.to_s.downcase)
        @css2_slipDamageSets[$1.to_s.downcase]  = $2.to_i
        @css2_slip_damage = true
      when IEX::REGEXP::Custom_Stats::STAT_DEGEN2  
        next unless IEX::Custom_Stats.valid_regen_type?($1.to_s.downcase)
        @css2_slipDamageRates[$1.to_s.downcase] = $2.to_i
        @css2_slip_damage = true
      when IEX::REGEXP::Custom_Stats::STAT_ANTI_R
        @css2_AntiRegens.push($1.to_s.downcase)
      when IEX::REGEXP::Custom_Stats::STAT_ANTI_D  
        @css2_AntiDegens.push($1.to_s.downcase)
      end  
      }
      @css2_state_cache_complete = true
    end
    
  #--------------------------------------------------------------------------#
  # * new-method :css2_slipDamage?
  #--------------------------------------------------------------------------#    
    def css2_slipDamage?()
      iex_css2_state_cache unless @css2_state_cache_complete 
      return @css2_slip_damage 
    end
    
  #--------------------------------------------------------------------------#
  # * new-method :css2_slipDamageRates
  #--------------------------------------------------------------------------#      
    def css2_slipDamageRates()
      iex_css2_state_cache unless @css2_state_cache_complete 
      return @css2_slipDamageRates
    end  
    
  #--------------------------------------------------------------------------#
  # * new-method :css2_slipDamageSets
  #--------------------------------------------------------------------------#      
    def css2_slipDamageSets()
      iex_css2_state_cache unless @css2_state_cache_complete 
      return @css2_slipDamageSets
    end
  
  #--------------------------------------------------------------------------#
  # * new-method :css2_AntiRegens
  #--------------------------------------------------------------------------#      
    def css2_AntiRegens()
      iex_css2_state_cache unless @css2_state_cache_complete 
      return @css2_AntiRegens
    end
    
  #--------------------------------------------------------------------------#
  # * new-method :css2_AntiDegens
  #--------------------------------------------------------------------------#        
    def css2_AntiDegens()  
      iex_css2_state_cache unless @css2_state_cache_complete 
      return @css2_AntiDegens
    end  
    
  end  
end

#==============================================================================#
# ** Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base
  
  #--------------------------------------------------------------------------#
  # * alias-method :load_database
  #--------------------------------------------------------------------------#  
  alias :iex_css2_load_database :load_database unless $@
  def load_database( *args, &block )
    iex_css2_load_database( *args, &block )
    iex_css2_cache_load()
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_css2_cache_load
  #--------------------------------------------------------------------------#  
  def iex_css2_cache_load()
    groups = [$data_weapons, $data_armors, $data_items, $data_states]
    groups.each { |group|
      group.compact.each { |obj|
        next if obj == nil
        obj.iex_css2_cache
        obj.iex_css2_state_cache if obj.is_a?(RPG::State)
      }  
    }  
  end
  
end

#==============================================================================#
# ** Game_Battler
#==============================================================================#
class Game_Battler 

  IEX::Custom_Stats::STATS.keys.each { |meth|
    meth = meth.to_s.downcase
    if IEX::Custom_Stats::BEHAVIOUR[meth.to_sym].include?(:healable)
      aStr = "attr_reader :#{meth}"
      module_eval(aStr)
    end
  }   
  
  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#        
  alias :iex_css2_initialize :initialize unless $@
  def initialize( *args, &block )
    @level = 1
    iex_css2_initialize( *args, &block )
    IEX::Custom_Stats::STATS.keys.each { |meth|
      meth = meth.to_s.downcase
      vStr = "@#{meth}_plus = 0"
      eval(vStr)
      if IEX::Custom_Stats::BEHAVIOUR[meth.to_sym].include?(:healable)
        vStr2 = "@#{meth} = 0"
        eval(vStr2)
      end  
    }
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :stack
  #--------------------------------------------------------------------------#    
  def stack(sta_id) ; return 1 ; end unless method_defined?(:stack)
    
  #--------------------------------------------------------------------------#
  # * new-method :anti_regens
  #--------------------------------------------------------------------------#   
  def anti_regens()
    result = []
    for state in states ; result |= state.css2_AntiRegens ; end
    return result
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :anti_degens
  #--------------------------------------------------------------------------#   
  def anti_degens
    result = []
    for state in states ; result |= state.css2_AntiDegens ; end
    return result
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :anti_stat_regen?
  #--------------------------------------------------------------------------#   
  def anti_stat_regen?( stat )
    stat = stat.to_s
    return anti_regens.include?( stat )
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :anti_stat_degen?
  #--------------------------------------------------------------------------#  
  def anti_stat_degen?( stat )
    stat = stat.to_s
    return anti_degens.include?(stat)
  end
  
  #--------------------------------------------------------------------------#
  # * overwrite-method :slip_damage_effect
  #--------------------------------------------------------------------------#
  def slip_damage_effect()
    return unless self.slip_damage?()
    for state in states ; perform_slip_effect( state ) ; end
  end unless $imported["BattleEngineMelody"]
    
  #--------------------------------------------------------------------------#
  # * new-method :perform_slip_effect
  #--------------------------------------------------------------------------#  
  def perform_slip_effect(state)
    if slip_damage? and @hp > 0
      @hp_damage = apply_variance(maxhp / 10, 10)
      @hp_damage = @hp - 1 if @hp_damage >= @hp
      self.hp -= @hp_damage
    end
  end unless method_defined?(:perform_slip_effect) 
  
  #--------------------------------------------------------------------------#
  # * alias-method :perform_slip_effect
  #--------------------------------------------------------------------------#
  alias :iex_css2_pse :perform_slip_effect unless $@
  def perform_slip_effect(state)
    css2_slip_damage(state)
    iex_css2_pse(state)    
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :css2_slip_damage
  #--------------------------------------------------------------------------#  
  def css2_slip_damage( state )
    return if state.nil?()
    return unless self.exist?()
    return unless state.css2_slipDamage?()
    cHash = {}
    hash1 = state.css2_slipDamageSets
    hash2 = state.css2_slipDamageRates
    for sta in hash1.keys
      stat_dmg = 0  
      stat_dmg += hash1[sta]
      stat_dmg *= stack(state)
      cHash[sta] = 0 if cHash[sta] == nil
      cHash[sta] += stat_dmg
    end 
    for sta in hash2.keys
      stat_dmg = 0  
      stat_dmg += IEX::IMath.cal_percent(hash2[sta], eval("max#{sta}")) 
      stat_dmg *= stack(state)
      cHash[sta] = 0 if cHash[sta] == nil
      cHash[sta] += stat_dmg
    end
    for sta in cHash.keys
      stat_dmg = cHash[sta]
      stat_dmg = 0 if anti_stat_regen?(sta) if stat_dmg < 0
      stat_dmg = 0 if anti_stat_degen?(sta) if stat_dmg > 0
      if stat_dmg != 0
        aEva = "@#{sta} = [[@#{sta} - stat_dmg, max#{sta}].min, 0].max"
        eval(aEva)
        #if $imported["BattleEngineMelody"]
        #  pos_sym_sta = (sta.to_s+"_HEAL").to_s.downcase.to_sym
        #  neg_sym_sta = (sta.to_s+"_DMG").to_s.downcase.to_sym
        #  if stat_dmg > 0
        #    rules  = IEX::CustomStats::CusMelodyRules[neg_sym_sta.to_s.upcase]
        #    sprint = IEX::CustomStats::CusMelodyPopSettings[neg_sym_sta]
        #  else  
        #    rules  = IEX::CustomStats::CusMelodyRules[pos_sym_sta.to_s.upcase]
        #    sprint = IEX::CustomStats::CusMelodyPopSettings[pos_sym_sta]
        #  end  
        #  value  = stat_dmg.to_i
        #  value  = sprintf(sprint, value)
        #  create_popup(value, rules) if $scene.is_a?(Scene_Battle)
        #end  
      end  
    end  
  end
  IEX::Custom_Stats::STATS.keys.each { |meth|
    meth = meth.to_s.downcase
    if IEX::Custom_Stats::BEHAVIOUR[meth.to_sym].include?(:healable)
      bsStr = %Q( 
      def base_max#{meth}
        n = custom_base_formula('#{meth}'.to_sym)
        return Integer(n)
      end
        
      def max#{meth}
        n = [base_max#{meth} +  @#{meth}_plus, 1].max
        if IEX::Custom_Stats::BEHAVIOUR['#{meth}'.to_sym].include?(:state)
          for state in states
            stack(state).times do
              n += IEX::IMath.cal_percent(state.#{meth}_rate, n)
            end
          end
          for state in states
            next if state.#{meth}_set == 0
            n += state.#{meth}_set * stack(state)
          end 
        end
        @#{meth} = [Integer(@#{meth}), Integer(n)].min
        return Integer(n)
      end 
  
      def max#{meth}=(val)
        @max#{meth}_plus += val - self.max#{meth}
        @max#{meth}_plus = [[@max#{meth}_plus, -9999].max, 9999].min
        @#{meth} = [@#{meth}, self.max#{meth}].min
      end 
      
      def #{meth}=(val)
        @#{meth} = [[val, max#{meth}].min, 0].max
      end
  
      )
      module_eval(bsStr)
    else
      bsStr = %Q(
      def base_#{meth}
        n = 1
        n = custom_base_formula('#{meth}'.to_sym)
        return Integer(n)
      end
      
      def #{meth}
        n = [base_#{meth} +  @#{meth}_plus, 1].max
        if IEX::Custom_Stats::BEHAVIOUR['#{meth}'.to_sym].include?(:state)
          for state in states
            stack(state).times do
              n += IEX::IMath.cal_percent(state.#{meth}_rate, n)
            end
          end
          for state in states
            next if state.#{meth}_set == 0
            n += state.#{meth}_set * stack(state)
          end 
        end
        return Integer(n)
      end 
      
      def #{meth}=(val)
        @#{meth}_plus += val - self.#{meth}
      end 
    )
      module_eval(bsStr)
    end  
  } 
  
end # Game Battler

#==============================================================================#
# ** Game_Enemy
#==============================================================================#
class Game_Enemy < Game_Battler
  
  IEX::Custom_Stats::STATS.keys.each { |meth|
    meth = meth.to_s.downcase
    if IEX::Custom_Stats::BEHAVIOUR[meth.to_sym].include?(:healable)
      aStr = %Q(
    
        def base_max#{meth}
          n = enemy.max#{meth}
          return Integer(n)
        end
  
      )
    else
      aStr = %Q(
    
        def base_#{meth}
          n = enemy.#{meth}
          return Integer(n)
        end
  
      )
    end
  module_eval(aStr)
  }
  
end # Game Enemy

#==============================================================================#
# ** Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler
  
  IEX::Custom_Stats::STATS.keys.each { |meth|
    meth = meth.to_s.downcase
    if IEX::Custom_Stats::BEHAVIOUR[meth.to_sym].include?(:healable)
    aStr = %Q(
    
      def base_max#{meth}
        n = super
        if IEX::Custom_Stats::BEHAVIOUR['#{meth}'.to_sym].include?(:equip)
          for eq in equips
            next if eq == nil
            n += eq.#{meth}
            n += IEX::IMath.cal_percent(eq.#{meth}_rate, n)
          end  
        end  
        return Integer(n)
      end
       
    )
    else
    aStr = %Q(
    
      def base_#{meth}
        n = super
        if IEX::Custom_Stats::BEHAVIOUR['#{meth}'.to_sym].include?(:equip)
          for eq in equips
            next if eq == nil
            n += eq.#{meth}
            n += IEX::IMath.cal_percent(eq.#{meth}_rate, n)
          end  
        end  
        return Integer(n)
      end
       
    )
    end
  module_eval(aStr)
  }
  
end # Game Actor

#==============================================================================#
# ** END OF FILE
#==============================================================================#