#==============================================================================#
# ** IEX(Icy Engine Xelion) - Attack Uses HP / MP
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Equipment and Enemies)
# ** Script Type   : Equipment and Enemy Atk Modifier
# ** Date Created  : 11/06/2010
# ** Date Modified : 07/17/2011
# ** Requested By  : tafgames
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# >.O Okay so this script adds a new feature to your equipment and enemies
# that causes them to use hp/mp when you attack.
# >_< What!?
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FEATURES
#------------------------------------------------------------------------------#
# V1.0
#  Notetags! Can be placed in Equipment and Enemy noteboxes
#------------------------------------------------------------------------------#
# <hp atk cost: +/-x> or <health atk cost: +/-x>
# Anytime a normal attack is done x amount will be subtracted from the User's
# Hp. If the value is negative, it will subtract from the total cost.
# So
# <hp atk cost: 2>
# Everytime an atk is done 2 hp is lost
# <hp atk cost: 2> and <hp atk cost: -1>
# Everytime an atk is done 1 hp is lost the -1 subtracts from the total cost
#
# If this is applied to multiple armors and weapons, the cost is added together
# for the user.
#
# <sp atk cost: +/-x> or <mp atk cost: +/-x>
# Does the same thing as the <hp atk cost> excpet with mp
#
# <sp low allow atk> or <mp low allow atk> 
# <hp low allow atk> or <health low allow atk> 
# If this tag is used the atk can be used regardles of much hp/mp they have
# By default if the user doesn't have enough hp/mp they cannot attack
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
# 
# (DD/MM/YYYY)
#  11/05/2010 - V1.0  Finished Script
#  07/17/2011 - V1.1  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment. 
#
#------------------------------------------------------------------------------#
$imported ||= {} 
$imported["IEX_ATK_HP_MP"] = true
#==============================================================================
# ** IEX::REGEXP::ATK_HP_SP_USE
#------------------------------------------------------------------------------
#==============================================================================
module IEX
  module REGEXP
    module ATK_HP_SP_USE
      COST = /<(\w+)[ ]*(?:ATK_COST|atk cost):[ ]*([\+\-]?\d+)>/i
 ALLOW_ATK = /<(\w+)[ ]*(?:LOW_ALLOW_ATK|low allow atk)>/i
    end
  end
end
 
#==============================================================================#
# ** RPG::BaseItem
#==============================================================================#
class RPG::BaseItem
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_hpmp_bs_cache
  #--------------------------------------------------------------------------#  
  def iex_hpmp_bs_cache()
    @iex_hpmp_cache_complete = false
    @iex_atk_hp_cost = 0
    @iex_atk_mp_cost = 0
    @iex_allow_low_hp_atk = false
    @iex_allow_low_mp_atk = false
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when IEX::REGEXP::ATK_HP_SP_USE::COST
      cost = $2.to_i
      case $1.to_s
      when /(?:HP|HEALTH)/i
        @iex_atk_hp_cost = cost
      when /(?:SP|MP)/i
        @iex_atk_mp_cost = cost
      end  
    when IEX::REGEXP::ATK_HP_SP_USE::ALLOW_ATK  
      case $1.to_s
      when /(?:HP|HEALTH)/i
        @iex_allow_low_hp_atk = true
      when /(?:SP|MP)/i
        @iex_allow_low_mp_atk = true
      end 
    end
    }
    @iex_hpmp_cache_complete = true
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_atk_hp_cost
  #--------------------------------------------------------------------------#  
  def iex_atk_hp_cost()
    iex_hpmp_bs_cache unless @iex_hpmp_cache_complete
    return @iex_atk_hp_cost
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_atk_mp_cost
  #--------------------------------------------------------------------------#  
  def iex_atk_mp_cost()
    iex_hpmp_bs_cache unless @iex_hpmp_cache_complete
    return @iex_atk_mp_cost
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_allow_low_hp_atk
  #--------------------------------------------------------------------------#  
  def iex_allow_low_hp_atk()
    iex_hpmp_bs_cache unless @iex_hpmp_cache_complete
    return @iex_allow_low_hp_atk
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_allow_low_mp_atk
  #--------------------------------------------------------------------------#  
  def iex_allow_low_mp_atk()
    iex_hpmp_bs_cache unless @iex_hpmp_cache_complete
    return @iex_allow_low_mp_atk 
  end
  
end

