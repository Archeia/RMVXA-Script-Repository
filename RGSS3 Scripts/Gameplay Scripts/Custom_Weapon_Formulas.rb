#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Custom Weapon Formulas
#  Author: Kread-EX
#  Version 1.01
#  Release date: 13/12/2011
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
 
#------------------------------------------------------------------------------
#  ▼ UPDATES
#------------------------------------------------------------------------------
# # 04/02/2013. Added support for multiple lines.
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
# # Allows weapons to have their own formulas, just like skills. They take
# # precedence over the Attack skill formula.
#------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#------------------------------------------------------------------------------
# # There are 3 parameters.
# # To create the formula itself, just enter it between the boundary tags,
# # exactly like you would do on a skill formula field:
# # <formula>
# # 400 + a.atk
# # </formula>
# #
# # This tag allows you to make your weapon healing your target.
# # <formula_recovery>
# #
# # And with this one, you can set the variance (omitting it sets the variance
# # to 20): # # <formula_variance: number>
#------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#------------------------------------------------------------------------------
# # List of aliases and overwrites:
# #
# # DataManager
# # load_database (alias)
# # load_wepfor_notetags (new method)
# #
# # RPG::Weapon
# # load_wepfor_notetags (new method)
# # formula_eval (new method)
# #
# # Game_Battler
# # make_damage_value (alias)
#------------------------------------------------------------------------------

$imported = {} if $imported.nil?
$imported['KRX-WeaponFormulas'] = true

puts 'Load: Custom Weapon Formulas v1.01 by Kread-EX'

module KRX

	module REGEXP
		WEAPON_FORMULA_START = /<formula>/
		WEAPON_FORMULA_END = /<\/formula>/
		WEAPON_FORMULA_REC = /<formula_recovery>/
		WEAPON_FORMULA_VAR = /<formula_variance:[ ]*(\d+)>/i
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
		alias_method(:krx_wepfor_dm_load_database, :load_database)
	end
	def self.load_database
		krx_wepfor_dm_load_database
		load_wepfor_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_wepfor_notetags
		groups = [$data_weapons]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_wepfor_notetags
			end
		end
		puts "Read: Custom Weapon Formulas Notetags"
	end
end

#==========================================================================
#  ■  RPG::Weapon
#==========================================================================

class RPG::Weapon < RPG::EquipItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
	attr_reader		:formula
	attr_reader		:formula_recovery
	attr_reader		:formula_variance
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_wepfor_notetags
		@formula = nil
		@formula_recovery = false
		@formula_variance = 20
		@note.split(/[\r\n]+/).each do |line|
			case line
			when  KRX::REGEXP::WEAPON_FORMULA_START
				@use_formula = true
			when KRX::REGEXP::WEAPON_FORMULA_END
				@use_formula = false
			when KRX::REGEXP::WEAPON_FORMULA_REC
				@formula_recovery = true
			when KRX::REGEXP::WEAPON_FORMULA_VAR
				@formula_variance = $1.to_i
			else
        @formula ||= '' if @use_formula
				@formula << line if @use_formula
			end
		end
	end
	#--------------------------------------------------------------------------
	# ● Evaluates the formula
	#--------------------------------------------------------------------------
	def formula_eval(a, b, v)
		sign = @formula_recovery ? -1 : 1
		[Kernel.eval(@formula), 0].max * sign rescue 0
	end
end

#==========================================================================
#  ■  Game_Battler
#==========================================================================

class Game_Battler
	#--------------------------------------------------------------------------
	# ● Calculates the damage value
	#--------------------------------------------------------------------------
	alias_method(:krx_wformula_gb_mdv, :make_damage_value)
	def make_damage_value(user, item)
		if item == $data_skills[1] && user.is_a?(Game_Actor)
			user.weapons.each do |wep|
				if wep.formula != nil
					value = wep.formula_eval(user, self, $game_variables)
					value *= item_element_rate(user, item)
					value *= pdr if item.physical?
					value *= mdr if item.magical?
					value *= rec if wep.formula_recovery
					value = apply_critical(value) if @result.critical
					value = apply_variance(value, wep.formula_variance)
					value = apply_guard(value)
					@result.make_damage(value.to_i, item)
					return
				end
			end
		end
		krx_wformula_gb_mdv(user, item)
	end
end