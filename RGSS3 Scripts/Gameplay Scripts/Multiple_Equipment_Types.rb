#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Multiple Equip Types
#  Author: Kread-EX
#  Version 1.01
#  Release date: 20/03/2012
#
#  Made for Hesufo.
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
 
#------------------------------------------------------------------------------
#  ▼ UPDATES
#------------------------------------------------------------------------------
# # 20/01/2013. Fixed a bug with skill weapon requirements.
#------------------------------------------------------------------------------
#  ▼ TERMS OF USAGE
#------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work for commercial purposes if you like it.
# #  Credit is appreciated.
# #
# # For support:
# # grimoirecastle.wordpress.com
# # rpgmakerweb.com
#------------------------------------------------------------------------------
#  ▼ INTRODUCTION
#------------------------------------------------------------------------------
# # Allows equipment to have more than one different type.
#------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#------------------------------------------------------------------------------
# # Just add <new_equiptypes: x> in the weapon or armor's notebox, whilst x is
# # the type ID. You can add more than one type ID, separated by commas.
#------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#------------------------------------------------------------------------------
# # List of aliases and overwrites:
# #
# # DataManager
# # load_database (alias)
# # load_net_notetags (new method)
# #
# # RPG::EquipItem
# # load_net_notetags (new method)
# # new_etypes (new attr method)
# #
# # RPG::Weapon
# # wtype_id (alias)
# #
# # RPG::Armor
# # atype_id (alias)
# #
# # Game_BattlerBase
# # equip_wtype_ok? (overwrite)
# # equip_atype_ok? (overwrite)
# #
# # Game_Actor
# # wtype_equipped? (overwrite)
#------------------------------------------------------------------------------

($imported ||= {})['KRX-MultipleEquipTypes'] = true

puts 'Load: Multiple Equip Types v1.01 by Kread-EX'

module KRX
  
  module REGEXP
    EQUIP_TYPES = /<new_equiptypes:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
  end
  
end

#===========================================================================
# ■ DataManager
#===========================================================================

module DataManager  
	#--------------------------------------------------------------------------
	# ● Loads the database
	#--------------------------------------------------------------------------
	class << self
		alias_method(:krx_net_dm_load_database, :load_database)
	end
	def self.load_database
		krx_net_dm_load_database
		load_net_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_net_notetags
		groups = [$data_weapons, $data_armors]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_net_notetags
			end
		end
		puts "Read: Multiple Equip Types Notetags"
	end
end

#==========================================================================
# ■ RPG::EquipItem
#==========================================================================

class RPG::EquipItem < RPG::BaseItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader   :new_etypes
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_net_notetags
    @new_etypes = []
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::EQUIP_TYPES
        $1.scan(/\d+/).each {|i| @new_etypes.push(i.to_i)}
			end
		end
  end
end

#==========================================================================
# ■ RPG::Weapon
#==========================================================================

class RPG::Weapon < RPG::EquipItem
	#--------------------------------------------------------------------------
	# ● Returns the type IDs
	#--------------------------------------------------------------------------
  alias_method(:krx_net_rw_wid, :wtype_id)
  def wtype_id
    @new_etypes << krx_net_rw_wid
  end
end

#==========================================================================
# ■ RPG::Armor
#==========================================================================

class RPG::Armor < RPG::EquipItem
	#--------------------------------------------------------------------------
	# ● Returns the type IDs
	#--------------------------------------------------------------------------
  alias_method(:krx_net_ra_aid, :atype_id)
  def atype_id
    @new_etypes << krx_net_ra_aid
  end
end

#==========================================================================
# ■ Game_BattlerBase
#==========================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● Determine if a type of weapon can be equipped
  #--------------------------------------------------------------------------
  def equip_wtype_ok?(wtype_id)
    wtype_id.each do |id|
      return true if features_set(FEATURE_EQUIP_WTYPE).include?(id)
    end
    false
  end
  #--------------------------------------------------------------------------
  # ● Determine if a type of armor can be equipped
  #--------------------------------------------------------------------------
  def equip_atype_ok?(atype_id)
    atype_id.each do |id|
      return true if features_set(FEATURE_EQUIP_ATYPE).include?(id)
    end
    false
  end
end

#==========================================================================
# ■ Game_Actor
#==========================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● Determine if a weapon with a specific type is equipped
  #--------------------------------------------------------------------------
  def wtype_equipped?(wtype_id)
    weapons.any? {|weapon| weapon.wtype_id.include?(wtype_id)}
  end
end