#==============================================================================#
# ** RPG::Enemy
#==============================================================================#
class RPG::Enemy
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_hpmp_en_cache
  #--------------------------------------------------------------------------# 
  def iex_hpmp_en_cache()
    @iex_hpmp_en_cache_complete = false
    @iex_atk_hp_cost = 0
    @iex_atk_mp_cost = 0
    @iex_allow_low_hp_atk = false
    @iex_allow_low_mp_atk = false
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when IEX::REGEXP::ATK_HP_SP_USE::COST
      cost = $2.to_i
      case $1.to_s
      when /(?:HP|HEALTH)/i
        @iex_atk_hp_cost = cost
      when /(?:SP|MP)/i
        @iex_atk_mp_cost = cost
      end  
    when IEX::REGEXP::ATK_HP_SP_USE::ALLOW_ATK  
      case $1.to_s
      when /(?:HP|HEALTH)/i
        @iex_allow_low_hp_atk = true
      when /(?:SP|MP)/i
        @iex_allow_low_mp_atk = true
      end 
    end
    }
    @iex_hpmp_en_cache_complete = true
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_atk_hp_cost
  #--------------------------------------------------------------------------# 
  def iex_atk_hp_cost()
    iex_hpmp_en_cache unless @iex_hpmp_en_cache_complete
    return @iex_atk_hp_cost
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_atk_mp_cost
  #--------------------------------------------------------------------------# 
  def iex_atk_mp_cost()
    iex_hpmp_en_cache unless @iex_hpmp_en_cache_complete
    return @iex_atk_mp_cost
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_allow_low_hp_atk
  #--------------------------------------------------------------------------#
  def iex_allow_low_hp_atk()
    iex_hpmp_en_cache unless @iex_hpmp_en_cache_complete
    return @iex_allow_low_hp_atk
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_allow_low_mp_atk
  #--------------------------------------------------------------------------#
  def iex_allow_low_mp_atk()
    iex_hpmp_en_cache unless @iex_hpmp_en_cache_complete
    return @iex_allow_low_mp_atk 
  end
  
end

#==============================================================================#
# ** Game_BattleAction
#==============================================================================#
class Game_BattleAction

  #--------------------------------------------------------------------------#
  # * alias-method :valid?
  #--------------------------------------------------------------------------#  
  alias :iex_weapon_use_mp_valid? :valid? unless $@
  def valid?( *args, &block )
    if attack?
      return false unless @battler.hp >= @battler.calculate_attack_hp_cost
      return false unless @battler.mp >= @battler.calculate_attack_mp_cost
    end 
    iex_weapon_use_mp_valid?( *args, &block )
  end
  
end

#==============================================================================#
# ** Game_Battler
#==============================================================================#
class Game_Battler
  
  #--------------------------------------------------------------------------#
  # * null-methods :allow_low_*_atk / calculate_attack_*_cost
  #--------------------------------------------------------------------------#        
  def allow_low_hp_atk ; return false end  
  def allow_low_mp_atk ; return false end  
  def calculate_attack_hp_cost ; return 0 end    
  def calculate_attack_mp_cost ; return 0 end
  
end

#==============================================================================#
# ** Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler 
  
  #--------------------------------------------------------------------------#
  # * super-method :allow_low_hp_atk
  #--------------------------------------------------------------------------#      
  def allow_low_hp_atk()
    for eq in equips.compact
      return true if eq.iex_allow_low_hp_atk
    end  
    super()
  end
  
  #--------------------------------------------------------------------------#
  # * super-method :allow_low_mp_atk
  #--------------------------------------------------------------------------#    
  def allow_low_mp_atk()
    for eq in equips.compact
      return true if eq.iex_allow_low_mp_atk
    end  
    super()
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :calculate_attack_hp_cost
  #--------------------------------------------------------------------------#    
  def calculate_attack_hp_cost()
    hp_cost = 0
    for eq in equips.compact
      hp_cost += eq.iex_atk_hp_cost
    end  
    hp_cost = [hp_cost, 0].max
    return hp_cost
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :calculate_attack_mp_cost
  #--------------------------------------------------------------------------#    
  def calculate_attack_mp_cost()
    mp_cost = 0
    for eq in equips.compact
      mp_cost += eq.iex_atk_mp_cost
    end  
    mp_cost = [mp_cost, 0].max
    return mp_cost
  end
  
end

#==============================================================================#
# ** Game_Enemy
#==============================================================================#
class Game_Enemy < Game_Battler 
  
  #--------------------------------------------------------------------------#
  # * super-method :allow_low_mp_atk
  #--------------------------------------------------------------------------#  
  def allow_low_hp_atk()
    return true if enemy.iex_allow_low_hp_atk
    super()
  end
  
  #--------------------------------------------------------------------------#
  # * super-method :allow_low_mp_atk
  #--------------------------------------------------------------------------#
  def allow_low_mp_atk()
    return true if enemy.iex_allow_low_mp_atk 
    super()
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :calculate_attack_hp_cost
  #--------------------------------------------------------------------------#
  def calculate_attack_hp_cost()
    hp_cost = [enemy.iex_atk_hp_cost , 0].max
    return hp_cost
  end
    
  #--------------------------------------------------------------------------#
  # * new-method :calculate_attack_mp_cost
  #--------------------------------------------------------------------------#
  def calculate_attack_mp_cost()
    mp_cost = [enemy.iex_atk_mp_cost, 0].max
    return mp_cost
  end
  
end

#==============================================================================#
# ** Scene Battle
#==============================================================================#
class Scene_Battle < Scene_Base 

  #--------------------------------------------------------------------------#
  # * alias-method :execute_action_attack
  #--------------------------------------------------------------------------#
  alias :iex_weapon_use_mp_execute_action_attack :execute_action_attack unless $@
  def execute_action_attack( *args, &block )
    @active_battler.mp -= @active_battler.calculate_attack_mp_cost
    @active_battler.hp -= @active_battler.calculate_attack_hp_cost
    iex_weapon_use_mp_execute_action_attack( *args, &block )
  end
  
end

#==============================================================================#
# ** END OF FILE
#==============================================================================#