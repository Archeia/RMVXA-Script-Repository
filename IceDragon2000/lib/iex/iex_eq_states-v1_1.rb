#==============================================================================#
# ** IEX(Icy Engine Xelion) - Equipment States
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Equipment)
# ** Script Type   : States from Equipment
# ** Date Created  : 11/28/2010
# ** Date Modified : 07/24/2011
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# This script gives equipment the ability to have autosates for there wielders.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FEATURES
#------------------------------------------------------------------------------#
# V1.0
#  Notetags! Can be placed in Equipment noteboxes
#------------------------------------------------------------------------------#
#  <EQUIP_STATE: id, id, id> (or) <equip state: id, id, id>
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** HOW TO USE
#------------------------------------------------------------------------------#
#  In an equipments notebox (Weapon or Armor)
#  put <EQUIP_STATE: id, id, id> or <equip state: id, id, id>
#  The actor will gain the states marked by Id while that piece of equipment
#  is equipped.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
#
# (DD/MM/YYYY)
#  11/28/2010 - V1.0  Finished Script
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
$imported["IEX_Equipment_States"] = true
#==============================================================================#
# ** IEX::REGEXP::EQUIPMENT_STATES
#==============================================================================#
module IEX
  module REGEXP
    module EQUIPMENT_STATES
      EQUIPMENT_STATE = /<(?:EQUIP_STATE|equip state)s?:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
    end
  end
end
 
#==============================================================================#
# ** RPG::BaseItem
#==============================================================================#
class RPG::BaseItem

  #--------------------------------------------------------------------------#
  # * new-method :iex_state_equipment_cache
  #--------------------------------------------------------------------------# 
  def iex_state_equipment_cache()
    @iex_equip_states = []
    self.note.split(/[\r\n]+/).each { |line| 
      case line
      when IEX::REGEXP::EQUIPMENT_STATES::EQUIPMENT_STATE
        $1.scan(/\d+/).each { |state_id|
        @iex_equip_states.push(state_id.to_i) }
      end
    }
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_equip_states
  #--------------------------------------------------------------------------# 
  def iex_equip_states()
    iex_state_equipment_cache if @iex_equip_states.nil?()
    return @iex_equip_states
  end
  
end

#==============================================================================#
# ** Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------#
  # * alias-method :states
  #--------------------------------------------------------------------------# 
  alias :iex_equipment_ga_states :states unless $@
  def states( *args, &block )
    result = iex_equipment_ga_states( *args, &block )
    more_states = []
    equips.compact.each { |eq|
      eq.iex_equip_states.compact.each { |ski_id|
        more_states << $data_states[ski_id]
      }
    }
    return result |= more_states
  end
  
end

#==============================================================================#
# ** END OF FILE
#==============================================================================#