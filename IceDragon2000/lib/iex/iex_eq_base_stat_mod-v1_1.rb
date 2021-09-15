#==============================================================================#
# ** IEX(Icy Engine Xelion) - Equipment Base Stat Mod
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon
# ** Script-Status : Addon (Equipment)
# ** Script Type   : Base Stat Modifier
# ** Date Created  : 11/14/2010
# ** Date Modified : 07/21/2011
# ** Requested By  : projectlight
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# This script allows equipment to modify an actors base stat.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FEATURES
#------------------------------------------------------------------------------#
# V1.0
#  Notetags! Can be placed in Skill and Item noteboxes
#------------------------------------------------------------------------------#
#  <stat stat_mod: x%> # Affects the Base Stat by percentage
#  <stat stat_mod: +/-x> # Affects the main stat by fixed amount
#   replace stat with
#   atk
#   def
#   spi
#   agi
#   maxhp
#   maxmp
#   
#   These require the Dex and Res stat (By Yanfly)
#   dex
#   res
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
# 
# (DD/MM/YYYY)
#  11/14/2010 - V1.0  Finished Script
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
$imported["IEX_EQ_Base_Stat_Mod"] = true
#==============================================================================#
# ** IEX::EQ_STAT_MOD
#==============================================================================#
module IEX
  module EQ_STAT_MOD
  #--------------------------------------------------------------------------#
  # * AFFECTS
  #--------------------------------------------------------------------------#
  # My advice is, don't mess with this, the strings are case sensitive
  # If you make even 1 mistake you will receive an error
  #--------------------------------------------------------------------------#
    AFFECTS = ['maxhp', 'maxmp', 'atk', 'def', 'spi', 'agi']
    
    AFFECTS.push('dex') if $imported["DEX Stat"] # // If YEM Dex Stat is present
    AFFECTS.push('res') if $imported["RES Stat"] # // If YEM Res Stat is present
  end
end

#==============================================================================#
# ** RPG::BaseItem
#==============================================================================#
class RPG::BaseItem
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_eq_base_stat_mod
  #--------------------------------------------------------------------------#  
  def iex_eq_base_stat_mod()
    @iex_base_stat_mod_complete = false
    
    @iex_base_stat_mod = {}
    @iex_base_stat_mod["MAXHP"] = 100
    @iex_base_stat_mod["MAXMP"] = 100
    @iex_base_stat_mod["ATK"] = 100
    @iex_base_stat_mod["DEF"] = 100
    @iex_base_stat_mod["AGI"] = 100
    @iex_base_stat_mod["SPI"] = 100
    @iex_base_stat_mod["DEX"] = 100
    @iex_base_stat_mod["RES"] = 100
    
    @iex_base_stat_change = {}
    @iex_base_stat_change["MAXHP"] = 0
    @iex_base_stat_change["MAXMP"] = 0
    @iex_base_stat_change["ATK"] = 0
    @iex_base_stat_change["DEF"] = 0
    @iex_base_stat_change["AGI"] = 0
    @iex_base_stat_change["SPI"] = 0
    @iex_base_stat_change["DEX"] = 0
    @iex_base_stat_change["RES"] = 0
    
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when /<(\w+)[ ]*(?:STAT_MOD|stat mod):[ ]*(\d+)([%%])>/i
      val = $2.to_i
      case $1.to_s
      when /(?:MAXHP)/i
        @iex_base_stat_mod["MAXHP"] = val
      when /(?:MAXMP)/i 
        @iex_base_stat_mod["MAXMP"] = val
      when /(?:ATK)/i
        @iex_base_stat_mod["ATK"] = val
      when /(?:DEF)/i  
        @iex_base_stat_mod["DEF"] = val
      when /(?:AGI)/i  
        @iex_base_stat_mod["AGI"] = val
      when /(?:SPI)/i
        @iex_base_stat_mod["SPI"] = val
      when /(?:DEX)/i
        @iex_base_stat_mod["DEX"] = val
      when /(?:RES)/i  
        @iex_base_stat_mod["RES"] = val
      end  
    when /<(\w+)[ ]*(?:STAT_MOD|stat mod):[ ]*([\+\-]?\d+)>/i
      val = $2.to_i
      case $1.to_s
      when /(?:MAXHP)/i
        @iex_base_stat_change["MAXHP"] = val
      when /(?:MAXMP)/i 
        @iex_base_stat_change["MAXMP"] = val
      when /(?:ATK)/i
        @iex_base_stat_change["ATK"] = val
      when /(?:DEF)/i  
        @iex_base_stat_change["DEF"] = val
      when /(?:AGI)/i  
        @iex_base_stat_change["AGI"] = val
      when /(?:SPI)/i
        @iex_base_stat_change["SPI"] = val
      when /(?:DEX)/i
        @iex_base_stat_change["DEX"] = val
      when /(?:RES)/i  
        @iex_base_stat_change["RES"] = val
      end  
    end  
    }
    @iex_base_stat_mod_complete = true
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_eq_bs_stat_mod
  #--------------------------------------------------------------------------#  
  def iex_eq_bs_stat_mod( stat )
    iex_eq_base_stat_mod unless @iex_base_stat_mod_complete
    return @iex_base_stat_mod[stat.to_s.upcase]
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_eq_bs_stat_change
  #--------------------------------------------------------------------------#  
  def iex_eq_bs_stat_change( stat )
    iex_eq_base_stat_mod unless @iex_base_stat_mod_complete
    return @iex_base_stat_change[stat.to_s.upcase]
  end
  
end

#==============================================================================#
# ** Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler
  
  IEX::EQ_STAT_MOD::AFFECTS.each { |stat|
    aStr = %Q(
    alias iex_eq_bs_stat_mod_base_#{stat} base_#{stat} unless $@
    def base_#{stat}
      bs = iex_eq_bs_stat_mod_base_#{stat}
      equips.compact.each { |eq|
        bs = bs * eq.iex_eq_bs_stat_mod('#{stat}') / 100.0
      }
      return Integer(bs)
    end
  
    alias iex_eq_bs_stat_change_#{stat} #{stat} unless $@
    def #{stat}
      ss = iex_eq_bs_stat_change_#{stat}
      equips.compact.each { |eq|
        ss += eq.iex_eq_bs_stat_change('#{stat}')
      }
      return Integer(ss)
    end
    )
    module_eval(aStr)
  }
  
end

#==============================================================================#
# ** END OF FILE
#==============================================================================#