#==============================================================================#
# ** IEX(Icy Engine Xelion) - Can Attack EX
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Requires      : IEX - Attack Costs/Patch (Optional but Recommended)
# ** Script-Status : Addon (Weapons)
# ** Script Type   : Can Attack?
# ** Date Created  : 01/31/2011
# ** Date Modified : 07/17/2011
# ** Script Tag    : IEX - Can Attack EX
# ** Difficulty    : Lunatic
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# Basically a copy and paste job, using the Skill Can Use EX
# This allows special conditions for weapons in order to attack.
# Such Hp/Mp needed to use the item or another item which is needed.
# This is a lunatic script, meaning it requires scripting knowledge to use it
# to its fullest.
# NOTE* You MUST have IEX - Attack Costs/Patch for this script to work properly
# either that or BEM.
# Even if your not using the Attack Costs script.
#------------------------------------------------------------------------------#
#==============================================================================#
# ** HOW TO USE
#------------------------------------------------------------------------------#
# 1.0
#  Notetags! Can be placed in Weapon noteboxes.
#==============================================================================#
# <condition: phrase>
# Replace phrase. (Game_Battler - Lunatic)
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
#
# Most battle systems, except GTBS
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#------------------------------------------------------------------------------#
# 
# Below 
#  Materials
#  Battle Engines
#  Attack Cost/Patch
#
# Above 
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES 
#------------------------------------------------------------------------------# 
# ** I'll put them in one day...
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
#
# (DD/MM/YYYY)
#  01/09/2011 - V1.0  Started Script
#  07/17/2011 - V1.1  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#  
#
#  Non at the moment
#
#------------------------------------------------------------------------------#
$imported ||= {} 
$imported["IEX_CanAttackEX"] = true
#==============================================================================#
# ** IEX::ATTACK_COSTS - Patch for "IEX - Attack Costs"
#==============================================================================#
module IEX
  module ATTACK_COSTS
#==============================================================================#
#                           Start Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#  
    UNARMED_WEAPON = 0
#==============================================================================#
#                           End Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#    
  end
end

#===============================================================================#
# ** Game_Battler
#===============================================================================#
class Game_Battler
  
  #--------------------------------------------------------------------------#
  # * new-method :ex_can_attack?
  #--------------------------------------------------------------------------#
  # Runs through all the items conditions and breaks if a false is found
  # <condition: cond_name>
  # <condition: alwaystrue>
  #--------------------------------------------------------------------------#
  #                 item == RPG::Weapon
  def ex_can_attack?( item, tag = :can_use )
    return true if item.nil?() # // Return true if no weapon
    can_use   = true
    icon      = 0
    need_text = ""
    for cond in item.use_conditions
      case cond.to_s.upcase
    #--------------------------------------------------------------------------#
    # EDIT HERE
    #--------------------------------------------------------------------------#
    # ------------------------------------------------------------------------ #
    # <condition: alwaystrue>
    # The skill can always be used, as long as the other conditions (Hp/Mp Costs)
    # are acheived
    # ------------------------------------------------------------------------ #
      when "ALWAYSTRUE"
        can_use = true
    # ------------------------------------------------------------------------ #
    # <condition: alwaysfalse>
    # Opposite of alwaystrue
    # ------------------------------------------------------------------------ #
      when "ALWAYSFALSE" 
        can_use = false
    # ------------------------------------------------------------------------ #
    # <condition: state x>
    # Requires that the user have x state
    # ------------------------------------------------------------------------ #    
      when /(?:STATE)[ ](\d+)/i  
        can_use = @states.include?($1.to_i)
    # ------------------------------------------------------------------------ #
    # Hp/Mp Requirements
    # -Rate-
    # <condition: hp sign x%> <condition: mp sign x%>
    # EG. <condition: hp => 50%>  <condition: mp < 50%>
    #
    # -Set-
    # <condition: hp sign x> <condition: mp sign x>
    # EG. <condition: hp => 50>  <condition: mp < 50>
    #
    # sign can be:
    # == Equal to
    # >  Greater than
    # <  Less than
    # <= Less than or Equal to
    # >= Greater than or Equal to
    # != Not Equal to
    # ------------------------------------------------------------------------ #      
      when /(HP|MP)[ ](.*)[ ](\d+)([%%])/i
        val = $3.to_i
        sign = $2.to_s
        case $1.to_s.upcase
        when "HP"
          can_use = eval("self.hp #{sign} IEX::IMath.cal_percent(val, maxhp)")
        when "MP"  
          can_use = eval("self.mp #{sign} IEX::IMath.cal_percent(val, maxmp)")
        end  
      when /(HP|MP)[ ](.*)[ ](\d+)/i
        val = $3.to_i
        sign= $2.to_s
        sign= "==" if sign == "="
        case $1.to_s.upcase
        when "HP"
          can_use = eval("self.hp #{sign} val")
        when "MP"  
          can_use = eval("self.mp #{sign} val")
        end   
    # ------------------------------------------------------------------------ #
    # <condition: item x:y>
    # Requires that the user has x item, of y amount
    # ------------------------------------------------------------------------ #  
      when /ITEM[ ](\d+):(\d+)/i
        iid = $1.to_i
        amt = $2.to_i
        can_use = $game_party.item_number($data_items[iid]) >= amt
        
    # << You start adding here    
    # // Yup here
    #--------------------------------------------------------------------------#
    # STOP EDIT HERE
    #--------------------------------------------------------------------------#    
      else
        can_use = true
      end
      break if can_use == false
    end
    return can_use if tag == :can_use
  end
  
