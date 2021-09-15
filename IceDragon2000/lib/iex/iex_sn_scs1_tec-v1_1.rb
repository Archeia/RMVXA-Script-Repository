#==============================================================================#
# ** IEX(Icy Engine Xelion) - Swordcraft Story TEC STAT
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Actor Stat)
# ** Script Type   : New Stat
# ** Date Created  : 12/05/2010 (DD/MM/YYYY)
# ** Date Modified : 01/03/2011 (DD/MM/YYYY)
# ** Script Tag    : IEX - SN-SwdCrftStry TEC
# ** Difficulty    : Easy
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# This script adds a new stat to your actors, called TEC.
# -What is TEC?
# Well (Its got alot, of uses), but in this case.
# It is "Techincal", this stat changes with weapon use.
# Each weapon has its own TEC.
#
# -So what does TEC do?
# >.> Well in SN - Swordcraft Story, more TEC meant faster, and stronger attacks.
# In this script you can choose the stat changes you want.
#
# NOTE. The changes are only visible on the wielder, when the weapon is equipped
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** HOW TO USE
#------------------------------------------------------------------------------#
# Notetags - Weapons (Apply to Weapon's Notebox)
#------------------------------------------------------------------------------#
# <TEC_CAP: x>
# This changes the weapons TEC_CAP (Limit).
# 
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#------------------------------------------------------------------------------#
# 
# Below 
#  Materials
#  Custom Battle Systems
#  Anything that Changes the attack_effect
#
# Above 
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES 
#------------------------------------------------------------------------------#
# Modules
#   Vocab
#     new-method :tec
#  
# Classes
#   RPG::Skill
#     new-method :iex_snsw_tec_rpgs_cache
#     new-method :tec_rate 
#   RPG::Weapon
#     new-method :iex_snsw_tec_rpgw_cache
#     new-method :tec_cap
#     new-method :ctec
#     new-method :increase_tec
#     new-method :decrease_tec
#   Scene_Title
#     alias      :load_database
#     new-method :load_tec_database
#   Game_Battler
#     alias      :attack_effect
#     alias      :skill_effect
#     new-method :process_tec
#     new-method :tec
#     new-method :tecmax
#     new-method :increase_tec
#     new-method :decrease_tec
#   Game_Actor
#     overwrite  :tec
#     overwrite  :tecmax
#     overwrite  :increase_tec
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
#
# (DD/MM/YYYY)
#  12/05/2010 - V1.0  Started and Finsihed Script
#  01/03/2011 - V1.0  Realeased Script
#  01/16/2011 - V1.1  Several Improvements, added database preping,
#                     added a small lunatic section, to change tec increases.
#                     Skills can now raise tec. Skills also have a tec_rate.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#  
#
#  Non at the moment
#
#------------------------------------------------------------------------------#
$imported = {} if $imported == nil
$imported["IEX_SN_SWDCRFTSTRY_TEC"] = true

#==============================================================================
# ** IEX::TEC
#------------------------------------------------------------------------------
#==============================================================================
module IEX
  module TEC
