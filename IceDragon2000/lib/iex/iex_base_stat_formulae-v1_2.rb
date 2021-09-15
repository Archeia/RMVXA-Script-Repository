#==============================================================================#
# ** IEX(Icy Engine Xelion) - Base Stat Formulae
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Requested By  : RuGeaR1277
# ** Script-Status : Addon (Actor Stats)
# ** Script Type   : Base Stat Formulae
# ** Date Created  : 11/16/2010 (DD/MM/YYYY)
# ** Date Modified : 07/17/2011 (DD/MM/YYYY)
# ** Script Tag    : IEX - Base Stat Formulae
# ** Difficulty    : Hard
# ** Version       : 1.2
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# *WANRING* Any stat mentioned will have its Base formulae OVERWRITTEN
# Similar to the YEM New Stats, dex and res stat formulae system. 
# This was written to affect all and any base stats, you can also add custom
# base stats if needed.
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
#==============================================================================#
# ** CHANGES 
#------------------------------------------------------------------------------#
# Classes
#   Game_Battler
#     new-method :base_stat_value
#     meta-prog  - base_(stat)
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
#   Every other custom script that changes the base_stats
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
# (DD/MM/YYYY)
#  11/16/2010 - V1.0  Completed Script
#  11/16/2010 - V1.0a Equipment changes weren't added to stats
#                    Added the YEM Equipment Overhaul Compatabilty
#  01/02/2011 - V1.1  Changed Stat Calculation from string evaluation to a
#                    direct method
#  01/08/2011 - V1.1a Few Changes, not worth mentioning
#  07/17/2011 - V1.2  Edited for the IEX Recall
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
$imported["IEX_Base_Stat_Formulae"] = true
#==============================================================================#
# ** IEX::BASE_STAT_FORMULAE
#==============================================================================#
module IEX
  module BASE_STAT_FORMULAE
#==============================================================================#
#                           Start Customization
#------------------------------------------------------------------------------#
#==============================================================================#   
  #--------------------------------------------------------------------------#
  # * STATS
  #--------------------------------------------------------------------------#
  # This is an array of all the affected base stats, if you remove one
  # of the elements, it will use the original method.
  #--------------------------------------------------------------------------#
    STATS = ['maxhp', 'maxmp', 'atk', 'def', 'spi', 'agi', 'dex', 'res']
  #--------------------------------------------------------------------------#
  # * EQ_STATS
  #--------------------------------------------------------------------------#
  # This is the list of stats that gain from Equipment.
  #--------------------------------------------------------------------------#
 EQ_STATS = ['atk', 'def', 'spi', 'agi', 'dex', 'res']
   
  end # End BASE_STAT_FORMULAE
end # End IEX

#==============================================================================#
# ** Game_Battler - Stat Formulae
#==============================================================================#
class Game_Battler
  
  #--------------------------------------------------------------------------#
  # * BASE_ACTOR_STATS
  #--------------------------------------------------------------------------#
  # This method handles the
  #--------------------------------------------------------------------------#
  def base_stat_value(stat)
    value = 1
    return value unless self.is_a?(Game_Actor)
    case @actor_id
    when -1
      
    else # Else if actor notstated
      case stat.upcase
      #when "MAXHP"
      #  value = maxhp_stat_points * 200
      #when "MAXMP"  
      #  value = maxmp_stat_points * 100
      #when "ATK"  
      #  value = atk_stat_points * 2 + 10
      #when "DEF"  
      #  value = def_stat_points * 2 + 5
      #when "SPI"   
      #  value = spi_stat_points * 2 + 10
      #when "AGI" 
      #  value = agi_stat_points * 3 + 10
      #when "DEX"  
      #  value = dex_stat_points * 3 + 5
      #when "RES"  
      #  value = res_stat_points * 3 + 3
      when "MAXHP"
        value = actor.parameters[0, @level]
      when "MAXMP"  
        value = actor.parameters[1, @level]
      when "ATK"  
        value = actor.parameters[2, @level]
      when "DEF"  
        value = actor.parameters[3, @level]
      when "SPI"   
        value = actor.parameters[4, @level]
      when "AGI" 
        value = actor.parameters[5, @level]
      when "DEX"  
        value = @level * 4 + 5
      when "RES"  
        value = @level * 4 + 5
      end  
    end  
    return value
  end
#==============================================================================#
#                           End Customization
#------------------------------------------------------------------------------#
#==============================================================================#   
end

#==============================================================================#
# ** Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler
      
  IEX::BASE_STAT_FORMULAE::STATS.each { |stat|
  aStr = %Q(
  def base_#{stat}
    n = base_stat_value('#{stat}')
    if $imported["EquipmentOverhaul"]
      percent = 100
      case '#{stat}'
      when 'maxhp'
        symm = :hp
      when 'maxmp'
        symm = :mp
      else
        symm = '#{stat}'.to_sym
      end  
      for item in equips.compact
        if item.stat_per.include?(symm)
          percent += aptitude(item.stat_per[symm], symm)
        end  
      end
      n *= percent / 100.0  
      for item in equips.compact
        n += aptitude(item.#{stat}, symm)
      end
    else  
      if IEX::BASE_STAT_FORMULAE::EQ_STATS.include?('#{stat}')
        for item in equips.compact do n += item.#{stat} end
      end    
    end  
    return Integer(n)
  end
  )
  module_eval(aStr)
  }
  
end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#