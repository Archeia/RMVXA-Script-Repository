#==============================================================================#
# ** IEX(Icy Engine Xelion) - Advance Item Check
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Interpreter)
# ** Script Type   : Inverntory Checking
# ** Date Created  : 12/06/2010
# ** Date Modified : 07/17/2011
# ** Requested By  : new
# ** Version       : 1.1
#------------------------------------------------------------------------------#
# Script Call:
# check_items(type, id, amount)
# type
# 0 - Items
# 1 - Weapons
# 2 - Armors
#
# id can be
# Number EG: 1
# Array  EG: [1, 5, 6]
# Range  EG: 2..50
#
# Amount by default is 1
# You can set it higher to check if the player has x amount of an item
#
# For coders
# IEX::IParty.check_items(type, id, amount)
# So you can call it anywhere
#
#==============================================================================#
$imported ||= {} 
$imported["IEX_AdvanceItemCheck"] = true
#==============================================================================#
# ** IEX::IParty
#==============================================================================#
module IEX
  module IParty
    
  #--------------------------------------------------------------------------#
  # * new-method :check_items
  #--------------------------------------------------------------------------#  
    def self.check_items(type, id, amount = 1)
      ids = []
      case id
      when Range
        ids |= id.to_a
      when Array  
        ids |= id 
      else
        ids << id.to_i
      end
      ids.each { |i|
        case type
        when 0
          return false unless $game_party.has_item?($data_items[i])
          return false unless $game_party.item_number($data_items[i]) >= amount
        when 1
          return false unless $game_party.has_item?($data_weapons[i])
          return false unless $game_party.item_number($data_weapons[i]) >= amount
        when 2
          return false unless $game_party.has_item?($data_armors[i])
          return false unless $game_party.item_number($data_armors[i]) >= amount
        end  
      }  
      return true
    end
    
  end  
end

#==============================================================================#
# ** Game_Interpreter
#==============================================================================#
class Game_Interpreter

  #--------------------------------------------------------------------------#
  # * new-method :check_items
  #--------------------------------------------------------------------------#  
  def check_items(type, id, amount = 1)
    return IEX::IParty.check_items(type, id, amount)
  end
  
end

#==============================================================================#
# ** END OF FILE
#==============================================================================#