end

#==============================================================================#
# ** IEX::IMath
#==============================================================================#
module IEX
  module IMath
    
    def self.cal_percent( perc, val )
      return Integer(val.to_f * perc.to_f / 100.0)
    end  
    
  end
end

#==============================================================================#
# ** RPG::Weapon
#==============================================================================#
class RPG::Weapon

  #--------------------------------------------------------------------------#
  # * new-method :ica_ex_cache
  #--------------------------------------------------------------------------#    
  def ica_ex_cache()
    @ica_ex_cache_complete = false
    @scu_conditions = []
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when /<(?:CONDITION|cond|can use|canuse|can_use):[ ](.*)>/i
      @scu_conditions.push($1)
    end  
    }
    @ica_ex_cache_complete = true
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :use_conditions
  #--------------------------------------------------------------------------#    
  def use_conditions()
    ica_ex_cache unless @ica_ex_cache_complete
    return @scu_conditions 
  end
  
end

#===============================================================================#
# ** Game_Battler
#===============================================================================#
class Game_Battler

  #--------------------------------------------------------------------------#
  # * new-method :ac_can_attack?
  #--------------------------------------------------------------------------#   
  def ac_can_attack?() ; return true ; end unless method_defined? :ac_can_attack?
  
  #--------------------------------------------------------------------------#
  # * alias-method :ac_can_attack?
  #--------------------------------------------------------------------------#      
  alias :iex_canatk_ac_can_attack? :ac_can_attack? unless $@
  def ac_can_attack?()
    return false unless ex_can_attack?( attack_object )
    return iex_canatk_ac_can_attack?()
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :attack_object
  #--------------------------------------------------------------------------#   
  def attack_object ; return nil ; end
  
end

#===============================================================================#
# ** Game_Actor
#===============================================================================#
class Game_Actor < Game_Battler

  #--------------------------------------------------------------------------#
  # * new-method :attack_object
  #--------------------------------------------------------------------------#  
  def attack_object()
    eq = $data_weapons[IEX::ATTACK_COSTS::UNARMED_WEAPON]
    eq = weapons.compact[0] unless weapons.compact[0].nil?  
    return eq
  end
  
end

#===============================================================================#
# Game_Enemy
#===============================================================================#
class Game_Enemy < Game_Battler

  #--------------------------------------------------------------------------#
  # * new-method :attack_object
  #--------------------------------------------------------------------------#  
  def attack_object()
    eq = $data_weapons[IEX::ATTACK_COSTS::UNARMED_WEAPON]
    return eq
  end
  
end

#==============================================================================#
# ** Game_BattleAction
#==============================================================================#
class Game_BattleAction

  #--------------------------------------------------------------------------#
  # * alias-method :valid?
  #--------------------------------------------------------------------------#
  alias :iex_canatk_valid? :valid? unless $@
  def valid?( *args, &block )
    if attack?
      unless @battler.attack_object.nil?
        return false unless @battler.ac_can_attack?
      end  
    end 
    iex_canatk_valid?( *args, &block )
  end
  
end

#===============================================================================#
# ** Window_ActorCommand
#===============================================================================#
class Window_ActorCommand < Window_Command
  
  #--------------------------------------------------------------------------#
  # * alias-method :enabled?
  #--------------------------------------------------------------------------# 
  def enabled?( obj = nil ) ; return true ; end unless method_defined? :enabled?
  
  #--------------------------------------------------------------------------
  # * alias method :enabled?
  #--------------------------------------------------------------------------
  alias :iex_canatk_enabled? :enabled? unless $@
  def enabled?( obj = nil )
    return false unless @actor.ac_can_attack?() if obj == :attack
    iex_canatk_enabled?( obj )
  end
  
end

#==============================================================================#
# ** END OF FILE
#==============================================================================#