#==============================================================================
#                           Start Customization
#------------------------------------------------------------------------------
#==============================================================================
  #--------------------------------------------------------------------------#
  # * DEFAULT_TEC_CAP
  #--------------------------------------------------------------------------#
  # If the <TEC_CAP: x> tag isn't used, to change a weapons tec cap.
  # Then is this becomes the deafult.
  #--------------------------------------------------------------------------#
    DEFAULT_TEC_CAP = 100
  #--------------------------------------------------------------------------#
  # * AFFECTS - TEC_RATES 
  #--------------------------------------------------------------------------#
  # AFFECTS is all the stats that can be, changed by the TEC
  # Valid stats are:
  # 'maxhp' 'maxmp'
  # 'atk' 'def' 'agi' 'spi' 
  # 'dex' 'res' If you have YEM - New Battle Stats
  # You can also use it on the IEX - Custom Stats, as long as they are not
  # :healable
  #
  # TEC_RATES handles the Stas Change Rate. 
  # 'all' is the deafult for unstated stats
  # simply add the name of the stat on the left and the rate on the right
  # The following Equation is used for Calculating TEC changes
  # (tec * rate / 100)
  #--------------------------------------------------------------------------#  
    AFFECTS = ['atk', 'agi', 'dex']
    TEC_RATES = {
      'all' => 60, # This is the Default for all the AFFECTS, DO NOT REMOVE
    }
    
  #--------------------------------------------------------------------------#
  # * TEC_MANAGEMENT
  #--------------------------------------------------------------------------#
  # This is very important as it affects how the TEC is stored
  #   0 - On Actor
  #   1 - On Weapon
  # By Default the management is 0
  # Use 1 when you have custom scripts that can make multiple copies of the
  # weapon.
  #--------------------------------------------------------------------------#
    # 0 On actor, 1 On Weapon (Use this if you save the Weapons data)
    TEC_MANAGEMENT = 0     
  end
end

#==============================================================================
# ** Vocab
#------------------------------------------------------------------------------
#==============================================================================
module Vocab # Don't touch
  
  def self.tec # Don't touch
    return "TEC" #<-- Change the string to whatever you like
  end # Don't touch
  
end # Don't touch

#==============================================================================
# ** Game_Battler - Lunatic
#------------------------------------------------------------------------------
#==============================================================================
class Game_Battler
  
  #--------------------------------------------------------------------------#
  # * process
  #--------------------------------------------------------------------------#
  # This handles tec changes for attacks, and skills
  #--------------------------------------------------------------------------#
  def process_tec(attacker, target, obj = nil)
    allowed = true
    allowed = obj.physical_attack unless obj.nil?
    gain = 0 # Set to 0 at start
    if allowed
      gain = 1 # This is the amount gained normally
      gain = gain * 2 if target.critical # Multiple it by 2 if critical
      gain += obj.tec_rate / attacker.tecmax * 100.0 unless obj.nil?
    end  
    attacker.increase_tec(Integer(gain)) # Gain tec
  end
  
end  

#==============================================================================
#                           End Customization
#------------------------------------------------------------------------------
#==============================================================================
#==============================================================================
# ** RPG::Skill
#------------------------------------------------------------------------------
#==============================================================================
class RPG::Skill
  
  def iex_snsw_tec_rpgs_cache
    @iex_snsw_tec_rpgs_cache_complete = false
    @tec_rate = 100
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when /<(?:TECRATE|TEC_RATE|TEC RATE):[ ]*(\d+)([%%])>/i
      @tec_rate = $1.to_i
    end  
    }
    @iex_snsw_tec_rpgs_cache_complete = true
  end
  
  def tec_rate
    iex_snsw_tec_rpgs_cache unless @iex_snsw_tec_rpgs_cache_complete 
    return @tec_rate 
  end
  
end  

#==============================================================================
# ** RPG::Weapon
#------------------------------------------------------------------------------
#==============================================================================
class RPG::Weapon
  
  attr_accessor :tec_array # If using the Weapon Store TEC then this is used
  
  def iex_snsw_tec_rpgw_cache
    @tec_array = {} # Its keys are actor ids
    @iex_snsw_tec_rpgw_cache_complete = false
    @iex_tec_cap = IEX::TEC::DEFAULT_TEC_CAP
    self.note.split(/[\r\n]+/).each { |line| 
    case line
    when /<(TECCAP|TEC_CAP|tec cap):[ ]*(\d+)>/i
      @iex_tec_cap = $1.to_i
    end  }
    @iex_snsw_tec_rpgw_cache_complete = true
  end
  
  def tec_cap
    iex_snsw_tec_rpgw_cache unless @iex_snsw_tec_rpgw_cache_complete
    return @iex_tec_cap
  end
  
  def ctec(actor_id)
    iex_snsw_tec_rpgw_cache unless @iex_snsw_tec_rpgw_cache_complete
    @tec_array[actor_id] = 0 if @tec_array[actor_id] == nil
    return @tec_array[actor_id]
  end  
  
  def increase_tec(actor_id, val)
    iex_snsw_tec_rpgw_cache unless @iex_snsw_tec_rpgw_cache_complete
    @tec_array[actor_id] = [[ctec(actor_id) + val, 0].max, tec_cap].min
  end
  
  def decrease_tec(actor_id, val)
    iex_snsw_tec_rpgw_cache unless @iex_snsw_tec_rpgw_cache_complete
    add_tec(actor_id, -val)
  end
  
end

#==============================================================================
# ** Scene_Title
#------------------------------------------------------------------------------
#==============================================================================
class Scene_Title < Scene_Base
  
  alias iex_snsw_tec_load_database load_database unless $@
  def load_database
    iex_snsw_tec_load_database
    load_tec_database
  end
  
  def load_tec_database
    for obj in ($data_skills + $data_weapons)
      next if obj == nil
      obj.iex_snsw_tec_rpgw_cache if obj.is_a?(RPG::Weapon)
      obj.iex_snsw_tec_rpgs_cache if obj.is_a?(RPG::Skill)
    end  
  end
  
end  

#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#==============================================================================
class Game_Battler
  
  def tec ; return 0 end
  def tecmax ; return 0 end  
  def increase_tec(amt) ; end  
  def decrease_tec(amt) ; increase_tec(-amt) end
  
  alias iex_snsw_tec_attack_effect attack_effect unless $@
  def attack_effect(attacker)
    iex_snsw_tec_attack_effect(attacker)
    if attacker.actor?
      attacker.process_tec(attacker, self)  
    end  
  end
  
  alias iex_snsw_tec_skill_effect skill_effect unless $@
  def skill_effect(user, obj)
    iex_snsw_tec_skill_effect(user, obj)
    if user.actor?
      user.process_tec(user, self, obj)  
    end  
  end
  
end

#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#==============================================================================
class Game_Actor < Game_Battler
    
  IEX::TEC::AFFECTS.each { |meth|
    meth = meth.downcase
    aStr = %Q(
      alias iex_snsw_tec_#{meth} #{meth} unless $@
      def #{meth}
        rate = IEX::TEC::TEC_RATES['all']
        rate = IEX::TEC::TEC_RATES['#{meth}'] if IEX::TEC::TEC_RATES.has_key?('#{meth}')
        bs = iex_snsw_tec_#{meth}
        bs *= 100 + (tec * rate.to_i / 100)
        bs /= 100.0
        return Integer(bs)
      end
    )
    module_eval(aStr)
  }
  
  def tec 
    eq = weapons[0]
    case IEX::TEC::TEC_MANAGEMENT 
    when 0
      @tec_cache = {} if @tec_cache == nil
      if eq != nil
        @tec_cache[eq.id] = 0 if @tec_cache[eq.id] == nil
        return @tec_cache[eq.id]
      end 
    when 1  
      return eq.ctec(@actor_id) if eq != nil 
    end  
    return 0
  end
  
  def tecmax
    eq = weapons[0]
    return eq.tec_cap unless eq.nil?
    return 0
  end
  
  def increase_tec(amt)
    eq = weapons[0]
    case IEX::TEC::TEC_MANAGEMENT 
    when 0
      @tec_cache = {} if @tec_cache == nil
      if eq != nil
        @tec_cache[eq.id] = 0 if @tec_cache[eq.id] == nil
        @tec_cache[eq.id] = [[@tec_cache[eq.id] + amt, 0].max, tecmax].min
      end
    when 1  
      eq.increase_tec(@actor_id, amt) if eq != nil
    end  
  end
  
end

